extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var randomX = randi() % 3600 * 2 - 3600
	var randomY = randi() % 2100 * 2 - 2100
	print(randomX, randomY)
	self.set_global_position(Vector2(randomX, randomY))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
