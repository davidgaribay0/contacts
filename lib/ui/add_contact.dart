import 'dart:convert';

import 'package:contacts/ui/common/editor/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:contacts/util/constants.dart' as Constants;
import 'package:flutter/src/widgets/text.dart' as Flutter;
import 'package:contacts/ui/common/application_bar.dart';
import '../db/contact_table.dart';
import '../model/contact.dart';
import 'common/application_bar.dart';
import 'common/input_field.dart';
import 'contact_list.dart';

class Add extends ConsumerWidget {
  Add({Key? key}) : super(key: key);

  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController birthday = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController homeAddress = TextEditingController();
  final FocusNode _focus = FocusNode();

  var phoneNumberMask = MaskTextInputFormatter(
      mask: '(###) ###-####x#####', filter: {"#": RegExp(r'[0-9]')});
  var birthdayMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final QuillController _quillController = QuillController.basic();
  final addFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef watch) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: ApplicationBar(
          "New Contact",
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (addFormKey.currentState!.validate()) {
                  await ContactTable().insert(Contact(
                      name: fullName.text,
                      phoneNumber: phoneNumber.text
                          .replaceAll(RegExp(r'[^\w\s]+'), '')
                          .replaceAll(" ", ""),
                      birthday: birthday.text,
                      email: email.text,
                      address: homeAddress.text,
                      notes: jsonEncode(
                          _quillController.document.toDelta().toJson())));
                  watch.refresh(contactListsProvider);
                  Navigator.pop(context);
                  // nice to have but not needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    // ability to undo crud?? (5 seconds like on gmail?)
                    const SnackBar(
                        content: Flutter.Text(Constants.CONTACT_CREATED)),
                  );
                }
              },
              child: const Flutter.Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Form(
              key: addFormKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Wrap(runSpacing: 15, children: [
                  InputField(
                    fullName,
                    "Full Name",
                    TextInputType.text,
                    // autoFocus: true,
                    validation: (value) {
                      if (value == null || value.isEmpty) {
                        return Constants.FULL_NAME_REQUIRED;
                      }
                      return null;
                    },
                  ),
                  InputField(phoneNumber, "Phone Number", TextInputType.phone,
                      inputFormatters: [phoneNumberMask]),
                  InputField(
                    birthday,
                    "Birthday",
                    TextInputType.phone,
                    inputFormatters: [birthdayMask],
                  ),
                  InputField(
                      email, "Email Address", TextInputType.emailAddress),
                  InputField(homeAddress, "Home Address", TextInputType.text),
                  Row(children: const [
                    Flutter.Text(
                      "Notes",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ]),
                  Toolbar(quillController: _quillController),
                  Flex(direction: Axis.horizontal, children: [
                    Expanded(
                      child: QuillEditor(
                          focusNode: _focus,
                          autoFocus: false,
                          controller: _quillController,
                          readOnly: true,
                          scrollController: ScrollController(),
                          scrollable: true,
                          padding: EdgeInsets.zero,
                          expands: false),
                    ),
                  ])
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
