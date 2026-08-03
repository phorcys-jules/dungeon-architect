# Dungeon Architect v0.8.0-alpha

La v0.8 transforme les runs en campagne tactique persistante. Les choix du village, les factions rencontrées, les rivaux et l'environnement modifient désormais la construction du donjon.

## Campagne et adversaires

- Carte déterministe de neuf étapes réparties en trois actes.
- Trois factions d'aventuriers avec résistances, styles et récompenses propres.
- Aperçu tactique des routes au village : type de rencontre, biome, résistance, style, récompense et modificateurs avant confirmation.
- Trois boss à trois phases avec intentions annoncées et actions sur l'architecture.
- Système de némésis mémorisant les pièges et monstres rencontrés.

## Monstres et donjon

- Deux évolutions pour chacune des quatre familles de monstres.
- Quatre mutations à avantage et contrepartie, avec capacité dédiée.
- Le mimic se déguise désormais en coffre, attire les aventuriers et ne révèle son embuscade qu'à l'ouverture.
- Les six pièges disposent de sprites dédiés, également visibles dans les raccourcis de construction.
- Les cryptes, mines, châteaux et égouts utilisent chacun des atlas distincts pour leurs sols et leurs murs.
- Propagation déterministe de l'eau, du feu, de la fumée, du givre et de la corruption.
- Plans locaux avec rotation, miroir, prévisualisation, validation et coût avant confirmation.
- Export et import de graines de défi versionnées.

## Village et confort

- Refonte visuelle complète du village : grille sans chevauchement, panneau d'inspection défilable, barre narrative et identité cuivre/braise/brume.
- Trois quêtes pour chacun des quatre habitants fonctionnels du village.
- Remappage des actions, palettes daltoniennes, réglages audio séparés et réduction des effets.
- Défi quotidien hors ligne reproductible et sans progression permanente.
- Migration automatique des sauvegardes v0.7 vers le format 6.

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

## Finition de campagne

- Une campagne guidée accompagne la première run et reste rejouable.
- Les intentions adverses et formations de monstres clarifient les menaces tactiques.
- Les risques d'évasion deviennent des missions de sauvetage annoncées.
- Le débrief relie ses conseils aux événements enregistrés dans le replay.
- Les textes structurants disposent de catalogues français et anglais.
- La langue change immédiatement depuis le village ; les libellés statiques utilisent la traduction native Godot et les textes dynamiques conservent leurs paramètres.
- Les profils Découverte, Architecte et Impitoyable annoncent toutes leurs règles.
