import 'dart:async';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

String vehicleForStep(int step, int total) {
  if (total < 1 || step < 1) return '🛹';
  final bucket = ((step - 1) * 5) ~/ total;
  return ['🛹', '🚲', '🚗', '🚙', '✈️'][bucket.clamp(0, 4)];
}
String vehicleName(String emoji) => {'🛹':'Skate','🚲':'Vélo','🚗':'Voiture','🚙':'Monster Truck','✈️':'Avion'}[emoji] ?? '';
void main() => runApp(const TreasurePotApp());

class TreasurePotApp extends StatelessWidget {
  const TreasurePotApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner:false,title:'Treasure Pot',theme:ThemeData(useMaterial3:true,colorSchemeSeed:const Color(0xFFB87928),scaffoldBackgroundColor:const Color(0xFFFFF8E8)),home:const HomePage());
}
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
  int peeTarget=20,poopTarget=5,peeProgress=0,poopProgress=0; bool loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); if(!mounted)return; setState((){peeTarget=p.getInt('pee_target')??20;poopTarget=p.getInt('poop_target')??5;peeProgress=p.getInt('pee_progress')??0;poopProgress=p.getInt('poop_progress')??0;loading=false;}); }
  Future<void> _save(String key,int value) async => (await SharedPreferences.getInstance()).setInt(key,value);
  Future<void> _openSettings() async {await Navigator.push(context,MaterialPageRoute(builder:(_)=>const TreasureSettingsPage()));_load();}
  @override Widget build(BuildContext context){if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));return Scaffold(appBar:AppBar(title:const Text('🏴‍☠️ Treasure Pot',style:TextStyle(fontWeight:FontWeight.w800)),centerTitle:true,actions:[IconButton(icon:const Icon(Icons.settings),tooltip:'Réglages',onPressed:_openSettings)]),body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,24),children:[const Text('À la chasse au trésor !',textAlign:TextAlign.center,style:TextStyle(fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('Chaque réussite fait avancer le pirate vers le coffre.',textAlign:TextAlign.center),const SizedBox(height:18),TreasureTrail(title:'Pipi',emoji:'💧',progress:peeProgress,target:peeTarget,onTap:()=>_validate(true)),const SizedBox(height:18),TreasureTrail(title:'Caca',emoji:'💩',progress:poopProgress,target:poopTarget,onTap:()=>_validate(false))]));}
  Future<void> _validate(bool pee) async {final target=pee?peeTarget:poopTarget;final current=pee?peeProgress:poopProgress;if(current>=target)return;final next=current+1;if(next>=target){await _save(pee?'pee_progress':'poop_progress',0);if(!mounted)return;setState((){if(pee)peeProgress=0;else poopProgress=0;});await showDialog(context:context,barrierDismissible:false,builder:(_)=>const TreasureDialog());}else{await _save(pee?'pee_progress':'poop_progress',next);if(!mounted)return;setState((){if(pee)peeProgress=next;else poopProgress=next;});await showDialog(context:context,builder:(_)=>ProgressDialog(step:next,total:target));}}
}
class TreasureTrail extends StatelessWidget {
  const TreasureTrail({super.key,required this.title,required this.emoji,required this.progress,required this.target,required this.onTap});
  final String title,emoji;final int progress,target;final VoidCallback onTap;
  @override Widget build(BuildContext context){final safeTarget=math.max(1,target);final width=MediaQuery.sizeOf(context).width-32;return Card(elevation:2,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Row(children:[Text(emoji,style:const TextStyle(fontSize:34)),const SizedBox(width:10),Expanded(child:Text(title,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900))),Text('$progress / $target',style:const TextStyle(fontWeight:FontWeight.bold))]),const SizedBox(height:12),SizedBox(height:112,child:Stack(children:[Positioned(left:12,right:12,top:53,child:CustomPaint(size:Size(width,12),painter:PathPainter())),for(int i=0;i<safeTarget;i++)Positioned(left:12+(width-40)*(i/(safeTarget-1==0?1:safeTarget-1)),top:34,child:Text('•',style:TextStyle(fontSize:38,color:i<progress?Colors.green:Colors.brown.shade200))),AnimatedPositioned(duration:const Duration(milliseconds:500),curve:Curves.easeOut,left:(width-40)*(progress/(safeTarget==0?1:safeTarget)),top:8,child:Text(progress==0?'🏴‍☠️':vehicleForStep(progress,target),style:const TextStyle(fontSize:42))),const Positioned(right:0,top:15,child:Text('🧰',style:TextStyle(fontSize:42)))])),FilledButton.icon(onPressed:onTap,icon:Icon(title=='Pipi'?Icons.water_drop:Icons.child_friendly),label:Text('Valider $title',style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(54)))]));}
}
class PathPainter extends CustomPainter { @override void paint(Canvas c,Size s){final p=Paint()..color=Colors.brown.shade300..strokeWidth=7..style=PaintingStyle.stroke;final path=Path()..moveTo(0,s.height/2)..quadraticBezierTo(s.width*.25,-8,s.width*.5,s.height/2)..quadraticBezierTo(s.width*.75,s.height+8,s.width,s.height/2);c.drawPath(path,p);}@override bool shouldRepaint(covariant CustomPainter old)=>false; }
class ProgressDialog extends StatelessWidget { const ProgressDialog({super.key,required this.step,required this.total});final int step,total;@override Widget build(BuildContext context){final v=vehicleForStep(step,total);return AlertDialog(title:const Text('Bravo !',textAlign:TextAlign.center,style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),content:Column(mainAxisSize:MainAxisSize.min,children:[Text(v,style:const TextStyle(fontSize:78)),Text(vehicleName(v),style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Le voyage continue !',textAlign:TextAlign.center)]));}}
class TreasureDialog extends StatefulWidget { const TreasureDialog({super.key});@override State<TreasureDialog> createState()=>_TreasureDialogState(); }
class _TreasureDialogState extends State<TreasureDialog>{late final ConfettiController controller;Timer? timer;@override void initState(){super.initState();controller=ConfettiController(duration:const Duration(seconds:2));WidgetsBinding.instance.addPostFrameCallback((_){controller.play();timer=Timer(const Duration(milliseconds:2200),(){if(mounted)Navigator.pop(context);});});}@override void dispose(){timer?.cancel();controller.dispose();super.dispose();}@override Widget build(BuildContext context)=>Stack(alignment:Alignment.center,children:[AlertDialog(title:const Text('🎉 Trésor !',textAlign:TextAlign.center,style:TextStyle(fontSize:32,fontWeight:FontWeight.w900)),content:const Column(mainAxisSize:MainAxisSize.min,children:[Text('🧰',style:TextStyle(fontSize:92)),Text('✨ 💰 ⭐ 💰 ✨',style:TextStyle(fontSize:25)),SizedBox(height:10),Text('Bravo, le coffre est ouvert !',textAlign:TextAlign.center,style:TextStyle(fontSize:18))]),),ConfettiWidget(confettiController:controller,blastDirectionality:BlastDirectionality.explosive,shouldLoop:false,numberOfParticles:35,gravity:.25)]);}
