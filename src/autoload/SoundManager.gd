# res://src/autoload/SoundManager.gd
extends Node

var _sfx_players: Array[AudioStreamPlayer] = []
var _bgm_player: AudioStreamPlayer
var _audio_cache: Dictionary = {}

func _ready() -> void:
	# Pool of audio players for sound effects
	for i in range(8):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)
		
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	_bgm_player.volume_db = -8.0
	add_child(_bgm_player)

func play_sfx(sound_name: String, pitch: float = 1.0) -> void:
	var stream: AudioStream = _get_or_generate_sound(sound_name)
	if not stream:
		return
		
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch + randf_range(-0.05, 0.05)
			p.play()
			return
			
	# If all busy, use first
	_sfx_players[0].stream = stream
	_sfx_players[0].pitch_scale = pitch
	_sfx_players[0].play()

func _get_or_generate_sound(sound_name: String) -> AudioStreamWAV:
	if _audio_cache.has(sound_name):
		return _audio_cache[sound_name]
		
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	
	var data: PackedByteArray = PackedByteArray()
	var sample_count: int = 0
	
	match sound_name:
		"card_play", "card_draw":
			# Crisp swish sound
			sample_count = int(22050 * 0.15)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = (1.0 - float(i)/sample_count)
				var noise = randf_range(-1.0, 1.0) * env * 0.4
				var tone = sin(t * 800.0 * TAU) * env * 0.3
				var sample_val = int(clampf((noise + tone) * 0.5, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)
				
		"hit", "strike":
			# Heavy impact punch
			sample_count = int(22050 * 0.22)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = exp(-float(i) / (22050.0 * 0.04))
				var freq = 180.0 * exp(-t * 20.0) + 50.0
				var wave = sin(t * freq * TAU) * 0.7 + randf_range(-0.3, 0.3)
				var sample_val = int(clampf(wave * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)
				
		"rasengan":
			# High speed swirling vortex sound
			sample_count = int(22050 * 0.5)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = sin(float(i)/sample_count * PI)
				var mod_freq = 400.0 + sin(t * 40.0 * TAU) * 150.0
				var wave = sin(t * mod_freq * TAU) * 0.6 + randf_range(-0.2, 0.2)
				var sample_val = int(clampf(wave * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)
				
		"chidori":
			# Electric lightning zaps
			sample_count = int(22050 * 0.45)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = (1.0 - float(i)/sample_count)
				var zap = sin(t * (1200.0 + sin(t * 120.0 * TAU) * 600.0) * TAU)
				var crackle = randf_range(-0.5, 0.5) if randf() > 0.4 else 0.0
				var sample_val = int(clampf((zap * 0.5 + crackle) * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)
				
		"kawarimi":
			# Smoke puff & wood 'thud'
			sample_count = int(22050 * 0.35)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = exp(-float(i) / (22050.0 * 0.08))
				var thud = sin(t * 120.0 * TAU) * 0.6
				var smoke = randf_range(-0.4, 0.4) * exp(-t * 8.0)
				var sample_val = int(clampf((thud + smoke) * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)

		"qte_success":
			# Sharp high pitch chime
			sample_count = int(22050 * 0.25)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = exp(-float(i) / (22050.0 * 0.06))
				var chime = sin(t * 880.0 * TAU) * 0.5 + sin(t * 1760.0 * TAU) * 0.3
				var sample_val = int(clampf(chime * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)

		"chakra_charge":
			# Ascending power up tone
			sample_count = int(22050 * 0.4)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = sin(float(i)/sample_count * PI)
				var freq = 200.0 + (float(i)/sample_count) * 600.0
				var wave = sin(t * freq * TAU) * 0.6
				var sample_val = int(clampf(wave * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)

		"combo_storm":
			# Epic resonant gong / storm roar
			sample_count = int(22050 * 0.6)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = exp(-float(i) / (22050.0 * 0.15))
				var boom = sin(t * 80.0 * TAU) * 0.7 + sin(t * 240.0 * TAU) * 0.3
				var sample_val = int(clampf(boom * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)
				
		"kunai_defense":
			# Sharp metallic blade parry / deflection sound
			sample_count = int(22050 * 0.3)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = exp(-float(i) / (22050.0 * 0.05))
				var ring = sin(t * 2200.0 * TAU) * 0.5 + sin(t * 3300.0 * TAU) * 0.3 + sin(t * 880.0 * TAU) * 0.2
				var click = randf_range(-0.4, 0.4) * exp(-t * 80.0)
				var sample_val = int(clampf((ring + click) * env, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)
				
		_:
			# Default UI click
			sample_count = int(22050 * 0.08)
			data.resize(sample_count * 2)
			for i in range(sample_count):
				var t = float(i) / 22050.0
				var env = 1.0 - float(i)/sample_count
				var click = sin(t * 600.0 * TAU) * env * 0.4
				var sample_val = int(clampf(click, -1.0, 1.0) * 32767.0)
				data.encode_s16(i * 2, sample_val)
				
	wav.data = data
	_audio_cache[sound_name] = wav
	return wav
