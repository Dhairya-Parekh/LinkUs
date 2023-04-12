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

class Link {
  final String sender;
  final String title;
  final DateTime time;
  final String description;
  final int likes;
  final int dislikes;
  final String link;

  Link({
    required this.sender,
    required this.title,
    required this.time,
    required this.description,
    required this.likes,
    required this.dislikes,
    required this.link,
  });
}

class ShortLink {
  final String linkId;
  final String senderName;
  final String title;
  final DateTime timeStamp;

  ShortLink({
    required this.linkId,
    required this.senderName,
    required this.title,
    required this.timeStamp,
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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    // final List<ShortLink> links = List.generate(
    //   10,
    //   (index) => ShortLink(
    //     linkId: "${index + 1}",
    //     title: 'Link ${index + 1}',
    //     senderName: 'John Doe S $groupId',
    //     timeStamp: DateTime.now(),
    //   ),
    // );
    final Database db = await database;
    String query =
        'SELECT link_id,user_name,title,time_stamp FROM links join users on links.sender_id = users.user_id WHERE group_id = ?';
    final List<Map<String, dynamic>> rawLinks =
        await db.rawQuery(query, [groupId]);
    final List<ShortLink> links = rawLinks
        .map((link) => ShortLink(
              linkId: link["link_id"],
              title: link["title"],
              senderName: link["user_name"],
              timeStamp: DateTime.parse(link["time_stamp"]),
            ))
        .toList();
    return links;
  }

  static Future<List<ShortLink>> fetchBookmarks() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    final List<Map<String, dynamic>> bookmars =
        await db.rawQuery('SELECT * FROM bookmarks natural join links');
    print(bookmars);
    // Generate dummy data
    final List<ShortLink> bookmarks = List.generate(
      10,
      (index) => ShortLink(
        linkId: "${index + 1}",
        title: 'Link ${index + 1}',
        senderName: 'John Doe B',
        timeStamp: DateTime.now(),
      ),
    );

    return bookmarks;
  }

  static Future<Map<String, dynamic>> getGroupInfo(String groupId) async {
    // Simulate network delay
    try {
      await Future.delayed(const Duration(seconds: 3));
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
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final linkInfo = {
      "title": "Link $linkId",
      "link": "https://www.google.com",
      "info": "Lorem ipsum dolor sit amet, consectetur adipiscing",
      "senderName": "John Doe",
      "timeStamp": DateTime.now(),
      "likes": 10,
      "dislikes": 2,
      "tags": ["tag1", "tag2", "tag3"],
    };
    return linkInfo;
  }

  static Future<Map<String, dynamic>> getGroupSpecificUserInfo(
      String userId, String groupId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final jsonResponse = {
      "userId": userId,
      "isAdmin": true,
    };
    return jsonResponse;
  }

  static Future<void> updateMessages(
      List<Map<String, dynamic>> newMessages) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    try {
      final Database db = await database;
      for (Map<String, dynamic> message in newMessages) {
        final String senderId = message['sender_id'];
        final String groupId = message['group_id'];
        final Map<String, dynamic> linkInfo = message['link'];
        final String linkId = linkInfo['link_id'];
        final String title = linkInfo['title'];
        final String link = linkInfo['link'];
        final String info = linkInfo['info'];
        final int timeStamp = linkInfo['time_stamp'];
        final List<String> tags = linkInfo['tags'];

        String query =
            "insert into links(link_id,sender_id,group_id,title,link,time_stamp,info) values"
            "('$linkId','$senderId','$groupId','$title','$link',$timeStamp,'$info')";
        await db.rawInsert(query);
        for (String tag in tags) {
          query = "insert into tags(link_id,tag) values('$linkId','$tag')";
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
    await Future.delayed(const Duration(seconds: 3));
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
    await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> reaction in reactions) {
      final String userId = reaction['user_id'];
      final String linkId = reaction['link_id'];
      final String react = reaction['react'];
      final String query =
          "insert into reacts(user_id,link_id,react) values('$userId','$linkId','$react')";
      await db.rawInsert(query);
    }
  }

  static Future<void> updateRoles(
      List<Map<String, dynamic>> updateRolesActions) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> roleAction in updateRolesActions) {
      final String userId = roleAction['user_id'];
      final String groupId = roleAction['group_id'];
      final String role = roleAction['role'].value;
      String query =
          "update participants set roles = '$role' where user_id = '$userId' and group_id = '$groupId'";
      await db.rawInsert(query);
    }
  }

  static Future<void> removeMembers(
      List<Map<String, dynamic>> removeMember) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> target in removeMember) {
      final String userId = target['user_id'];
      final String groupId = target['group_id'];
      String query =
          "delete from participants where user_id = '$userId' and group_id = '$groupId'";
      await db.rawDelete(query);
    }
  }

  static Future<void> addUsers(List<Map<String, dynamic>> addUser) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
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
}
