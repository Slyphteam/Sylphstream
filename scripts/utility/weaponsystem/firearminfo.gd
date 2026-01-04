class_name FIREARM_INFO extends WEAP_INFO
#This is the template class used for firearms.
@export_category("Weapon Information")
#@export var wepName = "Default firearm!"
@export_category("Technical Variables")
@export var gunshot : AudioStreamMP3 
@export var reload : AudioStreamMP3 

@export_category("Behavioral variables")
@export var shotCooldown: int = 10 ##in frames, determine firerate
@export var chambering : int = 1 ## 1- Pistol; 2- Light rifle (5.56); 3- Heavy rifle (30 caliber); 4- Shotgun; 5- Plinking (.22 lr); 6- Magnum
@export var maxCapacity : int = 5
@export var reloadtime : float = 1 ##In seconds
@export var aimBonus: float = 5 ##the amount by which ADS boons the aimcone. Should NEVER be greater than minRecoil
@export var maxRecoil : float = 50 ##Maximum pixels of offset under recoil
@export var minRecoil : float = 10 ##Default pixels of offset
@export var recoilAmount: float = 10 ##pixels of recoil per shot. Also affects camera offset. 10 is barely any
@export var viewpunchMult: float = 1 ##Multiplier on viewpunch
@export var recoverAmount: float = 0.5 ##In pixels per frame. Feels best between 1 and 0.25
@export var doCasing: bool = false ##Create casings when gun is fired
@export var casingPath: String = ""
@export var ejectOnReload: bool = false ##Eject when we reload or immediately after firing?
@export var casingDelay: float = 0.5 ##in seconds
@export_category("Script override")
@export var singleReloadOverride: bool = false ##Override script to use SHOTGUNINSTANCE, primarily changes reload behavior
@export var pelletAMT: int = 12 ##How many bullets in a volley?
@export var burstMode: bool = false ##Do we fire in bursts, requiring a trigger reset after each?
@export var burstAMT: int = 3
