# MedTranslate

Application macOS native gratuite pour enregistrer un cours, transcrire l'anglais avec macOS et produire une traduction française sur l'appareil.

## Utilisation

Au premier lancement, autorisez le microphone et la reconnaissance vocale. macOS peut demander de télécharger les langues anglaise et française une fois.

1. Autorisez le microphone quand macOS le demande.
2. Cliquez sur **Démarrer l'enregistrement**.
3. Cliquez sur **Arrêter et traduire**.
4. Exportez le cours en fichier Markdown si souhaité.

Cette version n’utilise ni clé API, ni crédit OpenAI. La qualité de traduction dépend des langues Apple installées sur le Mac.

## Compilation

Le workflow GitHub Actions construit automatiquement `MedTranslate.dmg` sur macOS. Le DMG n'est pas signé/notarisé : macOS peut demander une validation supplémentaire au premier lancement.
