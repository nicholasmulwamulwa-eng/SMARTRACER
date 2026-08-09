extends RigidBody3D

# CarController - basic, typed, configurable vehicle controller
# This is a gameplay controller separated from visuals so models can be swapped later.

@export var max_speed_kmh: float = 180.0
@export var acceleration_force: float = 8000.0
@export var brake_force: float = 12000.0
@export var steer_torque: float = 1500.0
@export var grip: float = 0.8
@export var drift_factor: float = 0.6
@export var weight: float = 1200.0
@export var downforce: float = 100.0
@export var nitro_boost: float = 4000.0
@export var nitro_capacity: float = 3.0 # seconds

var _accel_input: float = 0.0
var _brake_input: float = 0.0
var _steer_input: float = 0.0
var _handbrake: bool = false
var _use_nitro: bool = false
var _nitro_remaining: float

var respawn_transform: Transform3D

func _ready() -> void:
    mass = weight
    _nitro_remaining = nitro_capacity
    respawn_transform = global_transform
    add_to_group("player_car")

func set_input(accel: float, brake: float, steer: float, handbrake: bool, nitro: bool) -> void:
    _accel_input = clamp(accel, 0.0, 1.0)
    _brake_input = clamp(brake, 0.0, 1.0)
    _steer_input = clamp(steer, -1.0, 1.0)
    _handbrake = handbrake
    _use_nitro = nitro and _nitro_remaining > 0.0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    # Called each physics frame to apply forces
    var forward: Vector3 = -global_transform.basis.z.normalized()
    var right: Vector3 = global_transform.basis.x.normalized()
    var current_velocity: Vector3 = state.get_linear_velocity()
    var speed_kmh: float = current_velocity.length() * 3.6

    # Throttle/brake
    var engine_force: Vector3 = Vector3.ZERO
    if _accel_input > 0.01:
        if speed_kmh < max_speed_kmh or _use_nitro:
            var applied = acceleration_force * _accel_input
            if _use_nitro:
                applied += nitro_boost
                _nitro_remaining = max(_nitro_remaining - state.get_step(), 0.0)
            engine_force = forward * applied
            state.apply_central_force(engine_force)
    elif _brake_input > 0.01:
        # Apply braking as negative forward force
        var brake_f = brake_force * _brake_input
        state.apply_central_force(-forward * brake_f)
        # also increase linear damp to simulate skidding
        state.set_linear_damp(4.0)
    else:
        # Natural rolling resistance
        state.set_linear_damp(0.2)

    # Steering
    if abs(_steer_input) > 0.01:
        # torque around up axis to turn
        var turn = _steer_input * steer_torque
        state.apply_torque_impulse(Vector3.UP * turn * state.get_step())

    # Downforce proportional to speed
    var down = downforce * current_velocity.length()
    state.apply_central_force(Vector3.DOWN * down)

    # Simple grip / lateral force reduction (drift)
    var lateral_speed = current_velocity.dot(right)
    var lateral_impulse = -lateral_speed * (1.0 - (drift_factor if _handbrake else grip)) * mass
    state.apply_central_force(right * lateral_impulse)

    # Limit max speed (simple clamp)
    var vel = state.get_linear_velocity()
    var vel_kmh = vel.length() * 3.6
    if vel_kmh > max_speed_kmh and not _use_nitro:
        var scale = (max_speed_kmh / vel_kmh)
        state.set_linear_velocity(vel * scale)

func get_speed_kmh() -> float:
    return linear_velocity.length() * 3.6

func respawn() -> void:
    global_transform = respawn_transform
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO

func recharge_nitro(amount: float) -> void:
    _nitro_remaining = clamp(_nitro_remaining + amount, 0.0, nitro_capacity)

func get_nitro_remaining() -> float:
    return _nitro_remaining
