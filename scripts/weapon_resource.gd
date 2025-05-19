class_name Wep extends Resource

@export_category("Weapon Information")
@export var wepName  : StringName
@export var selection : int
@export var mesh: Mesh
@export var position : Vector3
@export var rotation : Vector3
@export var scale : Vector3
#@onready var manager = $".."
@export_category("Variables")
@export var chambering : int
@export var maxCapacity : int
@export var capacity : int
@export var reloadtime : float
@export var reloading : bool
