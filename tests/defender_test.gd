extends SceneTree

const HealthComponentScript := preload("res://scripts/components/health_component.gd")
const DefenderScript := preload("res://scripts/monsters/defender.gd")

func _init() -> void:
    var health: HealthComponent = HealthComponentScript.new()
    health.max_health = 100
    root.add_child(health)

    var defender: Defender = DefenderScript.new()
    defender.damage = 20
    defender.cooldown = 1.0
    defender.attack_range_cells = 2.0
    defender.setup(Vector2i(2, 2), Vector2(96, 96))
    root.add_child(defender)

    assert(defender.try_attack(Vector2(144, 96), health, 48.0))
    assert(health.current_health == 80)
    assert(not defender.try_attack(Vector2(144, 96), health, 48.0))
    defender.tick(1.0)
    assert(defender.try_attack(Vector2(144, 96), health, 48.0))
    assert(health.current_health == 60)
    defender.tick(1.0)
    assert(not defender.try_attack(Vector2(500, 500), health, 48.0))

    print("Defender test passed")
    quit(0)
