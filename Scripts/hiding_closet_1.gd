extends AnimatableBody2D

var is_in_entrance_area: bool = false
var is_full: bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _process(delta: float) -> void:
	if is_in_entrance_area == true and Input.is_action_just_pressed("Interact") and is_full == false:
		animated_sprite_2d.play("Opening_Closing_Entering")
		await get_tree().create_timer(0.5).timeout
		animated_sprite_2d.play("Closed_Hiding")
		is_full = true
		
	elif Input.is_action_just_pressed("Interact") and is_full == true:
		animated_sprite_2d.play("Opening_Closing_Exiting")
		await get_tree().create_timer(0.5).timeout
		animated_sprite_2d.play("Closed_Empty")
		is_full = false
		
	

func _on_entrance_area_area_entered(area: Area2D) -> void:
	is_in_entrance_area = true


func _on_entrance_area_area_exited(area: Area2D) -> void:
	is_in_entrance_area = false
