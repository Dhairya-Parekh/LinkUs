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
        sender: 'John Doe B',
        likes: 10,
        dislikes: 2,
        link: 'https://google.com',
        time: DateTime.now(),
      ),
    );

    return links;
  }
}
