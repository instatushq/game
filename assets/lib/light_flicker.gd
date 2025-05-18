extends Light2D

@export var min_energy_multiplier: float = 0.5
@export var flicker_speed: float = 2.0

var noise: FastNoiseLite
var time: float = 0.0
var noise_offset: float = 0.0
var initial_energy: float

func _ready() -> void:
	initial_energy = energy
	
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise_offset = randf_range(0, 1000)

func _process(delta: float) -> void:
	time += delta * flicker_speed
	var noise_value = noise.get_noise_1d(time + noise_offset)
	noise_value = (noise_value + 1.0) * 0.5
	energy = lerp(initial_energy * min_energy_multiplier, initial_energy, noise_value)
