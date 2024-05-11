extends Area2D

##The ABSOLUTELY MASSIVE player controller script for the Flow Engine.
##most of the game's physics and logic is within this one 
##script.
##
##I'm still working through commenting and refactoring most of this code. 
##Please be patient. :D
class_name RushPlayer2D

@export_group("Linked HUD")
##The boost bar for Sonic
@export var boostbar_hud:NodePath
##The ring counter for Sonic
@export var ring_counter_hud:NodePath

@export_group("Input Mappings")
##Up on d-pad
@export var up_button:StringName
##Down on d-pad
@export var down_button:StringName
##Left on d-pad
@export var left_button:StringName
##Right on d-pad
@export var right_button:StringName
##The jump button
@export var jump_button:StringName
##The boost button
@export var boost_button:StringName
##The tricking button. This will also act as the stomp button under specific situations.
@export var trick_button:StringName

@export_group("Effects & Sounds")
## the minimum speed/pitch changes on the grinding sound
@export var RAILSOUND_MINPITCH:float = 0.5
## the maximum speed/pitch changes on the grinding sound
@export var RAILSOUND_MAXPITCH:float = 2.0
## a reference to a bouncing ring prefab, so we can spawn a bunch of them when
## sonic is hurt 
@export var bounceRing: PackedScene
##The floaty wisp things that give Sonic boost
@export var boostParticle: PackedScene

@export_group("Animations")
##Sonic's idle animation
@export var idle_anim:StringName
##Sonic's crouching animation
@export var crouch_anim:StringName

@export_group("Running")
@export_subgroup("Animations")
##Sonic's walking animation
@export var walking_anim:StringName
@export_subgroup("")
## sonic's acceleration on his own
@export var ACCELERATION:float = 0.15 / 4
## how much sonic decelerates when skidding.
@export var SKID_ACCEL:float = 1
## maximum speed under sonic's own power
@export var MAX_SPEED:float = 20.0 / 2.0
## used to dampen Sonic's movement a little bit. Basically poor man's friction
@export var SPEED_DECAY:float = 0.2 / 2.0

@export_group("Rolling and Spindashing")
@export_subgroup("Animations and SFX")
##The animation that plays when Sonic curls into a ball
@export var ball_curl_anim:StringName
##The sound that plays when Sonic curls into a ball
@export var ball_curl_sfx:AudioStream
##The animation when Sonic is in the spindash charge state
@export var spindash_anim:StringName
##The animation when Sonic actively charges the spindash
@export var spindash_charge_anim:StringName
##The sound that plays when Sonic charges a spindash
@export var spindash_sfx:AudioStream
@export_subgroup("")
##The amount of velocity added from a single spindash charge (jump + down)
@export var SPINDASH_ACCUMULATE:float = 15.0
##The maximum velocity Sonic can build up from charging a Spindash.
@export var SPINDASH_CHARGE_CAP:float = 0.0
##The initial charge of the spindash when initiated.
@export var INITIAL_SPINDASH_CHARGE:float 
##How fast Sonic will speed up when rolling downhill
@export var downhill_roll:float 
##How fast Sonic will slow down when rolling uphill
@export var uphill_roll:float
##If true, Sonic can unroll and go back to running while moving
@export var moving_unroll:bool = false

@export_group("Boosting")
## audio stream for Sonic's boost sound
@export var boost_sfx: AudioStream
## the speed of sonic's boost. Generally just a tad higher than MAX_SPEED
@export var BOOST_SPEED:float = 25.0 / 2.0
## The cooldown on activating the boost between activations, in seconds. 
##Smaller values make it more spammable.
@export var BOOST_COOLDOWN:float = 0.0
##The amount of boost that boosting will cost per physics frame.
@export var BOOST_COST:float = 0.06
##The length of Sonic's boost (or stomp) trail
@export var TRAIL_LENGTH:int = 40

@export_group("Air")
@export_subgroup("Animations and SFX")
##Sonic's jumping animation
@export var jump_anim:StringName
##Sonic's jump sound effect
@export var jump_sfx:AudioStream
##Sonic's free falling animation (he is in the air but not jumping)
@export var freefall_anim:StringName
##Sonic's hurt animation
@export var hurt_anim:StringName
##Sonic's hurt sound effect
@export var hurt_sfx:AudioStream
@export_subgroup("")
## sonic's gravity
@export var GRAVITY:float = 0.3 / 4
## sonic's acceleration in the air.
@export var AIR_ACCEL:float = 0.1 / 4
## what velocity should sonic jump at?
@export var JUMP_VELOCITY:float = 3.5
## what is the Velocity that sonic should slow to when releasing the jump button?
@export var JUMP_SHORT_LIMIT:float = 1.5
##If enabled, Sonic can initiate boosting in midair.
@export var AIR_BOOST:bool = true
##When enabled, the velocity that Sonic was moving at is the velocity he will be launched back when hurt
@export var HURT_VEL_ADD:bool = true
##This is the velocity Sonic will be sent backwards when HURT_VEL_ADD is false.
##This vector is treated absolutely, so negative values will act like their positive equivalent.
@export var STATIC_HURT_VEL:Vector2 = Vector2.ONE

@export_group("Tricking")
@export_subgroup("Animations and SFX")
##The animation that plays when Sonic tricks on a rail
@export var rail_trick_anim:StringName
##The sound that plays when Sonic tricks on a rail
@export var rail_trick_sfx:AudioStream
##The animation that plays when Sonic tricks in midair
@export var air_trick_anim:StringName
##The sound that plays when Sonic tricks in midair
@export var air_trick_sfx:AudioStream
@export_subgroup("")
##If enabled, Sonic can trick in midair, like in the Rush series
@export var air_tricking_enabled:bool = true
##If enabled, Sonic can trick on rails, like in the Rush series
@export var rail_tricking_enabled:bool = true
##The velocity that Sonic will be sent from a side trick.
##The x value will automatically be flipped positive or negative to match 
##the input direction.
@export var side_trick_vel:Vector2
##The velocity that Sonic will be sent up from an up trick
@export var up_trick_vel:float

@export_group("Stomp")
@export_subgroup("Animations and SFX")
##Sonic's stomping animation
@export var stomp_anim:StringName
## audio streams for Sonic's stomp sound
@export var stomp_sfx: AudioStream
##Sonic's stomp [i]landing[/i] animation
@export var stomp_land_anim:StringName
## audio streams for Sonic's stomp landing sound
@export var stomp_land_sfx: AudioStream
@export_subgroup("")
##If enabled, Sonic can stomp by pressing trick when not able to air trick, or
##by pressing trick+down while he can air trick
@export var stomp_enabled:bool = true

## how fast (in pixels per 1/120th of a second) should sonic stomp
@export var STOMP_SPEED:float = 20.0 / 2.0
## what is the limit to Sonic's horizontal movement when stomping?
@export var MAX_STOMP_XVEL:float = 2.0 / 2.0
##How much Sonic will bounce upon landing from a stomp
@export var STOMP_BOUNCE:float = 0.0

@export_group("Camera")
## the speed at which the camera should typically follow sonic
@export var DEFAULT_CAM_LAG:float = 20
## the speed at which the camera should follow sonic when starting a boost
@export var BOOST_CAM_LAG:float = 0
## how fast the Boost lag should slide back to the default lag while boosting
@export var CAM_LAG_SLIDE:float = 0.01 # (float,1)

# references to all the various raycasting nodes used for Sonic's collision with
# the map
@onready var LeftCast:RayCast2D = $"LeftCast"
@onready var RightCast:RayCast2D = $"RightCast"
@onready var LSideCast:RayCast2D = $"LSideCast"
@onready var RSideCast:RayCast2D = $"RSideCast"
@onready var LeftCastTop:RayCast2D = $"LeftCastTop"
@onready var RightCastTop:RayCast2D = $"RightCastTop"

## a reference to Sonic's physics collider
@onready var collider:CollisionShape2D = $"playerCollider"

##The cooldown timer on Sonic's boost
@onready var boost_cooldown_timer:Timer = $"BoostTimer"

# sonic's sprites/renderers
### sonic's sprite
@onready var sprite1:AnimatedSprite2D = $"PlayerSprites"
## the sprite that appears over sonic while boosting
@onready var boostSprite:AnimatedSprite2D = $"BoostSprite"
## the line renderer for boosting and stomping
@onready var boostLine:Line2D = $"BoostLine"

## the audio stream player with the boost sound
@onready var boostSound:AudioStreamPlayer = $"BoostSound"
## the audio stream player with the rail grinding sound
@onready var RailSound:AudioStreamPlayer = $"RailSound"
## the audio stream player with the character's voices
@onready var voiceSound:AudioStreamPlayer2D = $"Voice"

## a little text label attached to sonic for debugging
@onready var text_label:RichTextLabel = $"Camera2D/RichTextLabel"

## a reference to the scene's camera
@onready var cam:Camera2D = $"Camera2D"
## a reference to the particle node for grinding
@onready var grindParticles:GPUParticles2D = $"GrindParticles"

## a list of particle systems for Sonic to control with his speed 
## used for the confetti in the carnival level, or the falling leaves in leaf storm
var parts:Array[GPUParticles2D] = []

##Sonic's current state
var state:CharStates = CharStates.STATE_AIR

##An enumeration on Sonic's various states
enum CharStates {
	##Sonic is on the ground
	STATE_GROUND = 0,
	##Sonic is in the air
	STATE_AIR = -1,
}

## can the player shorten the jump (aka was this -1 (air) state initiated by a jump?)
var canShort:bool = false 

# state flags
var crouching:bool = false
var spindashing:bool = false
var rolling:bool = false
var grinding:bool = false
var stomping:bool = false
var boosting:bool = false
var can_boost:bool = true
var tricking:bool = false

var trickingCanStop:bool = false

# flags and values for getting hurt
var hurt:bool = false
var invincible:int = 0

# grinding values.
## the origin position of the currently grinded rail 
var grindPos:Vector2 = Vector2.ZERO
### how far along the rail (in pixels) is sonic?
var grindOffset:float = 0.0
## the curve that sonic is currently grinding on
var grindCurve:Curve2D = null
## the velocity along the grind rail at which sonic is currently moving
var grindVel:float = 0.0
### how high above the rail is the center of Sonic's sprite?
var grindHeight:float = 16

##The amount of velocity built up by the spindash before release
var spindash_buildup:float = 0

##average Ground position between the two foot raycasts
var avgGPoint:Vector2 = Vector2.ZERO 
##average top position between the two head raycasts
var avgTPoint:Vector2 = Vector2.ZERO 
## average ground rotation between the two foot raycasts
var avgGRot:float = 0
## the angle of the left foot raycast
var langle:float = 0
## the angle of the right foot raycast
var rangle:float = 0
## Sonic's rotation during the last frame
var lRot:float = 0
## the position at which sonic starts the level
var startpos:Vector2 = Vector2.ZERO
## the layer on which sonic starts
var startLayer:int = 0

## sonic's current velocity
var velocity1:Vector2 = Vector2.ZERO
##Sonic's last position
var lastPos:Vector2 = Vector2.ZERO

## the ground velocity
var gVel:float = 0
## the ground velocity during the previous frame
var pgVel:float = 0

## whether or not sonic is currently on the "back" layer
var backLayer:bool = false

func _ready():
	# get the UI elements
	#Register Sonic to the singleton stat manager
	get_node(boostbar_hud).linked_player_id = self.get_rid()
	get_node(ring_counter_hud).linked_player_id = self.get_rid()
	
	FlowStatSingleton.add_player(self.get_rid())
	
	# put all child particle systems in parts except for the grind particles
	for i in get_children():
		if i is GPUParticles2D and not i == grindParticles:
			parts.append(i)
	
	# set the start position and layer
	startpos = position
	startLayer = collision_layer
	setCollisionLayer(false)
	
	# set the trail length to whatever the boostLine's size is.
	TRAIL_LENGTH = boostLine.get_point_count()
	
	# reset all game values
	resetGame()

##Returns the given angle as an angle (in radians) between -PI and PI
func limitAngle(ang:float) -> float:
	var sign1:float = 1
	if not ang == 0:
		sign1 = ang / absf(ang)
	ang = fmod(ang, PI * 2)
	if absf(ang) > PI:
		ang = (2 * PI - absf(ang)) * sign1 * -1
	return ang

##returns the angle distance between rot1 and rot2, even over the 360deg
##mark (i.e. 350 and 10 will be 20 degrees apart)
func angleDist(rot1:float, rot2:float) -> float:
	rot1 = limitAngle(rot1)
	rot2 = limitAngle(rot2)
	if absf(rot1 - rot2) > PI and rot1 > rot2:
		return absf(limitAngle(rot1) - (limitAngle(rot2) + PI * 2))
	elif abs(rot1 - rot2) > PI and rot1 < rot2:
		return absf((limitAngle(rot1) + PI * 2) - (limitAngle(rot2)))
	else:
		return absf(rot1 - rot2)


##Handles the boosting controls
func boostControl():
	#fetch this once to prevent recurring fetches (costly)
	var boostAmount:float =  FlowStatSingleton.getBoostAmount(self.get_rid())
	
	#if Input.is_action_just_pressed(boost_button) and boostBar.boostAmount > 0 and can_boost:
	if Input.is_action_just_pressed(boost_button) and boostAmount > 0 and can_boost:
		# set boosting to true
		boosting = true
		can_boost = false
		
		#Begin boost timer
		if not boost_cooldown_timer.is_connected("timeout", set.bind("can_boost", true)):
			#This will set can_boost back to true when the timer is done
			boost_cooldown_timer.connect("timeout", set.bind("can_boost", true), CONNECT_ONE_SHOT)
		
		#This is to get around the fact that the timer will default to 1 second when 0 is provided for time
		if BOOST_COOLDOWN > 0:
			boost_cooldown_timer.start(BOOST_COOLDOWN)
		else:
			can_boost = true
		
		# reset the boost line points
		for i in range(0, TRAIL_LENGTH):
			boostLine.points[i] = Vector2.ZERO
		
		# play the boost sfx
		boostSound.stream = boost_sfx
		boostSound.play()
		
		# set the camera smoothing to the initial boost lag
		cam.set_position_smoothing_speed(BOOST_CAM_LAG)
		
		# stop moving vertically as much if you are in the air (air boost)
		#if state == CharStates.STATE_AIR and velocity1.x < ACCELERATION:
		if state == CharStates.STATE_AIR and absf(velocity1.x) < ACCELERATION:
			#if velocity1.x < BOOST_SPEED * (1 if sprite1.flip_h else -1):
			#	velocity1.x = BOOST_SPEED * (1 if sprite1.flip_h else -1)
			velocity1.x = maxf(velocity1.x, BOOST_SPEED * (1 if sprite1.flip_h else -1))
			velocity1.y = 0
		
		voiceSound.play_effort()
	
	if Input.is_action_pressed(boost_button) and boosting and boostAmount > 0:
#		if boostSound.stream != boost_sfx:
#			boostSound.stream = boost_sfx
#			boostSound.play()
		
		# linearly interpolate the camera's "boost lag" back down to the normal (non-boost) value
		#cam.set_position_smoothing_speed(lerpf(cam.get_position_smoothing_speed(), DEFAULT_CAM_LAG, CAM_LAG_SLIDE))
		var cam_tween:Tween = create_tween()
		cam_tween.tween_property(cam, "position_smoothing_speed", DEFAULT_CAM_LAG, 1.0)
		
		if grinding:
			# apply boost to a grind
			grindVel = BOOST_SPEED * (1 if sprite1.flip_h else -1)
		elif state == CharStates.STATE_GROUND:
			if not rolling:
				# apply boost if you are on the ground and not rolling
				gVel = maxf(absf(gVel), BOOST_SPEED) * (1 if sprite1.flip_h else -1)
			#At this point in code, sonic is rolling, but no boost is applied. This is intended.
		
		elif state == CharStates.STATE_AIR:
			if (angleDist(velocity1.angle(), 0) < PI/3 or angleDist(velocity1.angle(), PI) < PI / 3):
				# apply boost if you are in the air (and are not going straight up or down)
				velocity1 = velocity1.normalized() * BOOST_SPEED
			
			#At this point in code, Sonic is in the air, and traveling basically vertically. 
			#No boost is applied. This is intentional, because this is faithful to the Rush games.
		else:
			# if none of these situations fit, you shouldn't be boosting here!
			boosting = false
		
		# set the visibility and rotation of the boost line and sprite
		boostSprite.visible = true
		boostSprite.rotation = velocity1.angle() - rotation
		boostLine.visible = true
		boostLine.rotation = -rotation
		
		# decrease boost value while boosting
		#boostBar.changeBy(-BOOST_COST)
		FlowStatSingleton.boostChangeBy(self.get_rid(), -BOOST_COST)
	else:
		# the camera lag should be normal while not boosting
		cam.set_position_smoothing_speed(DEFAULT_CAM_LAG)
		
		# stop the boost sound, if it is playing
		if boostSound.stream == boost_sfx:
			boostSound.stop()
		
		# disable all visual boost indicators
		boostSprite.visible = false
		boostLine.visible = false
		
		# we're not boosting, so set boosting to false
		boosting = false

##handles physics while Sonic is in the air
func airProcess() -> void:
	# apply gravity
	velocity1.y += GRAVITY
	
	# get the angle of the point for the left and right floor raycasts
	langle = -atan2(LeftCast.get_collision_normal().x, LeftCast.get_collision_normal().y)-PI
	langle = limitAngle(langle)
	rangle = -atan2(RightCast.get_collision_normal().x,RightCast.get_collision_normal().y)-PI
	rangle = limitAngle(rangle)
	
	# calculate the average ground rotation (averaged between the points)
	avgGRot = (langle + rangle) / 2
	
	# set a default avgGPoint
	avgGPoint = Vector2(-INF,-INF)
	
	# calculate the average ground point (the elifs are for cases where one 
	# raycast cannot find a collider)
	var rot_ang:Vector2 = Vector2.from_angle(rotation)
	if (LeftCast.is_colliding() and RightCast.is_colliding()):
		text_label.text += "Left & Right Collision"
		var LeftCastPt:Vector2 = LeftCast.get_collision_point() + rot_ang * 8
		var RightCastPt:Vector2 = RightCast.get_collision_point() - rot_ang * 8
		if position.distance_to(LeftCastPt) < position.distance_to(RightCastPt):
			avgGPoint = LeftCastPt
		else:
			avgGPoint = RightCastPt
	elif LeftCast.is_colliding():
		text_label.text += "Left Collision"
		avgGPoint = LeftCast.get_collision_point() + rot_ang * 8
		avgGRot = langle
	elif RightCast.is_colliding():
		text_label.text += "Right Collision"
		avgGPoint = RightCast.get_collision_point() - rot_ang * 8
		avgGRot = rangle
	
	# calculate the average ceiling height based on the collision raycasts
	# (again, elifs are for cases where only one raycast is successful)
	if (LeftCastTop.is_colliding() and RightCastTop.is_colliding()):
		avgTPoint = (LeftCastTop.get_collision_point() + RightCastTop.get_collision_point()) / 2
	elif LeftCastTop.is_colliding():
		avgTPoint = LeftCastTop.get_collision_point() + rot_ang * 8
	elif RightCastTop.is_colliding():
		avgTPoint = RightCastTop.get_collision_point() - rot_ang * 8
	
	# handle collision with the ground
	if absf(avgGPoint.y - position.y) < 21: #-velocity1.y
	#if avgGPoint.distance_to(position) < 21:
#		print("ground hit")
		state = CharStates.STATE_GROUND
		rotation = avgGRot
		sprite1.rotation = 0
		gVel = sin(rotation) * (velocity1.y + 0.5) + cos(rotation) * velocity1.x
		
		# play the stomp sound if you were stomping
		if stomping:
			boostSound.stream = stomp_land_sfx
			boostSound.play()
			stomping = false
	
	# air-based movement (using the arrow keys)
	#Only let the player accelerate if they aren't already at max speed
	if Input.is_action_pressed(right_button) and velocity1.x < MAX_SPEED:
		velocity1.x += AIR_ACCEL
	elif Input.is_action_pressed(left_button) and velocity1.x > -MAX_SPEED:
		velocity1.x -= AIR_ACCEL
	
	#air tricking. Make sure the player is not jumping (or stomping)
	if state == CharStates.STATE_AIR and not canShort and not stomping:
		if Input.is_action_just_pressed(trick_button):
			if not sprite1.is_connected("animation_finished", rewardBoost):
				sprite1.connect("animation_finished", rewardBoost, CONNECT_ONE_SHOT)
			sprite1.play("railTrick") #because there's no formal "air trick" animation
			voiceSound.play_effort()
	
	### STOMPING CONTROLS ###
	
	var stomp_pressed:bool = false
	#Sonic has to be in the air to stomp, obviously
	if state == CharStates.STATE_AIR:
		#Check if air_tricking is enabled, because that way, if it's not,
		#trick_button will basically just be stomp always (else statement)
		if (not canShort) and air_tricking_enabled:
			#Sonic *could* be tricking, so only stomp if the player *also* presses down
			stomp_pressed = Input.is_action_pressed(trick_button) and Input.is_action_pressed(down_button) 
		else:
			#Sonic can't trick here, so trick may as well instantly initiate stomp
			stomp_pressed = Input.is_action_pressed(trick_button)
	
	# initiating a stomp
	if stomp_enabled and stomp_pressed and (not stomping):
		# set the stomping state, and animation state 
		stomping = true
		sprite1.play("Roll")
		rotation = 0
		sprite1.rotation = 0
		
		# clear all points in the boostLine rendered line
		for i in range(0, TRAIL_LENGTH):
			boostLine.points[i] = Vector2.ZERO
		
		# play sound 
		boostSound.stream = stomp_sfx
		boostSound.play()
	
	# for every frame while a stomp is occuring...
	if stomping:
		velocity1 = Vector2(maxf(-MAX_STOMP_XVEL, minf(MAX_STOMP_XVEL, velocity1.x)), STOMP_SPEED)
		
		# make sure that the boost sprite is not visible
		boostSprite.visible = false
		
		# manage the boost line 
		boostLine.visible = true
		boostLine.rotation = -rotation
		
		# don't run the boost code when stomping
	else:
		boostControl()
	
	# slowly slide Sonic's rotation back to zero as you fly through the air
	sprite1.rotation = lerpf(sprite1.rotation, 0.0, 0.1)
	
	# handle left and right sideways collision (respectively)
	if LSideCast.is_colliding() and LSideCast.get_collision_point().distance_to(position + velocity1) < 14 and velocity1.x < 0:
		#velocity1 = Vector2(0,velocity1.y)
		velocity1.x = 0
		#position = LSideCast.get_collision_point() + Vector2(14,0)
		position.x = LSideCast.get_collision_point().x + 14.0
		boosting = false
	if RSideCast.is_colliding() and RSideCast.get_collision_point().distance_to(position + velocity1) < 14 and velocity1.x > 0:
		#velocity1 = Vector2(0,velocity1.y)
		velocity1.x = 0
		position.x = RSideCast.get_collision_point().x - 14
		#position = RSideCast.get_collision_point() - Vector2(14,0)
		boosting = false
	
	# top collision
	if Vector2(position + velocity1).distance_to(avgTPoint) < 21:
#		Vector2(avgTPoint.x-20*sin(rotation),avgTPoint.y+20*cos(rotation))
		velocity1.y = 0
	
	# render the sprites facing the correct direction
	if velocity1.x < 0:
		sprite1.flip_h = false
	elif velocity1.x > 0:
		sprite1.flip_h = true
	
	# Allow the player to change the duration of the jump by releasing the jump
	# button early
	if not Input.is_action_pressed(jump_button) and canShort:
		#velocity1 = Vector2(velocity1.x, maxf(velocity1.y,-JUMP_SHORT_LIMIT))
		velocity1.y = maxf(velocity1.y, -JUMP_SHORT_LIMIT)
	
	# ensure the proper speed of the animated sprites
	sprite1.speed_scale = 1

func groundProcess() -> void:
	# caluclate the ground rotation for the left and right raycast colliders,
	# respectively
	langle = -atan2(LeftCast.get_collision_normal().x,LeftCast.get_collision_normal().y)-PI
	langle = limitAngle(langle)
	rangle = -atan2(RightCast.get_collision_normal().x,RightCast.get_collision_normal().y)-PI
	rangle = limitAngle(rangle)
	
	# calculate the average ground rotation
	if absf(langle - rangle) < PI:
		avgGRot = limitAngle((langle + rangle) / 2)
	else:
		avgGRot = limitAngle((langle + rangle + PI * 2) / 2)
	
	# calculate the average ground level based on the available colliders
	if (LeftCast.is_colliding() and RightCast.is_colliding()):
		avgGPoint = Vector2((LeftCast.get_collision_point().x+RightCast.get_collision_point().x)/2,(LeftCast.get_collision_point().y+RightCast.get_collision_point().y)/2)
		#((acos(LeftCast.get_collision_normal().y/1)+PI)+(acos(RightCast.get_collision_normal().y/1)+PI))/2
	elif LeftCast.is_colliding():
		avgGPoint = Vector2(LeftCast.get_collision_point().x + cos(rotation) * 8, LeftCast.get_collision_point().y + sin(rotation) * 8)
		avgGRot = langle
	elif RightCast.is_colliding():
		avgGPoint = Vector2(RightCast.get_collision_point().x-cos(rotation)*8,RightCast.get_collision_point().y-sin(rotation)*8)
		avgGRot = rangle
	
	# set the rotation and position of Sonic to snap to the ground.
	rotation = avgGRot
	position = Vector2(avgGPoint.x + 20 * sin(rotation), avgGPoint.y - 20 * cos(rotation))
	
	#If this is negative, the player is pressing left. If positive, they're pressing right.
	var input_direction:float = Input.get_axis(left_button, right_button)
	
	if not rolling:
		# handle rightward acceleration
		if input_direction > 0 and gVel < MAX_SPEED:
			#Analog controls :nice:
			gVel += ACCELERATION * input_direction 
			# "skid" mechanic, to more quickly accelerate when reversing 
			# (this makes Sonic feel more responsive)
			if gVel < 0:
				gVel += SKID_ACCEL
		
		# handle leftward acceleration
		elif input_direction < 0 and gVel > -MAX_SPEED:
			#This works as a += because input_direction is negative
			gVel += ACCELERATION * input_direction
			
			# "skid" mechanic (see rightward section)
			if gVel > 0:
				gVel -= SKID_ACCEL
		elif input_direction == 0.0:
			# general deceleration and stopping if no key is pressed
			# declines at a constant rate
			if not gVel == 0:
				gVel -= SPEED_DECAY * (gVel / absf(gVel))
			if absf(gVel) < SPEED_DECAY * 1.5:
				gVel = 0
	elif rolling and is_zero_approx(avgGRot):
		# general deceleration and stopping if no key is pressed and ground is level
		# declines at a constant rate
		if not gVel == 0:
			gVel -= SPEED_DECAY * signf(gVel) * 0.3
		if absf(gVel) < SPEED_DECAY * 1.5:
			gVel = 0
	
	# left and right wall collision, respectively
	if LSideCast.is_colliding() and LSideCast.get_collision_point().distance_to(position) < 21 and gVel < 0:
		gVel = 0
		#position = LSideCast.get_collision_point() + Vector2(position.x-LSideCast.get_collision_point().x,position.y-LSideCast.get_collision_point().y).normalized()*21
		position = LSideCast.get_collision_point() + Vector2(position - LSideCast.get_collision_point()).normalized() * 21
		boosting = false
	if RSideCast.is_colliding() and RSideCast.get_collision_point().distance_to(position) < 21 and gVel > 0:
		gVel = 0
		#position = RSideCast.get_collision_point() + Vector2(position.x-RSideCast.get_collision_point().x,position.y-RSideCast.get_collision_point().y).normalized()*21
		position = RSideCast.get_collision_point() + Vector2(position - RSideCast.get_collision_point()).normalized() * 21
		boosting = false 
	
	# apply gravity if you are on a slope, and apply the ground velocity
	gVel += sin(rotation) * GRAVITY
	var rot_ang:Vector2 = Vector2.from_angle(rotation)
	#velocity1 = Vector2(cos(rotation) * gVel, sin(rotation) * gVel)
	velocity1 = rot_ang * gVel
	
	# enter the air state if you run off a ramp, or walk off a cliff, or something
	if not avgGPoint.distance_to(position) < 21 or not (LeftCast.is_colliding() and RightCast.is_colliding()):
		state = CharStates.STATE_AIR
		sprite1.rotation = rotation
		rotation = 0
		rolling = false
	
	# fall off of walls if you aren't going fast enough
	#if absf(rotation) >= PI/3 and (absf(gVel) < 0.2 or (not gVel == 0 and not pgVel == 0 and not gVel / absf(gVel) == pgVel / abs(pgVel))):
	if absf(rotation) >= PI/3 and (absf(gVel) < 0.2 or (gVel != 0 and pgVel != 0 and signf(gVel) != signf(pgVel))):
		state = CharStates.STATE_AIR
		sprite1.rotation = rotation
		rotation = 0
		#position = Vector2(position.x-sin(rotation)*2,position.y+cos(rotation)*2)
		#since rotation = 0, we can do some extreme math assumptions
		position.y += 2
		rolling = false
	
	# ensure Sonic is facing the right direction
	if gVel < 0:
		sprite1.flip_h = false
	elif gVel > 0:
		sprite1.flip_h = true
	
	#Check if Sonic is in the air (and not because he's jumping), and play that anim if so
	if state == CharStates.STATE_AIR and not canShort:
		sprite1.play("Free_falling")
	# set Sonic's sprite based on his ground velocity
	elif not rolling:
		if absf(gVel) > 6.0: #12.0 / 2.0
			sprite1.play("Run4")
		elif absf(gVel) > 5.0: #10.0 / 2.0
			sprite1.play("Run3")
		elif absf(gVel) > 2.5: #5.0 / 2.0
			sprite1.play("Run2")
		elif absf(gVel) > 0.02:
			sprite1.play("Walk")
		elif not crouching:
			sprite1.play("idle")
	else:
		sprite1.play("Roll")
	
	
	#Crouching
	if absf(gVel) > 0.02:
		crouching = false
		sprite1.speed_scale = 1
	else:
		gVel = 0
		rolling = false
	
	
	if not spindashing:
		if Input.is_action_pressed(down_button):
			#Sonic is either rolling or crouching
			
			if absf(gVel) <= 0.02:
				#crouch, since Sonic is effectively at a standstill
				
				#Only play the anim if he wasn't crouching before, 
				#to avoid it being played repeatedly
				if not crouching:
					sprite1.play("Crouch")
				crouching = true
			else:
				#roll, since Sonic is moving
				crouching = false
				rolling = true
				sprite1.play("Roll")
		
		#since the previous check is false in this case, Sonic is no longer crouching
		else:
			if crouching == true:
				sprite1.stop()
				#sprite1.play("Crouch", -1.0, true)
				sprite1.play_backwards("Crouch")
				crouching = false
			
			#unroll while moving :nice:
			if Input.is_action_pressed(up_button) and rolling and moving_unroll:
				rolling = false
	
	# run boost controls, but only if you aren't spindashing or rolling
	if not (rolling or spindashing):
		boostControl()
	
	# jumping
	if Input.is_action_pressed(jump_button) and not (crouching or spindashing):
		if not canShort:
			state = CharStates.STATE_AIR
			#velocity1 = Vector2(velocity1.x + sin(rotation) * JUMP_VELOCITY, velocity1.y - cos(rotation) * JUMP_VELOCITY)
			velocity1 += Vector2(sin(rotation), -cos(rotation)) * JUMP_VELOCITY
			sprite1.rotation = rotation
			rotation = 0
			sprite1.play("Roll")
			canShort = true
			rolling = false
	else:
		canShort = false
	
	#initate spindash
	if (Input.is_action_pressed(jump_button) and crouching) and not rolling:
		spindashing = true
		#Mimic how the animation would restart in the classics
		sprite1.play("Spindash")
	
	#if spindashing and not rolling:
	if spindashing:
		#if a charge is being built up this frame
		if Input.is_action_just_pressed(jump_button):
			#accumulate spindash speed
			spindash_buildup += SPINDASH_ACCUMULATE * (1 if sprite1.flip_h else -1)
			#cap buildup velocity so Sonic can't rocket off
			if SPINDASH_CHARGE_CAP > 0:
				spindash_buildup = clampf(spindash_buildup, -SPINDASH_CHARGE_CAP, SPINDASH_CHARGE_CAP)
		#charge release
		if not Input.is_action_pressed(down_button):
			spindashing = false
			rolling = true
			gVel += spindash_buildup
			spindash_buildup = 0
	
	# set the previous ground velocity and last rotation for next frame
	pgVel = gVel
	lRot = rotation

func grindProcess() -> void:
	#Handle tricking
	if Input.is_action_pressed(trick_button) or tricking:
		tricking = true
		if not sprite1.is_connected("animation_finished", rewardBoost):
			sprite1.connect("animation_finished", rewardBoost, CONNECT_ONE_SHOT)
		sprite1.play("railTrick") #because there's no formal "air trick" animation
		voiceSound.play_effort()
	else:
		sprite1.play("Grind")
	
	grindHeight = sprite1.sprite_frames.get_frame_texture(sprite1.animation, sprite1.frame).get_height() / 2.0
	
	grindOffset += grindVel
	var dirVec:Vector2 = grindCurve.sample_baked(grindOffset + 1) - grindCurve.sample_baked(grindOffset)
	#grindVel = velocity1.dot(dirVec)
	rotation = dirVec.angle()
	position = grindCurve.sample_baked(grindOffset) + (Vector2(1 * sin(rotation), -1 * cos(rotation)) * grindHeight) + grindPos
	
	
	RailSound.pitch_scale = lerpf(RAILSOUND_MINPITCH, RAILSOUND_MAXPITCH,\
		absf(grindVel) / BOOST_SPEED)
	grindVel += sin(rotation) * GRAVITY
	
	if dirVec.length() < 0.5 or \
		grindCurve.sample_baked(grindOffset - 1) == \
		grindCurve.sample_baked(grindOffset):
		state = CharStates.STATE_AIR
		grinding = false
		tricking = false
		trickingCanStop = false
		RailSound.stop()
		sprite1.play("Free_falling")
	else:
		velocity1 = dirVec * grindVel
	
	if Input.is_action_pressed(jump_button) and not crouching:
		if not canShort:
			state = CharStates.STATE_AIR
			#velocity1 = Vector2(velocity1.x+sin(rotation)*JUMP_VELOCITY,velocity1.y-cos(rotation)*JUMP_VELOCITY)
			velocity1 = velocity1 + Vector2(sin(rotation), -cos(rotation)) * JUMP_VELOCITY
			sprite1.rotation = rotation
			rotation = 0
			sprite1.play("Roll")
			canShort = true
			rolling = false
			grinding = false
			tricking = false
			trickingCanStop = false
			RailSound.stop()
	else:
		canShort = false
	boostControl()

func _process(_delta:float) -> void:
	if invincible > 0:
		sprite1.modulate = Color(1,1,1, 1-(invincible % 30)/30.0)
	else:
		hurt = false

#calculate Sonic's physics, controls, and all that fun stuff
func _physics_process(_delta:float) -> void:
	if invincible > 0:
		invincible -= 1
	# reset using the dedicated reset button
	if Input.is_action_pressed('restart'):
		resetGame()
		if get_tree().reload_current_scene() != OK:
			push_error("Could not reload current scene!")
	
	grindParticles.emitting = grinding
	
	# run the correct function based on the current air/ground state
	if grinding:
		grindProcess()
	elif state == CharStates.STATE_AIR:
		airProcess()
		rolling = false
	elif state == CharStates.STATE_GROUND:
		groundProcess()
	
	# update the boost line 
	for i in range(0, TRAIL_LENGTH - 1):
		boostLine.points[i] = (boostLine.points[i+1]-velocity1+(lastPos-position))
	boostLine.points[TRAIL_LENGTH - 1] = Vector2.ZERO
	if stomping:
		boostLine.points[TRAIL_LENGTH - 1] = Vector2(0,8)
	
	# apply the character's velocity, no matter what state the player is in.
	#position = Vector2(position.x+velocity1.x,position.y+velocity1.y)
	#position = position + velocity1
	position += velocity1
	lastPos = position
	
	if parts:
		for i:GPUParticles2D in parts:
			i.process_material.direction = Vector3(velocity1.x, velocity1.y, 0)
			
			#i.process_material.initial_velocity = velocity1.length() * 20
			
			i.rotation = -rotation

##shortcut to change the collision mask for every raycast node connected to
## sonic at the same time. Value is true for loop_right, false for loop_left
func setCollisionLayer(value:bool) -> void:
	backLayer = value
	
	for rays:RayCast2D in [LeftCast, RightCast, RSideCast, LSideCast, LeftCastTop, RightCastTop]:
		rays.set_collision_mask_value(2, not backLayer)
		rays.set_collision_mask_value(3, backLayer)

## toggle between layers
func FlipLayer() -> void:
	setCollisionLayer(not backLayer)

## enables interaction with the "left loop" collision layer for Sonic
func LeftLayerOn() -> void:
	setCollisionLayer(false)

## enables interaction with the "right loop" collision layer
func RightLayerOn() -> void:
	setCollisionLayer(true)

func _on_DeathPlane_area_entered(area:Node) -> void:
	if self == area:
		resetGame()
		if get_tree().reload_current_scene() != OK: 
			push_error("Could not reload current scene!")

## reset your position and state if you pull a dimps (fall out of the world)
func resetGame() -> void:
	velocity1 = Vector2.ZERO
	state = CharStates.STATE_AIR
	position = startpos
	setCollisionLayer(false)

##this function is run whenever sonic hits a rail.
func _on_Railgrind(area:Area2D, curve:Curve2D, origin:Vector2) -> void:
	# stick to the current rail if you're already grindin
	if grinding:
		return
	
	# activate grind, if you are going downward
	if self == area and velocity1.y > 0:
		grinding = true
		grindCurve = curve
		grindPos = origin
		grindOffset = grindCurve.get_closest_offset(position-grindPos)
		grindVel = velocity1.x
		
		RailSound.play()
		
		# play the sound if you were stomping
		if stomping:
			boostSound.stream = stomp_land_sfx
			boostSound.play()
			stomping = false

##This spawns in a boost particle "on demand".
##If make_check is true, it will make sure Sonic is tricking by checking the animation.
func rewardBoost(make_check:bool = true) -> void:
	if make_check:
		if sprite1.animation == "railTrick":
			tricking = false
		else:
			return
	
	var part = boostParticle.instantiate()
	part.position = position 
	part.boostValue = 2
	get_node("/root/Node2D").add_child(part)

func isAttacking() -> bool:
	if stomping or boosting or rolling or spindashing or \
		(sprite1.animation == "Roll" and state == CharStates.STATE_AIR):
		return true
	return false

func hurt_player() -> void:
	if not invincible > 0:
		invincible = 120 * 5
		state = CharStates.STATE_AIR
		if HURT_VEL_ADD:
			velocity1 = Vector2(-velocity1.x + sin(rotation) * JUMP_VELOCITY, velocity1.y - cos(rotation) * JUMP_VELOCITY)
		else:
			velocity1 = Vector2(-signf(velocity1.x) * absf(STATIC_HURT_VEL.x) + sin(rotation), -signf(velocity1.y) * STATIC_HURT_VEL.y - cos(rotation)) * JUMP_VELOCITY
		rotation = 0
		position += velocity1 * 2
		sprite1.play("hurt")
		
		voiceSound.play_hurt()
		
		var t:int = 0
		var angle:float = 101.25
		var n:bool = false
		var speed:int = 4
		var ringCount:int = FlowStatSingleton.getRingCount(self.get_rid())
		
		
		while t < mini(ringCount, 32):
			var currentRing:Node2D = bounceRing.instantiate()
			currentRing.velocity1 = Vector2(-sin(angle) * speed, cos(angle) * speed) / 2
			currentRing.position = position
			if n:
				currentRing.velocity1.x *= -1
				angle += 22.5
			n = not n
			t += 1
			if t == 16:
				speed = 2
				angle = 101.25
			get_node("/root/Node2D").call_deferred("add_child", currentRing)
		
		#Remove the rings we had from the ring counter
		FlowStatSingleton.addRing(self.get_rid(), -ringCount)
