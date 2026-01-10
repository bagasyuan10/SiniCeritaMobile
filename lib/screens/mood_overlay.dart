import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Definisi Mood Data
class MoodData {
  final String emoji;
  final String label;
  final Color color;

  const MoodData(this.emoji, this.label, this.color);
}

class MoodOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const MoodOverlay({super.key, required this.onDismiss});

  @override
  State<MoodOverlay> createState() => _MoodOverlayState();
}

class _MoodOverlayState extends State<MoodOverlay> with SingleTickerProviderStateMixin {
  int? _selectedMoodIndex;
  bool _isLoading = false;
  bool _isSuccess = false;
  late AnimationController _controller;

  final List<MoodData> _moods = [
    const MoodData('😢', 'Sedih', Color(0xFF607D8B)), // Blue Grey
    const MoodData('😐', 'Biasa', Color(0xFF8D6E63)), // Brownish
    const MoodData('😊', 'Senang', Color(0xFF26A69A)), // Teal
    const MoodData('😁', 'Bahagia', Color(0xFFFFB74D)), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _currentColor {
    if (_selectedMoodIndex == null) return Colors.grey.shade900;
    return _moods[_selectedMoodIndex!].color;
  }

  Future<void> _submitMood() async {
    if (_selectedMoodIndex == null) return;
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      // Simulasi delay untuk UX
      await Future.delayed(const Duration(milliseconds: 800));

      if (user != null) {
        final selectedData = _moods[_selectedMoodIndex!];
        await Supabase.instance.client.from('daily_moods').insert({
          'user_id': user.id,
          'mood_label': selectedData.label,
          'mood_emoji': selectedData.emoji,
        });
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });

        await Future.delayed(const Duration(milliseconds: 1000));
        widget.onDismiss();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. DYNAMIC AMBIENT BACKGROUND
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _currentColor.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          // 2. GLASS BLUR
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SizedBox.expand(),
          ),

          // 3. MAIN CONTENT
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
                      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
                    ),
                    child: FadeTransition(
                      opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "How are you feeling?",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Check in with yourself right now.",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                            ),
                            const SizedBox(height: 40),

                            // MOOD GRID
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(_moods.length, (index) => _buildStaggeredMoodItem(index)),
                            ),

                            const SizedBox(height: 40),

                            // SMART BUTTON
                            _buildSmartButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredMoodItem(int index) {
    final double start = 0.3 + (index * 0.1);
    final double end = start + 0.4;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.elasticOut),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeOut),
        ),
        child: _buildMoodItem(index),
      ),
    );
  }

  Widget _buildMoodItem(int index) {
    bool isSelected = _selectedMoodIndex == index;
    final mood = _moods[index];

    return GestureDetector(
      onTap: _isLoading || _isSuccess ? null : () {
        HapticFeedback.lightImpact();
        setState(() => _selectedMoodIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? mood.color : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          // FIX 1: BoxShadow Selalu ada, tapi transparan jika tidak dipilih
          boxShadow: [
            BoxShadow(
              color: isSelected ? mood.color.withValues(alpha: 0.6) : Colors.transparent,
              blurRadius: isSelected ? 20 : 0,
              spreadRadius: isSelected ? 2 : 0,
            )
          ],
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(mood.emoji, style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
              child: Text(mood.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartButton() {
    bool isEnabled = _selectedMoodIndex != null && !_isLoading && !_isSuccess;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 60,
      width: _isLoading || _isSuccess ? 60 : double.infinity,
      decoration: BoxDecoration(
        color: _isSuccess
            ? Colors.greenAccent
            : (isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(30),
        // FIX 2: BoxShadow Selalu ada, tapi transparan jika button disabled
        boxShadow: [
          BoxShadow(
            color: isEnabled ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
            blurRadius: isEnabled ? 15 : 0,
            offset: isEnabled ? const Offset(0, 5) : Offset.zero,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: isEnabled ? _submitMood : null,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                    )
                  : _isSuccess
                      ? const Icon(Icons.check, color: Colors.black, size: 30, key: ValueKey('success'))
                      : Text(
                          "Continue",
                          key: const ValueKey('text'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isEnabled ? Colors.black : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}