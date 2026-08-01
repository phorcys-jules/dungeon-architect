extends SceneTree

const HealthComponentScript := preload("res://scripts/components/health_component.gd")

var failures: Array[String] = []
var death_count := 0

func _init() -> void:
    var health = HealthComponentScript.new()
    health.max_health = 100
    health.died.connect(_on_died)
    root.add_child(health)
    await process_frame

    _expect(health.current_health == 100, "La santé doit démarrer au maximum.")
    _expect(health.take_damage(30) == 30, "Les dégâts appliqués doivent être retournés.")
    _expect(health.current_health == 70, "Les dégâts doivent réduire la santé.")
    _expect(health.heal(20) == 20, "Les soins appliqués doivent être retournés.")
    _expect(health.current_health == 90, "Les soins doivent augmenter la santé.")
    _expect(health.heal(100) == 10, "Les soins ne doivent pas dépasser le maximum.")
    _expect(health.current_health == 100, "La santé ne doit pas dépasser le maximum.")
    _expect(health.take_damage(150) == 100, "Les dégâts doivent être limités à la santé restante.")
    _expect(health.current_health == 0, "La santé ne doit pas descendre sous zéro.")
    _expect(health.is_dead, "Le composant doit être marqué mort à zéro PV.")
    _expect(death_count == 1, "Le signal de mort doit être émis une seule fois.")
    _expect(health.take_damage(10) == 0, "Une unité morte ne doit plus recevoir de dégâts.")
    _expect(death_count == 1, "Les dégâts après la mort ne doivent pas réémettre le signal.")

    health.reset()
    _expect(health.current_health == 100 and not health.is_dead, "Reset doit restaurer la santé et l'état vivant.")

    health.queue_free()

    if failures.is_empty():
        print("HEALTH COMPONENT TEST PASSED")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)

func _on_died() -> void:
    death_count += 1

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
