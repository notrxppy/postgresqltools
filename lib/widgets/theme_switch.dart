import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../models/theme_model.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);

    return SwitchListTile(
      title: Text(
        themeModel.isDarkMode ? 'Dark Mode' : 'Light Mode',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      value: themeModel.isDarkMode,
      onChanged: (value) => themeModel.toggleTheme(),
      secondary: Icon(
        themeModel.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
