import 'package:flutter/material.dart';

import 'address.dart';
import 'address_picker_page.dart';
import 'theme.dart';

class HousesApp extends StatelessWidget {
  const HousesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Houses',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const AddressPickerPage(),
        for (final address in addresses)
          address.path: (context) => address.page,
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        builder: (context) => const AddressPickerPage(),
      ),
    );
  }
}
