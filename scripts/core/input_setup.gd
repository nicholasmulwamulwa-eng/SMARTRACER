extends Node

# InputSetup - ensures required InputMap actions exist for testing in editor

func _ready() -> void:
    _ensure_action("accelerate", [KEY_W, KEY_UP])
    _ensure_action("brake", [KEY_S, KEY_DOWN])
    _ensure_action("steer_left", [KEY_A, KEY_LEFT])
    _ensure_action("steer_right", [KEY_D, KEY_RIGHT])
    _ensure_action("handbrake", [KEY_SPACE])
    _ensure_action("nitro", [KEY_SHIFT])
    _ensure_action("pause", [KEY_ESCAPE])

func _ensure_action(name: String, keys: Array) -> void:
    if not InputMap.has_action(name):
        InputMap.add_action(name)
    for k in keys:
        var ei = InputEventKey.new()
        ei.physical_scancode = 0
        ei.scancode = k
        InputMap.action_add_event(name, ei)
