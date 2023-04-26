import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/link_list.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/local_storage.dart';
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
  List<ShortLink> _links = [];
  bool _areLinksLoading = true;
  bool _isMember = true;
  bool _showSearchBar = false;
  bool _areFiltersApplied = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> _users = [];
  List<String> _tags = [];
  Set<String> _filteredUsers = {};
  Set<String> _filteredTags = {};
  List<ShortLink> _filteredLinks = [];
  List<ShortLink> _searchedLinks = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final tags =["Fiction","Novel","Science Fiction","Non-fiction","Mystery","Genre Fiction","Historical Fiction"];
    setState(() {
      _tags.addAll(tags);
    });
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
      } 
      else {
        _searchedLinks = _filteredLinks
          .where((link) =>
              link.title.toLowerCase().contains(query.toLowerCase()) || link.info.toLowerCase().contains(query.toLowerCase()))
          .toList();
      }
    });
  }

  void _sortByTime(){
    setState(() {
      _filteredLinks.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    });
  }

  void _sortByReacts(){
    setState(() {
      _filteredLinks.sort((a, b) => b.likes.compareTo(a.likes));
    });
  }

  void showSortOptionsPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Time'),
                onTap: () {
                  // Handle sort by time
                  _sortByTime();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sort by Reacts'),
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
          title: Text('Filter Options'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Wrap(
                spacing: 16,
                children: [
                  // Column for tag filtering
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter by Tags'),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _tags.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CheckboxListTile(
                              title: Text(_tags[index]),
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Column for user filtering
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter by Users'),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CheckboxListTile(
                              title: Text(_users[index]),
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
            TextButton(
              child: Text('Apply Filters'),
              onPressed: () {
                filterLinks();
                Navigator.pop(context);
              },
            ),
            // Button to clear all filters
            TextButton(
              child: Text('Clear Filters'),
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
        );
      },
    );
  }

  void filterLinks()
  {
    List<ShortLink> filteredLinks = [];
    // are there any filters?
    if(_filteredTags.isEmpty && _filteredUsers.isEmpty)
    {
      filteredLinks = _filteredLinks;
    }
    else
    {
      // are user filters applied?
      if(_filteredUsers.isNotEmpty)
      {
        for(var link in _filteredLinks)
        {
          if(_filteredUsers.contains(link.senderName))
          {
            filteredLinks.add(link);
          }
        }
      }
      else
      {
        filteredLinks = _filteredLinks;
      }
      // are tag filters applied?
      if(_filteredTags.isNotEmpty)
      {
        List<ShortLink> tempLinks = [];
        for(var link in filteredLinks)
        {
          for(var tag in link.tags)
          {
            if(_filteredTags.contains(tag))
            {
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

  LinkList getLinkList() {
    if(_showSearchBar)
    {
      return LinkList(links: _searchedLinks, user: widget.user, groupId: widget.group.groupId);
    }
    else
    {
      return LinkList(links: _filteredLinks, user: widget.user, groupId: widget.group.groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // navigate to group info page
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
          child: Text(widget.group.groupName),
        ),
        leading: Visibility(
          visible: !_showSearchBar,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Visibility(
            visible: !_showSearchBar,
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case 'search':
                    setState(() {
                      _showSearchBar = true;
                      _searchedLinks = _filteredLinks;
                    });
                    break;
                  case 'sort':
                    // handle sort action
                    showSortOptionsPopUp();
                    break;
                  case 'filter':
                    setState(() {
                      showFilterOptionsPopUp();    
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'search',
                  child: Text('Search'),
                ),
                PopupMenuItem<String>(
                  value: 'sort',
                  child: Text('Sort'),
                ),
                PopupMenuItem<String>(
                  value: 'filter',
                  child: Text('Filter'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _showSearchBar,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 30)),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchLinks,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Icon(Icons.clear),
                      onTap: () {
                        setState(() {
                          _showSearchBar = false;
                          _searchController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _areLinksLoading
          ? const Loading()
          : getLinkList(),
      floatingActionButton: _isMember
          ? FloatingActionButton(
              onPressed: showNewMessagePopUp,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
