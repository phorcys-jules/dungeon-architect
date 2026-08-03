extends SceneTree

func _init() -> void:
    assert(ArchitectContext.resource_label("gold") == "Paiement")
    assert(ArchitectContext.resource_label("blueprints") == "Plans")

    var map_copy := ArchitectContext.system_copy("world_map")
    assert(String(map_copy.title) == "Tableau des contrats")
    assert(not String(map_copy.description).is_empty())

    var reward := ArchitectContext.format_run_reward({
        "gold": 120,
        "reputation": 8,
        "blueprints": 2,
        "materials": 15,
    })
    assert(int(reward.payment) == 120)
    assert(int(reward.reputation) == 8)
    assert(int(reward.blueprints) == 2)
    assert(int(reward.materials) == 15)

    var summary := ArchitectContext.contract_summary({
        "client_name": "Dame Morvane",
        "objective": "Protéger le phylactère",
        "biome": "crypt",
    })
    assert(String(summary.title) == "Contrat — Dame Morvane")
    assert(String(summary.client) == "Dame Morvane")
    assert(String(summary.objective) == "Protéger le phylactère")
    assert(String(summary.subtitle).contains("Crypt"))

    print("architect context test passed")
    quit()
