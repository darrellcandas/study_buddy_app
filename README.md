# Study Buddy App

Study Buddy App is a Flutter Windows MVP for the Microsoft Store. It turns pasted class notes into a small study system.

## V1 Core Loop

1. Paste typed notes.
2. Generate a local study set.
3. Review flashcards, quiz questions, key terms, and a study order.
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

## Roadmap

- V2: saved subjects, test-date planner, daily study screen, weak-area tracking
- V3: AI-generated mnemonics, simple explanations, harder questions, spaced repetition
- V4: PDF upload, image-to-notes, tutor chat, matching games, voice explanations

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
- Package the Windows release as MSIX.
- Add a privacy policy link, support URL, screenshots, age rating, and store description.
- Keep the first release focused on pasted notes only. File uploads and cloud AI should wait until the privacy and copyright policies are ready.

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

- Home: `https://YOUR-GITHUB-USERNAME.github.io/YOUR-REPO-NAME/`
- Privacy Policy: `https://YOUR-GITHUB-USERNAME.github.io/YOUR-REPO-NAME/privacy.html`
- Support: `https://YOUR-GITHUB-USERNAME.github.io/YOUR-REPO-NAME/support.html`
