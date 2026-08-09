extends Node

# LapManager - handles checkpoints and lap counting per car for the current track

@export var total_laps: int = 3

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

func checkpoint_passed(car: RigidBody3D, index: int) -> void:
    var id = str(car.get_instance_id())
    if not car_state.has(id):
        car_state[id] = {"last_index": -1, "lap": 1, "finished": false}
    var st = car_state[id]
    if st["finished"]:
        return
    var expected = (st["last_index"] + 1) % checkpoints_count
    # Accept if matches expected checkpoint
    if index == expected:
        st["last_index"] = index
        # If this was the last checkpoint in the lap (finish line)
        if index == checkpoints_count - 1:
            if st["lap"] >= total_laps:
                st["finished"] = true
                print("[LapManager] Car %s finished race (lap %d)" % [id, st["lap"]])
                # TODO: integrate with RaceManager finish handling
            else:
                st["lap"] += 1
                st["last_index"] = -1
                print("[LapManager] Car %s advanced to lap %d" % [id, st["lap"]])

func get_car_lap(car: RigidBody3D) -> int:
    var id = str(car.get_instance_id())
    if car_state.has(id):
        return car_state[id]["lap"]
    return 0

func is_finished(car: RigidBody3D) -> bool:
    var id = str(car.get_instance_id())
    return car_state.has(id) and car_state[id]["finished"]
