import 'package:flutter/material.dart';

import '../../models/classes/user.dart';
import '../../models/universal_widgets/search_card.dart';
import '../../services/node_services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _searchText;
  List<User>? _usersList;
  late Future _future;

  Future getSearch() async {
      dynamic result = await SearchService().getSearchQuery(_searchText ?? '');
      _usersList = result[0] as List<User>;
      return [_usersList];
  }

  @override
  void initState() {
    _future =  getSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                  onPressed: () {Navigator.pop(context);},
                                  icon: const Icon(Icons.close, color: Colors.white,)
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: 'Search',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey, width: 0.5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.blueAccent, width: 0.5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    )
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchText = val;
                                    _future =  getSearch();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        FutureBuilder(
                            future:  (_searchText == null || _searchText == '') ? null : _future,
                            builder: (context, snap) {
                              if(_searchText == null || _searchText == '') { return const SizedBox(); }
                              if(snap.connectionState == ConnectionState.done && _usersList != null && _searchText != '') {
                                return Expanded(
                                  child: ListView(
                                    children: [

                                      _usersList?.isNotEmpty ?? false
                                          ? labelWidget('People')
                                          : const SizedBox(),

                                      cardBuilder('user', users: _usersList),

                                      _usersList!.length >= 5
                                          ? viewMoreButton('userSearch')
                                          : const SizedBox(),

                                       SizedBox(height:_usersList!.isNotEmpty ? 20 : 0,),


                                    ],
                                  ),
                                );
                              } else if(_searchText == null || _searchText == '') {
                                return Container();
                              } else {
                                return const Padding(
                                  padding:  EdgeInsets.only(top: 30.0),
                                  child:   CircularProgressIndicator(color: Colors.grey,),
                                );
                              }
                            }
                        )
                      ],
                    ),
                  )
              ),
            ),
          ),
        )
    );
  }

  Widget labelWidget(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child:  Text(
        text,
        style: TextStyle(
            color: Colors.grey[400],
            fontSize: 20
        ),
      ),
    );
  }

  Widget cardBuilder(String type, {List<User>? users}) {
    return Column(
      children: [
        ListView.builder(
            itemCount: type == 'user'
                ? users!.length
                : 0,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(height: 10,),
                  searchCard(context, userInfo: users?[index], type: type),
                ],
              );
            }),
      ],
    );
  }

  Widget viewMoreButton(String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Center(
        child: GestureDetector(
          // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewMoreQueryScreen(type: type, searchText: _searchText!))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('view all', style: TextStyle(color: Colors.grey, fontSize: 20),),
              Icon(Icons.arrow_forward_ios, color: Colors.grey,)
            ],
          ),
        ),
      ),
    );
  }


}
