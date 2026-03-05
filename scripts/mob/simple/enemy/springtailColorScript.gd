extends Node3D
@onready var ourModel = self

func _ready() -> void:
	var ourMaterial = ourModel.get_active_material(0).duplicate()
	var colors = [Color.DARK_TURQUOISE, Color.DARK_ORCHID, Color.GREEN, Color.HOT_PINK, 
	Color.ORANGE_RED, Color.YELLOW, Color.CRIMSON, Color.RED, Color.MEDIUM_SEA_GREEN,
	Color.AQUA, Color.DODGER_BLUE, Color.TOMATO]
	ourMaterial.albedo_color = colors[randi_range(0, colors.size()-1 )]
	ourMaterial.albedo_color.a = 0.5
	ourModel.material_override = ourMaterial
