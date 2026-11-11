
extends CharacterBody2D

var vida = 100
var dano = 20

const SPEED = 300.0
const ACCELERATION = 1800.0
const FRICTION = 2200.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 980.0

var estado = "parado"
var estado_anterior = ""
var pode_atacar = true
var ataque_ativo = false
var ja_acertou = false
var defendendo = false

func receber_dano():
	vida = vida - dano


	if not pode_atacar:
		return

	estado = "atacando"
	pode_atacar = false
	ataque_ativo = true

	$AreaAtaque/CollisionShape2D.set_deferred("disabled", false)
	$ColorRect.modulate = Color(1, 0.3, 0.3)
	if $ColorRect.scale.x ==1:
		$Braco.position.x = 45
	else:
		$Braco.position.x = -45

	print("O JOGADOR EXECUTOU UM ATAQUE!")

	await get_tree().create_timer(1.0).timeout

	ataque_ativo = false
	$AreaAtaque/CollisionShape2D.set_deferred("disabled", true)
	$ColorRect.modulate = Color.WHITE
	if $ColorRect.scale.x == 1:
		$Braco.position.x = 20
	else:
		$Braco.position.x = 20

	pode_atacar = true


func _ready():
	print("O JOGADOR FOI INICIADO!")
	print("Posição do jogador: ", position)
	print("Vida inicial: ", vida)

	$AreaAtaque/CollisionShape2D.set_deferred("disabled", true)

	if not $AreaAtaque.body_entered.is_connected(_on_area_ataque_body_entered):
		$AreaAtaque.body_entered.connect(_on_area_ataque_body_entered)


func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_J:
			print("TECLA J RECEBIDA!")
			atacar()

		elif event.keycode == KEY_A:
			print("TECLA A RECEBIDA!")


func _physics_process(delta: float) -> void:
	#SISTEMA DE DEFESA
	# SISTEMA DE DEFESA
	var oponente = get_parent().get_node("Oponente")
	var defendendo_direita = oponente.global_position.x > global_position.x

	var segurando_defesa = false

	if defendendo_direita:
		segurando_defesa = Input.is_key_pressed(KEY_A)
	else:
		segurando_defesa = Input.is_key_pressed(KEY_D)

	if segurando_defesa and not defendendo:
		defendendo = true
		$ColorRect.modulate = Color(0.4, 0.7, 1.0)
		print("JOGADOR ENTROU EM DEFESA!")

	elif not segurando_defesa and defendendo:
		defendendo = false
		$ColorRect.modulate = Color.WHITE
		print("JOGADOR SAIU DA DEFESA!")

	var direction = Input.get_axis("ui_left", "ui_right")

	# PULO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# DIREÇÃO DO PERSONAGEM E DO BRAÇO
	# DIREÇÃO DO PERSONAGEM
	if pode_atacar:
		if direction > 0:
			$ColorRect.scale.x = 1
			$Braco.position.x = 20
			$Braco.scale.x = 1
			$AreaAtaque.position.x = 35

	elif direction < 0:
		$ColorRect.scale.x = -1
		$Braco.position.x = -55
		$Braco.scale.x = 1
		$AreaAtaque.position.x = -35

	# MOVIMENTAÇÃO
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# GRAVIDADE
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

	# ESTADOS DO PERSONAGEM
	
func atacar():
	if not pode_atacar:
		return

	var direcao = $ColorRect.scale.x

	estado = "atacando"
	pode_atacar = false
	ataque_ativo = true
	ja_acertou = false

	$AreaAtaque/CollisionShape2D.set_deferred("disabled", false)
	$ColorRect.modulate = Color(1, 0.3, 0.3)

	print("O JOGADOR EXECUTOU UM ATAQUE!")

	# AVANÇAR O BRAÇO
	var tween = create_tween()
	tween.tween_property($Braco, "position:x", direcao * 45, 0.12)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	await tween.finished

	# PEQUENA PAUSA DO SOCO
	await get_tree().create_timer(0.08).timeout

	# RETORNAR O BRAÇO
	var retorno = create_tween()
	retorno.tween_property($Braco, "position:x", direcao * 20, 0.12)

	await retorno.finished

	ataque_ativo = false
	$AreaAtaque/CollisionShape2D.set_deferred("disabled", true)
	$ColorRect.modulate = Color.WHITE

	pode_atacar = true


	# MOSTRAR MUDANÇA DE ESTADO
	if estado != estado_anterior:
		print(estado)
		estado_anterior = estado



func _on_area_ataque_body_entered(body: Node2D):
	if body == self:
		return

	if ataque_ativo and not ja_acertou:
		if body.has_method("receber_dano"):
			ja_acertou = true

			print("UM CORPO FOI ATINGIDO PELO ATAQUE!")

			body.receber_dano(dano)
