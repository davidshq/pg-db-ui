import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/search_provider.dart';
import '../providers/filter_provider.dart';
import '../database/database_service.dart';
import '../widgets/book_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_chips.dart';
import 'book_detail_screen.dart';
import 'filter_screen.dart';

/// Main screen for browsing books
class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeDatabase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Initialize database and load data
  Future<void> _initializeDatabase() async {
    final databaseService = context.read<DatabaseService>();
    final searchProvider = context.read<SearchProvider>();
    final filterProvider = context.read<FilterProvider>();

    // Initialize database
    final initialized = await databaseService.initialize();
    
    if (!initialized && mounted) {
      // Show error dialog
      _showDatabaseErrorDialog();
      return;
    }

    // Set database service references
    searchProvider.setDatabaseService(databaseService);
    filterProvider.setDatabaseService(databaseService);

    // Load initial data
    if (mounted) {
      await context.read<BookProvider>().initialize();
      await filterProvider.loadFilterOptions();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  /// Show database error dialog
  void _showDatabaseErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Not Found'),
        content: const Text(
          'The pg.db database file was not found. Please ensure the database file exists in the expected location or select it manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final searchProvider = context.read<SearchProvider>();
      final filterProvider = context.read<FilterProvider>();
      final bookProvider = context.read<BookProvider>();

      if (searchProvider.hasQuery) {
        searchProvider.loadMore();
      } else if (filterProvider.hasActiveFilters) {
        filterProvider.loadMore();
      } else {
        bookProvider.loadMore();
      }
    }
  }

  /// Get current book list based on active mode
  List<Book> _getCurrentBooks() {
    final searchProvider = context.read<SearchProvider>();
    final filterProvider = context.read<FilterProvider>();
    final bookProvider = context.read<BookProvider>();

    if (searchProvider.hasQuery) {
      return searchProvider.results;
    } else if (filterProvider.hasActiveFilters) {
      return filterProvider.filteredBooks;
    } else {
      return bookProvider.books;
    }
  }

  /// Check if currently loading
  bool _isLoading() {
    final searchProvider = context.read<SearchProvider>();
    final filterProvider = context.read<FilterProvider>();
    final bookProvider = context.read<BookProvider>();

    if (searchProvider.hasQuery) {
      return searchProvider.isSearching;
    } else if (filterProvider.hasActiveFilters) {
      return filterProvider.isLoading;
    } else {
      return bookProvider.isLoading;
    }
  }

  /// Check if has more to load
  bool _hasMore() {
    final searchProvider = context.read<SearchProvider>();
    final filterProvider = context.read<FilterProvider>();
    final bookProvider = context.read<BookProvider>();

    if (searchProvider.hasQuery) {
      return searchProvider.hasMore;
    } else if (filterProvider.hasActiveFilters) {
      return filterProvider.hasMore;
    } else {
      return bookProvider.hasMore;
    }
  }

  /// Check if empty
  bool _isEmpty() {
    final searchProvider = context.read<SearchProvider>();
    final filterProvider = context.read<FilterProvider>();
    final bookProvider = context.read<BookProvider>();

    if (searchProvider.hasQuery) {
      return searchProvider.isEmpty;
    } else if (filterProvider.hasActiveFilters) {
      return filterProvider.isEmpty;
    } else {
      return bookProvider.isEmpty;
    }
  }

  /// Get error message
  String? _getError() {
    final searchProvider = context.read<SearchProvider>();
    final filterProvider = context.read<FilterProvider>();
    final bookProvider = context.read<BookProvider>();

    if (searchProvider.hasQuery) {
      return searchProvider.error;
    } else if (filterProvider.hasActiveFilters) {
      return filterProvider.error;
    } else {
      return bookProvider.error;
    }
  }

  /// Refresh data
  Future<void> _refresh() async {
    final searchProvider = context.read<SearchProvider>();
    final filterProvider = context.read<FilterProvider>();
    final bookProvider = context.read<BookProvider>();

    if (searchProvider.hasQuery) {
      await searchProvider.search(searchProvider.query, refresh: true);
    } else if (filterProvider.hasActiveFilters) {
      await filterProvider.applyFilters(refresh: true);
    } else {
      await bookProvider.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PG DB Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilterScreen(),
                ),
              );
            },
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Consumer<SearchProvider>(
            builder: (context, searchProvider, _) {
              return SearchBarWidget(
                initialValue: searchProvider.query,
                showClearButton: searchProvider.hasQuery,
                onChanged: (value) {
                  searchProvider.updateQuery(value);
                },
                onClear: () {
                  searchProvider.clear();
                },
              );
            },
          ),

          // Filter chips
          const FilterChips(),

          // Book list
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, _) {
                return Consumer<SearchProvider>(
                  builder: (context, searchProvider, _) {
                    return Consumer<FilterProvider>(
                      builder: (context, filterProvider, _) {
                        final books = _getCurrentBooks();
                        final isLoading = _isLoading();
                        final hasMore = _hasMore();
                        final isEmpty = _isEmpty();
                        final error = _getError();

                        if (error != null) {
                          return Center(
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
                                  error,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refresh,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (isEmpty && !isLoading) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchProvider.hasQuery
                                      ? 'No books found'
                                      : filterProvider.hasActiveFilters
                                          ? 'No books match filters'
                                          : 'No books available',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: books.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= books.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final book = books[index];
                              return BookCard(
                                book: book,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookDetailScreen(bookId: book.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

