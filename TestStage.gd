extends Node2D

var Rope = preload("res://Rope.tscn")
var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if start_pos == Vector2.ZERO:
			start_pos = get_global_mouse_position()
		else:
			end_pos = get_global_mouse_position()
			var rope = Rope.instance()
			add_child(rope)
			rope.spwan_rope(start_pos, end_pos)
			start_pos = Vector2.ZERO
			end_pos = Vector2.ZERO
