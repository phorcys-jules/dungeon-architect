extends SceneTree

const HealthComponentScript := preload("res://scripts/components/health_component.gd")
const SpikeTrapScript := preload("res://scripts/traps/spike_trap.gd")

func _initialize() -> void:
    var health: HealthComponent = HealthComponentScript.new()
    health.max_health = 100
    root.add_child(health)
    health.reset()

    var trap: SpikeTrap = SpikeTrapScript.new()
    root.add_child(trap)
    trap.setup(Vector2i(3, 4))

    _assert(trap.is_ready, "Le piège doit être prêt au départ")
    _assert(trap.try_trigger(health), "Le premier déclenchement doit réussir")
    _assert(health.current_health == 65, "Le piège doit infliger 35 dégâts")
    _assert(not trap.try_trigger(health), "Le piège ne doit pas se redéclencher pendant la recharge")

    trap.tick(1.5)
    _assert(trap.is_ready, "Le piège doit redevenir prêt après la recharge")
    _assert(trap.try_trigger(health), "Le piège doit pouvoir se redéclencher")
    _assert(health.current_health == 30, "Le second déclenchement doit infliger des dégâts")

    trap.reset()
    _assert(trap.is_ready, "Reset doit rendre le piège prêt")
    print("SpikeTrap tests passed")
    quit(0)

func _assert(condition: bool, message: String) -> void:
    if condition:
        return
    push_error(message)
    quit(1)
