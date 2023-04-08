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
    _database = await openDatabase(
      'linkus_local.db',
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

  static Future<List<Group>> fetchGroups() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final List<Group> groups = List.generate(
      15,
      (index) => Group(
        groupId: "${index + 1}",
        groupName: "Group ${index + 1}",
      ),
    );

    return groups;
  }

  static Future<List<ShortLink>> fetchLinks(String groupId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final List<ShortLink> links = List.generate(
      10,
      (index) => ShortLink(
        linkId: "${index + 1}",
        title: 'Link ${index + 1}',
        senderName: 'John Doe S $groupId',
        timeStamp: DateTime.now(),
      ),
    );

    return links;
  }

  static Future<List<ShortLink>> fetchBookmarks() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    // final Database db = await database;
    // final List<Map<String, dynamic>> users =
    //     await db.rawQuery('SELECT * FROM users');
    // print(users)
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
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final Map<String, dynamic> groupInfo = {
      "groupName": "Group $groupId",
      "groupDesc": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      "members": [
        {
          "userId": "10",
          "userName": "John Doe",
          "role": GroupRole.admin,
        },
        {
          "userId": "20",
          "userName": "Jane Doe S",
          "role": GroupRole.admin,
        },
        {
          "userId": "30",
          "userName": "John Smith",
          "role": GroupRole.member,
        },
        {
          "userId": "40",
          "userName": "Jane Smith S",
          "role": GroupRole.member,
        },
        {
          "userId": "50",
          "userName": "John Doe B",
          "role": GroupRole.member,
        },
        {
          "userId": "60",
          "userName": "Jane Doe A",
          "role": GroupRole.member,
        },
        {
          "userId": "70",
          "userName": "John Smith C",
          "role": GroupRole.member,
        },
        {
          "userId": "80",
          "userName": "Jane Smith T",
          "role": GroupRole.member,
        },
      ],
    };
    return groupInfo;
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
    db.close();
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
    db.close();
  }

  static Future<void> updateRoles(
      List<Map<String, dynamic>> updateRolesActions) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> roleAction in updateRolesActions) {
      final String userId = roleAction['userId'];
      final String groupId = roleAction['groupId'];
      final String role = roleAction['role'] == GroupRole.admin ? 'adm' : 'mem';
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
      await db.rawInsert(query);
      // insert into participants
      query =
          "insert into participants(user_id,group_id,role) values('$userId','$groupId','$role')";
      await db.rawInsert(query);
    }
  }

  static Future<void> getAdded(List<Map<String, dynamic>> addGroup) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    final Database db = await database;
    for (Map<String, dynamic> target in addGroup) {
      final String groupId = target['group_id'];
      final String groupName = target['group_name'];
      final String groupInfo = target['group_info'];
      // insert into groups
      String query =
          "insert into groups(group_id,group_name,group_info) values('$groupId','$groupName','$groupInfo')";
      await db.rawInsert(query);
      final List<Map<String, dynamic>> members = target['members'];
      for (Map<String, dynamic> member in members) {
        final String userId = member['user_id'];
        final String userName = member['user_name'];
        final String role = member['role'];
        // insert into users
        query =
            "insert into users(user_id,user_name) values('$userId','$userName')";
        await db.rawInsert(query);
        // insert into participants
        query =
            "insert into participants(user_id,group_id,role) values('$userId','$groupId','$role')";
        await db.rawInsert(query);
      }
    }
  }
}
