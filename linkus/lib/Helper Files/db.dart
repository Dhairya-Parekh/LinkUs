import 'package:sqflite/sqflite.dart';

class Group {
  final int id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["id"],
      name: json["name"],
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

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  static Database? _database;
  LocalDatabase._internal();
  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await openDatabase('my_database.db', version: 1,
        onCreate: (Database db, int version) async {
      // Create the first table
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY,
          name TEXT,
          age INTEGER
        )
      ''');
    });
    return _database!;
  }

  static Future<List<Link>> fetchBookmarks() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    // final Database db = await database;
    // final List<Map<String, dynamic>> users =
    //     await db.rawQuery('SELECT * FROM users');
    // print(users)
    // Generate dummy data
    final List<Link> bookmarks = List.generate(
      10,
      (index) => Link(
        title: 'Link ${index + 1}',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        sender: 'John Doe B',
        likes: 10,
        dislikes: 2,
        link: 'https://www.google.com',
        time: DateTime.now(),
      ),
    );

    return bookmarks;
  }

  static Future<List<Group>> fetchGroups() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final List<Group> groups = List.generate(
      15,
      (index) => Group(id: index + 1, name: "Group ${index + 1}"),
    );

    return groups;
  }

  static Future<List<Link>> fetchLinks(int groupId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final List<Link> links = List.generate(
      10,
      (index) => Link(
        title: 'Link ${index + 1}',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        sender: 'John Doe B $groupId',
        likes: 10,
        dislikes: 2,
        link: 'https://google.com',
        time: DateTime.now(),
      ),
    );

    return links;
  }

  static Future<Map<String, dynamic>> getGroupInfo(int groupId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    final Map<String, dynamic> groupInfo = {
      "name": "Group $groupId",
      "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      "members": [
        {
          "name": "John Doe A",
          "role": "Admin",
        },
        {
          "name": "John Doe B",
          "role": "Member",
        },
        {
          "name": "John Doe C",
          "role": "Member",
        },
        {
          "name": "John Doe D",
          "role": "Member",
        },
        {
          "name": "John Doe E",
          "role": "Admin",
        },
        {
          "name": "John Doe F",
          "role": "Member",
        },
        {
          "name": "John Doe G",
          "role": "Member",
        },
        {
          "name": "John Doe H",
          "role": "Member",
        },
        {
          "name": "John Doe I",
          "role": "Member",
        },
        {
          "name": "John Doe J",
          "role": "Admin",
        },
        {
          "name": "John Doe K",
          "role": "Member",
        },
        {
          "name": "John Doe L",
          "role": "Member",
        },
        {
          "name": "John Doe M",
          "role": "Admin",
        },
        {
          "name": "John Doe N",
          "role": "Member",
        },
        {
          "name": "John Doe O",
          "role": "Member",
        },
        {
          "name": "John Doe P",
          "role": "Member",
        },
        {
          "name": "John Doe Q",
          "role": "Member",
        },
        {
          "name": "John Doe R",
          "role": "Member",
        },
        {
          "name": "John Doe S",
          "role": "Member",
        },
        {
          "name": "John Doe T",
          "role": "Member",
        },
        {
          "name": "John Doe U",
          "role": "Admin",
        },
        {
          "name": "John Doe V",
          "role": "Member",
        },
        {
          "name": "John Doe W",
          "role": "Member",
        },
        {
          "name": "John Doe X",
          "role": "Member",
        },
        {
          "name": "John Doe Y",
          "role": "Member",
        },
        {
          "name": "John Doe Z",
          "role": "Member",
        },
      ],
      "isAdmin": true,
    };
    return groupInfo;
  }

  static Future<int> getUserId(String username) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    const int userId = 1;
    return userId;
  }

  static Future<void> changeRole(int groupId, int userId, String role) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    print("Changed role of user $userId in group $groupId to $role");
  }

  static Future<void> kickUser(int groupId, int userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate dummy data
    print("Kicked user $userId from group $groupId");
  }
  
}
