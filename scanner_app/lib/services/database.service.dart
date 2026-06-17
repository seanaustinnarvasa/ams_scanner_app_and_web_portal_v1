import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/services/gpg.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final String? uid;

  static final CollectionReference logCollection = FirebaseFirestore.instance.collection(App.logs);

  static final CollectionReference userLogsCollection = FirebaseFirestore.instance.collection(App.userMerchantLogs);

  static final CollectionReference qrRecordsCollection = FirebaseFirestore.instance.collection(App.qrRecords);

  static final CollectionReference<Map<String, dynamic>> userCollection =  FirebaseFirestore.instance.collection(App.users);

  static final CollectionReference assetsCollection = FirebaseFirestore.instance.collection('assets');

  static DatabaseService dbService = DatabaseService(App.e);

  DatabaseService(this.uid);

  static Future<void> insertLogs({
    required String id,
    required String tenantId,
    required String membershipId,
    required String deviceId,
    required String jsonRequest,
    required String jsonResponse,
    required String endpoint,
    required String appVersion,
    required String username,
    required bool hasError
  }) async {
    return await logCollection.doc(id).set({
      App.idKey: id,
      App.tenantIdField: tenantId,
      App.membershipIdField: membershipId,
      App.deviceIdField: deviceId,
      App.jsonReqField: jsonRequest,
      App.jsonResponseField: jsonResponse,
      App.endpointField: endpoint,
      App.appVersionNumberField: appVersion,
      App.username: username,
      App.dateAndTimeCreatedTransactionField: Timestamp.now(),
    });
  }

  static Future<DocumentSnapshot> getDoc(String uuid) async {
    return DatabaseService.logCollection.doc(uuid).get();
  }

  static Future<void> updateRewardsShopCartItem({
    required String uid,
    required String docId
  }) async => await userCollection.doc(uid).collection(App.cartItemsKey).doc(docId).update({
    App.cartItemStateKey: App.redeemed
  });

  static Future<void> removeCartItems({
    required String uid,
    required String docId
  }) async => await userCollection.doc(uid).collection(App.cartItemsKey).doc(docId).delete();

  static Future<void> insertRedeemedItems({
    required String uid,
    required String docId,
    required String itemState
  }) async => await userCollection.doc(uid).collection(App.redeemedItemsKey).doc(docId).set({
    'id': uid,
    'doc_id': docId,
    'cart_item_state': itemState,
    'device_id': App.memberCurrentDeviceID,
    'tenant_id': App.memberCurrentTenantID,
    'tenant_username': App.memberCurrentUsername,
    'app_version_number': App.versionNumber,
    'date_and_time_created_transaction': Timestamp.now(),
  });

  static void firebaseInit() async {
    await Firebase.initializeApp();
    var project = Firebase.app();
    debugPrint("Firebase Project ID -> ${project.options.projectId}");
  }

  static FirebaseAuth authInstance() {
    return FirebaseAuth.instance;
  }

  /*
  static Future<UserCredential?> signInWith(BuildContext context) async {
    final email = await Gpg.decodeData(await AppRemoteConfig.get(
      rcName: 'UAT_RES_DEFAULT_ONE',
      isParamStringType: true
    ));

    final pw = await Gpg.decodeData(await AppRemoteConfig.get(
      rcName: 'UAT_RES_DEFAULT_TWO',
      isParamStringType: true
    ));

    try {
      return await authInstance().signInWithEmailAndPassword(
        email: email!,
        password: pw!
      );
    } on FirebaseAuthException catch (_) {
      // ignore: use_build_context_synchronously
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: false,
        confirmBtnText: App.ok,
        title: App.e,
        text: App.connectionAttemptFailed,
      );
      return null;
    }
  }
  */

  static Future<bool> authenticateAndCreateUserEmailAndPassword(BuildContext context, {
    required String userEmailAddress,
    required String userPw
  }) async {
    final currentUser = authInstance().currentUser;

    log("authenticateAndCreateUserEmailAndPassword currentUser ->$currentUser");

    if (currentUser != null) {
      return true;
    }

    final formattedEmailAddress = "$userEmailAddress@gmail.com";

    try {
      final newUserCredential = await authInstance().createUserWithEmailAndPassword(
        email: formattedEmailAddress,
        password: userPw,
      );
      log("newUserCredential user ->${newUserCredential.user}");

      final uid = newUserCredential.user?.uid;

      final userExists = await checkUID(formattedEmailAddress);
      log("userExists ->$userExists");

      if (!userExists) {
        await userCollection.doc(uid).set({
          'uid': uid,
          'biometric_key': App.na,
          'biometric_skip': false,
          'biometric_status': false,
          'device_id': App.na,
          'name': App.na,
          'email_address': formattedEmailAddress,
          'p': App.na,
          'private_key': App.na,
          'profile_pic_url': App.na,
          'mobileNumber': App.na,
          'user_provider': 'M_APP',
          App.statusKey: 1,
          'date_time_created': Timestamp.now()
        });
      }

      log("newUserCredential.user ->${newUserCredential.user}");

      if (newUserCredential.user == null) {
        log("newUserCredential error");
        return false;
      }

      await authInstance().signOut();
      
      final authSignIn = await authInstance().signInWithEmailAndPassword(
        email: formattedEmailAddress,
        password: userPw
      );

      if (authSignIn.user == null) {
        log("authSignIn error");
        return false;
      }

      log("authSignIn success!");

      return true;

    } on FirebaseAuthException catch (e) {
      var errorMessage = "";
      
      if (e.code == 'email-already-in-use') {
        final authSignIn = await authInstance().signInWithEmailAndPassword(
          email: formattedEmailAddress,
          password: userPw
        );

        if (authSignIn.user == null) {
          log("authSignIn error");
          return false;
        }

        return true;
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Password is too weak";
      } else {
        errorMessage = e.message.toString();
      }

      log("Authentication error: $errorMessage");

      Loader.stop();

      // ignore: use_build_context_synchronously
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: false,
        confirmBtnText: App.ok,
        title: App.e,
        text: "Unable to login. Please try again" //errorMessage,
      );
      return false;
    }
  }

  static Future<void> insertUserLogs({
    required String userId,
    required String deviceId,
    required String username,
    required String name,
    required int tenantId,
    required String tenantName,
    required bool earnPointsEnabled,
    required bool pointsRedemptionEnabled,
    required bool compRedemptionEnabled,
    required bool balanceInquiryEnabled
  }) async {
    final uuid = Uuid().v4();
    // return await userLogsCollection.doc("${App.docKey}$merchant").collection(userId).doc(username).set({
    return await userLogsCollection.doc(uuid).set({
      App.userIdField: userId,
      App.deviceIdField: deviceId,
      App.usernameKey: username,
      App.nameKey: name,
      App.tenantIdField: tenantId,
      App.dateAndTimeLoginField: Timestamp.now(),
      App.earnPointsEnabledField: earnPointsEnabled,
      App.pointsRedemptionEnabledField: pointsRedemptionEnabled,
      App.compRedemptionEnabledField: compRedemptionEnabled,
      App.balanceInquiryEnabledField: balanceInquiryEnabled
    });
  }

  static Future<void> insertUserComps({
    required String userId,
    required String username,
    required String compId
  }) async {
    final merchant = await Gpg.encodeData(App.merchant.toLowerCase());
    final uuid = Uuid().v4();
    return await userCollection.doc("${App.docKey}$merchant").collection
    (userId).doc(username).collection(App.comps).doc(compId).set({
      App.idKey: uuid,
      App.compIdField: compId,
      App.statusKey: true,
      App.dateAndTimeCreatedTransactionField: Timestamp.now()
    });
  }

  static Future<DocumentSnapshot>? getUserCompsData({
    required String userId,
    required String username,
    required String compId
  }) async {
    final merchant = await Gpg.encodeData(App.merchant.toLowerCase());
    return await userCollection.doc("${App.docKey}$merchant").collection(userId)
    .doc(username).collection(App.comps).doc(compId).get();
  }

  static Future<DocumentSnapshot>? getQrRecords() async {
    return await qrRecordsCollection.doc().get();
  }

   static Future<QuerySnapshot<Object?>> getQrRecordDataUsingVoucherID(BuildContext context, String value) async {
     return await qrRecordsCollection
       .where("voucherId", isEqualTo: value)
       .orderBy("createdAt", descending: true)
       .get()
       // ignore: invalid_return_type_for_catch_error
       .catchError((err) {
         Loader.stop();
         // ignore: use_build_context_synchronously, invalid_return_type_for_catch_error
         return QuickAlert.show(
           context: context,
           type: QuickAlertType.error,
           barrierDismissible: false,
           confirmBtnText: App.ok,
           title: App.e,
           text: err.message,
         );
       });

     // return await qrRecordsCollection.where("voucherId", isEqualTo: value).orderBy("expiresAt", descending: true).get();
   }

   static Future<void> insertQrRecord({
    required BuildContext context,
    required String assetTagName,
    required String assetGroup,
    required String assetVendor
  }) async {
    try {
      final deviceId = await App.getDeviceID() ?? App.na;
      final uuid = Uuid().v4();
      
      await qrRecordsCollection.doc(uuid).set({
        App.idKey: uuid,
        'assetTagName': assetTagName,
        'assetGroup': assetGroup,
        'assetVendor': assetVendor,
        App.deviceIdField: deviceId,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      Loader.stop();
      // ignore: use_build_context_synchronously
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: false,
        confirmBtnText: App.ok,
        title: App.e,
        text: "Failed to save scan record: ${e.toString()}",
      );
    }
  }

  static Future<bool> checkUID(String value) async =>
  (await userCollection.where('uid', isEqualTo: value).get()).docs.isNotEmpty;

  static Future<void> insertAssetLogs({
    required String assetTagId,
    required String assetTagName,
    required String assetGroup,
    required String assetVendor,
    required String assetSerialNumber,
    required String assetInvoiceNumber,
    required String assigneeOwnerName,
    required String departmentName,
    required dynamic assetCost,
    required String assetCreatedDate,
    required String deviceId,
    required String assetStatus,
  }) async {
    // final uuid = Uuid().v4();
    return await assetsCollection.doc().set({
      'asset_tag_id': assetTagId,
      'asset_tag_name': assetTagName,
      'asset_group': assetGroup,
      'asset_vendor': assetVendor,
      'asset_serial_number': assetSerialNumber,
      'asset_invoice_number': assetInvoiceNumber,
      'asset_assignee_owner': assigneeOwnerName,
      'asset_department_name': departmentName,
      'asset_cost': assetCost,
      'asset_created_date': assetCreatedDate,
      'asset_status': assetStatus,
      'device_id': deviceId,
      'timestamp': Timestamp.now(),
      'is_active': true
    });
  }
   
 }