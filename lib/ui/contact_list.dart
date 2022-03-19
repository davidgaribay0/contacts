import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/contact_table.dart';
import '../model/contact.dart';
import 'view.dart';

final contactListsProvider =
FutureProvider.autoDispose<List<Contact>>((ref) async {
  final contacts = ref.read(contactsProvider);
  return await contacts.all();
});

class ContactList extends ConsumerWidget {
  ContactList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(contactListsProvider).map(
        data: (contacts) {
          return ListView.builder(
              itemCount: contacts.data?.value.length,
              itemBuilder: (BuildContext context, index) {
                return OpenContainer(
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: Duration(milliseconds: 300),
                  closedElevation: 0,
                  openBuilder: (context, _) {
                    return View(contacts.data!.value[index].id);
                  },
                  closedBuilder: (BuildContext context, _) => ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                    title: Text(
                      contacts.data!.value[index].name,
                      style: TextStyle(fontSize: 18),
                    ),
                    leading: Icon(Icons.person),
                    onTap: () async {
                      Contact contact = await ContactTable()
                          .one(contacts.data!.value[index].id);
                      _();
                    },
                  ),
                );
              });
        },
        loading: (_) => Center(child: CircularProgressIndicator()),
        error: (message) => Center(child: Text(message.error.toString())));
  }
}
