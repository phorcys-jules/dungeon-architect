class_name RogueliteWorldMap
extends RefCounted

enum NodeType { COMBAT, ELITE, MERCHANT, BOSS }

var seed: int = 0
var columns: Array[Array] = []
var current_column := 0
var current_node_id := ""
var visited: Array[String] = []

func generate(run_seed: int, depth: int = 6, width: int = 3) -> void:
    seed = run_seed
    columns.clear()
    current_column = 0
    current_node_id = ""
    visited.clear()
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
    }

func from_dict(data: Dictionary) -> void:
    seed = int(data.get("seed", 0))
    columns.assign(data.get("columns", []))
    current_column = int(data.get("current_column", 0))
    current_node_id = String(data.get("current_node_id", ""))
    visited.assign(data.get("visited", []))

func _roll_type(rng: RandomNumberGenerator, column_index: int) -> NodeType:
    var roll := rng.randf()
    if column_index > 0 and roll < 0.18:
        return NodeType.ELITE
    if roll < 0.36:
        return NodeType.MERCHANT
    return NodeType.COMBAT

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
