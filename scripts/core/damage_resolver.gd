class_name DamageResolver
extends RefCounted

enum DamageSource { TRAP, DEFENDER }

static func resolve(base_damage: int, adventurer: AdventurerData, source: DamageSource) -> int:
    if base_damage <= 0 or adventurer == null:
        return 0
    var multiplier := adventurer.trap_damage_multiplier if source == DamageSource.TRAP else adventurer.defender_damage_multiplier
    var scaled_damage := roundi(float(base_damage) * multiplier)
    return maxi(scaled_damage - adventurer.flat_armor, 1)
