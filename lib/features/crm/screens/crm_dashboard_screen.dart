import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme.dart';
import '../models/crm_models.dart';
import '../providers/crm_provider.dart';
import 'crm_client_dialog.dart';

class CrmDashboardScreen extends StatefulWidget {
  const CrmDashboardScreen({super.key});

  @override
  State<CrmDashboardScreen> createState() => _CrmDashboardScreenState();
}

class _CrmDashboardScreenState extends State<CrmDashboardScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'lead', 'active', 'inactive'
  CrmClient? _selectedClient;
  List<CrmClientActivity> _activities = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();

  String _newActivityType = 'note'; // 'note', 'call', 'email', 'meeting'

  @override
  void dispose() {
    _searchController.dispose();
    _taskController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities(String clientId) async {
    final crmProvider = Provider.of<CrmProvider>(context, listen: false);
    final acts = await crmProvider.getActivitiesForClient(clientId);
    setState(() {
      _activities = acts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  @override
  Widget build(BuildContext context) {
    final crmProvider = Provider.of<CrmProvider>(context);
    final allClients = crmProvider.clients
        .where((c) => c.deletedAt == null)
        .toList();

    // Filtered clients list
    final filteredClients = allClients.where((c) {
      final query = _searchQuery.toLowerCase();
      final matchQuery =
          c.companyName.toLowerCase().contains(query) ||
          (c.contactName?.toLowerCase().contains(query) ?? false) ||
          (c.email?.toLowerCase().contains(query) ?? false);

      final matchStatus = _statusFilter == 'all' || c.status == _statusFilter;

      return matchQuery && matchStatus;
    }).toList();

    // Ensure currently selected client stays updated in detail pane if modified in list
    if (_selectedClient != null) {
      final updated = allClients.firstWhere(
        (c) => c.id == _selectedClient!.id,
        orElse: () => _selectedClient!,
      );
      if (updated != _selectedClient) {
        _selectedClient = updated;
      }
    }

    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Master List View
          Expanded(
            flex: isLargeScreen ? 6 : 10,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, crmProvider),
                  const SizedBox(height: 24),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: crmProvider.loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                            ),
                          )
                        : filteredClients.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: filteredClients.length,
                            itemBuilder: (context, index) {
                              final client = filteredClients[index];
                              final isSelected =
                                  _selectedClient?.id == client.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildClientCard(
                                  client,
                                  isSelected,
                                  crmProvider,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Detail Pane View (For Desktop)
          if (isLargeScreen && _selectedClient != null)
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F0F12),
                  border: Border(
                    left: BorderSide(color: AppTheme.border, width: 1),
                  ),
                ),
                child: _buildDetailPane(crmProvider),
              ),
            ),
        ],
      ),
      // Slide-in bottom drawer detail view for mobile/tablet screens
      bottomSheet: (!isLargeScreen && _selectedClient != null)
          ? Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F12),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  Expanded(child: _buildDetailPane(crmProvider)),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, CrmProvider crmProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CRM',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Offline-first správa klientov a úloh (${crmProvider.clients.where((c) => c.deletedAt == null).length})',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          key: const Key('add_client_button'),
          onPressed: () => _openCreateClientDialog(crmProvider),
          icon: const Icon(LucideIcons.userPlus, size: 16),
          label: const Text('Pridať klienta'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Input
        TextField(
          controller: _searchController,
          key: const Key('crm_search_input'),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Hľadať podľa názvu, emailu alebo kontaktu...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            prefixIcon: const Icon(
              LucideIcons.search,
              color: AppTheme.textSecondary,
              size: 18,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Status Filter Chips
        Row(
          children: [
            _buildFilterChip('all', 'Všetci'),
            const SizedBox(width: 8),
            _buildFilterChip('lead', 'Leads', color: Colors.blue),
            const SizedBox(width: 8),
            _buildFilterChip('active', 'Aktívni', color: AppTheme.success),
            const SizedBox(width: 8),
            _buildFilterChip(
              'inactive',
              'Neaktívni',
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterVal, String label, {Color? color}) {
    final isSelected = _statusFilter == filterVal;
    return ChoiceChip(
      key: Key('filter_chip_$filterVal'),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primary.withOpacity(0.3),
      backgroundColor: Colors.white.withOpacity(0.02),
      onSelected: (val) {
        if (val) {
          setState(() {
            _statusFilter = filterVal;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users,
            size: 48,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _statusFilter != 'all'
                ? 'Nenašli sa žiadni vyhovujúci klienti'
                : 'Žiadni CRM klienti v systéme',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(
    CrmClient client,
    bool isSelected,
    CrmProvider crmProvider,
  ) {
    // Task Completion Progress calculations
    final totalTasks = client.tasks.length;
    final doneTasks = client.tasks.where((t) => t.done).length;
    final progress = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

    Color statusColor = AppTheme.textSecondary;
    String statusLabel = 'Neaktívny';
    if (client.status == 'lead') {
      statusColor = Colors.blue;
      statusLabel = 'Lead';
    } else if (client.status == 'active') {
      statusColor = AppTheme.success;
      statusLabel = 'Aktívny';
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedClient = client;
        });
        _loadActivities(client.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: isSelected
            ? AppTheme.activeGlassDecoration(borderRadius: 12)
            : AppTheme.glassDecoration(
                borderRadius: 12,
                borderColor: Colors.white.withOpacity(0.05),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    client.companyName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (client.service.isNotEmpty) ...[
                  Text(
                    client.service,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Colors.white24)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    client.contactName ?? 'Bez kontaktnej osoby',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Task progress bar
            if (totalTasks > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Úlohy: $doneTasks/$totalTasks',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white10,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPane(CrmProvider crmProvider) {
    final client = _selectedClient;
    if (client == null) return const SizedBox.shrink();

    // Stats
    final totalTasks = client.tasks.length;
    final doneTasks = client.tasks.where((t) => t.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Detail Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Karta Klienta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.edit,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    tooltip: 'Upraviť',
                    onPressed: () => _openEditClientDialog(client, crmProvider),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: AppTheme.error,
                    ),
                    tooltip: 'Vymazať',
                    onPressed: () => _confirmDeleteClient(client, crmProvider),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedClient = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),

        // Scrollable Details
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Client Core Info Card
              _buildSectionTitle('ZÁKLADNÉ ÚDAJE'),
              const SizedBox(height: 12),
              _buildDetailInfoTile(
                LucideIcons.home,
                'Firma',
                client.companyName,
              ),
              if (client.contactName != null)
                _buildDetailInfoTile(
                  LucideIcons.user,
                  'Kontakt',
                  client.contactName!,
                ),
              if (client.email != null)
                _buildDetailInfoTile(LucideIcons.mail, 'E-mail', client.email!),
              if (client.phone != null)
                _buildDetailInfoTile(
                  LucideIcons.phone,
                  'Telefón',
                  client.phone!,
                ),
              if (client.website != null)
                _buildDetailInfoTile(LucideIcons.globe, 'Web', client.website!),
              if (client.budget != null)
                _buildDetailInfoTile(
                  LucideIcons.dollarSign,
                  'Rozpočet',
                  '${client.budget} €',
                ),
              if (client.notes != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Poznámky:',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    client.notes!,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Checklist Section
              _buildSectionTitle('CHECKLIST ÚLOH ($doneTasks/$totalTasks)'),
              const SizedBox(height: 12),
              _buildTaskInputWidget(client.id, crmProvider),
              const SizedBox(height: 8),
              if (client.tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Žiadne úlohy pre tohto klienta.',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                )
              else
                ...client.tasks.map(
                  (task) => _buildTaskItem(client.id, task, crmProvider),
                ),

              const SizedBox(height: 24),

              // Activity Timeline Section
              _buildSectionTitle('ČASOVÁ OS AKTIVÍT'),
              const SizedBox(height: 12),
              _buildActivityLoggerWidget(client.id, crmProvider),
              const SizedBox(height: 16),
              if (_activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Žiadne zaznamenané aktivity.',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activities.length,
                  itemBuilder: (context, idx) {
                    return _buildActivityTimelineTile(_activities[idx]);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDetailInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tasks checklist widgets ---
  Widget _buildTaskInputWidget(String clientId, CrmProvider crmProvider) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _taskController,
            key: const Key('add_task_input'),
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Pridať novú úlohu...',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const Key('add_task_submit'),
          icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 24),
          onPressed: () async {
            final txt = _taskController.text.trim();
            if (txt.isNotEmpty) {
              await crmProvider.addTask(clientId, txt, null);
              _taskController.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _buildTaskItem(
    String clientId,
    CrmClientTask task,
    CrmProvider crmProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: task.done,
            activeColor: AppTheme.success,
            onChanged: (val) {
              if (val != null) {
                crmProvider.updateTask(clientId, task.id, done: val);
              }
            },
          ),
          Expanded(
            child: Text(
              task.text,
              style: TextStyle(
                color: task.done
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                fontSize: 13,
                decoration: task.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.error,
              size: 18,
            ),
            onPressed: () => crmProvider.deleteTask(clientId, task.id),
          ),
        ],
      ),
    );
  }

  // --- Activities widgets ---
  Widget _buildActivityLoggerWidget(String clientId, CrmProvider crmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selection chips
        Row(
          children: [
            _buildTypeSelectChip('note', 'Poznámka'),
            const SizedBox(width: 6),
            _buildTypeSelectChip('call', 'Hovor'),
            const SizedBox(width: 6),
            _buildTypeSelectChip('email', 'E-mail'),
            const SizedBox(width: 6),
            _buildTypeSelectChip('meeting', 'Stretnutie'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _activityController,
                key: const Key('add_activity_input'),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Zapísať priebeh aktivity...',
                  hintStyle: const TextStyle(
                    color: Colors.white24,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('add_activity_submit'),
              icon: const Icon(Icons.send, color: AppTheme.primary, size: 20),
              onPressed: () async {
                final text = _activityController.text.trim();
                if (text.isNotEmpty) {
                  String title = 'Zaznamenaná aktivita';
                  if (_newActivityType == 'call') title = 'Telefonát';
                  if (_newActivityType == 'email') title = 'E-mail odoslaný';
                  if (_newActivityType == 'meeting')
                    title = 'Osobné stretnutie';
                  if (_newActivityType == 'note') title = 'Interná poznámka';

                  await crmProvider.addActivity(
                    clientId: clientId,
                    type: _newActivityType,
                    title: title,
                    content: text,
                  );
                  _activityController.clear();
                  _loadActivities(clientId);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeSelectChip(String type, String label) {
    final isSelected = _newActivityType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _newActivityType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTimelineTile(CrmClientActivity activity) {
    IconData icon = LucideIcons.stickyNote;
    Color iconColor = AppTheme.primary;

    if (activity.type == 'call') {
      icon = LucideIcons.phone;
      iconColor = AppTheme.success;
    } else if (activity.type == 'email') {
      icon = LucideIcons.mail;
      iconColor = Colors.orange;
    } else if (activity.type == 'meeting') {
      icon = LucideIcons.calendar;
      iconColor = Colors.purple;
    }

    final timeStr =
        '${activity.createdAt.day}.${activity.createdAt.month}.${activity.createdAt.year} ${activity.createdAt.hour.toString().padLeft(2, '0')}:${activity.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                if (activity.content != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.content!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CRUD Modal Triggers ---
  void _openCreateClientDialog(CrmProvider crmProvider) async {
    final results = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CrmClientDialog(),
    );

    if (results != null) {
      await crmProvider.createClient(
        companyName: results['companyName'],
        contactName: results['contactName'],
        email: results['email'],
        phone: results['phone'],
        website: results['website'],
        service: results['service'],
        status: results['status'],
        budget: results['budget'],
        notes: results['notes'],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Klient bol úspešne pridaný'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _openEditClientDialog(CrmClient client, CrmProvider crmProvider) async {
    final results = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CrmClientDialog(client: client),
    );

    if (results != null) {
      final updated = client.copyWith(
        companyName: results['companyName'],
        contactName: results['contactName'],
        email: results['email'],
        phone: results['phone'],
        website: results['website'],
        service: results['service'],
        status: results['status'],
        budget: results['budget'],
        notes: results['notes'],
      );
      await crmProvider.updateClient(updated);
      setState(() {
        _selectedClient = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Klient bol úspešne upravený'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _confirmDeleteClient(CrmClient client, CrmProvider crmProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text(
          'Vymazať klienta?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Naozaj chcete presunúť klienta "${client.companyName}" do koša?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Zrušiť',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Vymazať', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(context).pop();
              await crmProvider.softDeleteClient(client.id);
              setState(() {
                _selectedClient = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Klient bol vymazaný (presunutý do koša)'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
