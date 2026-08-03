class_name AccessibilitySettings
extends RefCounted

var settings := {"colorblind_mode":"off", "reduced_motion":false}

func set_colorblind(mode: String) -> void:
	settings["colorblind_mode"] = mode

func set_reduced_motion(enabled: bool) -> void:
	settings["reduced_motion"] = enabled

func serialize(path: String) -> bool:
	var file := File.new()
	if file.open(path, File.WRITE) != OK:
		return false
	file.store_string(to_json(settings))
	file.close()
	return true

func load(path: String) -> bool:
	var file := File.new()
	if not file.file_exists(path):
		return false
	if file.open(path, File.READ) != OK:
		return false
	settings = parse_json(file.get_as_text())
	file.close()
	return true
