@tool
extends MarginContainer

@onready var _tab_container:TabContainer = %TabContainer

func _ready():
	_tab_container.set_tab_title(0, "Keyboard & Mouse" )
	
	
