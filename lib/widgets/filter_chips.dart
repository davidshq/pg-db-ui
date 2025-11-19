import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../models/author.dart';
import '../models/subject.dart';
import '../models/bookshelf.dart';

/// Filter chips widget for displaying and managing filters
class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, _) {
        if (!filterProvider.hasActiveFilters) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (filterProvider.selectedAuthorId != null)
                _FilterChip(
                  label: _getAuthorName(
                    filterProvider.selectedAuthorId!,
                    filterProvider.authors,
                  ),
                  onRemove: () => filterProvider.setAuthorFilter(null),
                ),
              if (filterProvider.selectedSubjectId != null)
                _FilterChip(
                  label: _getSubjectName(
                    filterProvider.selectedSubjectId!,
                    filterProvider.subjects,
                  ),
                  onRemove: () => filterProvider.setSubjectFilter(null),
                ),
              if (filterProvider.selectedBookshelfId != null)
                _FilterChip(
                  label: _getBookshelfName(
                    filterProvider.selectedBookshelfId!,
                    filterProvider.bookshelves,
                  ),
                  onRemove: () => filterProvider.setBookshelfFilter(null),
                ),
              if (filterProvider.selectedLanguage != null &&
                  filterProvider.selectedLanguage!.isNotEmpty)
                _FilterChip(
                  label: filterProvider.selectedLanguage!.toUpperCase(),
                  onRemove: () => filterProvider.setLanguageFilter(null),
                ),
              if (filterProvider.hasActiveFilters)
                TextButton.icon(
                  onPressed: filterProvider.clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear all'),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getAuthorName(int id, List<Author> authors) {
    final author = authors.firstWhere(
      (a) => a.id == id,
      orElse: () => Author(id: id, name: 'Unknown'),
    );
    return author.displayName;
  }

  String _getSubjectName(int id, List<Subject> subjects) {
    final subject = subjects.firstWhere(
      (s) => s.id == id,
      orElse: () => Subject(id: id, subject: 'Unknown'),
    );
    return subject.subject;
  }

  String _getBookshelfName(int id, List<Bookshelf> bookshelves) {
    final bookshelf = bookshelves.firstWhere(
      (b) => b.id == id,
      orElse: () => Bookshelf(id: id, bookshelf: 'Unknown'),
    );
    return bookshelf.bookshelf;
  }
}

/// Individual filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onRemove,
        backgroundColor: theme.colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

