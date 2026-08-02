class_name DenViewModel
extends RefCounted

var den: DenProgression

func _init(progression: DenProgression = null) -> void:
    den = progression if progression != null else DenProgression.new()

func get_title() -> String:
    return "Tanière — niveau %d/%d" % [den.level, DenProgression.MAX_LEVEL]

func get_status() -> String:
    return "Capacité : %d monstres\n%s : %s" % [den.get_capacity(), VillageCurrency.DISPLAY_NAME, den.currency.formatted()]

func get_upgrade_label() -> String:
    if den.level >= DenProgression.MAX_LEVEL:
        return "Niveau maximum"
    return "Améliorer (%s)" % den.currency.formatted(den.get_upgrade_cost())

func can_upgrade() -> bool:
    return den.can_upgrade()

func upgrade() -> bool:
    return den.upgrade()
