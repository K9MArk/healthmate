import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/record.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  final DbHelper _db = DbHelper.instance;

  List<Record> _records = [];
  bool _isLoading = true;

  final TextEditingController _dateController = TextEditingController();
  String? _filterDate; // yyyy-MM-dd

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    List<Record> records;

    if (_filterDate == null || _filterDate!.isEmpty) {
      records = await _db.getAllRecords();
    } else {
      records = await _db.getRecordsByDate(_filterDate!);
    }

    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  Future<void> _pickFilterDate() async {
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
      final dateStr = '$y-$m-$d';

      setState(() {
        _filterDate = dateStr;
        _dateController.text = dateStr;
      });

      _loadRecords();
    }
  }

  void _clearFilter() {
    setState(() {
      _filterDate = null;
      _dateController.clear();
    });
    _loadRecords();
  }

  Future<void> _deleteRecord(Record record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete this record for ${record.date}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteRecord(record.id!);
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Record deleted')));

      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records'), centerTitle: true),
      body: Column(
        children: [
          // Filter by date area
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Filter by Date (yyyy-mm-dd)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit_calendar),
                        onPressed: _pickFilterDate,
                      ),
                    ),
                    onTap: _pickFilterDate,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _clearFilter,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filter',
                ),
              ],
            ),
          ),

          const Divider(height: 0),

          // List of records
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRecords,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _records.isEmpty
                  ? const Center(
                      child: Text(
                        'No records found.\nTry adding a new record.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                record.date.split('-').last, // day
                              ),
                            ),
                            title: Text(record.date),
                            subtitle: Text(
                              'Steps: ${record.steps}   |   '
                              'Calories: ${record.calories}   |   '
                              'Water: ${record.water} ml',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRecord(record),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
