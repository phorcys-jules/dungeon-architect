class_name RunRewardService
extends RefCounted

var calculator := RunRewardCalculator.new()
var save_store := VillageSaveStore.new()
var claimed_run_ids: Dictionary = {}

func _init(store: VillageSaveStore = null) -> void:
    if store != null:
        save_store = store

func claim(run_id: String, waves_completed: int, captures: int, relics_protected: int, victory: bool) -> Dictionary:
    if run_id.is_empty() or claimed_run_ids.has(run_id):
        return {"claimed": false, "total": 0}
    var reward := calculator.calculate(waves_completed, captures, relics_protected, victory)
    var den := save_store.load_den()
    den.add_resources(int(reward.get("total", 0)))
    if not save_store.save_den(den):
        return {"claimed": false, "total": 0}
    claimed_run_ids[run_id] = true
    reward["claimed"] = true
    return reward
