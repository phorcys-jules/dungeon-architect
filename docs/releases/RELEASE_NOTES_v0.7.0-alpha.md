# Dungeon Architect v0.7.0-alpha

Cette alpha renforce le cœur « Pac-Man inversé » : le donjon se construit, s'analyse et se pilote pendant l'invasion.

## Nouveautés

- Six combos déterministes entre états, pièges, monstres et terrain.
- Inspection, deux branches d'amélioration et recyclage des défenses.
- Trois pouvoirs tactiques alimentés uniquement par les pièges et combos (`Q`, `E`, `F`).
- Tunnels bidirectionnels utilisables par monstres et aventuriers, intégrés au calcul de route pondéré.
- Escouades de deux à quatre aventuriers avec rôles, formations, capacités et recharges.
- Carte tactique (`H`) conservant circulation, dégâts, captures et déclenchements de la vague précédente.
- Six règles locales de salles et trois types d'objectifs secondaires.
- Tutoriel contextuel rejouable, codex lié et mode guidé sans récompenses persistantes.

## Progression et compatibilité

Les sauvegardes de la v0.6 restent compatibles. Les découvertes, statistiques, ressources, village, marché noir, équipes de monstres et préférences sont conservés.

## Validation

La release est validée avec Godot 4.7.1, les tests headless historiques, les tests d'intégration 0.6 et la suite dédiée 0.7.
