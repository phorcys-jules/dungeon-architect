class_name AdventurerSquadRuntime
extends RefCounted

const ROLES := [&"scout", &"tank", &"healer", &"disarmer", &"ranged"]
const COOLDOWNS := {&"scout": 3.0, &"tank": 5.0, &"healer": 6.0, &"disarmer": 4.0, &"ranged": 3.5}

var members: Array[Dictionary] = []

func configure(wave: int) -> Array[Dictionary]:
    members.clear()
    var count := clampi(1 + int(ceil(float(wave) / 2.0)), 2, 4)
    for index in count:
        var role: StringName = ROLES[index]
        members.append({"id": "adventurer_%d" % index, "role": role, "cooldown": 0.0, "separated": false})
    return members.duplicate(true)

func tick(delta: float) -> void:
    for member in members:
        member.cooldown = maxf(float(member.cooldown) - delta, 0.0)

func use_ability(role: StringName, context: Dictionary) -> Dictionary:
    for member in members:
        if member.role != role:
            continue
        if float(member.cooldown) > 0.0:
            return {"ok": false, "reason": "cooldown"}
        member.cooldown = float(COOLDOWNS.get(role, 4.0))
        match role:
            &"healer": return {"ok": true, "heal": mini(20, int(context.get("missing_health", 0)))}
            &"tank": return {"ok": true, "protection": 0.4, "duration": 2.0}
            &"disarmer": return {"ok": true, "disable_trap": bool(context.get("trap_present", false))}
            &"scout": return {"ok": true, "reveal_radius": 4}
            _: return {"ok": true, "range": 3, "damage": 12}
    return {"ok": false, "reason": "role_missing"}

func formation(corridor_width: int) -> StringName:
    return &"column" if corridor_width <= 1 else &"screen"

func regroup_distance() -> int:
    return 3
