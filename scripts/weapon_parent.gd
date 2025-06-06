class_name WEAPON_PARENT extends Resource
@export_category("Weapon Information")
@export var wepName  : StringName = "Weapon parent name!"
@export var wepDesc  : StringName = "Uh oh! You shouldn't see this! Please dial 1-800-imcoder!"
@export var mesh: Mesh
@export var secondMesh: Mesh
@export var selection : int = 4
@export var weaponType: int = 0 # determines behavior patterns
@export var position : Vector3 = Vector3(0, -0.3, -0.3)
@export var rotation : Vector3 = Vector3(90, 90, 0)
@export var scale : Vector3 = Vector3.ONE
