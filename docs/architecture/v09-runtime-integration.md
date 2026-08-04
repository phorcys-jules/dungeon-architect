# Intégration runtime v0.9

`V09ArchitectRuntime` est le point d’entrée unique des fonctionnalités ajoutées autour de Grib et de son atelier.

Il orchestre :

- `WorkshopHub` et `WorkshopUpgradeTree` ;
- `MonsterContractSystem` ;
- `GribStory` ;
- `VillageNarrativeGrowth` et `VillageResidents` ;
- `ArchitectCampaign` ;
- `DemonLordFinalContract`.

La scène principale doit appeler :

- `enter_hub()` au retour d’une run ;
- `generate_contract(seed)` au choix du prochain chantier ;
- `complete_contract(metrics)` lors du débrief ;
- `begin_final_contract()` et `complete_final_contract(metrics)` pour la conclusion ;
- `to_dict()` / `from_dict()` dans le système de sauvegarde.

Cette façade évite que les scènes dépendent directement de huit systèmes séparés et empêche la création de nouveaux contrôleurs suffixés par une version.
