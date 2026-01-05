import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:legal_analyzer/gemeni_provider.dart';
import 'package:provider/provider.dart';
import 'ui/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Definimos el Future en una variable para evitar que se reinicie al reconstruir el widget
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initApp();
  }

  Future<void> _initApp() async {
    // FORZAMOS 3 SEGUNDOS DE ESPERA REAL
    await Future.delayed(const Duration(seconds: 3));
    await dotenv.load(fileName: ".env");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // 1. Si todavía está cargando...
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoadingScreen(),
          );
        }

        // 2. Si terminó, cargamos la App con el Provider
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => GeminiProvider())],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}

// Pantalla de Carga de Alto Impacto
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.indigo[900], // Fondo oscuro para que se vea SI O SI
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel_rounded, size: 100, color: Colors.white),
            const SizedBox(height: 40),
            // Spinner blanco sobre fondo azul oscuro
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 6,
            ),
            const SizedBox(height: 30),
            const Text(
              "CONFIGURANDO IA LEGAL...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
