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

## Interface de partie

L'interface utilise trois surfaces sombres bordées : l'en-tête pour l'état de la run, la barre
latérale pour les objectifs, effets et actions, puis le pied de page pour les messages et
statistiques. La fenêtre de résultat possède une zone de résumé défilable afin que les
récompenses, défis et succès ne puissent plus recouvrir les boutons de navigation.

## Salles spéciales

Les cinq salles du deck actif possèdent une tuile pixel-art dédiée dans
`assets/sprites/rooms/` : bassin de slime, carrefour, faux trésor, portail de monstres et
salle de brume. Elles remplacent les anciennes abréviations de debug tout en conservant les
tags, connexions et synergies de chaque ressource `RoomData`.

## Collectables

Les objets interactifs de la run utilisent maintenant trois sprites RGBA de 128 × 128 pixels
dans `assets/sprites/collectibles/` : la relique d'âme à collecter, la flamme de bénédiction
et le coffre final. Ils sont affichés entre 38 et 44 pixels pour rester lisibles sans masquer
les cases voisines. Leur disparition et leurs effets restent pilotés par les contrôleurs de jeu.

## Animations de combat

Les combattants possèdent une anticipation courte, une impulsion vers leur cible et un retour
au repos. Les défenseurs lancent des projectiles violets et les quatre archétypes mobiles ont
un effet identifiable : frappe spectrale du fantôme, éclaboussure du slime, morsure du mimic
et projectile de toile de l'araignée. Au contact, l'aventurier répond par un arc d'arme doré ;
les impacts produisent une gerbe brève et sa réception des dégâts reste signalée par un flash.

L'attaque de l'aventurier est désormais pilotée par son profil. L'éclaireur tire à distance
sur les cibles blessées, le guerrier engage le monstre le plus proche et le champion privilégie
la menace la plus dangereuse. Chaque monstre possède des points de vie visibles ; une cible
neutralisée disparaît quelques secondes avant de revenir à son repaire. L'aventurier ralentit
brièvement pendant sa frappe puis reprend automatiquement son objectif de run.

La bénédiction fonctionne comme une pac-gomme : elle interrompt immédiatement les routes de
poursuite, renforce portée, dégâts et cadence de l'aventurier, puis force chaque monstre à
chercher le coin praticable le plus éloigné. Un contact pendant cette phase neutralise le
monstre jusqu'à la fin du pouvoir. Un halo pulsant indique la durée active et les deux camps
recalculent leurs objectifs lorsque la chasse reprend.

## Ambiance sonore du village

Le village joue `assets/audio/music/village_night.wav`, une boucle originale de 16 secondes
en ré mineur mêlant bourdon grave, nappes et cloches discrètes. La lecture démarre avec un
fondu de 1,8 seconde à −19 dB et disparaît en 0,45 seconde avant le lancement d'une run afin
d'éviter une coupure sèche ou la superposition de plusieurs pistes.

Le décor possède également une couche d'animation procédurale entre le fond et les bâtiments :
le feu de camp central pulse et projette neuf braises, les douze torches vacillent avec des
phases différentes, et cinq volutes de fumée s'échappent de la cheminée de la forge en dérivant
vers la droite. Cette couche ignore la souris et ne modifie donc aucune zone cliquable.

## Pièges de la forge

Chaque niveau de forge ouvre un nouveau piège dans la run : pointes, fosse de poix, rune
incendiaire, sceau de givre, mine d'âme puis faille du Néant. La fiche du bâtiment affiche les modèles possédés
et le prochain palier. Le bouton de construction fait défiler uniquement les pièges débloqués ;
chacun possède son coût, ses dégâts, sa recharge, sa couleur et, pour la poix et le givre, un
ralentissement distinct appliqué à l'aventurier.

## Suite prévue

- ajouter des variantes visuelles liées aux traits et familles ;
- créer les pièges dans la même palette ;
- ajouter des animations d'attaque et de dégâts sans réduire la lisibilité.
