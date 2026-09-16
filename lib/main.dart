import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ApexKartAI());
}

// ============================================================
// APEX KART AI
// Version 0.2 - Setup Engineer
// ============================================================

class ApexKartAI extends StatelessWidget {
  const ApexKartAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APEX Kart AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF090B0F),
        cardColor: const Color(0xFF14171D),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF15181E),
          border: OutlineInputBorder(),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// SESSION MODEL
// ============================================================

class KartSession {
  final String date;
  final String track;
  final String sessionType;

  final String chassis;
  final String engine;
  final String tyres;

  final String frontSprocket;
  final String rearSprocket;

  final String frontWidth;
  final String rearWidth;

  final String frontRideHeight;
  final String rearRideHeight;

  final String caster;
  final String camber;
  final String toe;
  final String ackermann;

  final String axle;
  final String frontHubs;
  final String rearHubs;

  final String frontBar;
  final String rearBar;

  final String coldPressureFL;
  final String coldPressureFR;
  final String coldPressureRL;
  final String coldPressureRR;

  final String hotPressureFL;
  final String hotPressureFR;
  final String hotPressureRL;
  final String hotPressureRR;

  final String airTemp;
  final String trackTemp;
  final String weather;
  final String gripLevel;

  final String balanceEntry;
  final String balanceMid;
  final String balanceExit;

  final String braking;
  final String traction;
  final String hopping;

  final String setupChange;
  final String feedback;

  final List<double> laps;

  KartSession({
    required this.date,
    required this.track,
    required this.sessionType,
    required this.chassis,
    required this.engine,
    required this.tyres,
    required this.frontSprocket,
    required this.rearSprocket,
    required this.frontWidth,
    required this.rearWidth,
    required this.frontRideHeight,
    required this.rearRideHeight,
    required this.caster,
    required this.camber,
    required this.toe,
    required this.ackermann,
    required this.axle,
    required this.frontHubs,
    required this.rearHubs,
    required this.frontBar,
    required this.rearBar,
    required this.coldPressureFL,
    required this.coldPressureFR,
    required this.coldPressureRL,
    required this.coldPressureRR,
    required this.hotPressureFL,
    required this.hotPressureFR,
    required this.hotPressureRL,
    required this.hotPressureRR,
    required this.airTemp,
    required this.trackTemp,
    required this.weather,
    required this.gripLevel,
    required this.balanceEntry,
    required this.balanceMid,
    required this.balanceExit,
    required this.braking,
    required this.traction,
    required this.hopping,
    required this.setupChange,
    required this.feedback,
    required this.laps,
  });

  double? get bestLap {
    if (laps.isEmpty) return null;
    return laps.reduce(min);
  }

  double? get averageLap {
    if (laps.isEmpty) return null;

    double total = 0;

    for (final lap in laps) {
      total += lap;
    }

    return total / laps.length;
  }

  double? get consistency {
    if (laps.length < 2) return null;

    final avg = averageLap!;

    double totalDifference = 0;

    for (final lap in laps) {
      totalDifference += (lap - avg).abs();
    }

    return totalDifference / laps.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'track': track,
      'sessionType': sessionType,
      'chassis': chassis,
      'engine': engine,
      'tyres': tyres,
      'frontSprocket': frontSprocket,
      'rearSprocket': rearSprocket,
      'frontWidth': frontWidth,
      'rearWidth': rearWidth,
      'frontRideHeight': frontRideHeight,
      'rearRideHeight': rearRideHeight,
      'caster': caster,
      'camber': camber,
      'toe': toe,
      'ackermann': ackermann,
      'axle': axle,
      'frontHubs': frontHubs,
      'rearHubs': rearHubs,
      'frontBar': frontBar,
      'rearBar': rearBar,
      'coldPressureFL': coldPressureFL,
      'coldPressureFR': coldPressureFR,
      'coldPressureRL': coldPressureRL,
      'coldPressureRR': coldPressureRR,
      'hotPressureFL': hotPressureFL,
      'hotPressureFR': hotPressureFR,
      'hotPressureRL': hotPressureRL,
      'hotPressureRR': hotPressureRR,
      'airTemp': airTemp,
      'trackTemp': trackTemp,
      'weather': weather,
      'gripLevel': gripLevel,
      'balanceEntry': balanceEntry,
      'balanceMid': balanceMid,
      'balanceExit': balanceExit,
      'braking': braking,
      'traction': traction,
      'hopping': hopping,
      'setupChange': setupChange,
      'feedback': feedback,
      'laps': laps,
    };
  }

  factory KartSession.fromJson(Map<String, dynamic> json) {
    return KartSession(
      date: json['date']?.toString() ?? '',
      track: json['track']?.toString() ?? '',
      sessionType: json['sessionType']?.toString() ?? '',
      chassis: json['chassis']?.toString() ?? '',
      engine: json['engine']?.toString() ?? '',
      tyres: json['tyres']?.toString() ?? '',
      frontSprocket: json['frontSprocket']?.toString() ?? '',
      rearSprocket: json['rearSprocket']?.toString() ?? '',
      frontWidth: json['frontWidth']?.toString() ?? '',
      rearWidth: json['rearWidth']?.toString() ?? '',
      frontRideHeight: json['frontRideHeight']?.toString() ?? '',
      rearRideHeight: json['rearRideHeight']?.toString() ?? '',
      caster: json['caster']?.toString() ?? '',
      camber: json['camber']?.toString() ?? '',
      toe: json['toe']?.toString() ?? '',
      ackermann: json['ackermann']?.toString() ?? '',
      axle: json['axle']?.toString() ?? '',
      frontHubs: json['frontHubs']?.toString() ?? '',
      rearHubs: json['rearHubs']?.toString() ?? '',
      frontBar: json['frontBar']?.toString() ?? '',
      rearBar: json['rearBar']?.toString() ?? '',
      coldPressureFL: json['coldPressureFL']?.toString() ?? '',
      coldPressureFR: json['coldPressureFR']?.toString() ?? '',
      coldPressureRL: json['coldPressureRL']?.toString() ?? '',
      coldPressureRR: json['coldPressureRR']?.toString() ?? '',
      hotPressureFL: json['hotPressureFL']?.toString() ?? '',
      hotPressureFR: json['hotPressureFR']?.toString() ?? '',
      hotPressureRL: json['hotPressureRL']?.toString() ?? '',
      hotPressureRR: json['hotPressureRR']?.toString() ?? '',
      airTemp: json['airTemp']?.toString() ?? '',
      trackTemp: json['trackTemp']?.toString() ?? '',
      weather: json['weather']?.toString() ?? '',
      gripLevel: json['gripLevel']?.toString() ?? '',
      balanceEntry: json['balanceEntry']?.toString() ?? '',
      balanceMid: json['balanceMid']?.toString() ?? '',
      balanceExit: json['balanceExit']?.toString() ?? '',
      braking: json['braking']?.toString() ?? '',
      traction: json['traction']?.toString() ?? '',
      hopping: json['hopping']?.toString() ?? '',
      setupChange: json['setupChange']?.toString() ?? '',
      feedback: json['feedback']?.toString() ?? '',
      laps: (json['laps'] as List<dynamic>? ?? [])
          .map((e) => double.tryParse(e.toString()))
          .whereType<double>()
          .toList(),
    );
  }
}

// ============================================================
// STORAGE
// ============================================================

class SessionStorage {
  static const String key = 'apex_sessions_v2';

  static Future<List<KartSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();

    String? stored = prefs.getString(key);

    // Try old storage if this is the first v0.2 launch.
    stored ??= prefs.getString('apex_sessions');

    if (stored == null || stored.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(stored);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (item) => KartSession.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSessions(List<KartSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();

    final data = sessions.map((session) => session.toJson()).toList();

    await prefs.setString(
      key,
      jsonEncode(data),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<KartSession> sessions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final loaded = await SessionStorage.loadSessions();

    if (!mounted) return;

    setState(() {
      sessions = loaded;
      loading = false;
    });
  }

  Future<void> addSession() async {
    final session = await Navigator.push<KartSession>(
      context,
      MaterialPageRoute(
        builder: (_) => const NewSessionPage(),
      ),
    );

    if (session == null) return;

    setState(() {
      sessions.insert(0, session);
    });

    await SessionStorage.saveSessions(sessions);
  }

  Future<void> deleteSession(int index) async {
    setState(() {
      sessions.removeAt(index);
    });

    await SessionStorage.saveSessions(sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'APEX',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            Text(
              'KART AI • v0.2',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addSession,
        icon: const Icon(Icons.add),
        label: const Text('NEW SESSION'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DashboardCard(
                  sessions: sessions,
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.psychology,
                  title: 'APEX Setup Engineer',
                  subtitle:
                      'Analyzes handling, setup changes, conditions and lap performance.',
                  onTap: sessions.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EngineerPage(
                                sessions: sessions,
                              ),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.bluetooth,
                  title: 'Alfano 7',
                  subtitle:
                      'Bluetooth telemetry integration is planned for a later version.',
                  onTap: () {
                    showMessage(
                      context,
                      'Alfano 7 Bluetooth is coming later. First we are building the setup intelligence.',
                    );
                  },
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.cloud,
                  title: 'Weather',
                  subtitle:
                      'Automatic live weather will be connected in a later version.',
                  onTap: () {
                    showMessage(
                      context,
                      'Automatic weather is coming later. For now you can log conditions manually.',
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'SESSIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                if (sessions.isEmpty)
                  const _EmptySessions()
                else
                  ...List.generate(
                    sessions.length,
                    (index) {
                      final session = sessions[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SessionCard(
                          session: session,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SessionDetailPage(
                                  session: session,
                                  previousSession:
                                      index + 1 < sessions.length
                                          ? sessions[index + 1]
                                          : null,
                                ),
                              ),
                            );
                          },
                          onDelete: () => deleteSession(index),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class _DashboardCard extends StatelessWidget {
  final List<KartSession> sessions;

  const _DashboardCard({
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    double? allTimeBest;

    for (final session in sessions) {
      final best = session.bestLap;

      if (best != null) {
        if (allTimeBest == null || best < allTimeBest) {
          allTimeBest = best;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12151A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RACE ENGINEER',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sessions.isEmpty
                ? 'Create your first session to start building the APEX setup database.'
                : '${sessions.length} sessions recorded. APEX is building your setup history.',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  title: 'SESSIONS',
                  value: sessions.length.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  title: 'BEST LAP',
                  value: allTimeBest == null
                      ? '--'
                      : formatLap(allTimeBest),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;

  const _StatBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Icon(
          icon,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptySessions extends StatelessWidget {
  const _EmptySessions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF12151A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.sports_motorsports,
            size: 50,
            color: Colors.white38,
          ),
          SizedBox(height: 14),
          Text(
            'No sessions yet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Press NEW SESSION after your next run.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SESSION CARD
// ============================================================

class SessionCard extends StatelessWidget {
  final KartSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Text(
          session.track.isEmpty
              ? 'Unknown track'
              : session.track,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${session.date} • ${session.sessionType}\n'
            'Best: ${session.bestLap == null ? '--' : formatLap(session.bestLap!)}',
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete session'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NEW SESSION
// ============================================================

class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key});

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
  final track = TextEditingController();
  final sessionType = TextEditingController(text: 'Practice');

  final chassis = TextEditingController(text: 'Haase');
  final engine = TextEditingController(text: 'Rotax Max Senior');
  final tyres = TextEditingController();

  final frontSprocket = TextEditingController();
  final rearSprocket = TextEditingController();

  final frontWidth = TextEditingController();
  final rearWidth = TextEditingController();

  final frontRideHeight = TextEditingController();
  final rearRideHeight = TextEditingController();

  final caster = TextEditingController();
  final camber = TextEditingController();
  final toe = TextEditingController();
  final ackermann = TextEditingController();

  final axle = TextEditingController();
  final frontHubs = TextEditingController();
  final rearHubs = TextEditingController();

  final frontBar = TextEditingController();
  final rearBar = TextEditingController();

  final coldPressureFL = TextEditingController();
  final coldPressureFR = TextEditingController();
  final coldPressureRL = TextEditingController();
  final coldPressureRR = TextEditingController();

  final hotPressureFL = TextEditingController();
  final hotPressureFR = TextEditingController();
  final hotPressureRL = TextEditingController();
  final hotPressureRR = TextEditingController();

  final airTemp = TextEditingController();
  final trackTemp = TextEditingController();
  final weather = TextEditingController();
  final gripLevel = TextEditingController();

  final balanceEntry = TextEditingController();
  final balanceMid = TextEditingController();
  final balanceExit = TextEditingController();

  final braking = TextEditingController();
  final traction = TextEditingController();
  final hopping = TextEditingController();

  final setupChange = TextEditingController();
  final feedback = TextEditingController();

  final laps = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      track,
      sessionType,
      chassis,
      engine,
      tyres,
      frontSprocket,
      rearSprocket,
      frontWidth,
      rearWidth,
      frontRideHeight,
      rearRideHeight,
      caster,
      camber,
      toe,
      ackermann,
      axle,
      frontHubs,
      rearHubs,
      frontBar,
      rearBar,
      coldPressureFL,
      coldPressureFR,
      coldPressureRL,
      coldPressureRR,
      hotPressureFL,
      hotPressureFR,
      hotPressureRL,
      hotPressureRR,
      airTemp,
      trackTemp,
      weather,
      gripLevel,
      balanceEntry,
      balanceMid,
      balanceExit,
      braking,
      traction,
      hopping,
      setupChange,
      feedback,
      laps,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Widget input(
    TextEditingController controller,
    String label, {
    int lines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: lines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  List<double> parseLaps(String input) {
    final cleaned = input
        .replaceAll(';', ',')
        .replaceAll('\n', ',');

    return cleaned
        .split(',')
        .map((item) => double.tryParse(item.trim()))
        .whereType<double>()
        .where((lap) => lap > 0)
        .toList();
  }

  void save() {
    final parsedLaps = parseLaps(laps.text);

    if (track.text.trim().isEmpty) {
      showMessage(
        context,
        'Enter a track name.',
      );
      return;
    }

    final now = DateTime.now();

    final session = KartSession(
      date:
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}',
      track: track.text.trim(),
      sessionType: sessionType.text.trim(),
      chassis: chassis.text.trim(),
      engine: engine.text.trim(),
      tyres: tyres.text.trim(),
      frontSprocket: frontSprocket.text.trim(),
      rearSprocket: rearSprocket.text.trim(),
      frontWidth: frontWidth.text.trim(),
      rearWidth: rearWidth.text.trim(),
      frontRideHeight: frontRideHeight.text.trim(),
      rearRideHeight: rearRideHeight.text.trim(),
      caster: caster.text.trim(),
      camber: camber.text.trim(),
      toe: toe.text.trim(),
      ackermann: ackermann.text.trim(),
      axle: axle.text.trim(),
      frontHubs: frontHubs.text.trim(),
      rearHubs: rearHubs.text.trim(),
      frontBar: frontBar.text.trim(),
      rearBar: rearBar.text.trim(),
      coldPressureFL: coldPressureFL.text.trim(),
      coldPressureFR: coldPressureFR.text.trim(),
      coldPressureRL: coldPressureRL.text.trim(),
      coldPressureRR: coldPressureRR.text.trim(),
      hotPressureFL: hotPressureFL.text.trim(),
      hotPressureFR: hotPressureFR.text.trim(),
      hotPressureRL: hotPressureRL.text.trim(),
      hotPressureRR: hotPressureRR.text.trim(),
      airTemp: airTemp.text.trim(),
      trackTemp: trackTemp.text.trim(),
      weather: weather.text.trim(),
      gripLevel: gripLevel.text.trim(),
      balanceEntry: balanceEntry.text.trim(),
      balanceMid: balanceMid.text.trim(),
      balanceExit: balanceExit.text.trim(),
      braking: braking.text.trim(),
      traction: traction.text.trim(),
      hopping: hopping.text.trim(),
      setupChange: setupChange.text.trim(),
      feedback: feedback.text.trim(),
      laps: parsedLaps,
    );

    Navigator.pop(
      context,
      session,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NEW SESSION',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          section('SESSION'),
          input(
            track,
            'Track',
          ),
          input(
            sessionType,
            'Session type',
          ),

          section('KART'),
          input(
            chassis,
            'Chassis',
          ),
          input(
            engine,
            'Engine',
          ),
          input(
            tyres,
            'Tyres / compound',
          ),

          section('GEARING'),
          Row(
            children: [
              Expanded(
                child: input(
                  frontSprocket,
                  'Front sprocket',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: input(
                  rearSprocket,
                  'Rear sprocket',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          section('CHASSIS GEOMETRY'),
          Row(
            children: [
              Expanded(
                child: input(
                  frontWidth,
                  'Front width mm',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: input(
                  rearWidth,
                  'Rear width mm',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: input(
                  frontRideHeight,
                  'Front ride height',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: input(
                  rearRideHeight,
                  'Rear ride height',
                ),
              ),
            ],
          ),
          input(
            caster,
            'Caster',
          ),
          input(
            camber,
            'Camber',
          ),
          input(
            toe,
            'Toe',
          ),
          input(
            ackermann,
            'Ackermann',
          ),

          section('AXLE / HUBS / BARS'),
          input(
            axle,
            'Rear axle type / stiffness',
          ),
          input(
            frontHubs,
            'Front hubs',
          ),
          input(
            rearHubs,
            'Rear hubs',
          ),
          input(
            frontBar,
            'Front torsion bar',
          ),
          input(
            rearBar,
            'Rear torsion bar',
          ),

          section('COLD TYRE PRESSURES'),
          Row(
            children: [
              Expanded(
                child: input(
                  coldPressureFL,
                  'FL bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: input(
                  coldPressureFR,
                  'FR bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: input(
                  coldPressureRL,
                  'RL bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: input(
                  coldPressureRR,
                  'RR bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),

          section('HOT TYRE PRESSURES'),
          Row(
            children: [
              Expanded(
                child: input(
                  hotPressureFL,
                  'FL bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: input(
                  hotPressureFR,
                  'FR bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: input(
                  hotPressureRL,
                  'RL bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: input(
                  hotPressureRR,
                  'RR bar',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),

          section('TRACK CONDITIONS'),
          Row(
            children: [
              Expanded(
                child: input(
                  airTemp,
                  'Air °C',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: input(
                  trackTemp,
                  'Track °C',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          input(
            weather,
            'Weather (dry, cloudy, rain...)',
          ),
          input(
            gripLevel,
            'Grip level (low / medium / high)',
          ),

          section('DRIVER FEEDBACK'),
          input(
            balanceEntry,
            'Corner entry',
          ),
          input(
            balanceMid,
            'Mid-corner',
          ),
          input(
            balanceExit,
            'Corner exit',
          ),
          input(
            braking,
            'Braking stability',
          ),
          input(
            traction,
            'Traction',
          ),
          input(
            hopping,
            'Hopping / binding',
          ),

          section('SETUP CHANGE'),
          input(
            setupChange,
            'What did you change since the previous run?',
            lines: 3,
          ),

          section('LAP TIMES'),
          input(
            laps,
            'Lap times separated by commas\nExample: 51.42, 51.31, 51.19',
            lines: 3,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),

          section('NOTES'),
          input(
            feedback,
            'Other driver feedback / notes',
            lines: 4,
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save),
            label: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'SAVE SESSION',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// ============================================================
// SESSION DETAILS
// ============================================================

class SessionDetailPage extends StatelessWidget {
  final KartSession session;
  final KartSession? previousSession;

  const SessionDetailPage({
    super.key,
    required this.session,
    this.previousSession,
  });

  @override
  Widget build(BuildContext context) {
    final engineer = SetupEngineer.analyze(
      session,
      previousSession,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          session.track,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailSection(
            title: 'PERFORMANCE',
            children: [
              detail(
                'Best lap',
                session.bestLap == null
                    ? '--'
                    : formatLap(session.bestLap!),
              ),
              detail(
                'Average lap',
                session.averageLap == null
                    ? '--'
                    : formatLap(session.averageLap!),
              ),
              detail(
                'Consistency',
                session.consistency == null
                    ? '--'
                    : '±${session.consistency!.toStringAsFixed(3)} s',
              ),
              detail(
                'Laps',
                session.laps.length.toString(),
              ),
            ],
          ),

          _DetailSection(
            title: 'KART',
            children: [
              detail('Chassis', session.chassis),
              detail('Engine', session.engine),
              detail('Tyres', session.tyres),
              detail(
                'Gearing',
                joinValues(
                  session.frontSprocket,
                  session.rearSprocket,
                ),
              ),
            ],
          ),

          _DetailSection(
            title: 'CHASSIS SETUP',
            children: [
              detail('Front width', session.frontWidth),
              detail('Rear width', session.rearWidth),
              detail(
                'Ride height F/R',
                joinValues(
                  session.frontRideHeight,
                  session.rearRideHeight,
                ),
              ),
              detail('Caster', session.caster),
              detail('Camber', session.camber),
              detail('Toe', session.toe),
              detail('Ackermann', session.ackermann),
              detail('Axle', session.axle),
              detail('Front hubs', session.frontHubs),
              detail('Rear hubs', session.rearHubs),
              detail('Front bar', session.frontBar),
              detail('Rear bar', session.rearBar),
            ],
          ),

          _DetailSection(
            title: 'TYRES',
            children: [
              detail(
                'Cold FL / FR',
                joinValues(
                  session.coldPressureFL,
                  session.coldPressureFR,
                ),
              ),
              detail(
                'Cold RL / RR',
                joinValues(
                  session.coldPressureRL,
                  session.coldPressureRR,
                ),
              ),
              detail(
                'Hot FL / FR',
                joinValues(
                  session.hotPressureFL,
                  session.hotPressureFR,
                ),
              ),
              detail(
                'Hot RL / RR',
                joinValues(
                  session.hotPressureRL,
                  session.hotPressureRR,
                ),
              ),
            ],
          ),

          _DetailSection(
            title: 'CONDITIONS',
            children: [
              detail('Air temperature', session.airTemp),
              detail('Track temperature', session.trackTemp),
              detail('Weather', session.weather),
              detail('Grip level', session.gripLevel),
            ],
          ),

          _DetailSection(
            title: 'DRIVER',
            children: [
              detail('Entry', session.balanceEntry),
              detail('Mid-corner', session.balanceMid),
              detail('Exit', session.balanceExit),
              detail('Braking', session.braking),
              detail('Traction', session.traction),
              detail('Hopping', session.hopping),
              detail('Setup change', session.setupChange),
              detail('Notes', session.feedback),
            ],
          ),

          _EngineerResultCard(
            result: engineer,
          ),

          if (session.laps.isNotEmpty)
            _DetailSection(
              title: 'LAP TIMES',
              children: List.generate(
                session.laps.length,
                (index) {
                  final lap = session.laps[index];
                  final best = session.bestLap;

                  return detail(
                    'Lap ${index + 1}',
                    '${formatLap(lap)}'
                    '${best != null && lap == best ? '  • BEST' : ''}',
                  );
                },
              ),
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget detail(String title, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SETUP ENGINEER
// ============================================================

class EngineerResult {
  final String problem;
  final String recommendation;
  final String reasoning;
  final String comparison;

  const EngineerResult({
    required this.problem,
    required this.recommendation,
    required this.reasoning,
    required this.comparison,
  });
}

class SetupEngineer {
  static EngineerResult analyze(
    KartSession current,
    KartSession? previous,
  ) {
    final feedback = [
      current.balanceEntry,
      current.balanceMid,
      current.balanceExit,
      current.braking,
      current.traction,
      current.hopping,
      current.feedback,
    ].join(' ').toLowerCase();

    String problem = 'No major balance problem detected.';
    String recommendation =
        'Keep the current baseline. Change only one setup variable at a time.';
    String reasoning =
        'APEX needs repeatable A/B testing to learn which changes actually improve the kart.';

    if (feedback.contains('understeer') ||
        feedback.contains('push') ||
        feedback.contains('won\'t turn') ||
        feedback.contains('does not turn')) {
      problem = 'Understeer detected';

      if (current.balanceEntry.toLowerCase().contains('understeer') ||
          current.balanceEntry.toLowerCase().contains('push')) {
        recommendation =
            'Work on front response at corner entry. Test one small, reversible change such as caster, front track width or toe. Do not combine several changes.';
        reasoning =
            'Entry understeer means the kart is not rotating sufficiently during turn-in. A single-variable test lets APEX determine whether the change actually improves rotation.';
      } else if (current.balanceMid.toLowerCase().contains('understeer') ||
          current.balanceMid.toLowerCase().contains('push')) {
        recommendation =
            'Target mid-corner rotation. Review front grip, rear track width and whether the inside rear is unloading correctly. Change one parameter for the next run.';
        reasoning =
            'Mid-corner understeer can come from insufficient front grip or excessive rear grip/binding.';
      } else if (current.balanceExit.toLowerCase().contains('understeer') ||
          current.balanceExit.toLowerCase().contains('push')) {
        recommendation =
            'Exit understeer detected. Review rotation before throttle and rear grip. Keep gearing and chassis changes separate so the result remains measurable.';
        reasoning =
            'Exit push can be a chassis-balance issue, a driving-line issue or excessive rear grip. A controlled test is more useful than changing several components.';
      } else {
        recommendation =
            'Test one front-grip or rotation adjustment and compare the next run with this baseline.';
        reasoning =
            'The feedback indicates understeer, but APEX needs the corner phase to isolate it more accurately.';
      }
    } else if (feedback.contains('oversteer') ||
        feedback.contains('loose') ||
        feedback.contains('rear slide')) {
      problem = 'Oversteer detected';

      if (current.balanceEntry.toLowerCase().contains('oversteer') ||
          current.balanceEntry.toLowerCase().contains('loose')) {
        recommendation =
            'Prioritize entry stability. Check braking technique and test one rear-stability change before altering other parts of the setup.';
        reasoning =
            'Entry oversteer can be caused by rear instability during braking/turn-in. One controlled change makes the result easier to identify.';
      } else {
        recommendation =
            'Test one rear-stability adjustment and compare lap time, consistency and driver confidence.';
        reasoning =
            'The rear of the kart is losing stability. APEX recommends isolating the change rather than changing multiple variables.';
      }
    } else if (feedback.contains('hop') ||
        feedback.contains('binding') ||
        feedback.contains('bind')) {
      problem = 'Hopping / binding detected';
      recommendation =
          'Investigate whether the kart is carrying excessive grip or failing to release the inside rear. Test one chassis change at a time.';
      reasoning =
          'A kart that binds or hops can lose corner speed even when total grip is high. The goal is controlled inside-rear lift and release.';
    } else if (feedback.contains('no traction') ||
        feedback.contains('wheelspin') ||
        feedback.contains('wheel spin') ||
        feedback.contains('poor traction')) {
      problem = 'Low exit traction detected';
      recommendation =
          'Focus on rear traction and throttle application. Test one rear-grip adjustment and keep gearing unchanged during that comparison.';
      reasoning =
          'Separating chassis changes from gearing changes helps identify whether the improvement comes from mechanical grip or acceleration characteristics.';
    } else if (feedback.contains('unstable braking') ||
        feedback.contains('braking unstable') ||
        feedback.contains('rear locks')) {
      problem = 'Braking instability detected';
      recommendation =
          'Treat braking stability as the priority before chasing corner balance. Verify the kart mechanically and make only one setup change for the next test.';
      reasoning =
          'Unstable braking compromises corner entry and can make the driver report secondary handling problems that are not actually caused by chassis balance.';
    }

    String comparison = 'No previous comparable session available yet.';

    if (previous != null) {
      final currentBest = current.bestLap;
      final previousBest = previous.bestLap;

      if (currentBest != null && previousBest != null) {
        final difference = currentBest - previousBest;

        if (difference < 0) {
          comparison =
              'Best lap improved by ${difference.abs().toStringAsFixed(3)} s compared with the previous stored session.';
        } else if (difference > 0) {
          comparison =
              'Best lap was ${difference.toStringAsFixed(3)} s slower than the previous stored session.';
        } else {
          comparison =
              'Best lap matched the previous stored session.';
        }

        if (current.setupChange.isNotEmpty) {
          comparison +=
              '\nLogged setup change: ${current.setupChange}';
        }

        if (current.consistency != null &&
            previous.consistency != null) {
          final consistencyDifference =
              current.consistency! - previous.consistency!;

          if (consistencyDifference < 0) {
            comparison +=
                '\nConsistency improved by ${consistencyDifference.abs().toStringAsFixed(3)} s.';
          } else if (consistencyDifference > 0) {
            comparison +=
                '\nConsistency became ${consistencyDifference.toStringAsFixed(3)} s less stable.';
          }
        }
      }
    }

    return EngineerResult(
      problem: problem,
      recommendation: recommendation,
      reasoning: reasoning,
      comparison: comparison,
    );
  }
}

// ============================================================
// ENGINEER PAGE
// ============================================================

class EngineerPage extends StatelessWidget {
  final List<KartSession> sessions;

  const EngineerPage({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No sessions available.',
          ),
        ),
      );
    }

    final current = sessions.first;
    final previous =
        sessions.length > 1 ? sessions[1] : null;

    final result = SetupEngineer.analyze(
      current,
      previous,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'APEX SETUP ENGINEER',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            current.track,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Latest session analysis',
            style: TextStyle(
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 20),
          _EngineerResultCard(
            result: result,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APEX METHOD',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Establish a baseline.\n'
                    '2. Record driver feedback.\n'
                    '3. Change one setup variable.\n'
                    '4. Run again.\n'
                    '5. Compare lap time and consistency.\n'
                    '6. Keep or reverse the change.\n'
                    '7. Build the setup database.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${sessions.length} session(s) currently stored.',
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineerResultCard extends StatelessWidget {
  final EngineerResult result;

  const _EngineerResultCard({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.psychology,
                ),
                SizedBox(width: 10),
                Text(
                  'APEX ENGINEER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _EngineerText(
              title: 'DETECTED',
              text: result.problem,
            ),
            _EngineerText(
              title: 'NEXT TEST',
              text: result.recommendation,
            ),
            _EngineerText(
              title: 'WHY',
              text: result.reasoning,
            ),
            _EngineerText(
              title: 'COMPARISON',
              text: result.comparison,
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineerText extends StatelessWidget {
  final String title;
  final String text;

  const _EngineerText({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

String formatLap(double seconds) {
  if (seconds < 60) {
    return seconds.toStringAsFixed(3);
  }

  final minutes = seconds ~/ 60;
  final remaining = seconds - (minutes * 60);

  return '$minutes:${remaining.toStringAsFixed(3).padLeft(6, '0')}';
}

String joinValues(String first, String second) {
  final values = [
    first.trim(),
    second.trim(),
  ].where((value) => value.isNotEmpty).toList();

  if (values.isEmpty) {
    return '';
  }

  return values.join(' / ');
}

void showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}