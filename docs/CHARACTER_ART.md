# Direction visuelle des personnages v0.6

La première identité graphique utilise un pixel art sombre et coloré, des contours épais et des silhouettes lisibles sur une case de 48 × 48 pixels.

## Ressources actuelles

- `assets/backgrounds/monster_village.png` : carte nocturne du village avec cinq parcelles et un espace réservé au panneau d’information ;
- `assets/sprites/characters/monster_ghost.png` : fantôme spectral ;
- `assets/sprites/characters/monster_slime.png` : slime gélatineux ;
- `assets/sprites/characters/monster_mimic.png` : coffre mimic ;
- `assets/sprites/characters/monster_spider.png` : araignée de contrôle ;
- `assets/sprites/characters/adventurer_scout.png` : éclaireur léger ;
- `assets/sprites/characters/adventurer_warrior.png` : guerrier en armure ;
- `assets/sprites/characters/adventurer_knight.png` : champion lourdement équipé.

Les fichiers sources sont des PNG RGBA de 96 × 96 pixels, affichés en 48 × 48 avec filtrage nearest-neighbor. Ils ont été générés avec ImageGen sur fond chroma-key, puis détourés localement.

Chaque personnage possède aussi une planche horizontale dans
`assets/sprites/characters/animations/`. Ses quatre cellules de 128 × 128 pixels forment une
boucle de déplacement jouée à 8 images par seconde. Les trois aventuriers, les quatre
archétypes de monstres et le diablotin défenseur utilisent tous ce système dans la partie.

## Bâtiments du village

- `assets/sprites/buildings/den.png` : tanière des monstres ;
- `assets/sprites/buildings/forge.png` : forge des pièges ;
- `assets/sprites/buildings/laboratory.png` : laboratoire alchimique ;
- `assets/sprites/buildings/graveyard.png` : cimetière et mausolée ;
- `assets/sprites/buildings/black_market.png` : échoppe du marché noir.

Ces PNG RGBA de 160 × 112 pixels sont affichés directement sur les cinq zones cliquables. La sélection d'un bâtiment ouvre son état, ses effets et son amélioration.

## Suite prévue

- ajouter des variantes visuelles liées aux traits et familles ;
- créer les salles, pièges et reliques dans la même palette ;
- ajouter des animations d'attaque et de dégâts sans réduire la lisibilité.
