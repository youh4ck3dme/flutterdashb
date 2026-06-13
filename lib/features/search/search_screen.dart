import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data_provider.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../bugs/bug_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<dynamic> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_query.isEmpty || _query.length < 2) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    
    // Search with debounce
    Future.delayed(const Duration(milliseconds: 300), () {
      final bugs = dataProvider.bugs.where((bug) {
        return bug.title.toLowerCase().contains(_query.toLowerCase()) ||
               bug.description.toLowerCase().contains(_query.toLowerCase()) ||
               bug.trackingId.toLowerCase().contains(_query.toLowerCase()) ||
               (bug.projectId?.toLowerCase().contains(_query.toLowerCase()) ?? false);
      }).toList();

      final projects = dataProvider.projects.where((project) {
        return project.name.toLowerCase().contains(_query.toLowerCase()) ||
               (project.description?.toLowerCase().contains(_query.toLowerCase()) ?? false);
      }).toList();

      // Sort by relevance (exact match first)
      bugs.sort((a, b) {
        final aTitle = a.title.toLowerCase();
        final bTitle = b.title.toLowerCase();
        final query = _query.toLowerCase();
        
        final aStartsWith = aTitle.startsWith(query);
        final bStartsWith = bTitle.startsWith(query);
        
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;
        
        final aContains = aTitle.contains(query);
        final bContains = bTitle.contains(query);
        
        if (aContains && !bContains) return -1;
        if (!aContains && bContains) return 1;
        
        return aTitle.compareTo(bTitle);
      });

      setState(() {
        _results = [...bugs, ...projects];
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Vyhľadaj...',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              prefixIcon: Icon(LucideIcons.search, color: Colors.white54, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: Colors.white70, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _results = [];
                          _query = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(color: Colors.white, fontSize: 15),
            onChanged: (value) {
              if (value.length >= 2 || value.isEmpty) {
                _performSearch();
              }
            },
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        actions: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: _query.isEmpty && !_isSearching
          ? _buildEmptyState()
          : _results.isEmpty && !_isSearching
              ? _buildNoResultsState()
              : _buildResultsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.search,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            'Zadajte vyhľadávaný výraz',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white38,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nájsť môžete chyby, projekty a ďalšie polia',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.xCircle,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            'Žiadne výsledky pre "$_query"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Skúste iný vyhľadávaný výraz',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        
        if (item is Bug) {
          return _buildBugResult(item);
        } else if (item is Project) {
          return _buildProjectResult(item);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBugResult(Bug bug) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final projectName = bug.projectId != null
        ? dataProvider.projects
            .firstWhere(
              (p) => p.id == bug.projectId,
              orElse: () => Project(id: '', name: 'Unknown', createdAt: DateTime.now(), updatedAt: DateTime.now()),
            )
            .name
        : 'No Project';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BugDetailScreen(bugId: bug.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.glassDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bug.trackingId,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bug.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              bug.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (AppTheme.severityColors[bug.severity] ?? AppTheme.error).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (AppTheme.severityColors[bug.severity] ?? AppTheme.error).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    AppTheme.severityLabels[bug.severity] ?? bug.severity,
                    style: TextStyle(
                      color: AppTheme.severityColors[bug.severity] ?? AppTheme.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (AppTheme.statusColors[bug.status] ?? AppTheme.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (AppTheme.statusColors[bug.status] ?? AppTheme.primary).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    AppTheme.statusLabels[bug.status] ?? bug.status,
                    style: TextStyle(
                      color: AppTheme.statusColors[bug.status] ?? AppTheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (projectName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      projectName,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectResult(Project project) {
    return InkWell(
      onTap: () {
        // Could navigate to project detail if implemented
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.glassDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.folder,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (project.description != null && project.description!.isNotEmpty)
              Text(
                project.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Text(
              'Vytvorené: ${project.createdAt.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
