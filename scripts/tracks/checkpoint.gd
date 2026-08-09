extends Area3D

# Checkpoint: automatically determines its index from parent order when possible.
@export var index: int = -1

var _checkpoint_list: Array = []

func _ready() -> void:
    add_to_group("track_checkpoint")
    connect("body_entered", Callable(self, "_on_body_entered"))
    # Build a deterministic list of checkpoint nodes (only Area3D nodes that use this script) in parent order
    if get_parent():
        var cp_script = get_script()
        for child in get_parent().get_children():
            if child is Area3D and child.get_script() == cp_script:
                _checkpoint_list.append(child)
        # assign index based on position in the filtered list
        for i in range(_checkpoint_list.size()):
            if _checkpoint_list[i] == self:
                index = i
                break
    if index < 0:
        index = 0

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
