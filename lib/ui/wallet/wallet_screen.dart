import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/wallet_controller.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/wallet_transaction_model.dart';
import 'package:customer/payment/createRazorPayOrderModel.dart';
import 'package:customer/payment/rozorpayConroller.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/ui/intercityOrders/intercity_complete_order_screen.dart';
import 'package:customer/ui/orders/complete_order_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});

  TextEditingController amount = TextEditingController();

  Future<void> jazzCashPayment(String amount, String mobileAccountNO) async {
    var digest;
    String dateandtime = DateFormat("yyyyMMddHHmmss").format(DateTime.now());
    String dexpiredate = DateFormat("yyyyMMddHHmmss")
        .format(DateTime.now().add(const Duration(days: 1)));
    String tre = "T" + dateandtime;
    String pp_Amount = amount;
    // price set
    String pp_BillReference = "billRef";
    String pp_Description = "Description for transaction";
    String pp_Language = "EN";
    String pp_MerchantID = "MC74150";
    String pp_Password = "zzyt20005w";
    String pp_ReturnURL = "https://google.com";
    String pp_ver = "1.1";
    String pp_TxnCurrency = "PKR";
    String pp_TxnDateTime = dateandtime.toString();
    String pp_TxnExpiryDateTime = dexpiredate.toString();
    String pp_TxnRefNo = tre.toString();
    String pp_TxnType = "MWALLET";
    String ppmpf_1 = "4456733833993";
    String IntegeritySalt = "ecfcwvd2zv";
    String and = '&';

    String superdata = IntegeritySalt +
        and +
        pp_Amount +
        and +
        pp_BillReference +
        and +
        pp_Description +
        and +
        pp_Language +
        and +
        pp_MerchantID +
        and +
        pp_Password +
        and +
        pp_ReturnURL +
        and +
        pp_TxnCurrency +
        and +
        pp_TxnDateTime +
        and +
        pp_TxnExpiryDateTime +
        and +
        pp_TxnRefNo +
        and +
        pp_TxnType +
        and +
        pp_ver +
        and +
        ppmpf_1;

    var key = utf8.encode(IntegeritySalt);
    var bytes = utf8.encode(superdata);
    var hmacSha256 = Hmac(sha256, key);
    Digest sha256Result = hmacSha256.convert(bytes);
    String url =
        'https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction';
    var response = await http.post(Uri.parse(url), body: {
      "pp_Version": pp_ver,
      "pp_TxnType": pp_TxnType,
      "pp_Language": pp_Language,
      "pp_MerchantID": pp_MerchantID,
      "pp_Password": pp_Password,
      "pp_TxnRefNo": tre,
      "pp_Amount": pp_Amount,
      "pp_TxnCurrency": pp_TxnCurrency,
      "pp_TxnDateTime": dateandtime,
      "pp_BillReference": pp_BillReference,
      "pp_Description": pp_Description,
      "pp_TxnExpiryDateTime": dexpiredate,
      "pp_ReturnURL": pp_ReturnURL,
      "pp_SecureHash": sha256Result.toString(),
      "ppmpf_1": mobileAccountNO
    });

    print("response=>");
    print(response.body);
    var res = await response.body;
    var body = jsonDecode(res);
    var responcePrice = body['pp_Amount'];
    print(responcePrice);
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<WalletController>(
        init: WalletController(),
        builder: (controller) {
          print(controller.userModel.value.walletAmount.toString());
          return Scaffold(
            // backgroundColor: Colors.green,
            body: Column(
              children: [
                Container(
                  height: Responsive.width(28, context),
                  width: Responsive.width(100, context),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Balance".tr,
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Text(
                                    Constant.amountShow(amount: "PKR:"),
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24),
                                  ),
                                  Text(
                                    Constant.amountShow(
                                      amount: controller
                                          .userModel.value.walletAmount
                                          .toString(),
                                    ),
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -22),
                          child: ButtonThem.roundButton(
                            context,
                            title: "Topup Wallet".tr,
                            btnColor: Colors.green,
                            txtColor: Colors.white,
                            btnWidthRatio: 0.40,
                            btnHeight: 40,
                            onPress: () async {
                              paymentMethodDialog(context, controller);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -22),
                    child: Container(
                      decoration: BoxDecoration(
                          color: themeChange.getThem()
                              ? AppColors.background
                              : AppColors.background,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: controller.transactionList.isEmpty
                            ? StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection(
                                        CollectionName.walletTransaction)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: Text(
                                      "No transaction found".tr,
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? Colors.black
                                            : Colors.black,
                                      ),
                                    ));
                                  } else {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot snap =
                                              snapshot.data!.docs[index];

                                          var date = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  snap['createdDate']
                                                      .millisecondsSinceEpoch);

                                          return Expanded(
                                            child: Container(
                                              width: Get.width * 0.4,
                                              margin: EdgeInsets.only(
                                                  top: Get.height * 0.03),
                                              decoration: BoxDecoration(
                                                  color: themeChange.getThem()
                                                      ? AppColors.background
                                                      : AppColors.background,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 0.8,
                                                      spreadRadius: 0.4,
                                                    )
                                                  ]),
                                              child: ListTile(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                title: Text(snap['amount']),
                                                trailing:
                                                    Text(snap['paymentType']),
                                                subtitle: Text(
                                                    "Dated: ${date.day}-${date.month}-${date.year}"),
                                                // tileColor: themeChange.getThem()
                                                //     ? Colors.grey
                                                //     : Colors.black,
                                                textColor: themeChange.getThem()
                                                    ? Colors.black
                                                    : Colors.black,
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                })
                            : ListView.builder(
                                itemCount: controller.transactionList.length,
                                itemBuilder: (context, index) {
                                  WalletTransactionModel
                                      walletTransactionModel =
                                      controller.transactionList[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () async {
                                        if (walletTransactionModel.orderType ==
                                            "city") {
                                          await FireStoreUtils.getOrder(
                                                  walletTransactionModel
                                                      .transactionId
                                                      .toString())
                                              .then((value) {
                                            if (value != null) {
                                              OrderModel orderModel = value;
                                              Get.to(
                                                  const CompleteOrderScreen(),
                                                  arguments: {
                                                    "orderModel": orderModel,
                                                  });
                                            }
                                          });
                                        } else if (walletTransactionModel
                                                .orderType ==
                                            "intercity") {
                                          await FireStoreUtils
                                                  .getInterCityOrder(
                                                      walletTransactionModel
                                                          .transactionId
                                                          .toString())
                                              .then((value) {
                                            if (value != null) {
                                              InterCityOrderModel orderModel =
                                                  value;
                                              Get.to(
                                                  const IntercityCompleteOrderScreen(),
                                                  arguments: {
                                                    "orderModel": orderModel,
                                                  });
                                            }
                                          });
                                        } else {
                                          showTransactionDetails(
                                              context: context,
                                              walletTransactionModel:
                                                  walletTransactionModel);
                                        }
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: themeChange.getThem()
                                                ? AppColors
                                                    .darkContainerBackground
                                                : AppColors
                                                .darkContainerBackground,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: themeChange.getThem()
                                                    ? AppColors
                                                        .darkContainerBorder
                                                    : AppColors
                                                    .darkContainerBorder,
                                                width: 0.5),
                                            boxShadow: themeChange.getThem()
                                                ? null
                                                : null,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            AppColors.lightGray,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: SvgPicture.asset(
                                                        'assets/icons/ic_wallet.svg',
                                                        width: 24,
                                                        color: Colors.black,
                                                      ),
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              Constant.dateFormatTimestamp(
                                                                  walletTransactionModel
                                                                      .createdDate),
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                          Text(
                                                            "${Constant.IsNegative(double.parse(walletTransactionModel.amount.toString())) ? "(-" : "+"}${Constant.amountShow(amount: walletTransactionModel.amount.toString().replaceAll("-", ""))}${Constant.IsNegative(double.parse(walletTransactionModel.amount.toString())) ? ")" : ""}",
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Constant.IsNegative(double.parse(
                                                                        walletTransactionModel
                                                                            .amount
                                                                            .toString()))
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              walletTransactionModel
                                                                  .note
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          Text(walletTransactionModel
                                                              .paymentType
                                                              .toString()
                                                              .toUpperCase())
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  paymentMethodDialog(BuildContext context, WalletController controller) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  controller.amountController.value.clear();
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: themeChange.getThem()
                                      ? Colors.black
                                      : Colors.black,
                                )),
                            Expanded(
                                child: Center(
                                    child: Text(
                              "Topup Wallet".tr,
                              style: GoogleFonts.poppins(
                                color: themeChange.getThem()
                                    ? Colors.black
                                    : Colors.black,
                              ),
                            ))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Topup Amount".tr,
                                  style: GoogleFonts.poppins(
                                      color: themeChange.getThem()
                                          ? Colors.black
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFieldThem.buildTextFiled(context,
                                    hintText: 'Enter Amount'.tr,
                                    controller:
                                        controller.amountController.value,
                                    keyBoardType: TextInputType.number),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Select Payment Option".tr,
                                  style: GoogleFonts.poppins(
                                      color: themeChange.getThem()
                                          ? Colors.black
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value
                                          .jazzCash!.enable ==
                                      true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        30),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        30))),
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    height: Get.height * 0.3,
                                                    width: Get.width,
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                              Get.height * 0.05,
                                                        ),
                                                        Text(
                                                          "Enter Mobile Account No: "
                                                              .tr,
                                                          style: GoogleFonts.poppins(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? Colors.black
                                                                  : Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              Get.height * 0.01,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              Get.width * 0.8,
                                                          child: TextFieldThem.buildTextFiled(
                                                              context,
                                                              hintText:
                                                                  'Enter Mobile Account'
                                                                      .tr,
                                                              controller: controller
                                                                  .mobileAccountController
                                                                  .value,
                                                              keyBoardType:
                                                                  TextInputType
                                                                      .number),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              Get.height * 0.01,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              Get.width * 0.6,
                                                          child: ButtonThem
                                                              .buildButton(
                                                                  context,
                                                                  title: 'Done',
                                                                  onPress: () {
                                                            Get.back();
                                                          }),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                });
                                            controller.selectedPaymentMethod
                                                    .value =
                                                controller.paymentModel.value
                                                    .jazzCash!.name
                                                    .toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller
                                                              .selectedPaymentMethod
                                                              .value ==
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .jazzCash!
                                                              .name
                                                              .toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.primary
                                                          : AppColors.primary
                                                      : AppColors.primary,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppColors
                                                                .lightGray
                                                            : AppColors
                                                            .lightGray,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.asset(
                                                        'assets/images/jazz-cash-logo.png',
                                                      ),

                                                      // SvgPicture.asset(
                                                      //     'assets/icons/ic_wallet.svg',
                                                      //     color: themeChange
                                                      //             .getThem()
                                                      //         ? AppColors.primary
                                                      //         : AppColors
                                                      //             .darkModePrimary),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel
                                                          .value.jazzCash!.name
                                                          .toString(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: themeChange
                                                                .getThem()
                                                            ? Colors.black
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller
                                                        .paymentModel
                                                        .value
                                                        .jazzCash!
                                                        .name
                                                        .toString(),
                                                    groupValue: controller
                                                        .selectedPaymentMethod
                                                        .value,
                                                    activeColor: themeChange
                                                            .getThem()
                                                        ? AppColors.primary
                                                        : AppColors.primary,
                                                    onChanged: (value) {
                                                      print('radio');
                                                      controller
                                                              .selectedPaymentMethod
                                                              .value =
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .jazzCash!
                                                              .name
                                                              .toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(context, title: "Topup".tr,
                          onPress: () {
                        if (controller.amountController.value.text.isNotEmpty) {
                          Get.back();
                          if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.jazzCash!.name) {
                            print('ad');
                            jazzCashPayment(
                              controller.amountController.value.text.toString(),
                              controller.mobileAccountController.value.text
                                  .toString(),
                            );

                            WalletTransactionModel transaction =
                                WalletTransactionModel();
                            transaction.amount = controller
                                .amountController.value.text
                                .toString();
                            transaction.id =
                                FirebaseAuth.instance.currentUser!.uid;
                            transaction.userId =
                                FirebaseAuth.instance.currentUser!.uid;
                            transaction.paymentType =
                                controller.paymentModel.value.jazzCash!.name;
                            transaction.orderType = "";
                            transaction.userType = 'Customer';
                            transaction.createdDate = Timestamp.now();
                            transaction.note = "Topup Wallet";
                            transaction.transactionId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            FireStoreUtils.setWalletTransaction(transaction);

                            controller.amountController.value.clear();
                            controller.mobileAccountController.value.clear();
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.paypal!.name) {
                            // controller.paypalPaymentSheet(
                            //     controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.payStack!.name) {
                            // controller.payStackPayment(
                            //     controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.mercadoPago!.name) {
                            // controller.mercadoPagoMakePayment(
                            //     context: context,
                            //     amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.flutterWave!.name) {
                            // controller.flutterWaveInitiatePayment(
                            //     context: context,
                            //     amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.payfast!.name) {
                            // controller.payFastPayment(
                            //     context: context,
                            //     amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.paytm!.name) {
                            // controller.getPaytmCheckSum(context, amount: double.parse(controller.amountController.value.text));
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.razorpay!.name) {
                            // RazorPayController()
                            //     .createOrderRazorPay(
                            //         amount: int.parse(
                            //             controller.amountController.value.text),
                            //         razorpayModel:
                            //             controller.paymentModel.value.razorpay)
                            //   .then((value) {
                            // if (value == null) {
                            //   Get.back();
                            //   ShowToastDialog.showToast(
                            //       "Something went wrong, please contact admin."
                            //           .tr);
                            // } else {
                            //   // CreateRazorPayOrderModel result = value;
                            // controller.openCheckout(
                            //     amount:
                            //         controller.amountController.value.text,
                            //     orderId: result.id);
                            // }
                            // });
                          } else {
                            ShowToastDialog.showToast(
                                "Please select payment method".tr);
                          }
                        } else {
                          ShowToastDialog.showToast("Please enter amount".tr);
                        }
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  showTransactionDetails(
      {required BuildContext context,
      required WalletTransactionModel walletTransactionModel}) {
    return showModalBottomSheet(
        elevation: 5,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            final themeChange = Provider.of<DarkThemeProvider>(context);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Transaction Details".tr,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppColors.darkContainerBackground
                            :  AppColors.darkContainerBackground,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: themeChange.getThem()
                                ? AppColors.darkContainerBorder
                                : AppColors.darkContainerBorder,
                            width: 0.5),
                        boxShadow: themeChange.getThem()
                            ? null
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaction ID".tr,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "#${walletTransactionModel.transactionId!.toUpperCase()}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppColors.darkContainerBackground
                            : AppColors.darkContainerBackground,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: themeChange.getThem()
                                ? AppColors.darkContainerBorder
                                :  AppColors.darkContainerBorder,
                            width: 0.5),
                        boxShadow: themeChange.getThem()
                            ? null
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment Details".tr,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            "Pay Via".tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          " ${walletTransactionModel.paymentType}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date in UTC Format".tr,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          DateFormat('KK:mm:ss a, dd MMM yyyy')
                                              .format(walletTransactionModel
                                                  .createdDate!
                                                  .toDate())
                                              .toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
