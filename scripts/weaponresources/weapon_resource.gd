class_name Wep extends Resource
#This is the template class used for firearms.
@export_category("Weapon Information")
@export var wepName  : StringName
@export var selection : int
@export var mesh: Mesh
@export var position : Vector3
@export var rotation : Vector3
@export var scale : Vector3
#@export var scalar : float
#@onready var manager = $".."
@export_category("Variables")
@export var chambering : int
@export var maxCapacity : int
@export var capacity : int
@export var reloadtime : float
#@export var reloading : bool
@export var maxRecoil : float #maximum pixels of offset
@export var minRecoil : float #absolute minimum pixels of offset
@export var recoilAmount: float #pixels of recoil per shot.
@export var recoverAmount: float #pixels per second. Feels best between 1 and 0.25
