extends SceneTree

const StoreScript := preload("res://scripts/village/village_save_store.gd")
const ServiceScript := preload("res://scripts/core/run_reward_service.gd")
const ControllerScript := preload("res://scripts/core/run_end_controller.gd")

func _init() -> void:
    var path := "user://run_end_controller_test.json"
    var store: VillageSaveStore = StoreScript.new(path)
    store.delete_save()
    var service: RunRewardService = ServiceScript.new(store)
    var controller: RunEndController = ControllerScript.new(service)
    controller.begin_run("run-end-1")
    var reward := controller.finish(2, 1, 3, false)
    if int(reward.get("total", 0)) != 60:
        quit(1)
        return
    var duplicate := controller.finish(2, 1, 3, false)
    if int(duplicate.get("total", 0)) != 60 or store.load_den().soul_shards != 60:
        quit(1)
        return
    controller.begin_run("run-end-2")
    var second := controller.finish(1, 0, 0, false)
    if int(second.get("total", 0)) != 12 or store.load_den().soul_shards != 72:
        quit(1)
        return
    store.delete_save()
    print("Run end controller test passed")
    quit(0)
