import 'package:flutter/material.dart';
import 'timer_screen.dart'; // Timer sayfasını buraya bağlıyoruz

void main() {
  runApp(const StudyTrackerApp());
}

// ── Tema Renkleri ────────────────────────────────────────────────────────────
const Color bgColor = Color(0xFF0F172A);
const Color cardColor = Color(0xFF1E293B);
const Color goldAccent = Color(0xff10B981);
const Color darkRing = Color(0xFFF43F5E);
const Color pillColor = Color(0xff38BDF8);
const Color pillText = Color(0xFFF8FAFC);

class StudyTrackerApp extends StatelessWidget {
  const StudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çalışma Takipçisi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
      ),
      home: const TaskSelectionScreen(),
    );
  }
}

// ── Veri Modeli ──────────────────────────────────────────────────────────────
class StudyTask {
  final String id;
  final String title;
  int durationMinutes;
  bool isCompleted;
  int elapsedSeconds;

  StudyTask({
    required this.id,
    required this.title,
    this.durationMinutes = 25,
    this.isCompleted = false,
    this.elapsedSeconds = 0,
  });

  double get progress =>
      (elapsedSeconds / (durationMinutes * 60)).clamp(0.0, 1.0);
}

// ── Anasayfa (Görev Belirleme) ───────────────────────────────────────────────
class TaskSelectionScreen extends StatefulWidget {
  const TaskSelectionScreen({super.key});

  @override
  State<TaskSelectionScreen> createState() => _TaskSelectionScreenState();
}

class _TaskSelectionScreenState extends State<TaskSelectionScreen> {
  final TextEditingController _taskController = TextEditingController();

  final List<StudyTask> _tasks = [];

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    setState(() {
      _tasks.add(StudyTask(
        id: DateTime.now().toString(),
        title: _taskController.text.trim(),
      ));
      _taskController.clear();
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      if (_tasks[index].isCompleted) {
        _tasks[index].elapsedSeconds = _tasks[index].durationMinutes * 60;
      } else {
        _tasks[index].elapsedSeconds = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              const Text(
                'Ne Çalışacaksın?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Yeni görev adı...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: cardColor.withOpacity(0.45),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _addTask,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: goldAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.add, color: pillText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: goldAccent.withOpacity(0.45), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      itemCount: _tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _TaskRow(
                        task: _tasks[i],
                        onToggle: () => _toggleTask(i),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TimerScreen(task: _tasks[i]),
                            ),
                          );
                          setState(() {}); 
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _TaskRow({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  static const Color _gold = Color(0xFFD4A820);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? const Color(0xFF3A2010)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: task.isCompleted
                        ? const Color(0xFF3A2010)
                        : Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  color: task.isCompleted
                      ? Colors.white.withOpacity(0.45)
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${task.durationMinutes}dk',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}