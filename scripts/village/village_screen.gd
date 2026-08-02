extends "res://scripts/village/village_den_screen.gd"

signal run_requested

const VillageBackground := preload("res://assets/backgrounds/monster_village.png")
const VillageMusic := preload("res://assets/audio/music/village_night.wav")
const VillageAmbientAnimatorScript := preload("res://scripts/village/village_ambient_animator.gd")
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
var music_player: AudioStreamPlayer
var ambient_animator: VillageAmbientAnimator
var monster_roster := MonsterRoster.new()
var roster_buttons: Dictionary = {}
var labyrinth_modules := LabyrinthModuleLoadout.new()
var module_buttons: Dictionary = {}

func _ready() -> void:
    super._ready()
    _load_village_state()
    _build_village_map()
    _build_roster_controls()
    _build_module_controls()
    _start_village_animations()
    _start_village_music()
    start_run_button.pressed.connect(_on_start_run_pressed)
    _select_building("den")
    _refresh_navigation()

func _load_village_state() -> void:
    var state := meta_store.load_state()
    var den := save_store.load_den()
    progression_service = V04ProgressionService.new(state.get("v04_progression", {}))
    black_market.from_dict(state.get("black_market", {}))
    if state.has("monster_roster"):
        monster_roster.from_dict(state.monster_roster)
    else:
        monster_roster.recruited = ["ghost", "slime", "mimic", "spider"]
        monster_roster.selected_team = monster_roster.recruited.duplicate()
    monster_roster.capacity = mini(den.get_capacity(), 4)
    if monster_roster.selected_team.size() > monster_roster.capacity:
        monster_roster.selected_team = monster_roster.selected_team.slice(0, monster_roster.capacity)
    labyrinth_modules.from_dict(state.get("labyrinth_modules", {}), progression_service.state.buildings)
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

func _build_roster_controls() -> void:
    var content := get_node("Panel/Margin/Content") as VBoxContainer
    var heading := Label.new()
    heading.text = "ÉQUIPE DE MONSTRES"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(heading)
    content.move_child(heading, 2)
    var row := HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_theme_constant_override("separation", 4)
    content.add_child(row)
    content.move_child(row, 3)
    var labels := {"ghost": "Fantôme", "slime": "Slime", "mimic": "Mimic", "spider": "Araignée"}
    for monster_id in labels:
        var button := Button.new()
        button.text = labels[monster_id]
        button.toggle_mode = true
        button.custom_minimum_size = Vector2(58, 34)
        button.add_theme_font_size_override("font_size", 10)
        button.tooltip_text = "Ajouter ou retirer %s de l'équipe active." % labels[monster_id]
        button.pressed.connect(_toggle_roster_monster.bind(String(monster_id)))
        row.add_child(button)
        roster_buttons[monster_id] = button
    _refresh_roster_controls()

func _toggle_roster_monster(monster_id: String) -> void:
    var den := save_store.load_den()
    if not monster_roster.recruited.has(monster_id):
        var recruitment := monster_roster.recruit(monster_id, den.soul_shards)
        if not bool(recruitment.ok):
            status_label.text = "Éclats d'âme insuffisants pour recruter ce monstre."
            _refresh_roster_controls()
            return
        den.soul_shards += int(recruitment.gold_delta)
        save_store.save_den(den)
    var team := monster_roster.selected_team.duplicate()
    if team.has(monster_id):
        if team.size() <= 1:
            status_label.text = "L'équipe doit conserver au moins un monstre."
            _refresh_roster_controls()
            return
        team.erase(monster_id)
    else:
        if team.size() >= monster_roster.capacity:
            status_label.text = "L'équipe est complète (%d monstres)." % monster_roster.capacity
            _refresh_roster_controls()
            return
        team.append(monster_id)
    monster_roster.select_team(team)
    _persist_village_state()
    _show_den()

func _refresh_roster_controls() -> void:
    for monster_id in roster_buttons:
        var button := roster_buttons[monster_id] as Button
        button.button_pressed = monster_roster.selected_team.has(String(monster_id))
        button.modulate = Color.WHITE if monster_roster.recruited.has(String(monster_id)) else Color("8b8b9b")

func _build_module_controls() -> void:
    var content := get_node("Panel/Margin/Content") as VBoxContainer
    var heading := Label.new()
    heading.text = "MODULES DU LABYRINTHE — %d/%d" % [labyrinth_modules.complexity_used(), LabyrinthModuleLoadout.MAX_COMPLEXITY]
    heading.name = "LabyrinthModulesHeading"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(heading)
    content.move_child(heading, 4)
    var row := HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_theme_constant_override("separation", 3)
    content.add_child(row)
    content.move_child(row, 5)
    for module_id in LabyrinthModuleLoadout.DEFINITIONS:
        var definition: Dictionary = LabyrinthModuleLoadout.DEFINITIONS[module_id]
        var button := Button.new()
        button.text = String(definition.name)
        button.toggle_mode = true
        button.custom_minimum_size = Vector2(56, 30)
        button.add_theme_font_size_override("font_size", 9)
        button.tooltip_text = "%s — complexité %d" % [String(definition.name), int(definition.cost)]
        button.pressed.connect(_toggle_labyrinth_module.bind(String(module_id)))
        row.add_child(button)
        module_buttons[module_id] = button
    _refresh_module_controls()

func _toggle_labyrinth_module(module_id: String) -> void:
    var selection: Array[String] = labyrinth_modules.selected.duplicate()
    if selection.has(module_id):
        selection.erase(module_id)
    else:
        selection.append(module_id)
    var result := labyrinth_modules.select(selection, progression_service.state.buildings)
    if not bool(result.ok):
        status_label.text = "Module refusé : déblocage requis, sélection vide ou budget de complexité dépassé."
    else:
        _persist_village_state()
        status_label.text = "Modules actifs : %s (%d/%d)." % [", ".join(labyrinth_modules.selected), labyrinth_modules.complexity_used(), LabyrinthModuleLoadout.MAX_COMPLEXITY]
    _refresh_module_controls()

func _refresh_module_controls() -> void:
    var unlocked := labyrinth_modules.unlocked_ids(progression_service.state.buildings)
    for module_id in module_buttons:
        var button := module_buttons[module_id] as Button
        button.button_pressed = labyrinth_modules.selected.has(String(module_id))
        button.disabled = not unlocked.has(String(module_id))
    var heading := get_node_or_null("Panel/Margin/Content/LabyrinthModulesHeading") as Label
    if heading != null:
        heading.text = "MODULES DU LABYRINTHE — %d/%d" % [labyrinth_modules.complexity_used(), LabyrinthModuleLoadout.MAX_COMPLEXITY]

func _start_village_music() -> void:
    music_player = AudioStreamPlayer.new()
    music_player.name = "VillageAmbience"
    var looped_stream := VillageMusic.duplicate() as AudioStreamWAV
    looped_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    music_player.stream = looped_stream
    music_player.volume_db = -36.0
    add_child(music_player)
    music_player.play()
    create_tween().tween_property(music_player, "volume_db", -19.0, 1.8)

func _start_village_animations() -> void:
    ambient_animator = VillageAmbientAnimatorScript.new()
    ambient_animator.name = "VillageAmbientAnimations"
    ambient_animator.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(ambient_animator)
    move_child(ambient_animator, 1)

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
    status_label.text = "Équipe : %s (%d/%d)\nDéfenseurs en run : %d\n%s : %s\n\nEffet : équipe jusqu'à 4 monstres, puis +2 défenseurs par niveau." % [", ".join(monster_roster.selected_team), monster_roster.selected_team.size(), monster_roster.capacity, den.get_capacity(), VillageCurrency.DISPLAY_NAME, den.currency.formatted()]
    upgrade_button.text = "Améliorer (%s)" % den.currency.formatted(den.get_upgrade_cost()) if den.level < DenProgression.MAX_LEVEL else "Niveau maximum"
    upgrade_button.disabled = not den.can_upgrade()
    _refresh_roster_controls()

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
    match building_id:
        "forge": status_label.text += "\nRenforce les dégâts et ouvre un piège par niveau."
        "laboratory": status_label.text += "\nProlonge poix, givre, flaques et toiles ; accélère les défenseurs."
        "graveyard": status_label.text += "\nRéduit le temps de retour des monstres neutralisés."
    if building_id == "forge":
        var unlocked := TrapCatalog.unlocked_for_forge_level(level)
        var names: Array[String] = []
        for trap_id in unlocked:
            names.append(String(TrapCatalog.definition(trap_id).name))
        status_label.text += "\n\nPièges débloqués : %s" % ", ".join(names)
        var next := TrapCatalog.next_unlock(level)
        if not next.is_empty():
            status_label.text += "\nNiveau %d : %s" % [int(next.level), String(next.name)]
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
    status_label.text = "%s\nRareté : %s\nEffet : %s\nContrepartie : %s\n\n%s : %s" % [
        String(offer.name),
        String(offer.rarity).capitalize(),
        _market_effect_description(String(offer.id)),
        _curse_effect_description(String(offer.curse.id)),
        VillageCurrency.DISPLAY_NAME,
        den.currency.formatted(),
    ]
    upgrade_button.text = "Acheter (%s)" % den.currency.formatted(int(offer.price))
    upgrade_button.disabled = not den.currency.can_afford(int(offer.price))

func _on_upgrade_pressed() -> void:
    var den := save_store.load_den()
    if selected_building == "den":
        if den.upgrade():
            save_store.save_den(den)
            monster_roster.capacity = mini(den.get_capacity(), 4)
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
    _refresh_module_controls()
    _select_building(selected_building)

func _persist_village_state() -> void:
    var state := meta_store.load_state()
    state["v04_progression"] = progression_service.state.duplicate(true)
    state["black_market"] = black_market.to_dict()
    state["monster_roster"] = monster_roster.to_dict()
    state["labyrinth_modules"] = labyrinth_modules.to_dict()
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

func _market_effect_description(offer_id: String) -> String:
    match offer_id:
        "wraith_recruit": return "+25 % de santé aux monstres"
        "mimic_room": return "+15 % de dégâts aux monstres"
        "void_crown": return "+25 % de dégâts aux monstres"
        "bone_foundry": return "+25 % de dégâts aux pièges"
        "blood_contract": return "+30 % de dégâts aux défenseurs"
        _: return "pouvoir inconnu"

func _curse_effect_description(curse_id: String) -> String:
    match curse_id:
        "fragile_walls": return "−10 or initial"
        "greedy_chest": return "+10 % de vitesse aux aventuriers"
        "elite_hunters": return "+12 % de santé aux aventuriers"
        "taxed_essence": return "−15 or initial"
        "monster_upkeep": return "−10 or initial"
        _: return curse_id.replace("_", " ")

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
    if music_player and music_player.playing:
        var fade := create_tween()
        fade.tween_property(music_player, "volume_db", -40.0, 0.45)
        await fade.finished
    run_requested.emit()
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _refresh_navigation() -> void:
    if start_run_button:
        start_run_button.disabled = transition_in_progress
