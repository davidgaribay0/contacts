import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:contacts/ui/add_contact.dart';
import 'package:contacts/ui/contact_list.dart';
import 'package:flutter/material.dart';

import 'common/application_bar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _showAddPage() async {
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false, pageBuilder: (BuildContext context, _, __) => Add()));
    }

    return Scaffold(
      appBar: const ApplicationBar("Contacts"),
      body: ContactList(),
      backgroundColor: const Color(0xFFFFFFFF),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 300),
        closedColor: Colors.blueAccent,
        closedElevation: 10,
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        openBuilder: (context, _) => Add(),
        closedBuilder: (context, _) => FloatingActionButton.extended(
          label: const Text('New', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          tooltip: 'New',
          onPressed: () {
            _();
          },
          // onPressed: _showAddPage,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
