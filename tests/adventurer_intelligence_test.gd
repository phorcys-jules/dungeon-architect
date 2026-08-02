extends SceneTree

const Scout := preload("res://resources/adventurers/scout.tres")
const IntelligenceScript := preload("res://scripts/meta/adventurer_intelligence.gd")

func _init() -> void:
    var intelligence: RefCounted = IntelligenceScript.new()
    var basic: Dictionary = intelligence.report(Scout, 0)
    var improved: Dictionary = intelligence.report(Scout, 2)
    assert(basic.visible.size() == 2)
    assert(int(basic.hidden_count) > 0)
    assert(improved.visible.size() == 4)
    assert(int(improved.hidden_count) < int(basic.hidden_count))
    assert(intelligence.record_encounter("scout"))
    assert(not intelligence.record_encounter("scout"))
    var restored: RefCounted = IntelligenceScript.new()
    restored.from_dict(intelligence.to_dict())
    assert(restored.encountered == ["scout"])
    print("Adventurer intelligence test passed")
    quit(0)
