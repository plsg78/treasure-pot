import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreasureSettingsPage extends StatefulWidget {
  const TreasureSettingsPage({super.key});
  @override State<TreasureSettingsPage> createState() => _TreasureSettingsPageState();
}

class _TreasureSettingsPageState extends State<TreasureSettingsPage> {
  int _pees = 20, _poops = 5;
  bool _loaded = false;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _pees = p.getInt('pee_target') ?? 20; _poops = p.getInt('poop_target') ?? 5; _loaded = true; });
  }
  Future<void> _change(bool pee, int delta) async {
    final value = (pee ? _pees : _poops) + delta;
    if (value < 1) return;
    setState(() { if (pee) _pees = value; else _poops = value; });
    final p = await SharedPreferences.getInstance();
    await p.setInt(pee ? 'pee_target' : 'poop_target', value);
  }
  @override Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Nombre de réussites pour trouver le trésor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _Counter(icon: '💧', title: 'Parcours Pipi', value: _pees, minus: () => _change(true, -1), plus: () => _change(true, 1)),
        const SizedBox(height: 16),
        _Counter(icon: '💩', title: 'Parcours Caca', value: _poops, minus: () => _change(false, -1), plus: () => _change(false, 1)),
        const SizedBox(height: 28),
        const Text('Les réglages sont enregistrés automatiquement sur cet appareil.', textAlign: TextAlign.center),
      ]),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.icon, required this.title, required this.value, required this.minus, required this.plus});
  final String icon, title; final int value; final VoidCallback minus, plus;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
    Text(icon, style: const TextStyle(fontSize: 36)), const SizedBox(width: 10),
    Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    IconButton(onPressed: value > 1 ? minus : null, icon: const Icon(Icons.remove_circle), iconSize: 36),
    Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    IconButton(onPressed: plus, icon: const Icon(Icons.add_circle), iconSize: 36),
  ])));
}
