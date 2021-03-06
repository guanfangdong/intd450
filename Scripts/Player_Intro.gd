extends KinematicBody2D

# This is a demo showing how KinematicBody2D
# move_and_slide works.

# Member variables
var MAX_MOTION_SPEED = 240
var MOTION_SPEED = 240 # Pixels/second
var DEATHS_PER_COLOR_CHANGE = 3
var distance = 500

var target
var vulnerable

var timer = 0
var magnitude = 10
var gap = 0.1

var canMove = true
var dead = false
var anim
var oldAnim

var control = true
export (bool) var timerVisible = true



func _ready():
	$Camera2D.zoomfactor = 1.4
	var monsters  = get_tree().get_nodes_in_group("Monster")
	for t in monsters:
		target = t
	$CanvasLayer/SceneTransition.play("SceneTransition")
	vulnerable = true
	#$AnimationPlayer.play("SpawnAnimation")
	$CanvasLayer/Blur.show()
	oldAnim = ""
	anim = ""
	var deaths = GameManagerNode.totalDeaths
	updatePlayerTexture(deaths)
	if !timerVisible:
		hideTimer()

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if target and !target.spawned:
				target.spawn()
			$Camera2D/CanvasLayer/RichTextLabel.start()

func _physics_process(delta):
	var motion = Vector2()
	if control == true:
		if Input.is_action_pressed("ui_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("ui_down"):
			motion += Vector2(0, 1)
		if Input.is_action_pressed("ui_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("ui_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("ui_pause") and vulnerable:
			$CanvasLayer/PauseMenu.show()
			get_tree().paused = true
		
		if canMove:
			if motion.y < 0:
				anim = "WalkUp"
			elif motion.y > 0:
				anim = "WalkDown"
			if motion.x < 0:
				anim = "WalkRight"
				$sprite.flip_h = true
			elif motion.x > 0:
				anim = "WalkRight"
				$sprite.flip_h = false
			if motion == Vector2(0, 0):
				if oldAnim == "WalkUp":
					anim = "IdleUp"
				if oldAnim == "WalkDown":
					anim = "IdleDown"
				if oldAnim == "WalkRight":
					anim = "IdleRight"
			if oldAnim != anim:
				$AnimationPlayer.play(anim)
				oldAnim = anim
			
			motion = motion.normalized() * MOTION_SPEED
			move_and_slide(motion)
	
func _process(delta):
	if target:
		distance = sqrt(pow((target.position.x - position.x),2) + pow((target.position.y - position.y),2))
		timer += delta
		# zoom by distance
		$Camera2D.zoomIn(distance/100)
		if distance < 100 and timer > gap:
			update_magnitude_and_gap(distance)
			$Camera2D/Shaker.shake(magnitude)
			timer = 0
		var blurLevel = 0
		if vulnerable:
			blurLevel = -1*((distance)/4)+30 # Scale runs from [0,30]. Outer 30 moves value into this range.
		$CanvasLayer/Blur.updateBlur(blurLevel)

func update_magnitude_and_gap(distance):
	magnitude = pow(2,-distance/50) * 25

func takeDamage():
	if vulnerable:
		MOTION_SPEED = 0
		dead = true
		$CanvasLayer/SceneTransition.play_backwards("SceneTransition")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "SpawnAnimation":
		canMove = true


func _on_SceneTransition_animation_finished(anim_name):
	if anim_name == "SceneTransition" and dead:
		dead = false
		MOTION_SPEED = MAX_MOTION_SPEED
		GameManagerNode.reloadLevel()

func updatePlayerTexture(deaths):
	var i = 1
	i = int((deaths+DEATHS_PER_COLOR_CHANGE)/ DEATHS_PER_COLOR_CHANGE)
	if i <= 0:	# if below limit
		i = 1
	if i > 6:	# if above limit
		i = 5
	$sprite.texture = load("res://Art/PCs" + str(i) + ".png")
	
func hideTimer():
	$Camera2D/CanvasLayer/RichTextLabel.hide()

func _on_Button_button_pressed():
	var offset_vec = Vector2()
	offset_vec.y += 500
	offset_vec.x -= 200
	$Camera2D.offset  = offset_vec
	var zoom_vec = Vector2()
	zoom_vec.x += 1.3
	zoom_vec.y += 1.3
	$Camera2D.zoom = zoom_vec
	canMove = false
	control = false
	


func _on_Monster_can_move():
	canMove = true
	control = true
	var offset_vec = Vector2()
	$Camera2D.offset  = offset_vec