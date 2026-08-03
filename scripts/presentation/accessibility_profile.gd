class_name AccessibilityProfile
extends RefCounted

const COLORBLIND_PALETTES := {
    &"default": [Color("4cc9f0"), Color("f72585"), Color("ffd166")],
    &"deuteranopia": [Color("0072b2"), Color("e69f00"), Color("cc79a7")],
    &"protanopia": [Color("56b4e9"), Color("f0e442"), Color("000000")],
    &"tritanopia": [Color("d55e00"), Color("009e73"), Color("cc79a7")],
}

var bindings: Dictionary = {}
var palette: StringName = &"default"
var audio := {"music": 1.0, "effects": 1.0, "voice": 1.0}
var reduced_motion := false
var flashes_enabled := true
var screen_shake := 1.0
var game_speed := 1.0

func ensure_default_bindings() -> void:
    var defaults := {&"start_wave": KEY_ENTER, &"toggle_door": KEY_D, &"tactical_lock": KEY_Q, &"tactical_hunt": KEY_E, &"tactical_overcharge": KEY_F, &"toggle_heatmap": KEY_H, &"capture_blueprint": KEY_B, &"place_blueprint": KEY_G}
    for action in defaults:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        if bindings.has(action):
            continue
        bindings[action] = defaults[action]
        var key_event := InputEventKey.new()
        key_event.physical_keycode = int(defaults[action])
        InputMap.action_add_event(action, key_event)
    _ensure_controller_binding(&"start_wave", JOY_BUTTON_A)
    _ensure_controller_binding(&"toggle_door", JOY_BUTTON_X)
    _ensure_controller_binding(&"tactical_lock", JOY_BUTTON_LEFT_SHOULDER)
    _ensure_controller_binding(&"tactical_hunt", JOY_BUTTON_RIGHT_SHOULDER)
    _ensure_controller_binding(&"toggle_heatmap", JOY_BUTTON_Y)

func apply_bindings() -> void:
    ensure_default_bindings()
    for action in bindings:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for event in InputMap.action_get_events(action):
            if event is InputEventKey:
                InputMap.action_erase_event(action, event)
        var key_event := InputEventKey.new()
        key_event.physical_keycode = int(bindings[action])
        InputMap.action_add_event(action, key_event)

func _ensure_controller_binding(action: StringName, button: JoyButton) -> void:
    for event in InputMap.action_get_events(action):
        if event is InputEventJoypadButton and event.button_index == button:
            return
    var joy_event := InputEventJoypadButton.new()
    joy_event.button_index = button
    InputMap.action_add_event(action, joy_event)

func rebind(action: StringName, physical_code: int) -> bool:
    if action.is_empty() or physical_code <= 0:
        return false
    bindings[action] = physical_code
    return true

func set_palette(id: StringName) -> bool:
    if not COLORBLIND_PALETTES.has(id):
        return false
    palette = id
    return true

func color(index: int) -> Color:
    var colors: Array = COLORBLIND_PALETTES[palette]
    return colors[posmod(index, colors.size())]

func apply(data: Dictionary) -> void:
    bindings = Dictionary(data.get("bindings", {})).duplicate(true)
    set_palette(StringName(data.get("palette", "default")))
    audio.merge(data.get("audio", {}), true)
    reduced_motion = bool(data.get("reduced_motion", false))
    flashes_enabled = bool(data.get("flashes_enabled", true))
    screen_shake = clampf(float(data.get("screen_shake", 1.0)), 0.0, 1.0)
    game_speed = clampf(float(data.get("game_speed", 1.0)), 0.5, 2.0)

func serialize() -> Dictionary:
    return {"bindings": bindings.duplicate(true), "palette": palette, "audio": audio.duplicate(true), "reduced_motion": reduced_motion, "flashes_enabled": flashes_enabled, "screen_shake": screen_shake, "game_speed": game_speed}
