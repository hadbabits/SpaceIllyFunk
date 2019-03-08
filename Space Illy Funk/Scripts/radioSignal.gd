extends Area2D

"""
To dos:
	Add a static sound that gets reduced as the player closer to the source
donezo:
	
"""

onready var sound1 = $sound1
onready var sound2 = $sound2

export var midRange = 1000 #Keeps track of where the signal light should pulse faster
export var closeRange = 500 #See above

var inArea = false

func _process(delta):
	if inArea && !sound1.playing:
		sound1.play()
		sound2.play()
	elif !inArea && sound1.playing:
		sound1.stop()
		sound2.stop()

func _on_soundArea_body_entered(body):
	if "player" in body.name:
		inArea = true
func _on_soundArea_body_exited(body):
	if "player" in body.name:
		inArea = false

# Radio Source Area, not the main bit
func _on_Area2D_body_entered(body):
	if "player" in body.name:
		queue_free()
