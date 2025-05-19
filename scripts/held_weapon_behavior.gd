extends Node3D

@export var WEP_TYPE: Wep
@onready var weapon_mesh: MeshInstance3D = $weapModel

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
var capacity
var reloading 
var chambering 
var maxCapacity 

func init_stats():
	maxCapacity = WEP_TYPE.maxCapacity
	capacity = maxCapacity
	reloading = false
	chambering = WEP_TYPE.chambering

func tryShoot():
	if(capacity > 0):
		print("pew!!!!")
		capacity-=1
	else:
		print("click!")

func startReload():
	if(!reloading):
		print("Starting reload!")
		reloading = true
		reloadtimer.start();

func _on_reload_timer_timeout() -> void:
	reloading = false
	var ammoPool = manager.getAmmoAmt(chambering)
	var takenAmount = 0;
	takenAmount += (maxCapacity - capacity)
		
	if(capacity > 0):
		takenAmount+=1

	var newCap = manager.withdrawAmmo(chambering, takenAmount)
	
	capacity += newCap
	print("Finished reload! Rounds: ", capacity)
