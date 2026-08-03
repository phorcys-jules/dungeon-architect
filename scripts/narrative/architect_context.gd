class_name ArchitectContext
extends RefCounted

const RESOURCE_LABELS := {
    "gold": "Paiement",
    "reputation": "Réputation",
    "blueprints": "Plans",
    "materials": "Matériaux",
    "essence": "Essence de chantier",
}

const SYSTEM_CONTEXT := {
    "world_map": {
        "title": "Tableau des contrats",
        "description": "Choisissez le prochain chantier proposé à l'atelier.",
    },
    "merchant": {
        "title": "Fournisseur itinérant",
        "description": "Achetez du matériel et des plans pour le contrat en cours.",
    },
    "black_market": {
        "title": "Fournisseur clandestin",
        "description": "Obtenez du matériel rare en acceptant une contrepartie risquée.",
    },
    "relics": {
        "title": "Prototypes d'atelier",
        "description": "Des pièces expérimentales qui modifient la conception du donjon.",
    },
    "recruitment": {
        "title": "Sous-traitants monstrueux",
        "description": "Recrutez temporairement des spécialistes pour le chantier.",
    },
    "events": {
        "title": "Imprévus de chantier",
        "description": "Des incidents temporaires obligent à adapter le plan initial.",
    },
    "challenges": {
        "title": "Clauses optionnelles",
        "description": "Respectez des exigences supplémentaires pour améliorer le paiement.",
    },
    "encyclopedia": {
        "title": "Archives de l'atelier",
        "description": "Consultez les plans, créatures, clients et synergies découverts.",
    },
    "achievements": {
        "title": "Salle des trophées",
        "description": "Exposez les réalisations qui ont bâti la réputation de l'atelier.",
    },
}

static func resource_label(resource_id: String) -> String:
    return String(RESOURCE_LABELS.get(resource_id, resource_id.capitalize()))

static func system_copy(system_id: String) -> Dictionary:
    return Dictionary(SYSTEM_CONTEXT.get(system_id, {
        "title": system_id.capitalize(),
        "description": "Système de l'atelier.",
    })).duplicate(true)

static func format_run_reward(reward: Dictionary) -> Dictionary:
    return {
        "payment": int(reward.get("gold", reward.get("payment", 0))),
        "reputation": int(reward.get("reputation", 0)),
        "blueprints": int(reward.get("blueprints", 0)),
        "materials": int(reward.get("materials", 0)),
    }

static func contract_summary(run_data: Dictionary) -> Dictionary:
    var client_name := String(run_data.get("client_name", "Client confidentiel"))
    var objective := String(run_data.get("objective", "Protéger le cœur du donjon"))
    var biome := String(run_data.get("biome", "site inconnu"))
    return {
        "title": "Contrat — %s" % client_name,
        "subtitle": "%s · %s" % [biome.capitalize(), objective],
        "client": client_name,
        "objective": objective,
        "biome": biome,
    }
