extends "res://scripts/village/village_den_screen.gd"

signal run_requested

const VillageBackground := preload("res://assets/backgrounds/monster_village.png")
const BUILDING_TEXTURES := {
    "den": preload("res://assets/sprites/buildings/den.png"),
    "forge": preload("res://assets/sprites/buildings/forge.png"),
    "laboratory": preload("res://assets/sprites/buildings/laboratory.png"),
    "graveyard": preload("res://assets/sprites/buildings/graveyard.png"),
    "market": preload("res://assets/sprites/buildings/black_market.png"),
}

const BUILDING_LAYOUT := {
    "den": {"label": "TANIÈRE", "subtitle": "Repaire des monstres", "position": Vector2(65, 125), "color": Color("6b4a8f")},
    "forge": {"label": "FORGE", "subtitle": "Pièges renforcés", "position": Vector2(370, 72), "color": Color("a95832")},
    "laboratory": {"label": "LABORATOIRE", "subtitle": "Effets prolongés", "position": Vector2(470, 235), "color": Color("467b82")},
    "graveyard": {"label": "CIMETIÈRE", "subtitle": "Retour des monstres", "position": Vector2(65, 390), "color": Color("58606f")},
    "market": {"label": "MARCHÉ NOIR", "subtitle": "Pouvoir contre malédiction", "position": Vector2(365, 430), "color": Color("7f315f")},
}

@onready var start_run_button: Button = %StartRunButton

var transition_in_progress := false
var black_market := VillageBlackMarket.new()
var meta_store := V06ProgressionStore.new()
var progression_service := V04ProgressionService.new()
var selected_building := "den"
var building_buttons: Dictionary = {}

func _ready() -> void:
    super._ready()
    _load_village_state()
    _build_village_map()
    start_run_button.pressed.connect(_on_start_run_pressed)
    _select_building("den")
    _refresh_navigation()

func _load_village_state() -> void:
    var state := meta_store.load_state()
    progression_service = V04ProgressionService.new(state.get("v04_progression", {}))
    black_market.from_dict(state.get("black_market", {}))
    if black_market.stock.is_empty():
        black_market.refresh(int(Time.get_unix_time_from_system()))

func _build_village_map() -> void:
    var background := TextureRect.new()
    background.name = "VillageBackground"
    background.texture = VillageBackground
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    move_child(background, 0)

    var panel := get_node("Panel") as PanelContainer
    panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
    panel.offset_left = -305.0
    panel.offset_top = -270.0
    panel.offset_right = -20.0
    panel.offset_bottom = 270.0
    panel.modulate = Color(1, 1, 1, 0.96)

    for building_id in BUILDING_LAYOUT:
        var definition: Dictionary = BUILDING_LAYOUT[building_id]
        var button := Button.new()
        button.name = "%sBuilding" % String(building_id).capitalize()
        button.position = definition.position
        button.size = Vector2(180, 125)
        button.toggle_mode = true
        button.tooltip_text = String(definition.subtitle)
        button.add_theme_stylebox_override("normal", _building_style(definition.color, 0.10))
        button.add_theme_stylebox_override("hover", _building_style(definition.color.lightened(0.18), 0.42))
        button.add_theme_stylebox_override("pressed", _building_style(definition.color.darkened(0.18), 0.58))
        button.pressed.connect(func(): _select_building(String(building_id)))
        var artwork := TextureRect.new()
        artwork.name = "Artwork"
        artwork.texture = BUILDING_TEXTURES[building_id]
        artwork.position = Vector2(10, 0)
        artwork.size = Vector2(160, 112)
        artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.add_child(artwork)
        var label := Label.new()
        label.name = "BuildingName"
        label.text = String(definition.label)
        label.position = Vector2(0, 96)
        label.size = Vector2(180, 27)
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.add_theme_font_size_override("font_size", 14)
        label.add_theme_color_override("font_color", Color("f8e3a1"))
        label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
        label.add_theme_constant_override("shadow_offset_x", 2)
        label.add_theme_constant_override("shadow_offset_y", 2)
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.add_child(label)
        add_child(button)
        building_buttons[building_id] = button

func _building_style(color: Color, alpha: float) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(color, alpha)
    style.border_color = Color("e8c878")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.shadow_color = Color(0, 0, 0, 0.65)
    style.shadow_size = 5
    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    return style

func _select_building(building_id: String) -> void:
    selected_building = building_id
    for id in building_buttons:
        (building_buttons[id] as Button).button_pressed = String(id) == building_id
    match building_id:
        "den":
            _show_den()
        "market":
            _show_market()
        _:
            _show_progression_building(building_id)

func _show_den() -> void:
    var den := save_store.load_den()
    title_label.text = "Tanière — niveau %d/%d" % [den.level, DenProgression.MAX_LEVEL]
    status_label.text = "Capacité : %d monstres\n%s : %s\n\nEffet : +2 places par niveau." % [den.get_capacity(), VillageCurrency.DISPLAY_NAME, den.currency.formatted()]
    upgrade_button.text = "Améliorer (%s)" % den.currency.formatted(den.get_upgrade_cost()) if den.level < DenProgression.MAX_LEVEL else "Niveau maximum"
    upgrade_button.disabled = not den.can_upgrade()

func _show_progression_building(building_id: String) -> void:
    var building := _building_data(building_id)
    if building == null:
        return
    var levels: Dictionary = progression_service.state.buildings
    var level := int(levels.get(building_id, 0))
    var den := save_store.load_den()
    var effect_value := building.bonus_per_level * level
    title_label.text = "%s — niveau %d/%d" % [building.display_name, level, building.max_level]
    status_label.text = "%s : %s\n\nEffet actuel : %s %+d%%\nProchain niveau : %+d%%" % [
        VillageCurrency.DISPLAY_NAME,
        den.currency.formatted(),
        _effect_label(String(building.bonus_key)),
        roundi(effect_value * 100.0),
        roundi(building.bonus_per_level * 100.0),
    ]
    if level >= building.max_level:
        upgrade_button.text = "Niveau maximum"
        upgrade_button.disabled = true
    else:
        var cost := building.cost_for_level(level + 1)
        upgrade_button.text = "Améliorer (%s)" % den.currency.formatted(cost)
        upgrade_button.disabled = not den.currency.can_afford(cost)

func _show_market() -> void:
    var offer := _first_available_offer()
    var den := save_store.load_den()
    title_label.text = "Marché noir"
    if offer.is_empty():
        status_label.text = "Le marchand a épuisé son stock."
        upgrade_button.text = "Stock épuisé"
        upgrade_button.disabled = true
        return
    status_label.text = "%s\nRareté : %s\n\nMalédiction : %s\n%s : %s" % [String(offer.name), String(offer.rarity).capitalize(), String(offer.curse.id), VillageCurrency.DISPLAY_NAME, den.currency.formatted()]
    upgrade_button.text = "Acheter (%s)" % den.currency.formatted(int(offer.price))
    upgrade_button.disabled = not den.currency.can_afford(int(offer.price))

func _on_upgrade_pressed() -> void:
    var den := save_store.load_den()
    if selected_building == "den":
        if den.upgrade():
            save_store.save_den(den)
            upgrade_requested.emit()
    elif selected_building == "market":
        var offer := _first_available_offer()
        var purchase := black_market.buy(String(offer.get("id", "")), den.soul_shards)
        if bool(purchase.get("ok", false)):
            den.soul_shards += int(purchase.gold_delta)
            save_store.save_den(den)
    else:
        var purchase := progression_service.buy_building_level(StringName(selected_building), den.soul_shards)
        if bool(purchase.get("success", false)):
            den.soul_shards = int(purchase.remaining)
            save_store.save_den(den)
    _persist_village_state()
    _select_building(selected_building)

func _persist_village_state() -> void:
    var state := meta_store.load_state()
    state["v04_progression"] = progression_service.state.duplicate(true)
    state["black_market"] = black_market.to_dict()
    meta_store.save_state(state)

func _building_data(building_id: String) -> VillageBuildingData:
    for building: VillageBuildingData in progression_service.catalog.buildings():
        if String(building.building_id) == building_id:
            return building
    return null

func _effect_label(key: String) -> String:
    match key:
        "trap_damage_multiplier": return "dégâts des pièges"
        "effect_duration_multiplier": return "durée des effets"
        "monster_respawn_speed_multiplier": return "vitesse de retour des monstres"
        _:
            return key.replace("_", " ")

func _first_available_offer() -> Dictionary:
    for offer in black_market.stock:
        if not bool(offer.get("sold", false)):
            return offer
    return {}

func _on_start_run_pressed() -> void:
    if transition_in_progress:
        return
    transition_in_progress = true
    _refresh_navigation()
    run_requested.emit()
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _refresh_navigation() -> void:
    if start_run_button:
        start_run_button.disabled = transition_in_progress
