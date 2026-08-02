class_name PacmanRoundState
extends RefCounted

enum Phase { COLLECTE, CHASSE, PANIQUE, RESOLUTION }

var phase := Phase.COLLECTE
var total_collectibles := 0
var remaining_collectibles := 0
var panic_time_left := 0.0

func reset(total: int) -> void:
    total_collectibles = maxi(total, 0)
    remaining_collectibles = total_collectibles
    panic_time_left = 0.0
    phase = Phase.COLLECTE

func update(remaining: int, panic_left: float, resolved: bool = false) -> Phase:
    remaining_collectibles = clampi(remaining, 0, total_collectibles)
    panic_time_left = maxf(panic_left, 0.0)
    if resolved or remaining_collectibles <= 0:
        phase = Phase.RESOLUTION
    elif panic_time_left > 0.0:
        phase = Phase.PANIQUE
    elif progress_ratio() >= 0.5:
        phase = Phase.CHASSE
    else:
        phase = Phase.COLLECTE
    return phase

func progress_ratio() -> float:
    if total_collectibles <= 0:
        return 1.0
    return clampf(1.0 - float(remaining_collectibles) / float(total_collectibles), 0.0, 1.0)

func tension_speed_multiplier() -> float:
    return 1.0 + progress_ratio() * 0.2

func label() -> String:
    match phase:
        Phase.COLLECTE:
            return "COLLECTE — %d relique(s) restante(s)" % remaining_collectibles
        Phase.CHASSE:
            return "CHASSE INTENSE — %d relique(s) restante(s)" % remaining_collectibles
        Phase.PANIQUE:
            return "PANIQUE — monstres en fuite (%.1f s)" % panic_time_left
        Phase.RESOLUTION:
            return "RÉSOLUTION — trésor ou capture"
    return ""
