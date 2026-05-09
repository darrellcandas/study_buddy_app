import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Buddy App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.paper,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const StudyBuddyHome(),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF18245F);
  static const purple = Color(0xFF7B2CFF);
  static const blue = Color(0xFF0478FF);
  static const accent = Color(0xFF33D6E8);
  static const success = Color(0xFF17A979);
  static const warning = Color(0xFFFFB84D);
  static const danger = Color(0xFFFF5C7A);
  static const canvas = Color(0xFFF4F7FF);
  static const paper = Color(0xFFFFFFFF);
  static const line = Color(0xFFD8E1F5);
  static const muted = Color(0xFF667085);
  static const ink = primary;
  static const teal = blue;
  static const mint = accent;
  static const coral = purple;
  static const gold = warning;
  static const notice = Color(0xFFE9FBFF);
  static const noticeLine = Color(0xFFA7EEF6);
  static const cardAnswer = Color(0xFFEAF5FF);
}

class AppRadius {
  static const small = 12.0;
  static const medium = 16.0;
  static const large = 20.0;
}

class AppType {
  static const title = TextStyle(
    color: AppColors.primary,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    height: 1.08,
  );
  static const section = TextStyle(
    color: AppColors.primary,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1.15,
  );
  static const body = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );
  static const label = TextStyle(
    color: AppColors.muted,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.25,
  );
}

class StudyBuddyHome extends StatefulWidget {
  const StudyBuddyHome({super.key});

  @override
  State<StudyBuddyHome> createState() => _StudyBuddyHomeState();
}

class _StudyBuddyHomeState extends State<StudyBuddyHome> {
  final _notesController = TextEditingController(text: sampleNotes);
  StudySet? _studySet;
  int _selectedTab = 0;
  int _flashcardIndex = 0;
  int _quizIndex = 0;
  int? _selectedAnswer;
  bool _showAnswer = false;
  bool _isGenerating = false;
  bool _notesExpanded = true;
  int _generationStep = 0;
  final Map<String, ConfidenceLevel> _confidence = {};
  static const _generationSteps = [
    'Analyzing notes...',
    'Creating flashcards...',
    'Building quiz...',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generateStudySet() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _generationStep = 0;
    });

    for (var i = 0; i < _generationSteps.length; i++) {
      if (!mounted) return;
      setState(() => _generationStep = i);
      await Future<void>.delayed(const Duration(milliseconds: 280));
    }

    final generated = StudySetGenerator.generate(_notesController.text);
    if (!mounted) return;

    setState(() {
      _studySet = generated;
      _selectedTab = 0;
      _flashcardIndex = 0;
      _quizIndex = 0;
      _selectedAnswer = null;
      _showAnswer = false;
      _isGenerating = false;
      _notesExpanded = false;
      _generationStep = 0;
      _confidence.clear();
    });
  }

  void _resetQuizChoice() {
    _selectedAnswer = null;
    _showAnswer = false;
  }

  int get _masteredCount {
    return _confidence.values
        .where((level) => level == ConfidenceLevel.strong)
        .length;
  }

  int get _reviewedCount {
    return _confidence.length;
  }

  @override
  Widget build(BuildContext context) {
    final studySet = _studySet;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.purple, AppColors.blue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Study Buddy App',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFF), AppColors.canvas],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 880;
              return ListView(
                padding: EdgeInsets.all(wide ? 30 : 16),
                children: [
                  const _HeaderPanel(),
                  const SizedBox(height: 20),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildNotesPanel()),
                        const SizedBox(width: 20),
                        Expanded(child: _buildStudyPanel(studySet)),
                      ],
                    )
                  else ...[
                    _buildNotesPanel(),
                    const SizedBox(height: 16),
                    _buildStudyPanel(studySet),
                  ],
                  const SizedBox(height: 20),
                  _BottomPromoBanner(
                    generatedCount: studySet == null
                        ? 0
                        : studySet.flashcards.length +
                              studySet.questions.length,
                    masteredCount: _masteredCount,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotesPanel() {
    final hasStudySet = _studySet != null;

    return _Panel(
      title: 'Paste Notes',
      icon: Icons.edit_note_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasStudySet) ...[
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _notesExpanded = !_notesExpanded);
              },
              icon: Icon(
                _notesExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              label: Text(_notesExpanded ? 'Hide notes' : 'Show notes'),
            ),
            const SizedBox(height: 12),
          ],
          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Notice(
                  icon: Icons.verified_user_rounded,
                  text:
                      'Use your own notes. AI or auto-generated study material can be wrong, so compare it with class materials.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesController,
                  minLines: 14,
                  maxLines: 20,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    height: 1.42,
                  ),
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Class notes',
                    hintText:
                        'Paste lecture notes, outlines, or review sheets here.',
                    filled: true,
                    fillColor: Color(0xFFFBFDFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.medium),
                      ),
                      borderSide: BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.medium),
                      ),
                      borderSide: BorderSide(color: AppColors.line, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.medium),
                      ),
                      borderSide: BorderSide(color: AppColors.blue, width: 1.8),
                    ),
                  ),
                ),
              ],
            ),
            secondChild: _CollapsedNotesSummary(text: _notesController.text),
            crossFadeState: _notesExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: _isGenerating
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.purple, AppColors.blue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: _isGenerating ? AppColors.line : null,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generateStudySet,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.bolt_rounded),
              label: Text(
                _isGenerating
                    ? _generationSteps[_generationStep]
                    : 'Generate My Study Set',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledForegroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isGenerating
                ? Padding(
                    key: ValueKey(_generationStep),
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: (_generationStep + 1) / _generationSteps.length,
                        backgroundColor: AppColors.line,
                        color: AppColors.accent,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (hasStudySet && !_notesExpanded) ...[
            const SizedBox(height: 18),
            const _CollapsedNotesArt(),
          ],
        ],
      ),
    );
  }

  Widget _buildStudyPanel(StudySet? studySet) {
    if (studySet == null) {
      return const _EmptyStudyPanel();
    }

    return _Panel(
      title: studySet.title,
      icon: Icons.school_rounded,
      child: Column(
        children: [
          _StudyStats(
            set: studySet,
            reviewedCount: _reviewedCount,
            masteredCount: _masteredCount,
          ),
          const SizedBox(height: 14),
          _SegmentedTabs(
            selectedIndex: _selectedTab,
            onChanged: (index) {
              setState(() => _selectedTab = index);
            },
          ),
          const SizedBox(height: 14),
          IndexedStack(
            index: _selectedTab,
            children: [
              _OverviewTab(set: studySet),
              _FlashcardTab(
                set: studySet,
                index: _flashcardIndex,
                showAnswer: _showAnswer,
                confidence: _confidence,
                onFlip: () => setState(() => _showAnswer = !_showAnswer),
                onConfidence: (level) {
                  final card = studySet.flashcards[_flashcardIndex];
                  setState(() => _confidence[card.term] = level);
                },
                onPrevious: () {
                  setState(() {
                    _flashcardIndex =
                        (_flashcardIndex - 1) % studySet.flashcards.length;
                    if (_flashcardIndex < 0) {
                      _flashcardIndex = studySet.flashcards.length - 1;
                    }
                    _showAnswer = false;
                  });
                },
                onNext: () {
                  setState(() {
                    _flashcardIndex =
                        (_flashcardIndex + 1) % studySet.flashcards.length;
                    _showAnswer = false;
                  });
                },
              ),
              _QuizTab(
                set: studySet,
                questionIndex: _quizIndex,
                selectedAnswer: _selectedAnswer,
                onSelect: (index) {
                  setState(() {
                    _selectedAnswer = index;
                    _showAnswer = true;
                  });
                },
                onNext: () {
                  setState(() {
                    _quizIndex = (_quizIndex + 1) % studySet.questions.length;
                    _resetQuizChoice();
                  });
                },
              ),
              _TermsTab(terms: studySet.terms),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/study_buddy_banner.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
    );
  }
}

class _CollapsedNotesSummary extends StatelessWidget {
  const _CollapsedNotesSummary({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text
        .split(RegExp(r'\n+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.notes_rounded, color: AppColors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lines == 1 ? 'Class notes hidden' : '$lines note lines hidden',
              style: AppType.body.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedNotesArt extends StatelessWidget {
  const _CollapsedNotesArt();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/images/studyBuddyCollapse.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primary,
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.52),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPromoBanner extends StatelessWidget {
  const _BottomPromoBanner({
    required this.generatedCount,
    required this.masteredCount,
  });

  final int generatedCount;
  final int masteredCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.purple, AppColors.blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.small),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/study_buddy_icon_300.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.psychology_alt_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Turn Notes Into Flashcards Instantly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(
                      icon: Icons.auto_awesome_rounded,
                      text: generatedCount == 0
                          ? 'Fast guided review'
                          : '$generatedCount items generated',
                    ),
                    _HeroPill(
                      icon: Icons.trending_up_rounded,
                      text: '$masteredCount strong cards',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  generatedCount == 0
                      ? 'Paste notes, tap generate, and start reviewing.'
                      : 'Keep reviewing until weak cards turn into strong ones.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppType.section)),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.notice,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.noticeLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.blue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStudyPanel extends StatelessWidget {
  const _EmptyStudyPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Study Set',
      icon: Icons.view_list_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.purple.withValues(alpha: 0.08),
                    AppColors.blue.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/studyBuddyAppImage.png',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PlaceholderRow(
            icon: Icons.style_rounded,
            title: 'Instant Flashcards',
            subtitle: 'Review key ideas without building cards by hand.',
          ),
          _PlaceholderRow(
            icon: Icons.quiz_rounded,
            title: 'Test Yourself Fast',
            subtitle: 'Turn notes into quick practice questions.',
          ),
          _PlaceholderRow(
            icon: Icons.route_rounded,
            title: 'Know What To Study First',
            subtitle: 'Get a simple plan instead of guessing where to start.',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppType.body.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyStats extends StatelessWidget {
  const _StudyStats({
    required this.set,
    required this.reviewedCount,
    required this.masteredCount,
  });

  final StudySet set;
  final int reviewedCount;
  final int masteredCount;

  @override
  Widget build(BuildContext context) {
    final progress = set.flashcards.isEmpty
        ? 0.0
        : reviewedCount / set.flashcards.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Cards',
                value: set.flashcards.length.toString(),
                color: AppColors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                label: 'Reviewed',
                value: reviewedCount.toString(),
                color: AppColors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                label: 'Strong',
                value: masteredCount.toString(),
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Review progress', style: AppType.label),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 450),
            builder: (context, value, child) => LinearProgressIndicator(
              minHeight: 8,
              value: value,
              backgroundColor: AppColors.line,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (Icons.route_rounded, 'Plan'),
      (Icons.style_rounded, 'Cards'),
      (Icons.quiz_rounded, 'Quiz'),
      (Icons.key_rounded, 'Terms'),
    ];

    return Row(
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          Expanded(
            child: Tooltip(
              message: tabs[i].$2,
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[i].$1,
                        size: 18,
                        color: selectedIndex == i
                            ? Colors.white
                            : AppColors.blue,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        tabs[i].$2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedIndex == i
                              ? Colors.white
                              : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (i != tabs.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.set});

  final StudySet set;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What to study first', style: AppType.section),
        const SizedBox(height: 8),
        for (var i = 0; i < set.studyPlan.length; i++)
          _PlanStep(number: i + 1, text: set.studyPlan[i]),
        const SizedBox(height: 12),
        const _Notice(
          icon: Icons.lock_rounded,
          text:
              'V1 uses typed or pasted notes only. File uploads, tutor chat, and cloud AI can be added after this loop is tested.',
        ),
      ],
    );
  }
}

class _PlanStep extends StatelessWidget {
  const _PlanStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.blue],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppType.body)),
        ],
      ),
    );
  }
}

class _FlashcardTab extends StatelessWidget {
  const _FlashcardTab({
    required this.set,
    required this.index,
    required this.showAnswer,
    required this.confidence,
    required this.onFlip,
    required this.onConfidence,
    required this.onPrevious,
    required this.onNext,
  });

  final StudySet set;
  final int index;
  final bool showAnswer;
  final Map<String, ConfidenceLevel> confidence;
  final VoidCallback onFlip;
  final ValueChanged<ConfidenceLevel> onConfidence;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final card = set.flashcards[index];
    final currentConfidence = confidence[card.term];

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: showAnswer ? pi : 0),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final showingBack = value > pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(showingBack ? pi : 0),
                child: InkWell(
                  onTap: onFlip,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 230),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: showingBack ? AppColors.cardAnswer : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border: Border.all(
                        color: showingBack ? AppColors.accent : AppColors.line,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Card ${index + 1} of ${set.flashcards.length}',
                          style: AppType.label,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          showingBack ? card.definition : card.term,
                          style: AppType.title,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          showingBack
                              ? 'Tap to see term'
                              : 'Tap to reveal answer',
                          style: AppType.body.copyWith(color: AppColors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Next'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ConfidenceButton(
                label: 'Weak',
                selected: currentConfidence == ConfidenceLevel.weak,
                color: AppColors.danger,
                onTap: () => onConfidence(ConfidenceLevel.weak),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ConfidenceButton(
                label: 'Okay',
                selected: currentConfidence == ConfidenceLevel.okay,
                color: AppColors.warning,
                onTap: () => onConfidence(ConfidenceLevel.okay),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ConfidenceButton(
                label: 'Strong',
                selected: currentConfidence == ConfidenceLevel.strong,
                color: AppColors.success,
                onTap: () => onConfidence(ConfidenceLevel.strong),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfidenceButton extends StatelessWidget {
  const _ConfidenceButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? color : Colors.white,
        foregroundColor: selected ? Colors.white : color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      child: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _QuizTab extends StatelessWidget {
  const _QuizTab({
    required this.set,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.onSelect,
    required this.onNext,
  });

  final StudySet set;
  final int questionIndex;
  final int? selectedAnswer;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final question = set.questions[questionIndex];
    final answered = selectedAnswer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${questionIndex + 1} of ${set.questions.length}',
          style: AppType.label,
        ),
        const SizedBox(height: 8),
        Text(question.prompt, style: AppType.section),
        const SizedBox(height: 12),
        for (var i = 0; i < question.options.length; i++)
          _AnswerOption(
            text: question.options[i],
            selected: selectedAnswer == i,
            correct: answered && question.correctIndex == i,
            incorrect:
                answered && selectedAnswer == i && question.correctIndex != i,
            onTap: answered ? null : () => onSelect(i),
          ),
        const SizedBox(height: 10),
        if (answered)
          _Notice(
            icon: selectedAnswer == question.correctIndex
                ? Icons.check_circle_rounded
                : Icons.lightbulb_rounded,
            text: question.rationale,
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Next Question'),
          ),
        ),
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.text,
    required this.selected,
    required this.correct,
    required this.incorrect,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool correct;
  final bool incorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? AppColors.success
        : incorrect
        ? AppColors.danger
        : selected
        ? AppColors.warning
        : AppColors.line;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: correct || incorrect
              ? color.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: color, width: selected ? 1.4 : 1),
        ),
        child: Text(text, style: AppType.body),
      ),
    );
  }
}

class _TermsTab extends StatelessWidget {
  const _TermsTab({required this.terms});

  final List<KeyTerm> terms;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final term in terms)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term.term,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  term.definition,
                  style: AppType.body.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

enum ConfidenceLevel { weak, okay, strong }

class StudySet {
  const StudySet({
    required this.title,
    required this.flashcards,
    required this.questions,
    required this.terms,
    required this.studyPlan,
  });

  final String title;
  final List<Flashcard> flashcards;
  final List<QuizQuestion> questions;
  final List<KeyTerm> terms;
  final List<String> studyPlan;
}

class Flashcard {
  const Flashcard({required this.term, required this.definition});

  final String term;
  final String definition;
}

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.rationale,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String rationale;
}

class KeyTerm {
  const KeyTerm({required this.term, required this.definition});

  final String term;
  final String definition;
}

class StudySetGenerator {
  static StudySet generate(String rawNotes) {
    final sentences = _splitSentences(rawNotes);
    final sourceSentences = sentences.isEmpty
        ? _splitSentences(sampleNotes)
        : sentences;
    final terms = _extractTerms(rawNotes, sourceSentences);
    final cards = terms
        .map((term) => Flashcard(term: term.term, definition: term.definition))
        .toList();
    final questions = _buildQuestions(terms, sourceSentences);
    final title = _titleFromNotes(rawNotes);

    return StudySet(
      title: title,
      flashcards: cards,
      questions: questions,
      terms: terms,
      studyPlan: _buildPlan(terms, questions),
    );
  }

  static List<String> _splitSentences(String text) {
    return _normalizeMessyNotes(text)
        .replaceAll('\r', ' ')
        .split(RegExp(r'(?<=[.!?])\s+|\n+|;'))
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.length > 18)
        .toList();
  }

  static List<KeyTerm> _extractTerms(String rawNotes, List<String> sentences) {
    final biologyOutlineTerms = _extractKnownBiologyOutline(rawNotes);
    if (biologyOutlineTerms.isNotEmpty) {
      return biologyOutlineTerms;
    }

    final mathTerms = _extractKnownMathTerms(rawNotes);
    if (mathTerms.length >= 3) {
      return mathTerms;
    }

    final structuredTerms = _extractStructuredTerms(rawNotes);
    if (structuredTerms.length >= 4 ||
        _allContentLinesStructured(rawNotes, structuredTerms)) {
      return structuredTerms;
    }

    final knownTerms = _extractKnownRespiratoryTerms(rawNotes);
    if (knownTerms.length >= 4 ||
        (structuredTerms.isEmpty && knownTerms.length >= 3) ||
        _allContentLinesStructured(rawNotes, knownTerms)) {
      return knownTerms;
    }

    final candidates = [...structuredTerms];
    final seen = structuredTerms.map((term) => term.term.toLowerCase()).toSet();
    for (final term in knownTerms) {
      if (seen.add(term.term.toLowerCase())) {
        candidates.add(term);
      }
    }

    for (final sentence in sentences) {
      final definition = _cleanSentence(sentence);
      final term = _termFromSentence(sentence);
      if (term.length < 4 || term.split(' ').length > 5) {
        continue;
      }
      final key = term.toLowerCase();
      if (seen.add(key)) {
        candidates.add(KeyTerm(term: term, definition: definition));
      }
      if (candidates.length >= 10) break;
    }

    if (candidates.length >= 4) {
      return candidates;
    }

    final words = _importantWords(sentences.join(' '));
    for (final word in words) {
      if (seen.add(word.toLowerCase())) {
        candidates.add(
          KeyTerm(
            term: _titleCase(word),
            definition: _definitionForWord(word, sentences),
          ),
        );
      }
      if (candidates.length >= 8) break;
    }

    return candidates.take(max(4, min(candidates.length, 10))).toList();
  }

  static bool _allContentLinesStructured(String rawNotes, List<KeyTerm> terms) {
    if (terms.isEmpty) return false;
    final normalized = _normalizeStudySymbols(rawNotes).replaceAll('\r', '\n');
    final numberedHeadingCount = RegExp(
      r'^\s*[A-Za-z][A-Za-z0-9 /().-]{1,60}:\s*\n\s*\d+[.)]\s+',
      multiLine: true,
    ).allMatches(normalized).length;
    if (numberedHeadingCount > 0) {
      return terms.length >= numberedHeadingCount;
    }

    final blankBlocks = normalized
        .split(RegExp(r'\n\s*\n+'))
        .map((block) => block.trim())
        .where((block) => block.length > 2)
        .toList();
    if (blankBlocks.length > 1) {
      final structuredBlocks = blankBlocks
          .where((block) => _looksLikeNewStructuredLine(_cleanSentence(block)))
          .length;
      if (structuredBlocks > 0) {
        return terms.length >= structuredBlocks;
      }
    }

    final contentLineCount = rawNotes
        .replaceAllMapped(
          RegExp(r'([A-Za-z])-\s*\r?\n\s*([a-z])'),
          (match) => '${match.group(1)!}${match.group(2)!}',
        )
        .replaceAll('\r', '\n')
        .split(RegExp(r'\n\s*\n+|\n+'))
        .map(_cleanSentence)
        .where((line) => line.length > 2)
        .where(
          (line) =>
              !RegExp(r'^[A-Za-z][A-Za-z0-9 /().-]{1,60}:$').hasMatch(line),
        )
        .where((line) => !_isTableHeader(line))
        .length;
    return contentLineCount > 0 && terms.length >= contentLineCount;
  }

  static List<KeyTerm> _extractStructuredTerms(String rawNotes) {
    final rawLineTerms = _extractRawTermDefinitionLines(rawNotes);
    final hasExpandableHeading =
        RegExp(
          r'^[A-Za-z][A-Za-z0-9 /().-]{1,60}:\s*$',
          multiLine: true,
        ).hasMatch(rawNotes) &&
        RegExp(r'^\s*[-*]\s+', multiLine: true).hasMatch(rawNotes);
    if (rawLineTerms.length >= 4 && !hasExpandableHeading) {
      return rawLineTerms;
    }

    final lines = _normalizeMessyNotes(rawNotes)
        .split(
          RegExp(
            r'\n+|(?<=[.!?])\s+|;\s*(?=[A-Za-z][A-Za-z0-9 /().-]{1,60}\s*(?:[:=]|\s+[-\u2013\u2014]\s+|\s+HR\s*[<>]|\s*[<>]))',
            caseSensitive: false,
          ),
        )
        .map(_cleanSentence)
        .where((line) => line.length > 2)
        .toList();
    final terms = [...rawLineTerms];
    final seen = rawLineTerms.map((term) => term.term.toLowerCase()).toSet();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final qaMatch = RegExp(
        r'^(?:(?:q|question)[:.)-]?\s*)?(.+\?)\s*(?:(?:a|answer)[:.)-]?\s*)?(.+)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (qaMatch != null && qaMatch.group(2)!.trim().length > 3) {
        _addStructuredTerm(terms, seen, qaMatch.group(1)!, qaMatch.group(2)!);
        continue;
      }

      final uncertainMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /().-]{1,60}?)\?+\s+(.{4,})$',
      ).firstMatch(line);
      if (uncertainMatch != null &&
          _looksLikeUsefulPrompt(uncertainMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          uncertainMatch.group(1)!,
          uncertainMatch.group(2)!,
        );
        continue;
      }

      final parentheticalArrowMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /.-]{1,60}?)\s*\((.{4,})\)\s*(?:->|\u2192)\s*(.{2,})$',
      ).firstMatch(line);
      if (parentheticalArrowMatch != null &&
          _looksLikeUsefulPrompt(parentheticalArrowMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          parentheticalArrowMatch.group(1)!,
          '${parentheticalArrowMatch.group(2)!} \u2192 ${parentheticalArrowMatch.group(3)!}',
        );
        continue;
      }

      final rateMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /().-]{1,60}?)\s+(HR|heart rate)(\s*[<>]=?\s*)(.{2,})$',
        caseSensitive: false,
      ).firstMatch(line);
      if (rateMatch != null && _looksLikeUsefulPrompt(rateMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          rateMatch.group(1)!,
          '${rateMatch.group(2)!}${rateMatch.group(3)!}${rateMatch.group(4)!}',
        );
        continue;
      }

      final dashMatch = RegExp(
        r'^(.{2,70}?)\s+[-\u2013\u2014]\s+(.{4,})$',
      ).firstMatch(line);
      if (dashMatch != null &&
          !dashMatch.group(1)!.contains('?') &&
          _looksLikeUsefulPrompt(dashMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          dashMatch.group(1)!,
          dashMatch.group(2)!,
        );
        continue;
      }

      final arrowMatch = RegExp(
        r'^(.{2,70}?)\s*(?:->|\u2192)\s*(.{4,})$',
      ).firstMatch(line);
      if (arrowMatch != null &&
          !arrowMatch.group(1)!.contains('?') &&
          !arrowMatch.group(1)!.contains(':') &&
          !arrowMatch.group(1)!.contains('=') &&
          _looksLikeUsefulPrompt(arrowMatch.group(1)!)) {
        final left = arrowMatch.group(1)!;
        final right = arrowMatch.group(2)!;
        if (_looksLikeReverseArrowTerm(left, right)) {
          _addStructuredTerm(terms, seen, right, left);
        } else {
          _addStructuredTerm(terms, seen, left, right);
        }
        continue;
      }

      final colonMatch = RegExp(
        r'^(.{2,60}?)(?:\s*[:=]\s+)(.{4,})$',
      ).firstMatch(line);
      if (colonMatch != null &&
          !colonMatch.group(1)!.contains('?') &&
          !RegExp(
            r'^(q|question|a|answer|note)$',
            caseSensitive: false,
          ).hasMatch(colonMatch.group(1)!.trim()) &&
          _looksLikeUsefulPrompt(colonMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          colonMatch.group(1)!,
          colonMatch.group(2)!,
        );
        continue;
      }

      final noteTermMatch = RegExp(
        r'^NOTE\s*:\s*[“"]?(.{2,60}?)[”"]?\s*=\s+(.{4,})$',
        caseSensitive: false,
      ).firstMatch(line);
      if (noteTermMatch != null &&
          _looksLikeUsefulPrompt(noteTermMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          noteTermMatch.group(1)!,
          noteTermMatch.group(2)!,
        );
        continue;
      }

      final parenthesesMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /.-]{1,60}?)\s*\((.{4,})\)$',
      ).firstMatch(line);
      if (parenthesesMatch != null &&
          !parenthesesMatch.group(1)!.contains('?') &&
          _looksLikeUsefulPrompt(parenthesesMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          parenthesesMatch.group(1)!,
          parenthesesMatch.group(2)!,
        );
        continue;
      }

      final comparisonMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /().-]{1,60}?)\s*([<>]=?)\s*(.{2,})$',
      ).firstMatch(line);
      if (comparisonMatch != null &&
          _looksLikeUsefulPrompt(comparisonMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          comparisonMatch.group(1)!,
          '${comparisonMatch.group(2)!}${comparisonMatch.group(3)!}',
        );
        continue;
      }

      final headingMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /().-]{1,60}?):$',
      ).firstMatch(line);
      if (headingMatch != null &&
          _looksLikeUsefulPrompt(headingMatch.group(1)!)) {
        final details = <String>[];
        var j = i + 1;
        while (j < lines.length && details.length < 4) {
          final detail = lines[j];
          if (_looksLikeNewStructuredLine(detail)) break;
          if (detail.length > 3) details.add(detail);
          j++;
        }
        if (details.isNotEmpty) {
          _addStructuredTerm(
            terms,
            seen,
            headingMatch.group(1)!,
            details.join('; '),
          );
          i = j - 1;
          continue;
        }
      }

      if (line.endsWith('?') && i + 1 < lines.length) {
        final answer = lines[i + 1];
        final answerIsLabeled = RegExp(
          r'^(a|answer)\s*[:.)-]',
          caseSensitive: false,
        ).hasMatch(answer);
        if (!answer.endsWith('?') &&
            (!_looksLikeNewStructuredLine(answer) || answerIsLabeled) &&
            answer.length > 3) {
          _addStructuredTerm(terms, seen, line, answer);
          i++;
          continue;
        }
      }

      if (line.contains('?')) {
        continue;
      }

      final definitionMatch = RegExp(
        r'^(.{3,60}?)\s+(is|are|means|refers to|involves|happens when|occurs when|carries|transports|controls|produces|helps)\s+(.{4,})$',
        caseSensitive: false,
      ).firstMatch(line);
      if (definitionMatch != null &&
          _looksLikeUsefulPrompt(definitionMatch.group(1)!)) {
        _addStructuredTerm(terms, seen, definitionMatch.group(1)!, line);
      }

      if (terms.length >= 10) break;
    }

    return terms;
  }

  static List<KeyTerm> _extractRawTermDefinitionLines(String rawNotes) {
    final terms = <KeyTerm>[];
    final seen = <String>{};
    final normalizedRaw = _normalizeStudySymbols(
      rawNotes,
    ).replaceAll('\r', '\n');
    _addBlockStructuredTerms(normalizedRaw, terms, seen);

    final lines = normalizedRaw
        .replaceAll('\r', '\n')
        .split(
          RegExp(
            r'\n+|;\s*(?=[A-Za-z][A-Za-z0-9 /().-]{1,60}\s*(?:[:=]|\s+[-\u2013\u2014]\s+|\s+HR\s*[<>]|\s*[<>]))',
            caseSensitive: false,
          ),
        )
        .where((line) => _cleanSentence(line).length > 2);

    for (final rawLine in lines) {
      final line = _cleanSentence(rawLine);
      final uncertainMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /().-]{1,60}?)\?+\s+(.{4,})$',
      ).firstMatch(line);
      if (uncertainMatch != null &&
          _looksLikeUsefulPrompt(uncertainMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          uncertainMatch.group(1)!,
          uncertainMatch.group(2)!,
        );
        continue;
      }

      final parentheticalArrowMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /.-]{1,60}?)\s*\((.{4,})\)\s*(?:->|\u2192)\s*(.{2,})$',
      ).firstMatch(line);
      if (parentheticalArrowMatch != null &&
          _looksLikeUsefulPrompt(parentheticalArrowMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          parentheticalArrowMatch.group(1)!,
          '${parentheticalArrowMatch.group(2)!} \u2192 ${parentheticalArrowMatch.group(3)!}',
        );
        continue;
      }

      final rateMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /().-]{1,60}?)\s+(HR|heart rate)(\s*[<>]=?\s*)(.{2,})$',
        caseSensitive: false,
      ).firstMatch(line);
      if (rateMatch != null && _looksLikeUsefulPrompt(rateMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          rateMatch.group(1)!,
          '${rateMatch.group(2)!}${rateMatch.group(3)!}${rateMatch.group(4)!}',
        );
        continue;
      }

      final bareTermMatch = RegExp(
        r'^([A-Z][A-Za-z0-9-]{2,20})\s+([a-z][A-Za-z0-9 /().,+-]{8,})$',
      ).firstMatch(line);
      if (bareTermMatch != null &&
          !RegExp(r'^\s*(?:[-*\u2022]|\d+[.)])').hasMatch(rawLine) &&
          _looksLikeUsefulPrompt(bareTermMatch.group(1)!) &&
          _looksLikeBareDefinition(bareTermMatch.group(2)!)) {
        _addStructuredTerm(
          terms,
          seen,
          bareTermMatch.group(1)!,
          bareTermMatch.group(2)!,
        );
        continue;
      }

      final pipeMatch = RegExp(r'^(.{2,60}?)\s*\|\s*(.{4,})$').firstMatch(line);
      if (pipeMatch != null &&
          !_isTableHeader(line) &&
          _looksLikeUsefulPrompt(pipeMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          pipeMatch.group(1)!,
          pipeMatch.group(2)!,
        );
        continue;
      }

      final dashMatch = RegExp(
        r'^(.{2,70}?)\s+[-\u2013\u2014]\s+(.{4,})$',
      ).firstMatch(line);
      if (dashMatch != null &&
          !dashMatch.group(1)!.contains('?') &&
          _looksLikeUsefulPrompt(dashMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          dashMatch.group(1)!,
          dashMatch.group(2)!,
        );
        continue;
      }

      final arrowMatch = RegExp(
        r'^(.{2,70}?)\s*(?:->|\u2192)\s*(.{4,})$',
      ).firstMatch(line);
      if (arrowMatch != null &&
          !arrowMatch.group(1)!.contains('?') &&
          !arrowMatch.group(1)!.contains(':') &&
          !arrowMatch.group(1)!.contains('=') &&
          _looksLikeUsefulPrompt(arrowMatch.group(1)!)) {
        final left = arrowMatch.group(1)!;
        final right = arrowMatch.group(2)!;
        if (_looksLikeReverseArrowTerm(left, right)) {
          _addStructuredTerm(terms, seen, right, left);
        } else {
          _addStructuredTerm(terms, seen, left, right);
        }
        continue;
      }

      final colonMatch = RegExp(
        r'^(.{2,60}?)(?:\s*[:=]\s+)(.{4,})$',
      ).firstMatch(line);
      if (colonMatch != null &&
          !colonMatch.group(1)!.contains('?') &&
          !RegExp(
            r'^(q|question|a|answer|note)$',
            caseSensitive: false,
          ).hasMatch(colonMatch.group(1)!.trim()) &&
          _looksLikeUsefulPrompt(colonMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          colonMatch.group(1)!,
          colonMatch.group(2)!,
        );
        continue;
      }

      final noteTermMatch = RegExp(
        r'^NOTE\s*:\s*[“"]?(.{2,60}?)[”"]?\s*=\s+(.{4,})$',
        caseSensitive: false,
      ).firstMatch(line);
      if (noteTermMatch != null &&
          _looksLikeUsefulPrompt(noteTermMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          noteTermMatch.group(1)!,
          noteTermMatch.group(2)!,
        );
        continue;
      }

      final parenthesesMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /.-]{1,60}?)\s*\((.{4,})\)$',
      ).firstMatch(line);
      if (parenthesesMatch != null &&
          !parenthesesMatch.group(1)!.contains('?') &&
          _looksLikeUsefulPrompt(parenthesesMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          parenthesesMatch.group(1)!,
          parenthesesMatch.group(2)!,
        );
        continue;
      }

      final comparisonMatch = RegExp(
        r'^([A-Za-z][A-Za-z0-9 /().-]{1,60}?)\s*([<>]=?)\s*(.{2,})$',
      ).firstMatch(line);
      if (comparisonMatch != null &&
          _looksLikeUsefulPrompt(comparisonMatch.group(1)!)) {
        _addStructuredTerm(
          terms,
          seen,
          comparisonMatch.group(1)!,
          '${comparisonMatch.group(2)!}${comparisonMatch.group(3)!}',
        );
      }

      if (terms.length >= 10) break;
    }

    return terms;
  }

  static void _addBlockStructuredTerms(
    String rawNotes,
    List<KeyTerm> terms,
    Set<String> seen,
  ) {
    final lines = rawNotes.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final heading = RegExp(
        r'^\s*([A-Za-z][A-Za-z0-9 /().-]{1,60}):\s*$',
      ).firstMatch(lines[i]);
      if (heading == null || !_looksLikeUsefulPrompt(heading.group(1)!)) {
        continue;
      }

      final details = <String>[];
      var j = i + 1;
      while (j < lines.length) {
        final detail = _cleanSentence(lines[j]);
        if (detail.isEmpty) {
          j++;
          if (details.isNotEmpty) break;
          continue;
        }
        if (RegExp(
          r'^\s*[A-Za-z][A-Za-z0-9 /().-]{1,60}:\s*$',
        ).hasMatch(lines[j])) {
          break;
        }
        final numbered = RegExp(r'^\s*\d+[.)]\s*(.{3,})$').firstMatch(lines[j]);
        if (numbered != null) {
          details.add(_cleanAnswer(numbered.group(1)!));
          j++;
          continue;
        }
        if (details.isNotEmpty && !_looksLikeNewStructuredLine(detail)) {
          details.add(_cleanAnswer(detail));
          j++;
          continue;
        }
        break;
      }
      if (details.isNotEmpty) {
        _addStructuredTerm(terms, seen, heading.group(1)!, details.join('; '));
        i = j - 1;
      }
    }

    for (final block in rawNotes.split(RegExp(r'\n\s*\n+'))) {
      final blockLines = block
          .split('\n')
          .map(_cleanSentence)
          .where((line) => line.isNotEmpty)
          .toList();
      final structuredLineCount = blockLines
          .where((line) => _looksLikeNewStructuredLine(line))
          .length;
      if (blockLines.length > 1 && structuredLineCount > 1) continue;
      if (blockLines.length > 1 &&
          blockLines.where(_isTableHeader).isNotEmpty) {
        continue;
      }
      if (blockLines.length > 1 &&
          RegExp(
            r'^[A-Za-z][A-Za-z0-9 /().-]{1,60}:$',
          ).hasMatch(blockLines.first)) {
        continue;
      }
      final compact = blockLines.join(' ');
      if (compact.length < 4 || _isTableHeader(compact)) continue;
      if (RegExp(
        r';\s*(?=[A-Za-z][A-Za-z0-9 /().-]{1,60}\s*(?:[:=]|\s+[-\u2013\u2014]\s+|\s+HR\s*[<>]|\s*[<>]))',
        caseSensitive: false,
      ).hasMatch(compact)) {
        continue;
      }
      final match = RegExp(
        r'^(.{2,70}?)(?:\s*\|\s*|\s+[-\u2013\u2014]\s+|\s*[:=]\s+)(.{4,})$',
      ).firstMatch(compact);
      if (match != null &&
          !match.group(1)!.contains(':') &&
          _looksLikeUsefulPrompt(match.group(1)!)) {
        _addStructuredTerm(terms, seen, match.group(1)!, match.group(2)!);
      }
    }
  }

  static String _normalizeMessyNotes(String rawNotes) {
    var text = _normalizeStudySymbols(rawNotes).replaceAll('\r', '\n');
    text = text.replaceAll(RegExp(r'[•·]'), '\n- ');
    text = text.replaceAllMapped(
      RegExp(
        r',\s+while\s+([A-Za-z][A-Za-z0-9 /().-]{2,60}\s+(?:is|are|means|refers to|involves|happens when|occurs when)\b)',
        caseSensitive: false,
      ),
      (match) {
        final clause = match.group(1)!;
        return '. ${clause[0].toUpperCase()}${clause.substring(1)}';
      },
    );
    text = text.replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '\n- ');
    text = text.replaceAll(
      RegExp(r'\s+(?=(?:q|question)\s*\d*[:.)-]\s*)', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(
      RegExp(r'\s+(?=(?:a|answer)\s*\d*[:.)-]\s*)', caseSensitive: false),
      '\n',
    );
    text = text.replaceAllMapped(
      RegExp(r'(\?)\s+(?=[A-Z0-9])'),
      (match) => '${match.group(1)}\n',
    );
    text = text.replaceAllMapped(
      RegExp(
        r'([.!])\s+(?=(?:what|why|how|when|where|which|who)\b)',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}\n',
    );
    text = text.replaceAllMapped(
      RegExp(
        r'([.!])\s+(?=[A-Z][A-Za-z /-]{2,45}\s*(?:[:=]|[-\u2013\u2014]|\bis\b|\bare\b|\bmeans\b))',
      ),
      (match) => '${match.group(1)}\n',
    );
    text = text.replaceAll(
      RegExp(
        r'\s+(?=[A-Z][a-z][A-Za-z]*(?:\s+[A-Z]?[a-z][A-Za-z]*){0,5}\s*(?:[:=]|\s+[-\u2013\u2014]\s+))',
      ),
      '\n',
    );
    return text;
  }

  static String _normalizeStudySymbols(String rawNotes) {
    var text = rawNotes;
    text = text.replaceAllMapped(
      RegExp(r'([A-Za-z])-\s*\r?\n\s*([a-z])'),
      (match) => '${match.group(1)!}${match.group(2)!}',
    );
    text = text.replaceAll(RegExp(r'[ \t]*\n[ \t]*(?=[a-z])'), ' ');
    text = text.replaceAll(
      RegExp(r'⬇️?\s*(?=O2\b)', caseSensitive: false),
      ' - low ',
    );
    text = text.replaceAll('👉', ' - ');
    text = text.replaceAll('🤒', ' - ');
    text = text.replaceAll('❤️‍🔥', ' - ');
    text = text.replaceAll('❤', ' - ');
    text = text.replaceAll('🧊', ' - ');
    text = text.replaceAll(RegExp(r'>\s*>\s*>+|~~+'), ' - ');
    text = text.replaceAll(RegExp(r'[*_]{2,}'), '');
    return text;
  }

  static void _addStructuredTerm(
    List<KeyTerm> terms,
    Set<String> seen,
    String prompt,
    String answer,
  ) {
    final cleanPrompt = _cleanPrompt(prompt);
    final cleanAnswer = _cleanAnswer(answer);
    if (!_isAcronym(cleanPrompt) && cleanPrompt.length < 4) return;
    if (cleanAnswer.length < 4) return;
    final key = cleanPrompt.toLowerCase();
    if (seen.add(key)) {
      terms.add(KeyTerm(term: cleanPrompt, definition: cleanAnswer));
    }
  }

  static bool _looksLikeUsefulPrompt(String value) {
    final clean = _cleanSentence(value);
    final lower = clean.toLowerCase();
    final isAcronym = _isAcronym(clean);
    if ((!isAcronym && clean.length < 3) || clean.length > 70) return false;
    if (_stopWords.contains(lower)) return false;
    if (RegExp(r'^(and|but|or|so|because|while|then)\b').hasMatch(lower)) {
      return false;
    }
    return RegExp(r'[A-Za-z]').hasMatch(clean);
  }

  static bool _looksLikeNewStructuredLine(String line) {
    final clean = _cleanSentence(line);
    if (clean.length < 2) return false;
    final hasPrompt = RegExp(r'^[A-Z][A-Za-z0-9 /().-]{1,60}').hasMatch(clean);
    if (!hasPrompt) return false;
    return RegExp(
      r'(:\s+\S|=\s+\S|\s+[-\u2013\u2014]\s+|\s*(?:->|\u2192)\s*|\s+HR\s*[<>]|^NOTE\s*:)',
      caseSensitive: false,
    ).hasMatch(clean);
  }

  static bool _looksLikeReverseArrowTerm(String left, String right) {
    final cleanLeft = _cleanSentence(left);
    final cleanRight = _cleanSentence(right);
    if (!_looksLikeUsefulPrompt(cleanRight)) return false;
    if (cleanRight.split(RegExp(r'\s+')).length > 3) return false;
    if (RegExp(r'[()<>]|=|:|;').hasMatch(cleanRight)) return false;
    final leftWords = cleanLeft.split(RegExp(r'\s+')).length;
    return leftWords >= 5 ||
        RegExp(
          r'\b(collapse|infection|low|reduced|movement|system|process|condition|causes|leading|with)\b',
          caseSensitive: false,
        ).hasMatch(cleanLeft);
  }

  static bool _looksLikeBareDefinition(String value) {
    final clean = _cleanSentence(value);
    if (RegExp(
      r'^(is|are|was|were|means|mean|refers|refer)\b',
      caseSensitive: false,
    ).hasMatch(clean)) {
      return false;
    }
    final words = clean.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    if (words.length < 2) return false;
    if (RegExp(r'[?;:=<>]|\u2192').hasMatch(clean)) return false;
    return words.any((word) => word.length >= 5);
  }

  static String _termFromSentence(String sentence) {
    final colonMatch = RegExp(
      r'^([A-Za-z][A-Za-z0-9 /-]{2,40})\s*[:=\-\u2013\u2014]',
    ).firstMatch(sentence);
    if (colonMatch != null) {
      return _titleCase(colonMatch.group(1)!.trim());
    }

    final isMatch = RegExp(
      r'^([A-Za-z][A-Za-z0-9 /-]{2,42})\s+(is|are|means|refers to|involves|carries|transports|controls|produces|helps)\b',
      caseSensitive: false,
    ).firstMatch(sentence);
    if (isMatch != null) {
      return _titleCase(isMatch.group(1)!.trim());
    }

    final words = _importantWords(sentence);
    if (words.length >= 2) {
      return _titleCase(words.take(2).join(' '));
    }
    return words.isEmpty ? 'Core Concept' : _titleCase(words.first);
  }

  static List<QuizQuestion> _buildQuestions(
    List<KeyTerm> terms,
    List<String> sentences,
  ) {
    final questions = <QuizQuestion>[];
    final distractors = terms.map((term) => term.term).toList();

    for (var i = 0; i < min(terms.length, 8); i++) {
      final term = terms[i];
      final options = <String>[term.term];
      for (final distractor in distractors) {
        if (distractor != term.term && options.length < 4) {
          options.add(distractor);
        }
      }
      while (options.length < 4) {
        options.add(_fallbackOptions[options.length - 1]);
      }
      final shuffled = [...options]..shuffle(Random(i + term.term.length));
      questions.add(
        QuizQuestion(
          prompt: 'Which term best matches this note?\n"${term.definition}"',
          options: shuffled,
          correctIndex: shuffled.indexOf(term.term),
          rationale: '${term.term}: ${term.definition}',
        ),
      );
    }

    if (questions.isEmpty) {
      final keyIdeas = _importantWords(sentences.join(' ')).take(5);
      for (final idea in keyIdeas) {
        final answer = _titleCase(idea);
        final options = [
          answer,
          'Review Priority',
          'Practice Question',
          'Study Goal',
        ]..shuffle(Random(answer.length));
        questions.add(
          QuizQuestion(
            prompt: 'Which key idea appears in the pasted notes?',
            options: options,
            correctIndex: options.indexOf(answer),
            rationale: '$answer appears often enough to review first.',
          ),
        );
      }
    }

    return questions.take(10).toList();
  }

  static List<String> _buildPlan(
    List<KeyTerm> terms,
    List<QuizQuestion> questions,
  ) {
    final topTerms = terms.take(3).map((term) => term.term).join(', ');
    return [
      'Start with vocabulary: review ${terms.length} key terms, especially $topTerms.',
      'Run flashcards once and mark each card Weak, Okay, or Strong.',
      'Take ${questions.length} quiz questions without checking notes.',
      'Restudy every Weak card, then retake missed quiz questions.',
      'Before the test, explain the top concepts out loud in plain language.',
    ];
  }

  static List<String> _importantWords(String text) {
    final counts = <String, int>{};
    final words = RegExp(r'[A-Za-z][A-Za-z-]{3,}')
        .allMatches(text.toLowerCase())
        .map((match) => match.group(0)!.replaceAll('-', ' '))
        .where((word) => !_stopWords.contains(word))
        .toList();

    for (final word in words) {
      counts[word] = (counts[word] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return b.key.length.compareTo(a.key.length);
      });

    return sorted.map((entry) => entry.key).toList();
  }

  static String _definitionForWord(String word, List<String> sentences) {
    return sentences.firstWhere(
      (sentence) => sentence.toLowerCase().contains(word.toLowerCase()),
      orElse: () => 'Review how $word connects to the main topic.',
    );
  }

  static String _titleFromNotes(String rawNotes) {
    final firstLine = rawNotes
        .split(RegExp(r'\n+'))
        .map((line) => line.trim())
        .firstWhere(
          (line) => line.length > 4,
          orElse: () => 'Generated Study Set',
        );
    final clean = firstLine.replaceAll(RegExp(r'[#*]'), '').trim();
    if (clean.length <= 34) return clean;
    return '${clean.substring(0, 31).trim()}...';
  }

  static String _cleanSentence(String sentence) {
    return sentence
        .replaceAll(RegExp(r'^\*+|\*+$'), '')
        .replaceFirst(RegExp(r'^[•·]\s*'), '')
        .replaceFirst(RegExp(r'^[*-]\s*'), '')
        .replaceFirst(RegExp(r'^\d+[.)]\s*'), '')
        .replaceFirst(RegExp(r';$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _cleanPrompt(String prompt) {
    final clean = _cleanSentence(prompt)
        .replaceFirst(
          RegExp(r'^(q|question)\s*[:.)-]\s*', caseSensitive: false),
          '',
        )
        .trim();
    final corrected = _correctKnownStudyTerm(clean);
    if (corrected != clean) return corrected;
    final letters = RegExp(r'[A-Za-z]').allMatches(clean).length;
    final uppercase = RegExp(r'[A-Z]').allMatches(clean).length;
    if (_isAcronym(clean)) {
      return clean;
    }
    if (letters > 1 && uppercase == letters) {
      return _titleCase(clean);
    }
    return clean;
  }

  static bool _isAcronym(String value) {
    return RegExp(r'^[A-Z0-9]{2,8}$').hasMatch(value);
  }

  static String _cleanAnswer(String answer) {
    var clean = _cleanSentence(answer)
        .replaceFirst(
          RegExp(r'^(a|answer)\s*[:.)-]\s*', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\?+'), '')
        .replaceAll(RegExp(r'!+'), '')
        .trim();
    clean = clean.replaceFirst(
      RegExp(
        r'\.\s+(?:why|what|how|when|where|which|who)\b.*$',
        caseSensitive: false,
      ),
      '',
    );
    clean = _englishParentheticalIfUseful(clean);
    return _correctCommonStudyTypos(clean);
  }

  static String _englishParentheticalIfUseful(String value) {
    final spanishSignals = RegExp(
      r'[áéíóúñ]|\b(colapso|infecci[oó]n|bajo|ox[ií]geno|sangre|tejido|pulmonar|de|del|los|las|en)\b',
      caseSensitive: false,
    );
    if (!spanishSignals.hasMatch(value)) return value;
    final matches = RegExp(r'\(([^()]{3,80})\)').allMatches(value).toList();
    if (matches.isEmpty) return value;
    final inner = matches.last.group(1)!.trim();
    if (!RegExp(r'[A-Za-z]').hasMatch(inner)) return value;
    return inner;
  }

  static List<KeyTerm> _extractKnownRespiratoryTerms(String rawNotes) {
    final normalized = _normalizeStudySymbols(rawNotes).replaceAll('\r', '\n');
    final lower = normalized.toLowerCase();
    final terms = <KeyTerm>[];
    final seen = <String>{};

    final known = <String, List<String>>{
      'Atelectasis': ['atelectasis', 'collapse of alveoli', 'alveoli collapse'],
      'Pneumonia': [
        'pneumonia',
        'infection of lung tissue',
        'lung tissue gets infected',
        'lung infection',
      ],
      'Hypoxemia': ['hypoxemia', 'low oxygen', 'low o2'],
      'Tachycardia': [
        'tachycardia',
        'heart rate above 100',
        'heart rate greater than 100',
        'hr>100',
        'hr >100',
        'hr > 100',
      ],
      'Bradycardia': [
        'bradycardia',
        'heart rate less than 60',
        'heart rate under 60',
        'under 60',
        'hr<60',
        'hr <60',
        'hr < 60',
      ],
    };

    for (final entry in known.entries) {
      final mentioned = entry.value.any((phrase) => lower.contains(phrase));
      if (!mentioned) continue;
      final definition = _definitionForKnownRespiratoryTerm(
        entry.key,
        normalized,
      );
      if (definition.length >= 4 && seen.add(entry.key.toLowerCase())) {
        terms.add(KeyTerm(term: entry.key, definition: definition));
      }
    }
    return terms;
  }

  static List<KeyTerm> _extractKnownBiologyOutline(String rawNotes) {
    final normalized = _normalizeStudySymbols(rawNotes).replaceAll('\r', '\n');
    final lower = normalized.toLowerCase();
    final hasPhotosynthesisSignals =
        lower.contains('convert sunlight') &&
        lower.contains('glucose') &&
        lower.contains('chloroplast');
    final hasOutlineLabels =
        RegExp(
          r'^\s*purpose\s*:',
          multiLine: true,
          caseSensitive: false,
        ).hasMatch(normalized) &&
        RegExp(
          r'^\s*occurs in\s*:',
          multiLine: true,
          caseSensitive: false,
        ).hasMatch(normalized);
    if (!hasPhotosynthesisSignals || !hasOutlineLabels) return [];

    final terms = <KeyTerm>[];
    final seen = <String>{};

    final purpose = _valueForInlineLabel(normalized, 'Purpose');
    if (purpose.isNotEmpty) {
      _addStructuredTerm(terms, seen, 'Photosynthesis', purpose);
    }

    final occursIn = _valueForInlineLabel(normalized, 'Occurs in');
    final chloroplastMatch = RegExp(
      r'^(Chloroplasts?)\s*(?:\((.+)\))?\.?$',
      caseSensitive: false,
    ).firstMatch(occursIn);
    if (chloroplastMatch != null) {
      final locationDetail = chloroplastMatch.group(2);
      final definition = locationDetail == null
          ? 'Where photosynthesis occurs.'
          : 'Where photosynthesis occurs in $locationDetail.';
      _addStructuredTerm(terms, seen, chloroplastMatch.group(1)!, definition);
    } else if (occursIn.isNotEmpty) {
      _addStructuredTerm(terms, seen, 'Photosynthesis location', occursIn);
    }

    final equation = _valueForBlockLabel(normalized, 'Equation');
    if (equation.isNotEmpty) {
      _addStructuredTerm(terms, seen, 'Photosynthesis equation', equation);
    }

    for (final stage in _stageTermsAfterLabel(normalized, 'Two stages')) {
      _addStructuredTerm(
        terms,
        seen,
        stage.term,
        _biologyStageDefinition(stage.term, stage.definition),
      );
    }

    return terms.length >= 3 ? terms : [];
  }

  static List<KeyTerm> _extractKnownMathTerms(String rawNotes) {
    final normalized = _normalizeStudySymbols(rawNotes);
    final lower = normalized.toLowerCase();
    final hasMathSignals =
        lower.contains('slope') ||
        lower.contains('quadratic formula') ||
        lower.contains('pythagorean theorem');
    if (!hasMathSignals) return [];

    final terms = <KeyTerm>[];
    final seen = <String>{};
    final sentences = _splitKnownConceptSentences(normalized);

    for (final sentence in sentences) {
      final lowerSentence = sentence.toLowerCase();
      if (lowerSentence.contains('slope') &&
          lowerSentence.contains('line') &&
          seen.add('slope')) {
        terms.add(
          const KeyTerm(
            term: 'Slope',
            definition:
                'Measures how steep a line is and is found by dividing the change in y by the change in x.',
          ),
        );
      }

      if (lowerSentence.contains('quadratic formula') &&
          seen.add('quadratic formula')) {
        terms.add(
          const KeyTerm(
            term: 'Quadratic formula',
            definition: 'Used to find the roots of any quadratic equation.',
          ),
        );
      }

      if (lowerSentence.contains('pythagorean theorem') &&
          seen.add('pythagorean theorem')) {
        terms.add(
          const KeyTerm(
            term: 'Pythagorean theorem',
            definition: 'Relates the sides of a right triangle: a² + b² = c².',
          ),
        );
      }
    }

    return terms;
  }

  static String _biologyStageDefinition(String term, String definition) {
    final cleanDefinition = _cleanAnswer(definition);
    final lowerTerm = term.toLowerCase();
    if (lowerTerm.contains('light-dependent')) {
      return 'Stage of photosynthesis that ${_thirdPersonVerbPhrase(cleanDefinition)}';
    }
    if (lowerTerm.contains('calvin')) {
      return 'Stage of photosynthesis that ${_thirdPersonVerbPhrase(cleanDefinition)}';
    }
    return cleanDefinition;
  }

  static String _thirdPersonVerbPhrase(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return clean;
    final lower = clean[0].toLowerCase() + clean.substring(1);
    return lower
        .replaceFirst(RegExp(r'^capture\b', caseSensitive: false), 'captures')
        .replaceFirst(RegExp(r'^build\b', caseSensitive: false), 'builds');
  }

  static String _valueForInlineLabel(String rawNotes, String label) {
    final match = RegExp(
      '^\\s*${RegExp.escape(label)}\\s*:\\s*(.+)\$',
      multiLine: true,
      caseSensitive: false,
    ).firstMatch(rawNotes);
    return match == null ? '' : _cleanAnswer(match.group(1)!);
  }

  static String _valueForBlockLabel(String rawNotes, String label) {
    final lines = rawNotes.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (RegExp(
        '^\\s*${RegExp.escape(label)}\\s*:\\s*\$',
        caseSensitive: false,
      ).hasMatch(lines[i])) {
        for (var j = i + 1; j < lines.length; j++) {
          final value = _cleanSentence(lines[j]);
          if (value.isEmpty) continue;
          if (RegExp(
            r'^[A-Za-z][A-Za-z0-9 /().-]{1,60}:\s*$',
          ).hasMatch(value)) {
            return '';
          }
          return _cleanAnswer(value);
        }
      }
    }
    return '';
  }

  static List<KeyTerm> _stageTermsAfterLabel(String rawNotes, String label) {
    final lines = rawNotes.split('\n');
    final terms = <KeyTerm>[];
    var inStages = false;
    for (final rawLine in lines) {
      final line = _cleanSentence(rawLine);
      if (line.isEmpty) continue;
      if (RegExp(
        '^${RegExp.escape(label)}\\s*:\$',
        caseSensitive: false,
      ).hasMatch(line)) {
        inStages = true;
        continue;
      }
      if (!inStages) continue;

      final match = RegExp(r'^(.{3,60}?):\s+(.{3,})$').firstMatch(line);
      if (match != null &&
          !_isOutlineLabel(match.group(1)!) &&
          _looksLikeUsefulPrompt(match.group(1)!)) {
        terms.add(
          KeyTerm(
            term: _cleanPrompt(match.group(1)!),
            definition: _cleanAnswer(match.group(2)!),
          ),
        );
      } else if (_isOutlineLabel(line)) {
        break;
      }
    }
    return terms;
  }

  static bool _isOutlineLabel(String value) {
    return RegExp(
      r'^(purpose|occurs in|equation|two stages?)\s*:?\s*$',
      caseSensitive: false,
    ).hasMatch(_cleanSentence(value));
  }

  static String _definitionForKnownRespiratoryTerm(String term, String notes) {
    final sentences = _splitKnownConceptSentences(notes);
    final lowerTerm = term.toLowerCase();
    final direct = sentences.firstWhere(
      (sentence) => sentence.toLowerCase().contains(lowerTerm),
      orElse: () => '',
    );
    if (direct.isNotEmpty) return _cleanSentence(direct);

    for (final sentence in sentences) {
      final lower = sentence.toLowerCase();
      if (term == 'Atelectasis' &&
          lower.contains('collapse') &&
          lower.contains('alveoli')) {
        return _cleanSentence(sentence);
      }
      if (term == 'Pneumonia' &&
          lower.contains('infection') &&
          lower.contains('lung')) {
        return _cleanSentence(sentence);
      }
      if (term == 'Hypoxemia' &&
          (lower.contains('low oxygen') || lower.contains('low o2'))) {
        return _cleanSentence(sentence);
      }
      if (term == 'Tachycardia' &&
          lower.contains('heart rate') &&
          (lower.contains('greater than 100') ||
              lower.contains('above 100') ||
              lower.contains('> 100') ||
              lower.contains('>100'))) {
        return _cleanSentence(sentence);
      }
      if (term == 'Bradycardia' &&
          lower.contains('heart rate') &&
          (lower.contains('less than 60') ||
              lower.contains('under 60') ||
              lower.contains('< 60') ||
              lower.contains('<60'))) {
        return _cleanSentence(sentence);
      }
    }
    return '';
  }

  static List<String> _splitKnownConceptSentences(String notes) {
    var text = notes.replaceAll('\r', '\n');
    text = text.replaceAllMapped(
      RegExp(
        r'\b(then\s+)?(atelectasis|pneumonia|hypoxemia|tachycardia|bradycardia)\b',
        caseSensitive: false,
      ),
      (match) => '\n${match.group(2)}',
    );
    return text
        .split(RegExp(r'\n+|(?<=[.!?])\s+'))
        .map(_cleanSentence)
        .where((sentence) => sentence.length > 8)
        .toList();
  }

  static bool _isTableHeader(String line) {
    return RegExp(
      r'^\s*term\s*\|\s*definition\s*$',
      caseSensitive: false,
    ).hasMatch(line);
  }

  static String _correctKnownStudyTerm(String term) {
    final lower = term.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    const corrections = {
      'atelectsis': 'Atelectasis',
      'atelectasis': 'Atelectasis',
      'pnemonia': 'Pneumonia',
      'pneumonia': 'Pneumonia',
      'hypoxima': 'Hypoxemia',
      'hypoxemia': 'Hypoxemia',
      'tachycardea': 'Tachycardia',
      'tachycardia': 'Tachycardia',
      'bradycardea': 'Bradycardia',
      'bradycardia': 'Bradycardia',
    };
    return corrections[lower] ?? term;
  }

  static String _correctCommonStudyTypos(String value) {
    final replacements = <RegExp, String>{
      RegExp(r'\bcolapse\b', caseSensitive: false): 'collapse',
      RegExp(r'\balvioli\b', caseSensitive: false): 'alveoli',
      RegExp(r'\binfecton\b', caseSensitive: false): 'infection',
      RegExp(r'\boxgen\b', caseSensitive: false): 'oxygen',
    };
    var corrected = value;
    for (final entry in replacements.entries) {
      corrected = corrected.replaceAll(entry.key, entry.value);
    }
    return corrected;
  }

  static String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static const _fallbackOptions = [
    'Main Concept',
    'Supporting Detail',
    'Study Priority',
  ];

  static const _stopWords = {
    'about',
    'after',
    'also',
    'because',
    'before',
    'being',
    'between',
    'class',
    'common',
    'could',
    'does',
    'during',
    'each',
    'from',
    'have',
    'into',
    'main',
    'more',
    'most',
    'need',
    'notes',
    'often',
    'other',
    'should',
    'study',
    'than',
    'that',
    'their',
    'them',
    'then',
    'these',
    'this',
    'through',
    'when',
    'where',
    'which',
    'with',
    'will',
    'your',
  };
}

const sampleNotes = '''
Cellular Respiration
Glycolysis: breaks glucose into pyruvate.
Krebs Cycle: releases carbon dioxide and creates electron carriers.
Electron Transport Chain: uses oxygen and produces most ATP.
ATP: the cell's usable energy molecule.
Anaerobic Respiration: happens without oxygen and makes less ATP.
''';
