extends SceneTree

const DamageResolverScript := preload("res://scripts/core/damage_resolver.gd")
const Scout := preload("res://resources/adventurers/scout.tres")
const Warrior := preload("res://resources/adventurers/warrior.tres")
const Champion := preload("res://resources/adventurers/champion.tres")

func _init() -> void:
    assert(DamageResolverScript.resolve(35, Scout, DamageResolver.DamageSource.TRAP) == 25)
    assert(DamageResolverScript.resolve(35, Warrior, DamageResolver.DamageSource.TRAP) == 31)
    assert(DamageResolverScript.resolve(35, Champion, DamageResolver.DamageSource.TRAP) == 24)
    assert(DamageResolverScript.resolve(12, Scout, DamageResolver.DamageSource.DEFENDER) == 12)
    assert(DamageResolverScript.resolve(12, Warrior, DamageResolver.DamageSource.DEFENDER) == 7)
    assert(DamageResolverScript.resolve(12, Champion, DamageResolver.DamageSource.DEFENDER) == 1)
    assert(DamageResolverScript.resolve(0, Champion, DamageResolver.DamageSource.TRAP) == 0)
    print("DamageResolver test passed")
    quit(0)
