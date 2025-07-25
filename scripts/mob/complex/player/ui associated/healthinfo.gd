extends Control
@onready var aura = $Aura
@onready var health = $Health
@onready var background = $HealthholderUi

##Hides and disables all fields
func hideElements():
	background.visible = false
	aura.text = " "
	health.text =  " "

##Makes ammocounter visible with placeholder info
func showElementsAnything():
	showElements(50, 100)

##Makes ammocounter visible. Requires info to fill fields
func showElements(newAura, newHealth):
	background.visible = true
	aura.text = newAura
	health.text =  newHealth
	
##Update only the counter for bullets in magazine
func updateAura(newAura):
	aura.text = str(newAura)

##Updates only the counter for reserve rounds
func updateHealth(newHealth):
	health.text = str(newHealth)

##Updates both the magazine and reserve counters
func updateBoth(newAura, newHealth):
	aura.text = str(newAura)
	health.text = str(newHealth)
