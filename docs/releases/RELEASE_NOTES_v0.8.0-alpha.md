# Dungeon Architect v0.8.0-alpha

La v0.8 transforme les runs en campagne tactique persistante. Les choix du village, les factions rencontrées, les rivaux et l'environnement modifient désormais la construction du donjon.

## Campagne et adversaires

- Carte déterministe de neuf étapes réparties en trois actes.
- Trois factions d'aventuriers avec résistances, styles et récompenses propres.
- Trois boss à trois phases avec intentions annoncées et actions sur l'architecture.
- Système de némésis mémorisant les pièges et monstres rencontrés.

## Monstres et donjon

- Deux évolutions pour chacune des quatre familles de monstres.
- Quatre mutations à avantage et contrepartie, avec capacité dédiée.
- Propagation déterministe de l'eau, du feu, de la fumée, du givre et de la corruption.
- Plans locaux avec rotation, miroir, prévisualisation, validation et coût avant confirmation.
- Export et import de graines de défi versionnées.

## Village et confort

- Trois quêtes pour chacun des quatre habitants fonctionnels du village.
- Remappage des actions, palettes daltoniennes, réglages audio séparés et réduction des effets.
- Défi quotidien hors ligne reproductible et sans progression permanente.
- Migration automatique des sauvegardes v0.7 vers le format 5.

## Validation

- Compilation Godot 4.7.1 headless.
- Tests unitaires et d'intégration des huit systèmes 0.8.
- Validation déterministe et de solvabilité sur 100 graines de campagne.

## Extensions de gameplay

- Les aventuriers capturés peuvent devenir des prisonniers à interroger, rançonner ou libérer.
- Les factions annoncent des sabotages déterministes avec cible, certitude et contre-mesure.
- Les monstres reçoivent des zones de garde, patrouille, embuscade et repli visibles avec `P`.
- Une chronologie compacte enregistre les événements majeurs ; `J` permet de les parcourir.
- La direction audio calcule des couches réactives au biome, à la faction, au danger et au boss.
- Des défis personnalisés combinent mutateurs, restrictions, score et code partageable avec checksum.
