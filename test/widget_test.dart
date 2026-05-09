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

  test('builds flashcards from semicolon-separated inline notes', () {
    const notes =
        'Atelectasis = alveoli collapse; Pneumonia = lung infection; '
        'Hypoxemia = low O2; Tachycardia = HR >100; Bradycardia = HR <60';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Atelectasis'], 'alveoli collapse');
    expect(cards['Pneumonia'], 'lung infection');
    expect(cards['Hypoxemia'], 'low O2');
    expect(cards['Tachycardia'], 'HR >100');
    expect(cards['Bradycardia'], 'HR <60');
  });

  test('builds flashcards from definition-to-term arrow notes', () {
    const notes = '''
Collapse of alveoli leading to reduced gas exchange \u2192 Atelectasis
Infection of lung tissue with inflammation \u2192 Pneumonia
Low oxygen in the blood \u2192 Hypoxemia
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));
    expect(cards.length, 3);
    expect(
      cards['Atelectasis'],
      'Collapse of alveoli leading to reduced gas exchange',
    );
    expect(cards['Pneumonia'], 'Infection of lung tissue with inflammation');
    expect(cards['Hypoxemia'], 'Low oxygen in the blood');
    expect(
      cards.keys,
      isNot(contains('Collapse of alveoli leading to reduced gas exchange')),
    );
  });

  test('builds flashcards from bare term definition lines', () {
    const notes = '''
Atelectasis collapse of alveoli reduced gas exchange
Pneumonia infection lung tissue inflammation fluid
Hypoxemia low oxygen blood
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));
    expect(cards.length, 3);
    expect(cards['Atelectasis'], 'collapse of alveoli reduced gas exchange');
    expect(cards['Pneumonia'], 'infection lung tissue inflammation fluid');
    expect(cards['Hypoxemia'], 'low oxygen blood');
  });

  test('builds flashcards from emoji-heavy shorthand notes', () {
    const notes = '''
Atelectasis 👉 alveoli collapse ↓ gas exchange
Pneumonia 🤒 infection lungs + fluid
Hypoxemia ⬇️O2 in blood
Tachycardia ❤️‍🔥 HR>100
Bradycardia 🧊 HR<60
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Atelectasis'], contains('alveoli collapse'));
    expect(cards['Pneumonia'], 'infection lungs + fluid');
    expect(cards['Hypoxemia'], 'low O2 in blood');
    expect(cards['Tachycardia'], 'HR>100');
    expect(cards['Bradycardia'], 'HR<60');
  });

  test('corrects common respiratory term misspellings', () {
    const notes = '''
Atelectsis = colapse of alvioli
Pnemonia = lung infecton
Hypoxima = low oxgen in blood
Tachycardea = HR >100
Bradycardea = HR <60
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Atelectasis'], 'collapse of alveoli');
    expect(cards['Pneumonia'], 'lung infection');
    expect(cards['Hypoxemia'], 'low oxygen in blood');
    expect(cards['Tachycardia'], 'HR >100');
    expect(cards['Bradycardia'], 'HR <60');
  });

  test('keeps helpful parenthetical details in dash notes', () {
    const notes = '''
Atelectasis – collapse of alveoli (super common after surgery btw)
Pneumonia – infection of lung tissue (remember: crackles!!)
Hypoxemia – low O2 in blood (SpO2 < 90 is bad)
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));
    expect(cards.length, 3);
    expect(cards['Atelectasis'], contains('super common after surgery'));
    expect(cards['Pneumonia'], contains('crackles'));
    expect(cards['Hypoxemia'], contains('SpO2 < 90'));
  });

  test('keeps semicolon details in dash notes', () {
    const notes = '''
Atelectasis – collapse of alveoli; ↓ gas exchange; often post-op
Pneumonia – lung infection; inflammation; fluid buildup; fever/cough
Hypoxemia – low O2; cyanosis; confusion
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 3);
    expect(cards['Atelectasis'], contains('often post-op'));
    expect(cards['Pneumonia'], contains('fluid buildup'));
    expect(cards['Hypoxemia'], contains('cyanosis'));
  });

  test('ignores section headings around indented term notes', () {
    const notes = '''
Respiratory Disorders:
    Atelectasis – collapse of alveoli
    Pneumonia – infection of lung tissue
Cardiac Terms:
    Tachycardia – HR > 100
    Bradycardia – HR < 60
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 4);
    expect(cards['Atelectasis'], 'collapse of alveoli');
    expect(cards['Pneumonia'], 'infection of lung tissue');
    expect(cards['Tachycardia'], 'HR > 100');
    expect(cards['Bradycardia'], 'HR < 60');
    expect(cards.keys, isNot(contains('Respiratory Disorders')));
    expect(cards.keys, isNot(contains('Cardiac Terms')));
  });

  test('builds flashcards from pasted table notes', () {
    const notes = '''
Term | Definition
Atelectasis | Collapse of alveoli
Pneumonia | Infection of lung tissue
Hypoxemia | Low oxygen in blood
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 3);
    expect(cards['Atelectasis'], 'Collapse of alveoli');
    expect(cards['Pneumonia'], 'Infection of lung tissue');
    expect(cards['Hypoxemia'], 'Low oxygen in blood');
    expect(cards.keys, isNot(contains('Term')));
  });

  test('normalizes all-caps and mixed-case term notes', () {
    const notes = '''
ATELECTASIS – Collapse Of Alveoli
PNEUMONIA – Infection Of LUNG Tissue
Hypoxemia – LOW Oxygen In Blood
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 3);
    expect(cards['Atelectasis'], 'Collapse Of Alveoli');
    expect(cards['Pneumonia'], 'Infection Of LUNG Tissue');
    expect(cards['Hypoxemia'], 'LOW Oxygen In Blood');
  });

  test('extracts respiratory terms from lecture transcript notes', () {
    const notes =
        'So atelectasis basically what that means is the alveoli collapse and '
        'then you get reduced gas exchange and that’s why patients after '
        'surgery need to use the incentive spirometer okay then pneumonia is '
        'when the lung tissue gets infected and inflamed and you’ll hear '
        'crackles and fever usually bacterial but can be viral too and '
        'hypoxemia is just low oxygen in the blood like SpO2 under 90 percent '
        'and tachycardia is heart rate above 100 usually from pain or fever '
        'and bradycardia is under 60 sometimes normal in athletes';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards['Atelectasis'], contains('alveoli collapse'));
    expect(cards['Pneumonia'], contains('lung tissue gets infected'));
    expect(cards['Hypoxemia'], contains('low oxygen in the blood'));
    expect(cards['Tachycardia'], contains('heart rate above 100'));
    expect(cards['Bradycardia'], contains('under 60'));
  });

  test('repairs broken PDF line-copy words', () {
    const notes = '''
Atelectasis – col-
lapse of alve-
oli → ↓ gas ex-
change

Pneumonia – infec-
tion of lung tis-
sue (inflam-
mation + fluid)

Hypoxemia – low
oxygen in
the blood
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 3);
    expect(cards['Atelectasis'], contains('collapse of alveoli'));
    expect(cards['Pneumonia'], contains('infection of lung tissue'));
    expect(cards['Hypoxemia'], contains('low oxygen in the blood'));
  });

  test('uses English parenthetical definitions in bilingual notes', () {
    const notes = '''
Atelectasis – colapso de los alvéolos (collapse of alveoli)
Pneumonia – infección del tejido pulmonar (lung infection)
Hypoxemia – bajo oxígeno en la sangre (low O2)
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 3);
    expect(cards['Atelectasis'], 'collapse of alveoli');
    expect(cards['Pneumonia'], 'lung infection');
    expect(cards['Hypoxemia'], 'low O2');
  });

  test('accepts student synonym definitions', () {
    const notes = '''
Atelectasis – lung collapse thing
Pneumonia – chest infection
Hypoxemia – low O2 situation
Tachycardia – fast heart
Bradycardia – slow heart
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Atelectasis'], 'lung collapse thing');
    expect(cards['Pneumonia'], 'chest infection');
    expect(cards['Hypoxemia'], 'low O2 situation');
    expect(cards['Tachycardia'], 'fast heart');
    expect(cards['Bradycardia'], 'slow heart');
  });

  test('removes embedded self-quiz questions after definitions', () {
    const notes = '''
Atelectasis – collapse of alveoli. Why does this happen post-op?
Pneumonia – infection of lung tissue. What are the risk factors?
Hypoxemia – low oxygen in blood. What SpO2 is considered low?
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));
    expect(cards.length, 3);
    expect(cards['Atelectasis'], 'collapse of alveoli');
    expect(cards['Pneumonia'], 'infection of lung tissue');
    expect(cards['Hypoxemia'], 'low oxygen in blood');
  });

  test('handles chaotic notes across unrelated subjects', () {
    const notes = '''
Atelectasis – alveoli collapse
Mitochondria – powerhouse of the cell
Pneumonia – lung infection
French Revolution – 1789 uprising
Hypoxemia – low oxygen in blood
Photosynthesis – plants convert sunlight
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 6);
    expect(cards['Atelectasis'], 'alveoli collapse');
    expect(cards['Mitochondria'], 'powerhouse of the cell');
    expect(cards['French Revolution'], '1789 uprising');
    expect(cards['Photosynthesis'], 'plants convert sunlight');
  });

  test('keeps nested parenthetical details', () {
    const notes = '''
Atelectasis – collapse of alveoli (↓ gas exchange (esp. post-op))
Pneumonia – infection of lung tissue (bacterial (most common) or viral)
Hypoxemia – low O2 in blood (SpO2 < 90 (danger zone))
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 3);
    expect(cards['Atelectasis'], contains('esp. post-op'));
    expect(cards['Pneumonia'], contains('most common'));
    expect(cards['Hypoxemia'], contains('danger zone'));
  });

  test('ignores random symbols and emphasis noise', () {
    const notes = '''
Atelectasis = collapse?? alveoli → ↓ gas exchange!!!
Pneumonia >>> lung infection + fluid??
Hypoxemia ~~ low O2 in blood
Tachycardia **HR>100**
Bradycardia __HR<60__
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Atelectasis'], contains('collapse alveoli'));
    expect(cards['Pneumonia'], 'lung infection + fluid');
    expect(cards['Hypoxemia'], 'low O2 in blood');
    expect(cards['Tachycardia'], 'HR>100');
    expect(cards['Bradycardia'], 'HR<60');
  });

  test('merges numbered definitions under term headings', () {
    const notes = '''
Atelectasis:
1. Collapse of alveoli
2. Reduced gas exchange
3. Often post-operative

Pneumonia:
1. Infection of lung tissue
2. Inflammation
3. Fluid buildup
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 2);
    expect(cards['Atelectasis'], contains('Collapse of alveoli'));
    expect(cards['Atelectasis'], contains('Often post-operative'));
    expect(cards['Pneumonia'], contains('Infection of lung tissue'));
    expect(cards['Pneumonia'], contains('Fluid buildup'));
  });

  test('infers known respiratory terms from definitions only', () {
    const notes = '''
Collapse of alveoli leading to reduced gas exchange
Infection of lung tissue causing inflammation
Low oxygen level in the blood
Heart rate greater than 100 bpm
Heart rate less than 60 bpm
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(cards['Atelectasis'], contains('Collapse of alveoli'));
    expect(cards['Pneumonia'], contains('Infection of lung tissue'));
    expect(cards['Hypoxemia'], contains('Low oxygen level'));
    expect(cards['Tachycardia'], contains('greater than 100'));
    expect(cards['Bradycardia'], contains('less than 60'));
  });

  test('builds useful flashcards from biology outline labels', () {
    const notes = '''
Purpose: Convert sunlight into chemical energy (glucose).

Occurs in: Chloroplasts (plants + some bacteria).

Equation:
Carbon dioxide + Water + Light \u2192 Glucose + Oxygen

Two stages:

Light-dependent reactions: Capture sunlight.

Calvin cycle: Build glucose.
''';

    final cards = flashcardMap(StudySetGenerator.generate(notes));

    expect(cards.length, 5);
    expect(
      cards['Photosynthesis'],
      'Convert sunlight into chemical energy (glucose).',
    );
    expect(
      cards['Chloroplasts'],
      'Where photosynthesis occurs in plants + some bacteria.',
    );
    expect(
      cards['Photosynthesis equation'],
      'Carbon dioxide + Water + Light \u2192 Glucose + Oxygen',
    );
    expect(
      cards['Light-dependent reactions'],
      'Stage of photosynthesis that captures sunlight.',
    );
    expect(
      cards['Calvin cycle'],
      'Stage of photosynthesis that builds glucose.',
    );
    expect(cards.keys, isNot(contains('Purpose')));
    expect(cards.keys, isNot(contains('Occurs in')));
    expect(cards.keys, isNot(contains('Equation')));
  });

  test('builds useful flashcards from cellular respiration study notes', () {
    const notes = '''
Cellular Respiration Study Notes

Cellular respiration is the process cells use to turn glucose into ATP, which is the main energy molecule cells use for work.

Glucose is a sugar molecule. ATP stands for adenosine triphosphate.

The three main stages of cellular respiration are glycolysis, the Krebs cycle, and the electron transport chain.

Glycolysis happens in the cytoplasm. It breaks one glucose molecule into two pyruvate molecules. Glycolysis produces a small amount of ATP and does not require oxygen.

The Krebs cycle happens in the mitochondria. It breaks down pyruvate further and releases carbon dioxide. The Krebs cycle also produces electron carriers.

The electron transport chain happens in the inner mitochondrial membrane. It uses oxygen as the final electron acceptor and produces the most ATP.

Aerobic respiration uses oxygen and produces more ATP.

Anaerobic respiration happens without oxygen and produces less ATP.

Fermentation is a type of anaerobic process. In humans, lactic acid fermentation can happen when muscles do not get enough oxygen.

Important comparison:
Aerobic respiration = oxygen present, more ATP, mitochondria involved.
Anaerobic respiration = no oxygen, less ATP, may involve fermentation.

Key terms:
Glucose: sugar used for energy.
ATP: cell energy molecule.
Glycolysis: first stage of cellular respiration.
Pyruvate: molecule made after glucose is split.
Mitochondria: organelle where most ATP is made.
Oxygen: final electron acceptor.
Carbon dioxide: waste product released during cellular respiration.
Fermentation: anaerobic process that makes ATP without oxygen.
Lactic acid: product of fermentation in human muscle cells.
''';

    final set = StudySetGenerator.generate(notes);
    final cards = flashcardMap(set);

    expect(cards.length, 14);
    expect(
      cards['Cellular respiration'],
      'Process cells use to turn glucose into ATP.',
    );
    expect(cards['ATP'], contains('adenosine triphosphate'));
    expect(cards['Glycolysis'], contains('cytoplasm'));
    expect(cards['Krebs cycle'], contains('mitochondria'));
    expect(cards['Electron transport chain'], contains('most ATP'));
    expect(cards['Aerobic respiration'], contains('more ATP'));
    expect(cards['Anaerobic respiration'], contains('less ATP'));
    expect(cards['Fermentation'], contains('without oxygen'));
    expect(cards.keys, isNot(contains('Cellular')));
    expect(cards.keys, isNot(contains('Aerobic')));
    expect(cards.keys, isNot(contains('Anaerobic')));
    expect(set.questions.length, 14);
  });

  test('builds clean flashcards from math paragraph notes', () {
    const notes =
        'The slope of a line measures how steep it is and is found by dividing '
        'the change in y by the change in x. The quadratic formula is used to '
        'find the roots of any quadratic equation. The Pythagorean theorem '
        'relates the sides of a right triangle: a² + b² = c².';

    final set = StudySetGenerator.generate(notes);
    final cards = flashcardMap(set);

    expect(cards.length, 3);
    expect(
      cards['Slope'],
      'Measures how steep a line is and is found by dividing the change in y by the change in x.',
    );
    expect(
      cards['Quadratic formula'],
      'Used to find the roots of any quadratic equation.',
    );
    expect(
      cards['Pythagorean theorem'],
      'Relates the sides of a right triangle: a² + b² = c².',
    );
    expect(cards.keys, isNot(contains('Dividing')));
    expect(cards.keys, isNot(contains('The quadratic formula')));
    expect(
      set.questions
          .map((question) => question.options)
          .expand((option) => option),
      isNot(contains('Study Goal')),
    );
  });

  test('keeps compact formulas from larger math notes', () {
    const notes = '''
Derivative — Measures rate of change.
Integral — Finds area under a curve.
Chain rule — d/dx[f(g(x))] = f'(g(x)) × g'(x)
Sine — Opposite / Hypotenuse
Cosine — Adjacent / Hypotenuse
Tangent — Opposite / Adjacent
Area formulas:
Rect = L×W
Tri = ½BH
Circ = 2πr
Vol cyl = πr²h
Pythag: a²+b²=c²
Derivative — Measures rate of change.
Integral — Finds area under a curve.
Chain rule — d/dx[f(g(x))] = f'(g(x)) × g'(x)
Sine — Opposite / Hypotenuse
Cosine — Adjacent / Hypotenuse
Tangent — Opposite / Adjacent
Slope (m) = (y₂ − y₁)/(x₂ − x₁)
Quadratic formula → x = (−b ± √(b² − 4ac)) / 2a
Remember: π ≈ 3.14
Derivative of x² → 2x
Integral of 2x → x² + C
''';

    final set = StudySetGenerator.generate(notes);
    final cards = flashcardMap(set);

    expect(cards.length, greaterThanOrEqualTo(14));
    expect(cards['Derivative'], 'Measures rate of change.');
    expect(cards['Integral'], 'Finds area under a curve.');
    expect(cards['Chain rule'], "d/dx[f(g(x))] = f'(g(x)) × g'(x)");
    expect(cards['Rectangle area'], 'L×W');
    expect(cards['Triangle area'], '½BH');
    expect(cards['Circumference'], '2πr');
    expect(cards['Cylinder volume'], 'πr²h');
    expect(cards['Pythagorean theorem'], 'a²+b²=c²');
    expect(cards['Slope'], '(y₂ − y₁)/(x₂ − x₁)');
    expect(cards['Quadratic formula'], 'x = (−b ± √(b² − 4ac)) / 2a');
    expect(cards['Derivative of x²'], '2x');
    expect(cards['Integral of 2x'], 'x² + C');
    expect(cards.keys, isNot(contains('Remember')));
    expect(set.questions.length, greaterThan(8));
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
