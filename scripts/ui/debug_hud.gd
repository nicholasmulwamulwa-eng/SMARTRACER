extends CanvasLayer

@onready var fps_label: Label = $VBox/FPSLabel
@onready var speed_label: Label = $VBox/SpeedLabel
@onready var lap_label: Label = $VBox/LapLabel

var _player: Node = null

func _ready() -> void:
    # Try to find a player in group 'player_car'
    var players = get_tree().get_nodes_in_group("player_car")
    if players.size() > 0:
        _player = players[0]

func _process(delta: float) -> void:
    fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
    if _player and _player.has_method("get_speed_kmh"):
        speed_label.text = "Speed: %d km/h" % int(_player.call("get_speed_kmh"))
    else:
        speed_label.text = "Speed: -"
    # Lap info placeholder
    lap_label.text = "Lap: - / -"
