import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/record.dart';
import '../widgets/custom_card.dart';
import '../widgets/chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoadingSummary = true;
  bool _isLoadingChart = true;

  int _totalSteps = 0;
  int _totalCalories = 0;
  int _totalWater = 0;

  List<String> _chartLabels = [];
  List<double> _chartValues = [];

  @override
  void initState() {
    super.initState();
    _loadTodaySummary();
    _loadLast7DaysSteps();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _todayString() {
    return _formatDate(DateTime.now());
  }

  Future<void> _loadTodaySummary() async {
    setState(() {
      _isLoadingSummary = true;
    });

    try {
      final db = DbHelper.instance;
      final today = _todayString();

      final List<Record> records = await db.getRecordsByDate(today);

      int steps = 0;
      int calories = 0;
      int water = 0;

      for (final r in records) {
        steps += r.steps;
        calories += r.calories;
        water += r.water;
      }

      setState(() {
        _totalSteps = steps;
        _totalCalories = calories;
        _totalWater = water;
        _isLoadingSummary = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSummary = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading summary: $e')));
      }
    }
  }

  Future<void> _loadLast7DaysSteps() async {
    setState(() {
      _isLoadingChart = true;
    });

    try {
      final db = DbHelper.instance;
      final now = DateTime.now();

      final List<String> labels = [];
      final List<double> values = [];

      // Last 7 days including today (6 days ago -> today)
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dateStr = _formatDate(day);

        final records = await db.getRecordsByDate(dateStr);

        int steps = 0;
        for (final r in records) {
          steps += r.steps;
        }

        // label: short weekday (Mon, Tue, ...)
        final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final weekdayLabel = weekdayNames[day.weekday - 1];

        labels.add(weekdayLabel);
        values.add(steps.toDouble());
      }

      setState(() {
        _chartLabels = labels;
        _chartValues = values;
        _isLoadingChart = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingChart = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading chart data: $e')));
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadTodaySummary(), _loadLast7DaysSteps()]);
  }

  void _goToAddRecord() async {
    await Navigator.pushNamed(context, '/addRecord');
    _refreshAll();
  }

  void _goToRecordList() async {
    await Navigator.pushNamed(context, '/recordList');
    _refreshAll();
  }

  void _goToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    final todayText = _todayString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate - Dashboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Today label
              Text(
                'Today: $todayText',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Summary stats
              if (_isLoadingSummary)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                CustomCard(
                  title: 'Steps Today',
                  subtitle: '$_totalSteps steps',
                  icon: Icons.directions_walk,
                  iconColor: Colors.blue,
                  onTap: _goToRecordList,
                ),
                CustomCard(
                  title: 'Calories Today',
                  subtitle: '$_totalCalories kcal',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  onTap: _goToRecordList,
                ),
                CustomCard(
                  title: 'Water Today',
                  subtitle: '$_totalWater ml',
                  icon: Icons.water_drop,
                  iconColor: Colors.teal,
                  onTap: _goToRecordList,
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Chart section
              const Text(
                'Steps - Last 7 Days',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (_isLoadingChart)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                StepsLineChart(labels: _chartLabels, values: _chartValues),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _goToAddRecord,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Today\'s Record'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _goToRecordList,
                  icon: const Icon(Icons.list),
                  label: const Text('View All Records'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _goToSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
