import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/login_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginController>(
        init: LoginController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppColors.background
                : AppColors.darkBackground,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/login_image.png",
                      width: Responsive.width(100, context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text("Login".tr,
                              style: GoogleFonts.poppins(
                                  color: themeChange.getThem()
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                              "Welcome Back! We are happy to have \n you back"
                                  .tr,
                              style: GoogleFonts.poppins(
                                  color: themeChange.getThem()
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w400)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            validator: (value) =>
                                value != null && value.isNotEmpty
                                    ? null
                                    : 'Required',
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            controller: controller.phoneNumberController.value,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                              color: themeChange.getThem()
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: themeChange.getThem()
                                    ? AppColors.textField
                                    : AppColors.darkTextField,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                prefixIcon: CountryCodePicker(
                                  textStyle: TextStyle(
                                      color: themeChange.getThem()
                                          ? Colors.black
                                          : Colors.white),
                                  onChanged: (value) {
                                    controller.countryCode.value =
                                        value.dialCode.toString();
                                  },
                                  dialogBackgroundColor: themeChange.getThem()
                                      ? AppColors.darkBackground
                                      : AppColors.background,
                                  initialSelection:
                                      controller.countryCode.value,
                                  comparator: (a, b) =>
                                      b.name!.compareTo(a.name.toString()),
                                  flagDecoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2)),
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                hintText: "Phone number".tr)),
                        const SizedBox(
                          height: 30,
                        ),
                        ButtonThem.buildButton(
                          context,
                          title: "Next".tr,
                          onPress: () {
                            controller.sendCode();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: 'By tapping "Next" you agree to '.tr,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: themeChange.getThem()
                              ? Colors.black
                              : Colors.white),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(const TermsAndConditionScreen(
                              type: "terms",
                            ));
                          },
                        text: 'Terms and conditions'.tr,
                        style: GoogleFonts.poppins(
                            decoration: TextDecoration.underline,
                            decorationColor: themeChange.getThem()
                                ? Colors.black
                                : Colors.white),
                      ),
                      TextSpan(text: ' and ', style: GoogleFonts.poppins()),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(const TermsAndConditionScreen(
                              type: "privacy",
                            ));
                          },
                        text: 'privacy policy'.tr,
                        style: GoogleFonts.poppins(
                            decoration: TextDecoration.underline,
                            decorationColor: themeChange.getThem()
                                ? Colors.black
                                : Colors.white),
                      ),
                      // can add more TextSpans here...
                    ],
                  ),
                )),
          );
        });
  }
}
