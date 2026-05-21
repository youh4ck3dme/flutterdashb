import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth_provider.dart';
import '../../core/supabase_service.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final SupabaseService _supabase = SupabaseService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AiConversation> _conversations = [];
  List<AiMessage> _messages = [];
  AiConversation? _activeConversation;
  bool _loadingConvs = false;
  bool _loadingMsgs = false;
  bool _sending = false;
  
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _unsubscribeRealtime();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _loadingConvs = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid ?? '';
    
    final convs = await _supabase.getConversations(userId);
    setState(() {
      _conversations = convs;
      _loadingConvs = false;
    });

    if (convs.isNotEmpty) {
      _selectConversation(convs.first);
    }
  }

  Future<void> _selectConversation(AiConversation conv) async {
    _unsubscribeRealtime();
    setState(() {
      _activeConversation = conv;
      _loadingMsgs = true;
      _messages = [];
    });

    final msgs = await _supabase.getMessages(conv.id);
    setState(() {
      _messages = msgs;
      _loadingMsgs = false;
    });

    _subscribeRealtime(conv.id);
    _scrollToBottom();
  }

  void _subscribeRealtime(String conversationId) {
    try {
      _realtimeChannel = _supabase.client
          .channel('ai-messages-realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'ai_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: conversationId,
            ),
            callback: (payload) {
              final newMsg = AiMessage.fromMap(payload.newRecord);
              setState(() {
                // Ensure we don't add duplicates
                if (!_messages.any((m) => m.id == newMsg.id)) {
                  _messages.add(newMsg);
                }
              });
              _scrollToBottom();
            },
          );
      _realtimeChannel!.subscribe();
    } catch (e) {
      print('Realtime AI subscription failed: $e');
    }
  }

  void _unsubscribeRealtime() {
    if (_realtimeChannel != null) {
      _supabase.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }

  Future<void> _createNewChat() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid ?? '';
    if (userId.isEmpty) return;

    setState(() => _loadingMsgs = true);
    
    final newConv = await _supabase.createConversation('Nová konverzácia', userId);
    if (newConv != null) {
      setState(() {
        _conversations.insert(0, newConv);
      });
      _selectConversation(newConv);
    } else {
      setState(() => _loadingMsgs = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _activeConversation == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid ?? '';

    setState(() => _sending = true);
    _msgController.clear();

    final userMsg = AiMessage(
      id: '',
      conversationId: _activeConversation!.id,
      content: text,
      role: 'user',
      userId: userId,
      createdAt: DateTime.now(),
    );

    // Save user message to database
    final savedMsg = await _supabase.createMessage(userMsg);
    if (savedMsg != null) {
      setState(() {
        if (!_messages.any((m) => m.id == savedMsg.id)) {
          _messages.add(savedMsg);
        }
      });
      _scrollToBottom();
    }

    setState(() => _sending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Sidebar with conversations on desktop
          if (isDesktop) _buildSidebar(),
          
          // Main chat panel
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0x10FFFFFF)),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _activeConversation == null
                        ? _buildNoConversationPlaceholder()
                        : _buildChatArea(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.black.withOpacity(0.1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppTheme.primary, width: 0.5),
                ),
              ),
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Nový chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _createNewChat,
            ),
          ),
          const Divider(color: Color(0x10FFFFFF)),
          Expanded(
            child: _loadingConvs
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final c = _conversations[index];
                      final isActive = _activeConversation?.id == c.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        child: InkWell(
                          onTap: () => _selectConversation(c),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: isActive
                                ? AppTheme.activeGlassDecoration(borderRadius: 8)
                                : null,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.messageSquare, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    c.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDesktop = Responsive.isDesktop(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0x0AFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0x15FFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.bot, color: AppTheme.primary, size: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Asistent',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    _activeConversation != null ? 'Položte otázku o nahlásených chybách' : 'Rýchla analýza a prehľad',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          if (!isDesktop)
            IconButton(
              icon: const Icon(LucideIcons.messageSquare, size: 18),
              onPressed: () {
                // Show a dialog to select chats on mobile
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF0F0F12),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Moje konverzácie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(LucideIcons.plus, size: 16, color: AppTheme.primary),
                            title: const Text('Nový chat', style: TextStyle(fontSize: 13, color: AppTheme.primary)),
                            onTap: () {
                              Navigator.pop(context);
                              _createNewChat();
                            },
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _conversations.length,
                              itemBuilder: (context, index) {
                                final c = _conversations[index];
                                return ListTile(
                                  leading: const Icon(LucideIcons.messageSquare, size: 16),
                                  title: Text(c.title, style: const TextStyle(fontSize: 13)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _selectConversation(c);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNoConversationPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: const Icon(LucideIcons.bot, color: AppTheme.primary, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vitajte v AI Asistentovi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Môžete klásť otázky o svojich projektoch a nahlásených chybách.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _createNewChat,
            child: const Text('Začať novú konverzáciu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    if (_loadingMsgs) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Messages list
        Expanded(
          child: _messages.isEmpty
              ? _buildWelcomeMessage()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    final isUser = m.role == 'user';
                    return _buildMessageBubble(m.content, isUser);
                  },
                ),
        ),

        // Text input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0x05FFFFFF),
            border: Border(top: BorderSide(color: Color(0x10FFFFFF))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x0EFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x12FFFFFF)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Položte otázku...',
                      hintStyle: TextStyle(color: Color(0x35FFFFFF), fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary,
                child: IconButton(
                  icon: const Icon(LucideIcons.send, color: Colors.white, size: 14),
                  onPressed: _sending ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.bot, color: AppTheme.textSecondary, size: 30),
            const SizedBox(height: 12),
            const Text(
              'Konverzácia je prázdna',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Položte prvú otázku! Napr.: „Koľko kritických chýb máme?“',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: const Icon(LucideIcons.bot, color: AppTheme.primary, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : const Color(0x0EFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                ),
                border: isUser
                    ? null
                    : Border.all(color: const Color(0x12FFFFFF)),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 12,
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0x0EFFFFFF),
              child: const Icon(LucideIcons.user, color: AppTheme.textSecondary, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}
