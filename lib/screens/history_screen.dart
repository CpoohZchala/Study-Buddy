import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../providers/session_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _chartAnimation;

  String _selectedPeriod = 'All Time';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _chartAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _chartAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SessionProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalMinutes = provider.sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );
    final totalHours = (totalMinutes / 60).toStringAsFixed(1);

    // Get subject statistics
    final subjectStats = _getSubjectStatistics(provider.sessions);
    final longestSession = provider.sessions.isNotEmpty
        ? provider.sessions.map((s) => s.durationMinutes).reduce(math.max)
        : 0;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            flexibleSpace: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_slideAnimation.value * 0.2),
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
                        child: ClipRect(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 5),
                                const Text(
                                  'Study History',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Your learning journey over time',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: _buildHeaderStat(
                                          '📚',
                                          '${provider.sessions.length}',
                                          'Sessions'),
                                    ),
                                    Flexible(
                                      child: _buildHeaderStat(
                                          '⏱️', totalHours, 'Hours'),
                                    ),
                                    Flexible(
                                      child: _buildHeaderStat(
                                          '🎯', '${longestSession}m', 'Best'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Period Filter
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value.clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildPeriodFilter(isDark),
                    ),
                  ),
                );
              },
            ),
          ),

          // Statistics Cards
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value.clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (subjectStats.isNotEmpty) ...[
                            _buildSubjectBreakdown(subjectStats, isDark),
                            const SizedBox(height: 16),
                          ],
                          _buildProgressChart(provider.sessions, isDark),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sessions List
          if (provider.sessions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(isDark),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = provider.sessions[index];
                    return AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - _slideAnimation.value)),
                          child: Opacity(
                            opacity: math.min(
                                1.0,
                                (_slideAnimation.value + (index * 0.1))
                                    .clamp(0.0, 1.0)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSessionCard(session, isDark, index),
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
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodFilter(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPeriod = period;
                });
                HapticFeedback.lightImpact();
              },
              backgroundColor:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              selectedColor: const Color(0xFF667EEA).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF667EEA)
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
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

  Widget _buildSubjectBreakdown(Map<String, int> subjectStats, bool isDark) {
    if (subjectStats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.pie_chart, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Subject Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...subjectStats.entries.map((entry) {
            final total =
                subjectStats.values.fold(0, (sum, value) => sum + value);
            final percentage = (entry.value / total * 100).round();
            return _buildSubjectBar(entry.key, entry.value, percentage, isDark);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubjectBar(
      String subject, int minutes, int percentage, bool isDark) {
    final colors = {
      'Mathematics': Colors.blue,
      'Science': Colors.green,
      'History': Colors.brown,
      'Literature': Colors.purple,
      'Programming': Colors.orange,
      'Languages': Colors.red,
      'Art': Colors.pink,
      'Music': Colors.indigo,
    };

    final color = colors[subject] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
              Text(
                '${minutes}m ($percentage%)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 100) * _chartAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(List<dynamic> sessions, bool isDark) {
    final dailyMinutes = <String, int>{};

    for (final session in sessions) {
      final dateKey = _formatDateKey(session.date);
      dailyMinutes[dateKey] =
          (dailyMinutes[dateKey] ?? 0) + (session.durationMinutes as int);
    }

    final sortedEntries = dailyMinutes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up,
                    color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sortedEntries.isNotEmpty)
            SizedBox(
              height: 100,
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 100),
                    painter: ProgressChartPainter(
                      sortedEntries,
                      _chartAnimation.value,
                      isDark,
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: Text(
                'No data to display',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(dynamic session, bool isDark, int index) {
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

    return Container(
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
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  if (session.notes != null && session.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      session.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
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
          ],
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
              Icons.history,
              size: 64,
              color: isDark ? Colors.white60 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No study history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging study sessions to\nsee your progress over time!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getSubjectStatistics(List<dynamic> sessions) {
    final stats = <String, int>{};
    for (final session in sessions) {
      stats[session.subject] =
          (stats[session.subject] ?? 0) + (session.durationMinutes as int);
    }
    return stats;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';

    return '${date.day}/${date.month}/${date.year}';
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
}

class ProgressChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> data;
  final double animationValue;
  final bool isDark;

  ProgressChartPainter(this.data, this.animationValue, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF667EEA)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF667EEA).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxValue = data.map((e) => e.value).reduce(math.max).toDouble();
    final stepX = size.width / (data.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX * animationValue;
      final y = size.height -
          (data[i].value / maxValue * size.height * animationValue);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(data.length * stepX * animationValue, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF667EEA)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX * animationValue;
      final y = size.height -
          (data[i].value / maxValue * size.height * animationValue);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
