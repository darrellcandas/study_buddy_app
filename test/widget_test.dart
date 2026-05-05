import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_buddy_app/main.dart';

void main() {
  Map<String, String> flashcardMap(StudySet set) => {
    for (final card in set.flashcards) card.term: card.definition,
  };

  test('builds clean flashcards from question-answer notes', () {
    const notes = '''
What is blood pressure?
The force of blood pushing against the walls of arteries

What is dehydration?
A condition where the body does not have enough fluids

What does the respiratory system do?
It allows the body to take in oxygen and remove carbon dioxide
''';

    final set = StudySetGenerator.generate(notes);

    expect(set.flashcards.first.term, 'What is blood pressure?');
    expect(
      set.flashcards.first.definition,
      'The force of blood pushing against the walls of arteries',
    );
    expect(set.flashcards[1].term, 'What is dehydration?');
    expect(
      set.flashcards[1].definition,
      'A condition where the body does not have enough fluids',
    );
  });

  test('builds flashcards from jammed mixed-format notes', () {
    const notes =
        'Blood pressure is the force of blood pushing against artery walls. '
        'What is normal body temperature in Celsius? About 37 C '
        'Dehydration: a condition where the body does not have enough fluids. '
        'Respiratory system - takes in oxygen and removes carbon dioxide. '
        'Q: What is infection? A: The invasion and growth of harmful microorganisms.';

    final set = StudySetGenerator.generate(notes);
    final fronts = set.flashcards.map((card) => card.term).toList();
    final backs = set.flashcards.map((card) => card.definition).toList();

    expect(fronts, contains('Blood pressure'));
    expect(fronts, contains('What is normal body temperature in Celsius?'));
    expect(fronts, contains('Dehydration'));
    expect(fronts, contains('Respiratory system'));
    expect(fronts, contains('What is infection?'));
    expect(backs, contains('About 37 C'));
  });

  test('cleans separated question and answer labels', () {
    const notes = '''
Q: What is homeostasis?
A: The body keeping internal conditions stable

Question: What does insulin do?
Answer: It helps glucose move from blood into cells
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(
      cards['What is homeostasis?'],
      'The body keeping internal conditions stable',
    );
    expect(
      cards['What does insulin do?'],
      'It helps glucose move from blood into cells',
    );
  });

  test('builds flashcards from numbered and equals-sign notes', () {
    const notes = '''
1. Osmosis = movement of water across a semipermeable membrane.
2. Diffusion: movement of particles from high to low concentration.
3. Active transport - movement that requires cellular energy.
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(
      cards['Osmosis'],
      'movement of water across a semipermeable membrane.',
    );
    expect(
      cards['Diffusion'],
      'movement of particles from high to low concentration.',
    );
    expect(
      cards['Active transport'],
      'movement that requires cellular energy.',
    );
  });

  test('builds flashcards from bullet definition sentences', () {
    const notes = '''
- Photosynthesis is the process plants use to make glucose from light.
- Chlorophyll is the green pigment that absorbs light energy.
- Stomata are tiny openings that control gas exchange in leaves.
- Xylem carries water from roots to the rest of the plant.
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(
      cards['Photosynthesis'],
      'Photosynthesis is the process plants use to make glucose from light.',
    );
    expect(
      cards['Chlorophyll'],
      'Chlorophyll is the green pigment that absorbs light energy.',
    );
    expect(
      cards['Stomata'],
      'Stomata are tiny openings that control gas exchange in leaves.',
    );
    expect(
      cards['Xylem'],
      'Xylem carries water from roots to the rest of the plant.',
    );
  });

  testWidgets('generates a local study set from pasted notes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudyBuddyApp());

    expect(find.text('Study Buddy App'), findsOneWidget);
    expect(find.text('Generate My Study Set'), findsOneWidget);

    await tester.ensureVisible(find.text('Generate My Study Set'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate My Study Set'));
    await tester.pumpAndSettle();

    expect(find.text('Cellular Respiration'), findsOneWidget);
    expect(find.text('What to study first'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.style_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Card 1 of'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Strong'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Strong'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Strong'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(OutlinedButton, 'Strong'), findsOneWidget);
  });
}
