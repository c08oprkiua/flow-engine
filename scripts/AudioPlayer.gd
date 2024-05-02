# plays audio with intro and loop sections

extends AudioStreamPlayer

# the time, in seconds, to loop back to once the end is reached.
@export var loopbackTime:float = 13.25

# records whether or not the track is in the loopable 
# section yet
var loopbackFlag:bool = false


func _process(_delta:float) -> void:
	#Only process the music if it's actually playing
	if playing:
		# set the loopback flag if we are in the loopable section
		if get_playback_position() > loopbackTime:
			loopbackFlag = true
		
		# if the track loops back to the beginning, automatically 
		# skip to the loopable section instead
		if get_playback_position() < loopbackTime and loopbackFlag:
			seek(loopbackTime)

