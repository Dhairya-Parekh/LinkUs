import 'dart:async';
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

  Link({required this.sender, required this.title, required this.time});
}

Future<List<Group>> fetchGroups() async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 3));

  // Generate dummy data
  final List<Group> groups = List.generate(
    15,
    (index) => Group(id: index + 1, name: "Group ${index + 1}"),
  );

  return groups;
}

Future<List<Link>> fetchBookmarks() async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 3));

  // Generate dummy data
  final List<Link> bookmarks = List.generate(
    10,
    (index) => Link(
        sender: "Sender B",
        title: "Link ${index + 1}",
        time: DateTime.now()
    ),
  );

  return bookmarks;
}

Future<List<Link>> fetchLinks(int GroupID) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 3));

  // Generate dummy data
  final List<Link> links = List.generate(
    10,
    (index) => Link(
        sender: "Sender $GroupID",
        title: "Link ${index + 1}",
        time: DateTime.now()
    ),
  );

  return links;
}