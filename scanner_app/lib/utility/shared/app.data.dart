import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nustar_turnstile_scanner/components/toast.dart';
import 'package:nustar_turnstile_scanner/data/models/token.dart';
import 'package:nustar_turnstile_scanner/screens/signin.screen.dart';
import 'package:nustar_turnstile_scanner/services/gpg.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class App {
  static const defaultKey = "M3rch4nt";
  static const docKey = "0025mrch-0212-2f25-ntap-";
  static const e = "";
  static const s = " ";
  static const na = "N/A";
  static const inn = "IN";
  static const out = "OUT";
  static const nl = "\n";
  static const tn = "10.";
  static const str = "s";
  static const intNumber = "int";
  static const boolean = "bool";
  static const idleModeKey = "IDLE_MODE";

  ///IMAGES
  static const noImageAvailable =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/2048px-No_image_available.svg.png";
  static const userPlaceholder =
      "https://firebasestorage.googleapis.com/v0/b/nustar-resort-app-92c7c.appspot.com/o/user-placeholder.png?alt=media&token=270f28f1-c9be-4283-a58e-46792053027f";
  static const nustarLogo = "assets/images/nustar_logo.png";
  static const nustarResort = "assets/images/nustar-resort.jpg";
  static const casinoCover = "assets/images/casino-cover.jpeg";
  static const theMallCover = "assets/images/the-mall.jpg";
  static const bedroomImg = "assets/images/bedroom-1.jpg";
  static const liquorCover = "assets/images/liquor-1.jpeg";
  static const cinemaCover = "assets/images/cinema.jpg";
  static const nustarCinemas = "assets/images/nustar-premier-cinemas.png";
  static const skyDeckCover = "assets/images/skydeck.jpg";
  static const nustarSkyDeckCover = "assets/images/nustar-skydeck.png";
  static const boardWalkCover = "assets/images/boardwalk.jpg";
  static const conventionCenterCover = "assets/images/convention-center.jpg";
  static const nustarConventionCenterCover =
      "assets/images/nustar-convention-center.png";
  static const casino1Cover = "assets/images/casino-1.jpeg";
  static const casino4Cover = "assets/images/casino-4.jpeg";
  static const promotions1Cover = "assets/images/promotions-1.jpg";
  static const promotions2Cover = "assets/images/promotions-2.jpg";
  static const promotions3Cover = "assets/images/promotions-3.jpg";
  static const promotions4Cover = "assets/images/promotions-4.jpg";
  static const hotelCover = "assets/images/hotel-overview.jpeg";
  static const filiNustar = "assets/images/fili-nustar.jpg";
  static const filiLogo = "assets/images/fili-logo.png";
  static const filiDiningNustar = "assets/images/fili-fine-dinning-nustar.jpg";
  static const googleIconURL =
      "assets/images/google-gradient-icon.png"; //"https://firebasestorage.googleapis.com/v0/b/nustar-resort-app-92c7c.appspot.com/o/NUSTAR%2Ficons%2Fgoogle-gradient-icon.png?alt=media&token=9a721901-fd09-43c7-8fd1-e0912c173396";
  static const facebookIconURL =
      "assets/images/facebook-logo.png"; //"https://firebasestorage.googleapis.com/v0/b/nustar-resort-app-92c7c.appspot.com/o/NUSTAR%2Ficons%2Ffacebook-logo-png-23.png?alt=media&token=8503e835-a5be-424b-99a5-610c124693f6";
  static const roadFortuneURL = "./assets/images/road-fortune.jpeg";

  ///TITLES
  static const nustar = "NUSTAR";
  static const merchant = "TURNSTILE SCANNER";
  static const defaultUser = "User";
  static const nustarResortCasino = "NUSTAR RESORT & CASINO CEBU";
  static const nustarNewTitle = "NUSTAR\nRESORT & CASINO\n CEBU";
  static const casino = "Casino";
  static const hotels = "Hotels";
  static const theMall = "The Mall";
  static const dining = "Dining";
  static const experiences = "Experiences";
  static const meetingsEvents = "Meetings & Events";
  static const nustarRewards = "Nustar Rewards";
  static const offers = "Offers";
  static const islandNewPossibilties = "ISLAND OF NEW POSSIBILITIES";
  static const rooms = "Rooms";
  static const cuisine = "Cuisine";
  static const multisensory = "A MULTISENSORY FEAST OF FLAVORS";
  static const whiskyCigar = "Whisky, Cigar and Wine Bar";
  static const expirenceRefinement = "AN EXPERIENCE OF REFINEMENT";
  static const extraOrdinaryMoment = "EXTRAORDINARY IN EVERY MOMENT";
  static const theWharfBoardWalk = "THE WHARF AND THE BOARDWALK";
  static const architecturalWonder = "AN ARCHITECTURAL WONDER";
  static const exceptionalExclusivity = "EXCEPTIONAL EXCLUSIVITY";
  static const marvelous = "MARVELOUS";
  static const rewarding = "REWARDING";
  static const whereSophisticationLuxury =
      "WHERE \nSOPHISTICATION AND\n LUXURY MEET";
  static const destinationWithin = "A DESTINATION WITHIN A DESTINATION";
  static const embracedFilipino = "EMBRACED BY FILIPINO WARMTH";
  static const ultraRedefined = "ULTRA-LUXURY \nREDEFINED";
  static const oasisFlavors = "AN OASIS OF FLAVORS";
  static const privacyPolicy = "PRIVACY POLICY";
  static const or = "or";
  static const theWharfNustar = "THE WHARF | NUSTAR";
  static const loyaltyBecomesRoyalty = "LOYALTY BECOMES ROYALTY";
  static const delightfulDealsAwait = "DELIGHTFUL DEALS AWAIT";
  static const gaming = "GAMING";
  static const roadToFortune = "ROAD TO FORTUNE";
  static const description = "Description";
  static const promotions = "PROMOTIONS";
  static const login = "LOGIN";
  static const logout = "LOGOUT";
  static const pin = "PIN";
  static const backHome = "Back to Home";
  static const points = "Points";
  static const totalAmount = "Total Amount";
  static const transactedAmount = "Transacted Amount";
  static const print = "Print";
  static const pointsEarned = "Points Earned";
  static const pointsRedeemed = "Points Redeemed";
  static const amountRedeem = "Amount to Redeem";
  static const pointsToRedeem = "Points to Redeem";
  static const compsToRedeem = "Comps to Redeem";
  static const tenantID = "Tenant ID";
  static const getBalance = "GET BALANCE";
  static const pinValidation = "PIN VALIDATION";
  static const getPlayerID = "GET PLAYER ID";
  static const cardTier = "Card Tier";
  static const balance = "BALANCE";
  static const inquiry = "INQUIRY";
  static const tenantName = "Tenant Name";
  static const redemptionDateTime = "Redemption Date & Time";
  static const earnDateTime = "Earn Date & Time";
  static const warning = "Warning";
  static const voucherNumber = "Voucher Number";
  static const compId = "Comp ID";
  static const voucher = "Voucher";
  static const selectVoucher = "Select Voucher";
  static const compList = "Comp List";
  static const compInquiry = "Comp Inquiry";
  static const compRedeeem = "Comp Redeem";
  static const redemptionNumberTitle = "Redemption Number";
  static const redeemedDescription = "Description";
  static const amountExceeded = "Amount Exceeded";
  static const scanQRCode = "Scan using QR Code";
  static const pointsRedemptionTitle = "POINTS REDEMPTION";
  static const earnPointsTitle = "EARN POINTS";
  static const balanceInquiryTitle = "BALANCE INQUIRY";
  static const compRedemptionTitle = "COMP REDEMPTION";
  static const enterCompNumber = "Enter COMP #";

  ///ROUTE NAMES
  static const splashScreen = "/splash-screen";
  static const navigationMenuScreen = "/navigation-menu-screen";
  static const accountScreen = "/account-screen";
  static const detailScreen = "/detail-screen";
  static const homeScreen = "/home-screen";
  static const messageScreen = "/messages-screen";
  static const promoScreen = "/promo-screen";
  static const settingsScreen = "/settings-screen";
  static const indexScreen = "/index-screen";
  static const loginScreen = "/login-screen";
  static const signupScreen = "/signup-screen";
  static const getStartedScreen = "/get-started-screen";
  static const casinoScreen = "/casino-screen";
  static const hotelsScreen = "/hotels-screen";
  static const theMallScreen = "/the-mall-screen";
  static const diningScreen = "/dining-screen";
  static const experiencesScreen = "/experiences-screen";
  static const meetingEventsScreen = "/meeting-events-screen";
  static const nustarRewardsScreen = "/nustar-rewards-screen";
  static const offersScreen = "/offers-screen";
  static const gettingHereScreen = "/getting-here-screen";
  static const faqScreen = "/faq-screen";
  static const contactScreen = "/contact-screen";
  static const responsibleGamingScreen = "/responsible-screen";
  static const termsOfUseScreen = "/terms-of-use-screen";
  static const privacyPolicyScreen = "/privacy-policy-screen";
  static const profileScreen = "/profile-screen";
  static const balanceInquiryScreen = "/balance-inquiry-screen";
  static const compRedemptionScreen = "/comp-redemption-screen";
  static const pointsRedemptionScreen = "/points-redemption-screen";
  static const earnPointsScreen = "/earn-points-screen";
  static const assetTagScreen = "/asset-tag-screen";
  static const aboutScreen = "/about-screen";
  static const printingScreen = "/printing-screen";

  ///DESCRIPTION
  static const nustarHomeDesc =
      "A premier 5-star integrated resort in Cebu, Philippines, redeﬁning luxury with world-class gaming, entertainment, events exclusive shopping and dining offerings.";

  ///BUTTON NAMES
  static const learnMore = "Learn more";
  static const bookNow = "Book Now";
  static const ok = "OK";
  static const cancel = "Cancel";
  static const close = "Close";
  static const yes = "Yes";
  static const no = "No";
  static const signIn = "Sign in";
  static const wth = "with";
  static const discover = "DISCOVER";
  static const beMemberNow = "BE A MEMBER NOW";
  static const forgotPassword = "Forgot Password?";
  static const back = " Back";
  static const home = "HOME";
  static const splash = "SPLASH";
  static const balanceInquiry = "BALANCE\nINQUIRY";
  static const pointsRedemption = "POINTS\nREDEMPTION";
  static const compsRedemption = "COMPS\nREDEMPTION";
  static const earnPoints = "EARN\nPOINTS";
  static const about = "ABOUT";
  static const termsOfUse = "TERMS OF USE";
  static const checkBalance = "Check Balance";
  static const confirm = "Confirm";
  static const submit = "Submit";

  ///KEYWORDS
  static const pubApp = "Public App";
  static const facebook = "facebook.com";
  static const fb = "fb";
  static const g = "google";
  static const google = "google.com";
  static const public = "password";
  static const com = ".com";
  static const userLoggedIn = "user_logged_in";
  static const emailAddress = "Email Address";
  static const username = "username";
  static const password = "Password";
  static const missedFbAuthToken = "ERROR_MISSING_FACEBOOK_AUTH_TOKEN";
  static const abortedByUser = "ERROR_ABORTED_BY_USER";
  static const emailKey = "email";
  static const publicProfileKey = "public_profile";
  static const idKey = "id";
  static const pictureKey = "picture";
  static const dataKey = "data";
  static const urlKey = "url";
  static const enableEarnKey = "enableEarn";
  static const enableInquiryKey = "enableInquiry";
  static const enableRedeemKey = "enableRedeem";
  static const enableRedeemCompKey = "enableRedeemComp";
  static const cartItemsKey = "cart_items";
  static const redeemedItemsKey = "redeemed_items";
  static const cartItemStateKey = "cartItemState";
  static const weakPasswordCode = "weak-password";
  static const invalidEmailCode = "invalid-email";
  static const userDisabledCode = "user-disabled";
  static const userNotFoundCode = "user-not-found";
  static const wrongPasswordCode = "wrong-password";
  static const errInvalidEmail = "ERROR_INVALID_EMAIL";
  static const errWrongPw = "ERROR_WRONG_PASSWORD";
  static const errUserNotFound = "ERROR_USER_NOT_FOUND";
  static const errUserDisabled = "ERROR_USER_DISABLED";
  static const errTooManyReq = "ERROR_TOO_MANY_REQUESTS";
  static const errOpNotAllowed = "ERROR_OPERATION_NOT_ALLOWED";
  static const errEmailAlreadyInUse = "ERROR_EMAIL_ALREADY_IN_USE";
  static const uid = "uid";
  static const membershipId = "Membership ID";
  static const playerId = "Player ID";
  static const invoiceNumber = "Invoice Number";
  static const transaction = "Transaction";
  static const pointS = "Points";
  static const updatedPts = "UpdatedPoints";
  static const updatedPtS = "Updated Points";
  static const pointsBalance = "Points Balance";
  static const err = "Error";
  static const errorMsg = "ErrorMessage";
  static const contentType = "Content-Type";
  static const appJsonUTF8 = "application/json; charset=UTF-8";
  static const utf8 = "utf-8";
  static const membershipRewards = "membership_rewards";
  static const logs = "logs";
  static const userMerchantLogs = "user_merchant_logs";
  static const qrRecords = "qr_records";
  static const comps = "comps";
  static const mask = "**";
  static const tenantIdPrm = "tenantId";
  static const voucherIdKey = "voucherId";
  static const vouchersKey = "vouchers";
  static const redemptionNumberKey = "compID";
  static const rvcKey = "rvc";
  static const statusKey = "status";
  static const statusDescKey = "statusDesc";
  static const itemNumberKey = "itemNumber";
  static const descriptionKey = "description";
  static const redemptionCenterKey = "redemptionCenter";
  static const cardTierPrm = "cardTier";
  static const membershipIdPrm = "membershipId";
  static const transactionIdPrm = "transactionId";
  static const amountPrm = "amount";
  static const userIdPrm = "userId";
  static const pointsToRedeemPrm = "pointsToRedeem";
  static const deviceId = "deviceId";
  static const pinCorrect = "isPinCorrect";
  static const deviceIMEI = "deviceImei";
  static const flutterValue = "flutter_value";
  static const clearMagStripe = "M4GSTR1P3_CL34R";
  static const balanceInquiryClear = "BALANCE_INQUIRY_MAG_STRIPE";
  static const classic = "CLASSIC";
  static const silver = "SILVER";
  static const gold = "GOLD";
  static const platinum = "PLATINUM";
  static const vipElite = "VIP ELITE";
  static const banned = "BANNED";
  static const stopMagStripeSwiping = "MAG_STRIPE_CLEAR_DATA";
  static const swipeMagStripeCard = "MAG_STRIPE_SWIPE_CARD";
  static const merchantSwipeMagStripeCard = "MERCHANT_MAG_STRIPE_SWIPE_CARD";
  static const stopMerchantMagStripeSwiping = "MERCHANT_MAG_STRIPE_CLEAR_DATA";
  static const usernameKey = "username";
  static const nameKey = "name";
  static const tenantNameKey = "tenantName";
  static const tenantIdKey = "tenantId";
  static const errorKey = "error";
  static const errorMessageKey = "errorMessage";
  static const applicationKey = "Application";
  static const authKey = "authKey";
  static const clientKey = "clientKey";
  static const transactionKey = "transaction";
  static const compIdKey = "compId";
  static const compStatusKey = "compStatus";
  static const successKey = "success";
  static const playerIdKey = "playerId";
  static const cardIdKey = "cardTier";
  static const updatedPointsKey = "updatedPoints";
  static const rewardsBalanceKey = "rewardsBalance";
  static const goSettings = "Go to Settings";
  static const firstNameKey = "firstName";
  static const lastNameKey = "lastName";
  static const prod = "PROD";
  static const uat = "UAT";
  static const pw = "ITnust4r!";
  static const tenantIdField = "tenant_id";
  static const tenantNameField = "tenant_name";
  static const membershipIdField = "membership_id";
  static const deviceIdField = "device_id";
  static const userIdField = "user_id";
  static const compIdField = "comp_id";
  static const jsonReqField = "json_request";
  static const jsonResponseField = "json_response";
  static const endpointField = "endpoint";
  static const appVersionNumberField = "app_version_number";
  static const dateAndTimeLoginField = "date_and_time_login";
  static const dateAndTimeCreatedTransactionField =
      "date_and_time_created_transaction";
  static const earnPointsEnabledField = "earn_points_enabled";
  static const pointsRedemptionEnabledField = "points_redemption_enabled";
  static const compRedemptionEnabledField = "comp_redemption_enabled";
  static const balanceInquiryEnabledField = "balance_inquiry_enabled";
  static const deviceImeiKey = "deviceImei";

  ///KEY
  static const defaultPw = "Qwerty123!";
  static String magStripeKeyName = "mag_stripe_membership_card";
  static String magStripeStopKeyName =
      "mag_stripe_stop_scanning_membership_card";
  static String magStripeChannel = "flutter/keydata";

  //CONFIG
  static const fbApiKey = "AIzaSyDghAc2EjlHs7Kh_tY5d5TARV7CvqAb6W8";
  static const fbAuthDomain = "nustar-merchant-app.firebaseapp.com";
  static const fbProjectId = "nustar-merchant-app";
  static const fbStorageBucket = "nustar-merchant-app.appspot.com";
  static const fbMessagingSenderId = "878211255711";
  static const fbAppId = "1:878211255711:web:55c099cd93b629441a41aa";
  static const androidPackageName = "uhri.nustar";

  ///INFO OR MESSAGES
  static const createAccount = "Create Account here";
  static const defaultFont = "OpenSans";
  static const error = "Error: ";
  static const logoutMsg = "Do you wish to log out?";
  static const promptMsgLogin = "Please login to the app before you book.";
  static const notAvailable = "This feature is not available for this merchant";
  static const requiredField = "Please fill-up input field.";
  static const selectVoucherMsg = "Please select Voucher.";
  static const passwordConfirm =
      "Password mismatched! Please confirm your password.";
  static const codeValid = "Success! Code is Valid.";
  static const invalidCode = "* Invalid code.";
  static const codeExpired = "* Code expired.";
  static const codeLength = "* Code must be length of ";
  static const tryAgain = "Request timeout.\nPlease try again.";
  static const verifyCaptcha =
      "Please verify that you're not a robot. Kindly input the correct code on CAPTCHA.";
  static const thanksFeedBack = "Thank you for your feedback!";
  static const unableDiscover = "Unable to discover settings for ";
  static const emailSuccess = "Email successfully sent!";
  static const welcomeUser = "Welcome to Nustar Resort App!";
  static const openingSoon = "Opening Soon";
  static const privacyStatement = "Privacy Statement";
  static const coveragePrivacyPolicy = "Coverage of this Privacy Policy";
  static const featureNotAvailable =
      "Sorry, this feature isn't available right now.";
  static const successSignUp = "Successfully sign up!";
  static const emailMalformed = "Your email address appears to be malformed.";
  static const passwordWrong = "Your password is wrong.";
  static const userDoesntExist = "User with this email doesn't exist.";
  static const userDisabled = "User with this email has been disabled.";
  static const tooManyRequests = "Too many requests. Try again later.";
  static const signingNotEnabled =
      "Signing in with Email and Password is not enabled.";
  static const userAlreadyExists = "User already exists.";
  static const undefinedError = "An undefined Error happened.";
  static const unableSignUp = "Unable to Sign up:";
  static const missingFbAuthToken = "Missing Facebook Auth Token";
  static const signInAbortedByUser = "Sign in aborted by user";
  static const enter = "Enter";
  static const passwordIsWeak = "The password provided is too weak.";
  static const invalidEmail = "Invalid Email Address.";
  static const userNotExist = "User with this Email doesn't exist.";
  static const userNotFound = "User not found.";
  static const invalidPassword = "Invalid Password.";
  static const undefineError = "An undefined Error happened.";
  static const userNotLoggedIn =
      "Please Log into your account to display your Account rewards point(s).";
  static const enterMembershipID = "Enter Membership ID";
  static const plsConfirm = "Please confirm";
  static const success = "Success!";
  static const successfullySaved = "Successfully saved!";
  static const successfullyRedeeemed =
      "Comp Successfully Redeemed!"; //"Successfully Redeemed!";
  static const printing = "Printing...";
  static const printSuccess = "Successfully Printed!";
  static const printFailed =
      "Unable to print. It might be a Bluetooth device issue or not supported.";
  static const failedPermission =
      "Please enable and check your device permission.";
  static const deviceNotFound = "Device not found.";
  static const currentDeviceId = "Current Device ID: ";
  static const telpoConnected = "Telpo service connected...";
  static const telpoNotFound = "Telpo device not found...";
  static const connectionAttemptFailed = "Server connection attempt failed";
  static const serverErrorMsg =
      "Unable to connect to IGT. Please check with system administrator.";
  static const internetFound = "Internet connected!";
  static const noInternet =
      "Unable to connect. Please try again after checking your Device network settings.";
  static const failedAPIrequest = "Failed to communicate with the Server.";
  static const swipeCard = "Swipe your card";
  static const enterPassword = "Please enter the password\nto continue.";
  static const accessGranted = "Access Granted!";
  static const invalidPIN = "Invalid PIN";
  static const invalidInvoiceNumber =
      "Unable to proceed. Invoice Number already exists.";
  static const noAvailableVouchers = "No Available Vouchers.";
  static const invalidAmount = "Invalid amount. Please try again";
  static const cardIdInvalid = "Card ID is invalid or not active.";
  static const compRedeemFailedStatus =
      "Unable to Redeemed this Comp. This Comp is already Redeemed/Voided/Expired.";
  static const enterAmount = "Enter Amount";
  static const compAvailableRewardsCounter =
      "This comp is only available for redemption at the Rewards Counter.";

  ///LINKS
  static const pdfLink =
      "https://www.nustar.ph/downloads/nustar-getting-there-en.pdf";
  static const careerLink =
      "https://jgsummit.darwinbox.com/ms/candidate/a6373b98b30596/careers";
  static const fbLink = "https://www.facebook.com/NUSTARCebu";
  static const igLink = "https://www.instagram.com/nustarresort/";
  static const linkedInLink =
      "https://www.linkedin.com/company/nustar-resort-and-casino/";
  static const nustarWebsite = "nustar.ph";

  ///DESCRIPTIONS
  static const loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras convallis nisl dolor. Donec venenatis tellus est, eu tincidunt quam faucibus et. Pellentesque dapibus, lorem non euismod euismod, ex nisi efficitur orci, sit amet posuere tellus lacus molestie justo. Aliquam nisi ligula, venenatis vel ex luctus, aliquam tristique nibh. Nullam eu pellentesque orci, vitae mollis neque. Duis ut purus vel dui aliquet tempor ac sed lacus. Proin sed ante vel ligula cursus rhoncus.";
  static const casinoInfo =
      "Designed by Hirsch-Bedner Associates, one of the world’s leading hospitality design companies, the Casino at NUSTAR is a dazzling harmony of the most reﬁned architecture and embellishments, creating a destination all its own – envisioned to be the number one casino in central and southern Philippines.";
  static const hotelInfo =
      "Indulge in ultra-luxury, where ocean vistas, sublime pools and sundecks, fine-dining, and personalized service await.";
  static const theMallInfo =
      "The Mall | NUSTAR houses rows of luxury brands and dining colonnade of four floors comprising sophisticated curations for everyone. Luxury goes beyond shopping with restaurants featuring different cuisines and first-of-its-kind VIP Cinemas with bar and lounge";
  static const info =
      "We meticulously craft each of our dishes to please the most discerning palates, bringing you the tastes of the world through elegant creativity and robust, inventive flavors.";
  static const diningInfo =
      "We meticulously craft each of our dishes to please the most discerning palates, bringing you the tastes of the world through elegant creativity and robust, inventive flavors.";
  static const experiencesInfo =
      "Designed by renowned contemporary artist JEFRË, the boardwalk spans 580m, connecting NUSTAR resort to CEBU strait in an idyllic and scenic walk.";
  static const meetingsEventsInfo =
      "Curate world-class conferences, exhibitions, fetes, and more in a versatile, multifunctional space with avant-garde technology and bespoke event planning.";
  static const rewardsInfo =
      "NUSTAR Rewards is the official lifestyle rewards program of Cebu’s first and premier integrated resort destination, NUSTAR Resort and Casino. Make the most of every experience when you sign up and earn points. Get priority access to events and enjoy our exclusive offers. The possibilities are endless with NUSTAR Rewards.";
  static const nightInspire = "NIGHTS THAT INSPIRE DAYS THAT DELIGHT";
  static const combineExtraordinary =
      "Combining an extraordinary island location, the Philippine zest for life, and an unmatched culture of hospitality, NUSTAR Resort and Casino is where families, friends, and business professionals from around the world enjoy the very best that life has to offer – exhilarating entertainment, personalized services, the best of global cuisine, and a luxurious shopping experience.";
  static const roomsDesc =
      "Experience opulence at every turn at NUSTAR’s well-appointed rooms. Designed to exude luxury and comfort in every detail, each of the luxe spaces will have guests wake up with renewed vigor to enjoy the amenities and attractions within the integrated resort.";
  static const indulgeUnwind = "INDULGE AND UNWIND";
  static const theCasino = "The Casino";
  static const regionLargestGaming = "THE REGION’S LARGEST GAMING FLOOR";
  static const casinoDesc =
      "Experience the thrill of the game in the region’s largest and most varied gaming floor with exceptional, personalized services – all these with exclusive private rooms, spectacular live performances in the Entertainment Bar, exhilarating events in the Sports Bar, and tantalizing gourmet cuisine.";
  static const theMallNustar = "The Mall | NUSTAR";
  static const shopFinest = "SHOP THE FINEST THE \nWORLD HAS TO OFFER";
  static const theMallDesc =
      "Showcasing an exceptional mix of global luxury brands, NUSTAR’s unique curation of the finest boutiques and exquisite cuisine is guaranteed to bring next-level shopping and dining experiences.";
  static const exploreExclusive =
      "Explore exclusive designer pieces and exquisite collections from global luxury brands.";
  static const tantalizeBoth =
      "Tantalize both your palate and your senses as you indulge in some of the world’s most delightful international dishes prepared by our renowned chefs.";
  static const savorWorld =
      "Savor the world’s finest whiskies and wine as you soak up the ambience along with a choice range of cigars and other offerings.";
  static const cinemaDesc =
      "This is no ordinary cinema experience. First class meets high deﬁnition at the NUSTAR Premier Cinema, which can be booked for private screenings and premieres.";
  static const iconicDeck =
      "This iconic viewing deck 116 meters high boasts breathtaking 180-degree views of Mactan Island and Cebu City that you will long cherish and remember.";
  static const designedFamed =
      "Designed by famed contemporary artist JEFRË, this 580-meter promenade is where people can unwind and go on scenic strolls with some of the best views of Mactan and Cebu City.";
  static const onceCompleted =
      "Once completed, this will be the biggest convention center in the region, catering up to 2,000 delegates. It combines cutting-edge technology, bespoke event planning, and a world-class venue to curate premier meetings, conferences, and any other events for clients.";
  static const islandLeisure =
      "AN ISLAND OF LEISURE AND ENTERTAINMENT POSSIBILITIES – WHERE NUSTAR RESORT AND CASINO IS SET TO DELIVER SENSATIONAL ADVENTURES OF A LIFETIME.";
  static const shufflingPlayingCards =
      "The shuffling of playing cards, the excitement of the crowds, and the thrill of the win – playing at NUSTAR is an adventure of a lifetime everyone should experience.";
  static const withExquisite =
      "With exquisite, lavish VIP Rooms that offer top-notch gourmet dishes, drinks, and services, we redeﬁne the casino experience for the highest of high-rollers. Enjoy playing like royalty and experience amenities and privileges exclusively for our most valued guests.";
  static const marvelousInfo =
      "Enjoy spectacular live performances in the Entertainment Bar, exclusive events in the Sports Bar, and exceptional local and international cuisines.";
  static const rewardingInfo =
      "There is no better place to discover the thrill of the game than at NUSTAR. Our retreat offers a wide variety of promotions and offers to enhance your gaming experience and make every visit more rewarding.";
  static const privacyPolicyInfo =
      "NUSTAR RESORT & CASINO (“NUSTAR”), owned and operated by Universal Hotels and Resorts Inc. (UHRI) takes your privacy seriously. We want you to be informed on how we collect, use, protect, and manage your Personal Information. Please take the time to read the following and learn more about our privacy policy.";
  static const roadToFortuneInfo =
      "Promotion is open to all NUSTAR Rewards members.\n\nTournament is open to qualified NUSTAR Rewards members who have earned 50 Rewards Points from table games and slots, within the earning period, to get one (1) raffle ticket.\n\nNo maximum limit is set for the number of times the player can earn and redeem.Qualified patrons must proceed to the NUSTAR Rewards counter or the tournament desk area and present their membership card to print their raffle tickets starting March 1 (6:00 AM) to April 30, 2023 (2:45 PM).";
  static const unableRedeem = "Unable to Redeem this Item.";
  static const users = "users";
  static const redeemed = "redeemed";
  static const issued = "Issued";
  static const voided = "Voided";
  static const expired = "Expired";

  //FONT FAMILY
  static const oswald = "Oswald";
  static const montserrat = "Montserrat";
  static const fontPrimary = "MontserratBlack";
  static const fontSecondary = "MontserratMedium";

  //ENDPOINTS
  static var getBalanceByIdURI = "";
  static var earnPointsURI = "";
  static var pointsRedemptionURI = "";
  static var accountLoginURI = "";
  static var validatePinURI = "";
  static var getPlayerIdURI = "";
  static var getTokenKeyURI = "";
  static var compListURI = "";
  static var compInquiryURI = "";
  static var compRedeemURI = "";
  static var catalogRedeemURI = "";
  static var compStatusRedeemURI = "";
  static var getCardInfoByIdURI = e;

  //VALUES
  static String versionNumber = "v2.8.10-UAT-1";
  static String memberCurrentMembershipID = na;
  static String memberCurrentUsername = na;
  static String memberCurrentName = e;
  static String? memberCurrentDeviceID;
  static String? memberCurrentPlayerID;
  static String? cardTierValue;
  static String? magStripe;
  static String? memberCurrentTenantName;
  static String? k3y;
  static String? response;
  static String? tokenUserId;
  static String? tokenUserPw;
  static String? tokenUserClientKey;
  static String? cardHolderName;
  static String? requestKey;
  static String? loginDateTime;
  static String? transactionInvoiceNumber;
  static String? totalAmountValue;
  static String? compRedemptionNumberValue;
  static String? redeemedDescriptionValue;
  static String? rvcValue;
  static int memberCurrentTenantID = 0;
  static int memberCurrentPoints = 0;
  static int memberCurrentUpdatedPoints = 0;
  static int memberCurrentBalance = 0;
  static int memberDefaultUserId = 1;
  static int paneProportion = 70;
  static int idleIntervalDuration =
      300; //30; //330; /// 80 = 1 min 30 sec //minutes 330 sec = 5 mins. + 30 sec
  static String? amountValue;
  static double breakpoint = 800;
  static bool validateSuccess = false;
  static bool clearStripe = false;
  static bool telpoServiceConnected = false;
  static bool switchMode = true;
  static bool idleMode = false;
  static bool showEnvMode = false;
  static bool? balanceInquiryEnabled;
  static bool? earnPointsEnabled;
  static bool? pointsRedemptionEnabled;
  static bool? compsRedemptionEnabled;
  static bool shouldClearMagStripe = false;
  static bool isTenantValetService = false;
  static bool isIdle = true;
  static bool isHomeActive = true;
  static bool isBalanceInquiryActive = true;
  static bool isPointsRedemptionActive = true;
  static bool isEarnPointsActive = true;
  static bool isCompRedemptionActive = true;
  static Map<String, String> headers = {};
  // static var methodChannel = MethodChannel(App.magStripeChannel);
  static MethodChannel? methodChannel;
  static List app555249 = [];
  static BuildContext? context;
  static Map userDetails = {};
  static String environmentModeLabel = App.prod;
  static String? goingMode;
  static Color environmentModeColor = Colors.green;
  static String idleModeLabel = idleMode ? on : off;
  static Color idleModeColor = Colors.green;
  static Timer? t;

  //FORMATTER
  static const dateTimeFormat = "MMM dd, yyyy hh:mm:ss a";
  static const dateTimeFormat2 = "mmmddyyyyhhmmssa";
  static String formNum(String s) {
    return NumberFormat.decimalPattern().format(
      int.parse(s),
    );
  }

  static const defaultInitApp = "assets/app/init.json";
  static const uniformeLocalizador = "555249";
  static const pinchar = "70726f64";
  static const arena = "53616e64626f78";
  static const lausuarioacepta = "839711010098111120";
  static const identificaciondeusuario = "75736572206964";
  static const contrasena = "70617373776f7264";
  static const clavedecliente = "636c69656e74206b6579";
  static const off = "OFF";
  static const on = "ON";

  static timestampGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  static String generateDateTimeSeconds() {
    return DateFormat(dateTimeFormat2).format(DateTime.now()).toString();
  }

  // static void checkAppPermissions() async {
  //   if (await Permission.phone.request().isGranted) {
  //     return;
  //   }
  //   Permission.phone.request();
  // }

  static void userLogout() async {
    memberCurrentMembershipID = e;
    memberCurrentUsername = e;
    memberCurrentName = e;
    memberCurrentTenantID = 0;
    memberCurrentPoints = 0;
    memberCurrentUpdatedPoints = 0;
    memberCurrentBalance = 0;
    App.isHomeActive = false;
    App.isBalanceInquiryActive = false;
    App.isPointsRedemptionActive = false;
    App.isEarnPointsActive = false;
    App.isCompRedemptionActive = false;
    Routes.navigateToScreen(const SignInScreen());
  }

  static Future<String?> getDeviceID() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var device = await deviceInfo.androidInfo;
      return device
          .androidId; // The Android hardware device ID that is unique between the device + user and app signing
    }
    return null;
  }

  static void setLocalStorage({
    required String keyName,
    required dynamic value,
    required String dataType,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic pref;
    if (dataType == App.str) {
      pref = (prefs).setString(keyName, value);
    } else if (dataType == App.intNumber) {
      pref = (prefs).setInt(keyName, value);
    } else if (dataType == App.boolean) {
      pref = (prefs).setBool(keyName, value);
    }
    log("setLocalStorage pref ->$pref");
  }

  static Future<bool?> getLocalStorage({
    required String keyName,
    required String dataType,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic pref;
    if (dataType == App.str) {
      pref = (prefs).getString(keyName);
    } else if (dataType == App.intNumber) {
      pref = (prefs).getInt(keyName);
    } else if (dataType == App.boolean) {
      pref = (prefs).getBool(keyName);
    }
    log("getLocalStorage pref ->$pref");
    return pref;
  }

  static void clearLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
      log("this will delete cache...");
    }
  }

  static Future<void> deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
      log("this will delete app's storage...");
    }
  }

  static Future<String>? callMethodChannel(val) async {
    App.methodChannel = MethodChannel(App.magStripeChannel);
    return await App.methodChannel?.invokeMethod<String>(val) ?? e;
  }

  static void clearMembershipIdField(TextEditingController membershipIdField) {
    membershipIdField.clear();
    magStripe = e;
    clearStripe = true;
  }

  static void checkServerStatus(BuildContext context, String errorMessage) {
    errorMessage =
        "A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond. (10.40.21.32:42527)";
    if (errorMessage.contains(App.connectionAttemptFailed) ||
        errorMessage.contains(App.tn)) {
      // ignore: use_build_context_synchronously
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.serverErrorMsg);
      Loader.stop();
    }
  }

  static String currentDateAndTime() {
    return DateFormat(dateTimeFormat).format(DateTime.now());
  }

  static void captureDeviceID(BuildContext context) async {
    // ignore: use_build_context_synchronously
    QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        barrierDismissible: true,
        confirmBtnText: App.ok,
        title: App.e,
        text: "${App.currentDeviceId} $memberCurrentDeviceID");
  }

  static void initJSONresponse(env) async {
    response = await rootBundle.loadString(defaultInitApp);
    updateURI(await getUniformeLocalizador(env));
    tokenUserId = await App.getIdentificacionDeusuario();
    tokenUserPw = await App.getContrasena();
    tokenUserClientKey = await App.getClavedecliente();
  }

  static Future<String>? getUniformeLocalizador(env) async {
    final data = await json.decode(response ?? App.e);
    app555249 = data[App.applicationKey];
    return app555249.first[App.uniformeLocalizador].first[env];
  }

  static Future<String>? getIdentificacionDeusuario() async {
    final data = await json.decode(response ?? App.e);
    app555249 = data[App.applicationKey];
    return await Gpg.decodeData(
            app555249.first[App.identificaciondeusuario] ?? App.na) ??
        App.na;
  }

  static Future<String>? getContrasena() async {
    final data = await json.decode(response ?? App.e);
    app555249 = data[App.applicationKey];
    return await Gpg.decodeData(app555249.first[App.contrasena] ?? App.na) ??
        App.na;
  }

  static Future<String>? getClavedecliente() async {
    final data = await json.decode(response ?? App.e);
    app555249 = data[App.applicationKey];
    return await Gpg.decodeData(
            app555249.first[App.clavedecliente] ?? App.na) ??
        App.na;
  }

  static void updateURI(data) async {
    String? uri = await Gpg.decodeData(data ?? App.na);
    getBalanceByIdURI = "${uri}rewards/getbalancebyid";
    earnPointsURI = "${uri}rewards/earnpoints";
    pointsRedemptionURI = "${uri}rewards/redeem";
    accountLoginURI = "${uri}account/login";
    validatePinURI = "${uri}rewards/validatepin";
    getPlayerIdURI = "${uri}rewards/getplayerid";
    getTokenKeyURI = "${uri}auth/gettokenkey";
    compListURI = "${uri}comp/list";
    compInquiryURI = "${uri}comp/inquire";
    compRedeemURI = "${uri}comp/redemption";
    catalogRedeemURI = "${uri}catalogitems/redeem";
    compStatusRedeemURI = "${uri}comp/status";
    getCardInfoByIdURI = "${uri}rewards/getcardinfobyid";

    debugPrint(">>> BaseURL -->$uri");
    debugPrint(">>> getBalanceByIdURI -->$getBalanceByIdURI");
  }

  static Future<String?> getTokenKey(BuildContext context) async {
    Loader.show(context, 0);

    var url = Uri.parse(
        // 'https://assetmanagementapi-uat.nustar.systems/Auth/GetTokenKey' /* UAT */
        'https://ams-api.nustar.systems/Auth/GetTokenKey' /* PROD */
        );

    App.headers = {App.contentType: App.appJsonUTF8};

    Map<String, dynamic>? data = {'id': 'admin', 'password': 'admin'};

    var response = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );

    Loader.stop();

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      debugPrint(">>> getTokenKey result -->$result");
      // debugPrint(">>> getTokenKey result token -->${result[0]}");
      return result.toString();
    } else {
      Toast.show(App.undefinedError);
      return null;
    }

    /*
    Loader.show(context, 0);
    var url = Uri.parse(App.getTokenKeyURI);
    App.headers = {
      App.contentType: App.appJsonUTF8
    };
    Map<String, dynamic>? data = {
      App.userIdPrm: App.tokenUserId,
      App.public: App.tokenUserPw,
      App.clientKey: App.tokenUserClientKey
    };
    var response = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );
    if (response.statusCode == 200) {
      final List<Token> token = [
        Token.fromJson(jsonDecode(response.body))
      ];
      String errorMessage = token[0].errorMessage ?? App.undefinedError;
      if (errorMessage.contains(App.connectionAttemptFailed) || 
          errorMessage.contains(App.tn)
      ) {
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.serverErrorMsg
        );
        Loader.stop();
        return null;
      }
      if (token[0].hasError ?? false) {
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: errorMessage
        );
        Loader.stop();
        return null;
      }
      return token[0].key ?? App.na;
    } else {
      // ignore: use_build_context_synchronously
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: true,
        confirmBtnText: App.ok,
        title: App.e,
        text: App.undefinedError
      );
      Loader.stop();
      return null;
    }
    */
  }

  static checkIGTerror(
      {required BuildContext context, required String errorMessage}) {
    if (errorMessage.contains("XML") ||
        errorMessage.contains("CRM") ||
        errorMessage.contains("_") ||
        errorMessage.contains("-")) {
      Loader.stop();
      // ignore: use_build_context_synchronously
      return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.serverErrorMsg);
    }
  }

  // static checkIdle(context) async {
  //   App.t = Timer.periodic(const Duration(seconds: 300), (Timer t) async {
  //     if (App.isIdle) {
  //       t.cancel();
  //       return QuickAlert.show(
  //         context: context,
  //         type: QuickAlertType.info,
  //         barrierDismissible: true,
  //         confirmBtnText: App.ok,
  //         text: "User Session expired, \nPlease Login again to continue.",
  //         title: App.warning,
  //         onConfirmBtnTap:() {
  //           App.userLogout();
  //         },
  //       );
  //     }
  //   });
  // }

  static showWarningExpiredSession(BuildContext context) {
    Loader.stop();
    return QuickAlert.show(
        onConfirmBtnTap: () => Restart.restartApp(),
        type: QuickAlertType.info,
        barrierDismissible: false,
        confirmBtnText: App.ok,
        text: "User Session expired, \nPlease Login again to continue.",
        title: App.warning,
        context: context);
  }

  static qrNotAvailable(
      {required BuildContext context, required void Function() onTap}) {
    Loader.stop();
    // ignore: use_build_context_synchronously
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: true,
        confirmBtnText: App.ok,
        title: App.e,
        text:
            "This QR code is not available. Please generate a new QR code using the Rewards App.",
        onConfirmBtnTap: onTap);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
