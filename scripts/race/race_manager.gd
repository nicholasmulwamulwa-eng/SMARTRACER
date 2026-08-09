extends Node

# RaceManager stub - will be expanded in later phases
# Manages race state, countdown, and registered cars

class_name RaceManager

signal race_countdown_started(seconds)
signal race_started()
signal race_finished(results)

var cars: Array = []
var race_active: bool = false

func _ready() -> void:
    # This file is intended to be added as an autoload named RaceManager
    print("[RaceManager] Ready")

func register_car(car: Node) -> void:
    if car in cars:
        return
    cars.append(car)

func start_countdown(seconds: int = 3) -> void:
    emit_signal("race_countdown_started", seconds)
    # Simplified immediate start for now
    race_active = true
    emit_signal("race_started")
    print("[RaceManager] Race started")

func end_race() -> void:
    race_active = false
    emit_signal("race_finished", {})
    print("[RaceManager] Race finished")

func get_positions() -> Array:
    # Placeholder: returns cars array order
    return cars.duplicate()
