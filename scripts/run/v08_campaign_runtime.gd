class_name V08CampaignRuntime
extends RefCounted

var world_map := RogueliteWorldMap.new()
var boss_service := BossMapService.new()
var nemesis := NemesisRuntime.new()
var environment := EnvironmentFlowRuntime.new()
var blueprints := BlueprintRuntime.new()
var quests := VillageQuestRuntime.new()
var accessibility := AccessibilityProfile.new()
var daily := DailyChallengeRuntime.new()
var active_node: Dictionary = {}
var campaign_complete := false
var daily_active := false

func start(seed_value: int) -> void:
    world_map.generate(seed_value, 9, 3)
    boss_service.prepare_for_map(world_map)
    active_node.clear()
    campaign_complete = false
    daily_active = false

func start_daily(date_iso: String, version: String) -> Dictionary:
    var challenge := daily.definition(date_iso, version)
    start(int(challenge.seed))
    daily_active = true
    return challenge

func ensure_started(seed_value: int) -> void:
    if world_map.columns.is_empty():
        start(seed_value)

func available_routes() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for node in world_map.available_nodes():
        result.append(world_map.route_preview(String(node.id)))
    return result

func choose_route(node_id: String) -> Dictionary:
    if not world_map.choose(node_id):
        return {"ok": false, "reason": "route_unavailable"}
    active_node = world_map.find_node(node_id).duplicate(true)
    quests.record("campaign_nodes")
    return {"ok": true, "node": active_node, "faction": world_map.faction_definition(StringName(active_node.faction))}

func run_tags() -> Array[String]:
    if active_node.is_empty():
        return []
    return ["faction:%s" % String(active_node.faction), "biome:%s" % String(active_node.biome), "act:%d" % int(active_node.act)]

func finish_node(result: Dictionary) -> Dictionary:
    var rewards: Array[Dictionary] = []
    if daily_active:
        campaign_complete = world_map.is_complete() and bool(result.get("victory", false))
        active_node.clear()
        return {"campaign_complete": campaign_complete, "quest_rewards": [], "routes": available_routes(), "daily": true, "persistent_rewards": false}
    if bool(result.get("victory", false)):
        var type := int(active_node.get("type", RogueliteWorldMap.NodeType.COMBAT))
        if type == RogueliteWorldMap.NodeType.ELITE:
            rewards.append_array(quests.record("elite_victories"))
        if type == RogueliteWorldMap.NodeType.BOSS:
            rewards.append_array(quests.record("bosses"))
        if not active_node.is_empty():
            rewards.append_array(quests.record("factions_met", 1))
    elif bool(result.get("stole_treasure", false)):
        var adventurer_id := String(result.get("adventurer_id", "rival_%d" % world_map.seed))
        nemesis.promote(adventurer_id, String(result.get("adventurer_name", "Rival inconnu")), result)
    campaign_complete = world_map.is_complete() and bool(result.get("victory", false))
    active_node.clear()
    return {"campaign_complete": campaign_complete, "quest_rewards": rewards, "routes": available_routes()}

func daily_definition(date_iso: String, version: String) -> Dictionary:
    return daily.definition(date_iso, version)

func to_dict() -> Dictionary:
    return {"world_map": world_map.to_dict(), "nemesis": nemesis.to_dict(), "blueprints": blueprints.to_dict(), "village_quests": quests.to_dict(), "accessibility": accessibility.serialize(), "active_node": active_node.duplicate(true), "campaign_complete": campaign_complete, "daily_active": daily_active}

func from_dict(data: Dictionary) -> void:
    world_map.from_dict(data.get("world_map", {}))
    nemesis.from_dict(data.get("nemesis", {}))
    blueprints.from_dict(data.get("blueprints", {}))
    quests.from_dict(data.get("village_quests", {}))
    accessibility.apply(data.get("accessibility", {}))
    active_node = Dictionary(data.get("active_node", {})).duplicate(true)
    campaign_complete = bool(data.get("campaign_complete", false))
    daily_active = bool(data.get("daily_active", false))
