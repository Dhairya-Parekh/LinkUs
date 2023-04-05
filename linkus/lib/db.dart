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

Future<List<Group>> fetchGroups() async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 3));

  // Generate dummy data
  final List<Group> groups = List.generate(
    10,
    (index) => Group(id: index + 1, name: "Group ${index + 1}"),
  );

  return groups;
}

Future<List<String>> fetchBookmarks() async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 3));

  // Generate dummy data
  final List<String> bookmarks = List.generate(
    10,
    (index) => "Bookmark ${index + 1}",
  );

  return bookmarks;
}