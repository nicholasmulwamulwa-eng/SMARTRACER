extends Node

# SimpleAIDriver - follows WaypointPath and controls a car (RigidBody3D with set_input method)
# Preserves existing steering and acceleration behavior while improving node resolution and waypoint support.

@export var waypoint_node_path: NodePath
@export var car_node_path: NodePath
@export var max_steer_angle: float = 1.0
@export var accel: float = 1.0

var _waypoints: Node = null
var _wp_positions: Array = []
var _car: Node = null
var _current_index: int = 0

func set_car_node(node: Node) -> void:
    # Directly set the car node reference (safer than NodePath resolution)
    _car = node
    if _car:
        if not _car.is_in_group("ai_car"):
            _car.add_to_group("ai_car")
        # Registration is handled by spawner/RaceManager; do not register here to avoid duplication

func set_waypoints_node(node: Node) -> void:
    _waypoints = node
    _prepare_waypoints()

func _ready() -> void:
    # Resolve car node from NodePath if provided
    if not _car and car_node_path and car_node_path != NodePath(""):
        if has_node(car_node_path):
            _car = get_node(car_node_path)
        else:
            var scene = get_tree().get_current_scene()
            if scene and scene.has_node(car_node_path):
                _car = scene.get_node(car_node_path)
    # fallback: first node in ai_car group (if any)
    if not _car:
        var ai_candidates = get_tree().get_nodes_in_group("ai_car")
        if ai_candidates.size() > 0:
            _car = ai_candidates[0]
    if _car:
        if not _car.is_in_group("ai_car"):
            _car.add_to_group("ai_car")
        # Do not register with RaceManager here; spawner will register explicitly

    # Resolve waypoints from NodePath or scene
    if not _waypoints and waypoint_node_path and waypoint_node_path != NodePath(""):
        if has_node(waypoint_node_path):
            _waypoints = get_node(waypoint_node_path)
        else:
            var scene = get_tree().get_current_scene()
            if scene and scene.has_node(waypoint_node_path):
                _waypoints = scene.get_node(waypoint_node_path)
    if not _waypoints:
        var scene = get_tree().get_current_scene()
        if scene and scene.has_node("Waypoints"):
            _waypoints = scene.get_node("Waypoints")

    _prepare_waypoints()

func _prepare_waypoints() -> void:
    _wp_positions.clear()
    if not _waypoints:
        return
    # If the waypoints node implements the waypoint API, use it directly
    if _waypoints.has_method("get_point") and _waypoints.has_method("get_count"):
        return
    # Otherwise, gather Marker3D child positions (supports Track_NairobiCircuit structure)
    for child in _waypoints.get_children():
        if child is Marker3D:
            _wp_positions.append(child.global_transform.origin)

func _get_waypoint_point(idx: int) -> Vector3:
    if _waypoints and _waypoints.has_method("get_point") and _waypoints.has_method("get_count"):
        var count = _waypoints.get_count()
        if count == 0:
            return Vector3.ZERO
        idx = idx % count
        return _waypoints.get_point(idx)
    else:
        if _wp_positions.size() == 0:
            return Vector3.ZERO
        idx = idx % _wp_positions.size()
        return _wp_positions[idx]

func _get_waypoint_count() -> int:
    if _waypoints and _waypoints.has_method("get_count"):
        return _waypoints.get_count()
    return max(0, _wp_positions.size())

func _physics_process(delta: float) -> void:
    if not _car or _get_waypoint_count() == 0:
        return
    var pos = _car.global_transform.origin
    var target = _get_waypoint_point(_current_index)
    var to_target = (target - pos)
    var forward = -_car.global_transform.basis.z.normalized()
    var desired_dir = to_target.normalized()
    var steer = forward.cross(desired_dir).y
    steer = clamp(steer, -max_steer_angle, max_steer_angle)
    # Preserve existing speed control behavior
    var facing = forward.dot(desired_dir)
    var do_accel = facing > 0.3
    # Use the car's existing set_input interface (accel, brake, steer, handbrake, nitro)
    if _car and _car.has_method("set_input"):
        var accel_value = accel if do_accel else 0.0
        _car.call("set_input", accel_value, 0.0, steer, false, false)
    # Advance to next waypoint when close
    if to_target.length() < 4.0:
        _current_index = (_current_index + 1) % max(1, _get_waypoint_count())
