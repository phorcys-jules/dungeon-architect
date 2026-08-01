# Dungeon Architect

Prototype Godot 4 d'un jeu de défense de donjon inspiré d'un **Pac-Man inversé**.

Le joueur incarne le maître du donjon. Des aventuriers entrent dans le labyrinthe et tentent d'atteindre le trésor. L'objectif futur sera de placer des portes, pièges et monstres afin de créer des réactions en chaîne.

## Prototype actuel

- grille de donjon de 15 × 10 cases ;
- entrée et trésor ;
- aventurier autonome ;
- pathfinding avec `AStarGrid2D` ;
- porte interactive qui recalcule le chemin ;
- phase de préparation avec compte à rebours ;
- lancement manuel de l'invasion ;
- rendu temporaire entièrement généré par le code.

## Prérequis

### Obligatoire

- **Godot Engine 4.7.1 Standard** — version recommandée pour le projet.
  - Télécharger l'édition standard, pas l'édition `.NET`.
  - Le projet utilise GDScript : le SDK .NET n'est donc pas nécessaire.
  - Éviter les versions `dev`, `beta` et `rc`.
- Un ordinateur Windows, Linux ou macOS compatible avec Godot 4.

### Recommandé

- **Git** pour cloner le dépôt et récupérer les mises à jour.
- **GitHub Desktop** si tu préfères une interface graphique à la ligne de commande.

### Facultatif

- **Visual Studio Code** pour consulter ou modifier les scripts en dehors de Godot.
- L'extension VS Code **godot-tools**.

Godot possède déjà son propre éditeur de scripts : VS Code n'est pas obligatoire.

## Installation sous Windows

### 1. Installer Godot

1. Aller sur le site officiel de Godot.
2. Télécharger **Godot Engine 4.7.1** pour Windows.
3. Choisir l'édition standard, sans la mention `.NET`.
4. Décompresser l'archive dans un dossier permanent, par exemple :

```text
C:\Tools\Godot\
```

5. Lancer l'exécutable Godot.

Godot est portable : il n'a pas besoin d'un programme d'installation classique.

### 2. Installer Git

Installer Git for Windows avec les options par défaut, puis vérifier l'installation :

```powershell
git --version
```

### 3. Cloner le dépôt

```powershell
git clone https://github.com/phorcys-jules/dungeon-architect.git
cd dungeon-architect
```

Avec GitHub Desktop, utiliser **File → Clone repository**, puis sélectionner `phorcys-jules/dungeon-architect`.

### 4. Importer le projet dans Godot

1. Ouvrir le gestionnaire de projets Godot.
2. Cliquer sur **Importer**.
3. Sélectionner le fichier `project.godot` à la racine du dépôt.
4. Cliquer sur **Importer et modifier**.
5. Lancer le projet avec `F6` ou `F5`.

## Vérification en ligne de commande

Depuis la racine du dépôt, Godot peut vérifier que le projet et les scripts se chargent :

```powershell
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe --headless --path . --editor --quit
```

Le nom exact de l'exécutable peut varier selon l'archive téléchargée.

Cette commande servira aussi de base à la future intégration continue GitHub Actions.

## Contrôles

- Cliquer sur la porte rouge ou verte pour la fermer ou l'ouvrir.
- Pendant la préparation, cliquer sur **Lancer l'invasion** pour démarrer immédiatement.
- Après le lancement, utiliser le bouton principal pour recommencer une partie.

## Structure

```text
res://
├── project.godot
├── scenes/
│   └── main.tscn
└── scripts/
    └── main.gd
```

## Développement

Flux de travail recommandé :

```powershell
git checkout main
git pull
git checkout -b feature/nom-de-la-fonctionnalite
```

Avant de commencer une nouvelle tâche, vérifier que `main` est à jour.

## Prochain jalon

Construire un premier cycle jouable :

1. système de points de vie et de dégâts ;
2. placement d'un piège à pointes ;
3. premier monstre défenseur ;
4. conditions de victoire et de défaite ;
5. économie simple avec coûts de placement.
