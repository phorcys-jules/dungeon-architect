class_name LocalizationRuntime
extends RefCounted

const SUPPORTED := [&"fr", &"en"]
const FR_TRANSLATION: Translation = preload("res://resources/localization/ui.fr.tres")
const EN_TRANSLATION: Translation = preload("res://resources/localization/ui.en.tres")
const TEXT := {
    &"fr": {
        "tutorial.choose_route": "Choisissez une route de campagne.",
        "tutorial.place_wall": "Placez un mur sans bloquer le trésor.",
        "tutorial.place_trap": "Placez un piège sur la route annoncée.",
        "tutorial.assign_monster": "Affectez un monstre à une zone.",
        "tutorial.start_wave": "Lancez la vague quand le plan est prêt.",
        "tutorial.review_result": "Consultez le débrief tactique.",
        "tutorial.upgrade_village": "Utilisez vos ressources au village.",
        "debrief.treasure_exposed": "Le trésor était directement exposé.",
        "debrief.defense_breached": "Une brèche a concentré les dégâts.",
        "debrief.monsters_isolated": "Les monstres ont combattu isolément.",
        "debrief.untracked_route": "La route principale était peu surveillée.",
    },
    &"en": {
        "tutorial.choose_route": "Choose a campaign route.",
        "tutorial.place_wall": "Place a wall without blocking the treasure.",
        "tutorial.place_trap": "Place a trap on the announced route.",
        "tutorial.assign_monster": "Assign a monster to a zone.",
        "tutorial.start_wave": "Start the wave when your plan is ready.",
        "tutorial.review_result": "Review the tactical debrief.",
        "tutorial.upgrade_village": "Spend your resources in the village.",
        "debrief.treasure_exposed": "The treasure was directly exposed.",
        "debrief.defense_breached": "A breach concentrated incoming damage.",
        "debrief.monsters_isolated": "Monsters fought in isolation.",
        "debrief.untracked_route": "The main route was poorly monitored.",
    },
}

var locale: StringName = &"fr"

func _init() -> void:
    TranslationServer.add_translation(FR_TRANSLATION)
    TranslationServer.add_translation(EN_TRANSLATION)
    TranslationServer.set_locale(String(locale))

func set_locale(value: StringName) -> bool:
    if not SUPPORTED.has(value):
        return false
    locale = value
    TranslationServer.set_locale(String(locale))
    return true

func text(key: String, values: Dictionary = {}) -> String:
    var catalog: Dictionary = TEXT.get(locale, TEXT[&"fr"])
    var translated := String(TranslationServer.translate(key))
    if translated == key and not catalog.has(key):
        translated = "[%s]" % key
    for name in values:
        translated = translated.replace("{%s}" % name, str(values[name]))
    return translated

func coverage() -> Dictionary:
    var source: Dictionary = TEXT[&"fr"]
    var missing := {}
    for candidate in SUPPORTED:
        var catalog: Dictionary = TEXT[candidate]
        missing[candidate] = source.keys().filter(func(key): return not catalog.has(key))
    return missing

func audit_catalogs() -> Dictionary:
    var missing: Array[String] = []
    var placeholder_mismatches: Array[String] = []
    for key in FR_TRANSLATION.get_message_list():
        var english := EN_TRANSLATION.get_message(key)
        if english.is_empty():
            missing.append(key)
        elif _placeholders(FR_TRANSLATION.get_message(key)) != _placeholders(english):
            placeholder_mismatches.append(key)
    return {"missing": missing, "placeholder_mismatches": placeholder_mismatches, "messages": FR_TRANSLATION.get_message_count()}

func _placeholders(value: String) -> Array[String]:
    var regex := RegEx.new()
    regex.compile("%(?:\\.\\d+)?[dfs]")
    var result: Array[String] = []
    for match_result in regex.search_all(value):
        result.append(match_result.get_string())
    return result

func to_dict() -> Dictionary:
    return {"locale": locale}

func from_dict(data: Dictionary) -> void:
    set_locale(StringName(data.get("locale", &"fr")))
