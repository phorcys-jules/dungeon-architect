class_name VillageQuestRuntime
extends RefCounted

const CHAINS := {
    &"blacksmith": [
        {"id": "forge_sparks", "metric": "combos", "target": 6, "reward": {"stone": 20}},
        {"id": "tested_edges", "metric": "trap_captures", "target": 12, "reward": {"unlock": "runic_blade"}},
        {"id": "boss_breaker", "metric": "bosses", "target": 1, "reward": {"blueprint_slot": 1}},
    ],
    &"archivist": [
        {"id": "first_records", "metric": "discoveries", "target": 8, "reward": {"essence": 15}},
        {"id": "room_studies", "metric": "room_rules", "target": 10, "reward": {"codex_hints": 1}},
        {"id": "living_history", "metric": "rival_encounters", "target": 3, "reward": {"unlock": "nemesis_archive"}},
    ],
    &"merchant": [
        {"id": "trade_route", "metric": "campaign_nodes", "target": 5, "reward": {"gold": 30}},
        {"id": "rare_goods", "metric": "elite_victories", "target": 2, "reward": {"market_slots": 1}},
        {"id": "three_factions", "metric": "factions_met", "target": 3, "reward": {"discount": 0.1}},
    ],
    &"den_keeper": [
        {"id": "pack_tactics", "metric": "monster_captures", "target": 10, "reward": {"bones": 20}},
        {"id": "new_forms", "metric": "evolutions", "target": 2, "reward": {"mutation_chance": 0.05}},
        {"id": "perfect_lair", "metric": "perfect_runs", "target": 1, "reward": {"team_capacity": 1}},
    ],
}

var progress: Dictionary = {}
var completed: Array[String] = []
var choices: Dictionary = {}

func record(metric: String, amount := 1) -> Array[Dictionary]:
    progress[metric] = int(progress.get(metric, 0)) + amount
    var rewards: Array[Dictionary] = []
    for resident in CHAINS:
        var quest := current_quest(resident)
        if not quest.is_empty() and String(quest.metric) == metric and int(progress[metric]) >= int(quest.target):
            completed.append(String(quest.id))
            rewards.append({"resident": resident, "quest": quest.id, "reward": Dictionary(quest.reward).duplicate(true)})
    return rewards

func current_quest(resident: StringName) -> Dictionary:
    for quest in CHAINS.get(resident, []):
        if not completed.has(String(quest.id)):
            var result: Dictionary = quest.duplicate(true)
            result["current"] = int(progress.get(String(quest.metric), 0))
            return result
    return {}

func choose_outcome(quest_id: String, outcome: String) -> bool:
    if not completed.has(quest_id) or choices.has(quest_id):
        return false
    choices[quest_id] = outcome
    return true

func to_dict() -> Dictionary:
    return {"progress": progress.duplicate(true), "completed": completed.duplicate(), "choices": choices.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    progress = Dictionary(data.get("progress", {})).duplicate(true)
    completed.assign(data.get("completed", []))
    choices = Dictionary(data.get("choices", {})).duplicate(true)
