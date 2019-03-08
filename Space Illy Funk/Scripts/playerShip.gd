extends KinematicBody2D

"""
To do:
	School myself on canvas items so I have a better gui system
	
donezo:
	make flashing proximity dash light
		I want the light to be solid when you're really close
	
	Need to fix accel so that it moves in the direction the ship is facing
		Need to work out the physics of the cans rigid body; spazzes out right now
	
	Cap the spin speed
"""

onready var bulletSpawnArea = $bulletSpawn
onready var bulletTimer = $bulletTime
onready var dashboard = $Camera2D/dashboard
onready var dashboardLight = $Camera2D/dashboard/dashboardLight
onready var dashboardLightTimer = $Camera2D/dashboard/dashboardLight/Timer
onready var camera = $Camera2D

var sigArea

var bulletScene = load("res://Scenes/spaceCan.tscn")

var vel = Vector2(0,0)
var rotDir = 0
var sigDist

var canShoot = true
var nearSignal = false

func _ready():
	dashboardLight.hide()


func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		vel = Vector2(0,-3).rotated(rotation)
	
	if Input.is_action_pressed("ui_right"):
		rotDir = clamp(rotDir + 1, 0, 20)
	elif Input.is_action_pressed("ui_left"):
		rotDir = clamp(rotDir - 1, -20, 0)
	else:
		rotDir = lerp(rotDir, 0, 0.05) #Spin speed cap
	
	if Input.is_action_pressed("ui_down"):
		vel = Vector2(lerp(vel.x, 0, 0.1),lerp(vel.y, 0, 0.1))
	
	#Radio Signal Dash Light
	if nearSignal:
		sigDist = global_position.distance_to(sigArea.global_position)
		
		#Changes speed of signal light flash
		if sigDist < 250:
			dashboardLightTimer.wait_time = 8888 #Cheap, but it works.//Actually it doensn't, timer won't change wait time until it finishes
			dashboardLight.show()
		elif sigDist < sigArea.closeRange:
			dashboardLightTimer.wait_time = 0.2
			if dashboardLightTimer.time_left > 1: #Okay, now THIS is the cheap fix for that ^ 
				dashboardLightTimer.start()
		elif sigDist < sigArea.midRange:
			dashboardLightTimer.wait_time = 0.4
		else: dashboardLightTimer.wait_time = 0.8
	
	print(dashboardLightTimer.time_left)
	
	#Shootin
	if Input.is_action_pressed("ui_accept") && canShoot:
		canShoot = false
		bulletTimer.start()
		
		var bullet = bulletScene.instance()
		get_parent().add_child(bullet)
		bullet.position.y = global_position.y + 50
		bullet.position.x = global_position.x
		bullet.set_scale(Vector2(1,1))
		print(bullet.rigidBod.angular_velocity)
	
	rotation += rotDir * 0.1 * delta
	
	#Fix Dashboard rotation
	dashboard.global_rotation = 0
	dashboard.global_position = camera.global_position
	
	move_and_collide(vel)


func _on_bulletTime_timeout():
	canShoot = true

func _on_shipArea_area_entered(area):
	if "Signal" in area.name:
		nearSignal = true
		sigArea = area
		if dashboardLightTimer.is_stopped():
			dashboardLight.show()
			dashboardLightTimer.start()
func _on_shipArea_area_exited(area):
	if "Signal" in area.name:
		nearSignal = false
		dashboardLight.hide()
		dashboardLightTimer.stop()
#Dashboard light timer
func _on_Timer_timeout():
	if nearSignal:
		if dashboardLight.visible: dashboardLight.hide()
		else: dashboardLight.show()
		
		dashboardLightTimer.start()
