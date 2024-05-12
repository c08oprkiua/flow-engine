extends RigidBody2D
##this script is for the bouncy-type rings that fly out of you when you get hit
class_name FlowBouncyRing

##Whether the ring exists due to Sonic dropping it
@export var dropped:bool = false
##How much boost, if any, the ring will give the collector.
##This will do nothing if dropped is true.
@export var boost_reward:float = 2.0

## true if the ring has been collected 
var collected:bool = false

## stores a reference to the raycast node
@onready var downCast:RayCast2D = $"DownCast"
## holds a reference to the AnimatedSprite node for the ring
@onready var sprite:AnimatedSprite2D = $"AnimatedSprite2D"
## holds a referene to the AudioStreamPlayer for the ring
@onready var audio:AudioStreamPlayer = $"AudioStreamPlayer"
##Holds a reference to the collection timer, for how long 
##the ring will be "alive" when it is dropped
@onready var dropped_timeout:Timer = $"Timer"


## timer variable to keep track of when the ring disappears.
var collectionStartTimer:int = 120

# represents the current velocity of the ring.
@export var velocity1: Vector2 = Vector2.ZERO

func _ready() -> void:
	sprite.play("default")

func _process(_delta:float) -> void:
	# make the sprite invisible once the ring has been collected and
	# the sparkle animation is over
	if collected and sprite.animation == "Sparkle" and \
		sprite.frame >= 6:
		visible = false

func _physics_process(_delta:float) -> void:
	pass

func ba():
	# count down the timer
	if dropped:
		collectionStartTimer -= 1
	
	if not freeze and not collected:
		# bounce on relevent ground nodes
		if downCast.is_colliding() and downCast.get_collision_point().y < position.y + 16:
			velocity1.y *= -1
		
		# add gravity
		velocity1.y += 0.02
		
		# apply velocity 
		position += velocity1
	
	# once the timer gets to a certain point, start flashing the ring sprite
	if dropped and collectionStartTimer < -900:
		sprite.modulate = Color(1,1,1,1 -(-collectionStartTimer % 30) / 30.0)
	
	# remove the ring node once the timer is up
	if dropped and collectionStartTimer < -1080:
		queue_free()

##Make the ring behave like a dropped ring
func DropRing() -> void:
	freeze = false
	dropped = true

func _on_body_entered(body: Node) -> void:
	# if the ring hasn't been collected and the player collides...
	if FlowStatSingleton.player_exists(body.get_rid()) and not collected and (freeze or collectionStartTimer <= 0):
		# set collected to true
		collected = true
		sprite.stop()
		#hide when the timer is done
		sprite.connect("animation_finished", hide, CONNECT_ONE_SHOT)
		# set the animation to the sparkle
		sprite.play("Sparkle")
		# play the ring sfx
		audio.play()
		# add a ring to the total
		FlowStatSingleton.addRing(body.get_rid(), 1)
		#give a reward for collecting it if it's not a dropped ring
		if not dropped:
			FlowStatSingleton.boostChangeBy(body.get_rid(), boost_reward)