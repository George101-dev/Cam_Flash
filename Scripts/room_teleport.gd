extends Area2D

@export var destination: Area2D

var is_cooling_down : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player-Soléne" and not is_cooling_down and destination != null:
		print("Warping player safely...")
	
		destination.start_cooldown()
	
		body.global_position = destination.global_position
		
func start_cooldown() -> void:
	is_cooling_down = true
	await get_tree().create_timer(0.4).timeout
	is_cooling_down = false
