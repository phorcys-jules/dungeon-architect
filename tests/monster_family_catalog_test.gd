extends SceneTree

func _init() -> void:
    var catalog := MonsterFamilyCatalog.new()
    var spectral: Dictionary = catalog.get_family("spectral")
    assert(spectral.affinity == "mist")
    var affinities: Dictionary = catalog.team_affinities(["spectral", "spectral", "slime"])
    assert(affinities.has("spectral"))
    assert(not affinities.has("slime"))
    print("monster family catalog test passed")
    quit()
