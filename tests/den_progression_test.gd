extends SceneTree

const DenProgressionScript := preload("res://scripts/village/den_progression.gd")

func _init() -> void:
    var den: DenProgression = DenProgressionScript.new()
    if den.get_capacity() != 2:
        quit(1)
        return
    den.add_soul_shards(40)
    if not den.upgrade() or den.level != 1 or den.get_capacity() != 4:
        quit(1)
        return
    var saved := den.serialize()
    var restored: DenProgression = DenProgressionScript.new()
    restored.restore(saved)
    if restored.level != 1 or restored.soul_shards != den.soul_shards:
        quit(1)
        return
    print("Den progression test passed")
    quit(0)
