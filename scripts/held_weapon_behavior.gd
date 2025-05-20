# this is THE script that drives weapon behavior and loads weapon models/stats
#into a game instance. It answers directly to the invenmanager script.

extends Node3D

@export var WEP_TYPE: Wep
@onready var weapon_mesh: MeshInstance3D = $weapModel
@onready var our_reticle: CenterContainer = $"../../../Control/CenterContainer"

#Resource loading code:
func _ready() -> void:
	load_weapon()
	init_stats()

func load_weapon():
	print("hi!")
	print("Loading mesh: ", WEP_TYPE.mesh)
	weapon_mesh.mesh = WEP_TYPE.mesh
	
	position = WEP_TYPE.position
	rotation_degrees = WEP_TYPE.rotation
	scale = WEP_TYPE.scale

#weapon behavior code
@onready var reloadtimer = $reloadTimer
@onready var manager = $".."
#Variables we calculate with
var capacity
var reloading 
var currentRecoil: float = 0

#variables inferred from the resource
var chambering 
var maxCapacity 
var minRecoil
var maxRecoil
var recoveryAmount
var recoilAmount

func init_stats():
	#grap all our variables
	maxCapacity = WEP_TYPE.maxCapacity
	chambering = WEP_TYPE.chambering
	minRecoil = WEP_TYPE.minRecoil
	maxRecoil = WEP_TYPE.maxRecoil
	recoveryAmount = WEP_TYPE.recoverAmount
	recoilAmount = WEP_TYPE.recoilAmount
	
	print("recovery amount", recoveryAmount)
	
	our_reticle.adjust_spread(minRecoil)
	
	#initialize stats
	capacity = maxCapacity
	reloading = false
	currentRecoil = minRecoil

func tryShoot():
	if(capacity > 0):
		currentRecoil += recoilAmount
		if(currentRecoil > maxRecoil):
			currentRecoil = maxRecoil
		
		print("Pew! Recoil: ", currentRecoil)
		our_reticle.adjust_spread(currentRecoil)
		
		capacity-=1
	else:
		print("click!")
	
func _process(delta: float): 
	
	#we SHOULD be using delta here buuuuuut nahhhhhhhhhhh
	if(currentRecoil > minRecoil):
		#i lied the actual reason is because I don't trust floating imprecision to not fuck things up
		currentRecoil = currentRecoil - recoveryAmount 
		if(currentRecoil < minRecoil):
			currentRecoil = minRecoil
		our_reticle.adjust_spread(currentRecoil)

func startReload():
	if(!reloading):
		print("Starting reload!")
		reloading = true
		reloadtimer.start();

func _on_reload_timer_timeout() -> void:
	reloading = false
	var takenAmount = 0;
	takenAmount += (maxCapacity - capacity)
		
	if(capacity > 0):
		takenAmount+=1

	var newCap = manager.withdrawAmmo(chambering, takenAmount)
	
	capacity += newCap
	print("Finished reload! Rounds: ", capacity)
