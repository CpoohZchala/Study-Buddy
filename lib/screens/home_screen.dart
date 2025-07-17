import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../providers/session_provider.dart';
import 'add_session_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;

  bool _showStats = true;
  String _selectedTimeFilter = 'All Time';
  final List<String> _timeFilters = [
    'Today',
    'This Week',
    'This Month',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _headerAnimationController, curve: Curves.elasticOut),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('StudyBuddy'),
        content: const Text(
          'Track your learning journey and build better study habits!\n\n'
          'Features:\n'
          '• Log study sessions\n'
          '• Track your progress\n'
          '• View statistics\n'
          '• Organize by subjects',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SessionProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            flexibleSpace: AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_headerAnimation.value * 0.2),
                  child: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF667EEA),
                                  const Color(0xFF764BA2),
                                  const Color(0xFF6B73FF),
                                ]
                              : [
                                  const Color(0xFF4FACFE),
                                  const Color(0xFF00F2FE),
                                  const Color(0xFF667EEA),
                                ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'StudyBuddy',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildIconButton(
                                        Icons.analytics_outlined,
                                        () {
                                          setState(() {
                                            _showStats = !_showStats;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      _buildIconButton(
                                        Icons.history,
                                        () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  const HistoryScreen(),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return SlideTransition(
                                                  position: animation.drive(
                                                    Tween(
                                                            begin: const Offset(
                                                                1.0, 0.0),
                                                            end: Offset.zero)
                                                        .chain(CurveTween(
                                                            curve: Curves
                                                                .easeInOut)),
                                                  ),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      _buildIconButton(
                                        Icons.info_outline,
                                        () {
                                          _showAppInfo();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '${provider.sessions.length} sessions logged',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Stats Cards
          if (_showStats) ...[
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _cardAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset:
                        Offset(0, 50 * (1 - _cardAnimationController.value)),
                    child: Opacity(
                      opacity: _cardAnimationController.value,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildStatsRow(provider, isDark),
                            const SizedBox(height: 16),
                            _buildTimeFilterChips(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Sessions List
          provider.sessions.isEmpty
              ? SliverFillRemaining(
                  child: _buildEmptyState(isDark),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = provider.sessions[index];
                        return AnimatedBuilder(
                          animation: _cardAnimationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  0, 30 * (1 - _cardAnimationController.value)),
                              child: Opacity(
                                opacity: math.min(
                                    1.0,
                                    _cardAnimationController.value +
                                        (index * 0.1)),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSessionCard(
                                      session, provider, isDark, index),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: provider.sessions.length,
                    ),
                  ),
                ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddSessionScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.elasticOut)),
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor:
            isDark ? const Color(0xFF667EEA) : const Color(0xFF4FACFE),
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 18,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  Widget _buildStatsRow(SessionProvider provider, bool isDark) {
    final totalMinutes = provider.sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
    final totalHours = (totalMinutes / 60).toStringAsFixed(1);
    final avgSession = provider.sessions.isNotEmpty
        ? (totalMinutes / provider.sessions.length).round()
        : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Hours',
            totalHours,
            Icons.schedule,
            Colors.blue,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Sessions',
            provider.sessions.length.toString(),
            Icons.book,
            Colors.green,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Session',
            '${avgSession}m',
            Icons.trending_up,
            Colors.orange,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _timeFilters.map((filter) {
          final isSelected = _selectedTimeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTimeFilter = filter;
                });
                HapticFeedback.lightImpact();
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: const Color(0xFF667EEA).withOpacity(0.2),
              labelStyle: TextStyle(
                color:
                    isSelected ? const Color(0xFF667EEA) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected ? const Color(0xFF667EEA) : Colors.transparent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionCard(
      dynamic session, SessionProvider provider, bool isDark, int index) {
    final subjectColors = {
      'Mathematics': Colors.blue,
      'Science': Colors.green,
      'History': Colors.brown,
      'Literature': Colors.purple,
      'Programming': Colors.orange,
      'Languages': Colors.red,
      'Art': Colors.pink,
      'Music': Colors.indigo,
    };

    final color = subjectColors[session.subject] ?? Colors.grey;

    return Dismissible(
      key: Key(session.id.toString()),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        HapticFeedback.heavyImpact();
        provider.deleteSession(session.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Implement undo functionality if needed
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              _showSessionDetails(session, color);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSubjectIcon(session.subject),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.subject,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(session.date),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDark ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        if (session.notes != null &&
                            session.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            session.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${session.durationMinutes}m',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.white60 : Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: isDark ? Colors.white60 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No study sessions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your learning journey by\nadding your first study session!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSessionScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(dynamic session, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSubjectIcon(session.subject),
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.subject,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(session.date),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildDetailRow('Duration', '${session.durationMinutes} minutes',
                  Icons.schedule),
              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailRow('Notes', session.notes!, Icons.note),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history_edu;
      case 'literature':
      case 'english':
        return Icons.book;
      case 'programming':
      case 'coding':
        return Icons.code;
      case 'languages':
        return Icons.language;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      default:
        return Icons.school;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 🌤️';
    return 'Good Evening! 🌙';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
