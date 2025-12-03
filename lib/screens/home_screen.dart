import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_diary_app/models/mood_state.dart';
import 'package:mood_diary_app/providers/mood_provider.dart';
import 'package:mood_diary_app/repos/auth_repository.dart';
import 'package:mood_diary_app/screens/statistics_screen.dart';
import 'package:mood_diary_app/widgets/mood_card.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:mood_diary_app/models/mood.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthRepository _authRepo = AuthRepository();
  String username = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        analytics.logEvent(name: 'statistics_tab_opened');
      }
    });
    username = _authRepo.getUsername() ?? 'Guest';
  }

  void _showMoodDialog({Map<String, Object>? existingMood, int? index}) {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    final TextEditingController noteController =
        TextEditingController(text: existingMood?['note'] as String? ?? '');
    int rating = existingMood?['rating'] as int? ?? 0;
    String emoji = existingMood?['emoji'] as String? ?? '';
    bool _submitted = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                existingMood == null ? 'Add New Mood' : 'Edit Mood',
                style: GoogleFonts.jua(fontSize: 22),
              ),
              content: Form(
                key: _formKey,
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text('Rate your day:', style: GoogleFonts.jua(fontSize: 18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          return IconButton(
                            onPressed: () {
                              setDialogState(() => rating = i + 1);
                            },
                            icon: Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      if (_submitted && rating == 0)
                        Text(
                          'Please select a rating',
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      const SizedBox(height: 8),
                      Text('Pick an emoji:', style: GoogleFonts.jua(fontSize: 18)),
                      const SizedBox(height: 4),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        children: ['😄', '😊', '😐', '😢', '😡'].map((e) {
                          final bool selected = emoji == e;
                          return GestureDetector(
                            onTap: () => setDialogState(() => emoji = e),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.black : Colors.transparent,
                                  width: 2,
                                ),
                                color: selected
                                    ? Colors.grey.shade200
                                    : Colors.transparent,
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_submitted && emoji.isEmpty)
                        Text(
                          'Please select an emoji',
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteController,
                        decoration: InputDecoration(
                          labelText: 'Note',
                          labelStyle: GoogleFonts.jua(),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a note';
                          }
                          if (value.length > 200) {
                            return 'Note cannot exceed 200 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (existingMood != null)
                  TextButton(
                    onPressed: () {
                      moodProvider.deleteMood(index!);
                      analytics.logEvent(name: 'mood_deleted', parameters: <String, Object>{
                          'emoji': existingMood['emoji'] as String,
                          'rating': existingMood['rating'] as int,
                        });
                      Navigator.pop(context);
                    },
                    child: Text('Delete', style: GoogleFonts.jua(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.jua()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    setDialogState(() => _submitted = true);
                    if (!_formKey.currentState!.validate()) return;
                    if (rating == 0 || emoji.isEmpty) return;

                    final moodMap = {
                      'date': existingMood?['date'] ??
                          DateTime.now().toString().substring(0, 10),
                      'rating': rating,
                      'emoji': emoji,
                      'note': noteController.text.trim(),
                      if (existingMood != null) 'id': existingMood['id'] as String,
                    };

                    if (existingMood == null) {
                      // Add new mood
                      final newMood = Mood.fromMap(moodMap.cast<String, dynamic>());
                      moodProvider.addMood(newMood);
                      analytics.logEvent(
                        name: 'mood_created',
                        parameters: <String, Object>{
                          'emoji': moodMap['emoji'] as String,
                          'rating': moodMap['rating'] as int,
                        },
                      );
                    } else {
                      // Update existing mood
                      final editedMood = Mood.fromMap(moodMap.cast<String, dynamic>());
                      moodProvider.editMood(index!, editedMood);
                      analytics.logEvent(name: 'mood_edited', parameters: <String, Object>{
                          'emoji': moodMap['emoji'] as String,
                          'rating': moodMap['rating'] as int,
                        },
                      );
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    existingMood == null ? 'Add' : 'Update',
                    style: GoogleFonts.jua(color: Colors.white),
                  ),
                ),

              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    const EdgeInsets.only(top: 16, bottom: 16, left: 20, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        analytics.logEvent(name: 'home_title_clicked');
                        throw StateError('This is test exception');
                      },
                      child: Text(
                        'MoodDiary',
                        style: GoogleFonts.jua(
                          color: Colors.black,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.public, color: Colors.black),
                          const SizedBox(width: 6),
                          Text('English',
                              style: GoogleFonts.jua(fontSize: 24, color: Colors.black)),
                          const SizedBox(width: 20),
                          const Icon(Icons.account_circle, color: Colors.black),
                          const SizedBox(width: 6),
                          Text('$username',
                              style: GoogleFonts.jua(fontSize: 24, color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelStyle: GoogleFonts.jua(fontSize: 32),
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                tabs: const [
                  Tab(text: 'Home'),
                  Tab(text: 'Statistics'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Your Latest Mood Records',
                    style: GoogleFonts.jua(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<MoodProvider>(
                    builder: (context, provider, _) {
                      final state = provider.state;

                      if (state.status == MoodStateStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.status == MoodStateStatus.error) {
                        return Center(child: Text(state.errorMessage ?? 'Error'));
                      } else {
                        final moods = state.moods;
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 280 / 350,
                          ),
                          itemCount: moods.length + 1,
                          itemBuilder: (context, index) {
                            if (index < moods.length) {
                              final mood = moods[index];
                              return MoodCard(
                                date: mood['date'] as String,
                                rating: mood['rating'] as int,
                                emoji: mood['emoji'] as String,
                                note: mood['note'] as String,
                                onEdit: () => _showMoodDialog(existingMood: mood, index: index),
                                onDelete: () => provider.deleteMood(index),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () => _showMoodDialog(),
                                child: Container(
                                  width: 280,
                                  height: 350,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add, size: 48, color: Colors.black),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                )

              ],
            ),
          ),
          const StatisticsPage(),
        ],
      ),
    );
  }
}
