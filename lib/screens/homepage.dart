import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github_searcher/screens/user_details_screen.dart';
import 'package:http/http.dart' as http;
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

  void _getUsers() async {
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    try {
      //https://api.github.com/users/awrwrwrwr
      //https://api.github.com/search/users?q=location:iceland%20followers:%3E=100
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
        debugPrint(users_found.toString());
        debugPrint(jsonData['items'][0].toString());

        for (int i = 0; i < users_found; i++) {
          userprovider.addUserData(userModel(
            id: jsonData['items'][i]['id'].toString(),
            userName: jsonData['items'][i]['login'].toString(),
            userImg: jsonData['items'][i]['avatar_url'],
            repos: jsonData['items'][i]['repos_url'],
          ));
        }
      } else {
        debugPrint('no data received-------');
        users_found = 0;
        // debugPrint(results.length.toString());
      }
    } on SocketException catch (_) {
      debugPrint('socket exception-------');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Github Searcher'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  obscureText: false,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          _getUsers();
                        },
                        icon: Icon(Icons.search)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    hintText: "search for users",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    errorText: _validate ? 'Value Can\'t Be Empty' : null,
                  ),
                ),
              ),
              users_found == null || users_found == 0
                  ? const Text(
                      'No users found:',
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .75,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: userprovider.userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 5, right: 5),
                            child: InkWell(
                              onTap: () {
                                Globals.currentUser = userprovider
                                    .userList[index].userName
                                    .toString();

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => UserDetailsPage()));
                              },
                              child: Container(
                                  color: Colors.amber,
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
                                              tag: userprovider
                                                  .userList[index].id
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
                                            child: Text(userprovider
                                                .userList[index].userName
                                                .toString())),
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
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
