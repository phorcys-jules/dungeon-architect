# Audit de recontextualisation — Dungeon Architect

Référence : #251 et `docs/vision/goblin-dungeon-architect.md`.

## Principes

1. Le joueur est un gobelin architecte indépendant.
2. Une run est un contrat commandé par un client monstrueux.
3. L'atelier concentre les investissements permanents.
4. Le village grandit avec la réputation et la campagne.
5. Les systèmes existants sont conservés lorsqu'un changement de vocabulaire ou de présentation suffit.

## Matrice de migration

| Système actuel | Nouvelle lecture | Action |
| --- | --- | --- |
| Carte roguelite | Tableau des contrats et étapes de chantier | Renommer et injecter client, objectif, biome et récompenses |
| Or de fin de run | Paiement du client | Conserver la valeur, modifier la présentation |
| Déblocages | Plans et licences de construction | Rattacher à la salle des plans |
| Ressources permanentes | Matériaux, plans, réputation | Normaliser les libellés |
| Recrutement | Sous-traitants monstrueux | Adapter les textes et portraits |
| Reliques | Prototypes d'atelier | Adapter les textes sans changer les effets |
| Marchand | Fournisseur itinérant | Adapter les textes et son emplacement narratif |
| Marché noir | Fournisseur clandestin | Conserver les malédictions comme contreparties contractuelles |
| Événements | Imprévus de chantier | Adapter annonces et historique |
| Défis | Clauses optionnelles du contrat | Lier la récompense au paiement et à la réputation |
| Encyclopédie | Archives de l'atelier | Déplacer l'accès dans le hub |
| Succès | Salle des trophées | Déplacer l'accès et adapter les intitulés |
| Écran de fin | Rapport de livraison | Ajouter satisfaction, paiement et réputation |
| Boss | Menace majeure ou inspection finale | Associer au client et au cahier des charges |

## Priorités d'intégration

### P0 — Identité immédiate

- tableau des contrats ;
- rapport de livraison ;
- paiement, réputation, plans et matériaux ;
- fournisseur, prototypes et sous-traitants.

### P1 — Hub

- atelier ;
- archives ;
- salle des trophées ;
- salle des plans ;
- bureau des contrats.

### P2 — Campagne

- clients récurrents ;
- actes narratifs ;
- croissance du village ;
- contrat final du Seigneur Démon.

## Règle de compatibilité

Les identifiants techniques historiques peuvent rester inchangés dans les sauvegardes. La couche `ArchitectContext` traduit les noms exposés au joueur afin d'éviter une migration destructive prématurée.
