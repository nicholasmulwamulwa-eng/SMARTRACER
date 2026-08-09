extends Area3D

@export var index: int = 0

func _ready() -> void:
    # identify as a track checkpoint
    add_to_group("track_checkpoint")
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
    # Accept RigidBody3D cars via groups
    if not (body is RigidBody3D):
        return
    if not (body.is_in_group("player_car") or body.is_in_group("ai_car")):
        return
    var scene = get_tree().get_current_scene()
    if scene and scene.has_node("LapManager"):
        var lm = scene.get_node("LapManager")
        if lm and lm.has_method("checkpoint_passed"):
            lm.checkpoint_passed(body, index)
