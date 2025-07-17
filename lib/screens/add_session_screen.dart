import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/session.dart';
import '../providers/session_provider.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  String _subject = '';
  int _duration = 0;
  String? _notes;
  String _selectedSubject = '';
  bool _isLoading = false;

  late AnimationController _animationController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.green},
    {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.brown},
    {'name': 'Literature', 'icon': Icons.book, 'color': Colors.purple},
    {'name': 'Programming', 'icon': Icons.code, 'color': Colors.orange},
    {'name': 'Languages', 'icon': Icons.language, 'color': Colors.red},
    {'name': 'Art', 'icon': Icons.palette, 'color': Colors.pink},
    {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.indigo},
  ];

  final List<int> _quickDurations = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    _subjectController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectSubject(String subject) {
    setState(() {
      _selectedSubject = subject;
      _subjectController.text = subject;
    });
    HapticFeedback.lightImpact();
  }

  void _selectDuration(int duration) {
    setState(() {
      _durationController.text = duration.toString();
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _saveSession() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _fabController.forward();

      _formKey.currentState!.save();

      // Add a slight delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));

      final session = Session(
        subject: _subject,
        date: DateTime.now(),
        durationMinutes: _duration,
        notes: _notes,
      );

      try {
        await Provider.of<SessionProvider>(context, listen: false)
            .insertSession(session);

        // Success haptic feedback
        HapticFeedback.heavyImpact();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Study session saved! 🎉'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _fabController.reverse();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Failed to save session'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'New Study Session',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE9ECEF),
                    const Color(0xFFDEE2E6),
                  ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // Header Card
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.indigo.shade700,
                                          Colors.purple.shade700
                                        ]
                                      : [
                                          Colors.indigo.shade400,
                                          Colors.purple.shade400
                                        ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.school,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Track Your Learning Journey',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Every session counts towards your goals!',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Subject Selection
                          _buildSectionTitle('📚 Choose Your Subject'),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: _subjects.map((subject) {
                                      final isSelected =
                                          _selectedSubject == subject['name'];
                                      return AnimatedScale(
                                        scale: isSelected ? 1.1 : 1.0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectSubject(subject['name']),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? subject['color']
                                                  : subject['color']
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                color: subject['color'],
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  subject['icon'],
                                                  color: isSelected
                                                      ? Colors.white
                                                      : subject['color'],
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  subject['name'],
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : subject['color'],
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _subjectController,
                                    decoration: InputDecoration(
                                      labelText: 'Custom Subject',
                                      hintText: 'Or type your own subject...',
                                      prefixIcon: const Icon(Icons.edit),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade50,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSubject = value;
                                      });
                                    },
                                    onSaved: (value) => _subject = value!,
                                    validator: (value) => value!.isEmpty
                                        ? 'Please enter a subject'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Duration Selection
                          _buildSectionTitle('⏱️ Set Study Duration'),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'Quick Select (minutes)',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _quickDurations.map((duration) {
                                      final isSelected =
                                          _durationController.text ==
                                              duration.toString();
                                      return GestureDetector(
                                        onTap: () => _selectDuration(duration),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.indigo
                                                : Colors.indigo
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.indigo,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            '${duration}m',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.indigo,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _durationController,
                                    decoration: InputDecoration(
                                      labelText: 'Custom Duration (minutes)',
                                      hintText: 'Enter custom duration...',
                                      prefixIcon: const Icon(Icons.timer),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade50,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSaved: (value) =>
                                        _duration = int.tryParse(value!) ?? 0,
                                    validator: (value) => value!.isEmpty ||
                                            int.tryParse(value) == null
                                        ? 'Please enter a valid duration'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Notes Section
                          _buildSectionTitle('📝 Add Notes (Optional)'),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Session Notes',
                                  hintText: 'What did you learn? Any thoughts?',
                                  prefixIcon: const Icon(Icons.note_add),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade50,
                                ),
                                maxLines: 4,
                                onSaved: (value) => _notes =
                                    value?.isEmpty == true ? null : value,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_fabController.value * 0.1),
            child: FloatingActionButton.extended(
              onPressed: _isLoading ? null : _saveSession,
              backgroundColor: Colors.indigo,
              elevation: 8,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isLoading ? 'Saving...' : 'Save Session',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.grey.shade800,
      ),
    );
  }
}
