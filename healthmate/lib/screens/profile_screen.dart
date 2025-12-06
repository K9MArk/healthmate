import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/db_helper.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _p;
  bool _editing = false;

  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  bool _hasDiabetes = false;
  bool _hasCholesterol = false;

  @override
  void initState() {
    super.initState();
    _p = widget.profile;
    _fillFromProfile();
  }

  void _fillFromProfile() {
    _nameCtrl.text = _p.name;
    _heightCtrl.text = _p.heightCm.toString();
    _weightCtrl.text = _p.weightKg.toString();
    _hasDiabetes = _p.hasDiabetes;
    _hasCholesterol = _p.hasCholesterol;
  }

  Future<void> _toggleEdit() async {
    if (_editing) {
      // Cancel edits → restore original values
      setState(() {
        _editing = false;
        _fillFromProfile();
      });
      return;
    }
    // Ask password before enabling edit
    final ok = await _askPassword();
    if (ok && mounted) setState(() => _editing = true);
  }

  Future<bool> _askPassword() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter password to edit'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OK')),
        ],
      ),
    );
    if (ok != true) return false;
    return ctrl.text == _p.password;
  }

  Future<void> _save() async {
    _p = UserProfile(
      username: _p.username,
      password: _p.password,
      name: _nameCtrl.text.trim(),
      dob: _p.dob, // not editable here
      heightCm: int.tryParse(_heightCtrl.text) ?? _p.heightCm,
      weightKg: double.tryParse(_weightCtrl.text) ?? _p.weightKg,
      hasDiabetes: _hasDiabetes,
      hasCholesterol: _hasCholesterol,
      profilePicturePath: _p.profilePicturePath,
    );
    await DbHelper.instance.updateUserProfile(_p);
    if (!mounted) return;
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = !_editing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _toggleEdit,
            child: Text(_editing ? 'Cancel' : 'Edit',
                style: const TextStyle(color: Colors.white)),
          ),
          if (_editing)
            IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Username: ${_p.username}'),
          Text('DOB: ${_p.dob}'),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            readOnly: readOnly,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _heightCtrl,
            readOnly: readOnly,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Height (cm)'),
          ),
          TextField(
            controller: _weightCtrl,
            readOnly: readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          SwitchListTile(
            title: const Text('Diabetes'),
            value: _hasDiabetes,
            onChanged:
                readOnly ? null : (v) => setState(() => _hasDiabetes = v),
          ),
          SwitchListTile(
            title: const Text('High cholesterol'),
            value: _hasCholesterol,
            onChanged:
                readOnly ? null : (v) => setState(() => _hasCholesterol = v),
          ),
        ],
      ),
    );
  }
}
