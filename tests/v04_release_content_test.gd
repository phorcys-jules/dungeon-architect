extends SceneTree

func _init() -> void:
    var catalog := V04ContentCatalog.new()
    if catalog.adventurers().size() != 4 or catalog.buildings().size() != 3:
        quit(1)
        return
    for profile: AdventurerProfileData in catalog.adventurers():
        if not profile.is_valid():
            quit(1)
            return
    for building: VillageBuildingData in catalog.buildings():
        if not building.is_valid():
            quit(1)
            return
    if catalog.permanent_upgrades().size() != 6 or catalog.extra_synergies().size() != 3:
        quit(1)
        return
    var boss := catalog.mini_boss()
    if float(boss.get("health_multiplier", 0.0)) < 3.0:
        quit(1)
        return
    var migrated := catalog.migrate_save({"save_version": 1, "stored_resources": 100})
    if int(migrated.get("save_version", 0)) != 2 or not migrated.has("buildings"):
        quit(1)
        return
    var service := V04ProgressionService.new(migrated)
    var forge := service.buy_building_level(&"forge", 100)
    if not bool(forge.get("success", false)) or int(forge.get("remaining", -1)) != 40:
        quit(1)
        return
    var upgrade := service.buy_upgrade(&"swift_horde", int(forge["remaining"]))
    if not bool(upgrade.get("success", false)) or int(upgrade.get("remaining", -1)) != 0:
        quit(1)
        return
    var modifiers := service.combined_modifiers()
    if float(modifiers.get(&"trap_damage_multiplier", 0.0)) <= 0.0 or float(modifiers.get(&"monster_speed_multiplier", 0.0)) <= 0.0:
        quit(1)
        return
    print("v0.4 release content test passed")
    quit(0)
