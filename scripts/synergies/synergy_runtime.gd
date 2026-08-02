class_name SynergyRuntime
extends RefCounted

var catalog := SynergyCatalog.new()
var active: Array[Dictionary] = []
var discovered: Array[String] = []

func evaluate(tags: Array[String]) -> Array[Dictionary]:
    active.clear()
    for entry in catalog.all():
        var matches := true
        for required_tag in entry.requires:
            if not tags.has(String(required_tag)):
                matches = false
                break
        if matches:
            active.append(entry)
            var id := String(entry.id)
            if not discovered.has(id):
                discovered.append(id)
    return active.duplicate(true)

func combined_effects() -> Dictionary:
    var result := {}
    for entry in active:
        for key in entry.effect.keys():
            var value = entry.effect[key]
            result[key] = result.get(key, 0.0) + value
    return result

func presentation() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for entry in active:
        result.append({
            "id": entry.id,
            "name": entry.name,
            "description": String(entry.get("description", "Synergie active pendant cette run.")),
            "effect": entry.effect.duplicate(true),
        })
    return result

func to_dict() -> Dictionary:
    return {"discovered":discovered.duplicate()}

func from_dict(data: Dictionary) -> void:
    discovered.assign(data.get("discovered", []))
