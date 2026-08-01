# Vision — Dungeon Architect

## Pitch

Dungeon Architect est un jeu de défense de donjon en temps réel inspiré d'un Pac-Man inversé.

Le joueur incarne le maître du donjon. Des aventuriers entrent dans son labyrinthe pour atteindre le trésor. Pendant une courte phase de préparation, le joueur place des portes, pièges et monstres avec un budget limité. Pendant l'invasion, il observe et influence les réactions en chaîne créées par son architecture.

## Fantasy du joueur

Le joueur doit avoir l'impression d'être un maître du donjon ingénieux, capable de transformer un petit labyrinthe en machine défensive imprévisible.

Le plaisir principal ne vient pas du contrôle direct d'un personnage, mais du fait de concevoir une défense puis de voir son plan fonctionner — ou échouer de manière instructive.

## Boucle principale

1. Préparer le donjon.
2. Placer des défenses avec un budget limité.
3. Lancer l'invasion.
4. Observer et influencer les combats.
5. Gagner des ressources selon le résultat.
6. Améliorer ou modifier le donjon.
7. Affronter une invasion plus difficile.

## Piliers du gameplay

### 1. Lisibilité immédiate

Les règles doivent être comprises rapidement. Les aventuriers cherchent le trésor, les monstres les interceptent et les pièges se déclenchent sur leur passage.

### 2. Réactions en chaîne

Les systèmes doivent interagir. Une porte peut détourner un aventurier vers un piège, un monstre peut le retenir dans une zone dangereuse et un effet peut en déclencher un autre.

### 3. Choix sous contrainte

Le joueur ne peut pas tout construire. Le budget, l'espace et le temps de préparation imposent des choix.

### 4. Progression visible

À mesure que le joueur avance, son donjon doit devenir plus complexe, plus spectaculaire et plus personnel.

### 5. Parties courtes, décisions durables

Une invasion doit rester courte, mais ses récompenses et ses conséquences alimentent une progression plus longue.

## Minimum fun

Le premier prototype réellement amusant doit permettre de :

- préparer un petit donjon ;
- placer au moins un piège et un monstre ;
- lancer une invasion ;
- voir un aventurier adapter son trajet ;
- gagner ou perdre clairement ;
- comprendre immédiatement pourquoi le plan a fonctionné ou échoué.

Tant que cette boucle n'est pas amusante, les systèmes de méta-progression et le contenu massif ne sont pas prioritaires.

## Scope du MVP

Le MVP vise une seule boucle jouable complète avec :

- une carte fixe ;
- une phase de préparation ;
- une phase d'invasion ;
- un type d'aventurier ;
- un type de monstre ;
- un piège à pointes ;
- une porte ;
- un trésor ;
- une économie simple ;
- des conditions de victoire et de défaite ;
- une interface minimale ;
- une sauvegarde locale basique.

## Hors scope du MVP

Les éléments suivants ne doivent pas ralentir la validation de la boucle principale :

- multijoueur ;
- monde ouvert ;
- narration complexe ;
- éditeur de niveaux complet ;
- génération procédurale avancée ;
- dizaines de classes ou de monstres ;
- intégration Steam complète ;
- graphismes définitifs ;
- progression roguelite profonde.

## Direction artistique temporaire

Le prototype utilise des formes et couleurs simples. La priorité est la lisibilité des unités, des cases, des dangers et des états.

Le style final pourra tendre vers un pixel art sombre et coloré, avec des animations exagérées et des effets très lisibles.

## Principes techniques

- Godot 4 et GDScript typé.
- Une responsabilité principale par scène ou script.
- Les statistiques de contenu doivent être stockées dans des `Resource` lorsque cela devient utile.
- Les systèmes communs comme la santé, les dégâts et les attaques doivent être réutilisables.
- Les règles de jeu ne doivent pas dépendre du rendu graphique.
- Chaque fonctionnalité importante doit pouvoir être validée en mode headless.
- `main.gd` coordonne la partie mais ne doit pas contenir toute la logique du jeu.

## Critère de décision

Avant d'ajouter une fonctionnalité, poser cette question :

> Est-ce que cette fonctionnalité rend la préparation, les réactions en chaîne ou la progression du donjon plus intéressante ?

Si la réponse est non, elle doit rester dans le backlog ou être écartée.
