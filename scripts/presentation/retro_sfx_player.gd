class_name RetroSfxPlayer
extends AudioStreamPlayer

const SAMPLE_RATE := 22050
const DEFINITIONS := {
    "slash": {"frequency": 330.0, "duration": 0.07},
    "projectile": {"frequency": 620.0, "duration": 0.09},
    "spectral": {"frequency": 470.0, "duration": 0.12},
    "web": {"frequency": 220.0, "duration": 0.10},
    "splash": {"frequency": 150.0, "duration": 0.08},
    "impact": {"frequency": 110.0, "duration": 0.06},
}

func play_event(event_id: String, settings: GameFeedbackSettings) -> bool:
    if settings == null or settings.effects_volume <= 0.0 or settings.master_volume <= 0.0:
        return false
    var definition: Dictionary = DEFINITIONS.get(event_id, DEFINITIONS.impact)
    stream = _generate_tone(float(definition.frequency), float(definition.duration))
    volume_db = linear_to_db(maxf(settings.effects_volume * settings.master_volume * 0.22, 0.001))
    play()
    return true

func _generate_tone(frequency: float, duration: float) -> AudioStreamWAV:
    var sample_count := maxi(1, roundi(SAMPLE_RATE * duration))
    var bytes := PackedByteArray()
    bytes.resize(sample_count)
    for index in sample_count:
        var envelope := 1.0 - float(index) / float(sample_count)
        var phase := fmod(float(index) * frequency / float(SAMPLE_RATE), 1.0)
        var wave := 1.0 if phase < 0.5 else -1.0
        bytes[index] = clampi(roundi(128.0 + wave * envelope * 62.0), 0, 255)
    var result := AudioStreamWAV.new()
    result.format = AudioStreamWAV.FORMAT_8_BITS
    result.mix_rate = SAMPLE_RATE
    result.stereo = false
    result.data = bytes
    return result
