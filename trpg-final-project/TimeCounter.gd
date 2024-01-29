extends Label

export var max_time = 120;
var current_time = 0;

func ready():
	text = str(max_time - current_time)

func _on_Timer_timeout():
	current_time += 1;
	text = str(max_time - current_time)
	if current_time == max_time:
		get_tree().change_scene("res://EndGame.tscn")
