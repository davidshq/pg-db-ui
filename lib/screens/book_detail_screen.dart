import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../database/database_service.dart';
import '../models/format.dart';
import '../utils/error_messages.dart';

/// Screen for displaying detailed book information
class BookDetailScreen extends StatefulWidget {
  final int bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _book;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  /// Load book details
  Future<void> _loadBook() async {
    try {
      final databaseService = context.read<DatabaseService>();
      if (!databaseService.isInitialized) {
        setState(() {
          _error = ErrorMessages.databaseNotInitialized;
          _isLoading = false;
        });
        return;
      }

      final book = await databaseService.getBookById(widget.bookId);
      setState(() {
        _book = book;
        _isLoading = false;
        if (book == null) {
          _error = ErrorMessages.bookNotFound;
        }
      });
    } catch (e) {
      setState(() {
        _error = ErrorMessages.failedToLoadBook;
        debugPrint(ErrorMessages.forLogging(ErrorMessages.failedToLoadBook, e));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Book Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _book == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Book Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? ErrorMessages.bookNotFound,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBook,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _book!.displayTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Gutenberg ID
            Text(
              'Gutenberg ID: ${_book!.gutenbergId}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 24),

            // Authors
            if (_book!.authors.isNotEmpty) ...[
              const _SectionTitle('Authors'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _book!.authors.map((author) {
                  return Chip(
                    label: Text(author.displayName),
                    avatar: const Icon(Icons.person, size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Metadata
            const _SectionTitle('Information'),
            const SizedBox(height: 8),
            _InfoRow('Language', _book!.language?.toUpperCase() ?? 'Unknown'),
            _InfoRow('Downloads', _book!.formattedDownloadCount),
            if (_book!.issuedDate != null)
              _InfoRow('Issued Date', _book!.issuedDate!),
            if (_book!.publisher != null)
              _InfoRow('Publisher', _book!.publisher!),
            if (_book!.license != null) _InfoRow('License', _book!.license!),
            const SizedBox(height: 24),

            // Description
            if (_book!.description != null) ...[
              const _SectionTitle('Description'),
              const SizedBox(height: 8),
              Text(
                _book!.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],

            // Summary
            if (_book!.summary != null) ...[
              const _SectionTitle('Summary'),
              const SizedBox(height: 8),
              Text(
                _book!.summary!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],

            // Subjects
            if (_book!.subjects.isNotEmpty) ...[
              const _SectionTitle('Subjects'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _book!.subjects.map((subject) {
                  return Chip(
                    label: Text(subject),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Bookshelves
            if (_book!.bookshelves.isNotEmpty) ...[
              const _SectionTitle('Bookshelves'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _book!.bookshelves.map((bookshelf) {
                  return Chip(
                    label: Text(bookshelf),
                    avatar: const Icon(Icons.library_books, size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Formats
            if (_book!.formats.isNotEmpty) ...[
              const _SectionTitle('Available Formats'),
              const SizedBox(height: 8),
              ..._book!.formats.map((format) {
                return _FormatCard(format: format);
              }),
              const SizedBox(height: 24),
            ],

            // Production Notes
            if (_book!.productionNotes != null) ...[
              const _SectionTitle('Production Notes'),
              const SizedBox(height: 8),
              Text(
                _book!.productionNotes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
            ],

            // Reading Ease Score
            if (_book!.readingEaseScore != null) ...[
              const _SectionTitle('Reading Ease Score'),
              const SizedBox(height: 8),
              Text(
                _book!.readingEaseScore!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Format card widget
class _FormatCard extends StatelessWidget {
  final Format format;

  const _FormatCard({required this.format});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file),
        title: Text(format.displayType),
        subtitle: format.formattedFileSize != null
            ? Text(format.formattedFileSize!)
            : null,
        trailing: format.fileUrl != null
            ? IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  // In a real app, this would open the URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('URL: ${format.fileUrl}'),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}

