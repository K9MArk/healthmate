import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../services/db_helper.dart';
import 'add_edit_record_screen.dart'; // we only import it here

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DailyRecord> _records = [];
  String? _username;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await DbHelper.instance.getAnyProfile();
    if (profile != null) {
      final list = await DbHelper.instance.getDailyRecords(profile.username);
      setState(() {
        _username = profile.username;
        _records = list;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_username == null) {
      return const Scaffold(body: Center(child: Text('No profile found.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: _records.length,
          itemBuilder: (ctx, i) {
            final r = _records[i];
            return ListTile(
              title: Text(r.date),
              subtitle: Text(
                  'Steps: ${r.steps}, Water: ${r.waterMl} ml, Kcal: ${r.calorieIntake}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditRecordScreen(username: _username!, initial: r),
                ),
              ).then((_) => _load()),
            );
          },
        ),
      ),
    );
  }
}
