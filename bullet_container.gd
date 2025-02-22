extends Node2D

var bullet_scene = preload("res://bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# idk if this is bad code to have two of these functions
# umm yes this is kinda bad, but we can work on making classes if our game gets chosen -jalen
func _on_player_1_shoot_bullet(bullet: Transform2D, player_number : int) -> void:
	create_bullet(bullet, player_number)
func _on_player_2_shoot_bullet(bullet: Transform2D, player_number : int) -> void:
	create_bullet(bullet, player_number)

func create_bullet(bullet_pos: Transform2D, player_number : int) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.transform = bullet_pos
	bullet.player_number = player_number
	add_child(bullet)
