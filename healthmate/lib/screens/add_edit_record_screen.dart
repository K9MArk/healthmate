import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import '../services/db_helper.dart';

class AddEditRecordScreen extends StatefulWidget {
  final String username;
  final DailyRecord? initial;
  const AddEditRecordScreen({super.key, required this.username, this.initial});

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial == null) {
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _stepsCtrl.text = '0';
      _waterCtrl.text = '0';
      _kcalCtrl.text = '0';
    } else {
      final r = widget.initial!;
      _dateCtrl.text = r.date;
      _stepsCtrl.text = r.steps.toString();
      _waterCtrl.text = r.waterMl.toString();
      _kcalCtrl.text = r.calorieIntake.toString();
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _stepsCtrl.dispose();
    _waterCtrl.dispose();
    _kcalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final init = DateTime.tryParse(_dateCtrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rec = DailyRecord(
      recordId: widget.initial?.recordId,
      username: widget.username,
      date: _dateCtrl.text.trim(),
      steps: int.parse(_stepsCtrl.text),
      waterMl: int.parse(_waterCtrl.text),
      calorieIntake: int.parse(_kcalCtrl.text),
    );
    if (widget.initial == null) {
      await DbHelper.instance.insertDailyRecord(rec);
    } else {
      await DbHelper.instance.updateDailyRecord(rec);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.initial?.recordId == null) return;
    await DbHelper.instance.deleteDailyRecord(widget.initial!.recordId!);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Record' : 'Add Record'),
        actions: [
          if (editing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date (yyyy-MM-dd)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDate,
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _stepsCtrl,
                decoration: const InputDecoration(labelText: 'Steps'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _waterCtrl,
                decoration: const InputDecoration(labelText: 'Water (ml)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _kcalCtrl,
                decoration:
                    const InputDecoration(labelText: 'Calorie intake (kcal)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: Text(editing ? 'Save Changes' : 'Add Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
