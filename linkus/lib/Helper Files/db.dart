import 'package:sqflite/sqflite.dart';
import 'dart:io';

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

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  static Database? _database;
  LocalDatabase._internal();

  static Future<void> loadSchemaFile(Database db) async {
    final schemaFile = File('client_schema.sql');
    final schemaSql = await schemaFile.readAsString();
    final batch = db.batch();
    final sqlStatements = schemaSql.split(';');
    for (final statement in sqlStatements) {
      batch.execute(statement);
    }
    await batch.commit();
  }

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await openDatabase('my_database.db', version: 1,
        onCreate: (Database db, int version) async {
      await loadSchemaFile(db);
    });
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

  static Future<void> updateRoles(
      List<Map<String, dynamic>> changeRoleActions) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    for (final action in changeRoleActions) {
      final String groupId = action['groupId'];
      final String userId = action['userId'];
      final GroupRole role = action['role'];
      print(
          "Changed role of user $userId in group $groupId to ${role == GroupRole.admin ? "admin" : "member"}");
    }
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

  static Future<void> kickUser(int groupId, int userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    print("Kicked user $userId from group $groupId");
  }

  static Future<void> updateMessages(
      List<Map<String, dynamic>> newMessages) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
  }

  static Future<void> deleteMessages(
      List<Map<String, dynamic>> deleteMessages) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
  }

  static Future<void> updateReactions(List<Map<String, dynamic>> react) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
  }

  static Future<void> removeMembers(
      List<Map<String, dynamic>> removeMemberActions) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    for (final action in removeMemberActions) {
      final String groupId = action['groupId'];
      final String userId = action['userId'];
      print("Removed user $userId from group $groupId");
    }
  }

  static Future<void> addUsers(List<Map<String, dynamic>> addUser) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
  }

  static Future<void> getAdded(List<Map<String, dynamic>> addGroup) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
  }
}
