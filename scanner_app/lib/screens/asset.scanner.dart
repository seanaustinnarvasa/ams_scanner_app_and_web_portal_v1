import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/components/toast.dart';
import 'package:nustar_turnstile_scanner/data/enum/comp_status.dart';
import 'package:nustar_turnstile_scanner/data/models/comps.dart';
import 'package:nustar_turnstile_scanner/data/models/points.dart';
import 'package:nustar_turnstile_scanner/data/models/redemption.dart';
import 'package:nustar_turnstile_scanner/screens/printing.screen.dart';
import 'package:nustar_turnstile_scanner/screens/qr.scanner.screen.dart';
import 'package:nustar_turnstile_scanner/services/database.service.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AssetScannerScreen extends StatefulWidget {
  static String routeName = App.compRedemptionScreen;
  final String? headerTitle;

  const AssetScannerScreen({Key? key, this.headerTitle}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CompRedemptionScreenState createState() => _CompRedemptionScreenState();
}

class _CompRedemptionScreenState extends State<AssetScannerScreen> {
  final TextEditingController amountField = TextEditingController();
  final TextEditingController compNumberField = TextEditingController();
  final TextEditingController membershipIdField = TextEditingController();
  final TextEditingController pinField = TextEditingController();
  final TextEditingController amountToRedeemedField = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _compVouchers = [""];

  QRViewController? qrCodeController;
  String activeButtonName = App.confirm;
  String membershipIdValue = App.na;
  String voucherValue = App.e;
  String? _selectedRedemptionNumber;
  String? _currentSelectedVoucher;
  String? cardValue;
  String? qrCodeResultValue;
  String? getUID;
  String? getDocID;
  String? cardSwipeItemNumberCompID;
  String dropdownHintText = App.selectVoucher;
  String assetTagId = App.na;
  String assetTagName = App.na;
  String assetGroup = App.na;
  String assetVendor = App.na;
  String assetSerialNumber = App.na;
  String assetInvoiceNumber = App.na;
  String assetAssigneeOwner = App.na;
  String assetAssigneeDepartment = App.na;
  dynamic assetCost = 0;
  String assetCreatedDate = App.na;
  bool userScannedQR = false;
  bool isDirectionButtonDisabled = false;
  bool cardSwipe = false;
  bool isNotBdayTreatComp = false;
  bool isIdle = App.idleMode ? true : false;
  bool idleValidationSuccess = false;
  dynamic igtComps;
  dynamic compsRvcNotAvailable;
  dynamic amountExceededAvailableRVC;
  dynamic cardSwipeUID;
  dynamic cardSwipeDocID;
  dynamic tenantExcludedBirthdayTreatOffer;
  dynamic igtCompIdBirthdayComp;

  bool? selectVoucherActiveField;
  bool? compNumberActiveField;
  bool qrScanned = false;

  @override
  void initState() {
    _getDefaultData(context);
    super.initState();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrCodeController!.pauseCamera();
    } else if (Platform.isIOS) {
      qrCodeController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          _clear();
          Routes.goBack(context);
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: CustomColors.darkThemeColor,
          body: bodyWidget(context),
        ),
      ),
    );
  }

  Widget bodyWidget(BuildContext context) {
    return !userScannedQR ? 
      _buildResultAssetDetails() :
      _buildQRScanner();
  }

  Widget _buildResultAssetDetails() {
    return Scaffold(
      backgroundColor: const Color(0xFF210007),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => {
            setState(() {
              App.goingMode = null;
              isDirectionButtonDisabled = false;
              userScannedQR = true;
            })
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFFbe984b)),
        ),
        title: const Text(
          'Asset Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: App.montserrat,
            color: Color(0xFFbe984b),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDetailsContainer(context),
              const SizedBox(height: 16),
              _buildScanAgainButton(context),
              const SizedBox(height: 16),
              _buildInfoCards(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanAgainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            App.goingMode = null;
            isDirectionButtonDisabled = false;
            userScannedQR = true;
          });
          // Routes.goBack(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFcb9f48),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Scan Again',
          style: TextStyle(
            color: Color(0xFF320100),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: App.fontSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildQRScanner() {
    return Stack(
      children: <Widget>[
        QRView(
          key: qrKey,
          onQRViewCreated: viewQrCode,
        ),
        Positioned.fill(
          child: Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: const Color(0xFFddc580),
                borderWidth: 12,
                borderRadius: 10,
                borderLength: 20,
                cutOutSize: 30.h,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: const Color(0xFF531022),
            elevation: 0,
            // leading: IconButton(
            //   onPressed: () {
            //     qrCodeController?.pauseCamera();
            //     Routes.goBack(context);
            //   },
            //   icon: const Icon(
            //     Icons.arrow_back_ios,
            //     color: Color(0xFFbe984b),
            //   ),
            // ),
            leading: const SizedBox.shrink(),
            title: const Text(
              'Asset QR Scanner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: App.montserrat,
                color: Color(0xFFbe984b),
              ),
            ),
            centerTitle: true,
          ),
        ),
        _buildCaptionText(),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildCaptionText() {
    final scannerTop = (100.h - 25.h) / 2;
    final scannerBottom = scannerTop + 25.h;

    return Positioned(
      top: scannerBottom + 16,
      left: 0,
      right: 0,
      height: 80,
      child: const Center(
        child: Text(
          'Align Asset QR Code inside\n the frame',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              fontFamily: App.montserrat,
              color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        borderColor: const Color(0xFF00D9FF),
        borderLength: 40,
        borderWidth: 4,
        cornerRadius: 16,
        scanAreaSize: 280,
      ),
      child: SizedBox(
        width: 100.w,
        height: 100.h,
      ),
    );
  }

  Widget _buildScanIndicator() {
    return Positioned(
      top: 35.h,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final scannerTop = (100.h - 48.h) / 2;
    final scannerBottom = scannerTop + 48.h;

    return Positioned(
      top: scannerBottom + 16,
      left: 0,
      right: 0,
      height: 80,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 130,
              child: ElevatedButton.icon(
                onPressed: isDirectionButtonDisabled
                    ? null
                    : () => _handleDirectionButtonPressed('GOING IN'),
                icon: Icon(
                  Icons.login,
                  color: isDirectionButtonDisabled
                      ? Colors.white54
                      : const Color(0xFFbe984b),
                ),
                label: Text(
                  'GOING IN',
                  style: TextStyle(
                    color: isDirectionButtonDisabled
                        ? Colors.white54
                        : const Color(0xFFbe984b),
                    // fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: App.montserrat,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDirectionButtonDisabled
                      ? Colors.grey
                      : const Color(0xFF540c21),
                  foregroundColor:
                      isDirectionButtonDisabled ? Colors.white54 : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 130,
              child: ElevatedButton.icon(
                onPressed: isDirectionButtonDisabled
                    ? null
                    : () => _handleDirectionButtonPressed('GOING OUT'),
                icon: Icon(
                  Icons.logout,
                  color: isDirectionButtonDisabled
                      ? Colors.white54
                      : const Color(0xFF540c21),
                ),
                label: Text(
                  'GOING OUT',
                  style: TextStyle(
                    color: isDirectionButtonDisabled
                        ? Colors.white54
                        : const Color(0xFF540c21),
                    // fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: App.montserrat,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDirectionButtonDisabled
                      ? Colors.grey
                      : const Color(0xFFbe984b),
                  foregroundColor:
                      isDirectionButtonDisabled ? Colors.white54 : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDirectionButtonPressed(String direction) {
    if (!mounted || isDirectionButtonDisabled) return;

    final checkStatus = direction.contains(App.out) ? App.out : App.inn;

    setState(() {
      isDirectionButtonDisabled = true;
      // ignore: unrelated_type_equality_checks
      App.goingMode = checkStatus;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('YOU SELECT GOING $checkStatus'),
        backgroundColor: const Color(0xFF210007),
      ),
    );
  }

  void _resetScanner() async {
    if (!mounted) return;
    // setState(() {
    //   _hasScanned = false;
    //   _isScanning = true;
    // });
    await qrCodeController?.resumeCamera();
  }

  void _switchCamera() async {
    await qrCodeController?.flipCamera();
  }

  Future<void> requestCompRedemption(
      {Map<String, dynamic>? data,
      String? requestName,
      String? pinValue,
      String? membershipID}) async {
    var url = Uri.parse((requestName == App.pinValidation)
        ? App.validatePinURI
        : (requestName == App.compList)
            ? App.compListURI
            : (requestName == App.compInquiry)
                ? App.compInquiryURI
                : (requestName == App.compRedeeem)
                    ? App.compRedeemURI
                    : App.getPlayerIdURI);

    App.headers = {
      App.authKey: App.k3y ?? App.na,
      App.contentType: App.appJsonUTF8
    };

    var response = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );

    // ignore: use_build_context_synchronously
    final token = await App.getTokenKey(context);

    final List<Points> getPoints = [Points.fromJson(jsonDecode(response.body))];

    dynamic playerId;

    String? errorMessage;
    String? membershipId;
    String? cardTier;
    String? cardHolderName;

    bool? errorStatus;
    bool? pinCorrect;

    var p = getPoints[0];

    errorMessage = p.errorMessage ?? App.undefinedError;
    errorStatus = p.errorStatus ?? false;
    pinCorrect = p.pinCorrect ?? false;
    playerId = p.playerId;
    cardTier = p.cardTier;
    membershipId = p.membershipId ?? App.na;
    cardHolderName = "${p.firstName ?? App.na} ${p.lastName ?? App.na}";

    // ignore: use_build_context_synchronously
    App.checkIGTerror(context: context, errorMessage: errorMessage);

    DatabaseService.insertLogs(
      id: "${App.generateDateTimeSeconds()}${App.requestKey}",
      tenantId: App.memberCurrentTenantID.toString(),
      membershipId: membershipID ?? App.na,
      deviceId: App.memberCurrentDeviceID ?? App.na,
      jsonRequest: json.encode(data),
      jsonResponse: jsonDecode(response.body).toString(),
      endpoint: url.toString(),
      appVersion: App.versionNumber,
      username: App.memberCurrentUsername,
      hasError: errorStatus
    );

    if (errorMessage.contains(App.connectionAttemptFailed) ||
        errorMessage.contains(App.tn) ||
        errorMessage.contains('dbo') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains(
            'The ConnectionString property has not been initialized') ||
        errorMessage.contains('db') ||
        errorMessage.contains('dbo.') ||
        errorMessage.contains('ConnectionString') ||
        errorMessage.contains('not been initialized')) {
      _genericAlertMessage();
      return;
    }

    if (errorStatus) {
      Loader.stop();
      // ignore: use_build_context_synchronously
      QuickAlert.show(
          onConfirmBtnTap: () {
            Routes.goBack();
            clearSwipeAndEnableMagstripe(context);
          },
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: errorMessage == "Comp cannot be claimed in this merchant"
              ? "Invalid Comp #.\nPlease check and try again."
              : errorMessage
          // text: errorMessage == "Comp cannot be claimed in this merchant" ? "Comp cannot be redeemed at this merchant." : errorMessage
          );
      return;
    }

    if (response.statusCode == 200) {
      if (errorMessage == App.invalidPIN ||
          errorMessage == App.invalidInvoiceNumber) {
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text:
              "Message: $errorMessage\nMerchant Name: ${App.memberCurrentTenantName}\n${App.voucher}: $_currentSelectedVoucher",
        );
        Loader.stop();
        return;
      }

      if (errorStatus &&
          requestName != App.compList &&
          requestName != App.compRedeeem) {
        // ignore: use_build_context_synchronously
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            barrierDismissible: true,
            confirmBtnText: App.ok,
            title: App.e,
            text: errorMessage,
            onConfirmBtnTap: () => clearAmount());
        Loader.stop();
        return;
      }

      setState(() {
        if (requestName == App.pinValidation) {
          if (pinCorrect ?? false) {
            pinField.text = App.e;
            Map<String, dynamic>? catalogRedeemData = {
              App.voucherIdKey: App.compRedemptionNumberValue
            };

            if (cardSwipe) {
              validateQrCodeOrCardSwipe(
                  playerId: App.memberCurrentPlayerID.toString(),
                  catalogRedeemData: catalogRedeemData,
                  voucherId: App.compRedemptionNumberValue,
                  inputAmount: isNotBdayTreatComp ? 0 : App.amountValue,
                  uid: isNotBdayTreatComp ? null : cardSwipeUID,
                  docId: isNotBdayTreatComp ? null : cardSwipeDocID);
            }

            Loader.stop();
            return;
          }

          App.validateSuccess = false;
        } else if (requestName == App.getPlayerID) {
          cardSwipe = true;

          App.memberCurrentPlayerID = playerId ?? App.e;
          App.cardTierValue = cardTier ?? App.na;
          App.cardHolderName = cardHolderName;

          membershipIdValue = playerId ?? membershipIdField.text;

          Map<String, dynamic>? data = {
            App.playerIdKey: App.memberCurrentPlayerID,
            App.tenantIdKey: App.memberCurrentTenantID.toString()
          };

          requestCompRedemption(data: data, requestName: App.compList);

          return;
        } else if (requestName == App.compList) {
          final List<Redemption> redemp = [
            Redemption.fromJson(jsonDecode(response.body))
          ];

          var r = redemp[0];

          errorMessage = r.errorMessage ?? App.undefinedError;
          errorStatus = r.errorStatus ?? false;

          _compVouchers.clear();

          Loader.stop();

          r.vouchers?.forEach((v) {
            var description = v['description'];
            var compID = v['redemptionNumber']; //['compID'];
            var rvc = v['rvc'];
            var itemNumber = v['itemNumber'];

            _compVouchers.addAll(["$description - ($compID)"]);

            _selectedRedemptionNumber = compID.toString();

            if (!cardSwipe) {
              App.compRedemptionNumberValue = _selectedRedemptionNumber;
            }

            App.redeemedDescriptionValue = description;

            App.rvcValue = rvc.toString();

            cardSwipeItemNumberCompID = itemNumber.toString();

            /// --- Validate if Tenant ID are excluded When Redeeming Birthday Treat Offer --- ///
            if (cardSwipeItemNumberCompID != null) {
              if (igtCompIdBirthdayComp[0] ==
                  int.parse(cardSwipeItemNumberCompID!)) {
                if (tenantExcludedBirthdayTreatOffer[0].toString() ==
                    App.memberCurrentTenantID.toString()) {
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      barrierDismissible: true,
                      confirmBtnText: App.ok,
                      title: App.e,
                      text: App.compAvailableRewardsCounter);
                  return;
                }
              }
            }

            activeButtonName = App.compsToRedeem;
          });
        } else if (requestName == App.compRedeeem) {
          final List<Redemption> redemp = [
            Redemption.fromJson(jsonDecode(response.body))
          ];

          var r = redemp[0];

          errorMessage = r.errorMessage ?? App.undefinedError;
          errorStatus = r.errorStatus ?? false;

          App.memberCurrentPlayerID = "${r.playerId ?? 0}";

          if (!cardSwipe) {
            App.compRedemptionNumberValue = "${r.voucherId ?? 0}";
          }

          // App.amountValue = points;
          if (errorStatus == true) {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                barrierDismissible: true,
                confirmBtnText: App.ok,
                title: App.e,
                text: errorMessage,
                onConfirmBtnTap: () => clearAmount());
            Loader.stop();
            return;
          }

          Loader.stop();

          activeButtonName = App.print;

          App.validateSuccess = true;

          DatabaseService.updateRewardsShopCartItem(
              uid: getUID ?? App.na, docId: getDocID ?? App.na);

          // DatabaseService.removeCartItems(
          //   uid: getUID ?? App.na,
          //   docId: getDocID ?? App.na
          // );

          DatabaseService.insertRedeemedItems(
              uid: getUID ?? App.na,
              docId: getDocID ?? App.na,
              itemState: App.redeemed);

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            barrierDismissible: false,
            confirmBtnText: App.ok,
            title: App.e,
            text: App.successfullyRedeeemed,
            onConfirmBtnTap: () async {
              _clear();
              Routes.navigateToScreen(
                  PrintingScreen(headerTitle: widget.headerTitle));
            },
          );
        } else {
          App.memberCurrentMembershipID = membershipId ?? App.na;
          App.validateSuccess = true;

          activeButtonName = App.print;

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            barrierDismissible: false,
            confirmBtnText: App.ok,
            title: App.e,
            text: App.successfullyRedeeemed,
            onConfirmBtnTap: () async {
              _clear();
              Routes.navigateToScreen(
                  PrintingScreen(headerTitle: widget.headerTitle));
            },
          );

          Loader.stop();
          return;
        }
      });
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      Loader.stop();

      // ignore: use_build_context_synchronously
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.failedAPIrequest);
    } else {
      if (App.k3y != null) {
        setState(() {
          App.k3y = token;
          activeButtonName = App.compsToRedeem;
        });
      } else {
        // ignore: use_build_context_synchronously
        Loader.show(context, 0);
      }

      Loader.stop();
    }
    // Loader.stop();
  }

  pinValidation({required Map<String, dynamic> param}) async {
    await requestCompRedemption(data: param, requestName: App.pinValidation);
  }

  _clear() async {
    qrCodeController?.dispose();
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      child: const Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: <Widget>[
          SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: CustomColors.darkWhite,
                thickness: 1,
              ),
            ),
          ),
          Text(App.or,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: App.fontSecondary,
                  fontWeight: FontWeight.w400)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: CustomColors.darkWhite,
                thickness: 1,
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  viewQrCode(QRViewController controller) {
    setState(() => qrCodeController = controller);

    _getDefaultData(context);

    controller.scannedDataStream.listen((scanData) async {
      String? qrCode = scanData.code;

      if (App.goingMode == null) {
        // ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select GOING OUT or GOING IN to continue.'),
            backgroundColor: Color(0xFF390b16),
          ),
        );
        return;
      }

      // ignore: use_build_context_synchronously
      Loader.show(context, 0);

      if (qrCode != null) {
        qrCodeController?.pauseCamera();

        // qrCodeController?.dispose();

        final authToken = await App.getTokenKey(context);

        final isSuccess = await requestGetAssetTagAndStoreLogs(
          authToken: authToken ?? '',
          qrCode: qrCode,
          assetStatus: App.goingMode ?? 'NA'
        );

        if (isSuccess == false) {
          Loader.stop();

          Toast.show('QR code is either unavailable or unregistered in the Asset Management System (AMS)');

          qrCodeController?.resumeCamera();

          return;
        }
      }
    });
  }

  Future<void> requestCatalogRedeem(
      {required Map<String, dynamic>? data,
      required String membershipId}) async {
    var url = Uri.parse(App.catalogRedeemURI);
    App.headers = {
      App.authKey: App.k3y ?? App.na,
      App.contentType: App.appJsonUTF8
    };
    var response = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );
    // ignore: use_build_context_synchronously
    final token = await App.getTokenKey(context);
    String? errorMessage;
    bool? errorStatus;
    final List<Points> catalogRedeem = [
      Points.fromJson(jsonDecode(response.body))
    ];
    var cr = catalogRedeem[0];
    errorMessage = cr.errorMessage ?? App.undefinedError;
    errorStatus = cr.errorStatus ?? false;
    // ignore: use_build_context_synchronously
    App.checkIGTerror(context: context, errorMessage: errorMessage);
    if (errorMessage.contains(App.connectionAttemptFailed) ||
        errorMessage.contains(App.tn) ||
        errorMessage.contains('dbo') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains(
            'The ConnectionString property has not been initialized') ||
        errorMessage.contains('db') ||
        errorMessage.contains('dbo.') ||
        errorMessage.contains('ConnectionString') ||
        errorMessage.contains('not been initialized')) {
      _genericAlertMessage();
      return;
    }
    if (response.statusCode == 200) {
      DatabaseService.insertLogs(
          id: "${App.generateDateTimeSeconds()}${App.requestKey}",
          tenantId: App.memberCurrentTenantID.toString(),
          membershipId: membershipId,
          deviceId: App.memberCurrentDeviceID ?? App.na,
          jsonRequest: json.encode(data),
          jsonResponse: jsonDecode(response.body).toString(),
          endpoint: url.toString(),
          appVersion: App.versionNumber,
          username: App.memberCurrentUsername,
          hasError: errorStatus);
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      Loader.stop();
      // ignore: use_build_context_synchronously
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.failedAPIrequest);
    } else {
      if (App.k3y != null) {
        setState(() {
          App.k3y = token;
          activeButtonName = App.compsToRedeem;
        });
      } else {
        // ignore: use_build_context_synchronously
        Loader.show(context, 0);
      }
      Loader.stop();
    }
  }

  Future<bool?> requestCompList(Map<String, dynamic>? data) async {
    /// TO GET THE RVC FOR CHECKING BDAY TREAT COMP DURING QR CODE SCANNING
    var url = Uri.parse(App.compListURI);
    App.headers = {
      App.authKey: App.k3y ?? App.na,
      App.contentType: App.appJsonUTF8
    };
    var response = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );
    // ignore: use_build_context_synchronously
    final token = await App.getTokenKey(context);
    String? errorMessage;
    dynamic playerId;
    bool? errorStatus;
    final List<Redemption> redemp = [
      Redemption.fromJson(jsonDecode(response.body))
    ];
    var r = redemp[0];
    errorMessage = r.errorMessage ?? App.undefinedError;
    errorStatus = r.errorStatus ?? false;
    Loader.stop();
    // ignore: use_build_context_synchronously
    App.checkIGTerror(context: context, errorMessage: errorMessage);
    DatabaseService.insertLogs(
        id: "${App.generateDateTimeSeconds()}${App.requestKey}",
        tenantId: App.memberCurrentTenantID.toString(),
        membershipId: playerId ?? App.na,
        deviceId: App.memberCurrentDeviceID ?? App.na,
        jsonRequest: json.encode(data),
        jsonResponse: jsonDecode(response.body).toString(),
        endpoint: url.toString(),
        appVersion: App.versionNumber,
        username: App.memberCurrentUsername,
        hasError: errorStatus);
    if (errorMessage.contains(App.connectionAttemptFailed) ||
        errorMessage.contains(App.tn) ||
        errorMessage.contains('dbo') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains(
            'The ConnectionString property has not been initialized') ||
        errorMessage.contains('db') ||
        errorMessage.contains('dbo.') ||
        errorMessage.contains('ConnectionString') ||
        errorMessage.contains('not been initialized')) {
      _genericAlertMessage();
      return false;
    }
    if (response.statusCode == 200) {
      r.vouchers?.forEach((v) {
        var description = v['description'];
        var compID = v['compID'];
        var rvc = v['rvc'];
        _compVouchers.addAll(["$description - ($compID)"]);
        _selectedRedemptionNumber = compID.toString();
        if (!cardSwipe) {
          App.compRedemptionNumberValue = _selectedRedemptionNumber;
        }
        App.redeemedDescriptionValue = description;
        App.rvcValue = rvc.toString();
      });
      return true;
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      Loader.stop();
      // ignore: use_build_context_synchronously
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.failedAPIrequest);
      return false;
    } else {
      if (App.k3y != null) {
        setState(() {
          App.k3y = token;
          // activeButtonName = App.compsToRedeem;
        });
      } else {
        // ignore: use_build_context_synchronously
        Loader.show(context, 0);
      }
      Loader.stop();
      return false;
    }
  }

  Future<CompStatus?> requestCompStatusRedeem(
      Map<String, dynamic>? data, String playerID) async {
    var url = Uri.parse(App.compStatusRedeemURI);
    App.headers = {
      App.authKey: App.k3y ?? App.na,
      App.contentType: App.appJsonUTF8
    };
    var response = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );
    // ignore: use_build_context_synchronously
    final token = await App.getTokenKey(context);
    String? errorMessage;
    final List<Comps> compStatus = [Comps.fromJson(jsonDecode(response.body))];
    var comps = compStatus[0];
    errorMessage = comps.errorMessage ?? App.undefinedError;
    // ignore: use_build_context_synchronously
    App.checkIGTerror(context: context, errorMessage: errorMessage);
    if (errorMessage.contains(App.connectionAttemptFailed) ||
        errorMessage.contains(App.tn) ||
        errorMessage.contains('dbo') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains('Could not find') ||
        errorMessage.contains(
            'The ConnectionString property has not been initialized') ||
        errorMessage.contains('db') ||
        errorMessage.contains('dbo.') ||
        errorMessage.contains('ConnectionString') ||
        errorMessage.contains('not been initialized')) {
      _genericAlertMessage();
      return CompStatus.none;
    }
    if (response.statusCode == 200) {
      if (comps.compStatus == App.issued) {
        return CompStatus.issued;
      } else if (comps.compStatus == App.redeemed.capitalize()) {
        return CompStatus.redeemed;
      } else if (comps.compStatus == App.voided) {
        return CompStatus.voided;
      } else if (comps.compStatus == App.expired) {
        return CompStatus.expired;
      }
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      Loader.stop();
      // ignore: use_build_context_synchronously
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.failedAPIrequest);
      return CompStatus.none;
    } else {
      if (App.k3y != null) {
        setState(() {
          App.k3y = token;
          activeButtonName = App.compsToRedeem;
        });
      } else {
        // ignore: use_build_context_synchronously
        Loader.show(context, 0);
      }
      Loader.stop();
      return CompStatus.none;
    }
    return null;
  }

  clearAmount() {
    setState(() => amountField.text = App.e);
    Routes.goBack();
    Routes.goBack();
  }

  validateQrCodeOrCardSwipe(
      {required dynamic playerId,
      required dynamic catalogRedeemData,
      required dynamic voucherId,
      required dynamic inputAmount,
      required dynamic uid,
      required dynamic docId}) async {
    DatabaseService.insertUserComps(
        userId: App.requestKey!,
        username: App.memberCurrentUsername,
        compId: voucherId);
    if (catalogRedeemData != null) {
      await requestCatalogRedeem(
          membershipId: playerId ?? App.memberCurrentMembershipID,
          data: catalogRedeemData);
    }
    Map<String, dynamic>? compRedemptionData = {
      App.playerIdKey: int.parse(playerId.toString()),
      App.voucherIdKey: voucherId != "" ? int.parse(voucherId.toString()) : 0,
      App.tenantIdKey: App.memberCurrentTenantID,
      App.amountPrm: inputAmount,
      App.usernameKey: App.memberCurrentUsername,
      App.deviceImeiKey: App.memberCurrentDeviceID!
    };
    if (uid != null && docId != null) {
      setState(() {
        getUID = uid;
        getDocID = docId;
      });
    }
    requestCompRedemption(
        requestName: App.compRedeeem, data: compRedemptionData);
  }

  showPromptEnterAmount(BuildContext context, bool? cardSwipeRedeem,
      {required dynamic playerId,
      required String qrExpiresAt,
      required String itemName,
      required dynamic catalogRedeemData,
      required dynamic voucherId,
      required dynamic uid,
      required dynamic docId}) async {
    QuickAlert.show(
      // ignore: use_build_context_synchronously
      context: context,
      type: QuickAlertType.warning,
      barrierDismissible: false,
      showConfirmBtn: true,
      showCancelBtn: true,
      confirmBtnText: App.ok,
      cancelBtnText: App.close,
      // title: itemName,
      title: '',
      text: itemName,
      // text: "Please ${App.enterAmount}",
      widget: Container(
        margin: const EdgeInsets.only(top: 8),
        child: TextFormField(
          controller: amountField,
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            hintText: App.enterAmount,
            prefixIcon: Icon(Icons.money, color: Colors.black),
          ),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
        ),
      ),
      onConfirmBtnTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();

        var inputAmount = amountField.text;

        if (inputAmount.isEmpty) {
          await QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: App.warning,
              text: "Please enter amount value.");
          return;
        }

        double amountRedeemValue =
            double.parse(inputAmount.replaceAll(",", "").trim());

        if (amountExceededAvailableRVC.contains(App.rvcValue.toString())) {
          /// BIRTHDAY TREAT COMP.
          if (amountRedeemValue >= 1001) {
            return QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                barrierDismissible: true,
                confirmBtnText: App.ok,
                title: App.e,
                text: App.amountExceeded);
          }
        }

        if (!cardSwipe &&
            (voucherId.isNotEmpty || catalogRedeemData.isNotEmpty)) {
          validateQrCodeOrCardSwipe(
              playerId: playerId,
              catalogRedeemData: catalogRedeemData,
              voucherId: voucherId,
              inputAmount: inputAmount,
              uid: uid,
              docId: docId);
        }

        Routes.goBack();

        if (cardSwipe && cardSwipeRedeem == true) {
          Toast.show(
              "Please enter the PIN for Player ID: ${App.memberCurrentPlayerID}");
          setState(() {
            if (voucherId.isNotEmpty || catalogRedeemData.isNotEmpty) {
              cardSwipeUID = uid;
              cardSwipeDocID = docId;
            }
            App.amountValue = inputAmount.replaceAll(",", "").trim();
            activeButtonName = App.pin;
          });
          return;
        }
      },
    );
  }

  _getDefaultData(BuildContext context) async {
    App.memberCurrentDeviceID = await App.getDeviceID() ?? App.na;
    setState(() {
      userScannedQR = true;
    });
  }

  clearSwipeAndEnableMagstripe(context) async {
    Loader.show(context, 0);
    _clear();
    await Future.delayed(const Duration(seconds: 2));
    Loader.stop();
    Routes.navigateToScreen(
        const AssetScannerScreen(headerTitle: App.compRedemptionTitle));
  }

  _genericAlertMessage() {
    Loader.stop();
    return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: true,
        confirmBtnText: App.ok,
        title: App.e,
        text: App.serverErrorMsg);
  }

  Future<bool?> requestGetAssetTagAndStoreLogs({
    required String authToken,
    required String qrCode,
    required String assetStatus
  }) async {
    var url = Uri.parse(
        // 'https://assetmanagementapi-uat.nustar.systems/AssetItem/GetFirst_ByAssetTag?id=$qrCode' /* UAT */
        'https://ams-api.nustar.systems/AssetItem/GetFirst_ByAssetTag?id=$qrCode' /* PROD */
        );

    App.headers = {
      // App.authKey: App.k3y ?? App.na,
      'Authorization': 'Bearer $authToken',
      App.contentType: App.appJsonUTF8
    };

    var response = await http.get(
      url,
      headers: App.headers,
      // body: json.encode(data),
      // encoding: Encoding.getByName(App.utf8),
    );
    debugPrint(">>> requestGetAssetTag --> response.body: ${response.body}");

    if (response.body.toString().isEmpty) {
      return false;
    }

    // ignore: use_build_context_synchronously
    final result = jsonDecode(response.body);

    Loader.stop();

    dynamic resAssetCost;

    if (response.statusCode == 200) {
      var id = result['asset_Tag_Number']; //['id'];
      var resAssetTagName = result['asset_Name'] ?? 'N/A';
      var resAssetGroup = result['asset_Group'] ?? 'N/A';
      var resAssetVendor = result['vendor'] ?? 'N/A';
      var resAssetSerialNumber = result['serial_Number'] ?? 'N/A';
      var resAssetInvoiceNumber = result['invoice_Number'] ?? 'N/A';
      resAssetCost = result['asset_Cost'];
      var resAssetCreatedDate = result['created_Date'];
      var resAssetCurrentOwner = result['current_Asset_Owner'];
      var resAssetPreviousOwner = result['previous_Asset_Owner'];
      var resAssetDepartmentCostCenter = result['department_Cost_Center'];

      // debugPrint(">>> requestGetAssetTag --> Asset Tag: $id");
      // debugPrint(">>> requestGetAssetTag --> Asset Name: $resAssetTagName");
      // debugPrint(">>> requestGetAssetTag --> Asset Group: $resAssetGroup");
      // debugPrint(">>> requestGetAssetTag --> Asset Vendor: $resAssetVendor");
      // debugPrint(">>> requestGetAssetTag --> Asset Serial Number: $resAssetSerialNumber");
      // debugPrint(">>> requestGetAssetTag --> Asset Invoice Number: $resAssetInvoiceNumber");
      // debugPrint(">>> requestGetAssetTag --> Asset Cost: $resAssetCost");
      debugPrint(
          ">>> requestGetAssetTag --> Asset Created Date: $resAssetCreatedDate");
      debugPrint(
          ">>> requestGetAssetTag --> Asset Current Owner: $resAssetCurrentOwner");
      debugPrint(
          ">>> requestGetAssetTag --> Asset Previous Owner: $resAssetPreviousOwner");
      debugPrint(
          ">>> requestGetAssetTag --> Asset Department Cost Center: $resAssetDepartmentCostCenter");

      // ignore: use_build_context_synchronously
      // DatabaseService.insertQrRecord(
      //     context: context,
      //     assetTagName: resAssetTagName,

      //     assetGroup: resAssetGroup,
      //     assetVendor: resAssetVendor);

      setState(() {
        qrCodeResultValue = qrCode;
        userScannedQR = false;

        // debugPrint(">>> QR code scanned successfully! ---> qrCodeResultValue: $qrCodeResultValue");

        assetTagId = id.toString();
        assetTagName = resAssetTagName ?? App.na;
        assetGroup = resAssetGroup ?? App.na;
        assetVendor = resAssetVendor ?? App.na;
        assetSerialNumber = resAssetSerialNumber ?? App.na;
        assetInvoiceNumber = resAssetInvoiceNumber ?? App.na;
        assetAssigneeOwner = resAssetCurrentOwner ?? App.na;
        assetAssigneeDepartment = resAssetDepartmentCostCenter ?? App.na;
        // assetCost //= resAssetCost ?? '0';
        //     = NumberFormat.decimalPattern().format(
        //         // int.parse(resAssetCost.toString())
        //         int.tryParse(resAssetCost.toString()) ?? 0);
        assetCreatedDate //= resAssetCreatedDate ?? App.na;
            = DateFormat('MMM dd, yyyy hh:mm:ss a').format(
                DateTime.now()).toString();
                // DateTime.parse(resAssetCreatedDate.toString())).toString();
      });

      DatabaseService.insertAssetLogs(
        assetTagId: assetTagId,
        assetTagName: assetTagName,
        assetGroup: assetGroup,
        assetVendor: assetVendor,
        assetSerialNumber: assetSerialNumber,
        assetInvoiceNumber: assetInvoiceNumber,
        assigneeOwnerName: assetAssigneeOwner,
        departmentName: assetAssigneeDepartment,
        assetCost: resAssetCost,
        assetCreatedDate: assetCreatedDate,
        deviceId: App.memberCurrentDeviceID ?? 'N/A',
        assetStatus: assetStatus,
      );
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully Scanned for Asset tag #${assetTagId}'),
          backgroundColor: Color(0xFF390b16),
        ),
      );
      return true;
    } else {
      Loader.stop();
      // ignore: use_build_context_synchronously
      QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.failedAPIrequest);
      return false;
    }
  }

  resumeQrCodeScanning() {
    setState(() {
      userScannedQR = true;
      qrCodeResultValue = null;
      isDirectionButtonDisabled = false;
    });
    qrCodeController?.resumeCamera();
  }

  Widget _buildAssetHeaderDetails() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            child: Icon(
              Icons.laptop_chromebook,
              color: Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            assetTagName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            assetTagId,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.normal,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Asset Status',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.w100,
              fontFamily: App.montserrat,
            ),
          ),
          Text(
            App.goingMode ?? 'NA',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
          // _buildStatusBadge(true),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF00D9FF), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00D9FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: App.fontSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        _buildInfoCard(
          icon: Icons.edit_outlined,
          label: 'Edit Asset',
        ),
        const SizedBox(width: 10),
        _buildInfoCard(
          icon: Icons.flag_outlined,
          label: 'Report Issue',
        ),
        const SizedBox(width: 10),
        _buildInfoCard(
          icon: CupertinoIcons.person_circle,
          label: 'Assign to User',
        ),
      ],
    );
  }

  Widget _buildDetailsContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF906b65)),
      ),
      child: Column(
        children: [
          _buildAssetHeaderDetails(),
          const SizedBox(height: 16),
          _horizontalDivider(),
          const SizedBox(height: 8),
          _buildCenteredDetail(
              label: 'Asset Assignee',
              value: assetAssigneeOwner,
              hasSecondaryLabel: false),
          const SizedBox(height: 8),
          // _buildCenteredDetail(
          //     label: 'Asset Assignee ID Number',
          //     value: assetTagId,
          //     hasSecondaryLabel: false),
          _buildCenteredDetail(
              label: 'Asset Assignee Department',
              value: assetAssigneeDepartment,
              hasSecondaryLabel: false),
          _horizontalDivider(),
          const SizedBox(height: 8),
          _buildCenteredDetailWithAction(
            context: context,
            label: 'Asset Serial Number',
            value: assetSerialNumber,
            icon: Icons.copy,
          ),
          const SizedBox(height: 8),
          _buildCenteredDetail(
              label: 'Scanned Date',
              value: assetCreatedDate,
              hasSecondaryLabel: false),
        ],
      ),
    );
  }

  Widget _horizontalDivider() {
    return const SizedBox(
      width: 300,
      child: Divider(
        color: Color(0xFF906b65),
        thickness: 1,
      ),
    );
  }

  Widget _buildCenteredDetailWithAction({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          const Text(
            'Secondary Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.w100,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFe7bd9c),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: App.montserrat,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Serial number copied'),
                      backgroundColor: Color(0xFF390b16),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    icon,
                    color: const Color(0xFFe7bd9c),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredDetail(
      {required String label,
      required String value,
      required bool hasSecondaryLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.w100,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
  }) {
    return  Expanded(
        child: InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This feature is not yet available.'),
            backgroundColor: Color(0xFF210007),
          ),
        );
      },
      child: Container(
          height: 80,
          // color: const Color(0xFF390b16),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF390b16),
            borderRadius: BorderRadius.circular(14),
            // border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFe7bd9c), size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFe7bd9c),
                  fontSize: 14,
                  fontWeight: FontWeight.w100,
                  fontFamily: App.montserrat,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
