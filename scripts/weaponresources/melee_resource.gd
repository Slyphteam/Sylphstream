class_name Mel extends Resource
#This is the template class used for firearms.
@export_category("Weapon Information")
@export var wepName  : StringName = "Debug melee name!"
@export var wepDesc  : StringName = "Uh oh! You shouldn't see this! Please dial 1-800-imcoder!"
@export var mesh: Mesh
@export var sheathMesh: Mesh
@export var position : Vector3 = Vector3(0, -0.3, -0.3)
@export var rotation : Vector3 = Vector3(90, 90, 0)
@export var scale : Vector3 = Vector3.ONE
@export_category("Variables")
@export var damage : int = 10
@export var variance: float = 0.2
@export var reach : float = 2
@export var speed : int = 80
@export_category("Behaviors")
@export var canThrust : bool = true
@export var canParry : bool = true
@export var effectiveParry : bool = true 
