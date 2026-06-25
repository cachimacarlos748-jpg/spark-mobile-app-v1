import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/chat_message.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String _selectedModel = 'spark-3.5-flash';
  String _selectedReasoning = 'standard';
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userName ?? 'Usuario';

    setState(() {
      _messages.add({
        'role': 'system',
        'content': '¡Hola, $userName! Estoy listo para ayudarte',
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add({
        'role': 'user',
        'content': userMessage,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await GeminiService.sendMessage(
        userMessage,
        model: _selectedModel,
        reasoning: _selectedReasoning,
      );

      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': response,
          'timestamp': DateTime.now(),
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'error',
          'content': 'Error: ${e.toString()}',
          'timestamp': DateTime.now(),
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ModelSelectorSheet(
        selectedModel: _selectedModel,
        selectedReasoning: _selectedReasoning,
        onModelChanged: (model) {
          setState(() => _selectedModel = model);
          Navigator.pop(context);
        },
        onReasoningChanged: (reasoning) {
          setState(() => _selectedReasoning = reasoning);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionsMenu(
        onSelectOption: (option) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$option - Próximamente')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showModelSelector,
              child: Row(
                children: [
                  Text(
                    _selectedModel.replaceAll('spark-', 'Spark '),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.expand_more, size: 20),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Configuración'),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text('Cerrar sesión'),
                onTap: () => authProvider.logout(),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No hay mensajes aún',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatMessage(
                        role: message['role'],
                        content: message['content'],
                        timestamp: message['timestamp'],
                      );
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showOptionsMenu,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Pregunta a Spark',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        enabled: !_isLoading,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Micrófono - Próximamente')),
                        );
                      },
                    ),
                    IconButton(
                      icon: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : const Icon(Icons.send),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ModelSelectorSheet extends StatelessWidget {
  final String selectedModel;
  final String selectedReasoning;
  final Function(String) onModelChanged;
  final Function(String) onReasoningChanged;

  const _ModelSelectorSheet({
    required this.selectedModel,
    required this.selectedReasoning,
    required this.onModelChanged,
    required this.onReasoningChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seleccionar Modelo', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _ModelOption(
            title: 'Spark 3.1 Flash-Lite',
            subtitle: 'Respuestas más rápidas',
            isSelected: selectedModel == 'spark-3.1-flash-lite',
            onTap: () => onModelChanged('spark-3.1-flash-lite'),
          ),
          _ModelOption(
            title: 'Spark 3.5 Flash',
            subtitle: 'Asistencia general',
            isSelected: selectedModel == 'spark-3.5-flash',
            onTap: () => onModelChanged('spark-3.5-flash'),
          ),
          _ModelOption(
            title: 'Spark 3.1 Pro',
            subtitle: 'Matemáticas y programación',
            isSelected: selectedModel == 'spark-3.1-pro',
            onTap: () => onModelChanged('spark-3.1-pro'),
          ),
          const SizedBox(height: 24),
          Text('Nivel de Razonamiento', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _ModelOption(
            title: 'Estándar',
            subtitle: 'Ideal para la mayoría',
            isSelected: selectedReasoning == 'standard',
            onTap: () => onReasoningChanged('standard'),
          ),
          _ModelOption(
            title: 'Extendido',
            subtitle: 'Problemas complejos',
            isSelected: selectedReasoning == 'advanced',
            onTap: () => onReasoningChanged('advanced'),
          ),
        ],
      ),
    );
  }
}

class _ModelOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF3B82F6)),
          ],
        ),
      ),
    );
  }
}

class _OptionsMenu extends StatelessWidget {
  final Function(String) onSelectOption;

  const _OptionsMenu({required this.onSelectOption});

  @override
  Widget build(BuildContext context) {
    final options = [
      {'id': 'photos', 'title': 'Fotos', 'icon': Icons.photo_library},
      {'id': 'camera', 'title': 'Cámara', 'icon': Icons.camera_alt},
      {'id': 'files', 'title': 'Archivos', 'icon': Icons.attach_file},
      {'id': 'images', 'title': 'Imágenes', 'icon': Icons.image},
      {'id': 'music', 'title': 'Música', 'icon': Icons.music_note},
      {'id': 'canvas', 'title': 'Canvas', 'icon': Icons.dashboard_customize},
      {'id': 'research', 'title': 'Deep Research', 'icon': Icons.search},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opciones', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: options.map((option) {
              return GestureDetector(
                onTap: () => onSelectOption(option['title'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(option['icon'] as IconData, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        option['title'] as String,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
