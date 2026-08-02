class_name RunHudViewModel
extends RefCounted

func build(snapshot: Dictionary) -> Dictionary:
    var current_health := maxf(float(snapshot.get("current_health", 0.0)), 0.0)
    var max_health := maxf(float(snapshot.get("max_health", 1.0)), 1.0)
    var wave := maxi(int(snapshot.get("wave", 1)), 1)
    var total_waves := maxi(int(snapshot.get("total_waves", wave)), wave)
    var treasure_state := String(snapshot.get("treasure_state", "locked"))
    var active_synergies: Array = snapshot.get("active_synergies", [])
    var status_effects: Array = snapshot.get("status_effects", [])

    return {
        "health_ratio": clampf(current_health / max_health, 0.0, 1.0),
        "health_text": "%d / %d" % [roundi(current_health), roundi(max_health)],
        "wave_text": "Vague %d / %d" % [wave, total_waves],
        "difficulty_text": String(snapshot.get("difficulty", "Normal")),
        "treasure_text": _treasure_label(treasure_state),
        "synergy_text": _join_labels(active_synergies, "Aucune synergie"),
        "status_text": _join_labels(status_effects, "Aucun effet"),
        "gold": maxi(int(snapshot.get("gold", 0)), 0),
        "essence": maxi(int(snapshot.get("essence", 0)), 0),
    }

func _treasure_label(state: String) -> String:
    match state:
        "channeling": return "Trésor : pillage en cours"
        "stolen": return "Trésor : volé"
        "recovered": return "Trésor : récupéré"
        "opened": return "Trésor : ouvert"
        _: return "Trésor : protégé"

func _join_labels(values: Array, empty_label: String) -> String:
    if values.is_empty():
        return empty_label
    var labels: PackedStringArray = []
    for value in values:
        labels.append(String(value))
    return ", ".join(labels)
