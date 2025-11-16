import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _autoConnect = true;
  bool _syntaxHighlighting = true;
  bool _saveHistory = true;
  String _themeColor = 'Blue';
  String _fontSize = 'Medium';

  final List<String> _themeColors = ['Blue', 'Green', 'Purple', 'Orange'];
  final List<String> _fontSizes = ['Small', 'Medium', 'Large'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                _buildSettingSwitch(
                  'Dark Mode',
                  'Enable dark theme for the app',
                  _darkMode,
                  (value) {
                    setState(() => _darkMode = value);
                    _showSnackBar(
                        'Dark Mode ${value ? 'Enabled' : 'Disabled'}');
                  },
                ),
                _buildSettingDropdown(
                  'Theme Color',
                  'Choose your preferred color theme',
                  _themeColor,
                  _themeColors,
                  (value) {
                    setState(() => _themeColor = value!);
                    _showSnackBar('Theme changed to $value');
                  },
                ),
                _buildSettingDropdown(
                  'Font Size',
                  'Adjust the text size throughout the app',
                  _fontSize,
                  _fontSizes,
                  (value) {
                    setState(() => _fontSize = value!);
                    _showSnackBar('Font size changed to $value');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Database'),
          Card(
            child: Column(
              children: [
                _buildSettingSwitch(
                  'Auto Connect',
                  'Automatically connect to last used database',
                  _autoConnect,
                  (value) {
                    setState(() => _autoConnect = value);
                    _showSnackBar(
                        'Auto Connect ${value ? 'Enabled' : 'Disabled'}');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Editor'),
          Card(
            child: Column(
              children: [
                _buildSettingSwitch(
                  'Syntax Highlighting',
                  'Enable color coding for SQL syntax',
                  _syntaxHighlighting,
                  (value) {
                    setState(() => _syntaxHighlighting = value);
                    _showSnackBar(
                        'Syntax Highlighting ${value ? 'Enabled' : 'Disabled'}');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('History'),
          Card(
            child: Column(
              children: [
                _buildSettingSwitch(
                  'Save Query History',
                  'Keep track of all executed queries',
                  _saveHistory,
                  (value) {
                    setState(() => _saveHistory = value);
                    _showSnackBar(
                        'Query History ${value ? 'Enabled' : 'Disabled'}');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset to Defaults'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        value ? Icons.toggle_on : Icons.toggle_off,
        color: value ? Colors.blue : Colors.grey,
      ),
    );
  }

  Widget _buildSettingDropdown(String title, String subtitle, String value,
      List<String> items, Function(String?) onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _darkMode = false;
                _autoConnect = true;
                _syntaxHighlighting = true;
                _saveHistory = true;
                _themeColor = 'Blue';
                _fontSize = 'Medium';
              });
              Navigator.pop(context);
              _showSnackBar('All settings reset to defaults!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    _showSnackBar('All settings saved successfully!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
