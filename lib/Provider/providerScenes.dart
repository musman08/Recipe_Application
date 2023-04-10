import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProviderScene with ChangeNotifier {

  bool _buttonLoading = false;
  bool get buttonLoading => _buttonLoading;

  void startLoading(){
    _buttonLoading = true;
    notifyListeners();
  }
  void stopLoading(){
    _buttonLoading = false;
    notifyListeners();
  }
  
}

class ProviderImage with ChangeNotifier {
  File? _imageFile;

  File? get imageFile => _imageFile;

  void ChangeImage(File imageFile){
    _imageFile=imageFile;
    notifyListeners();
  }

  void removeImage(){
    _imageFile = null;
    notifyListeners();
  }

}