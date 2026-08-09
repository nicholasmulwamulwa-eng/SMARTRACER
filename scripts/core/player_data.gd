extends Node

# PlayerData autoload stub
# Stores player name, coins, unlocked cars, upgrades and settings

const SAVE_PATH := "user://player_save.cfg"
const SAVE_VERSION := 1

var data := {
    "version": SAVE_VERSION,
    "player_name": "Player",
    "coins": 0,
    "unlocked_cars": ["car_1"],
    "upgrades": {},
    "settings": {
        "music_volume": 0.8,
        "sfx_volume": 0.8,
        "engine_volume": 0.8,
        "graphics_quality": "medium",
        "steering_sensitivity": 1.0,
        "vibration": true
    }
}

func _ready() -> void:
    print("[PlayerData] Ready, loading save if present")
    load()

func save() -> void:
    var cfg := ConfigFile.new()
    for key in data.keys():
        cfg.set_value("player", key, data[key])
    var err = cfg.save(SAVE_PATH)
    if err != OK:
        push_error("Failed to save player data: %s" % str(err))

func load() -> void:
    var cfg := ConfigFile.new()
    var err = cfg.load(SAVE_PATH)
    if err == OK:
        for key in data.keys():
            if cfg.has_section_key("player", key):
                data[key] = cfg.get_value("player", key)
    else:
        print("[PlayerData] No save file found, using defaults")

func add_coins(amount: int) -> void:
    data.coins += amount
    save()

func unlock_car(car_id: String) -> void:
    if car_id in data.unlocked_cars:
        return
    data.unlocked_cars.append(car_id)
    save()
