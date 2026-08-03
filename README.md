# Dungeon Architect

Prototype Godot 4 d’un jeu de défense de donjon inspiré d’un **Pac-Man inversé**.

Le joueur prépare un labyrinthe, place des murs, portes, pièges et monstres, puis observe des aventuriers chercher les reliques et le trésor. Les récompenses alimentent le village et la progression persistante.

La direction produit se trouve dans [docs/VISION.md](docs/VISION.md). Les documents de version sont archivés dans [docs/releases](docs/releases).

## Version actuelle

La branche de développement prépare `v0.8.0-alpha` :

- campagne de cinq vagues et labyrinthe procédural ;
- construction de murs, pièges, portes et défenseurs ;
- monstres mobiles avec rôles de poursuite ;
- événements et défis déterministes de run ;
- synergies, encyclopédie, succès et statistiques persistantes ;
- boucle run → résultats → village → nouvelle run ;
- village cartographié avec tanière, forge, laboratoire, cimetière et marché noir cliquables ;
- premières silhouettes pixel art pour monstres et aventuriers ;
- migration automatique des anciennes sauvegardes.
- combos entre pièges, monstres et terrain, défenses améliorables et pouvoirs tactiques ;
- tunnels bidirectionnels, escouades d'aventuriers, règles locales de salles et objectifs secondaires ;
- carte tactique de circulation et tutoriel contextuel sauvegardé.
- campagne ramifiée en trois actes avec factions et boss architecturaux ;
- évolutions, mutations et rivaux persistants ;
- flux environnementaux, plans de construction et graines partageables ;
- quêtes fonctionnelles du village, accessibilité étendue et défi quotidien.
- prisonniers, contre-espionnage, sabotages annoncés et zones de patrouille ;
- replay tactique, ambiance réactive et défis personnalisés partageables.

## Prérequis

- Godot Engine **4.7.1 Standard** ;
- Git, recommandé pour contribuer ;
- Windows, Linux ou macOS compatible avec Godot 4.

Le projet utilise GDScript et ne nécessite pas l’édition .NET.

## Lancement

```powershell
git clone https://github.com/phorcys-jules/dungeon-architect.git
cd dungeon-architect
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe --editor --path .
```

La scène principale est `res://scenes/main.tscn`.

## Contrôles

- clic gauche : placer la construction sélectionnée ;
- `1` à `6` : sélectionner les six modèles de pièges ;
- `7` : sélectionner un défenseur ;
- `8` : placer un mur ;
- `9` : retirer un mur ;
- `W` : placer un mur ;
- `R` : retirer un mur construit ;
- `D` : ouvrir ou fermer la porte ;
- `Espace` ou `Entrée` : lancer la vague ou activer l’action principale ;
- entre deux vagues : choisir une amélioration de run parmi trois propositions ;
- boutons du résultat : retourner au village ou commencer une nouvelle run.
- `Q`, `E`, `F` : pouvoirs tactiques ;
- `H` : afficher ou masquer la carte tactique de la vague précédente.
- `P` : afficher ou masquer les zones de patrouille ;
- `J` : avancer jusqu'au prochain événement du replay tactique.

## Tests locaux

```powershell
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe --headless --path . --import
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe --headless --path . --script tests/smoke_test.gd
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe --headless --path . --script tests/v06_full_run_integration_test.gd
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe --headless --path . --script tests/v07_feature_runtime_test.gd
```

GitHub Actions importe le projet, exécute les tests headless et vérifie les exports de distribution. Une PR ne doit pas être fusionnée si Godot CI échoue.

### Linter GDScript

Le projet utilise `gdlint`, fourni par `gdtoolkit` :

```powershell
python -m pip install -r requirements-dev.txt
gdlint scripts tests
```

La même vérification est exécutée automatiquement sur les pull requests et les pushes vers `main` qui modifient du GDScript.

## Organisation

```text
assets/       ressources visuelles
docs/         vision, direction artistique et archives de version
resources/    données Godot des vagues, salles, monstres et synergies
scenes/       scènes jouables et village
scripts/      logique de jeu, UI, sauvegarde et progression
tests/        tests headless
```

## Principes de développement

- séparer les données, les règles et le rendu ;
- conserver une responsabilité principale par script ;
- rendre les systèmes importants testables en mode headless ;
- préserver les anciennes sauvegardes lors des changements de format ;
- privilégier la lisibilité immédiate des unités, dangers et objectifs.
