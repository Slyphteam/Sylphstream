##The parent resource object for all weapons. Do NOT use this; use one of the child classes instead.
class_name WEAP_INFO extends Resource
@export_category("Weapon Info")
@export var wepName  : StringName = "Weapon parent name!"
@export var wepDesc  : StringName = "Uh oh! You shouldn't see this! Please dial 1-800-imcoder!"
@export var mesh: Mesh ##Primary model of the weapon
@export_category("Basic Instance Data")
@export var secondMesh: Mesh ##Secondary model. Sheathe or magazine. Currently does nothing
@export var drawTime: float = 1 ##Draw time, in seconds. Currently does nothing
@export var drawSound: AudioStreamMP3 ##Draw sound. Currently also does nothing.
@export var damage: int = 1 
@export var selections : Array[int] = [3] ##Valid selection slots for the gun. the first will be the default.
@export var position : Vector3 = Vector3(0, -0.3, -0.3) ##Offset from camera center in L/R, U/D, F/B
@export var rotation : Vector3 = Vector3(90, 90, 0) ##In case the model is weird, custom held rotation
#@export var scale : Vector3 = Vector3.ONE ##In case model is incorrectly sized #NO MORE INCORRECTLY SIZED MODELS WE ACT PROFESSIONAL NOW
