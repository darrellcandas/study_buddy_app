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

  test('builds flashcards from em dash history notes', () {
    const notes = '''
Industrial Revolution \u2014 Period of major technological and manufacturing growth
Cold War \u2014 Political tension between the US and Soviet Union after WWII
Feudalism \u2014 Medieval system of land ownership and social hierarchy
Renaissance \u2014 Cultural rebirth of art and learning in Europe
Great Depression \u2014 Severe worldwide economic downturn in the 1930s
Civil Rights Movement \u2014 Fight for racial equality in the United States
Magna Carta \u2014 1215 document limiting the power of the English king
Imperialism \u2014 Policy of extending a nation's power through colonization
Treaty of Versailles \u2014 Agreement that ended WWI and imposed penalties on Germany
Democracy \u2014 Government system where citizens vote on leadership
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));
    expect(cards.length, 10);
    expect(
      cards['Industrial Revolution'],
      'Period of major technological and manufacturing growth',
    );
    expect(
      cards['Cold War'],
      'Political tension between the US and Soviet Union after WWII',
    );
    expect(
      cards['Feudalism'],
      'Medieval system of land ownership and social hierarchy',
    );
    expect(cards.keys, isNot(contains('Industrial Revolution \u2014 Period')));
    expect(cards.keys, isNot(contains('Political Tension')));
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

  test('builds flashcards from medical shorthand notes', () {
    const notes = '''
Atelectasis: collapse of alveoli \u2192 \u2193 gas exchange
PNEUMONIA - infection of lung tissue (inflammation + fluid)
Hypoxemia = low O2 in blood
Tachycardia >100 bpm
Bradycardia <60 bpm
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(
      cards['Atelectasis'],
      'collapse of alveoli \u2192 \u2193 gas exchange',
    );
    expect(
      cards['Pneumonia'],
      'infection of lung tissue (inflammation + fluid)',
    );
    expect(cards['Hypoxemia'], 'low O2 in blood');
    expect(cards['Tachycardia'], '>100 bpm');
    expect(cards['Bradycardia'], '<60 bpm');
  });

  test('builds flashcards from medical paragraph notes', () {
    const notes =
        'Atelectasis refers to the collapse of alveoli which reduces gas exchange. '
        'Pneumonia is an infection of the lung tissue that causes inflammation and fluid buildup. '
        'Hypoxemia means low oxygen levels in the blood. '
        'Tachycardia is when the heart rate exceeds 100 bpm, while bradycardia is when it falls below 60 bpm.';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards['Atelectasis'], contains('collapse of alveoli'));
    expect(cards['Pneumonia'], contains('infection of the lung tissue'));
    expect(
      cards['Hypoxemia'],
      'Hypoxemia means low oxygen levels in the blood.',
    );
    expect(
      cards['Tachycardia'],
      'Tachycardia is when the heart rate exceeds 100 bpm.',
    );
    expect(cards['Bradycardia'], 'Bradycardia is when it falls below 60 bpm.');
  });

  test('builds flashcards from medical bullet shorthand notes', () {
    const notes = '''
• Atelectasis – collapse of alveoli
• Pneumonia (infection of lung tissue)
• Hypoxemia: low blood oxygen
• Tachycardia = HR > 100
• Bradycardia = HR < 60
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Atelectasis'], 'collapse of alveoli');
    expect(cards['Pneumonia'], 'infection of lung tissue');
    expect(cards['Hypoxemia'], 'low blood oxygen');
    expect(cards['Tachycardia'], 'HR > 100');
    expect(cards['Bradycardia'], 'HR < 60');
  });

  test('builds flashcards from mixed subject section notes', () {
    const notes = '''
BIOLOGY:
Mitochondria \u2013 powerhouse of the cell
Osmosis \u2013 movement of water

MEDICAL:
Sepsis \u2013 life-threatening organ dysfunction
AKI \u2013 sudden decline in kidney function

HISTORY:
Renaissance \u2013 cultural rebirth in Europe
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Mitochondria'], 'powerhouse of the cell');
    expect(cards['Osmosis'], 'movement of water');
    expect(cards['Sepsis'], 'life-threatening organ dysfunction');
    expect(cards['AKI'], 'sudden decline in kidney function');
    expect(cards['Renaissance'], 'cultural rebirth in Europe');
    expect(cards.keys, isNot(contains('Biology')));
    expect(cards.keys, isNot(contains('Medical')));
    expect(cards.keys, isNot(contains('History')));
  });

  test('builds flashcards from messy student respiratory notes', () {
    const notes = '''
Atelectasis?? alveoli collapse \u2192 \u2193 gas exchange (seen post-op)
Pneumonia = infection lungs (bacteria/viral) \u2192 crackles??
Hypoxemia (LOW O2 in blood) \u2192 cyanosis maybe
Tachycardia HR>100 (stress, fever, pain)
Bradycardia HR<60 (athletes?? meds??)
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(
      cards['Atelectasis'],
      'alveoli collapse \u2192 \u2193 gas exchange (seen post-op)',
    );
    expect(
      cards['Pneumonia'],
      'infection lungs (bacteria/viral) \u2192 crackles',
    );
    expect(cards['Hypoxemia'], 'LOW O2 in blood \u2192 cyanosis maybe');
    expect(cards['Tachycardia'], 'HR>100 (stress, fever, pain)');
    expect(cards['Bradycardia'], 'HR<60 (athletes meds)');
  });

  test('builds flashcards from lecture-style respiratory notes', () {
    const notes = '''
Respiratory conditions we covered today:

Atelectasis = collapse of alveoli \u2192 \u2193 gas exchange. Often after surgery. (Remember incentive spirometer!!)

Pneumonia:
- infection of lung tissue
- inflammation + fluid
- symptoms: fever, cough, crackles
*can be bacterial or viral*

Hypoxemia: low O2 in blood (SpO2 < 90%). Causes: pneumonia, atelectasis, COPD, etc.

Tachycardia HR > 100 bpm (pain? anxiety? fever?)
Bradycardia HR < 60 bpm (athletes, beta blockers)

NOTE: “Ischemia” = reduced blood flow to tissues \u2192 pain
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards['Atelectasis'], contains('collapse of alveoli'));
    expect(cards['Pneumonia'], contains('infection of lung tissue'));
    expect(cards['Pneumonia'], contains('fever, cough, crackles'));
    expect(cards['Hypoxemia'], contains('low O2 in blood'));
    expect(cards['Tachycardia'], 'HR > 100 bpm (pain anxiety fever)');
    expect(cards['Bradycardia'], 'HR < 60 bpm (athletes, beta blockers)');
    expect(cards['Ischemia'], 'reduced blood flow to tissues \u2192 pain');
    expect(
      cards.keys,
      isNot(contains('Respiratory conditions we covered today')),
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

    final cardsTab = find.widgetWithText(InkWell, 'Cards');
    await tester.ensureVisible(cardsTab);
    await tester.pumpAndSettle();
    await tester.tap(cardsTab);
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
