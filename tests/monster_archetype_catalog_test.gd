extends SceneTree

const PATHS := [
    "res://resources/monsters/ghost.tres",
    "res://resources/monsters/slime.tres",
    "res://resources/monsters/mimic.tres",
    "res://resources/monsters/spider.tres",
]

func _init() -> void:
    var abilities: Dictionary = {}
    var tags: Dictionary = {}
    for path: String in PATHS:
        var archetype := load(path) as MonsterArchetypeData
        if archetype == null or not archetype.is_valid():
            push_error("Invalid monster archetype: %s" % path)
            quit(1)
            return
        for ability: StringName in archetype.abilities:
            abilities[ability] = true
        for tag: StringName in archetype.tags:
            tags[tag] = true

    for required_ability: StringName in [&"phase", &"slow_trail", &"first_hit_burst", &"web_crossroads"]:
        if not abilities.has(required_ability):
            quit(1)
            return
    for required_tag: StringName in [&"ghost", &"slime", &"mimic", &"spider"]:
        if not tags.has(required_tag):
            quit(1)
            return

    print("Monster archetype catalog test passed")
    quit(0)
