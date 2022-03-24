import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:contacts/model/contact.dart';
import 'package:contacts/ui/common/application_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common/input_field.dart';
import '../db/contact_table.dart';
import 'contact_list.dart';
import 'edit.dart';
import 'package:flutter/src/widgets/text.dart' as Flutter;

final contactProvider =
    FutureProvider.autoDispose.family<Contact, int?>((ref, id) async {
  final contacts = ref.read(contactsProvider);
  return await contacts.one(id);
});

class View extends ConsumerWidget {
  final int? id;

  TextEditingController phoneNumber = TextEditingController();
  TextEditingController birthday = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController homeAddress = TextEditingController();
  final FocusNode _focus = FocusNode();

  View(this.id, {Key? key}) : super(key: key);

  showAlertDialog(BuildContext context, Contact outerContact, WidgetRef ref) {
    Widget cancelButton = TextButton(
      child: const Flutter.Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Flutter.Text("Yes"),
      onPressed: () async {
        await ContactTable().delete(outerContact.id);
        ref.refresh(contactListsProvider);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      content:
          const Flutter.Text("Are you sure you want to delete this contact"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void handleClick(String value, BuildContext context, Contact outerContact,
      WidgetRef ref) async {
    switch (value) {
      case 'Delete':
        showAlertDialog(context, outerContact, ref);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QuillController _quillController = QuillController.basic();

    var outerContact;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 300),
        closedColor: Colors.blueAccent,
        closedElevation: 10,
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        openBuilder: (context, _) => Edit(outerContact),
        closedBuilder: (BuildContext context, _) =>
            FloatingActionButton.extended(
          label: const Flutter.Text('Edit'),
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
          ),
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            _();
          },
          tooltip: 'Add',
        ),
      ),
      body: ref.watch(contactProvider(id)).map(
          data: (data) {
            var contact = data.value;
            outerContact = contact;

            var jsonContent = jsonDecode(contact.notes ?? "");
            _quillController = QuillController(
                document: Document.fromJson(jsonContent),
                selection: const TextSelection.collapsed(offset: 0));

            phoneNumber.text = contact.phoneNumber;
            birthday.text = contact.birthday!;
            email.text = contact.email!;
            homeAddress.text = contact.address!;

            return Scaffold(
              appBar: ApplicationBar(contact.name),
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _buildQuickActionIcons(contact),
                          ),
                        ),
                        Wrap(
                          runSpacing: 20,
                          children: [
                            InputField(phoneNumber, "Phone Number",
                                TextInputType.phone,
                                border: InputBorder.none, enabled: false),
                            InputField(birthday, "Birthday", TextInputType.text,
                                border: InputBorder.none, enabled: false),
                            InputField(email, "Email Address",
                                TextInputType.emailAddress,
                                border: InputBorder.none, enabled: false),
                            InputField(
                                homeAddress, "Home Address", TextInputType.text,
                                border: InputBorder.none, enabled: false),
                            Row(children: const [
                              Flutter.Text(
                                "Notes",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  height: .4,
                                  fontSize: 12,
                                ),
                              ),
                            ]),
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
                          ],
                        )
                      ]),
                ),
              ),
            );
          },
          loading: (_) => const Center(child: CircularProgressIndicator()),
          error: (message) =>
              Center(child: Flutter.Text(message.error.toString()))),
    );
  }

  List<Widget> _buildQuickActionIcons(Contact contact) {
    List<Widget>? widgets = [];
    if (contact.phoneNumber.isNotEmpty) {
      var tel = contact.phoneNumber;
      widgets.add(TextButton(
          onPressed: () {
            launch("tel://$tel");
          },
          child: Column(children: const [
            Icon(
              Icons.call,
              color: Colors.black,
            ),
            SizedBox(height: 15),
            Flutter.Text("Call", style: TextStyle(color: Colors.black))
          ])));
      widgets.add(
        TextButton(
            onPressed: () {
              launch("sms://$tel");
            },
            child: Column(children: const [
              Icon(
                Icons.message,
                color: Colors.black,
              ),
              SizedBox(height: 15),
              Flutter.Text("Text", style: TextStyle(color: Colors.black))
            ])),
      );
    }
    if (contact.email!.isNotEmpty) {
      // TODO formatting if needed
      var sendEmail = contact.email;
      widgets.add(TextButton(
          onPressed: () {
            launch("mailto:$sendEmail");
          },
          child: Column(children: const [
            Icon(
              Icons.email,
              color: Colors.black,
            ),
            SizedBox(height: 15),
            Flutter.Text("Email", style: TextStyle(color: Colors.black))
          ])));
    }
    return widgets;
  }
}
