import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _stepGoalController = TextEditingController();
  final TextEditingController _waterGoalController = TextEditingController();

  bool _darkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _stepGoalController.text = prefs.getInt('stepGoal')?.toString() ?? '8000';
      _waterGoalController.text =
          prefs.getInt('waterGoal')?.toString() ?? '2000';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final stepGoal = int.tryParse(_stepGoalController.text.trim()) ?? 8000;
    final waterGoal = int.tryParse(_waterGoalController.text.trim()) ?? 2000;

    await prefs.setBool('darkMode', _darkMode);
    await prefs.setInt('stepGoal', stepGoal);
    await prefs.setInt('waterGoal', waterGoal);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  void dispose() {
    _stepGoalController.dispose();
    _waterGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Dark Mode Toggle
                  SwitchListTile(
                    value: _darkMode,
                    title: const Text('Dark Mode'),
                    secondary: const Icon(Icons.dark_mode),
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Step Goal
                  TextField(
                    controller: _stepGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Step Goal',
                      hintText: 'e.g. 8000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Water Goal
                  TextField(
                    controller: _waterGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Water Goal (ml)',
                      hintText: 'e.g. 2000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Save Settings',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
