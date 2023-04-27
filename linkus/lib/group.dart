import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/group_list.dart';
import 'package:linkus/Common%20Widgets/link_list.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
import 'package:linkus/Theme/theme_constant.dart';
import 'package:linkus/groupinfo.dart';
import 'package:linkus/message_popup.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  final User user;
  const GroupPage({super.key, required this.group, required this.user});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FocusNode _searchFocusNode = FocusNode();
  List<Link> _links = [];
  bool _areLinksLoading = true;
  bool _isMember = true;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _users = [];
  final List<String> _tags = [];
  final Set<String> _filteredUsers = {};
  final Set<String> _filteredTags = {};
  List<Link> _filteredLinks = [];
  List<Link> _searchedLinks = [];

  Future<void> _loadLinks() async {
    final links = await LocalDatabase.fetchLinks(widget.group.groupId);
    final uinfo = await LocalDatabase.getGroupSpecificUserInfo(
        widget.user.userId, widget.group.groupId);
    setState(() {
      _links = links;
      _areLinksLoading = false;
      _isMember = uinfo["isMember"];
      _filteredLinks = links;
    });
  }

  Future<void> _loadUsers() async {
    final users = await LocalDatabase.fetchUsersInGroup(widget.group.groupId);
    setState(() {
      _users.addAll(users);
    });
  }

  Future<void> _loadTags() async {
    final tags = [
      "Fiction",
      "Novel",
      "Science Fiction",
      "Non-fiction",
      "Mystery",
      "Genre Fiction",
      "Historical Fiction"
    ];
    setState(() {
      _tags.addAll(tags);
    });
  }

  Future<void> showNewMessagePopUp() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return MessagePopUp(groupId: widget.group.groupId, user: widget.user);
      },
    );

    if (result == true) {
      // Reload the data
      setState(() {
        _areLinksLoading = true;
      });
      await _loadLinks();
    }
  }
  
  void _searchLinks(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchedLinks = _filteredLinks;
      } else {
        _searchedLinks = _filteredLinks
            .where((link) =>
                link.title.toLowerCase().contains(query.toLowerCase()) ||
                link.info.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void filterLinks() {
    List<Link> filteredLinks = [];
    // are there any filters?
    if (_filteredTags.isEmpty && _filteredUsers.isEmpty) {
      filteredLinks = _links;
    } else {
      // are user filters applied?
      if (_filteredUsers.isNotEmpty) {
        for (var link in _filteredLinks) {
          if (_filteredUsers.contains(link.senderName)) {
            filteredLinks.add(link);
          }
        }
      } else {
        filteredLinks = _links;
      }
      // are tag filters applied?
      if (_filteredTags.isNotEmpty) {
        List<Link> tempLinks = [];
        for (var link in filteredLinks) {
          for (var tag in link.tags) {
            if (_filteredTags.contains(tag)) {
              tempLinks.add(link);
              break;
            }
          }
        }
        filteredLinks = tempLinks;
      }
    }
    setState(() {
      _filteredLinks = filteredLinks;
    });
  }

  void _sortByTime() {
    setState(() {
      _filteredLinks.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    });
  }

  void _sortByReacts() {
    setState(() {
      _filteredLinks.sort((a, b) => b.likes.compareTo(a.likes));
    });
  }

  void showSortOptionsPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sort by',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28, color: CustomTheme.of(context).onPrimary)),
          backgroundColor: CustomTheme.of(context).primary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        color: CustomTheme.of(context).onSecondary)),
                onTap: () {
                  // Handle sort by time
                  _sortByTime();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Reacts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        color: CustomTheme.of(context).onSecondary)),
                onTap: () {
                  // Handle sort by reaction
                  _sortByReacts();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showFilterOptionsPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28, color: CustomTheme.of(context).onPrimary)),
          backgroundColor: CustomTheme.of(context).primary,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Wrap(
                spacing: 16,
                children: [
                  // Column for tag filtering
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tags',
                          style: TextStyle(
                              fontSize: 24,
                              color: CustomTheme.of(context).onSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        width: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // color:  CustomTheme.of(context).onSecondary
                        ),
                        child: ListView.builder(
                          itemCount: _tags.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Theme(
                              data: ThemeData(
                                unselectedWidgetColor:
                                    CustomTheme.of(context).secondary,
                                checkboxTheme: CheckboxThemeData(
                                  checkColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return CustomTheme.of(context)
                                            .onSecondary;
                                      } else {
                                        return CustomTheme.of(context)
                                            .onSecondary;
                                      }
                                    },
                                  ),
                                  fillColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return CustomTheme.of(context)
                                            .secondary;
                                      } else {
                                        return CustomTheme.of(context)
                                            .secondary;
                                      }
                                    },
                                  ),
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(_tags[index],
                                    style: TextStyle(
                                        fontSize: 22,
                                        color:
                                            CustomTheme.of(context).secondary)),
                                value: _filteredTags.contains(_tags[index]),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value!) {
                                      _filteredTags.add(_tags[index]);
                                    } else {
                                      _filteredTags.remove(_tags[index]);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Column for user filtering
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Users',
                          style: TextStyle(
                              fontSize: 24,
                              color: CustomTheme.of(context).onSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        width: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // color:  CustomTheme.of(context).onSecondary
                        ),
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Theme(
                              data: ThemeData(
                                unselectedWidgetColor:
                                    CustomTheme.of(context).secondary,
                                checkboxTheme: CheckboxThemeData(
                                  checkColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return CustomTheme.of(context)
                                            .onSecondary;
                                      } else {
                                        return CustomTheme.of(context)
                                            .onSecondary;
                                      }
                                    },
                                  ),
                                  fillColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return CustomTheme.of(context)
                                            .secondary;
                                      } else {
                                        return CustomTheme.of(context)
                                            .secondary;
                                      }
                                    },
                                  ),
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(_users[index],
                                    style: TextStyle(
                                        fontSize: 22,
                                        color:
                                            CustomTheme.of(context).secondary)),
                                value: _filteredUsers.contains(_users[index]),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value!) {
                                      _filteredUsers.add(_users[index]);
                                    } else {
                                      _filteredUsers.remove(_users[index]);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            // Button to apply filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Button to apply filters
                TextButton(
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomTheme.of(context).onPrimary,
                    ),
                  ),
                  onPressed: () {
                    filterLinks();
                    Navigator.pop(context);
                  },
                ),

                // Button to clear all filters
                TextButton(
                  child: Text(
                    'Clear Filters',
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomTheme.of(context).onPrimary,
                    ),
                  ),
                  onPressed: () {
                    _filteredTags.clear();
                    _filteredUsers.clear();
                    setState(() {
                      _filteredLinks = _links;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  GroupMessageList getLinkList(){
    if(_showSearchBar){
      return GroupMessageList(
        groupId: widget.group.groupId,
        user: widget.user,
        links: _searchedLinks,
      );
    }
    else{
      return GroupMessageList(
        groupId: widget.group.groupId,
        user: widget.user,
        links: _filteredLinks,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLinks();
    _loadUsers();
    _loadTags();
    // by default sort by time
    _sortByTime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = _showSearchBar
        ? Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              onChanged: _searchLinks,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: CustomTheme.of(context).onSecondary,
                fontSize: 20,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupInfoPage(
                      group: widget.group,
                      user: widget.user,
                    ),
                  ),
                );
              },
              child: Text(
                widget.group.groupName,
                style: TextStyle(
                  color: CustomTheme.of(context).onSecondary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );

    final content = _areLinksLoading ?
       const Loading()
      :
      _showSearchBar
        ? GroupMessageList(
            groupId: widget.group.groupId,
            user: widget.user,
            links: _searchedLinks,
          )
        : GroupMessageList(
            groupId: widget.group.groupId,
            user: widget.user,
            links: _filteredLinks,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          if (_searchFocusNode.hasFocus) {
            _searchFocusNode.unfocus();
          }
          setState(() {
            _showSearchBar = false;
          });
        },
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                CustomTheme.of(context).gradientStart,
                CustomTheme.of(context).gradientEnd,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Container(
                  decoration: const BoxDecoration(
                    // color: CustomTheme.of(context).secondary,
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: CustomTheme.of(context).onSecondary,
                          )),
                      header,
                      // IconButton(
                      //     onPressed: () {
                      //       if(!_isSearching){
                      //         _searchFocusNode.requestFocus();
                      //       }
                      //       setState(() {
                      //         _isSearching = !_isSearching;
                      //       });
                      //       _searchController.clear();
                      //     },
                      //     icon: Icon(
                      //       _isSearching ? Icons.close :
                      //       Icons.search,
                      //       color: CustomTheme.of(context).onSecondary,
                      //     )),
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          switch (result) {
                            case 'search':
                              setState(() {
                                if(!_showSearchBar){
                                  _searchFocusNode.requestFocus();
                                }
                                setState(() {
                                  _showSearchBar = !_showSearchBar;
                                });
                                _searchController.clear();
                                _searchedLinks = _filteredLinks;
                              });
                              break;
                            case 'sort':
                              showSortOptionsPopUp();
                              break;
                            case 'filter':
                              setState(() {
                                showFilterOptionsPopUp();
                              });
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'search',
                            child: Text('Search',
                                style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        CustomTheme.of(context).onSecondary)),
                          ),
                          PopupMenuItem<String>(
                            value: 'sort',
                            child: Text('Sort',
                                style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        CustomTheme.of(context).onSecondary)),
                          ),
                          PopupMenuItem<String>(
                            value: 'filter',
                            child: Text('Filter',
                                style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        CustomTheme.of(context).onSecondary)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(child: content)
              ],
            )),
      ),
      floatingActionButton: _isMember
          ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: FloatingActionButton(
                onPressed: showNewMessagePopUp,
                backgroundColor: CustomTheme.of(context).secondary,
                child: Icon(Icons.message, color: CustomTheme.of(context).onSecondary,),
              ),
          )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
