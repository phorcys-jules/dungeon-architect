class_name VillageAmbientAnimator
extends Control

const CAMPFIRE_POSITION := Vector2(330, 270)
const FORGE_CHIMNEY_POSITION := Vector2(510, 82)
const TORCH_POSITIONS: Array[Vector2] = [
    Vector2(255, 100), Vector2(457, 110), Vector2(244, 184), Vector2(334, 172),
    Vector2(378, 174), Vector2(484, 260), Vector2(51, 390), Vector2(241, 382),
    Vector2(350, 379), Vector2(502, 394), Vector2(382, 531), Vector2(475, 533),
]

var elapsed := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)

func _process(delta: float) -> void:
    elapsed = fmod(elapsed + delta, 120.0)
    queue_redraw()

func _draw() -> void:
    _draw_campfire()
    for index in TORCH_POSITIONS.size():
        _draw_torch(TORCH_POSITIONS[index], index * 0.73)
    _draw_forge_smoke()

func _draw_campfire() -> void:
    var pulse := 1.0 + sin(elapsed * 7.0) * 0.08 + sin(elapsed * 11.0) * 0.04
    draw_circle(CAMPFIRE_POSITION, 31.0 * pulse, Color("ff8a32", 0.07))
    draw_circle(CAMPFIRE_POSITION, 20.0 * pulse, Color("ffb52e", 0.10))
    _draw_flame(CAMPFIRE_POSITION + Vector2(0, 1), 16.0, elapsed * 8.0)
    _draw_flame(CAMPFIRE_POSITION + Vector2(-7, 4), 10.0, elapsed * 9.3 + 1.7)
    _draw_flame(CAMPFIRE_POSITION + Vector2(7, 4), 11.0, elapsed * 7.6 + 3.1)
    for index in 9:
        var progress := fmod(elapsed * (0.34 + index * 0.018) + index * 0.137, 1.0)
        var drift := sin(elapsed * 2.1 + index * 2.4) * (3.0 + progress * 8.0)
        var spark_position := CAMPFIRE_POSITION + Vector2(drift, -8.0 - progress * 34.0)
        var alpha := sin(progress * PI) * 0.9
        draw_circle(spark_position, 1.7 - progress * 0.8, Color("ffd65a", alpha))

func _draw_torch(position: Vector2, phase: float) -> void:
    var pulse := 1.0 + sin(elapsed * 8.5 + phase) * 0.12
    draw_circle(position, 11.0 * pulse, Color("ff9c35", 0.065))
    _draw_flame(position + Vector2(0, -1), 5.5, elapsed * 10.0 + phase)

func _draw_flame(base: Vector2, height: float, phase: float) -> void:
    var sway := sin(phase) * height * 0.16
    var width := height * (0.34 + sin(phase * 1.37) * 0.025)
    var outer := PackedVector2Array([
        base + Vector2(-width, 2),
        base + Vector2(-width * 0.72, -height * 0.42),
        base + Vector2(sway, -height),
        base + Vector2(width * 0.8, -height * 0.38),
        base + Vector2(width, 2),
    ])
    draw_colored_polygon(outer, Color("ff7a24", 0.92))
    var inner := PackedVector2Array([
        base + Vector2(-width * 0.48, 1),
        base + Vector2(sway * 0.35, -height * 0.62),
        base + Vector2(width * 0.5, 1),
    ])
    draw_colored_polygon(inner, Color("ffd85a", 0.96))

func _draw_forge_smoke() -> void:
    for index in 5:
        var progress := fmod(elapsed * 0.105 + index * 0.2, 1.0)
        var wind := progress * 23.0 + sin(elapsed * 0.8 + index) * 3.0
        var position := FORGE_CHIMNEY_POSITION + Vector2(wind, -progress * 58.0)
        var alpha := sin(progress * PI) * 0.22
        var radius := 5.0 + progress * 8.0
        draw_circle(position, radius, Color("9aa2b5", alpha))
        draw_circle(position + Vector2(-radius * 0.35, 1), radius * 0.7, Color("596174", alpha * 0.7))
