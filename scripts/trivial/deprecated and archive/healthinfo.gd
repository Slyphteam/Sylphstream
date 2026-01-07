##Old script for health tracking. functionality moved to player UI manager
extends Control
#@onready var aura = $Aura
#@onready var health = $Health
#@onready var background = $HealthholderUi

###Hides and disables all fields
#func hide_Health_Elements():
	#background.visible = false
	#aura.text = " "
	#health.text =  " "
#
###Makes health visible with placeholder info
#func show_Health_Anything():
	#show_Health_Elements(50, 100)
#
###Makes ammocounter visible. Requires info to fill fields
#func show_Health_Elements(newAura, newHealth):
	#background.visible = true
	#aura.text = newAura
	#health.text =  newHealth
	
###Update only the counter for bullets in magazine
#func updateAura(newAura):
	##aura.text = str(newAura)
#
###Updates only the counter for reserve rounds
#func updateHealth(newHealth):
	#health.text = str(newHealth)
#
###Updates both health AND aura
#func updateBoth(newAura, newHealth):
	#aura.text = str(newAura)
	#health.text = str(newHealth)
