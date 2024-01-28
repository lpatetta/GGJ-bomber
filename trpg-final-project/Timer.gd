extends Timer
#onready var vieneloratih = get_parent().get_node("vieneloratih")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var vieneloratih = get_parent().get_node(".")
	vieneloratih.value -= 5.0
	pass # Replace with function body.
