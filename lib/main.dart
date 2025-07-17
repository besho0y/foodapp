import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  print('🔔 === APP STARTUP ===');
  print('🔔 Build Mode: ${kDebugMode ? 'DEBUG' : 'RELEASE'}');

  // Initialize Firebase with error handling
  try {
    print('🔔 Initializing Firebase...');
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    rethrow;
  }

  // TEMPORARY: Clear cart storage to fix the two items issue
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('cart_items');
  print('Cleared cart storage on app startup');

  // Initialize Firebase Messaging Service
  try {
    print('🔔 Initializing Firebase Messaging...');
    await FirebaseMessagingService.initialize();
    print('✅ Firebase Messaging initialized');
  } catch (e) {
    print('❌ Error initializing Firebase Messaging: $e');
    // Don't rethrow - continue app startup
  }

  // Initialize Admin Notification Service
  try {
    print('🔔 Initializing Admin Notification Service...');
    await AdminNotificationService.initialize();
    print('✅ Admin Notification Service initialized');
  } catch (e) {
    print('❌ Error initializing Admin Notification Service: $e');
    // Don't rethrow - continue app startup
  }

  // Initialize PayMob Service
  try {
    print('🔔 Initializing PayMob Service...');
    PayMobService.initialize();
    print('✅ PayMob Service initialized');
  } catch (e) {
    print('❌ Error initializing PayMob Service: $e');
    // Don't rethrow - continue app startup
  }

  // Initialize Bloc Observer
  Bloc.observer = MyBlocObserver();

  // Load saved language preference
  bool isArabic = prefs.getBool('isArabic') ?? false;

  // Check if user has selected location
  bool hasSelectedLocation = prefs.getBool('hasSelectedLocation') ?? false;
  String selectedArea = prefs.getString('selectedArea') ?? 'Cairo';

  print('🔔 Starting app with language: ${isArabic ? 'Arabic' : 'English'}');
  print('🔔 Selected area: $selectedArea');

  runApp(
    MyApp(
      isArabic: isArabic,
      hasSelectedLocation: hasSelectedLocation,
      selectedArea: selectedArea,
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
            // Initialize with user's selected area
            cubit.initializeWithUserArea(selectedArea);
            // Initialization is handled in constructor
            print("✅ Creating restaurant cubit instance...");
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = Favouritecubit();
            print('🔄 === EARLY FAVORITES INITIALIZATION ===');

            // Initialize favorite IDs first
            cubit.initializeFavoriteIds().then((_) {
              print('✅ Favorite IDs initialized on app start');

              // Only load favorites if user is logged in
              if (FirebaseAuth.instance.currentUser != null) {
                print('👤 User is logged in, scheduling favorites loading...');

                // Delay favorites loading to let restaurant data load first
                Future.delayed(const Duration(milliseconds: 1000), () {
                  print('🔄 Loading favorites after restaurant data...');

                  // Check if restaurant data is available before loading favorites
                  final currentContext = navigatorKey.currentContext;
                  if (currentContext != null) {
                    try {
                      final restaurantCubit =
                          Restuarantscubit.get(currentContext);
                      print(
                          '📊 Restaurant cubit has ${restaurantCubit.restaurants.length} restaurants available');

                      if (restaurantCubit.restaurants.isNotEmpty) {
                        print(
                            '✅ Restaurant data available, loading favorites...');
                      } else {
                        print(
                            '⚠️ Restaurant data not ready yet, favorites will use Firebase fallback');
                      }
                    } catch (e) {
                      print('⚠️ Could not access restaurant cubit: $e');
                    }
                  }

                  cubit.loadFavourites().catchError((error) {
                    print(
                        "❌ Error loading favorites during delayed startup: $error");
                  });
                });
              } else {
                print('❌ No user logged in, skipping favorites loading');
              }
            }).catchError((error) {
              print("❌ Error initializing favorites on app start: $error");
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
                routes: {'/login': (context) => const Loginscreen()},
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
