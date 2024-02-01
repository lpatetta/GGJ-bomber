class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

export var grid: Resource
export (Array, Color) var color_ids;

var _units := {}
var _active_unit: MainCharacter;
var _walkable_cells := []
var _interacted_npc:Unit;
var _interacted_npc_cell: Vector2;

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath

var is_walking = false;
var skin_id:int;
var is_busy = false;

func _ready() -> void:
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, resolution_list[current_res_index])
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:		
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false


func get_walkable_cells(unit: Unit) -> Array:
	return _get_walkables(unit.cell, unit.move_range);

func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		#var unit := child as Unit
		if "is_npc" in child and child.is_npc:
			_units[child.cell] = child
			
			child.set_color( color_ids[child.color_id ] );
		
	_active_unit = $Player
	_active_unit.color_ids = color_ids;
	_select_unit(_active_unit.cell) #reselect main unit

func _get_walkables(cell: Vector2, max_distance: int)-> Array:
	var array := _unit_overlay.get_used_cells_by_id(0);
		
	# FALTA AGREGAR PERSONAJES AL ARRAY
	for u in _units:
		if u in array:
			#array.remove( array.find(u) )
			print()
	
	var stack := [cell]
	while not stack.empty():
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		#if distance > max_distance:
		#	continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				
				continue
			if coordinates in array:
				continue

			stack.append(coordinates)
	
	return array

func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.empty():
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		#if distance > max_distance:
		#	continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue

			stack.append(coordinates)
	return array
	
		
func _move_main_character(new_cell:Vector2)->void:
	if $Camera/VideoPlayer/PanelContainer.is_playing:
		return
	
	_active_unit.walk_along(_unit_path.current_path)
	is_walking = true;
	yield(_active_unit, "walk_finished")
	
	_unit_path.draw(_active_unit.cell, _active_unit.cell);
	_select_unit(_active_unit.cell) #reselect main unit
	is_walking = false;
	if _interacted_npc:
		if _interacted_npc.is_reacting or is_busy:
			return
		else:
			is_busy = true;
			_active_unit.trigger_talk();
			
			var pauseposition = $AudioStreamPlayer.get_playback_position();
			$AudioStreamPlayer.stop();
			
			$Camera/VideoPlayer/PanelContainer._show_video();
			yield($Camera/VideoPlayer/PanelContainer, "video_finished")
			
			$Camera.target_node = _interacted_npc
			$Camera.is_zooming = true
		
			#null exceptions make me do unnecessary things...
			if _active_unit._current_skin:
				skin_id = _active_unit._current_skin
			else:
				skin_id = 0
			
			_interacted_npc.react( skin_id );
			yield(_interacted_npc, "talk_finished")
			
			if _interacted_npc.color_id == skin_id:
				_units.erase(_interacted_npc_cell)
			
			$Camera.target_node = _active_unit
			$Camera.is_zooming = false
			
			$AudioStreamPlayer.play();
			$AudioStreamPlayer.seek(pauseposition);
			
			is_busy = false;
			
		
		
	

func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
		
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	
	_active_unit.walk_along(_unit_path.current_path)
	is_walking = true;
	yield(_active_unit, "walk_finished")
	
	_select_unit(_active_unit.cell) #reselect main unit
	is_walking = false;
	if _interacted_npc:
		_interacted_npc.react( _active_unit._current_skin );
	


func _select_unit(cell: Vector2) -> void:
	
	#if not _units.has(cell):
	#	return
		
	#_active_unit = _units[cell]
			
	_active_unit.is_selected = true
	_walkable_cells = get_walkable_cells(_active_unit)
	#_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)
	
func _set_interacted_npc(cell:Vector2) -> void:
	if _units.has(cell):
		_interacted_npc = _units[cell]
		_interacted_npc_cell = cell
	else:
		_interacted_npc = null;


func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	#_unit_overlay.clear()
	_unit_path.stop()


func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if is_walking:
		return
		
	_set_interacted_npc(cell)
	_move_main_character(find_closest_walkable_cell(cell))


func _on_Cursor_moved(new_cell: Vector2) -> void:
	
	$Cursor._hide();
	
	if is_walking:
		return
		
	if _units.has(new_cell):
		$Cursor._show();
	
	if not new_cell in _unit_overlay.get_used_cells_by_id(0) :
		return
		
	if _active_unit and _active_unit.is_selected:
		var target_cell = find_closest_walkable_cell(new_cell)
		_unit_path.draw(_active_unit.cell, target_cell)


func find_closest_walkable_cell(cell: Vector2) -> Vector2:
	if not _units.has(cell):
		return cell

	var closest_cell := cell
	var min_distance := INF

	for direction in DIRECTIONS:
		var target: Vector2 = cell + direction
		if _units.has(target) and not _units[target] == _active_unit:
			continue

		var distance := target.distance_squared_to(_active_unit.cell)
		if distance < min_distance:
			min_distance = distance
			closest_cell = target

	return closest_cell


func _on_ChangeSkinButton_pressed():
	_active_unit._set_next_skin()
	
