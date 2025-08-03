extends Control
@onready var wepName = $name
@onready var magAmt = $Currentmag
@onready var reservAmt = $reserve
@onready var background = $Uiholdertest

##Hides and disables all fields
func hide_Ammo_Elements():
	background.visible = false
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
	background.visible = true

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
