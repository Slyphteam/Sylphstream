##Fairly trivial script that acts as a librarian for all the different UI elements. 
extends Control
@onready var theReticle = $Reticle
@onready var ammoCounter = $Ammo
@onready var pauseMenu = $pauseContainer

func hide_Everything():
	hide_Health_Elements()
	hide_Ammo_Elements()
	#add code that hides crosshairs

#===---===}>    dynamic reticle stuff
@export var crosshairs : Array[Line2D]
@export var ourplayer : CharacterBody3D
@export var reticlespeed : float = 0.25
@export var reticledistance : float = 2

#for movement speed: lerp crosshairs[0].position, [0,0] + vector 2 of 0, -playerspeed  * reticledistance
##adjust the spread of the crosshairs by a given amount. input MUST be an integer.
func adjust_spread(amount):
	
	crosshairs[0].position = Vector2(0, -amount) 
	crosshairs[1].position = Vector2(0, amount)
	crosshairs[2].position = Vector2(-amount, 0)
	crosshairs[3].position = Vector2(amount, 0)


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
	aura.text = newAura
	health.text =  newHealth

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
