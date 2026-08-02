extends SceneTree

const StoreScript := preload("res://scripts/village/village_save_store.gd")
const ServiceScript := preload("res://scripts/core/run_reward_service.gd")

func _init() -> void:
    var path := "user://run_reward_service_test.json"
    var store: VillageSaveStore = StoreScript.new(path)
    store.delete_save()
    var service: RunRewardService = ServiceScript.new(store)
    var reward := service.claim("run-1", 3, 2, 4, true)
    if not bool(reward.get("claimed", false)) or int(reward.get("total", 0)) != 126:
        quit(1)
        return
    assert(String(reward.currency_id) == VillageCurrency.ID)
    assert(String(reward.currency_name) == VillageCurrency.DISPLAY_NAME)
    var den := store.load_den()
    if den.soul_shards != 126:
        quit(1)
        return
    var duplicate := service.claim("run-1", 3, 2, 4, true)
    if bool(duplicate.get("claimed", true)) or store.load_den().soul_shards != 126:
        quit(1)
        return
    store.delete_save()
    print("Run reward service test passed")
    quit(0)
