import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/post_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp(
        title: 'PostBoard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5), // indigo
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
          cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
          cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),    
   );
  }
}