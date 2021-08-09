import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delivery_app/screens/home_screen.dart';


class AuthProvider extends ChangeNotifier {
  File image;
  bool isPicAvail = false;
  String pickerError = '';
  String error = '';

  //shop data
  double shopLatitude;
  double shopLongitude;
  String shopAddress;
  String placeName;
  String email;
  bool loading = false;

  CollectionReference _boys = FirebaseFirestore.instance.collection('boys');

  getEmail(email) {
    this.email = email;
    notifyListeners();
  }

//reduce image size
  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'No image selected.';
      print('No image selected.');
      notifyListeners();
    }
    return this.image;
  }

  Future getCurrentAddress() async {
    bool _serviceEnabled;
    LocationPermission _permissionGranted;

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable your location Service');
    }

    _permissionGranted = await Geolocator.checkPermission();
    if (_permissionGranted == LocationPermission.denied) {
      _permissionGranted = await Geolocator.requestPermission();
      if (_permissionGranted == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location Permission is denied');
      }
    }
    if (_permissionGranted == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location Permission denied forever');
    }

    Position currentPosition = await Geolocator.getCurrentPosition();

    List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    Placemark place = placemarks[0];
    shopAddress =
        '${place.street},${place.subLocality},${place.locality},${place.subAdministrativeArea},${place.postalCode},${place.country}';

    placeName = place.locality;
    shopLatitude = currentPosition.latitude;
    shopLongitude = currentPosition.longitude;
    notifyListeners();
    print(shopAddress);

    return shopAddress;
  }

  //register vendor using email

  Future<UserCredential> registerBoys(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak.';
        notifyListeners();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        this.error = 'The account already exists for that email.';
        notifyListeners();
        print('The account already exists for that email.');
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  //login
  Future<UserCredential> loginBoys(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  //reset password
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .whenComplete(() {});
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  //save vendor data to Firestore

  Future<void> saveBoysDataToDb(
      {String url, String name, String mobile, String password, context}) {
    User user = FirebaseAuth.instance.currentUser;
    _boys.doc(this.email).update({
      'uid': user.uid,
      'name': name,
      'password': password,
      'mobile': mobile,
      'address': '${this.placeName}: ${this.shopAddress}',
      'location': GeoPoint(this.shopLatitude, this.shopLongitude),
      'imageUrl': url,
      'accVerified': false //keep initial value as false
    }).whenComplete(() {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
    return null;
  }
}
