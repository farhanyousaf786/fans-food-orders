import 'package:fans_food_order/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'bloc/order/order_bloc.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox('myBox');
  // Initialize Firebase Core
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase services (App Check and FCM)
  await FirebaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: BlocProvider(
        create: (context) => OrderBloc(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                return MaterialApp(
                locale: languageProvider.appLocale,
                supportedLocales: const [Locale('en', ''), Locale('he', '')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                title: 'Fans Food Order',
                theme: themeProvider.themeData,
                home: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return authProvider.isAuthenticated
                        ? const HomeScreen()
                        : const SignInScreen();
                  },
                ),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
        ),
      ),
    );
  }
}
