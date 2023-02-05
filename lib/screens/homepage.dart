import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github_searcher/screens/user_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../Utils/globals.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/homepage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int users_found = 0;
  final _searchController = TextEditingController();
  bool _validate = false;
  bool initial_search = true;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _getUsers();
    });
  }

  void _getUsers() async {
    initial_search = false;
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    try {
      if (_searchController.text.isNotEmpty) {
        final response = await http.get(Uri.parse(
            'https://api.github.com/search/users?q=${_searchController.text} in:name type:user'));
        if (response.statusCode == 200) {
          userprovider.userList.clear();
          debugPrint(
              ':) data received--------------------------------------------------');

          // If the call to the server was successful, parse the JSON
          var jsonData = json.decode(response.body);
          // debugPrint(jsonData.toString());
          users_found = jsonData['total_count'];
          if (users_found != 0) {
            debugPrint(users_found.toString());
            debugPrint(jsonData['items'][0].toString());
            log(jsonData['items'][0].toString());

            for (int i = 0; i < users_found; i++) {
              userprovider.addUserData(userModel(
                id: jsonData['items'][i]['id'].toString(),
                userName: jsonData['items'][i]['login'].toString(),
                userImg: jsonData['items'][i]['avatar_url'],
                repos: jsonData['items'][i]['repos_url'],
              ));
            }
          } else {
            userprovider.userList.clear();
            setState(() {
              users_found = 0;
            });
          }
        } else {
          userprovider.userList.clear();
          debugPrint('no data received-------');
          setState(() {
            users_found = 0;
          });

          // debugPrint(results.length.toString());
        }
      } else {
        debugPrint('no data entered-------');
        setState(() {
          initial_search = true;
        });
      }
    } on SocketException catch (_) {
      debugPrint('socket exception-------');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new Image.asset(
              'lib/assets/github.png',
              width: 40.0,
              height: 30.0,
              fit: BoxFit.scaleDown,
            ),
            Text('GITHUB SEARCHER',
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: false,
                controller: _searchController,
                obscureText: false,
                textAlign: TextAlign.left,
                style: TextStyle(
                  letterSpacing: 1,
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _onSearchChanged(value);
                  } else {}
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 18,
                      )),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey)),
                  hintText: "search for users",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  errorText: _validate ? 'Value Can\'t Be Empty' : null,
                ),
              ),
            ),
            users_found == null || users_found == 0
                ? Container(
                    width: 200,
                    height: 200,
                    child: Column(
                      children: [
                        Lottie.asset('lib/lotties/home_search.json'),
                        Text(
                            initial_search
                                ? 'Search for users'
                                : 'No results found',
                            style: TextStyle(
                              letterSpacing: 2,
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ))
                      ],
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .8,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: userprovider.userList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(top: 10, left: 8, right: 8),
                          child: InkWell(
                            onTap: () {
                              Globals.currentUser = userprovider
                                  .userList[index].userName
                                  .toString();

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UserDetailsPage()));
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    // border: Border.all(
                                    //   color: Colors.grey.shade800,
                                    // ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Hero(
                                            tag: userprovider.userList[index].id
                                                .toString(),
                                            child: CircleAvatar(
                                              maxRadius: 100.0,
                                              backgroundImage: NetworkImage(
                                                userprovider
                                                    .userList[index].userImg
                                                    .toString(),
                                              ),
                                            )),
                                      ),
                                      Container(
                                          // color: Colors.amber,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Text(
                                              userprovider
                                                  .userList[index].userName
                                                  .toString(),
                                              style: TextStyle(
                                                letterSpacing: 2,
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                              ))),
                                      Container(
                                          //  color: Colors.red,
                                          //  width: MediaQuery.of(context).size.width * .3,
                                          child: Text(''))
                                    ],
                                  ),
                                )),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
