# Checklist de publication v0.6.0-alpha

## Socle de version

- [x] Version du jeu définie sur `v0.6.0-alpha` dans Godot et `GameVersion`.
- [x] Format de sauvegarde porté à la version 4.
- [x] Migration des sauvegardes v0.5 sans perte de progression.
- [x] Test headless de readiness v0.6.

## Vertical slice jouable

- [x] Relier événements, défis et synergies à la scène principale.
- [x] Afficher les objectifs et modificateurs actifs dans le HUD.
- [x] Relier les résultats de run à l'encyclopédie et aux statistiques globales.
- [x] Relier les récompenses de run, le village et le marché noir.
- [x] Permettre une partie complète village → run → résultats → village.

## Qualité et équilibrage

- [x] Ajouter un test d'intégration de partie complète déterministe.
- [x] Vérifier qu'une ancienne sauvegarde peut terminer une run puis être rechargée.
- [x] Ajouter des garde-fous d’équilibrage pour les coûts, récompenses, vagues, événements et défis.
- [x] Ajouter des commandes clavier en complément de la souris.
- [x] Corriger les nouveaux textes visibles et documenter les contrôles.
- [x] Ajouter `gdlint` et son contrôle GitHub Actions.
- [x] Éliminer les avertissements de ressources en conservant les UID Godot.
- [x] Vérifier le câblage réel des monstres, aventuriers, pièces, biomes et bâtiments.

## Publication

- [x] Configurer la génération automatisée des builds Windows et Linux.
- [x] Préparer les notes de version.
- [ ] Vérifier manuellement les builds et préparer les captures d’écran finales.
- [ ] Créer le tag et la release GitHub `v0.6.0-alpha`.
