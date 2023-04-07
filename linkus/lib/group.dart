import 'package:flutter/material.dart';
import 'package:linkus/Common%20Widgets/link_list.dart';
import 'package:linkus/Common%20Widgets/loading.dart';
import 'package:linkus/Helper%20Files/db.dart';
import 'package:linkus/Helper%20Files/api.dart';
import 'package:linkus/groupinfo.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class Tech {
  String label;
  Color color;
  bool isSelected;
  Tech(this.label, this.color, this.isSelected);
}

class TechChips extends StatefulWidget {
  final List<Tech> techList;
  final Function(Tech tech) onSelected;
  const TechChips({Key? key, required this.techList, required this.onSelected})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TechChipsState createState() => _TechChipsState();
}

class _TechChipsState extends State<TechChips> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.techList.map((tech) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 5),
          child: FilterChip(
            label: Text(tech.label),
            labelStyle: const TextStyle(color: Colors.white),
            backgroundColor: tech.color,
            selected: tech.isSelected,
            onSelected: (bool value) {
              setState(() {
                tech.isSelected = value;
              });
              widget.onSelected(tech);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _GroupPageState extends State<GroupPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Tech> _tags = [
    Tech("Fiction", Colors.brown, false),
    Tech("Novel", Colors.deepPurple, false),
    Tech("Science Fiction", Colors.red, false),
    Tech("Non-fiction", Colors.cyan, false),
    Tech("Mystery", Colors.black54, false),
    Tech("Genre Fiction", Colors.blueAccent, false),
    Tech("Historical Fiction", Colors.lightGreen, false)
  ];

  List<Link> _links = [];
  bool _areLinksLoading = true;

  Future<void> _loadLinks() async {
    final links = await LocalDatabase.fetchLinks(widget.group.id);
    setState(() {
      _links = links;
      _areLinksLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  List<Widget> techChips() {
    return [
      const Text('Tags:'),
      TechChips(
        techList: _tags,
        onSelected: (tech) {
          setState(() {});
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat'),
        actions: [
          IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                // navigate to group info page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupInfoPage(group: widget.group)),
                );
              }),
        ],
      ),
      body: _areLinksLoading ? const Loading() : LinkList(links: _links),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Link'),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _linkController,
                          decoration: const InputDecoration(
                            hintText: 'Link',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: techChips(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Description',
                          ),
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  FloatingActionButton(
                    onPressed: () async {
                      // Add link to database

                      final title = _titleController.text.trim();
                      final description = _descriptionController.text.trim();
                      final linkUrl = _linkController.text.trim();
                      final selectedTags = _tags
                          .where((tag) => tag.isSelected)
                          .map((tag) => tag.label)
                          .toList();

                      final link = {
                        "title": title,
                        "link": linkUrl,
                        "info": description,
                        "tags": selectedTags,
                      };

                      final jsonResponse =
                          await API.broadcastMessage(0, widget.group.id, link);

                      // TODO : Update the localstorage

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
