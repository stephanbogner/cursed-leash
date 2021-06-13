extends Node2D

var change_leash_color = false
var RopePiece = preload("res://RopePiece.tscn")
var piece_length := 3
var rope_parts := []
var rope_close_tolerance := 4.0
var rope_points : PoolVector2Array = []

onready var rope_start_piece = $RopeStartPiece
onready var rope_end_piece = $RopeEndPiece
onready var rope_start_joint = $RopeStartPiece/C/J
onready var rope_end_joint = $RopeEndPiece/C/J

func _process(_delta):
	get_rope_points()
	if !rope_points.empty():
		update()

func spawn(object1:Object, object2:Object):
	rope_start_piece.global_position = object1.get_node("C/J").global_position
	rope_end_piece.global_position = object2.get_node("C/J").global_position
	var start_pos = rope_start_joint.global_position
	var end_pos = rope_end_joint.global_position

	var distance = start_pos.distance_to(end_pos)
	var pieces_amount = round(distance/piece_length)
	var spawn_angle = (end_pos - start_pos).angle() - PI/2
	
	object1.get_node("C/J").node_b = rope_start_piece.get_path()
	object2.get_node("C/J").node_b = rope_end_piece.get_path()
	create(pieces_amount, rope_start_piece, end_pos, spawn_angle)

func pull():
	for i in rope_parts.size():
		var r = rope_parts[i]
		var radians = r.get_rotation() - PI / 2
		var direction = Vector2(cos(radians), sin(radians))
		r.set_linear_velocity(direction * 40 * i)

func chaos():
	for i in rope_parts.size():
		var iHalfNegative = i - rope_parts.size()/2
		var r = rope_parts[i]
		var radians = r.get_rotation() + PI / 2 + PI / 20
		var direction = Vector2(cos(radians), sin(radians))
		r.set_linear_velocity(direction * 70 * iHalfNegative)

#func shorten(amount:int):
#	for i in amount:
#		if rope_parts.size() < 4:
#			break
#		var rope_piece_to_remove = rope_parts.pop_front()
#		#rope_parts[i].scale.y = 0.1
#		#rope_parts[i].scale.x = 4
#		#rope_parts[i].get_node("C/J").position.y = 0.1
#		rope_piece_to_remove.free()
#	#rope_start_joint.set_softness(1)
#	rope_start_joint.node_b = rope_parts[0].get_path()
#	#rope_parts[0].global_position = rope_start_piece.global_position
#	#rope_start_joint.set_softness(1)

func create(pieces_amount:int, parent:Object, end_pos:Vector2, spawn_angle:float) -> void:
	for i in pieces_amount:
		parent = add_piece(parent, i, spawn_angle)
		parent.set_name("rope_piece_" + str(i))
		rope_parts.append(parent)
		
		var joint_pos = parent.get_node("C/J").global_position
		if joint_pos.distance_to(end_pos) < rope_close_tolerance:
			break

	rope_end_joint.node_b = rope_parts[-1].get_path()

func add_piece(parent:Object, id:int, spawn_angle:float) -> Object:
	var joint: PinJoint2D = parent.get_node("C/J") as PinJoint2D
	var piece: Object = RopePiece.instance() as Object
	piece.global_position = joint.global_position
	piece.rotation = spawn_angle
	piece.parent = self
	piece.id = id
	add_child(piece)
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	return piece

func get_rope_points() -> void:
	rope_points = []
	rope_points.append(rope_start_joint.global_position)
	for r in rope_parts:
		rope_points.append(r.global_position)
	rope_points.append(rope_end_joint.global_position)

func _on_TestStage_invert_screen_signal(boolean):
	print("changed now")
	change_leash_color = boolean

func _draw():
	if change_leash_color == true:
		draw_polyline(rope_points, Color(201, 0, 181, 0.001), 12.0)
		draw_polyline(rope_points, Color("#830176"), 4.0)
	else:
		draw_polyline(rope_points, Color("#3D0037"), 4.0)
