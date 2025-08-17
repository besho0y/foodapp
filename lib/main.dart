import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/firebase_options.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/screens/admin%20panel/cubit.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/login/cubit.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/signup/cubit.dart';
import 'package:foodapp/screens/splash/splash_screen.dart';
import 'package:foodapp/shared/admin_notification_service.dart';
import 'package:foodapp/shared/blocObserver.dart';
import 'package:foodapp/shared/firebase_messaging_service.dart';
import 'package:foodapp/shared/paymob_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/l10n.dart';
// Import the generated file

// Global navigator key for access across the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _initializeServices() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Clear cart storage (temporary fix)
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('cart_items');

  // Initialize services with error handling
  await _initializeFirebaseMessaging();
  await _initializeAdminNotificationService();
  _initializePayMobService();

  // Initialize Bloc Observer
  Bloc.observer = MyBlocObserver();
}

Future<void> _initializeFirebaseMessaging() async {
  try {
    await FirebaseMessagingService.initialize();
  } catch (e) {
    // Continue app startup even if messaging fails
  }
}

Future<void> _initializeAdminNotificationService() async {
  try {
    await AdminNotificationService.initialize();
  } catch (e) {
    // Continue app startup even if admin service fails
  }
}

void _initializePayMobService() {
  try {
    PayMobService.initialize();
  } catch (e) {
    // Continue app startup even if PayMob fails
  }
}

Future<Map<String, dynamic>> _loadUserPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'isArabic': prefs.getBool('isArabic') ?? false,
    'hasSelectedLocation': prefs.getBool('hasSelectedLocation') ?? false,
    'selectedArea': prefs.getString('selectedArea') ?? 'Cairo',
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeServices();
  final userPrefs = await _loadUserPreferences();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://a77c9d0abb052cdf70a3b630ce3f8896@o4509861345951744.ingest.us.sentry.io/4509861350539264';
      options.sendDefaultPii = true;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: MyApp(
          isArabic: userPrefs['isArabic'],
          hasSelectedLocation: userPrefs['hasSelectedLocation'],
          selectedArea: userPrefs['selectedArea'],
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isArabic;
  final bool hasSelectedLocation;
  final String selectedArea;
  const MyApp({
    super.key,
    required this.isArabic,
    required this.hasSelectedLocation,
    required this.selectedArea,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = Layoutcubit();
            cubit.isArabic = isArabic;
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = Restuarantscubit();
            cubit.initializeWithUserArea(selectedArea);
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = Favouritecubit();
            _initializeFavorites(cubit);
            return cubit;
          },
        ),
        BlocProvider(create: (context) => OrderCubit()),
        BlocProvider(create: (context) => Logincubit()),
        BlocProvider(create: (context) => Signupcubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => AdminPanelCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, child) {
          var cubit = Layoutcubit.get(context);

          return BlocBuilder<Layoutcubit, Layoutstates>(
            builder: (context, state) {
              return MaterialApp(
                locale: Layoutcubit.get(context).isArabic ? const Locale('ar') : const Locale('en'),
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                debugShowCheckedModeBanner: false,
                title: 'Food App',
                theme: cubit.isdark,
                navigatorKey: navigatorKey,
                home: const SplashScreen(),
                routes: {'/login': (context) => const Loginscreen()},
                builder: (context, child) {
                  FirebaseMessagingService.setContext(context);
                  return child ?? const SizedBox();
                },
              );
            },
          );
        },
      ),
    );
  }

  void _initializeFavorites(Favouritecubit cubit) {
    cubit.initializeFavoriteIds().then((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          final currentContext = navigatorKey.currentContext;
          if (currentContext != null) {
            try {
              final restaurantCubit = Restuarantscubit.get(currentContext);
              // Check if restaurant data is available before loading favorites
            } catch (e) {
              // Handle error silently
            }
          }
          cubit.loadFavourites().catchError((error) {
            // Handle error silently
          });
        });
      }
    }).catchError((error) {
      // Handle error silently
    });
  }
}
