import 'package:flutter/material.dart';

abstract class Languages {
  static Languages of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }
  String get aboutbunyan;
  String get shareapp;
  String get shaareapp;
  String get report;
  String get reported;
  String get title;
  String get title_ar;


  String get enterLabel;
  String get confirm;
  String get mobileNumber;
  String get email;
  String get userName;
  String get signUp;
  String get currence;
  String get save;
  String get before;
  String get next;
  String get send;
  String get non;
  String get tryAgain;
  String get loader;
  String get exist;
  String get showMore;
  String get showLess;
  String get today;
  String get days;
  String get emptyValidator;
  String get pickertitle;
  String get follow;
  String get unFollow;
  String get buildingNumber;
  String get streetNumber;
  String get zone;
  String get max;
  String get word;
  String get noAds;
  String get agencydetails;
  String get code;
  String get thecodeyouenteredisincorrect;
  String get password;
  String get newpassword;
  String get wrong;
  String get confirmpassword;
  String get categorie;
  String get article;

// **********************Filter **********************//
  String get realEstate;
  String get services;
  String get agencies;
  String get news;
  String get searchPlaceholder;
  String get search;
  String get readmore;
  String get service;
  String get profilecompany;

  // ********************** Bottom Menu App **********************//
  String get menuHome;
  String get menuFavorite;
  String get menuNotifications;
  String get menuProfile;

// ********************** Login Page **********************//
  String get loginPassword;
  String get loginForgetPwd;
  String get resetPassword;
  String get loginSignIn;
  String get loginAccount;
  String get loginAsGuest;
  String get register;
  String get registerAsPerson;
  String get registerAsCompany;

// ********************** Sign Up Page **********************//
  String get registerTerms;
  String get createPassword;
  String get confirmPassword;
  String get registerPhoto;
  String get registerCRnumber;
  String get registerPasswordValidator;
  String get registerEmployeDetails;
  String get registerEmployeName;
  String get registerEmployePosition;
  String get registerCompanyDetails;
  String get registerCompanyName;
  String get registerCompanyLogo;
  String get registerEmployePhoto;
  String get registerDetails;
  String get registerPhotos;

// ********************** Forget Password Page **********************//
  String get forgetTitle;
  String get forgetWelcome;
  String get forgetSend;

// ********************** OTP Page **********************//
  String get otpTitle;
  String get otpSubTitle;
  String get otpNoCode;
  String get otpResendCode;

// ********************** Product Details Page **********************//
  String get productDetailsFavorite;
  String get productDetailsUnFavorite;
  String get productDetailsShare;
  String get productDetailsRoom;
  String get productDetailsBathRoom;
  String get productDetailsFurniched;
  String get productDetailsUnFurniched;
  String get productDetailsDescrption;
  String get productDetailsID;
  String get productDetailsReport;
  String get productDetailsShowOnMap;
  String get productDetailsFollowers;
  String get productDetailsFollow;
  String get productDetailsCall;
  String get productDetailsCallAdvertiser;
  String get productDetailsCallWhats;
  String get productDetailsCallPhone;
  String get productDetailsCallChat;
  String get productDetailsMoreAds;
  String get makesureoftheinformation;
  String get back;
  String get chekconnection;
  String get ServererrorPleasetryagainlater;
  String get agreeon;
  String get Pleaseenteravalidmail;
  String get Pleaseenteravalidmobilenumber;
  String get activateacount;
  String get pleasegoemail;
  String get about;
  String get editprofile;
  String get profile;
  String get realstate;
  String get regions;
  String get home;
  String get advsearoption;
  String get cities;
  String get rooms;
  String get baths;
  String get price;
  String get from;
  String get to;
  String get furnishing;
  String get searchagence;
  String get like;
  String get dislike;
  String get reference;
  String get gotoprofile;
  String get rent;
  String get sale;
  String get commercial;
  String get notification;
  String get confirminformation;
  String get chekinternet;
  String get emptyValidatorPass;
  String get emailaddress;
  String get pleaseagree;
  String get paidadfeatured;
  String get fortheallowance;
  String get desired;
  String get Workersaccommodation;
  String get Popularhouses ;
  String get storehouses;
  String get Buildingsandtowers;
  String get Commercialoffices;
  String get Shops;
  String get Administrativeandcommercialvillas;
  String get Apartments;
  String get Residentialvillas;
  String get Otherproperties;
  String get locate;
  String get openonmap;
  String get nomapoutside;
  String get later;








  // ********************** Profile Page **********************//
  String get labelSelectLanguage;
  String get appLanguage;
  String get profileWorkOn;
  String get editPhotoProfileSuccess;
  String get logout;
  String get PaidadBanner;
  String get Paidadnormal;

  // ********************** ModalBottomSheet **********************//
  String get modalBottomSheetPhotoLibrary;
  String get modalBottomSheetCamera;

  // ********************** Add Ad Page **********************//
  String get adType;
  String get adPhoto;
  String get adPhotoValidation;
  String get adCatogory;
  String get adSubcategory;
  String get adCity;
  String get adZone;
  String get adFurnishing;
  String get adVideo;
  String get adSwimming;
  String get adWithSwimming;
  String get adWithoutSwimming;
  String get adRoomNumber;
  String get adBathRoomNumber;
  String get adSpace;
  String get adPrice;
  String get adLocation;
  String get adOnLocation;
  String get adOnLocationValidation;
  String get adAddress;
  String get adDescription;
  String get adDescriptionarabic;
  String get adAction;
  String get emailcode;

  // ********************** Real State Page **********************//
  String get employeeAccomodation;
  String get apartments;
  String get villa;
  String get depot;
  String get doha;
  String get khour;
  String get wakraha;
  String get rayyan;
  String get madinatchamal;
  String get omsalal;
  String get dhaayen;
  String get lusail;
  String get Pearl;
  String get putprice;
  String get demandereceive;
  String get mailverification;
  String get tomail;
  String get verification;
  String get enterfullname;
  String get enterphone;
  String get correctemail;
  String get servererror;
  String get addads;
  String get resent;
  String get nopin;
  String get typeservice;
  String get reportad;
  String get yourmessage;
  String get removefromfavoritelist;
  String get followus;
  String get serv;
  String get pressagain;
  String get nA;
  String get required;


  // ********************** Favorite Page **********************//
  String get noFavorite;
  String get favorite;
  String get favoriteno;

  // ********************** Chat Page **********************//
  String get noChats;

  // ********************** Redirect to Auth Page **********************//
  String get redirectToAuthMessage;

  // ********************** Notifications Page **********************//
  String get emptyNotifications;

  String get noNews;

  String get minPrice;

  String get maxPrice;

  String get registered;

  String get oldPassword;

  String get wrongPassword;

  String get or;

  String get continueWith;

  String get unavailable;

  String get updateRequired;

  String get updateNow;

  String get related;

  String get totalAds;
  String get inReviewAds;
  String get completedAds;
  String get completedAd;


  String get repost;
  String get edit;
  String get share;
  String get delete;


  String get deleteAccount;

  String get deleteAccountBody;

  String get yes;
  String get no;


}
