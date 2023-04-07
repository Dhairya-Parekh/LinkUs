import 'package:flutter/material.dart';
import 'package:linkus/Helper%20Files/api.dart';

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


class MessagePopUp extends StatefulWidget {
  final int groupId;
  const MessagePopUp({super.key, required this.groupId});

  @override
  State<MessagePopUp> createState() => _MessagePopUpState();
}

class _MessagePopUpState extends State<MessagePopUp> {

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
                    await API.broadcastMessage(0, widget.groupId, link);

                // TODO : Update the localstorage

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Icon(Icons.send),
            ),
          ],
        );
      }
}