class_name Mel extends WEAPON_PARENT
@export_category("Variables")
@export var variance: float = 0.2 ##Fractional representation of how much damage can vary
@export var reach : float = 1 ##In meters, from center of player
@export var speed : int = 80 ##Swing cooldown, in frames
@export_category("Behaviors")
@export var canThrust : bool = true ##1.5x reach charge attack
@export var canParry : bool = true ##Block behavior with partial melee damage reduction
@export var effectiveParry : bool = true ##Block behavior with full melee damage reduction

 
