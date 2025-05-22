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
	print("Loading weapon mesh: ", WEP_TYPE.mesh)
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
var minRecoil
var maxRecoil
var recoilDebt = 0

#variables inferred from the resource
var chambering 
var maxCapacity 
var totalMaxRecoil
var totalMinRecoil
var recoveryAmount
var recoilAmount

var debtCutoff = 10 #at what point do we just apply the recoil debt flat out?
var recoveryCutoff #at what point do we increase our recoil recovery?

func init_stats():
	#grab all our variables
	maxCapacity = WEP_TYPE.maxCapacity
	chambering = WEP_TYPE.chambering
	totalMinRecoil = WEP_TYPE.minRecoil
	totalMaxRecoil = WEP_TYPE.maxRecoil
	recoveryAmount = WEP_TYPE.recoverAmount
	recoilAmount = WEP_TYPE.recoilAmount
	
	
	#initialize stats
	capacity = maxCapacity
	reloading = false
	maxRecoil = totalMaxRecoil
	minRecoil = totalMinRecoil
	currentRecoil = minRecoil
	
	our_reticle.adjust_spread(minRecoil)

func tryShoot():
	if(capacity > 0):
		recoilDebt += recoilAmount #experimental, 
		
		calcRecoil()
		
		print("Pew! Recoil: ", currentRecoil)
		our_reticle.adjust_spread(currentRecoil)
		
		capacity-=1
	
	else:
		print("click!")
	
func _process(delta: float): 
	
	calcRecoil() #apply any "debt" we've acculmulated
	
	#we SHOULD be using delta here buuuuuut nahhhhhhhhhh
	#i lied the real reason is I don't trust float imprecision
	if(currentRecoil > minRecoil):
		currentRecoil = currentRecoil - recoveryAmount 
		if(currentRecoil < minRecoil):
			currentRecoil = minRecoil
		our_reticle.adjust_spread(currentRecoil)
		
func calcRecoil():
	if(recoilDebt < debtCutoff): #debtcutoff is a constant equal to 10
		currentRecoil += recoilDebt
		recoilDebt = 0
	else:
		currentRecoil += (0.5 * recoilDebt)
		recoilDebt -= (0.5 * recoilDebt)
		
	if(currentRecoil > maxRecoil):
		currentRecoil = maxRecoil

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
