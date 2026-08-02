# Dungeon Architect v0.6.0-alpha

## Économie du village

- Les améliorations et le marché noir utilisent désormais une monnaie permanente explicite : les **Éclats d'âme** (`◆`).
- Les Éclats d'âme sont gagnés à la fin de chaque run et conservés dans le village.
- Les anciennes « ressources » sont migrées automatiquement sans perte vers le nouveau portefeuille.

Cette version transforme les systèmes roguelite développés après la v0.5 en une boucle de jeu intégrée et testable de bout en bout.

## Nouveautés intégrées

- événements et défis de run ;
- synergies découvrables ;
- encyclopédie, succès et statistiques globales ;
- résultats de run, village et marché noir ;
- migration des sauvegardes v0.5 vers le format 4.
- objectifs, événements et synergies visibles pendant la run ;
- progression de l’encyclopédie, succès et statistiques après les résultats ;
- marché noir accessible depuis le village ;
- quatre monstres et trois aventuriers avec des silhouettes pixel art distinctes ;
- village illustré avec cinq bâtiments cliquables et améliorables ;
- deck de pièces utilisé pour structurer le labyrinthe de chaque run ;
- biomes, événements, défis et synergies alimentés par les véritables tags de la run ;
- sauvegarde des découvertes et statistiques après chaque partie ;
- lint GDScript automatisé avec `gdtoolkit` ;
- commandes clavier pour les principales actions de construction.

## Compatibilité

Les sauvegardes des versions précédentes sont migrées automatiquement. La v0.6 conserve les ressources, déblocages, historiques de run et préférences d'accessibilité existants.
