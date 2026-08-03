# Grille de playtest v0.6

Cette grille sert à comparer les décisions de construction, pas seulement à vérifier qu’une partie démarre.

## Protocole reproductible

1. Utiliser les seeds `601`, `602` et `603` pour chaque combinaison.
2. Tester chaque biome avec chacun des quatre monstres dans l’équipe active.
3. Jouer une fois sans amélioration, puis une fois avec les bâtiments niveau 2.
4. Noter victoire, vague atteinte, durée, score, captures, dégâts, pièges choisis et ressources restantes.
5. Rejouer toute combinaison située hors des fourchettes cibles avant de modifier une valeur.

## Matrice minimale

| Biome | Fantôme | Slime | Mimic | Araignée |
|---|---:|---:|---:|---:|
| Crypte | 3 seeds | 3 seeds | 3 seeds | 3 seeds |
| Mine | 3 seeds | 3 seeds | 3 seeds | 3 seeds |
| Château | 3 seeds | 3 seeds | 3 seeds | 3 seeds |
| Égouts | 3 seeds | 3 seeds | 3 seeds | 3 seeds |

## Fourchettes cibles

- Taux de victoire global : 40–65 %.
- Durée d’une campagne : 6–14 minutes.
- Première vague : aucune défaite avant 45 secondes dans une configuration valide.
- Cinquième vague : au moins deux types de défenses nécessaires.
- Aucun monstre, piège, bâtiment ou pacte choisi dans plus de 70 % des runs gagnantes.
- Écart de victoire entre deux biomes : moins de 20 points.

Les statistiques sont enregistrées dans `GlobalRunStats.balance_samples` par couple biome/monstre. Toute correction issue d’un playtest doit être accompagnée d’un test de garde-fou déterministe.
