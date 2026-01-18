##Fairly trivial script that acts as a librarian for all the different UI elements. 
extends Control
@onready var ammoCounter = $Ammo



func _input(event):
	if(Input.is_action_just_pressed("ui_inven")):
		toggle_Inv()
	
	if Input.is_action_just_pressed("ui_reload"):
		quarterMaster.update_Inven_Data()


func toggle_Mouse():
	if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Globalscript.do_Panic_Exception("Tried to toggle mouse input from UI manager to weird third value?")

#func _ready():
#===---===}>    Pause stuff
@onready var pauseMenu = $pauseContainer
#IIRC we can't actually have the pause toggle from in this node
#because it'll never unpause, so everything is handled in the globalscript(?)


#===---===}>    dynamic reticle stuff

@onready var theReticle = $Reticle
@export var crosshairs : Array[Line2D]
@export var ourplayer : CharacterBody3D
@export var reticlespeed : float = 0.25
@export var reticledistance : float = 2

#for movement speed: lerp crosshairs[0].position, [0,0] + vector 2 of 0, -playerspeed  * reticledistance
##Resets the crosshair
func crosshair_Reset_Size():
	adjust_spread(0)

##adjust the spread of the crosshairs by a given amount. input MUST be an integer. Typically called every frame by guns.
func adjust_spread(amount):
	
	crosshairs[0].position = Vector2(0, -amount) 
	crosshairs[1].position = Vector2(0, amount)
	crosshairs[2].position = Vector2(-amount, 0)
	crosshairs[3].position = Vector2(amount, 0)

var healthAmDisabled:bool = false
var ammoEnabledBeforeToggle:bool = false

@onready var toolTitle = $Reticle/tooltips/toolTitle
@onready var toolDesc = $Reticle/tooltips/toolTitle/toolDesc
@onready var toolTip = $Reticle/tooltips/toolTitle/toolTip
func doTooltipText(title:String, desc:String,tip:String):
	if(title == toolTitle.text): #check for update
		return
	
	toolTitle.text = title
	toolDesc.text = desc
	toolTip.text = tip
	



##Toggles health and ammo. elements. Currently unused. 
func toggle_Health_And_Ammo():
	if(healthAmDisabled):
		if(ammoEnabledBeforeToggle): #ammo counters arent always shown
			show_Ammo_Anything()
		show_Health_Anything()
		healthAmDisabled = false
	else:
		ammoEnabledBeforeToggle = ammBackground.visible
		hide_Health_And_Ammo()
		healthAmDisabled = true

func hide_Health_And_Ammo():
	hide_Health_Elements()
	hide_Ammo_Elements()

#===---===}>    health info stuff
@onready var aura = $Health/Aura
@onready var health = $Health/Health
@onready var healBackground = $Health/HealthholderUi

##Hides/disables all health stuff
func hide_Health_Elements():
	healBackground.visible = false
	aura.text = " "
	health.text =  " "

##Makes health visible with placeholder info
func show_Health_Anything():
	show_Health_Elements(50, 100)

##Makes health counters visible. Requires info to fill fields
func show_Health_Elements(newAura, newHealth):
	healBackground.visible = true
	aura.text = str(newAura)
	health.text =  str(newHealth)

##Update only aura
func updateAura(newAura):
	aura.text = str(newAura)

##Updates only health
func updateHealth(newHealth):
	health.text = str(newHealth)

##Updates both health AND aura
func updateHealthAura(newAura, newHealth):
	aura.text = str(newAura)
	health.text = str(newHealth)

#===---===}>    Ammo counter
@onready var wepName = $Ammo/name
@onready var magAmt = $Ammo/Currentmag
@onready var reservAmt = $Ammo/reserve
@onready var ammBackground = $Ammo/AmmocounterUi

##Hides and disables all fields
func hide_Ammo_Elements():
	ammBackground.visible = false
	magAmt.text = " "
	reservAmt.text =  " "
	wepName.text =  " "

##Makes ammocounter visible with placeholder info
func show_Ammo_Anything():
	show_Ammo_Elements("Ipsum Lorem", 123, 456)

##Makes ammocounter visible. Requires info to fill fields
func show_Ammo_Elements(newName, mag, reserve):
	wepName.text = newName
	magAmt.text = str(mag)
	reservAmt.text = str(reserve)
	ammBackground.visible = true

##Update only the counter for bullets in magazine
func updateMag(mag):
	magAmt.text = str(mag)

##Updates only the counter for reserve rounds
func updateReserve(reserve):
	reservAmt.text = str(reserve)

##Updates both the magazine and reserve counters
func updateMagReserve(mag, reserve):
	magAmt.text = str(mag)
	reservAmt.text = str(reserve)


#===---===}>    Inventory stuff
@onready var invContain = $invBkg
@onready var invSlotsUI = $"invBkg/TabContainer/Inventory panel/VBoxContainer/GenericSlots"
@onready var quarterMaster = $"invBkg/TabContainer/Inventory panel"
func toggle_Inv():
	#Should probably have sanity checks here
	toggle_Mouse()
	#toggle_Health_And_Ammo()
	if(invContain.visible == false): #closes inventory
		invContain.visible = true 
		quarterMaster.currentlyOpen = true
		quarterMaster.update_Inven_Data()
		
	else:
		invContain.visible = false #Open inventory
		quarterMaster.currentlyOpen = false
	
	#invSlotsUI.update_Inven_Data() 
