extends SceneTree

func _init() -> void:
    var catalog := EncyclopediaCatalog.new()
    var progress := EncyclopediaProgress.new()

    var unknown := progress.visible_entry(catalog, "monster_slime")
    assert(String(unknown.name) == "???")
    assert(String(unknown.description) == "")

    progress.preview("monster_slime")
    var previewed := progress.visible_entry(catalog, "monster_slime")
    assert(int(previewed.state) == EncyclopediaCatalog.DiscoveryState.PREVIEWED)
    assert(not String(previewed.description).is_empty())

    assert(progress.discover("monster_slime"))
    assert(not progress.discover("monster_slime"))
    progress.record_use("monster_slime", true)
    progress.record_use("monster_slime", false)
    var discovered := progress.visible_entry(catalog, "monster_slime")
    assert(String(discovered.name) == "Slime")
    assert(int(discovered.stats.uses) == 2)
    assert(int(discovered.stats.wins) == 1)

    var restored := EncyclopediaProgress.new()
    restored.from_dict(progress.to_dict())
    assert(restored.state_of("monster_slime") == EncyclopediaCatalog.DiscoveryState.DISCOVERED)
    assert(int(restored.stats["monster_slime"].uses) == 2)
    assert(catalog.list_by_kind("monster").size() == 4)
    assert(catalog.list_by_kind("room").size() >= 9)
    assert(catalog.list_by_kind("adventurer").size() >= 7)
    assert(restored.pending_notifications == ["monster_slime"])
    assert(restored.consume_notifications() == ["monster_slime"])
    assert(restored.pending_notifications.is_empty())

    print("encyclopedia test passed")
    quit()
