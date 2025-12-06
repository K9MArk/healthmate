import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../models/daily_record.dart';
import '../services/db_helper.dart';
import '../utils/health_calculator.dart';

import 'add_edit_record_screen.dart' as addrec;
import 'history_screen.dart';
import 'profile_screen.dart' as prof; // <-- prefix

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserProfile? _profile;
  DailyRecord? _today;
  bool _loading = true;

  static const int stepsGoal = 10000;
  static const int waterGoal = 2000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await DbHelper.instance.getAnyProfile();
    DailyRecord? todayRecord;
    if (profile != null) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      todayRecord =
          await DbHelper.instance.getRecordByDate(profile.username, today);
    }
    setState(() {
      _profile = profile;
      _today = todayRecord;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profile == null) {
      return const Scaffold(
          body: Center(child: Text('No profile found. Restart app.')));
    }

    final p = _profile!;
    final age = HealthCalculator.ageFromDob(p.dob);
    final bmi = HealthCalculator.bmi(p.weightKg, p.heightCm);
    final cat = HealthCalculator.bmiCategory(bmi);
    final bmiMsg = HealthCalculator.bmiMessage(cat);

    final steps = _today?.steps ?? 0;
    final water = _today?.waterMl ?? 0;
    final intake = _today?.calorieIntake ?? 0;

    final totalBurn = HealthCalculator.totalBurned(p.weightKg, steps);
    final net = HealthCalculator.netCalories(intake, totalBurn);

    final stepsPct = HealthCalculator.progress(steps, stepsGoal);
    final waterPct = HealthCalculator.progress(water, waterGoal);

    final stepMsg = HealthCalculator.stepsMessage(stepsPct);
    final waterMsg = HealthCalculator.waterMessage(waterPct);
    final netMsg = HealthCalculator.caloriesMessage(net);
    final tip = HealthCalculator.conditionTip(
      diabetes: p.hasDiabetes,
      cholesterol: p.hasCholesterol,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ).then((_) => _load()),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      prof.ProfileScreen(profile: p)), // <-- use prefix
            ).then((_) => _load()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => addrec.AddEditRecordScreen(
              username: p.username,
              initial: _today,
            ),
          ),
        ).then((_) => _load()),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Hello, ${p.name}',
                style: Theme.of(context).textTheme.titleLarge),
            Text('Age: $age'),
            const SizedBox(height: 8),
            Text('BMI: ${bmi.toStringAsFixed(1)} ($cat)'),
            Text(bmiMsg),
            const Divider(height: 24),
            _statTile('Steps', '$steps / $stepsGoal',
                '${stepsPct.toStringAsFixed(0)}%'),
            Text(stepMsg),
            const SizedBox(height: 12),
            _statTile('Water', '$water ml / $waterGoal ml',
                '${waterPct.toStringAsFixed(0)}%'),
            Text(waterMsg),
            const SizedBox(height: 12),
            _statTile(
              'Calories',
              'Intake: $intake, Burned: ${totalBurn.toStringAsFixed(0)}',
              'Net: ${net.toStringAsFixed(0)}',
            ),
            Text(netMsg),
            if (tip.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tip),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statTile(String title, String subtitle, String trailing) {
    return ListTile(
      tileColor: Colors.blueGrey.shade50,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing:
          Text(trailing, style: const TextStyle(fontWeight: FontWeight.w600)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
