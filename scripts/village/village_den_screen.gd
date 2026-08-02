extends Control

signal upgrade_requested

@onready var title_label: Label = %TitleLabel
@onready var status_label: Label = %StatusLabel
@onready var upgrade_button: Button = %UpgradeButton

var view_model := DenViewModel.new()

func _ready() -> void:
    upgrade_button.pressed.connect(_on_upgrade_pressed)
    refresh()

func set_progression(den: DenProgression) -> void:
    view_model = DenViewModel.new(den)
    if is_node_ready():
        refresh()

func refresh() -> void:
    title_label.text = view_model.get_title()
    status_label.text = view_model.get_status()
    upgrade_button.text = view_model.get_upgrade_label()
    upgrade_button.disabled = not view_model.can_upgrade()

func _on_upgrade_pressed() -> void:
    if view_model.upgrade():
        refresh()
        upgrade_requested.emit()
