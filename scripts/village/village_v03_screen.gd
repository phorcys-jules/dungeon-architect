extends "res://scripts/village/village_den_screen.gd"

signal run_requested

@onready var start_run_button: Button = %StartRunButton
var transition_in_progress := false

func _ready() -> void:
    super._ready()
    start_run_button.pressed.connect(_on_start_run_pressed)
    _refresh_navigation()

func _on_start_run_pressed() -> void:
    if transition_in_progress:
        return
    transition_in_progress = true
    _refresh_navigation()
    run_requested.emit()
    get_tree().change_scene_to_file("res://scenes/main_v03.tscn")

func _refresh_navigation() -> void:
    if start_run_button:
        start_run_button.disabled = transition_in_progress
