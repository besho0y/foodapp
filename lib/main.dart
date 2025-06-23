import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:foodapp/shared/blocObserver.dart';
import 'package:foodapp/shared/firebase_messaging_service.dart';
import 'package:foodapp/shared/paymob_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/l10n.dart';
// Import the generated file

// Global navigator key for access across the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already done
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('🔔 === BACKGROUND MESSAGE RECEIVED ===');
  print('📱 Message ID: ${message.messageId}');
  print('📝 Title: ${message.notification?.title ?? 'No title'}');
  print('📝 Body: ${message.notification?.body ?? 'No body'}');
  print('📊 Data: ${message.data}');
  print('⏰ Sent time: ${message.sentTime}');
  print('🏷️ From: ${message.from}');
  print('📱 App in BACKGROUND - Message handled');
}

void main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding
      .ensureInitialized(); // <--- Important for locking orientation

  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Firebase messaging background handler AFTER Firebase is initialized
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Firebase messaging service with error handling
  try {
    await FirebaseMessagingService.initialize();
  } catch (e) {
    print('⚠️ Warning: Firebase Messaging initialization failed: $e');
    print('⚠️ App will continue without push notifications');
    // Don't prevent app from starting if messaging fails
  }

  // Initialize PayMob payment gateway with correct credentials
  PayMobService.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Only portrait modes
  ]);

  final prefs = await SharedPreferences.getInstance();
  final isArabic = prefs.getBool('isArabic') ?? false;
  final hasSelectedLocation = prefs.getBool('hasSelectedLocation') ?? false;
  final selectedArea = prefs.getString('selectedArea') ?? 'Cairo';

  runApp(MyApp(
      isArabic: isArabic,
      hasSelectedLocation: hasSelectedLocation,
      selectedArea: selectedArea));
}

class MyApp extends StatelessWidget {
  final bool isArabic;
  final bool hasSelectedLocation;
  final String selectedArea;
  const MyApp(
      {super.key,
      required this.isArabic,
      required this.hasSelectedLocation,
      required this.selectedArea});

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
            // Initialize with user's selected area
            cubit.initializeWithUserArea(selectedArea);
            // Initialization is handled in constructor
            print("Creating restaurant cubit instance...");
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = Favouritecubit();
            // Initialize favorite IDs first, then load favorites
            cubit.initializeFavoriteIds().then((_) {
              cubit.loadFavourites();
            });
            return cubit;
          },
        ),
        BlocProvider(create: (context) => (OrderCubit())),
        BlocProvider(create: (context) => (Logincubit())),
        BlocProvider(create: (context) => (Signupcubit())),
        BlocProvider(create: (context) => (ProfileCubit())),
        BlocProvider(create: (context) => (AdminPanelCubit())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (BuildContext context, child) {
          var cubit = Layoutcubit.get(context);

          return BlocBuilder<Layoutcubit, Layoutstates>(
            builder: (context, state) {
              return MaterialApp(
                locale: Layoutcubit.get(context).isArabic
                    ? const Locale('ar')
                    : const Locale('en'),
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                debugShowCheckedModeBanner: false,
                title: 'Food App',
                // You can use the library anywhere in the app even in theme
                theme: cubit.isdark,
                navigatorKey:
                    navigatorKey, // Add navigator key for global access
                home: const SplashScreen(),
                routes: {
                  '/login': (context) => const Loginscreen(),
                },
                builder: (context, child) {
                  // Set context for Firebase messaging service
                  FirebaseMessagingService.setContext(context);
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}
