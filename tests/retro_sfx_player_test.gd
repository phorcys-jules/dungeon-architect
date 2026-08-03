extends SceneTree

const RetroSfxPlayerScript := preload("res://scripts/presentation/retro_sfx_player.gd")

func _init() -> void:
    var player = RetroSfxPlayerScript.new()
    root.add_child(player)
    await process_frame
    var settings := GameFeedbackSettings.new()
    assert(player.play_event("slash", settings))
    assert(player.stream is AudioStreamWAV)
    assert((player.stream as AudioStreamWAV).data.size() > 0)
    settings.effects_volume = 0.0
    assert(not player.play_event("impact", settings))
    root.remove_child(player)
    player.free()
    print("retro sfx player test passed")
    quit(0)
