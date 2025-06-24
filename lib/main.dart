import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/router.dart';
import 'features/generator/views/widgets/generator_widgets_extentions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: ResponsiveScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Portfolio PDF',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          margin: EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'NotoSans'),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
