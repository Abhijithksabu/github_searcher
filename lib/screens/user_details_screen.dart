import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:github_searcher/providers/repos_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Utils/globals.dart';
import '../models/repos_model.dart';
import '../providers/user_provider.dart';

class UserDetailsPage extends StatefulWidget {
  static const routeName = '/userDetails';

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool users_found = false;
  String name = '';
  String email = '';
  String location = '';
  String followers = '';
  String following = '';
  late DateTime joined;
  String bio = '';
  String image = '';
  String collabs = '';
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final _searchController = TextEditingController();
  bool _validate = false;
  int repos_found = 0;
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetails();
    _getInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _getRepos();
    });
  }

  void _getUserDetails() async {
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    try {
      final response = await http.get(
          Uri.parse('https://api.github.com/users/${Globals.currentUser}'));
      print(response.body);
      print(response.statusCode);
      if (response.body != null) {
        users_found = true;
      }
      if (response.statusCode == 200) {
        debugPrint(
            ':) data received--------------------------------------------------');

        // If the call to the server was successful, parse the JSON
        var jsonData = json.decode(response.body);
        name = jsonData['name'].toString() != 'null'
            ? jsonData['name'].toString()
            : '';
        email = jsonData['email'].toString() != 'null'
            ? jsonData['email'].toString()
            : '';
        followers = jsonData['followers'].toString() != 'null'
            ? jsonData['followers'].toString()
            : '0';
        following = jsonData['following'].toString() != 'null'
            ? jsonData['following'].toString()
            : '0';
        collabs = jsonData['collaborators'].toString() != 'null'
            ? jsonData['collaborators'].toString()
            : '0';
        joined = DateTime.parse(jsonData['created_at']).toUtc();
        bio = jsonData['bio'].toString() != 'null'
            ? jsonData['bio'].toString()
            : '';
        location = jsonData['location'].toString() != 'null'
            ? jsonData['location'].toString()
            : '';
        image = jsonData['avatar_url'].toString() != 'null'
            ? jsonData['avatar_url'].toString()
            : '';

        // debugPrint(jsonData.toString());
        setState(() {});
      } else {
        debugPrint('no data received-------');
        users_found = false;
        // debugPrint(results.length.toString());
      }
    } on SocketException catch (_) {
      debugPrint('socket exception-------');
    }
  }

  void _getInitialData() async {
    final reposProvider = Provider.of<ReposProvider>(context, listen: false);
    try {
      var searchValue = " ";
      final response = await http.get(Uri.parse(
          'https://api.github.com/search/repositories?q=${searchValue} user:${Globals.currentUser}'));
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        reposProvider.reposList.clear();
        debugPrint(
            ':) data received--------------------------------------------------');

        // If the call to the server was successful, parse the JSON
        var jsonData = json.decode(response.body);
        debugPrint(jsonData.toString());
        debugPrint(jsonData['total_count'].toString());
        repos_found = int.parse(jsonData['total_count'].toString());
        debugPrint(repos_found.toString());
        debugPrint(jsonData['items'][0].toString());

        for (int i = 0; i < repos_found; i++) {
          reposProvider.addReposData(reposModel(
            id: jsonData['items'][i]['id'].toString(),
            repoName: jsonData['items'][i]['name'].toString(),
            repoUrl: jsonData['items'][i]['html_url'].toString(),
            repoForks: jsonData['items'][i]['forks_count'].toString(),
            repoStars: jsonData['items'][i]['stargazers_count'].toString(),
          ));
        }
        setState(() {});
      } else {
        debugPrint('no data received-------');
        repos_found = 0;
        // debugPrint(results.length.toString());
      }
    } on SocketException catch (_) {
      debugPrint('socket exception-------');
    }
  }

  void _getRepos() async {
    final reposProvider = Provider.of<ReposProvider>(context, listen: false);
    try {
      if (_searchController.text.isNotEmpty) {
        final response = await http.get(Uri.parse(
            'https://api.github.com/search/repositories?q=${_searchController.text} user:${Globals.currentUser}'));
        print(response.body);
        print(response.statusCode);
        if (response.statusCode == 200) {
          reposProvider.reposList.clear();
          debugPrint(
              ':) data received--------------------------------------------------');

          // If the call to the server was successful, parse the JSON
          var jsonData = json.decode(response.body);
          debugPrint(jsonData.toString());
          debugPrint(jsonData['total_count'].toString());
          repos_found = int.parse(jsonData['total_count'].toString());

          if (repos_found != null && repos_found != 0) {
            debugPrint(users_found.toString());
            debugPrint(jsonData['items'][0].toString());
            log(jsonData['items'][0].toString());
            for (int i = 0; i < repos_found; i++) {
              reposProvider.addReposData(reposModel(
                id: jsonData['items'][i]['id'].toString(),
                repoName: jsonData['items'][i]['name'].toString(),
                repoUrl: jsonData['items'][i]['html_url'].toString(),
                repoForks: jsonData['items'][i]['forks_count'].toString(),
                repoStars: jsonData['items'][i]['stargazers_count'].toString(),
              ));
            }
            setState(() {});
          } else {
            reposProvider.reposList.clear();
            setState(() {
              repos_found = 0;
            });
          }
        } else {
          debugPrint('no data received-------');
          setState(() {
            repos_found = 0;
          });

          // debugPrint(results.length.toString());
        }
      } else {
        _searchController.clear();
      }
    } on SocketException catch (_) {
      debugPrint('socket exception-------');
    }
  }

  Widget topCard(title, data) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            )),
        Text(data,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reposProvider = Provider.of<ReposProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Container(
          //   color: Colors.red,
          child: Row(
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
      ),
      body: SingleChildScrollView(
          child: users_found
              ? Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 10, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Hero(
                                  tag: name,
                                  child: CircleAvatar(
                                    maxRadius: 100.0,
                                    backgroundImage: NetworkImage(
                                      image.toString(),
                                    ),
                                  )),
                            ),
                            Container(
                                // color: Colors.amber,
                                width: MediaQuery.of(context).size.width * .5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        topCard('Followers', followers),
                                        topCard('Following', following),
                                        topCard('Collabs', collabs),
                                      ],
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 15, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(email.toString(),
                                style: TextStyle(
                                  letterSpacing: 2,
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                )),
                            Text(location.toString(),
                                style: TextStyle(
                                  letterSpacing: 2,
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                )),
                            Text('joined on ${formatter.format(joined)}',
                                style: TextStyle(
                                  letterSpacing: 2,
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                )),
                            Text(bio.toString(),
                                style: TextStyle(
                                  letterSpacing: 2,
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                )),
                          ],
                        ),
                      ),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey)),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey)),
                            hintText: "search for user's repositories",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                            errorText:
                                _validate ? 'Value Can\'t Be Empty' : null,
                          ),
                        ),
                      ),
                      repos_found != null && repos_found != 0
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * .75,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: reposProvider.reposList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 8, right: 8),
                                    child: InkWell(
                                      onTap: () {
                                        final Uri _url = Uri.parse(reposProvider
                                            .reposList[index].repoUrl
                                            .toString());
                                        _launchUrl(_url);
                                      },
                                      child: Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade800,
                                              // border: Border.all(
                                              //   color: Colors.grey.shade800,
                                              // ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    // color: Colors.amber,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .5,
                                                    child: Text(
                                                        reposProvider
                                                            .reposList[index]
                                                            .repoName
                                                            .toString(),
                                                        style: TextStyle(
                                                          letterSpacing: 2,
                                                          fontSize: 11,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ))),
                                                Container(
                                                    //  color: Colors.red,
                                                    //  width: MediaQuery.of(context).size.width * .3,
                                                    child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'forks : ${reposProvider.reposList[index].repoForks}',
                                                        style: TextStyle(
                                                          letterSpacing: 2,
                                                          fontSize: 11,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        )),
                                                    Text(
                                                        'stars : ${reposProvider.reposList[index].repoStars}',
                                                        style: TextStyle(
                                                          letterSpacing: 2,
                                                          fontSize: 11,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        )),
                                                  ],
                                                ))
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                child: Column(
                                  children: [
                                    Lottie.asset(
                                        'lib/lotties/home_search.json'),
                                    Text('No results found',
                                        style: TextStyle(
                                          letterSpacing: 2,
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                )
              : SizedBox()),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<void> _launchUrl(_url) async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
