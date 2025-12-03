import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mood_diary_app/widgets/stat_card.dart';
import 'package:mood_diary_app/providers/mood_provider.dart';
import 'package:mood_diary_app/models/mood_state.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTimeRange? selectedWeek;

  void _showWeekPopup() {
    final now = DateTime.now();
    final start = selectedWeek?.start ?? now.subtract(const Duration(days: 3));
    final end = selectedWeek?.end ?? now.add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (context) {
        DateTimeRange tempRange = DateTimeRange(start: start, end: end);

        return AlertDialog(
          title: Text('Select Week', style: GoogleFonts.jua()),
          content: SizedBox(
            width: 300,
            child: CalendarDatePicker(
              initialDate: tempRange.start,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 1),
              onDateChanged: (newDate) {
                setState(() {
                  tempRange = DateTimeRange(start: newDate, end: newDate.add(const Duration(days: 6)));
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.jua()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 181, 136, 194),
              ),
              onPressed: () {
                setState(() => selectedWeek = tempRange);
                Navigator.pop(context);
              },
              child: Text('Select', style: GoogleFonts.jua(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  DateTime? _tryParseDate(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    final weekLabel = selectedWeek == null
        ? 'Select a week'
        : '${DateFormat.Md().format(selectedWeek!.start)} - ${DateFormat.Md().format(selectedWeek!.end)}';

    return Padding(
      padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 30.0),
      child: Consumer<MoodProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          if (state.status == MoodStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MoodStateStatus.error) {
            return Center(child: Text('Failed to load statistics'));
          }

          final moods = state.moods; 
          final ratingCounts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
          final Map<String, int> emojiCounts = {};
          final Map<String, List<int>> dayRatings = {}; 

          for (final m in moods) {
            final rating = (m['rating'] is int)
                ? (m['rating'] as int)
                : int.tryParse('${m['rating'] ?? 0}') ?? 0;
            final r = rating.clamp(1, 5);
            ratingCounts[r] = (ratingCounts[r] ?? 0) + 1;

            final emoji = (m['emoji'] is String) ? (m['emoji'] as String) : '${m['emoji'] ?? ''}';
            if (emoji.isNotEmpty) emojiCounts[emoji] = (emojiCounts[emoji] ?? 0) + 1;

            final dt = _tryParseDate(m['date']) ?? DateTime.now();
            final wk = DateFormat.E().format(dt); // Mon, Tue...
            dayRatings.putIfAbsent(wk, () => []).add(rating);
          }

          final total = ratingCounts.values.fold<int>(0, (a, b) => a + b);
          final average = total == 0
              ? 0.0
              : ratingCounts.entries.fold<int>(0, (s, e) => s + e.key * e.value) / total;

          // best / worst day by average rating
          String bestDay = '-';
          String worstDay = '-';
          if (dayRatings.isNotEmpty) {
            final averages = dayRatings.map((k, list) {
              final avg = list.isEmpty ? 0.0 : list.reduce((a, b) => a + b) / list.length;
              return MapEntry(k, avg);
            });
            final sorted = averages.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            bestDay = sorted.first.key;
            worstDay = sorted.last.key;
          }

          // emoji count string (top 4)
          final emojiList = emojiCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final emojiCountStr = emojiList.isEmpty
              ? '-'
              : emojiList.take(4).map((e) => '${e.key}×${e.value}').join(' ');

          // Build pie data based on rating buckets (keep original labels/colors)
          final categories = [
            {'rating': 5, 'emoji': '😄', 'label': 'Very Happy', 'color': Colors.yellow},
            {'rating': 4, 'emoji': '😊', 'label': 'Happy', 'color': Colors.green},
            {'rating': 3, 'emoji': '😐', 'label': 'Neutral', 'color': Colors.blue},
            {'rating': 2, 'emoji': '😕', 'label': 'Unhappy', 'color': Colors.orange},
            {'rating': 1, 'emoji': '😢', 'label': 'Sad', 'color': Colors.red},
          ];

          final moodData = categories.map((cat) {
            final cnt = ratingCounts[cat['rating'] as int] ?? 0;
            final value = total == 0 ? 0.0 : (cnt / total) * 100.0;
            return {
              'emoji': cat['emoji'],
              'label': cat['label'],
              'value': value,
              'count': cnt,
              'color': cat['color'],
            };
          }).toList();

          // Keep the original UI and style but replace hardcoded values with computed ones
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Statistics',
                    style: GoogleFonts.jua(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showWeekPopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.date_range, color: Colors.white),
                    label: Text(weekLabel, style: GoogleFonts.jua(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Centered stats cards (use real values)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatCard(title: 'Average Mood', value: total == 0 ? '-' : '${average.toStringAsFixed(1)} / 5', emoji: '😊'),
                    const SizedBox(width: 150),
                    StatCard(title: 'Best Day', value: bestDay, emoji: '😄'),
                    const SizedBox(width: 150),
                    StatCard(title: 'Worst Day', value: worstDay, emoji: '😕'),
                    const SizedBox(width: 150),
                    StatCard(title: 'Emoji Count', value: emojiCountStr, emoji: ''),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Chart + legend (use computed moodData)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SizedBox(
                        width: 310,
                        height: 310,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: moodData.map((data) {
                              return PieChartSectionData(
                                color: data['color'] as Color,
                                value: (data['value'] as double),
                                radius: 100,
                                title: total == 0 ? '' : '${(data['value'] as double).toStringAsFixed(0)}%',
                                titleStyle: GoogleFonts.jua(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Legend
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: moodData.map((data) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: data['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${data['emoji']} ${data['label']}  ${ (data['count'] as int? ?? 0) > 0 ? '(${(data['count'] as int?) ?? 0})' : '' }",
                                   style: GoogleFonts.jua(
                                     color: Colors.black,
                                     fontSize: 20,
                                   ),
                                 ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
