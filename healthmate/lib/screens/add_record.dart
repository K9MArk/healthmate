import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/record.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setTodayAsDefaultDate();
  }

  void _setTodayAsDefaultDate() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    _dateController.text = '$y-$m-$d'; // e.g. 2025-12-02
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final y = picked.year.toString();
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dateController.text = '$y-$m-$d';
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final steps = int.parse(_stepsController.text.trim());
      final calories = int.parse(_caloriesController.text.trim());
      final water = int.parse(_waterController.text.trim());
      final date = _dateController.text.trim();

      final record = Record(
        date: date,
        steps: steps,
        calories: calories,
        water: water,
      );

      await DbHelper.instance.insertRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record saved successfully')),
      );

      // Go back to previous screen (Dashboard or List)
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving record: $e')));
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Health Record'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your health data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in your activity and water intake for the selected date.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _pickDate,
                  ),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // Steps
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: 'Steps',
                  hintText: 'e.g. 8000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_walk),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter steps';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Steps must be a number';
                  }
                  if (int.parse(value.trim()) < 0) {
                    return 'Steps cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calories
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  hintText: 'e.g. 300',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter calories';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Calories must be a number';
                  }
                  if (int.parse(value.trim()) < 0) {
                    return 'Calories cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Water
              TextFormField(
                controller: _waterController,
                decoration: const InputDecoration(
                  labelText: 'Water (ml)',
                  hintText: 'e.g. 2000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter water intake';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Water must be a number';
                  }
                  if (int.parse(value.trim()) < 0) {
                    return 'Water cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveRecord,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Record',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
