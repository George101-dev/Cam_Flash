extends CharacterBody2D


enum State {ROAMING, CHASING, SEARCHING, FLASHED}

const Roam_Speed = 60.0
const Arrive_Distance = 4.0

@export var waypoint_parent: Node2D
@export var wait_time: float = 1.5

var state: State = State.ROAMING
var waypoints: Array[Vector2] = []
var waypoint_index: int = 0
var wait_left: float = 0.0
