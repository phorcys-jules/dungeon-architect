class_name AccessibilitySettings
extends RefCounted

var settings := {
	"colorblind_mode": "off",
	"reduced_motion": false,
}

func set_colorblind(mode: String) -> void:
	settings["colorblind_mode"] = mode

func set_reduced_motion(enabled: bool) -> void:
	settings["reduced_motion"] = enabled

func serialize(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(settings))
	file.close()
	return true

func load(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	settings = Dictionary(parsed).duplicate(true)
	return true
