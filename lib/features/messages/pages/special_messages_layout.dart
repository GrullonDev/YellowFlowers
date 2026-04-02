import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';
import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/features/messages/widgets/message_card.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';

class SpecialMessagesLayout extends StatefulWidget {
  const SpecialMessagesLayout({super.key});

  @override
  State<SpecialMessagesLayout> createState() => _SpecialMessagesLayoutState();
}

class _SpecialMessagesLayoutState extends State<SpecialMessagesLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialMessagesBloc>(
      builder: (context, model, _) => DefaultTabController(
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, model),
          body: AnimatedBackground(
            decorationCount: 8,
            child: SafeArea(
              child: TabBarView(
                children: [
                  _MessagesTab(model: model, controller: _listController),
                  _FavoritesTab(model: model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, SpecialMessagesBloc model) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Mensajes Especiales',
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w800,
          color: PremiumDesign.softText,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Ciclo y Música',
          icon: const Icon(Icons.auto_awesome_rounded,
              color: PremiumDesign.softText),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CycleMusicPage()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: TabBar(
        dividerColor: Colors.transparent,
        indicatorColor: PremiumDesign.premiumGold,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: PremiumDesign.softText,
        unselectedLabelColor:
            PremiumDesign.secondaryText.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        tabs: const [
          Tab(text: 'EXPLORAR'),
          Tab(text: 'FAVORITOS'),
        ],
      ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab({required this.model, required this.controller});
  final SpecialMessagesBloc model;
  final AnimationController controller;

  Color _getCategoryColor(MessageCategory cat) {
    switch (cat) {
      case MessageCategory.love:
        return Colors.redAccent.withValues(alpha: 0.8);
      case MessageCategory.selfEsteem:
        return Colors.blueAccent.withValues(alpha: 0.75);
      case MessageCategory.friendship:
        return Colors.tealAccent.withValues(alpha: 0.8);
      case MessageCategory.family:
        return Colors.orangeAccent.withValues(alpha: 0.8);
      case MessageCategory.occasions:
        return Colors.purpleAccent.withValues(alpha: 0.8);
      case MessageCategory.community:
        return Colors.indigoAccent.withValues(alpha: 0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(model.selected);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(PremiumDesign.s32,
                PremiumDesign.s24, PremiumDesign.s32, PremiumDesign.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El Lenguaje de las Flores',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: PremiumDesign.softText,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Encuentra las palabras perfectas para florecer.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PremiumDesign.secondaryText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: MessageCategory.values.map((category) {
                    final isSelected = model.selected == category;
                    final chipColor = _getCategoryColor(category);

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(category.label),
                        selected: isSelected,
                        onSelected: (_) => model.setCategory(category),
                        showCheckmark: false,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : PremiumDesign.softText,
                        ),
                        selectedColor: chipColor,
                        backgroundColor: Colors.white.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : PremiumDesign.softText
                                    .withValues(alpha: 0.05),
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: PremiumDesign.s32),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'RECOMENDACIÓN DEL DÍA',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color:
                            PremiumDesign.secondaryText.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.auto_awesome_rounded, color: catColor, size: 14),
                  ],
                ),
                const SizedBox(height: 16),
                _FeaturedMessageCard(model: model, accentColor: catColor),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: PremiumDesign.s32),
                child: Text(
                  'DI LO QUE SIENTES',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: PremiumDesign.secondaryText.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _MessageComposer(model: model, accentColor: catColor),
              const SizedBox(height: 48),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: PremiumDesign.s24, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final msg = model.messages[i];
                final isLarge = i % 5 == 0;
                final variant = i % 3;

                final animation = CurvedAnimation(
                  parent: controller,
                  curve: Interval(
                    (i * 0.04).clamp(0.0, 1.0),
                    1.0,
                    curve: Curves.easeOutQuart,
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: PremiumDesign.s24),
                      child: MessageCard(
                        text: msg.text,
                        isFavorite: msg.isFavorite,
                        onFavorite: () => model.toggleFavorite(i),
                        onSpeak: () => model.speak(i),
                        isLarge: isLarge,
                        variant: variant,
                        categoryColor: catColor,
                      ),
                    ),
                  ),
                );
              },
              childCount: model.messages.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _FeaturedMessageCard extends StatefulWidget {
  const _FeaturedMessageCard({required this.model, required this.accentColor});
  final SpecialMessagesBloc model;
  final Color accentColor;

  @override
  State<_FeaturedMessageCard> createState() => _FeaturedMessageCardState();
}

class _FeaturedMessageCardState extends State<_FeaturedMessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.model.messages.isEmpty) return const SizedBox.shrink();

    // Lógica para mensaje del día basado en la fecha
    final now = DateTime.now();
    final daySeed = now.year * 1000 + now.month * 100 + now.day;
    final index = daySeed % widget.model.messages.length;
    final featured = widget.model.messages[index];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(PremiumDesign.s32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor.withValues(alpha: 0.2),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.6),
                        widget.accentColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.4 + (0.2 * _glowController.value), 1.0],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: widget.accentColor.withValues(
                          alpha: 0.3 + (0.2 * _glowController.value)),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(
                            alpha: 0.08 + (0.08 * _glowController.value)),
                        blurRadius: 40,
                        spreadRadius: 10 * _glowController.value,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: child,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: widget.accentColor, size: 14),
              const SizedBox(width: 8),
              Text(
                'DESTACADO DEL MOMENTO',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: widget.accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome_rounded,
                  color: widget.accentColor, size: 14),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            featured.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: PremiumDesign.softText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          _PrimaryActionButton(
            icon: Icons.ios_share_rounded,
            label: 'Enviar ahora 💛',
            accentColor: widget.accentColor,
            onTap: () async => await Share.share(featured.text),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({required this.model, required this.accentColor});
  final SpecialMessagesBloc model;
  final Color accentColor;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  final List<String> _suggestions = [
    'Para mamá... 🌸',
    'Para mi pareja... ❤️',
    'Un consejo... ✨',
    'Para un amigo... 🤝',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(PremiumDesign.s12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _isFocused ? 0.98 : 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: _isFocused
                    ? widget.accentColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isFocused ? widget.accentColor : Colors.black)
                      .withValues(alpha: 0.05),
                  blurRadius: _isFocused ? 30 : 15,
                  offset: Offset(0, _isFocused ? 15 : 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.auto_fix_high_rounded,
                  color: _isFocused
                      ? widget.accentColor
                      : PremiumDesign.secondaryText.withValues(alpha: 0.4),
                  size: 20,
                ),
                Expanded(
                  child: TextField(
                    controller: widget.model.controller,
                    focusNode: _focusNode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PremiumDesign.softText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Siente y escribe... ✨',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color:
                            PremiumDesign.secondaryText.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                _AnimatedSendButton(
                  isFocused: _isFocused,
                  onPressed: () {
                    final text = widget.model.controller.text.trim();
                    if (text.isNotEmpty) {
                      widget.model.addMessage(text);
                      widget.model.controller.clear();
                      _focusNode.unfocus();
                    }
                  },
                  accentColor: widget.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _suggestions
                  .map((s) => _SuggestionChip(
                        label: s,
                        onTap: () {
                          final suggestion = s.split('...')[0];
                          widget.model.controller.text = '$suggestion ';
                          _focusNode.requestFocus();
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSendButton extends StatelessWidget {
  const _AnimatedSendButton(
      {required this.isFocused,
      required this.onPressed,
      required this.accentColor});
  final bool isFocused;
  final VoidCallback onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isFocused ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: PremiumDesign.softText,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PremiumDesign.softText.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PremiumDesign.softText.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: PremiumDesign.softText,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PremiumDesign.softText.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({required this.model});
  final SpecialMessagesBloc model;

  @override
  Widget build(BuildContext context) {
    if (model.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: PremiumDesign.premiumGold.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 80,
                  color: PremiumDesign.premiumGold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Aún no guardas mensajes... pero seguro encontrarás uno especial 💛',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PremiumDesign.softText,
                ),
              ),
              const SizedBox(height: 32),
              _PrimaryActionButton(
                icon: Icons.explore_rounded,
                label: 'Explorar mensajes',
                onTap: () => DefaultTabController.of(context).animateTo(0),
                accentColor: PremiumDesign.premiumGold,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(PremiumDesign.s24),
      itemCount: model.favorites.length,
      itemBuilder: (context, i) {
        final msg = model.favorites[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: PremiumDesign.s24),
          child: MessageCard(
            text: msg.text,
            isFavorite: true,
            onFavorite: () => model.toggleFavorite(i),
            onSpeak: () => model.speakMessage(msg),
          ),
        );
      },
    );
  }
}
