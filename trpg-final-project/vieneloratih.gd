extends ProgressBar

func _on_Timer_timeout():
	value -= 3.3
	if value == 0:
		get_tree().change_scene("res://EndGame.tscn")
