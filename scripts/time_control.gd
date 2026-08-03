class_name TimeControl
extends RefCounted

enum Mode { PAUSED, NORMAL, X2, X4 }
var mode: int = Mode.NORMAL
var tick_count: int = 0

func set_mode(m: int) -> void:
	mode = m

func get_multiplier() -> float:
	match mode:
		Mode.PAUSED:
			return 0.0
		Mode.NORMAL:
			return 1.0
		Mode.X2:
			return 2.0
		Mode.X4:
			return 4.0
		_:
			return 1.0

func step_once() -> void:
	# Advance exactly one logical tick even if paused
	tick_count += 1

func tick(delta: float) -> void:
	# Called by game loop: advances ticks according to multiplier
	var m := get_multiplier()
	if m == 0.0:
		return
	# advance tick_count proportionally to m and delta (simplified)
	tick_count += int(ceil(m * delta))

func get_tick_count() -> int:
	return tick_count
