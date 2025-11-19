import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/book_list_screen.dart';
import 'providers/book_provider.dart';
import 'providers/search_provider.dart';
import 'providers/filter_provider.dart';
import 'database/database_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop platforms before running the app
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI - this will try to use system SQLite or bundled DLL
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DatabaseService(),
        ),
        ChangeNotifierProxyProvider<DatabaseService, BookProvider>(
          create: (_) => BookProvider(null),
          update: (_, databaseService, previous) =>
              BookProvider(databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FilterProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'PG DB Browser',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const BookListScreen(),
      ),
    );
  }
}

