extends Node3D

# TrackTest Runner - instantiates the test track, player car and AI cars, and starts the RaceManager countdown
# Uses actual project architecture and avoids fragile NodePath computations.

@export var track_scene: PackedScene = preload("res://scenes/tracks/Track_NairobiCircuit.tscn")
@export var player_car_scene: PackedScene = preload("res://scenes/cars/PlayerCar.tscn")
@export var ai_car_scene: PackedScene = preload("res://scenes/cars/PlayerCar.tscn")

func _ready() -> void:
    # Instance track
    var track_inst = track_scene.instantiate()
    add_child(track_inst)
    # Ensure LapManager exists
    if not track_inst.has_node("LapManager"):
        push_error("Track instance missing LapManager node")
    # Spawn player car at StartGrid
    var player: Node = null
    if track_inst.has_node("StartGrid"):
        var start = track_inst.get_node("StartGrid")
        player = player_car_scene.instantiate()
        # Mark as player (set before add_child so _ready reads the property)
        if player.has_method("set"):
            player.set("is_player", true)
        add_child(player)
        player.global_transform = start.global_transform
    else:
        push_error("StartGrid not found in track")
    # Spawn two AI cars at respawn points (or near start)
    var respawns := []
    if track_inst.has_node("RespawnPoints"):
        var rpnode = track_inst.get_node("RespawnPoints")
        for i in range(rpnode.get_child_count()):
            respawns.append(rpnode.get_child(i))
    var ai_count = 2
    for i in range(ai_count):
        var ai_car = ai_car_scene.instantiate()
        # mark as AI (set before add_child so _ready reads it)
        if ai_car.has_method("set"):
            ai_car.set("is_player", false)
        add_child(ai_car)
        if respawns.size() > i:
            ai_car.global_transform = respawns[i].global_transform
        elif player:
            ai_car.global_transform = player.global_transform.translated(Vector3(0,0, -5 * (i+1)))
        # Add AI driver script (Script.new()) and set direct references
        var ai_driver = preload("res://scripts/ai/simple_ai_driver.gd").new()
        add_child(ai_driver)
        # Directly provide node references to avoid fragile path resolution
        ai_driver.set_car_node(ai_car)
        if track_inst.has_node("Waypoints"):
            ai_driver.set_waypoints_node(track_inst.get_node("Waypoints"))
    # Register player and AI cars with RaceManager explicitly (deterministic)
    var rm = get_node_or_null("/root/RaceManager")
    if rm:
        if player:
            rm.register_car(player)
        var ai_nodes = get_tree().get_nodes_in_group("ai_car")
        for node in ai_nodes:
            rm.register_car(node)
    else:
        push_error("RaceManager autoload not found; cannot start countdown")
    # Start countdown via RaceManager autoload
    if rm and rm.has_method("start_countdown"):
        rm.start_countdown(3)
