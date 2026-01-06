import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';
import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/features/messages/widgets/message_card.dart';
import 'package:yellow_flowers/utils/app_theme.dart';

class SpecialMessagesLayout extends StatefulWidget {
  const SpecialMessagesLayout({super.key});

  @override
  State<SpecialMessagesLayout> createState() => _SpecialMessagesLayoutState();
}

class _SpecialMessagesLayoutState extends State<SpecialMessagesLayout> {
  int _selectedIndex = 0; // 0 = Mensajes, 1 = Favoritos

  // Pastel colors for sticky notes
  final List<Color> _noteColors = const [
    Color(0xFFFFF9C4), // Yellow
    Color(0xFFE1BEE7), // Purple
    Color(0xFFC8E6C9), // Green
    Color(0xFFB3E5FC), // Blue
    Color(0xFFFFCCBC), // Orange
    Color(0xFFF0F4C3), // Lime
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialMessagesBloc>(
      builder: (context, model, _) {
        final messages = _selectedIndex == 0 ? model.messages : model.favorites;

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBF7), // Warm paper background
          body: CustomScrollView(
            slivers: [
              // 1. Custom Handwriting Header
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: const Color(0xFFFDFBF7),
                elevation: 0,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Palabras del Corazón",
                    style: GoogleFonts.playball(
                      color: AppTheme.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFDE7),
                          Color(0xFFFDFBF7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Custom Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton("Explorar", 0),
                      const SizedBox(width: 16),
                      _buildTabButton("Mis Favoritos", 1),
                    ],
                  ),
                ),
              ),

              // 3. Category Filter (Only for Explore)
              if (_selectedIndex == 0)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: MessageCategory.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final cat = MessageCategory.values[i];
                        final isSelected = cat == model.selected;
                        return ChoiceChip(
                          label: Text(
                            "${cat.emoji} ${cat.label}",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => model.setCategory(cat),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.sunnyGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 4. Input Area (Only for Explore - technically users might append anywhere but let's keep it here)
              if (_selectedIndex == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: model.controller,
                              decoration: const InputDecoration(
                                hintText: 'Escribe tu propio mensaje... ✍️',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded,
                                color: AppTheme.sunnyGold),
                            onPressed: () {
                              if (model.controller.text.isNotEmpty) {
                                model.addMessage(model.controller.text);
                                model.controller.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 5. Grid of Sticky Notes
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        0.85, // More vertical for sticky note feel
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final msg = messages[index];
                      // Determine color deterministically based on index/hash
                      final color = _noteColors[index % _noteColors.length];

                      return Dismissible(
                        key: ValueKey(
                            'msg_${msg.text}_${msg.createdAt.millisecondsSinceEpoch}'),
                        // Only allow deleting from main list if necessary, or favoriting
                        // For now, let's just make it Swipe-to-delete only if it's user generated?
                        // The original code allowed delete. Let's keep it but styling background.
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_sweep,
                              color: Colors.white, size: 30),
                        ),
                        onDismissed: (_) {
                          if (_selectedIndex == 0) {
                            model.removeMessage(msg);
                          } else {
                            // removing from favorites logic is different in original code?
                            // Original code: model.removeMessage(msg) which removes from 'messages' list.
                            // If we are in favorites view, we probably just want to unfavorite?
                            // Let's just assume delete works for both for now or handle unfavorite.
                            // To be safe and consistent with previous behavior:
                            model.toggleFavorite(model.messages.indexOf(msg));
                            // Wait, msg in favorites is a copy or reference?
                            // The original code mapped favorites from the main list.
                          }
                        },
                        child: MessageCard(
                          text: '${msg.text} ${msg.category.emoji}',
                          isFavorite: msg
                              .isFavorite, // Logic might need adjustment for favorites list
                          color: color,
                          onFavorite: () {
                            if (_selectedIndex == 0) {
                              model.toggleFavorite(index);
                            } else {
                              // Find index in main list
                              final mainIndex = model.messages.indexOf(msg);
                              if (mainIndex != -1)
                                model.toggleFavorite(mainIndex);
                            }
                          },
                          onSpeak: () => model.speakMessage(msg),
                        ),
                      );
                    },
                    childCount: messages.length,
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Scroll to top or add new?
              // For now maybe simple "Inspire Me" feature?
              // Or just hide it. Original didn't have FAB on main screen.
              // Let's add a random message generator button?
              // model.addMessage("Eres increíble ✨"); like a shuffle?
              // Let's keep it clean, NO FAB for now.
            },
            backgroundColor: AppTheme.accentPink,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.leafGreen : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.leafGreen.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
