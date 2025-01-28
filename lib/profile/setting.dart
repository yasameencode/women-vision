import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merge_voice_coplain/infoAR.dart';
// import '../main.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // Tracks the current theme mode

  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Load the saved theme preference
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
        onPressed: () {
  Navigator.pop(context); // يعود للصفحة السابقة
},

        ),
      ),
      body: ListView(
        children: [
          // Other settings...

          // Appearance (Dark Mode)
          // ListTile(
          //   leading: const Icon(Icons.brightness_6),
          //   title: const Text('مظهر التطبيق'),
          //   trailing: Switch(
          //     value: isDarkMode,
          //     onChanged: (bool value) {
          //       setState(() {
          //         isDarkMode = value; // Update the switch state
          //         _saveThemePreference(value); // Save preference
          //         // Use the theme switcher in parent widget (MaterialApp)
          //         MyApp.of(context)!.changeTheme(value);
          //       });
          //     },
          //     activeColor: const Color(0xFF36623F), // Set the color of the switch when it's ON
          //     activeTrackColor: const Color(0xFFF5F5F5), // Optional: Color of the track when switch is ON
          //   ),
          // ),

          // App Information
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('معلومات التطبيق'),
            subtitle: const Text('Version 2.0.0'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Infoar()),
              );
            },
          ),

          // Other settings...
        ],
      ),
    );
  }
}
