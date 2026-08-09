extends Node

# SimpleAIDriver - follows WaypointPath and controls a car (RigidBody3D with set_input method)

@export var waypoint_node_path: NodePath
@export var car_node_path: NodePath
@export var max_steer_angle: float = 1.0
@export var accel: float = 1.0

var _waypoints: Node = null
var _car: Node = null
var _current_index: int = 0

func _ready() -> void:
    if waypoint_node_path and has_node(waypoint_node_path):
        _waypoints = get_node(waypoint_node_path)
    if car_node_path and has_node(car_node_path):
        _car = get_node(car_node_path)
    if _car:
        _car.add_to_group("ai_car")
        # Auto-register with RaceManager autoload if present
        var root = get_tree().get_root()
        if root and root.has_node("RaceManager"):
            var rm = root.get_node("RaceManager")
            if rm and rm.has_method("register_car"):
                rm.register_car(_car)

func _physics_process(delta: float) -> void:
    if not _car or not _waypoints:
        return
    var pos = _car.global_transform.origin
    var target = _waypoints.get_point(_current_index)
    var to_target = (target - pos)
    var forward = -_car.global_transform.basis.z.normalized()
    var desired_dir = to_target.normalized()
    var steer = forward.cross(desired_dir).y
    steer = clamp(steer, -max_steer_angle, max_steer_angle)
    # Simple speed control: if facing target, accelerate
    var facing = forward.dot(desired_dir)
    var do_accel = facing > 0.3
    _car.call("set_input", (do_accel ? accel : 0.0), 0.0, steer, false, false)
    # Advance to next waypoint when close
    if to_target.length() < 4.0:
        _current_index = (_current_index + 1) % _waypoints.get_count()
