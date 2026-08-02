class_name CharacterAnimationRuntime
extends RefCounted

const FRAME_COUNT := 4
const BASE_FPS := 8.0

static func frame_index(elapsed: float, moving: bool, speed_multiplier: float = 1.0, phase: float = 0.0) -> int:
    if not moving:
        return 2
    var safe_speed := clampf(speed_multiplier, 0.35, 2.5)
    return int((elapsed + phase) * BASE_FPS * safe_speed) % FRAME_COUNT

static func facing_sign(horizontal_delta: float, current_sign: float = 1.0) -> float:
    if absf(horizontal_delta) < 0.001:
        return current_sign
    return 1.0 if horizontal_delta > 0.0 else -1.0

static func damage_tint(remaining: float) -> Color:
    if remaining <= 0.0:
        return Color.WHITE
    return Color("ff8f8f") if int(remaining * 24.0) % 2 == 0 else Color.WHITE

static func attack_scale(remaining: float, duration: float = 0.18) -> float:
    if remaining <= 0.0 or duration <= 0.0:
        return 1.0
    var progress := 1.0 - clampf(remaining / duration, 0.0, 1.0)
    return 1.0 + sin(progress * PI) * 0.18

static func attack_offset(remaining: float, direction: Vector2, duration: float = 0.22, distance: float = 10.0) -> Vector2:
    if remaining <= 0.0 or duration <= 0.0 or direction.is_zero_approx():
        return Vector2.ZERO
    var progress := 1.0 - clampf(remaining / duration, 0.0, 1.0)
    return direction.normalized() * sin(progress * PI) * distance
