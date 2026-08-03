class_name RogueliteWorldMap
extends RefCounted

enum NodeType { COMBAT, ELITE, MERCHANT, EVENT, BOSS }

const FACTIONS := {
    &"sun_order": {"name": "Ordre solaire", "resistance": &"fire", "reward": "gold", "style": "formation"},
    &"free_blades": {"name": "Lames libres", "resistance": &"fear", "reward": "stone", "style": "mobility"},
    &"arcane_circle": {"name": "Cercle arcanique", "resistance": &"frost", "reward": "essence", "style": "dispel"},
}

var seed: int = 0
var columns: Array[Array] = []
var current_column := 0
var current_node_id := ""
var visited: Array[String] = []
var decisions: Dictionary = {}

func generate(run_seed: int, depth: int = 6, width: int = 3) -> void:
    seed = run_seed
    columns.clear()
    current_column = 0
    current_node_id = ""
    visited.clear()
    decisions.clear()
    var rng := RandomNumberGenerator.new()
    rng.seed = run_seed
    for column_index in depth:
        var column: Array = []
        var node_count := 1 if column_index == depth - 1 else width
        for row_index in node_count:
            var node_type := NodeType.BOSS if column_index == depth - 1 else _roll_type(rng, column_index)
            column.append({
                "id": "%d:%d" % [column_index, row_index],
                "column": column_index,
                "row": row_index,
                "type": node_type,
                "act": mini(3, 1 + int(floor(float(column_index) / maxf(float(depth) / 3.0, 1.0)))),
                "faction": _faction_for(run_seed, column_index, row_index),
                "biome": _biome_for(column_index),
                "next": [],
            })
        columns.append(column)
    _connect_columns(rng)

func available_nodes() -> Array:
    if columns.is_empty() or current_column >= columns.size():
        return []
    if current_node_id.is_empty():
        return columns[0].duplicate(true)
    var current := find_node(current_node_id)
    var result: Array = []
    for next_id in current.get("next", []):
        result.append(find_node(String(next_id)))
    return result

func choose(node_id: String) -> bool:
    var candidates := available_nodes()
    for candidate in candidates:
        if candidate.id == node_id:
            current_node_id = node_id
            current_column = int(candidate.column) + 1
            visited.append(node_id)
            decisions[node_id] = {"faction": candidate.faction, "type": candidate.type}
            return true
    return false

func is_complete() -> bool:
    if current_node_id.is_empty():
        return false
    return int(find_node(current_node_id).type) == NodeType.BOSS

func find_node(node_id: String) -> Dictionary:
    for column in columns:
        for node in column:
            if node.id == node_id:
                return node
    return {}

func to_dict() -> Dictionary:
    return {
        "seed": seed,
        "columns": columns.duplicate(true),
        "current_column": current_column,
        "current_node_id": current_node_id,
        "visited": visited.duplicate(),
        "decisions": decisions.duplicate(true),
    }

func from_dict(data: Dictionary) -> void:
    seed = int(data.get("seed", 0))
    columns.assign(data.get("columns", []))
    current_column = int(data.get("current_column", 0))
    current_node_id = String(data.get("current_node_id", ""))
    visited.assign(data.get("visited", []))
    decisions = Dictionary(data.get("decisions", {})).duplicate(true)

func _roll_type(rng: RandomNumberGenerator, column_index: int) -> NodeType:
    var roll := rng.randf()
    if column_index > 0 and roll < 0.18:
        return NodeType.ELITE
    if roll < 0.36:
        return NodeType.MERCHANT
    if roll < 0.48:
        return NodeType.EVENT
    return NodeType.COMBAT

func faction_definition(faction_id: StringName) -> Dictionary:
    return FACTIONS.get(faction_id, {}).duplicate(true)

func route_preview(node_id: String) -> Dictionary:
    var node := find_node(node_id)
    if node.is_empty():
        return {}
    var faction := faction_definition(StringName(node.faction))
    return {"id": node.id, "act": node.act, "type": node.type, "faction": faction, "biome": node.biome, "known": true}

func _faction_for(run_seed: int, column_index: int, row_index: int) -> StringName:
    var ids: Array[StringName] = [&"sun_order", &"free_blades", &"arcane_circle"]
    return ids[abs(run_seed + column_index * 7 + row_index * 13) % ids.size()]

func _biome_for(column_index: int) -> StringName:
    return [&"crypt", &"mine", &"sewers"][mini(2, int(floor(float(column_index) / maxf(float(columns.size()) / 3.0, 1.0))))] if not columns.is_empty() else &"crypt"

func _connect_columns(rng: RandomNumberGenerator) -> void:
    for column_index in columns.size() - 1:
        var current: Array = columns[column_index]
        var next: Array = columns[column_index + 1]
        for node in current:
            var primary := mini(int(node.row), next.size() - 1)
            node.next.append(next[primary].id)
            if next.size() > 1 and rng.randf() < 0.65:
                var alternate := clampi(primary + (-1 if rng.randf() < 0.5 else 1), 0, next.size() - 1)
                if alternate != primary:
                    node.next.append(next[alternate].id)
