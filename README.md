# Study Buddy App

Study Buddy App is a Flutter Windows MVP for the Microsoft Store. It turns pasted class notes into a small local study system.

## V1 Core Loop

1. Paste typed notes.
2. Generate a local study set.
3. Review flashcards, quiz questions, key terms, and a study plan.
4. Mark flashcard confidence as Weak, Okay, or Strong.

This version intentionally avoids file uploads, cloud storage, and paid AI calls. That keeps the first Windows build fast to test and reduces privacy, copyright, and API-cost risk.

## Current Features

- Paste-notes workspace
- Local study-set generator
- Flashcards
- Multiple-choice quiz mode
- Key term list
- Simple "what to study first" plan
- Confidence tracker
- Accuracy and privacy notice in the UI
- Better parsing for common class-note formats:
  - question/answer notes
  - term-definition notes
  - pasted tables
  - biology outlines
  - cellular respiration notes
  - respiratory and medical-style study terms
  - math paragraph notes
  - compact math formulas

## Roadmap

### V1: Finished Core Loop

Version 1 proves the core idea: pasted notes can become a useful local study system.

- Paste notes
- Generate flashcards
- Generate quizzes
- Key terms
- Basic study plan
- Weak / Okay / Strong tracking during the session
- Local-only processing
- No accounts
- No cloud AI

### V2: Personal Study Organizer

Version 2 should turn Study Buddy from a study set generator into a personal study organizer.

Planned V2 features:

- Saved subjects/classes
- Saved study sets
- Local persistence for saved decks and progress
- Assignment and test planner
- Daily Planner / daily study screen
- Exam countdown mode
- Daily study checklist
- Weak-card review mode
- Quiz accuracy tracking
- Strong / Okay / Weak history
- Weak-area tracking
- Better "what to study today" guidance

Suggested V2 build order:

1. Add local saved study sets.
2. Add subjects/classes.
3. Add assignment and test dates.
4. Add the Daily Planner screen.
5. Add weak-card review and progress history.

### V3: Smarter Study Coach

Version 3 can add heavier smart features after V2 storage and planning are stable.

- Smart study calendar
- Spaced repetition
- Calculator/formula tools
- Harder practice modes
- Optional AI explanations after privacy and cost planning
- PDF upload
- Image-to-notes
- Tutor chat
- Matching games
- Voice explanations

## Version Control Strategy

Keep published V1 and active V2 development separate.

Recommended setup:

- `main`: stable published version or latest releasable version
- `v2-daily-planner`: active Version 2 development branch
- `v1.0.0`: tag for the exact Version 1 release commit

If V1 needs a bug fix after V2 work starts:

1. Switch back to `main` or a `v1-maintenance` branch.
2. Fix only the V1 bug.
3. Build and publish a patch version, such as `1.0.1`.
4. Merge or cherry-pick that fix into the V2 branch so V2 also gets it.

Do not build V2 directly on top of the published V1 release without a branch or tag. A branch lets V2 grow without forcing unfinished planner code into a V1 emergency fix.

## Development

```sh
flutter pub get
flutter test
flutter run -d windows
flutter build windows --release
```

## Microsoft Store Target

This app is aimed at Windows/Microsoft Store distribution, not Google Play.

Before store submission:

- Reserve the app name in Partner Center.
- Replace the default Windows app icon in `windows/runner/resources/app_icon.ico`.
- Replace placeholder support/privacy email addresses in `docs/privacy.html` and `docs/support.html`.
- Package the Windows release as MSIX.
- Add a privacy policy link, support URL, screenshots, age rating, and store description.
- Keep the first release focused on pasted notes only. File uploads and cloud AI should wait until the privacy and copyright policies are ready.

See `V1_RELEASE_CHECKLIST.md` for the working V1 finish checklist.

Generated study material can contain mistakes. Students should compare generated cards and quizzes against their own class materials.

## GitHub Pages

Privacy and support pages are in `docs/`.

After pushing this repo to GitHub:

1. Open the repository on GitHub.
2. Go to Settings.
3. Go to Pages.
4. Under Build and deployment, set Source to "Deploy from a branch".
5. Select the `main` branch and the `/docs` folder.
6. Click Save.

The URLs will usually be:

- Home: https://darrellcandas.github.io/study_buddy_app/
- Privacy Policy: https://darrellcandas.github.io/study_buddy_app/privacy.html
- Support: https://darrellcandas.github.io/study_buddy_app/support.html
