# Intégration

`WorkshopUpgradeTree` s’appuie sur `WorkshopHub` pour lire les niveaux de stations et débiter les ressources. Sa sauvegarde reste séparée afin de permettre une migration indépendante des anciennes parties.

Les effets numériques sont cumulés ; les déblocages textuels conservent leur identifiant. Les consommateurs peuvent appeler `combined_effects()` au démarrage d’un contrat.
