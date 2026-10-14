extends CharacterBody2D


enum State {ROAMING, CHASING, SEARCHING, FLASHED}

const Roam_Speed = 80.0
const CHASE_SPEED = 125.0
const Arrive_Distance = 4.0
const FLASH_DURATION = 3.0
const LOSE_SIGHT_TIME = 5.0
const CRUMB_SPACING = 8.0

@export var waypoints_parent: Node2D
@export var wait_time: float = 1.5

@onready var line_of_sight: Area2D = $Line_Of_Sight

var state: State = State.ROAMING
var waypoints: Array[Vector2] = []
var waypoint_index: int = 0
var wait_left: float = 0.0
var flash_left: float = 0.0
var lose_sight_left: float = 0.0
var player: Node2D = null
var player_in_vision := false
var facing_dir := Vector2.DOWN
var trail: Array[Vector2] = []


func _ready() -> void:
	if waypoints_parent:
		for child in waypoints_parent.get_children():
			if child is Marker2D:
				waypoints.append(child.global_position)

func _physics_process(delta: float) -> void:
	match state:
		State.ROAMING:
			roam(delta)
			if can_see_player():
				start_chase()
		State.CHASING:
			chase(delta)
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

	if dir != Vector2.ZERO:
		facing_dir = dir
		line_of_sight.rotation = facing_dir.angle() - Vector2.DOWN.angle()

	velocity = dir * speed
	move_and_slide()


func flashed(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	record_crumb()   # keep tracking the player while frozen
	flash_left -= delta
	if flash_left <= 0.0:
		state = State.CHASING
		lose_sight_left = LOSE_SIGHT_TIME

func get_flashed() -> void:
	if state == State.ROAMING:
		trail.clear()
	state = State.FLASHED
	flash_left = FLASH_DURATION

func _on_flash_area_area_entered(area: Area2D) -> void:
	if area.name == "CameraFlash":
		get_flashed()



func _on_line_of_sight_body_entered(body: Node2D) -> void:
	print("vision entered by: ", body.name, " in group player: ", body.is_in_group("Player"))
	if body.is_in_group("Player"):
		player = body
		player_in_vision = true

func _on_line_of_sight_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_vision = false

func can_see_player() -> bool:
	return player != null and player_in_vision and not player.is_hiding

func start_chase() -> void:
	state = State.CHASING
	lose_sight_left = LOSE_SIGHT_TIME
	trail.clear()

func record_crumb() -> void:
	if player == null or player.is_hiding:
		return
	if trail.is_empty() or trail.back().distance_to(player.global_position) > CRUMB_SPACING:
		trail.append(player.global_position)

func chase(delta: float) -> void:
	if can_see_player():
		lose_sight_left = LOSE_SIGHT_TIME
	else:
		lose_sight_left -= delta
		if lose_sight_left <= 0.0:
			end_chase()
			return

	record_crumb()

	while not trail.is_empty() and global_position.distance_to(trail[0]) <= Arrive_Distance * 1.5:
		trail.pop_front()

	if trail.is_empty():
		if can_see_player():
			move_toward_target(player.global_position, CHASE_SPEED)
		else:
			velocity = Vector2.ZERO
			move_and_slide()
		return

	move_toward_target(trail[0], CHASE_SPEED)


func end_chase() -> void:
	print("chase ended")
	trail.clear()
	state = State.ROAMING
	waypoint_index = closest_waypoint_index()
	wait_left = 0.0

func closest_waypoint_index() -> int:
	var best := 0
	var best_dist := INF
	for i in waypoints.size():
		var d := global_position.distance_squared_to(waypoints[i])
		if d < best_dist:
			best_dist = d
			best = i
	return best

func player_used_door(door: Area2D) -> void:
	if state == State.CHASING:
		trail.clear()
		trail.append(door.global_position)

func warped() -> void:
	if not trail.is_empty():
		trail.pop_front()
