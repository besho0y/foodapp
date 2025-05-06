import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/firebase_options.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/screens/admin%20panel/cubit.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/login/cubit.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/signup/cubit.dart';
import 'package:foodapp/screens/signup/signupScreen.dart';
import 'package:foodapp/shared/blocObserver.dart';
import 'package:foodapp/shared/local_storage.dart';
// Import the generated file

void main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding
      .ensureInitialized(); // <--- Important for locking orientation
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Only portrait modes
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => Layoutcubit()),
        BlocProvider(
          create: (context) => (Restuarantscubit()..getRestuarants()),
        ),
        BlocProvider(create: (context) => (Favouritecubit())..loadFavourites()),
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
                debugShowCheckedModeBanner: false,
                title: 'Food App',
                // You can use the library anywhere in the app even in theme
                theme: cubit.isdark,
                navigatorKey:
                    navigatorKey, // Add navigator key for global access
                home:
                FutureBuilder<bool>(
                  future: LocalStorageService.isUserLoggedIn(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final isLoggedIn = snapshot.data ?? false;

                    if (isLoggedIn) {
                      // Load user data
                      ProfileCubit.get(context).getuserdata();
                      return Layout();
                    } else {
                      return Loginscreen();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
