extends Node3D

# WaypointPath - holds ordered Marker3D children as waypoints

func get_count() -> int:
    return get_child_count()

func get_point(idx: int) -> Vector3:
    if idx < 0 or idx >= get_child_count():
        return Vector3.ZERO
    return get_child(idx).global_transform.origin

func get_closest_index(pos: Vector3) -> int:
    var best = -1
    var best_d = 1e30
    for i in range(get_child_count()):
        var d = get_child(i).global_transform.origin.distance_to(pos)
        if d < best_d:
            best_d = d
            best = i
    return best
