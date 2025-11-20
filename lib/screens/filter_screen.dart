import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';

/// Screen for managing filters
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  void initState() {
    super.initState();
    // Load filter options if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilterProvider>().loadFilterOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<FilterProvider>().clearFilters();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Consumer<FilterProvider>(
        builder: (context, filterProvider, _) {
          if (!filterProvider.optionsLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Author filter
              _FilterSection(
                title: 'Author',
                selectedId: filterProvider.selectedAuthorId,
                items: filterProvider.authors
                    .map((a) => _FilterItem(
                          id: a.id,
                          name: a.displayName,
                        ))
                    .toList(),
                onSelected: (id) => filterProvider.setAuthorFilter(id),
                onCleared: () => filterProvider.setAuthorFilter(null),
              ),

              const SizedBox(height: 24),

              // Subject filter
              _FilterSection(
                title: 'Subject',
                selectedId: filterProvider.selectedSubjectId,
                items: filterProvider.subjects
                    .map((s) => _FilterItem(
                          id: s.id,
                          name: s.subject,
                        ))
                    .toList(),
                onSelected: (id) => filterProvider.setSubjectFilter(id),
                onCleared: () => filterProvider.setSubjectFilter(null),
              ),

              const SizedBox(height: 24),

              // Bookshelf filter
              _FilterSection(
                title: 'Bookshelf',
                selectedId: filterProvider.selectedBookshelfId,
                items: filterProvider.bookshelves
                    .map((b) => _FilterItem(
                          id: b.id,
                          name: b.bookshelf,
                        ))
                    .toList(),
                onSelected: (id) => filterProvider.setBookshelfFilter(id),
                onCleared: () => filterProvider.setBookshelfFilter(null),
              ),

              const SizedBox(height: 24),

              // Language filter
              _FilterSection(
                title: 'Language',
                selectedId: filterProvider.selectedLanguage,
                items: filterProvider.languages
                    .map((lang) => _FilterItem(
                          id: lang,
                          name: lang.toUpperCase(),
                        ))
                    .toList(),
                onSelected: (id) => filterProvider.setLanguageFilter(id as String?),
                onCleared: () => filterProvider.setLanguageFilter(null),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Filter section widget
class _FilterSection extends StatelessWidget {
  final String title;
  final dynamic selectedId;
  final List<_FilterItem> items;
  final ValueChanged<dynamic> onSelected;
  final VoidCallback onCleared;

  const _FilterSection({
    required this.title,
    required this.selectedId,
    required this.items,
    required this.onSelected,
    required this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            if (selectedId != null)
              TextButton(
                onPressed: onCleared,
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: RadioGroup<dynamic>(
            groupValue: selectedId,
            onChanged: (value) {
              if (value != null) {
                onSelected(value);
              }
            },
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return RadioListTile<dynamic>(
                  title: Text(item.name),
                  value: item.id,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Filter item model
class _FilterItem {
  final dynamic id;
  final String name;

  _FilterItem({
    required this.id,
    required this.name,
  });
}

