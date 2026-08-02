extends SceneTree

func _init() -> void:
    var choice_engine := RogueliteChoiceEngine.new()
    var first := choice_engine.offer(3030, 2)
    var second := choice_engine.offer(3030, 2)
    if first != second or first.size() != 3:
        quit(1)
        return

    var definitions: Array[SynergyData] = [
        load("res://resources/synergies/ghost_fog.tres") as SynergyData,
        load("res://resources/synergies/slime_ice.tres") as SynergyData,
        load("res://resources/synergies/mimic_treasure.tres") as SynergyData,
    ]
    var state := RunBuildState.new()
    state.configure_synergies(definitions)
    if not state.apply_choice({"id": &"fog", "tags": [&"fog"]}):
        quit(1)
        return
    if not state.apply_choice({"id": &"ice", "tags": [&"ice"]}):
        quit(1)
        return
    if not state.apply_choice({"id": &"treasure", "tags": [&"treasure"]}):
        quit(1)
        return
    if state.active_synergy_ids.size() != 3 or state.get_active_synergy_labels().size() != 3:
        quit(1)
        return
    if state.apply_choice({"id": &"fog", "tags": [&"fog"]}):
        quit(1)
        return
    print("Roguelite synergy build test passed")
    quit(0)
