import 'package:flutter/material.dart';
import 'package:github_searcher/models/user_model.dart';

import '../models/repos_model.dart';

class ReposProvider with ChangeNotifier {
  reposModel _reposData = new reposModel();
  List<reposModel> reposList = [];

  List<reposModel> get reposData {
    return reposList;
  }

  void addReposData(reposModel obj) {
    _reposData = obj;
    reposList.add(_reposData);
    notifyListeners();
  }

  void removeItem(doc_id) {
    reposList.removeWhere((item) => item.id == doc_id);

    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
