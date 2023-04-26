import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

class Group {
  final String groupId;
  final String groupName;

  Group({required this.groupId, required this.groupName});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json["id"],
      groupName: json["name"],
    );
  }
}

class ShortLink {
  final String linkId;
  final String link;
  final String senderName;
  final String title;
  final DateTime timeStamp;
  final String info;
  final List<String> tags;
  final int likes;
  final int dislikes;

  ShortLink({
    required this.linkId,
    required this.link,
    required this.senderName,
    required this.title,
    required this.timeStamp,
    required this.info,
    required this.tags,
    required this.likes,
    required this.dislikes,
  });
}

enum GroupRole {
  admin,
  member,
}

extension GroupRoleExtension on GroupRole {
  String get value {
    switch (this) {
      case GroupRole.admin:
        return "adm";
      case GroupRole.member:
        return "mem";
      default:
        return "";
    }
  }
}

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  static Database? _database;
  LocalDatabase._internal();
  static String? _uid;

  static Future<void> loadSchemaFile(Database db) async {
    final schemaSql = await rootBundle.loadString('assets/client_schema.sql');
    final batch = db.batch();
    final sqlStatements = schemaSql.split(';');
    for (final statement
        in sqlStatements.sublist(0, sqlStatements.length - 1)) {
      batch.execute(statement);
    }
    await batch.commit();
  }

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    print("Opening database $_uid");
    _database = await openDatabase(
      'linkus_local_$_uid.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await loadSchemaFile(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await loadSchemaFile(db);
      },
    );
    return _database!;
  }

  static void setupLocalDatabase(String uid) {
    _uid = uid;
  }

  static void closeLocalDatabase() {
    _database?.close();
    _database = null;
  }

  static Future<List<Group>> fetchGroups() async {
    final Database db = await database;
    final List<Map<String, dynamic>> grps =
        await db.rawQuery('SELECT group_id, group_name FROM groups');
    final List<Group> groups = grps
        .map((grp) => Group(
              groupId: grp["group_id"],
              groupName: grp["group_name"],
            ))
        .toList();
    return groups;
  }
static Future<List<ShortLink>> fetchLinks(String groupId) async {
    final Database db = await database;
    String query =
        'SELECT link_id FROM links WHERE group_id = ?';
    List<Map<String, dynamic>> rawLinks = await db.rawQuery(query, [groupId]);
    List<String> linkIds = rawLinks.map((link) => link["link_id"] as String).toList();
    List<ShortLink> links = [];
    // for each link id, fetch the link info
    for(String linkId in linkIds) {
      Map<String,dynamic> linkInfo = await getLinkInfo(linkId);
      links.add(ShortLink(
        linkId: linkId,
        link: linkInfo["link"],
        senderName: linkInfo["senderName"],
        title: linkInfo["title"],
        timeStamp: linkInfo["timeStamp"],
        info: linkInfo["info"],
        tags: linkInfo["tags"],
        likes: linkInfo["likes"],
        dislikes: linkInfo["dislikes"],
      ));
    }
    return links;
  }


  static Future<List<ShortLink>> fetchBookmarks() async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    final List<Map<String, dynamic>> bookmars =
        await db.rawQuery('SELECT * FROM bookmarks natural join links');
    // print(bookmars);
    // Generate dummy data
    final List<ShortLink> bookmarks = [];

    return bookmarks;
  }

  static Future<Map<String, dynamic>> getGroupInfo(String groupId) async {
    // Simulate network delay
    try {
      // await Future.delayed(const Duration(seconds: 3));
      final Database db = await database;
      String query =
          'SELECT group_name, group_info FROM groups WHERE group_id = ?';
      final List<Map<String, dynamic>> rawGroupInfo =
          await db.rawQuery(query, [groupId]);

      query =
          'SELECT users.user_id,user_name,roles FROM participants join users on participants.user_id = users.user_id WHERE group_id = ?';
      final List<Map<String, dynamic>> rawMembers =
          await db.rawQuery(query, [groupId]);
      final Map<String, dynamic> groupInfo = {
        "groupName": rawGroupInfo[0]["group_name"],
        "groupDesc": rawGroupInfo[0]["group_info"],
        "members": rawMembers
            .map((member) => {
                  "userId": member["user_id"],
                  "userName": member["user_name"],
                  "role": member["roles"] == "adm"
                      ? GroupRole.admin
                      : GroupRole.member,
                })
            .toList(),
      };
      return groupInfo;
    } catch (e) {
      print(e);
      return {};
    }
  }

  static Future<Map<String, dynamic>> getLinkInfo(String linkId) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    // final linkInfo = {
    //   "title": "Link $linkId",
    //   "link": "https://www.google.com",
    //   "info": "Lorem ipsum dolor sit amet, consectetur adipiscing",
    //   "senderName": "John Doe",
    //   "timeStamp": DateTime.now(),
    //   "likes": 10,
    //   "dislikes": 2,
    //   "tags": ["tag1", "tag2", "tag3"],
    // };

    final Database db = await database;
    String query =
        'SELECT user_name, title, link, info, time_stamp FROM links join users on links.sender_id = users.user_id WHERE link_id = ?';
    final List<Map<String, dynamic>> rawLinks =
        await db.rawQuery(query, [linkId]);

    final List<Map<String, dynamic>> likesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reacts WHERE link_id = ? AND react = \'l\'',
      [linkId],
    );

    final List<Map<String, dynamic>> dislikesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reacts WHERE link_id = ? AND react = \'d\'',
      [linkId],
    );

    final List<Map<String, dynamic>> tagResults = await db.rawQuery(
      'SELECT tags FROM tags WHERE link_id = ?',
      [linkId],
    );
    final tags = tagResults.map((result) => result['tags'] as String).toList();

    if (rawLinks.isNotEmpty) {
      final Map<String, dynamic> linkInfo = {
        "title": rawLinks[0]["title"],
        "link": rawLinks[0]["link"],
        "info": rawLinks[0]["info"],
        "senderName": rawLinks[0]["user_name"],
        "timeStamp": DateTime.parse(rawLinks[0]["time_stamp"]),
        "likes": likesResult.first["count"],
        "dislikes": dislikesResult.first["count"],
        "tags": tags,
      };
      return linkInfo;
    }

    return {};
  }

  static Future<Map<String, dynamic>> getGroupSpecificUserInfo(
      String userId, String groupId) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    // TODO: Implement this method with actual database
    // Generate dummy data
    try {
      final Database db = await database;
      String query =
          'SELECT roles FROM participants WHERE group_id = ? AND user_id = ?';
      final List<Map<String, dynamic>> role =
          await db.rawQuery(query, [groupId, userId]);
      // Check if user is the only admin in the group
      if (role.isNotEmpty) {
        if (role.first["roles"] == "adm") {
          query =
              'SELECT COUNT(*) as count FROM participants WHERE group_id = ? AND roles = \'adm\'';
          final List<Map<String, dynamic>> admins =
              await db.rawQuery(query, [groupId]);
          if (admins.first["count"] == 1) {
            final jsonResponse = {
              "userId": userId,
              "isMember": true,
              "isAdmin": true,
              "isSoleAdmin": true,
            };
            return jsonResponse;
          } else {
            final jsonResponse = {
              "userId": userId,
              "isMember": true,
              "isAdmin": true,
              "isSoleAdmin": false,
            };
            return jsonResponse;
          }
        } else {
          final jsonResponse = {
            "userId": userId,
            "isMember": true,
            "isAdmin": false,
            "isSoleAdmin": false,
          };
          return jsonResponse;
        }
      } else {
        final jsonResponse = {
          "userId": userId,
          "isMember": false,
          "isAdmin": false,
          "isSoleAdmin": false,
        };
        return jsonResponse;
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  static Future<void> updateMessages(
      List<Map<String, dynamic>> newMessages) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    try {
      print(newMessages);
      final Database db = await database;
      for (Map<String, dynamic> message in newMessages) {
        print(message['tags']);
        print((message['tags'].runtimeType));
        final String senderId = message['sender_id'];
        final String groupId = message['group_id'];
        final String linkId = message['link_id'];
        final String title = message['title'];
        final String link = message['link'];
        final String info = message['info'];
        final List<String> tags =
            List<String>.from(message['tags'].map<String>((e) => e.toString()))
                .toList();
        final String timeStamp = message['time_stamp'];
        String query =
            "insert into links(link_id,sender_id,group_id,title,link,time_stamp,info) values"
            "('$linkId','$senderId','$groupId','$title','$link','$timeStamp','$info')";
        await db.rawInsert(query);
        for (String tag in tags) {
          query = "insert into tags(link_id,tags) values('$linkId','$tag')";
          await db.rawInsert(query);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteMessages(
      List<Map<String, dynamic>> deleteMessages) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> message in deleteMessages) {
      final String linkId = message['link_id'];
      String query = "delete from links where link_id = '$linkId'";
      await db.rawDelete(query);
      query = "delete from tags where link_id = '$linkId'";
      await db.rawDelete(query);
    }
  }

  static Future<void> updateReactions(
      List<Map<String, dynamic>> reactions) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> reaction in reactions) {
      final String userId = reaction['sender_id'];
      final String linkId = reaction['link_id'];
      final String react = reaction['react'];

      final String querySelect =
          "SELECT react FROM reacts WHERE user_id = '$userId' AND link_id = '$linkId'";

      final List<Map<String, dynamic>> result = await db.rawQuery(querySelect);

      if (result.isNotEmpty) {
        if (react == 'n') {
          // If the existing reaction is 'n', delete the row
          final String queryDelete =
              "DELETE FROM reacts WHERE user_id = '$userId' AND link_id = '$linkId'";
          await db.rawDelete(queryDelete);
        } else {
          // Otherwise, update the existing row with the new reaction
          final String queryUpdate =
              "UPDATE reacts SET react = '$react' WHERE user_id = '$userId' AND link_id = '$linkId'";
          await db.rawUpdate(queryUpdate);
        }
      } else {
        // If there is no existing row, insert a new row with the given user_id, link_id, and react
        final String queryInsert =
            "INSERT INTO reacts(user_id, link_id, react) VALUES ('$userId', '$linkId', '$react')";
        await db.rawInsert(queryInsert);
      }
    }
  }

  static Future<void> updateRoles(
      List<Map<String, dynamic>> updateRolesActions) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> roleAction in updateRolesActions) {
      final String userId = roleAction['user_id'];
      final String groupId = roleAction['group_id'];
      final String role = (roleAction['role'] as GroupRole).value;
      String query =
          "update participants set roles = '$role' where user_id = '$userId' and group_id = '$groupId'";
      await db.rawInsert(query);
    }
  }

  static Future<void> removeMembers(
      List<Map<String, dynamic>> removeMember) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> target in removeMember) {
      final String userId = target['affected_id'];
      final String groupId = target['group_id'];
      String query =
          "delete from participants where user_id = '$userId' and group_id = '$groupId'";
      await db.rawDelete(query);
    }
  }

  static Future<void> addUsers(List<Map<String, dynamic>> addUser) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> target in addUser) {
      final String userId = target['user_id'];
      final String groupId = target['group_id'];
      final String userName = target['user_name'];
      final String role = target['role'];
      // insert into users
      String query =
          "insert into users(user_id,user_name) values('$userId','$userName')";

      try {
        await db.rawInsert(query);
      } catch (e) {
        // ignore
      }
      // insert into participants
      query =
          "insert into participants(user_id,group_id,role) values('$userId','$groupId','$role')";
      await db.rawInsert(query);
    }
  }

  static Future<void> getAdded(List<Map<String, dynamic>> addGroup) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    try {
      final Database db = await database;
      for (Map<String, dynamic> target in addGroup) {
        final String groupId = target['group_id'];
        final String groupName = target['group_name'];
        final String groupInfo = target['group_info'];
        // insert into groups
        String query =
            "insert into groups(group_id,group_name,group_info) values('$groupId','$groupName','$groupInfo')";
        await db.rawInsert(query);
        final List<Map<String, dynamic>> members = target['members']
            .map<Map<String, dynamic>>(
                (message) => message as Map<String, dynamic>)
            .toList();
        for (Map<String, dynamic> member in members) {
          final String userId = member['user_id'];
          final String userName = member['user_name'];
          final String role = member['roles'];
          // insert into users
          try {
            query =
                "insert into users(user_id,user_name) values('$userId','$userName')";
            await db.rawInsert(query);
          } catch (e) {
            //
          }
          // insert into participants
          try {
            query =
                "insert into participants(user_id,group_id,roles) values('$userId','$groupId','$role')";
            await db.rawInsert(query);
          } catch (e) {
            //
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteLink(ShortLink link) async {
    // Simulate network delay
    // await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    final String linkId = link.linkId;
    String query = "delete from links where link_id = '$linkId'";
    await db.rawDelete(query);
  }

  static Future<bool> isGroupAdmin(String userId, String groupId) async {
    final Database db = await database;
    final String query =
        "select * from participants where user_id = '$userId' and group_id = '$groupId' and roles = 'adm'";
    final List<Map<String, dynamic>> result = await db.rawQuery(query);
    return result.isNotEmpty;
  }

  static Future<List<String>> fetchUsersInGroup(String groupId) async {
    final Database db = await database;
    final String query = "select user_name from users where user_id in (select user_id from participants where group_id = '$groupId')";
    final List<Map<String, dynamic>> result = await db.rawQuery(query);
    return result.map((e) => e['user_name'] as String).toList();
  }
}
