import 'package:animations/animations.dart';
import 'package:contacts/model/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/input_field.dart';
import '../db/contact_table.dart';
import 'edit.dart';

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

  View(this.id, {Key? key}) : super(key: key);

  showAlertDialog(BuildContext context, Contact outerContact) {
    Widget cancelButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes"),
      onPressed: () async {
        await ContactTable().delete(outerContact.id);
        // TODO
        // ref.refresh(contactListsProvider);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      content: const Text("Are you sure you want to delete this contact"),
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

  void handleClick(
      String value, BuildContext context, Contact outerContact) async {
    switch (value) {
      case 'Delete':
        showAlertDialog(context, outerContact);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var outerContact;

    void _showEditPage() async {
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => Edit(outerContact)));
    }

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
          label: const Text('Edit'),
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

            var tel = contact.phoneNumber;
            var sendEmail = contact.email;

            phoneNumber.text = contact.phoneNumber;
            birthday.text = contact.birthday!;
            email.text = contact.email!;
            homeAddress.text = contact.address!;

            return NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    elevation: 0,
                    expandedHeight: 260,
                    floating: false,
                    pinned: true,
                    iconTheme: const IconThemeData(
                      color: Colors.black, //change your color here
                    ),
                    backgroundColor: const Color(0xFFFFFFFF),
                    systemOverlayStyle: const SystemUiOverlayStyle(
                        statusBarColor: Colors.white,
                        statusBarIconBrightness: Brightness.dark),
                    actions: [
                      PopupMenuButton(
                        onSelected: (String item) {
                          handleClick(item, context, contact);
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Delete'}.map((String choice) {
                            return PopupMenuItem(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          contact.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        background: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Container(
                            child: Image.network(
                              "https://images.unsplash.com/photo-1561677843-39dee7a319ca?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2700&q=80",
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        )),
                  ),
                ];
              },
              body: Padding(
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
                          InputField(
                              phoneNumber, "Phone Number", TextInputType.phone,
                              border: InputBorder.none, enabled: false),
                          InputField(birthday, "Birthday", TextInputType.text,
                              border: InputBorder.none, enabled: false),
                          InputField(email, "Email Address",
                              TextInputType.emailAddress,
                              border: InputBorder.none, enabled: false),
                          InputField(
                              homeAddress, "Home Address", TextInputType.text,
                              border: InputBorder.none, enabled: false),
                        ],
                      )
                    ]),
              ),
            );
          },
          loading: (_) => Center(child: CircularProgressIndicator()),
          error: (message) => Center(child: Text(message.error.toString()))),
    );
  }

  List<Widget> _buildQuickActionIcons(Contact contact) {
    List<Widget>? widgets = [];
    if (contact.phoneNumber.isNotEmpty) {
      //format phone number correctly
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
            Text("Call", style: TextStyle(color: Colors.black))
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
              Text("Text", style: TextStyle(color: Colors.black))
            ])),
      );
    }
    if (contact.email!.isNotEmpty) {
      // do formatting if needed
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
            Text("Email", style: TextStyle(color: Colors.black))
          ])));
    }
    return widgets;
  }
}
