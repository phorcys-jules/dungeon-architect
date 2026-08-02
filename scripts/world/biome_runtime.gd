class_name BiomeRuntime
extends RefCounted

var catalog := BiomeCatalog.new()
var active_biome_id := BiomeCatalog.CRYPT
var seed := 0

func select_for_zone(run_seed: int, zone_index: int) -> String:
    seed = run_seed
    var ids := catalog.all_ids()
    if ids.is_empty():
        active_biome_id = ""
        return active_biome_id
    var rng := RandomNumberGenerator.new()
    rng.seed = run_seed + zone_index * 104729
    active_biome_id = ids[rng.randi_range(0, ids.size() - 1)]
    return active_biome_id

func set_active(biome_id: String) -> bool:
    if catalog.get_biome(biome_id).is_empty():
        return false
    active_biome_id = biome_id
    return true

func rule_value(rule_name: String, default_value: float = 1.0) -> float:
    var biome := catalog.get_biome(active_biome_id)
    if biome.is_empty():
        return default_value
    return float(biome.rules.get(rule_name, default_value))

func wall_cost(base_cost: int) -> int:
    var biome := catalog.get_biome(active_biome_id)
    if biome.is_empty():
        return base_cost
    return maxi(1, roundi(base_cost * float(biome.construction.wall_cost_multiplier)))

func can_place_room(room_tags: Array[String]) -> Dictionary:
    return catalog.validate_room_tags(active_biome_id, room_tags)

func can_start_run(placed_room_tags: Array[String]) -> bool:
    return catalog.has_required_room(active_biome_id, placed_room_tags)

func to_dict() -> Dictionary:
    return {"active_biome_id": active_biome_id, "seed": seed}

func from_dict(data: Dictionary) -> void:
    seed = int(data.get("seed", 0))
    var saved_id := String(data.get("active_biome_id", BiomeCatalog.CRYPT))
    active_biome_id = saved_id if not catalog.get_biome(saved_id).is_empty() else BiomeCatalog.CRYPT
