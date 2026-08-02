extends SceneTree

func _init() -> void:
    var roster = load("res://scripts/meta/monster_roster.gd").new()
    assert(roster.recruit("slime", 100).ok)
    assert(not roster.recruit("slime", 100).ok)
    assert(roster.select_team(["ghost", "slime"]))
    assert(not roster.select_team(["ghost", "unknown"]))

    var saved_roster := roster.to_dict()
    var restored_roster = load("res://scripts/meta/monster_roster.gd").new()
    restored_roster.from_dict(saved_roster)
    assert(restored_roster.selected_team == ["ghost", "slime"])

    var relics = load("res://scripts/meta/relic_catalog.gd").new()
    assert(relics.grant("blood_crown"))
    assert(relics.grant("thorn_heart"))
    assert(relics.equip(["blood_crown", "thorn_heart"]))
    var effects := relics.combined_effects()
    assert(is_equal_approx(float(effects.monster_damage_multiplier), 1.15))
    assert(is_equal_approx(float(effects.trap_damage_multiplier), 1.25))

    var restored_relics = load("res://scripts/meta/relic_catalog.gd").new()
    restored_relics.from_dict(relics.to_dict())
    assert(restored_relics.equipped.size() == 2)

    print("monster roster and relics test passed")
    quit()
