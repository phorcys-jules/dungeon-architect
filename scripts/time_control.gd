class_name TimeControl
extends RefCounted

enum Mode { PAUSED, NORMAL, X2, X4 }
var mode: int = Mode.NORMAL

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
