class_name RunEndController
extends RefCounted

signal go_to_village
signal restart_run

var reward_service := RunRewardService.new()
var current_run_id := ""
var last_reward: Dictionary = {}
var claimed := false

func _init(service: RunRewardService = null) -> void:
    if service != null:
        reward_service = service

func begin_run(run_id: String) -> void:
    current_run_id = run_id
    last_reward.clear()
    claimed = false

func finish(waves_completed: int, captures: int, relics_protected: int, victory: bool) -> Dictionary:
    if claimed:
        return last_reward
    last_reward = reward_service.claim(current_run_id, waves_completed, captures, relics_protected, victory)
    claimed = bool(last_reward.get("claimed", false))
    return last_reward

func request_village() -> void:
    go_to_village.emit()

func request_restart() -> void:
    restart_run.emit()
