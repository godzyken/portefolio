import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/services/theme_repository.dart';

import 'core/routes/router.dart';
import 'features/generator/views/widgets/generator_widgets_extentions.dart';
import 'features/parametres/themes/controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = ThemeRepository();
  final initial = await repo.loadTheme();
  await dotenv.load(fileName: "assets/.env");

  runApp(
    ProviderScope(
      overrides: [
        themeControllerProvider.overrideWith(
          (ref) => ThemeController(repo, initial),
        ),
      ],
      child: ResponsiveScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Portfolio PDF',

      theme: theme.toThemeData(),
      darkTheme: theme.toThemeData(),
      themeMode: ThemeMode.system,
      /* theme: ThemeData(
        fontFamily: 'NotoSans',
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        cardTheme: CardThemeData(
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
      ),*/
      routerConfig: router,
    );
  }
}
