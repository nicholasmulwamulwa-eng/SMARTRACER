extends Node

# RaceManager - manages race state, countdown, and registered cars
# Intended as an autoload (RaceManager)

class_name RaceManager

signal race_countdown_started(seconds)
signal race_countdown_tick(seconds_left)
signal race_started()
signal race_finished(results)
signal car_finished_event(car, final_lap)

var cars: Array = []
var race_active: bool = false
var _lap_manager: Node = null
var _results: Array = []

func _ready() -> void:
    print("[RaceManager] Ready (autoload)")
    # Autoload is ready — will attach to LapManager once a scene with LapManager is loaded.

func register_car(car: Node) -> void:
    if car in cars:
        return
    cars.append(car)
    # If lap manager already present, register the car there
    if _lap_manager and _lap_manager.has_method("register_car"):
        _lap_manager.register_car(car)

func start_countdown(seconds: int = 3) -> void:
    emit_signal("race_countdown_started", seconds)
    # Attempt to find LapManager in current scene
    var scene = get_tree().get_current_scene()
    if scene and scene.has_node("LapManager"):
        _lap_manager = scene.get_node("LapManager")
        # connect lap/finish signals
        if _lap_manager.has_signal("lap_changed"):
            _lap_manager.connect("lap_changed", Callable(self, "_on_lap_changed"))
        if _lap_manager.has_signal("car_finished"):
            _lap_manager.connect("car_finished", Callable(self, "_on_car_finished"))
        # register existing cars with lap manager
        # Also auto-discover cars in groups
        var player_nodes = get_tree().get_nodes_in_group("player_car")
        var ai_nodes = get_tree().get_nodes_in_group("ai_car")
        for c in player_nodes:
            register_car(c)
        for c in ai_nodes:
            register_car(c)
        for c in cars:
            if _lap_manager.has_method("register_car"):
                _lap_manager.register_car(c)
    # Countdown loop
    for i in range(seconds, 0, -1):
        emit_signal("race_countdown_tick", i)
        print("[RaceManager] Countdown: %d" % i)
        await get_tree().create_timer(1.0).timeout
    # Start race
    race_active = true
    emit_signal("race_started")
    print("[RaceManager] Race started")

func end_race() -> void:
    race_active = false
    emit_signal("race_finished", _results)
    print("[RaceManager] Race finished")

func _on_lap_changed(car: Node, lap: int) -> void:
    # Placeholder: can be used to update UI, positions, best lap, etc.
    print("[RaceManager] Car %s advanced to lap %d" % [str(car.get_instance_id()), lap])

func _on_car_finished(car: Node, final_lap: int) -> void:
    # Record finish order
    _results.append({"car": car, "lap": final_lap})
    emit_signal("car_finished_event", car, final_lap)
    print("[RaceManager] Car %s finished (lap %d)" % [str(car.get_instance_id()), final_lap])
    # If all cars finished, end race
    var all_finished = true
    for c in cars:
        if not (_lap_manager and _lap_manager.has_method("is_finished") and _lap_manager.is_finished(c)):
            all_finished = false
            break
    if all_finished:
        end_race()

func get_positions() -> Array:
    # Returns cars sorted by lap, checkpoint index and distance to next checkpoint (lower distance is ahead)
    if not _lap_manager:
        return cars.duplicate()
    var scored = []
    for c in cars:
        var prog = _lap_manager.get_progress_score(c)
        # higher lap -> ahead, higher last_index -> ahead, lower distance -> ahead
        var lap = prog.has("lap") and prog["lap"] or 0
        var index = prog.has("index") and prog["index"] or -1
        var dist = prog.has("dist") and prog["dist"] or 1e9
        scored.append({"car": c, "lap": lap, "index": index, "dist": dist})
    scored.sort_inplace_custom(self, "_position_compare")
    var order = []
    for s in scored:
        order.append(s.car)
    return order

func _position_compare(a, b) -> int:
    # compare two score dicts
    if a["lap"] != b["lap"]:
        return b["lap"] - a["lap"]
    if a["index"] != b["index"]:
        return b["index"] - a["index"]
    # smaller distance is ahead -> return negative if a.dist < b.dist
    if a["dist"] < b["dist"]:
        return -1
    elif a["dist"] > b["dist"]:
        return 1
    return 0
