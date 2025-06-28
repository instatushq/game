class_name VolumeManagerGeneral extends Node

var master_bus: int = AudioServer.get_bus_index("Master")

var volume_change_amount: float = 5.0
var hold_volume_change_amount: float = 5.0  # Smaller amount for continuous changes
var hold_timer: float = 0.0
var hold_delay: float = 0.2  # Delay before hold starts working
var hold_interval: float = 0.1  # How often to change volume while holding
var last_hold_time: float = 0.0  # Track when we last changed volume during hold

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("increase_volume"):
		AudioServer.set_bus_volume_db(master_bus, clamp(AudioServer.get_bus_volume_db(master_bus) + volume_change_amount, -50, 0))
		hold_timer = 0.0
		last_hold_time = 0.0
	elif event.is_action_pressed("decrease_volume"):
		AudioServer.set_bus_volume_db(master_bus, clamp(AudioServer.get_bus_volume_db(master_bus) - volume_change_amount, -50, 0))
		hold_timer = 0.0
		last_hold_time = 0.0

func _process(delta: float) -> void:
	# Handle continuous volume changes while holding
	if Input.is_action_pressed("increase_volume"):
		hold_timer += delta
		if hold_timer >= hold_delay:
			if hold_timer - last_hold_time >= hold_interval:
				AudioServer.set_bus_volume_db(master_bus, clamp(AudioServer.get_bus_volume_db(master_bus) + hold_volume_change_amount, -50, 0))
				last_hold_time = hold_timer
	
	elif Input.is_action_pressed("decrease_volume"):
		hold_timer += delta
		if hold_timer >= hold_delay:
			if hold_timer - last_hold_time >= hold_interval:
				AudioServer.set_bus_volume_db(master_bus, clamp(AudioServer.get_bus_volume_db(master_bus) - hold_volume_change_amount, -50, 0))
				last_hold_time = hold_timer
	
	else:
		hold_timer = 0.0
		last_hold_time = 0.0
