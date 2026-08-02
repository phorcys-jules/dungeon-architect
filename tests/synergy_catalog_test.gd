extends SceneTree

func _init() -> void:
    var paths := [
        "res://resources/synergies/ghost_fog.tres",
        "res://resources/synergies/slime_ice.tres",
        "res://resources/synergies/mimic_treasure.tres",
    ]
    var definitions: Array[SynergyData] = []
    for path: String in paths:
        var definition := load(path) as SynergyData
        if definition == null or not definition.is_valid():
            push_error("Invalid synergy resource: %s" % path)
            quit(1)
            return
        definitions.append(definition)

    var engine := SynergyEngine.new()
    engine.configure(definitions)
    var result := engine.evaluate([&"ghost", &"fog", &"mimic", &"treasure"])
    var active: Array = result.get("active_synergies", [])
    if active.size() != 2:
        push_error("Expected two active synergies")
        quit(1)
        return
    var modifiers: Dictionary = result.get("modifiers", {})
    if not modifiers.has("first_hit_damage_multiplier"):
        push_error("Expected mimic treasure modifier")
        quit(1)
        return

    print("Synergy catalog test passed")
    quit(0)
