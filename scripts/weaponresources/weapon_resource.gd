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
@export var chambering : int = 1
@export var maxCapacity : int = 5
#@export var capacity : int
@export var reloadtime : float = 1
#@export var reloading : bool
@export var aimBonus: float = 5 #the amount by which ADS boons the aimcone. Should NEVER be greater than minRecoil
@export var maxRecoil : float = 50 #maximum pixels of offset
@export var minRecoil : float = 10 #absolute minimum pixels of offset
@export var recoilAmount: float = 5 #pixels of recoil per shot.
@export var recoverAmount: float = 0.5 #pixels per second. Feels best between 1 and 0.25
