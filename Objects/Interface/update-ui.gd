extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var gamegrid: Resource
export var map_builder_tileset : TileSet
onready var unit_sprite = get_child(0).get_child(0)
onready var tilemap = get_parent().get_parent().get_node("Devtiles")
onready var rendered_tiles = get_parent().get_parent().get_node("RenderedTiles")
onready var property_tiles = get_parent().get_parent().get_node("PropertyTiles")
# Called when the node enters the scene tree for the first time.
func _ready():
	unit_sprite.set_texture(null)
	$TileMap.tile_set = map_builder_tileset


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Cursor_moved(new_coordinates):
	
	var grid_data = gamegrid.array[gamegrid.as_index(new_coordinates)]
	var tmp = gamegrid.get_unit(new_coordinates)
	
	var _sprite: Sprite = $"NinePatchRect/Unit sprite"
	var _tileSet: TileSet = tilemap.tile_set
	var tileId: int = grid_data.tileType
	# If tileset normal -> get normal
	$TileMap.set_cellv(Vector2(0,0), tileId)

	

	
	
	

	$NinePatchRect/VBoxContainer/text.text = String(gamegrid.get_terrain_bonus(grid_data))
	if gamegrid.has_property(new_coordinates):
		$NinePatchRect/VBoxContainer/property_sprite.visible = true
		var prop_sprite: Sprite = $NinePatchRect/VBoxContainer/property_sprite
		var prop_tileSet: TileSet = property_tiles.tile_set
		var prop_tileId: int = property_tiles.get_cellv(new_coordinates)
		prop_sprite.texture = prop_tileSet.tile_get_texture(prop_tileId)
		prop_sprite.region_rect = prop_tileSet.tile_get_region(prop_tileId)
		prop_sprite.region_enabled = true
		$NinePatchRect/VBoxContainer/Sprite2.visible = true
		$"NinePatchRect/VBoxContainer/Property Life".visible = true
		$TileMap.visible = false
		$"NinePatchRect/VBoxContainer/Property Life".text =  String(grid_data.property.health)
	else:
		$TileMap.visible = true
		$NinePatchRect/VBoxContainer/Sprite2.visible = false
		$NinePatchRect/VBoxContainer/property_sprite.visible = false
		$"NinePatchRect/VBoxContainer/Property Life".visible = false
	
	
	if tmp != null:
		unit_sprite.visible = true
		#print(tmp.health)
		var new_sprite = tmp.get_child(0).get_child(0)
		$"NinePatchRect/Unit sprite/Health text".text = String(ceil(tmp.health * 0.1))
		
		unit_sprite.set_texture(new_sprite.get_texture())
		unit_sprite.set_hframes(new_sprite.get_hframes())
		unit_sprite.set_frame(new_sprite.get_frame())
	else:
		unit_sprite.visible = false
