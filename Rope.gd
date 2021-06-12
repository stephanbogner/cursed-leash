extends Node2D

var RopePiece = preload("res://RopePiece.tscn")
var piece_length := 3
var rope_parts := []
var rope_close_tolerance := 4.0

onready var rope_start_piece = $RopeStartPiece
onready var rope_end_piece = $RopeEndPiece

func spawn(object1:Object, object2:Object):
	rope_start_piece.global_position = object1.get_node("C/J").global_position
	rope_end_piece.global_position = object2.get_node("C/J").global_position
	var start_pos = rope_start_piece.get_node("C/J").global_position
	var end_pos = rope_end_piece.get_node("C/J").global_position

	var distance = start_pos.distance_to(end_pos)
	var pieces_amount = round(distance/piece_length)
	var spawn_angle = (end_pos - start_pos).angle() - PI/2
	
	object1.get_node("C/J").node_b = rope_start_piece.get_path()
	object2.get_node("C/J").node_b = rope_end_piece.get_path()
	create(pieces_amount, rope_start_piece, end_pos, spawn_angle)

func create(pieces_amount:int, parent:Object, end_pos:Vector2, spawn_angle:float) -> void:
	for i in pieces_amount:
		print(i)
		parent = add_piece(parent, i, spawn_angle)
		parent.set_name("rope_piece_" + str(i))
		rope_parts.append(parent)
		
		var joint_pos = parent.get_node("C/J").global_position
		if joint_pos.distance_to(end_pos) < rope_close_tolerance:
			break
			
	rope_end_piece.get_node("C/J").node_a = rope_end_piece.get_path()
	rope_end_piece.get_node("C/J").node_b = rope_parts[-1].get_path()

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
