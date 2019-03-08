extends Sprite

onready var rigidBod = $RigidBody2D


func _physics_process(delta):
	rigidBod.add_force(Vector2(5,5),Vector2(5,5))