extends CharacterBody2D

var vida = 100
var dano = 20

const SPEED = 300.0
const ACCELERATION = 1800.0
const FRICTION = 2200.0
const JUMP_VELOCITY = -500.0

func receber_dano():
	vida = vida - dano

func _ready():
	receber_dano()
	print(vida)
	print("O JOGADOR FOI INICIADO!")
	print("posição do jogador: ", position)

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -500
	
	if direction > 0:
		$ColorRect.scale.x = 1
	elif direction < 0:
		$ColorRect.scale.x = -1
	
	if direction !=0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
