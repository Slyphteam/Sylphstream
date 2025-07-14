extends Control
@onready var wepName = $name
@onready var magAmt = $Currentmag
@onready var reservAmt = $reserve
func assignInfo(weap, mag, reserve):
	return

func updateMag(mag):
	magAmt.text = str(mag)

func updateReserve(reserve):
	reservAmt.text = str(reserve)
	
func updateCounters(mag, reserve):
	magAmt.text = str(mag)
	reservAmt.text = str(reserve)
