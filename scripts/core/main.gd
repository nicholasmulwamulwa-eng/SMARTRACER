extends Node3D

@export var debug_mode: bool = true

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    if debug_mode:
        print("[AFRICA RUSH] Main scene ready")
