class_name WEAPON_PARENT extends Resource
@export_category("Weapon Information")
@export var wepName  : StringName = "Weapon parent name!"
@export var wepDesc  : StringName = "Uh oh! You shouldn't see this! Please dial 1-800-imcoder!"
@export var isFirearm: bool = false ##determines behavior patterns
@export var mesh: Mesh ##Primary model of the weapon
@export var secondMesh: Mesh ##Secondary model. Sheathe or magazine.
@export var damage: int = 1 
@export var selection : int = 4 ##Currently unused, will be for switching
@export var position : Vector3 = Vector3(0, -0.3, -0.3) ##Offset from camera center in L/R, U/D, F/B
@export var rotation : Vector3 = Vector3(90, 90, 0) 
@export var scale : Vector3 = Vector3.ONE ##In case model is incorrectly sized
