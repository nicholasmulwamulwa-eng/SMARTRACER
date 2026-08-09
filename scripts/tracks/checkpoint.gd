extends Area3D

# Checkpoint: automatically determines its index from parent order if not explicitly set.
@export var index: int = -1

func _ready() -> void:
    add_to_group("track_checkpoint")
    connect("body_entered", Callable(self, "_on_body_entered"))
    # Auto-assign index from parent's children order when possible
    if index < 0 and get_parent():
        var siblings = get_parent().get_children()
        for i in range(siblings.size()):
            if siblings[i] == self:
                index = i
                break

func _on_body_entered(body: Node) -> void:
    if not (body is RigidBody3D):
        return
    if not (body.is_in_group("player_car") or body.is_in_group("ai_car")):
        return
    var scene = get_tree().get_current_scene()
    if scene and scene.has_node("LapManager"):
        var lm = scene.get_node("LapManager")
        if lm and lm.has_method("checkpoint_passed"):
            lm.checkpoint_passed(body, index)
