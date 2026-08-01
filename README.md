# Dungeon Architect

Prototype Godot 4 d'un jeu de défense de donjon inspiré d'un **Pac-Man inversé**.

Le joueur incarne le maître du donjon. Des aventuriers entrent dans le labyrinthe et tentent d'atteindre le trésor. L'objectif futur sera de placer des portes, pièges et monstres afin de créer des réactions en chaîne.

## Prototype actuel

- grille de donjon de 15 × 10 cases ;
- entrée et trésor ;
- aventurier autonome ;
- pathfinding avec `AStarGrid2D` ;
- porte interactive qui recalcule le chemin ;
- bouton permettant de relancer l'invasion ;
- rendu temporaire entièrement généré par le code.

## Installation

1. Installer **Godot 4.4** ou une version Godot 4 plus récente.
2. Cloner le dépôt.
3. Importer `project.godot` depuis le gestionnaire de projets Godot.
4. Lancer le projet avec `F6` ou `F5`.

## Contrôles

- Cliquer sur la porte rouge ou verte pour la fermer ou l'ouvrir.
- Utiliser **Relancer l'invasion** pour replacer l'aventurier à l'entrée.

## Structure

```text
res://
├── project.godot
├── scenes/
│   └── main.tscn
└── scripts/
    └── main.gd
```

## Prochain jalon

Construire un premier cycle jouable :

1. placement d'un piège à pointes ;
2. points de vie et mort de l'aventurier ;
3. or gagné après une défense réussie ;
4. phase de préparation suivie d'une phase d'invasion.
