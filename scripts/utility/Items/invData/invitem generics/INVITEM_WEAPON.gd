class_name INVWEP extends INVENITEMPARENT
var slotUsed: int ##What slot is the weapon currently taking up?
var roundInside:int = 0##How many rounds (if any) are in the weapon's magazine?
@export var weapInfoSheet: WEAP_INFO ##Reference to the wep info sheet

func _init():
	itemTyp = "WEP" #does not work, type is set to "GEN"

func _ready():
	itemTyp = "WEP" #does not work either

#var itemTyp = "WEP" #very clearly does not work
