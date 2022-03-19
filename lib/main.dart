import 'package:contacts/contacts_app.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: ContactsApp(),
    ),
  );
}
