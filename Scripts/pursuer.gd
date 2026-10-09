extends CharacterBody2D


enum State {ROAMING, CHASING, SEARCHING, FLASHED}

var Roam_Speed = 60.0
const Arrive_Distance = 4.0

@export var waypoints_parent: Node2D
@export var wait_time: float = 1.5

var state: State = State.ROAMING
var waypoints: Array[Vector2] = []
var waypoint_index: int = 0
var wait_left: float = 0.0
const FLASH_DURATION = 3.0
var flash_left: float = 0.0

func _ready() -> void:
	if waypoints_parent:
		for child in waypoints_parent.get_children():
			if child is Marker2D:
				waypoints.append(child.global_position)
	print("waypoints found: ", waypoints.size(), " parent: ", waypoints_parent)

func _physics_process(delta: float) -> void:
	match state:
		State.ROAMING:
			roam(delta)
		State.FLASHED:
			flashed(delta)

func roam(delta: float) -> void:
	if waypoints.is_empty():
		return
	
	if wait_left > 0.0:
		wait_left -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var target := waypoints[waypoint_index]

	if global_position.distance_to(target) <= Arrive_Distance * 1.5:
		waypoint_index = (waypoint_index + 1) % waypoints.size()
		wait_left = wait_time
		return

	move_toward_target(target, Roam_Speed)

func move_toward_target(target: Vector2, speed: float) -> void:
	var diff := target - global_position
	var dir := Vector2.ZERO

	if abs(diff.x) > Arrive_Distance:
		dir.x = sign(diff.x)
	elif abs(diff.y) > Arrive_Distance:
		dir.y = sign(diff.y)

	velocity = dir * speed
	move_and_slide()

func flashed(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	flash_left -= delta
	if flash_left <= 0.0:
		state = State.ROAMING

func get_flashed() -> void:
	state = State.FLASHED
	flash_left = FLASH_DURATION
	print("Was flashed!")

func _on_flash_area_area_entered(area: Area2D) -> void:
	if area.name == "CameraFlash":
		get_flashed()
