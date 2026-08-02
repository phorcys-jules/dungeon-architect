extends "res://scripts/dungeon_invasion_controller.gd"

const RunEndControllerScript := preload("res://scripts/core/run_end_controller.gd")

var run_end: RunEndController = RunEndControllerScript.new()
var village_button: Button
var restart_button: Button
var current_run_id := ""
var captures_this_run := 0
var relics_protected_this_run := 0

func _ready() -> void:
    super._ready()
    run_end.go_to_village.connect(_open_village)
    run_end.restart_run.connect(_restart_from_results)
    _build_run_end_actions()
    _begin_tracked_run()

func _build_run_end_actions() -> void:
    village_button = Button.new()
    village_button.text = "Village"
    village_button.position = Vector2(30, 202)
    village_button.size = Vector2(175, 36)
    village_button.visible = false
    village_button.pressed.connect(run_end.request_village)
    result_panel.add_child(village_button)

    restart_button = Button.new()
    restart_button.text = "Nouvelle run"
    restart_button.position = Vector2(235, 202)
    restart_button.size = Vector2(175, 36)
    restart_button.visible = false
    restart_button.pressed.connect(run_end.request_restart)
    result_panel.add_child(restart_button)

func _begin_tracked_run() -> void:
    current_run_id = "%d-%d" % [Time.get_unix_time_from_system(), Time.get_ticks_msec()]
    captures_this_run = 0
    relics_protected_this_run = 0
    run_end.begin_run(current_run_id)
    _set_run_end_actions_visible(false)

func _on_adventurer_died() -> void:
    var was_invasion := game_state == GameState.INVASION
    super._on_adventurer_died()
    if was_invasion:
        captures_this_run += 1

func _finish_campaign(victory: bool, message: String) -> void:
    if game_state == GameState.CAMPAIGN_FINISHED:
        return
    relics_protected_this_run = collectible_route.get_remaining_count()
    super._finish_campaign(victory, message)
    var completed_waves := waves.current_wave if victory else maxi(waves.current_wave - 1, 0)
    var reward := run_end.finish(completed_waves, captures_this_run, relics_protected_this_run, victory)
    result_summary.text += "\n\n" + run_end.reward_service.calculator.summary(reward)
    _set_run_end_actions_visible(true)

func _start_new_campaign() -> void:
    super._start_new_campaign()
    _begin_tracked_run()

func _set_run_end_actions_visible(value: bool) -> void:
    if village_button:
        village_button.visible = value
    if restart_button:
        restart_button.visible = value

func _open_village() -> void:
    get_tree().change_scene_to_file("res://scenes/village_screen.tscn")

func _restart_from_results() -> void:
    _start_new_campaign()
