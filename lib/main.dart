import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrangeAccent),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Item {
  Item({
    required this.name,
    this.isBought = false,
    this.quantity = 1,
    this.category = 'Food',
    this.note = '',
  });

  String name;
  bool isBought;
  int quantity;
  String category;
  String note;
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Item> items = [
    Item(name: 'Milk'),
    Item(name: 'Bread'),
    Item(name: 'Rice'),
  ];
  final controller = TextEditingController();
  String filter = 'All';

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }

    final matches = items.where(
      (item) => item.name.trim().toLowerCase() == text.toLowerCase(),
    );
    if (matches.isNotEmpty) {
      final existing = matches.first;
      setState(() {
        existing.quantity++;
      });
      controller.clear();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${existing.name} is already on the list: now ×${existing.quantity}',
          ),
        ),
      );
      return;
    }

    setState(() {
      items.add(Item(name: text));
    });
    controller.clear();
  }

  void openEditSheet(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditItemBottomSheet(item: item),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Item> shown;
    if (filter == 'All') {
      final notBought = items.where((item) => !item.isBought).toList();
      final bought = items.where((item) => item.isBought).toList();
      shown = [...notBought, ...bought];
    } else if (filter == 'To buy') {
      shown = items.where((item) => !item.isBought).toList();
    } else {
      shown = items.where((item) => item.isBought).toList();
    }

    final Widget content;
    if (items.isEmpty) {
      content = const Center(
        child: Text(
          'Your list is empty',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    } else if (shown.isEmpty) {
      content = const Center(
        child: Text(
          'Nothing here',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    } else {
      content = ListView.builder(
        itemCount: shown.length,
        itemBuilder: (context, index) {
          final item = shown[index];
          return ListTile(
            leading: Checkbox(
              value: item.isBought,
              onChanged: (bool? value) {
                setState(() {
                  item.isBought = value ?? false;
                });
              },
            ),
            title: Text(
              item.name,
              style: TextStyle(
                decoration: item.isBought
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              item.note.isEmpty
                  ? item.category
                  : '${item.category} · ${item.note}',
            ),
            onTap: () => openEditSheet(item),
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(item: item),
                ),
              ).then((_) {
                setState(() {});
              });
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (item.quantity > 1) {
                      setState(() {
                        item.quantity--;
                      });
                    }
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      item.quantity++;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final removedItem = item;
                    final removedIndex = items.indexOf(item);
                    setState(() {
                      items.remove(item);
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${removedItem.name} removed'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            setState(() {
                              final insertIndex =
                                  removedIndex.clamp(0, items.length);
                              items.insert(insertIndex, removedItem);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Add an item'),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'All',
                  onSelected: (_) {
                    setState(() {
                      filter = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: filter == 'To buy',
                  onSelected: (_) {
                    setState(() {
                      filter = 'To buy';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: filter == 'Bought',
                  onSelected: (_) {
                    setState(() {
                      filter = 'Bought';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.item});

  final Item item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController nameController;
  late final TextEditingController noteController;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    noteController = TextEditingController(text: widget.item.note);
    selectedCategory = widget.item.category;
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void save() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    widget.item.name = name;
    widget.item.note = noteController.text.trim();
    widget.item.category = selectedCategory;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'e.g. the 1 litre bottle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Food'),
                  selected: selectedCategory == 'Food',
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = 'Food';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Drinks'),
                  selected: selectedCategory == 'Drinks',
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = 'Drinks';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Home'),
                  selected: selectedCategory == 'Home',
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = 'Home';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditItemBottomSheet extends StatefulWidget {
  const EditItemBottomSheet({super.key, required this.item});

  final Item item;

  @override
  State<EditItemBottomSheet> createState() => _EditItemBottomSheetState();
}

class _EditItemBottomSheetState extends State<EditItemBottomSheet> {
  late final TextEditingController nameController;
  late final TextEditingController noteController;
  late String selectedCategory;
  late bool isBought;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    noteController = TextEditingController(text: widget.item.note);
    selectedCategory = widget.item.category;
    isBought = widget.item.isBought;
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void save() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    widget.item.name = name;
    widget.item.note = noteController.text.trim();
    widget.item.category = selectedCategory;
    widget.item.isBought = isBought;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'e.g. the 1 litre bottle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Food'),
                  selected: selectedCategory == 'Food',
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = 'Food';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Drinks'),
                  selected: selectedCategory == 'Drinks',
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = 'Drinks';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Home'),
                  selected: selectedCategory == 'Home',
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = 'Home';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mark as bought'),
              value: isBought,
              onChanged: (val) {
                setState(() {
                  isBought = val;
                });
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.check),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}