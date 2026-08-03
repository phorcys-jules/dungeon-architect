# Instructions pour les agents IA

## Portée

Ces instructions s'appliquent à l'ensemble du dépôt. Un fichier `AGENTS.md` placé dans un sous-dossier peut ajouter des règles plus précises pour ce sous-dossier.

## Vision du jeu

Dungeon Architect est un jeu d'inversion de Pac-Man : le joueur construit et améliore un donjon afin de piéger des aventuriers, puis développe son village entre les parties.

- Préserver une boucle de jeu immédiatement compréhensible : construire, défendre, collecter, améliorer, recommencer.
- Privilégier l'intégration et l'intérêt en jeu du contenu existant avant d'ajouter du contenu isolé.
- Rendre les comportements, effets, ressources et améliorations lisibles dans l'interface.
- Consulter `docs/VISION.md` avant toute modification importante de conception.

## Environnement technique

- Moteur : Godot 4.7.1 Standard.
- Langage : GDScript typé.
- Scène principale : `res://scenes/main.tscn`.
- Résolution de référence : 960 x 640.
- Rendu : compatibilité GL et filtrage nearest-neighbor pour le pixel art.
- Version de développement actuelle : `v0.8.0-alpha`.

Ne pas introduire de dépendance à une version différente de Godot sans mettre à jour explicitement la documentation, la CI et les fichiers de version concernés.

## Architecture et code

- Séparer les données, les règles de jeu, la persistance et le rendu.
- Garder une responsabilité principale par script et éviter de faire grossir les contrôleurs centraux avec des règles spécialisées.
- Placer les définitions réutilisables et configurables dans `resources/` plutôt que de dupliquer des constantes dans les scènes ou scripts.
- Utiliser des types explicites pour les paramètres, retours, collections et variables lorsque Godot le permet.
- Réutiliser les services, composants et utilitaires existants avant d'en créer de nouveaux.
- Éviter le code dupliqué, les branches mortes, les fonctionnalités non reliées à la boucle principale et les valeurs magiques sans nom.
- Conserver le caractère déterministe des systèmes procéduraux lorsqu'une graine est fournie.
- Ne pas masquer une erreur avec un fallback silencieux : produire un comportement sûr et une erreur exploitable.

## Sauvegardes et compatibilité

- Ne jamais casser volontairement les sauvegardes existantes.
- Toute évolution du format doit avoir une migration et des valeurs par défaut sûres.
- Garder synchronisées les versions de sauvegarde définies dans `scripts/core/game_version.gd` et dans le migrateur.
- Tester le chargement d'une sauvegarde ancienne ainsi que la création d'une sauvegarde neuve après une modification du format.

## Interface et accessibilité

- Concevoir et vérifier l'interface à 960 x 640 : aucun texte, bouton, panneau ou infobulle ne doit se chevaucher ou sortir de l'écran.
- Utiliser les conteneurs Godot et les tailles minimales plutôt que des positions absolues fragiles.
- Prévoir les libellés français les plus longs et conserver les traductions et placeholders cohérents.
- Expliquer par une infobulle les effets, états, monnaies, coûts et raccourcis non évidents.
- Respecter les réglages d'accessibilité existants : réduction des animations, lisibilité, contrastes et modes de daltonisme.
- Les actions importantes doivent rester accessibles au clavier et à la souris ; afficher les raccourcis utiles dans l'interface.

## Assets visuels et audio

- Respecter la direction pixel art et la palette déjà présentes.
- Utiliser des PNG transparents pour les objets et personnages, et conserver des dimensions cohérentes avec les assets voisins.
- Vérifier l'import Godot des nouveaux assets et inclure les fichiers `.import` nécessaires lorsqu'ils sont suivis par le dépôt.
- Ne pas laisser un simple bloc coloré ou un libellé temporaire lorsqu'un véritable sprite est demandé.
- Les animations doivent améliorer la compréhension de l'état ou de l'action sans nuire à la lisibilité.
- Tout son ou toute musique doit respecter les réglages de volume et pouvoir être désactivé.

## Tests et validation

Toute modification de gameplay doit ajouter ou adapter un test dans `tests/`. Les tests doivent fonctionner en mode headless et ne pas dépendre d'un périphérique audio, d'une fenêtre visible ou d'un ordre d'exécution implicite.

Avant de considérer un travail terminé, exécuter au minimum :

```powershell
gdlint scripts tests
godot --headless --path . --import
```

Exécuter ensuite le test ciblé :

```powershell
godot --headless --path . --script tests/<nom>_test.gd
```

Pour une validation complète, exécuter tous les tests comme le fait `.github/workflows/godot-ci.yml`. Vérifier également :

```powershell
git diff --check
```

Si un outil n'est pas disponible localement, le signaler clairement ; ne pas prétendre que la validation correspondante a réussi. Un export local peut nécessiter les templates d'export Godot.

## Documentation et versions

- Mettre à jour la documentation concernée pour toute fonctionnalité visible ou règle de jeu modifiée.
- Placer les documents durables dans `docs/` et les notes de livraison dans `docs/releases/`.
- Pour une livraison, garder cohérents `project.godot`, `scripts/core/game_version.gd`, `export_presets.cfg`, les notes et la checklist de release.
- Ne cocher comme terminées les étapes de CI, fusion, tag ou publication qu'après leur réussite réelle.
- Les tags de préversion suivent la forme `vX.Y.Z-alpha`.

## Git et travail partagé

- Le worktree peut contenir des modifications appartenant à l'utilisateur ou à un autre agent : les préserver et ne pas les réécrire sans nécessité.
- Ne jamais utiliser `git reset --hard`, restaurer massivement des fichiers ou supprimer des changements non liés à la demande.
- Limiter les modifications et le staging au périmètre demandé.
- Ne pas créer de commit, pousser, fusionner, taguer, publier une release ou supprimer une branche sans autorisation explicite.
- Avant de supprimer une branche, vérifier sur GitHub que sa pull request est réellement fusionnée. Après un squash merge, `git branch --no-merged` n'est pas une preuve suffisante.
- Ne pas modifier ou fermer une issue simplement parce qu'une implémentation partielle existe : vérifier les critères d'acceptation et les tests.

## Définition de terminé

Un changement est terminé lorsque :

1. La fonctionnalité est intégrée à la boucle principale et accessible en jeu.
2. Le comportement est lisible dans l'interface et compatible avec les sauvegardes.
3. Les tests pertinents existent et passent.
4. Le lint et `git diff --check` passent.
5. La documentation et les versions affectées sont cohérentes.
6. Aucun changement non lié de l'utilisateur n'a été écrasé.
