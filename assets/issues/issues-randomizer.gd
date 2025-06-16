class_name IssuesRandomizer extends Node2D

@export_range(0.0, 1.0) var weight_reduction_factor: float = 1
@export_range(0.0, 1.0) var weight_increase_amount: float = 0.3

var rng = RandomNumberGenerator.new()
var _weights: Array[float] = []

func init_weights(elements_length: int) -> void:
    for i in elements_length:
        _weights.append(1.0)

func step_randomizer(index: int) -> void:
    _weights[index] -= _weights[index] * weight_reduction_factor
    for i in _weights.size():
        if i != index:
            _weights[i] += weight_increase_amount


func get_random_index() -> int:
    return rng.rand_weighted(_weights)