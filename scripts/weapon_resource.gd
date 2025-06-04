class_name Wep extends Resource
#This is the template class used for firearms.
@export_category("Weapon Information")
@export var wepName  : StringName = "Debug weapon name!"
@export var wepDesc  : StringName = "Uh oh! You shouldn't see this! Please dial 1-800-imcoder!"
@export var selection : int = 4
@export_category("Technical Variables")
@export var mesh: Mesh
@export var gunshot : AudioStreamMP3 
@export var reload : AudioStreamMP3 
@export var position : Vector3 = Vector3(0, -0.3, -0.3)
@export var rotation : Vector3 = Vector3(90, 90, 0)
@export var scale : Vector3 = Vector3.ONE
@export_category("Behavioral variables")
@export var chambering : int = 1 ## 1- Pistol; 2- Light rifle (5.56); 3- Heavy rifle (30 caliber); 4- Shotgun; 5- Plinking (.22 lr); 6- Magnum
@export var damage: int = 1
@export var maxCapacity : int = 5
@export var reloadtime : float = 1 ##In seconds
@export var aimBonus: float = 5 ##the amount by which ADS boons the aimcone. Should NEVER be greater than minRecoil
@export var maxRecoil : float = 50 ##Maximum pixels of offset under recoil
@export var minRecoil : float = 10 ##Default pixels of offset
@export var recoilAmount: float = 10 ##pixels of recoil per shot. Also affects camera offset. 10 is barely any
@export var recoverAmount: float = 0.5 ##In pixels per frame. Feels best between 1 and 0.25
