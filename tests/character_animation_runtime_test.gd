extends SceneTree

func _init() -> void:
    assert(CharacterAnimationRuntime.frame_index(0.0, false) == 2)
    assert(CharacterAnimationRuntime.frame_index(0.0, true) == 0)
    assert(CharacterAnimationRuntime.frame_index(0.125, true) == 1)
    assert(CharacterAnimationRuntime.frame_index(0.125, true, 2.0) == 2)
    assert(CharacterAnimationRuntime.facing_sign(-2.0) == -1.0)
    assert(CharacterAnimationRuntime.facing_sign(2.0, -1.0) == 1.0)
    assert(CharacterAnimationRuntime.facing_sign(0.0, -1.0) == -1.0)
    assert(CharacterAnimationRuntime.damage_tint(0.0) == Color.WHITE)
    assert(CharacterAnimationRuntime.attack_scale(0.09) > 1.0)
    assert(is_equal_approx(CharacterAnimationRuntime.attack_scale(0.0), 1.0))
    assert(CharacterAnimationRuntime.attack_offset(0.11, Vector2.RIGHT).x > 0.0)
    assert(CharacterAnimationRuntime.attack_offset(0.0, Vector2.RIGHT) == Vector2.ZERO)
    print("Character animation runtime test passed")
    quit(0)
