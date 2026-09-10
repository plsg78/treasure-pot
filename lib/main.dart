import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

const _vehicles = ['🛹', '🚲', '🚗', '🚙', '✈️'];

String vehicleForStep(int step, int total) {
  if (step < 1 || total < 1) return _vehicles.first;
  final bucket = ((step - 1) * _vehicles.length) ~/ total;
  return _vehicles[math.min(bucket, _vehicles.length - 1)];
}

String vehicleName(String emoji) {
  const names = {
    '🛹': 'Skate',
    '🚲': 'Vélo',
    '🚗': 'Voiture',
    '🚙': 'Monster Truck',
    '✈️': 'Avion',
  };
  return names[emoji] ?? '';
}

int progressPercent(int progress, int total) {
  if (total < 1) return 0;
  return ((progress / total) * 100).round().clamp(0, 100);
}

void main() {
  runApp(const TreasurePotApp());
}

class TreasurePotApp extends StatelessWidget {
  const TreasurePotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Treasure Pot',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFB87928),
        scaffoldBackgroundColor: const Color(0xFFFFF8E8),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _defaultPeeTarget = 20;
  static const _defaultPoopTarget = 5;

  int peeTarget = _defaultPeeTarget;
  int poopTarget = _defaultPoopTarget;
  int peeProgress = 0;
  int poopProgress = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      peeTarget = prefs.getInt('pee_target') ?? _defaultPeeTarget;
      poopTarget = prefs.getInt('poop_target') ?? _defaultPoopTarget;
      peeProgress = prefs.getInt('pee_progress') ?? 0;
      poopProgress = prefs.getInt('poop_progress') ?? 0;
      loading = false;
    });
  }

  Future<void> _save(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _openSettings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const TreasureSettingsPage()),
    );
    await _load();
  }

  Future<void> _validate(bool pee) async {
    final target = pee ? peeTarget : poopTarget;
    final current = pee ? peeProgress : poopProgress;
    if (current >= target) return;

    final next = current + 1;
    final key = pee ? 'pee_progress' : 'poop_progress';

    if (next >= target) {
      await _save(key, 0);
      if (!mounted) return;
      setState(() {
        if (pee) {
          peeProgress = 0;
        } else {
          poopProgress = 0;
        }
      });
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const TreasureDialog(),
      );
    } else {
      await _save(key, next);
      if (!mounted) return;
      setState(() {
        if (pee) {
          peeProgress = next;
        } else {
          poopProgress = next;
        }
      });
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ProgressDialog(step: next, total: target),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏴‍☠️ Treasure Pot',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Réglages',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text(
              'À la chasse au trésor !',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chaque réussite fait avancer le pirate vers le coffre.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            TreasureTrail(
              title: 'Pipi',
              emoji: '💧',
              progress: peeProgress,
              target: peeTarget,
              onTap: () => _validate(true),
            ),
            const SizedBox(height: 18),
            TreasureTrail(
              title: 'Caca',
              emoji: '💩',
              progress: poopProgress,
              target: poopTarget,
              onTap: () => _validate(false),
            ),
          ],
        ),
      ),
    );
  }
}

class TreasureTrail extends StatelessWidget {
  const TreasureTrail({
    super.key,
    required this.title,
    required this.emoji,
    required this.progress,
    required this.target,
    required this.onTap,
  });

  final String title;
  final String emoji;
  final int progress;
  final int target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final safeTarget = math.max(1, target);
    final width = MediaQuery.sizeOf(context).width - 64;
    final denominator = math.max(1, safeTarget - 1);
    final markerProgress = progress.clamp(0, safeTarget);
    final markerLeft = (width - 42) * (markerProgress / safeTarget);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '$progress / $target',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercent(progress, safeTarget) / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 58,
                    child: CustomPaint(
                      size: Size(width, 12),
                      painter: PathPainter(),
                    ),
                  ),
                  for (int i = 0; i < safeTarget; i++)
                    Positioned(
                      left: 12 + (width - 24) * (i / denominator),
                      top: 45,
                      child: Icon(
                        Icons.circle,
                        size: 14,
                        color: i < progress
                            ? Colors.green.shade600
                            : Colors.brown.shade200,
                      ),
                    ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    left: markerLeft,
                    top: 5,
                    child: Text(
                      progress == 0 ? '🏴‍☠️' : vehicleForStep(progress, target),
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    top: 22,
                    child: Text('🧰', style: TextStyle(fontSize: 42)),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onTap,
              icon: Icon(
                title == 'Pipi' ? Icons.water_drop : Icons.child_friendly,
              ),
              label: Text(
                'Valider $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade300
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(
        size.width * .25,
        -8,
        size.width * .5,
        size.height / 2,
      )
      ..quadraticBezierTo(
        size.width * .75,
        size.height + 8,
        size.width,
        size.height / 2,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProgressDialog extends StatefulWidget {
  const ProgressDialog({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = vehicleForStep(widget.step, widget.total);
    return AlertDialog(
      title: const Text(
        'Bravo !',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(vehicle, style: const TextStyle(fontSize: 78)),
          Text(
            vehicleName(vehicle),
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Le voyage continue !',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TreasureDialog extends StatefulWidget {
  const TreasureDialog({super.key});

  @override
  State<TreasureDialog> createState() => _TreasureDialogState();
}

class _TreasureDialogState extends State<TreasureDialog> {
  late final ConfettiController controller;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.play();
      timer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AlertDialog(
          title: const Text(
            '🎉 Trésor !',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🧰', style: TextStyle(fontSize: 92)),
              Text('✨ 💰 ⭐ 💰 ✨', style: TextStyle(fontSize: 25)),
              SizedBox(height: 10),
              Text(
                'Bravo, le coffre est ouvert !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: controller,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 35,
          gravity: .25,
        ),
      ],
    );
  }
}
