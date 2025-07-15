extends Control
@onready var wepName = $name
@onready var magAmt = $Currentmag
@onready var reservAmt = $reserve
@onready var background = $Uiholdertest

##Hides and disables all fields
func hideElements():
	background.visible = false
	magAmt.text = " "
	reservAmt.text =  " "
	wepName.text =  " "

##Makes UI elements visible. Requires info to fill fields
func showElements(newName, mag, reserve):
	wepName.text = newName
	magAmt.text = str(mag)
	reservAmt.text = str(reserve)
	
	
##Update only the counter for bullets in magazine
func updateMag(mag):
	magAmt.text = str(mag)

##Updates only the counter for reserve rounds
func updateReserve(reserve):
	reservAmt.text = str(reserve)

##Updates both the magazine and reserve counters
func updateCounters(mag, reserve):
	magAmt.text = str(mag)
	reservAmt.text = str(reserve)
