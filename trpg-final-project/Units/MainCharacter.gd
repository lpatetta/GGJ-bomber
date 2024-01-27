extends Unit

onready var _changing_skin_timer: Timer = $Timer
var _is_changing_skin = false;
var _current_skin = 0;

export (Array, AnimatedTexture) var skins

func _ready():
	._ready();
	
	if skins:
		set_skin(skins[_current_skin])

func _unhandled_input(event: InputEvent) -> void:
	if _is_changing_skin and event.is_action_released("activate"):
		_set_next_skin();

func _set_next_skin():
	_is_changing_skin = false;
	_changing_skin_timer.start();
	_current_skin+=1;
	if (_current_skin >= skins.size() ):
		_current_skin = 0;
		
	set_skin( skins[_current_skin])

func _on_Timer_timeout():
	_is_changing_skin = true;
	
	
func set_skins(value: Array) -> void:
	skin = value[0]
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value[0]
