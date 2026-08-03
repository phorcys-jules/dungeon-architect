extends "res://scripts/village/village_den_screen.gd"

signal run_requested

const VillageBackground := preload("res://assets/backgrounds/monster_village.png")
const VillageMusic := preload("res://assets/audio/music/village_night.wav")
const VillageAmbientAnimatorScript := preload("res://scripts/village/village_ambient_animator.gd")
const MONSTER_TEXTURES := {
    "ghost": preload("res://assets/sprites/characters/animations/monster_ghost_walk.png"),
    "slime": preload("res://assets/sprites/characters/animations/monster_slime_walk.png"),
    "mimic": preload("res://assets/sprites/characters/animations/monster_mimic_walk.png"),
    "spider": preload("res://assets/sprites/characters/animations/monster_spider_walk.png"),
}
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
var room_deck_selection := RoomDeckSelection.new()
var biome_selector: OptionButton
var room_selector: OptionButton
var room_deck_label: Label
var encyclopedia := EncyclopediaProgress.new()
var encyclopedia_catalog := EncyclopediaCatalog.new()
var global_stats := GlobalRunStats.new()
var achievements := AchievementTracker.new()
var archives_button: Button
var archives_panel: PanelContainer
var archives_category: OptionButton
var archives_text: RichTextLabel
var archives_stats: Label
var last_run_result: Dictionary = {}
var village_residents: Array[Control] = []
var reaction_label: Label
var feedback_settings := GameFeedbackSettings.new()
var feedback_button: Button
var feedback_panel: PanelContainer

func _ready() -> void:
    super._ready()
    _load_village_state()
    _build_village_map()
    _build_village_residents()
    _build_roster_controls()
    _build_module_controls()
    _build_room_deck_controls()
    _build_archives()
    _build_feedback_settings()
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
    room_deck_selection.from_dict(state.get("room_deck_selection", {}))
    encyclopedia.from_dict(state.get("encyclopedia", {}))
    global_stats.from_dict(state.get("global_stats", {}))
    achievements.from_dict(state.get("achievements", {}))
    last_run_result = Dictionary(state.get("last_run_result", {})).duplicate(true)
    feedback_settings.apply(state.get("feedback_settings", {}))
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
    (get_node("Panel/Margin/Content") as VBoxContainer).add_theme_constant_override("separation", 8)
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
    _refresh_building_progression_visuals()

func _refresh_building_progression_visuals() -> void:
    var den := save_store.load_den()
    for building_id in building_buttons:
        var button := building_buttons[building_id] as Button
        var level := den.level if building_id == "den" else int(progression_service.state.buildings.get(building_id, 0))
        if building_id == "market":
            level = black_market.purchased_ids.size()
        var badge := button.get_node_or_null("ProgressBadge") as Label
        if badge == null:
            badge = Label.new()
            badge.name = "ProgressBadge"
            button.add_child(badge)
        badge.text = "NIV. %d" % level if building_id != "market" else "%d PACTE(S)" % level
        badge.position = Vector2(8, 7)
        badge.size = Vector2(92, 20)
        badge.add_theme_font_size_override("font_size", 10)
        badge.add_theme_color_override("font_color", Color("fff0a8"))
        badge.add_theme_color_override("font_shadow_color", Color.BLACK)
        badge.add_theme_constant_override("shadow_offset_x", 1)
        badge.add_theme_constant_override("shadow_offset_y", 1)
        badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var artwork := button.get_node("Artwork") as TextureRect
        artwork.modulate = Color.WHITE.lerp(Color("ffd782"), minf(float(level) * 0.08, 0.32))
        artwork.scale = Vector2.ONE * (1.0 + minf(float(level) * 0.012, 0.06))

func _build_village_residents() -> void:
    reaction_label = Label.new()
    reaction_label.name = "VillageReaction"
    reaction_label.position = Vector2(220, 18)
    reaction_label.size = Vector2(410, 42)
    reaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    reaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    reaction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    reaction_label.add_theme_font_size_override("font_size", 13)
    reaction_label.add_theme_color_override("font_color", Color("fff0b5"))
    reaction_label.add_theme_color_override("font_shadow_color", Color.BLACK)
    reaction_label.add_theme_constant_override("shadow_offset_x", 2)
    reaction_label.add_theme_constant_override("shadow_offset_y", 2)
    reaction_label.text = _village_reaction_text()
    add_child(reaction_label)

    var monster_positions := [Vector2(52, 285), Vector2(105, 300), Vector2(158, 285), Vector2(211, 300)]
    for index in monster_roster.recruited.size():
        if index >= monster_positions.size():
            break
        var monster_id := String(monster_roster.recruited[index])
        if not MONSTER_TEXTURES.has(monster_id):
            continue
        _add_resident(monster_id.capitalize(), MONSTER_TEXTURES[monster_id], monster_positions[index], func(): _select_building("den"))
    _add_resident("Forgeron", MONSTER_TEXTURES.mimic, Vector2(330, 196), func(): _select_building("forge"))
    _add_resident("Archiviste", MONSTER_TEXTURES.ghost, Vector2(278, 312), _open_archives)
    _add_resident("Marchand", MONSTER_TEXTURES.spider, Vector2(315, 420), func(): _select_building("market"))

func _add_resident(label: String, texture: Texture2D, position_value: Vector2, action: Callable) -> void:
    var button := Button.new()
    button.name = "%sResident" % label.replace(" ", "")
    button.position = position_value
    button.size = Vector2(48, 48)
    button.flat = true
    button.icon = _first_animation_frame(texture)
    button.expand_icon = true
    button.tooltip_text = "%s — cliquer pour ouvrir sa fonction." % label
    button.pressed.connect(action)
    add_child(button)
    village_residents.append(button)
    var tween := create_tween().set_loops()
    tween.tween_property(button, "position:y", position_value.y - 4.0, 0.65).set_trans(Tween.TRANS_SINE)
    tween.tween_property(button, "position:y", position_value.y, 0.65).set_trans(Tween.TRANS_SINE)

func _first_animation_frame(texture: Texture2D) -> AtlasTexture:
    var atlas := AtlasTexture.new()
    atlas.atlas = texture
    var frame_width := maxi(1, texture.get_width() / 4)
    atlas.region = Rect2(0, 0, frame_width, texture.get_height())
    return atlas

func _village_reaction_text() -> String:
    if last_run_result.is_empty():
        return "Le village attend les ordres de son architecte."
    if bool(last_run_result.get("victory", false)):
        return "Victoire ! Les habitants célèbrent %d capture(s) et renforcent le village." % int(last_run_result.get("captures", 0))
    return "Défaite à la vague %d… les monstres préparent déjà leur revanche." % int(last_run_result.get("wave", 0))

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

func _build_room_deck_controls() -> void:
    var content := get_node("Panel/Margin/Content") as VBoxContainer
    biome_selector = OptionButton.new()
    biome_selector.name = "BiomeSelector"
    biome_selector.add_theme_font_size_override("font_size", 9)
    var catalog := BiomeCatalog.new()
    for biome_id in catalog.all_ids():
        var definition := catalog.get_biome(biome_id)
        biome_selector.add_item("Biome : %s" % String(definition.name))
        biome_selector.set_item_metadata(biome_selector.item_count - 1, biome_id)
        if biome_id == room_deck_selection.biome_id:
            biome_selector.select(biome_selector.item_count - 1)
    biome_selector.item_selected.connect(_select_biome)
    content.add_child(biome_selector)
    room_deck_label = Label.new()
    room_deck_label.name = "RoomDeckLabel"
    room_deck_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    room_deck_label.add_theme_font_size_override("font_size", 9)
    room_deck_label.tooltip_text = "Le générateur place exactement ces pièces, dans un ordre déterminé par la seed."
    content.add_child(room_deck_label)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 4)
    content.add_child(row)
    room_selector = OptionButton.new()
    room_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    room_selector.add_theme_font_size_override("font_size", 9)
    for room_id in room_deck_selection.room_ids():
        var definition := room_deck_selection.room(room_id)
        room_selector.add_item("%s · %d or · R%d" % [definition.display_name, definition.build_cost, definition.rarity])
        room_selector.set_item_metadata(room_selector.item_count - 1, room_id)
        room_selector.set_item_tooltip(room_selector.item_count - 1, "Tags : %s · connexions : %d · copies max : %d" % [", ".join(definition.tags), definition.connections.size(), definition.max_copies])
    row.add_child(room_selector)
    var add_button := Button.new()
    add_button.text = "+"
    add_button.tooltip_text = "Ajouter la pièce sélectionnée au deck."
    add_button.pressed.connect(_add_selected_room)
    row.add_child(add_button)
    var remove_button := Button.new()
    remove_button.text = "−"
    remove_button.tooltip_text = "Retirer la dernière pièce du deck."
    remove_button.pressed.connect(_remove_last_room)
    row.add_child(remove_button)
    _refresh_room_deck_controls()

func _add_selected_room() -> void:
    if room_selector.selected < 0:
        return
    var room_id := String(room_selector.get_item_metadata(room_selector.selected))
    var result := room_deck_selection.add(room_id)
    if not bool(result.ok):
        status_label.text = room_deck_selection.rejection_message(result)
    else:
        _persist_village_state()
        status_label.text = "%s ajoutée au deck." % room_deck_selection.room(room_id).display_name
    _refresh_room_deck_controls()

func _remove_last_room() -> void:
    var result := room_deck_selection.remove_last()
    if not bool(result.ok):
        status_label.text = room_deck_selection.rejection_message(result)
    else:
        _persist_village_state()
    _refresh_room_deck_controls()

func _refresh_room_deck_controls() -> void:
    if room_deck_label != null:
        room_deck_label.text = "DECK DE PIÈCES %d/%d\n%s" % [room_deck_selection.selected.size(), RoomDeckSelection.MAX_ROOMS, room_deck_selection.display_summary()]
        var validation := room_deck_selection.validate_for_biome()
        room_deck_label.modulate = Color.WHITE if bool(validation.ok) else Color("ff9f80")
        room_deck_label.tooltip_text = "Deck valide pour ce biome." if bool(validation.ok) else room_deck_selection.rejection_message(validation)

func _select_biome(index: int) -> void:
    var result := room_deck_selection.set_biome(String(biome_selector.get_item_metadata(index)))
    if not bool(result.ok):
        status_label.text = room_deck_selection.rejection_message(result)
    else:
        _persist_village_state()
        var validation := room_deck_selection.validate_for_biome()
        status_label.text = "Biome sélectionné." if bool(validation.ok) else room_deck_selection.rejection_message(validation)
    _refresh_room_deck_controls()

func _build_archives() -> void:
    archives_button = Button.new()
    archives_button.name = "ArchivesButton"
    archives_button.position = Vector2(20, 20)
    archives_button.size = Vector2(190, 38)
    archives_button.text = "ARCHIVES"
    var pending := encyclopedia.pending_notifications.size()
    if pending > 0:
        archives_button.text += " · %d nouveau(x)" % pending
    archives_button.tooltip_text = "Encyclopédie, statistiques globales, records et succès."
    archives_button.pressed.connect(_open_archives)
    add_child(archives_button)

    archives_panel = PanelContainer.new()
    archives_panel.name = "ArchivesPanel"
    archives_panel.set_anchors_preset(Control.PRESET_CENTER)
    archives_panel.offset_left = -330.0
    archives_panel.offset_top = -270.0
    archives_panel.offset_right = 330.0
    archives_panel.offset_bottom = 270.0
    archives_panel.visible = false
    add_child(archives_panel)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 20)
    margin.add_theme_constant_override("margin_top", 16)
    margin.add_theme_constant_override("margin_right", 20)
    margin.add_theme_constant_override("margin_bottom", 16)
    archives_panel.add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)
    var heading := Label.new()
    heading.text = "ARCHIVES DU MAÎTRE DU DONJON"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 20)
    column.add_child(heading)
    archives_stats = Label.new()
    archives_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    archives_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(archives_stats)
    archives_category = OptionButton.new()
    for category in ["monster", "adventurer", "room", "biome", "synergy", "achievement"]:
        archives_category.add_item({"monster": "Monstres", "adventurer": "Aventuriers", "room": "Pièces", "biome": "Biomes", "synergy": "Synergies", "achievement": "Succès"}[category])
        archives_category.set_item_metadata(archives_category.item_count - 1, category)
    archives_category.item_selected.connect(_refresh_archives)
    column.add_child(archives_category)
    archives_text = RichTextLabel.new()
    archives_text.bbcode_enabled = true
    archives_text.fit_content = false
    archives_text.custom_minimum_size = Vector2(600, 350)
    archives_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(archives_text)
    var close_button := Button.new()
    close_button.text = "Fermer"
    close_button.pressed.connect(func(): archives_panel.visible = false)
    column.add_child(close_button)

func _open_archives() -> void:
    archives_panel.visible = true
    archives_panel.move_to_front()
    var notifications := encyclopedia.consume_notifications()
    if not notifications.is_empty():
        status_label.text = "%d nouvelle(s) découverte(s) ajoutée(s) aux Archives." % notifications.size()
        _persist_village_state()
    archives_button.text = "ARCHIVES"
    _refresh_archives(archives_category.selected)

func _refresh_archives(index: int) -> void:
    var favorite_monster := global_stats.most_used(global_stats.favorite_monsters)
    var favorite_synergy := global_stats.most_used(global_stats.favorite_synergies)
    archives_stats.text = "Runs : %d · Victoires : %d%% · Record : %d · Vague max : %d · Favoris : %s / %s" % [global_stats.total_runs, roundi(global_stats.win_rate() * 100.0), global_stats.best_score, global_stats.best_wave, favorite_monster if not favorite_monster.is_empty() else "—", favorite_synergy if not favorite_synergy.is_empty() else "—"]
    var category := String(archives_category.get_item_metadata(index))
    var lines: Array[String] = []
    if category == "achievement":
        for achievement_id in achievements.definitions:
            var definition: Dictionary = achievements.definitions[achievement_id]
            var progress := achievements.progress(achievement_id)
            var icon := "✓" if bool(progress.complete) else "○"
            lines.append("[b]%s %s[/b]  %d/%d" % [icon, String(definition.name), int(progress.current), int(progress.target)])
    else:
        for raw_entry in encyclopedia_catalog.list_by_kind(category):
            var entry := encyclopedia.visible_entry(encyclopedia_catalog, String(raw_entry.id))
            var state_label: String = ["INCONNU", "APERÇU", "DÉCOUVERT"][int(entry.state)]
            var line := "[b]%s[/b]  [color=#9aa8bf]%s[/color]\n%s" % [String(entry.name), state_label, String(entry.description)]
            if entry.has("stats"):
                line += " · Utilisations : %d · Victoires : %d" % [int(entry.stats.uses), int(entry.stats.wins)]
            lines.append(line)
    archives_text.text = "\n\n".join(lines)

func _start_village_music() -> void:
    music_player = AudioStreamPlayer.new()
    music_player.name = "VillageAmbience"
    var looped_stream := VillageMusic.duplicate() as AudioStreamWAV
    looped_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    music_player.stream = looped_stream
    music_player.volume_db = -60.0
    add_child(music_player)
    music_player.play()
    create_tween().tween_property(music_player, "volume_db", _village_music_db(), 1.8)

func _build_feedback_settings() -> void:
    feedback_button = Button.new()
    feedback_button.name = "FeedbackSettingsButton"
    feedback_button.position = Vector2(20, 66)
    feedback_button.size = Vector2(190, 32)
    feedback_button.text = "OPTIONS AUDIO / VFX"
    feedback_button.pressed.connect(func(): feedback_panel.visible = not feedback_panel.visible; feedback_panel.move_to_front())
    add_child(feedback_button)
    feedback_panel = PanelContainer.new()
    feedback_panel.name = "FeedbackSettingsPanel"
    feedback_panel.set_anchors_preset(Control.PRESET_CENTER)
    feedback_panel.offset_left = -210.0
    feedback_panel.offset_top = -190.0
    feedback_panel.offset_right = 210.0
    feedback_panel.offset_bottom = 190.0
    feedback_panel.visible = false
    add_child(feedback_panel)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 20)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_right", 20)
    margin.add_theme_constant_override("margin_bottom", 18)
    feedback_panel.add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)
    var heading := Label.new()
    heading.text = "AUDIO ET EFFETS"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 18)
    column.add_child(heading)
    _add_feedback_slider(column, "Volume général", feedback_settings.master_volume, "master_volume")
    _add_feedback_slider(column, "Musique", feedback_settings.music_volume, "music_volume")
    _add_feedback_slider(column, "Effets sonores", feedback_settings.effects_volume, "effects_volume")
    _add_feedback_slider(column, "Secousses", feedback_settings.screen_shake_strength, "screen_shake_strength")
    var particles := CheckButton.new()
    particles.text = "Particules et flashs"
    particles.button_pressed = feedback_settings.particles_enabled
    particles.toggled.connect(func(value: bool): _set_feedback_option("particles_enabled", value))
    column.add_child(particles)
    var reduced_motion := CheckButton.new()
    reduced_motion.text = "Réduire les mouvements"
    reduced_motion.button_pressed = feedback_settings.reduced_motion
    reduced_motion.toggled.connect(func(value: bool): _set_feedback_option("reduced_motion", value))
    column.add_child(reduced_motion)
    var close_button := Button.new()
    close_button.text = "Fermer"
    close_button.pressed.connect(func(): feedback_panel.visible = false)
    column.add_child(close_button)

func _add_feedback_slider(parent: VBoxContainer, label_text: String, value: float, key: String) -> void:
    var row := HBoxContainer.new()
    var label := Label.new()
    label.text = label_text
    label.custom_minimum_size.x = 145
    row.add_child(label)
    var slider := HSlider.new()
    slider.name = "%sSlider" % key.capitalize().replace("_", "")
    slider.min_value = 0.0
    slider.max_value = 1.0
    slider.step = 0.05
    slider.value = value
    slider.custom_minimum_size.x = 190
    slider.value_changed.connect(func(new_value: float): _set_feedback_option(key, new_value))
    row.add_child(slider)
    parent.add_child(row)

func _set_feedback_option(key: String, value: Variant) -> void:
    feedback_settings.apply({key: value})
    _persist_village_state()
    if music_player != null:
        music_player.volume_db = _village_music_db()

func _village_music_db() -> float:
    var linear_volume := feedback_settings.master_volume * feedback_settings.music_volume * 0.14
    return linear_to_db(linear_volume) if linear_volume > 0.001 else -80.0

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
    _refresh_building_progression_visuals()
    _refresh_module_controls()
    _select_building(selected_building)

func _persist_village_state() -> void:
    var state := meta_store.load_state()
    state["v04_progression"] = progression_service.state.duplicate(true)
    state["black_market"] = black_market.to_dict()
    state["monster_roster"] = monster_roster.to_dict()
    state["labyrinth_modules"] = labyrinth_modules.to_dict()
    state["room_deck_selection"] = room_deck_selection.to_dict()
    state["encyclopedia"] = encyclopedia.to_dict()
    state["feedback_settings"] = feedback_settings.serialize()
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
    var deck_validation := room_deck_selection.validate_for_biome()
    if not bool(deck_validation.ok):
        status_label.text = room_deck_selection.rejection_message(deck_validation)
        _refresh_room_deck_controls()
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
