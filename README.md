# MedTranslate

Application macOS native pour enregistrer un cours, transcrire l'anglais et produire une traduction médicale française rigoureuse.

## Utilisation

Au premier lancement, ouvrez **Réglages** et saisissez votre clé OpenAI. Elle est sauvegardée uniquement dans le Trousseau macOS, jamais dans ce dépôt.

1. Autorisez le microphone quand macOS le demande.
2. Cliquez sur **Démarrer l'enregistrement**.
3. Cliquez sur **Arrêter et traduire**.
4. Exportez le cours en fichier Markdown si souhaité.

La transcription utilise `gpt-transcribe`; la traduction utilise l'API Responses. Une connexion Internet et une clé API OpenAI avec facturation active sont nécessaires.

## Compilation

Le workflow GitHub Actions construit automatiquement `MedTranslate.dmg` sur macOS. Le DMG n'est pas signé/notarisé : macOS peut demander une validation supplémentaire au premier lancement.
