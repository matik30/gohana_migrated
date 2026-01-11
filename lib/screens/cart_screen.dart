import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/fonts.dart';
import 'package:gohana_migrated/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'dart:convert';

/// Hlavná obrazovka nákupného košíka s navigáciou a možnosťou prepínať medzi záložkami.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 1; // Aktuálne vybraná záložka (1 = Cart)

  // Zoznam obrazoviek v navigácii (prvá je placeholder pre Recipes)
  final List<Widget> _screens = const [
    SizedBox.shrink(), // placeholder for Recipes tab
    CartTab(),
  ];

  /// Prepína záložky v spodnej navigácii
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  void initState() {
    super.initState();
    Hive.openBox<String>('cart'); // Otvorí box pre nákupný zoznam
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bg = themeNotifier.bgColor;
    final accent = themeNotifier.accentColor;
    final accentSoft = themeNotifier.accentSoftColor;
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: bg,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Recipes'),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        shape: CircleBorder(side: BorderSide(color: accent, width: 2)),
        backgroundColor: accentSoft,
        foregroundColor: accent,
        child: const Icon(Icons.add, weight: 400),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// Záložka s obsahom nákupného košíka a možnosťami exportu, zdieľania a mazania
class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bg = themeNotifier.bgColor;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: SafeArea(
          top: true,
          bottom: false,
          child: AppBar(
            backgroundColor: bg,
            elevation: 0,
            centerTitle: true,
            titleSpacing: 0,
            toolbarHeight: 48,
            title: Text(
              'Cart',
              style: AppTextStyles.heading1(context, themeNotifier),
            ),
            leading: Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, _) {
                return PopupMenuButton<int>(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  color: themeNotifier.panelColor,
                  onSelected: (value) async {
                    if (value == 4) {
                      final panel = themeNotifier.panelColor;
                      final accent = themeNotifier.accentColor;
                      final small = themeNotifier.smallColor;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => Dialog(
                          backgroundColor: panel,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                            side: BorderSide(
                              color: accent.withValues(alpha: .5),
                              width: 3,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delete All Items',
                                  style: AppTextStyles.heading2(context, themeNotifier),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Are you sure you want to delete all items from your cart? This action cannot be undone.',
                                  style: AppTextStyles.body(context, themeNotifier),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: small,
                                        textStyle: AppTextStyles.small(context, themeNotifier),
                                      ),
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: accent,
                                        textStyle: AppTextStyles.smallAccent(context, themeNotifier),
                                      ),
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      if (confirmed == true) {
                        final box = await Hive.openBox<String>('cart');
                        final checkedBox = await Hive.openBox<bool>('cart_checked');
                        await box.clear();
                        await checkedBox.clear();
                        setState(() {});
                      }
                      return;
                    }
                    setState(() {}); // refresh after menu actions
                    switch (value) {
                      case 0:
                        final panel = themeNotifier.panelColor;
                        final accent = themeNotifier.accentColor;
                        String newItem = '';
                        await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              backgroundColor: panel,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                                side: BorderSide(color: accent.withValues(alpha: .5), width: 3),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Add Item', style: AppTextStyles.heading2(context, themeNotifier)),
                                    const SizedBox(height: 16),
                                    TextField(
                                      autofocus: true,
                                      style: AppTextStyles.body(context, themeNotifier),
                                      decoration: InputDecoration(
                                        hintText: 'Enter item',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        filled: true,
                                        fillColor: themeNotifier.bgColor,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: accent, width: 2),
                                        ),
                                      ),
                                      onChanged: (val) => newItem = val,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: accent,
                                            textStyle: AppTextStyles.smallText(context, themeNotifier),
                                          ),
                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: accent,
                                            textStyle: AppTextStyles.smallText(context, themeNotifier),
                                          ),
                                          onPressed: () async {
                                            if (newItem.trim().isNotEmpty) {
                                              final box = await Hive.openBox<String>('cart');
                                              if (!box.values.contains(newItem.trim())) {
                                                await box.add(newItem.trim());
                                              }
                                              if ((dialogContext.mounted)) {
                                                Navigator.of(dialogContext).pop();
                                              }
                                              if (mounted) {
                                                setState(() {});
                                              }
                                            }
                                          },
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        break;
                      case 1:
                        // Download cartlist
                        final box = await Hive.openBox<String>('cart');
                        final checkedBox = await Hive.openBox<bool>('cart_checked');
                        final items = <String>[];
                        for (int i = 0; i < box.length; i++) {
                          final key = box.keyAt(i);
                          final checked = checkedBox.get(key, defaultValue: false) ?? false;
                          if (!checked) {
                            items.add(box.get(key)!);
                          }
                        }
                        if (items.isEmpty) return;
                        final pdf = pw.Document();
                        pdf.addPage(
                          pw.Page(
                            build: (pw.Context context) => pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Shopping List', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 16),
                                ...items.map((item) => pw.Bullet(text: item)),
                              ],
                            ),
                          ),
                        );
                        final bytes = await pdf.save();
                        if (!mounted) return;
                        await FileSaver.instance.saveAs(
                          name: 'Shopping_List',
                          bytes: bytes,
                          fileExtension: 'pdf',
                          mimeType: MimeType.pdf,
                        );
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Shopping list saved as PDF.')),
                        );
                        break;
                      case 2:
                        // Send cartlist
                        final box = await Hive.openBox<String>('cart');
                        final checkedBox = await Hive.openBox<bool>('cart_checked');
                        final items = <String>[];
                        for (int i = 0; i < box.length; i++) {
                          final key = box.keyAt(i);
                          final checked = checkedBox.get(key, defaultValue: false) ?? false;
                          if (!checked) {
                            items.add(box.get(key)!);
                          }
                        }
                        if (items.isEmpty) return;
                        final pdf = pw.Document();
                        pdf.addPage(
                          pw.Page(
                            build: (pw.Context context) => pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Shopping List', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 16),
                                ...items.map((item) => pw.Bullet(text: item)),
                              ],
                            ),
                          ),
                        );
                        final bytes = await pdf.save();
                        final tempDir = await getTemporaryDirectory();
                        final filePath = '${tempDir.path}/shopping_list.pdf';
                        final file = File(filePath);
                        await file.writeAsBytes(bytes);
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(file.path)],
                            text: 'Gohana Shopping List',
                          ),
                        );
                        break;
                      case 3:
                        // Share list
                        final box = await Hive.openBox<String>('cart');
                        final checkedBox = await Hive.openBox<bool>('cart_checked');
                        final items = <Map<String, dynamic>>[];
                        for (int i = 0; i < box.length; i++) {
                          final key = box.keyAt(i);
                          final value = box.get(key);
                          final checked = checkedBox.get(key, defaultValue: false) ?? false;
                          if (value != null) {
                            items.add({'item': value, 'checked': checked});
                          }
                        }
                        if (items.isEmpty) return;
                        final json = jsonEncode({'cart': items});
                        final tempDir = await getTemporaryDirectory();
                        final jsonFile = File('${tempDir.path}/cart.json');
                        await jsonFile.writeAsString(json);
                        final zipFile = File('${tempDir.path}/cart.gohana');
                        final archive = Archive();
                        archive.addFile(ArchiveFile('cart.json', json.length, utf8.encode(json)));
                        final zipped = ZipEncoder().encode(archive);
                        await zipFile.writeAsBytes(zipped);
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(zipFile.path)],
                            text: 'Gohana Shopping List',
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.add, color: themeNotifier.textColor),
                          const SizedBox(width: 10),
                          Text(
                            'Add item',
                            style: AppTextStyles.smallText(context, themeNotifier),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.download, color: themeNotifier.textColor),
                          const SizedBox(width: 10),
                          Text(
                            'Download',
                            style: AppTextStyles.smallText(context, themeNotifier),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.share, color: themeNotifier.textColor),
                          const SizedBox(width: 10),
                          Text(
                            'Send',
                            style: AppTextStyles.smallText(context, themeNotifier),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(Icons.group, color: themeNotifier.textColor),
                          const SizedBox(width: 10),
                          Text(
                            'Share list',
                            style: AppTextStyles.smallText(context, themeNotifier),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: themeNotifier.textColor),
                          const SizedBox(width: 10),
                          Text(
                            'Delete all',
                            style: AppTextStyles.smallText(context, themeNotifier),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      themeNotifier.isDark
                        ? 'assets/images/GohanaDark.png'
                        : 'assets/images/Gohana.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(color: themeNotifier.accentColor.withValues(alpha: 0.5), width: 4),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: FutureBuilder<List<Box>>(
          future: Future.wait([
            Hive.openBox<String>('cart'),
            Hive.openBox<bool>('cart_checked'),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final box = snapshot.data![0] as Box<String>;
            final checkedBox = snapshot.data![1] as Box<bool>;
            final items = box.values.toList();
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'Your shopping list is empty.',
                  style: AppTextStyles.body(context, themeNotifier),
                ),
              );
            }
            final checkedStates = List<bool>.generate(items.length, (i) {
              final key = box.keyAt(i);
              return checkedBox.get(key, defaultValue: false) ?? false;
            });
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: ListView.builder(
                key: ValueKey(checkedStates.hashCode),
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                itemCount: items.length + 1, // +1 for separator
                itemBuilder: (context, index) {
                  // Find checked and unchecked indices
                  final unchecked = <int>[];
                  final checked = <int>[];
                  for (int i = 0; i < items.length; i++) {
                    if (!checkedStates[i]) {
                      unchecked.add(i);
                    } else {
                      checked.add(i);
                    }
                  }
                  // Separator index
                  final separatorIndex = unchecked.length;
                  if (index == separatorIndex) {
                    // Render separator only if there are checked items
                    return checked.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Divider(thickness: 2, color: themeNotifier.accentColor.withValues(alpha: 0.3)),
                          )
                        : const SizedBox.shrink();
                  }
                  // Map index to real item
                  int realIndex;
                  if (index < separatorIndex) {
                    realIndex = unchecked[index];
                  } else {
                    realIndex = checked[index - separatorIndex - 1];
                  }
                  final item = items[realIndex];
                  final itemKey = box.keyAt(realIndex);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: themeNotifier.bgColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -4.0,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: themeNotifier.textColor,
                        checkColor: themeNotifier.bgColor,
                        title: Text(
                          item,
                          style: AppTextStyles.smallText(context, themeNotifier),
                        ),
                        value: checkedStates[realIndex],
                        onChanged: (v) async {
                          await checkedBox.put(itemKey, v ?? false);
                          setState(() {}); // refresh whole list
                        },
                        secondary: IconButton(
                          icon: Icon(Icons.delete, color: themeNotifier.accentColor),
                          onPressed: () async {
                            await box.delete(itemKey);
                            await checkedBox.delete(itemKey);
                            setState(() {}); // refresh whole list
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// Import logic (to be called when opening a .gohana file)
Future<void> importCartFromGohanaZip(String zipPath) async {
  final bytes = await File(zipPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  final cartEntry = archive.findFile('cart.json');
  if (cartEntry == null) return;
  final jsonStr = utf8.decode(cartEntry.content as List<int>);
  final data = jsonDecode(jsonStr);
  final items = data['cart'] as List<dynamic>;
  final box = await Hive.openBox<String>('cart');
  final checkedBox = await Hive.openBox<bool>('cart_checked');
  for (final entry in items) {
    final item = entry['item'] as String;
    final checked = entry['checked'] as bool;
    if (!box.values.contains(item)) {
      final key = await box.add(item);
      await checkedBox.put(key, checked);
    }
  }
}
