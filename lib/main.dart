import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api.dart';
import 'splash_page.dart';
import 'screens/analyzer_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/therapy_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/schemes_screen.dart';

void main() => runApp(const KrishiSevaApp());

class KrishiSevaApp extends StatefulWidget {
  const KrishiSevaApp({super.key});
  @override
  State<KrishiSevaApp> createState() => _KrishiSevaAppState();
}

class _KrishiSevaAppState extends State<KrishiSevaApp> {
  String lang = 'hi';
  final api = Api();
  int _tab = 0;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final sp = await SharedPreferences.getInstance();
    setState(() => lang = sp.getString('lang') ?? 'hi');
    // end splash after language loads
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  Future<void> _setLang(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('lang', v);
    setState(() => lang = v);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AnalyzerScreen(api: api, lang: lang),
      SchemesScreen(api: api, lang: lang),
      ChatScreen(api: api, lang: lang),
      TherapyScreen(api: api, lang: lang),
      WeatherScreen(api: api, lang: lang),
    ];

    // Brand palette (from web styles.css)
    const saffron = Color(0xFFFF9933);
    const green = Color(0xFF138808);
    const bg = Color(0xFF08160C);
    const card = Color(0xFF0F2A15);

    final textTheme = GoogleFonts.nunitoTextTheme();

    return MaterialApp(
      title: 'KRISHI SEVA',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
          background: bg,
        ),
        scaffoldBackgroundColor: bg,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0B1F0F).withOpacity(0.65),
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFE9F5EC),
          ),
        ),
        cardTheme: const CardThemeData(
          color: card,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.all(12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFF04140A),
            backgroundColor: green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0x30FFFFFF)),
          ),
        ),
      ),
      home: _showSplash
          ? SplashPage(
              imagePath: 'slash.png',
              onFinished: () => setState(() => _showSplash = false),
              duration: const Duration(milliseconds: 1400),
            )
          : Scaffold(
            appBar: AppBar(
              title: const Text('KRISHI SEVA'),
              flexibleSpace: Stack(
                children: const [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _TricolorRibbon(),
                  ),
                ],
              ),
              actions: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: lang,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                    ],
                    onChanged: (v) => _setLang(v ?? 'hi'),
                  ),
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.1, -0.2),
                  radius: 1.2,
                  colors: [Color(0x26FF9933), Colors.transparent],
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_tab), child: tabs[_tab]),
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.image), label: 'Analyzer'),
                NavigationDestination(icon: Icon(Icons.assignment), label: 'Schemes'),
                NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
                NavigationDestination(icon: Icon(Icons.favorite), label: 'Therapy'),
                NavigationDestination(icon: Icon(Icons.cloud), label: 'Weather'),
              ],
            ),
        ),
      );
    }
}
class _TricolorRibbon extends StatelessWidget {
  const _TricolorRibbon();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF9933),
            Color(0xFFFFFFFF),
            Color(0xFF138808),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}
