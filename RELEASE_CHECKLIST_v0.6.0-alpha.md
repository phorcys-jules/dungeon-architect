# Checklist de publication v0.6.0-alpha

## Socle de version

- [x] Version du jeu définie sur `v0.6.0-alpha` dans Godot et `GameVersion`.
- [x] Format de sauvegarde porté à la version 4.
- [x] Migration des sauvegardes v0.5 sans perte de progression.
- [x] Test headless de readiness v0.6.

## Vertical slice jouable

- [ ] Relier événements, défis et synergies à la scène principale.
- [ ] Afficher les objectifs et modificateurs actifs dans le HUD.
- [ ] Relier les résultats de run à l'encyclopédie et aux statistiques globales.
- [ ] Relier les récompenses de run, le village et le marché noir.
- [ ] Permettre une partie complète village → run → résultats → village.

## Qualité et équilibrage

- [ ] Ajouter un test d'intégration de partie complète déterministe.
- [ ] Vérifier qu'une ancienne sauvegarde peut terminer une run puis être rechargée.
- [ ] Équilibrer coûts, récompenses, vagues, événements et défis.
- [ ] Vérifier clavier/souris, lisibilité et mode réduction des effets.
- [ ] Corriger les textes mal encodés visibles dans l'interface.

## Publication

- [ ] Générer et tester les builds Windows et Linux.
- [ ] Préparer les notes de version et captures d'écran.
- [ ] Créer le tag et la release GitHub `v0.6.0-alpha`.
