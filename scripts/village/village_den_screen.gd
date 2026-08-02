extends Control

signal upgrade_requested
signal run_requested

@onready var title_label: Label = %TitleLabel
@onready var status_label: Label = %StatusLabel
@onready var upgrade_button: Button = %UpgradeButton
@onready var start_run_button: Button = %StartRunButton

var save_store := VillageSaveStore.new()
var view_model := DenViewModel.new()
var transition_in_progress := false

func _ready() -> void:
    view_model = DenViewModel.new(save_store.load_den())
    upgrade_button.pressed.connect(_on_upgrade_pressed)
    start_run_button.pressed.connect(_on_start_run_pressed)
    refresh()

func set_progression(den: DenProgression) -> void:
    view_model = DenViewModel.new(den)
    if is_node_ready():
        refresh()

func set_save_store(store: VillageSaveStore) -> void:
    if store != null:
        save_store = store

func refresh() -> void:
    title_label.text = view_model.get_title()
    status_label.text = view_model.get_status()
    upgrade_button.text = view_model.get_upgrade_label()
    upgrade_button.disabled = not view_model.can_upgrade()
    start_run_button.disabled = transition_in_progress

func _on_upgrade_pressed() -> void:
    if view_model.upgrade():
        save_store.save_den(view_model.den)
        refresh()
        upgrade_requested.emit()

func _on_start_run_pressed() -> void:
    if transition_in_progress:
        return
    transition_in_progress = true
    refresh()
    run_requested.emit()
    get_tree().change_scene_to_file("res://scenes/main.tscn")
