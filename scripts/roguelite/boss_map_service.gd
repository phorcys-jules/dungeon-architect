class_name BossMapService
extends RefCounted

var catalog := BossCatalog.new()
var encounter := BossEncounter.new()
var selected_boss_id := ""

func prepare_for_map(world_map: RogueliteWorldMap) -> Dictionary:
    if world_map.columns.is_empty():
        return {}
    var last_column: Array = world_map.columns[world_map.columns.size() - 1]
    if last_column.is_empty() or int(last_column[0].get("type", -1)) != RogueliteWorldMap.NodeType.BOSS:
        return {}
    selected_boss_id = catalog.select_for_seed(world_map.seed)
    var definition := catalog.get_boss(selected_boss_id)
    if not encounter.start(selected_boss_id, definition):
        return {}
    return encounter.introduction()

func resolve_victory() -> Dictionary:
    if not encounter.finished:
        return {"ok": false, "reward": {}}
    return {"ok": true, "reward": encounter.reward(), "boss_id": selected_boss_id}
