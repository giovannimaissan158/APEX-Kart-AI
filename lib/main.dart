import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ApexApp());
}

class ApexApp extends StatelessWidget {
  const ApexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APEX Kart AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyan,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF071017),
      ),
      home: const HomeScreen(),
    );
  }
}

class KartSession {
  final String id;
  final String track;
  final String kart;
  final String engine;
  final String tyres;
  final String gearing;
  final String pressures;
  final String weather;
  final String trackCondition;
  final String feedback;
  final List<double> laps;
  final DateTime date;

  KartSession({
    required this.id,
    required this.track,
    required this.kart,
    required this.engine,
    required this.tyres,
    required this.gearing,
    required this.pressures,
    required this.weather,
    required this.trackCondition,
    required this.feedback,
    required this.laps,
    required this.date,
  });

  double? get bestLap {
    if (laps.isEmpty) return null;
    return laps.reduce(min);
  }

  double? get averageLap {
    if (laps.isEmpty) return null;

    return laps.reduce((a, b) => a + b) / laps.length;
  }

  double? get consistency {
    if (laps.length < 2) return null;

    final average = averageLap!;

    final variance = laps
            .map((lap) => pow(lap - average, 2))
            .reduce((a, b) => a + b) /
        laps.length;

    return sqrt(variance);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'track': track,
      'kart': kart,
      'engine': engine,
      'tyres': tyres,
      'gearing': gearing,
      'pressures': pressures,
      'weather': weather,
      'trackCondition': trackCondition,
      'feedback': feedback,
      'laps': laps,
      'date': date.toIso8601String(),
    };
  }

  factory KartSession.fromJson(Map<String, dynamic> json) {
    return KartSession(
      id: json['id'],
      track: json['track'] ?? '',
      kart: json['kart'] ?? '',
      engine: json['engine'] ?? '',
      tyres: json['tyres'] ?? '',
      gearing: json['gearing'] ?? '',
      pressures: json['pressures'] ?? '',
      weather: json['weather'] ?? '',
      trackCondition: json['trackCondition'] ?? '',
      feedback: json['feedback'] ?? '',
      laps: (json['laps'] as List? ?? [])
          .map((lap) => (lap as num).toDouble())
          .toList(),
      date: DateTime.parse(json['date']),
    );
  }
}

class SessionStorage {
  static const String storageKey = 'apex_sessions';

  static Future<List<KartSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();

    final storedData = prefs.getString(storageKey);

    if (storedData == null) {
      return [];
    }

    final decoded = jsonDecode(storedData) as List;

    return decoded
        .map((session) => KartSession.fromJson(session))
        .toList();
  }

  static Future<void> saveSessions(List<KartSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded =
        jsonEncode(sessions.map((session) => session.toJson()).toList());

    await prefs.setString(storageKey, encoded);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPage = 0;

  bool loading = true;

  List<KartSession> sessions = [];

  @override
  void initState() {
    super.initState();

    loadSessions();
  }

  Future<void> loadSessions() async {
    sessions = await SessionStorage.loadSessions();

    sessions.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    setState(() {
      loading = false;
    });
  }

  Future<void> createSession() async {
    final newSession = await Navigator.push<KartSession>(
      context,
      MaterialPageRoute(
        builder: (_) => const NewSessionScreen(),
      ),
    );

    if (newSession != null) {
      sessions.insert(0, newSession);

      await SessionStorage.saveSessions(sessions);

      setState(() {
        selectedPage = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(
        sessions: sessions,
        createSession: createSession,
      ),
      SessionsPage(
        sessions: sessions,
        createSession: createSession,
      ),
      EngineerPage(
        sessions: sessions,
      ),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'APEX // KART AI',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : pages[selectedPage],
      floatingActionButton: selectedPage <= 1
          ? FloatingActionButton.extended(
              onPressed: createSession,
              icon: const Icon(Icons.add),
              label: const Text('NEW SESSION'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPage,
        onDestinationSelected: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology),
            label: 'Engineer',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final List<KartSession> sessions;
  final VoidCallback createSession;

  const Dashboard({
    super.key,
    required this.sessions,
    required this.createSession,
  });

  @override
  Widget build(BuildContext context) {
    final latest = sessions.isEmpty ? null : sessions.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'RACE CONTROL',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Kart setup, telemetry and race engineering.',
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'SESSIONS',
                value: '${sessions.length}',
                icon: Icons.flag,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardCard(
                title: 'BEST LAP',
                value: latest?.bestLap == null
                    ? '--'
                    : '${latest!.bestLap!.toStringAsFixed(3)}s',
                icon: Icons.timer,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.bluetooth,
              size: 32,
            ),
            title: const Text(
              'ALFANO 7',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Bluetooth telemetry integration coming next.',
            ),
            trailing: const Chip(
              label: Text('SOON'),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.cloud,
              size: 32,
            ),
            title: const Text(
              'WEATHER',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Automatic track weather integration planned.',
            ),
          ),
        ),

        if (latest != null) ...[
          const SizedBox(height: 20),
          const Text(
            'LATEST SESSION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SessionCard(
            session: latest,
          ),
        ],
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionsPage extends StatelessWidget {
  final List<KartSession> sessions;
  final VoidCallback createSession;

  const SessionsPage({
    super.key,
    required this.sessions,
    required this.createSession,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sports_motorsports,
              size: 70,
            ),
            const SizedBox(height: 15),
            const Text(
              'No sessions yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            FilledButton(
              onPressed: createSession,
              child: const Text(
                'CREATE FIRST SESSION',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        return SessionCard(
          session: sessions[index],
        );
      },
    );
  }
}

class SessionCard extends StatelessWidget {
  final KartSession session;

  const SessionCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          session.track,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${session.date.day}-${session.date.month}-${session.date.year}'
          ' • ${session.laps.length} laps',
        ),
        trailing: Text(
          session.bestLap == null
              ? '--'
              : session.bestLap!.toStringAsFixed(3),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          info(
            'Kart',
            session.kart,
          ),
          info(
            'Engine',
            session.engine,
          ),
          info(
            'Gearing',
            session.gearing,
          ),
          info(
            'Tyres',
            session.tyres,
          ),
          info(
            'Pressures',
            session.pressures,
          ),
          info(
            'Weather',
            session.weather,
          ),
          info(
            'Track',
            session.trackCondition,
          ),
          info(
            'Driver feedback',
            session.feedback,
          ),
          info(
            'Best lap',
            session.bestLap?.toStringAsFixed(3) ?? '--',
          ),
          info(
            'Average',
            session.averageLap?.toStringAsFixed(3) ?? '--',
          ),
          info(
            'Consistency σ',
            session.consistency?.toStringAsFixed(3) ?? '--',
          ),
        ],
      ),
    );
  }

  Widget info(
    String title,
    String value,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? '--' : value,
      ),
    );
  }
}

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() {
    return _NewSessionScreenState();
  }
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final formKey = GlobalKey<FormState>();

  final track = TextEditingController();
  final kart = TextEditingController();
  final engine = TextEditingController();
  final tyres = TextEditingController();
  final gearing = TextEditingController();
  final pressures = TextEditingController();
  final weather = TextEditingController();
  final condition = TextEditingController();
  final feedback = TextEditingController();
  final laps = TextEditingController();

  List<double>? parseLaps() {
    final input = laps.text.trim();

    if (input.isEmpty) {
      return [];
    }

    final pieces = input.split(
      RegExp(r'[,;\n ]+'),
    );

    final values = <double>[];

    for (final piece in pieces) {
      if (piece.trim().isEmpty) {
        continue;
      }

      final value = double.tryParse(
        piece.trim(),
      );

      if (value == null) {
        return null;
      }

      values.add(value);
    }

    return values;
  }

  void saveSession() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final parsedLaps = parseLaps();

    if (parsedLaps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Check the lap-time format.',
          ),
        ),
      );

      return;
    }

    final session = KartSession(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      track: track.text.trim(),
      kart: kart.text.trim(),
      engine: engine.text.trim(),
      tyres: tyres.text.trim(),
      gearing: gearing.text.trim(),
      pressures: pressures.text.trim(),
      weather: weather.text.trim(),
      trackCondition: condition.text.trim(),
      feedback: feedback.text.trim(),
      laps: parsedLaps,
      date: DateTime.now(),
    );

    Navigator.pop(
      context,
      session,
    );
  }

  Widget input(
    TextEditingController controller,
    String label, {
    int lines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        validator: required
            ? (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return '$label is required';
                }

                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    track.dispose();
    kart.dispose();
    engine.dispose();
    tyres.dispose();
    gearing.dispose();
    pressures.dispose();
    weather.dispose();
    condition.dispose();
    feedback.dispose();
    laps.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NEW SESSION',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            input(
              track,
              'Track',
              required: true,
            ),
            input(
              kart,
              'Kart / chassis',
            ),
            input(
              engine,
              'Engine',
            ),
            input(
              tyres,
              'Tyres',
            ),
            input(
              gearing,
              'Gearing (example: 12/80)',
            ),
            input(
              pressures,
              'Tyre pressures',
            ),
            input(
              weather,
              'Weather',
            ),
            input(
              condition,
              'Track condition',
            ),
            input(
              feedback,
              'Driver feedback',
              lines: 3,
            ),
            input(
              laps,
              'Lap times in seconds',
              lines: 4,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: saveSession,
              icon: const Icon(
                Icons.save,
              ),
              label: const Text(
                'SAVE SESSION',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EngineerPage extends StatelessWidget {
  final List<KartSession> sessions;

  const EngineerPage({
    super.key,
    required this.sessions,
  });

  String getAdvice() {
    if (sessions.isEmpty) {
      return 'Log your first session. APEX needs data before making recommendations.';
    }

    final session = sessions.first;

    if (session.laps.length < 3) {
      return 'Record at least three representative laps before judging kart or driver performance.';
    }

    if ((session.consistency ?? 0) > 0.5) {
      return 'Lap variation is currently high. Keep the kart setup stable and focus on repeatable laps before making major setup changes.';
    }

    final feedback =
        session.feedback.toLowerCase();

    if (feedback.contains('understeer')) {
      return 'Understeer reported. Make only one front-grip adjustment for the next run, then compare pace and consistency against this baseline.';
    }

    if (feedback.contains('oversteer')) {
      return 'Oversteer reported. Test one rear-stability adjustment and compare it against this session.';
    }

    return 'The run is reasonably consistent. Telemetry and sector data are the next step for separating driver time loss from kart-balance effects.';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'AI RACE ENGINEER',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              getAdvice(),
              style: const TextStyle(
                fontSize: 17,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'APEX v0.1 uses evidence-based rules. '
          'Real telemetry analysis and AI reasoning will be added in later versions.',
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(
            Icons.phone_android,
          ),
          title: Text(
            'Platform',
          ),
          subtitle: Text(
            'Android priority',
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.storage,
          ),
          title: Text(
            'Storage',
          ),
          subtitle: Text(
            'Offline storage enabled',
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.bluetooth,
          ),
          title: Text(
            'Alfano 7',
          ),
          subtitle: Text(
            'Bluetooth integration planned',
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline,
          ),
          title: Text(
            'APEX Kart AI',
          ),
          subtitle: Text(
            'Version 0.1.0',
          ),
        ),
      ],
    );
  }
} 
