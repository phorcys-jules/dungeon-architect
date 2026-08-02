class_name AdventurerPerception
extends RefCounted

var vision_range := 5
var fear := 0.0
var morale := 100.0
var cautious_threshold := 35.0
var flee_threshold := 70.0

func visible_cells(origin: Vector2i, blocked: Array[Vector2i], darkness_penalty: int = 0, fog_penalty: int = 0) -> Array[Vector2i]:
    var result: Array[Vector2i] = []
    var effective_range := maxi(vision_range - darkness_penalty - fog_penalty, 1)
    for x in range(origin.x - effective_range, origin.x + effective_range + 1):
        for y in range(origin.y - effective_range, origin.y + effective_range + 1):
            var cell := Vector2i(x, y)
            if origin.distance_to(cell) > effective_range:
                continue
            if _has_line_of_sight(origin, cell, blocked):
                result.append(cell)
    return result

func apply_threat(amount: float, morale_damage: float = 0.0) -> void:
    fear = clampf(fear + amount, 0.0, 100.0)
    morale = clampf(morale - morale_damage, 0.0, 100.0)

func recover(fear_recovery: float, morale_recovery: float) -> void:
    fear = clampf(fear - fear_recovery, 0.0, 100.0)
    morale = clampf(morale + morale_recovery, 0.0, 100.0)

func decision_state() -> String:
    if fear >= flee_threshold or morale <= 20.0:
        return "flee"
    if fear >= cautious_threshold or morale <= 45.0:
        return "cautious"
    return "advance"

func configure_for_class(class_id: String) -> void:
    match class_id:
        "thief":
            vision_range = 6
            cautious_threshold = 45.0
            flee_threshold = 80.0
        "mage":
            vision_range = 7
            cautious_threshold = 30.0
            flee_threshold = 65.0
        "priest":
            vision_range = 5
            cautious_threshold = 40.0
            flee_threshold = 75.0
        "berserker":
            vision_range = 4
            cautious_threshold = 65.0
            flee_threshold = 95.0
        _:
            vision_range = 5
            cautious_threshold = 35.0
            flee_threshold = 70.0

func to_dict() -> Dictionary:
    return {
        "vision_range": vision_range,
        "fear": fear,
        "morale": morale,
        "cautious_threshold": cautious_threshold,
        "flee_threshold": flee_threshold,
    }

func from_dict(data: Dictionary) -> void:
    vision_range = int(data.get("vision_range", 5))
    fear = float(data.get("fear", 0.0))
    morale = float(data.get("morale", 100.0))
    cautious_threshold = float(data.get("cautious_threshold", 35.0))
    flee_threshold = float(data.get("flee_threshold", 70.0))

func _has_line_of_sight(origin: Vector2i, target: Vector2i, blocked: Array[Vector2i]) -> bool:
    var points := _bresenham(origin, target)
    for index in range(1, maxi(points.size() - 1, 1)):
        if blocked.has(points[index]):
            return false
    return true

func _bresenham(start: Vector2i, finish: Vector2i) -> Array[Vector2i]:
    var result: Array[Vector2i] = []
    var x0 := start.x
    var y0 := start.y
    var x1 := finish.x
    var y1 := finish.y
    var dx := absi(x1 - x0)
    var sx := 1 if x0 < x1 else -1
    var dy := -absi(y1 - y0)
    var sy := 1 if y0 < y1 else -1
    var error := dx + dy
    while true:
        result.append(Vector2i(x0, y0))
        if x0 == x1 and y0 == y1:
            break
        var doubled := 2 * error
        if doubled >= dy:
            error += dy
            x0 += sx
        if doubled <= dx:
            error += dx
            y0 += sy
    return result
