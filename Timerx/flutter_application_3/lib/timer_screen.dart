import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart'; // StudyTask ve renk sabitlerini (goldAccent vs) almak için

class TimerScreen extends StatefulWidget {
  final StudyTask task;

  const TimerScreen({super.key, required this.task});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isRunning = false;

  late AnimationController _animController;
  late Animation<double> _progressAnim;
  double _displayedProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _displayedProgress = widget.task.progress;
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _progressAnim = Tween<double>(begin: _displayedProgress, end: _displayedProgress)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() => _displayedProgress = _progressAnim.value);
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _progressAnim = Tween<double>(begin: _displayedProgress, end: target)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0);
  }

  void _startStop() {
    if (widget.task.isCompleted) return;

    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (widget.task.elapsedSeconds >= widget.task.durationMinutes * 60) {
          _completeActive();
          return;
        }
        setState(() => widget.task.elapsedSeconds++);
        _animateTo(widget.task.progress);
      });
    }
  }

  void _completeActive() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      widget.task.isCompleted = true;
      widget.task.elapsedSeconds = widget.task.durationMinutes * 60;
    });
    _animateTo(1.0);
  }

  void _changeDuration(int delta) {
    if (_isRunning || widget.task.isCompleted) return;
    setState(() {
      int newDuration = widget.task.durationMinutes + delta;
      if (newDuration >= 5) {
        widget.task.durationMinutes = newDuration;
        _animateTo(widget.task.progress);
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
            children: [
              const SizedBox(height: 24),
              
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),

              Opacity(
                opacity: (_isRunning || widget.task.isCompleted) ? 0.5 : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
                      onPressed: () => _changeDuration(-5),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${widget.task.durationMinutes} DK',
                      style: const TextStyle(
                        // Ana dosyadan goldAccent çekildi
                        color: goldAccent, 
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                      onPressed: () => _changeDuration(5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              _CircularTimer(
                progress: _displayedProgress,
                label: widget.task.isCompleted
                    ? '✓'
                    : '${((widget.task.durationMinutes * 60 - widget.task.elapsedSeconds) ~/ 60).toString().padLeft(2, '0')}:${((widget.task.durationMinutes * 60 - widget.task.elapsedSeconds) % 60).toString().padLeft(2, '0')}',
              ),

              const SizedBox(height: 50),

              GestureDetector(
                onTap: widget.task.isCompleted ? null : _startStop,
                child: Container(
                  width: 150,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAA9080),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: goldAccent.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.task.isCompleted
                          ? 'Bitti!'
                          : (_isRunning ? 'Duraklat' : 'Başlat'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularTimer extends StatelessWidget {
  final double progress;
  final String label;

  const _CircularTimer({
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _CircularPainter(progress: progress),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                    color: Colors.black45,
                    offset: Offset(2, 2),
                    blurRadius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularPainter extends CustomPainter {
  final double progress;
  static const Color _gold = Color(0xffC3CC9B);
  static const Color _dark = Color(0xFF2A1A1A);

  const _CircularPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeW = 15.0;
    const startAngle = -pi / 2;

    canvas.drawCircle(
        center,
        radius + 14,
        Paint()
          ..color = _gold.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);

    final tickPaint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0).withOpacity(0.55)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 48; i++) {
      final angle = (i / 48) * 2 * pi - pi / 2;
      final isLong = i % 12 == 0;
      final r1 = radius + 15.0 + (isLong ? 0 : 5);
      final r2 = radius + 15.0 + (isLong ? 11 : 9);
      canvas.drawLine(
        Offset(center.dx + r1 * cos(angle), center.dy + r1 * sin(angle)),
        Offset(center.dx + r2 * cos(angle), center.dy + r2 * sin(angle)),
        tickPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * pi,
      false,
      Paint()
        ..color = _dark.withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0.005) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        startAngle,
        2 * pi * progress,
        false,
        Paint()
          ..shader = SweepGradient(
            colors: [_gold, Colors.orangeAccent, _gold],
            stops: const [0.0, 0.5, 1.0],
            startAngle: startAngle,
            endAngle: startAngle + 2 * pi,
            transform: GradientRotation(startAngle),
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );

      final tipAngle = startAngle + 2 * pi * progress;
      final tx = center.dx + radius * cos(tipAngle);
      final ty = center.dy + radius * sin(tipAngle);
      canvas.drawCircle(
          Offset(tx, ty),
          8,
          Paint()
            ..color = Colors.white.withOpacity(0.7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawCircle(
          Offset(tx, ty),
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
    }

    canvas.drawCircle(
        center,
        radius - strokeW / 2 - 3,
        Paint()
          ..color = const Color(0xffC3CC9B)
          ..style = PaintingStyle.fill);

    canvas.drawCircle(
        center,
        radius - strokeW / 2 - 3,
        Paint()
          ..color = _dark.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_CircularPainter old) => old.progress != progress;
}