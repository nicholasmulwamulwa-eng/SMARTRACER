extends Node

# LapManager - handles checkpoints and lap counting per car for the current track

@export var total_laps: int = 3

signal lap_changed(car, lap)
signal car_finished(car, lap)

var checkpoints_count: int = 0
var car_state := {} # key: instance_id -> { last_index:int, lap:int, finished:bool }

func _ready() -> void:
    # Count checkpoints in current scene
    var scene = get_tree().get_current_scene()
    if scene and scene.has_node("Checkpoints"):
        checkpoints_count = scene.get_node("Checkpoints").get_child_count()
    else:
        checkpoints_count = 0
    print("[LapManager] checkpoints: %d" % checkpoints_count)

func register_car(car: RigidBody3D) -> void:
    var id = str(car.get_instance_id())
    if not car_state.has(id):
        car_state[id] = {"last_index": -1, "lap": 1, "finished": false}
    # Return current lap for convenience
    return car_state[id]["lap"]

func checkpoint_passed(car: RigidBody3D, index: int) -> void:
    if checkpoints_count == 0:
        return
    var id = str(car.get_instance_id())
    if not car_state.has(id):
        register_car(car)
    var st = car_state[id]
    if st["finished"]:
        return
    var expected = (st["last_index"] + 1) % checkpoints_count
    # Accept if matches expected checkpoint (tolerant: allow same index if not progressed)
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
    else:
        # Optional: if detection is out of order, we could allow partial progress; keep simple for now.
        pass

func get_car_lap(car: RigidBody3D) -> int:
    var id = str(car.get_instance_id())
    if car_state.has(id):
        return car_state[id]["lap"]
    return 0

func is_finished(car: RigidBody3D) -> bool:
    var id = str(car.get_instance_id())
    return car_state.has(id) and car_state[id]["finished"]

func get_progress_score(car: RigidBody3D) -> Dictionary:
    # Returns a simple tuple for ordering: lap, last_index (checkpoint), distance_to_next_checkpoint
    var id = str(car.get_instance_id())
    if not car_state.has(id):
        return {"lap":0, "index":-1, "dist":1e9}
    var st = car_state[id]
    var scene = get_tree().get_current_scene()
    var next_index = (st["last_index"] + 1) % checkpoints_count
    var dist = 1e9
    if scene and scene.has_node("Checkpoints"):
        var cp = scene.get_node("Checkpoints").get_child(next_index)
        if cp:
            dist = cp.global_transform.origin.distance_to(car.global_transform.origin)
    return {"lap": st["lap"], "index": st["last_index"], "dist": dist}
