import 'package:flutter/material.dart';
import 'package:github_searcher/models/user_model.dart';

class UserProvider with ChangeNotifier {
  userModel _userData = new userModel();
  List<userModel> userList = [];

  List<userModel> get userData {
    return userList;
  }

  void addUserData(userModel obj) {
    _userData = obj;
    userList.add(_userData);
    notifyListeners();
  }

  void removeItem(doc_id) {
    userList.removeWhere((item) => item.id == doc_id);

    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
