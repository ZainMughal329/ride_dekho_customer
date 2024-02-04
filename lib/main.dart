import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/controller/global_setting_conroller.dart';
import 'package:customer/firebase_options.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/themes/Styles.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/auth_screen/login_screen.dart';
import 'package:customer/ui/auth_screen/otp_screen.dart';
import 'package:customer/ui/coupon_screen/coupon_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/ui/on_boarding_screen.dart';
import 'package:customer/ui/splash_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'utils/Preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyA0v84Ssf2f5vpTfi_Hu5AX_4Cpc-7Ljz4",
        appId: "1:516489839414:android:2ccd9cd0386c4ff8dc6997",
        messagingSenderId: '',
        projectId: 'ridedekho',
    ),
  );
  await FirebaseAppCheck.instance.activate(
  webProvider: ReCaptchaV3Provider('6LcMSWIpAAAAAETjeo-cR1Bptu-B231jc6OBvyo7'),
   androidProvider: AndroidProvider.playIntegrity,
       appleProvider: AppleProvider.appAttest,
  
  );
  await Preferences.initPref();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {

    themeChangeProvider.darkTheme=0;
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(builder: (context, value, child) {
        return GetMaterialApp(
            title: 'GoRide',
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
                themeChangeProvider.darkTheme == 1 ? true : false, context),
            localizationsDelegates: const [
              CountryLocalizations.delegate,
            ],
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            builder: EasyLoading.init(),
            home: GetBuilder<GlobalSettingController>(
                init: GlobalSettingController(),
                builder: (context) {
                  return const OnBoardingScreen();
                }));
      }),
    );
  }
}
