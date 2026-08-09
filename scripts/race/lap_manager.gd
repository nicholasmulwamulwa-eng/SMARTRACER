extends Node

# LapManager - handles checkpoints and lap counting per car for the current track

@export var total_laps: int = 3

signal lap_changed(car, lap)
signal car_finished(car, lap)

var checkpoints: Array = [] # filtered list of checkpoint nodes in parent order
var checkpoints_count: int = 0
var car_state := {} # key: instance_id -> { last_index:int, lap:int, finished:bool }

func _ready() -> void:
    # Build a deterministic list of checkpoint nodes (only those using checkpoint.gd)
    checkpoints.clear()
    var scene = get_tree().get_current_scene()
    var cp_script = preload("res://scripts/tracks/checkpoint.gd")
    if scene and scene.has_node("Checkpoints"):
        var cp_parent = scene.get_node("Checkpoints")
        for child in cp_parent.get_children():
            if child is Area3D and child.get_script() == cp_script:
                checkpoints.append(child)
    checkpoints_count = checkpoints.size()
    print("[LapManager] checkpoints: %d" % checkpoints_count)

func reset() -> void:
    car_state.clear()

func register_car(car: RigidBody3D) -> void:
    var id = str(car.get_instance_id())
    if not car_state.has(id):
        car_state[id] = {"last_index": -1, "lap": 1, "finished": false}

func checkpoint_passed(car: RigidBody3D, index: int) -> void:
    if checkpoints_count == 0:
        return
    var id = str(car.get_instance_id())
    if not car_state.has(id):
        register_car(car)
    var st = car_state[id]
    if st["finished"]:
        return
    # Compute expected index
    var expected = (st["last_index"] + 1) % checkpoints_count
    if index == expected:
        st["last_index"] = index
        # If this was the last checkpoint in the lap (finish line)
        if index == checkpoints_count - 1:
            if st["lap"] >= total_laps:
                st["finished"] = true
                emit_signal("car_finished", car, st["lap"])
            else:
                st["lap"] += 1
                st["last_index"] = -1
                emit_signal("lap_changed", car, st["lap"])

func get_car_lap(car: RigidBody3D) -> int:
    var id = str(car.get_instance_id())
    if car_state.has(id):
        return car_state[id]["lap"]
    return 0

func is_finished(car: RigidBody3D) -> bool:
    var id = str(car.get_instance_id())
    return car_state.has(id) and car_state[id]["finished"]

func get_progress_score(car: RigidBody3D) -> Dictionary:
    var id = str(car.get_instance_id())
    if not car_state.has(id):
        return {"lap":0, "index":-1, "dist":1e9}
    var st = car_state[id]
    var scene = get_tree().get_current_scene()
    if checkpoints_count <= 0:
        return {"lap": st["lap"], "index": st["last_index"], "dist": 1e9}
    var next_index = (st["last_index"] + 1) % checkpoints_count
    next_index = clamp(next_index, 0, max(0, checkpoints_count - 1))
    var dist = 1e9
    if checkpoints.size() > next_index:
        var cp = checkpoints[next_index]
        if cp:
            dist = cp.global_transform.origin.distance_to(car.global_transform.origin)
    return {"lap": st["lap"], "index": st["last_index"], "dist": dist}
