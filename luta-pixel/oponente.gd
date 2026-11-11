
extends CharacterBody2D

var vida = 100
var recuo = 35.0
var pode_animar = true
var derrotado = false
var recuperando = false


func receber_dano(dano_recebido):
	if derrotado:
		return

	var jogador = get_parent().get_node("Jogador")

	var jogador_esta_na_frente = jogador.global_position.x < global_position.x

	if jogador.defendendo and jogador_esta_na_frente:
		print("JOGADOR BLOQUEOU O ATAQUE!")
	return

	vida -= dano_recebido

	if vida < 0:
		vida = 0

	print("OPONENTE RECEBEU DANO!")
	print("VIDA RESTANTE: ", vida)

	# EFEITO VISUAL DO IMPACTO
	$CorpoOponente.modulate = Color.RED

	# RECUO
	var direcao_recuo = sign(global_position.x - get_parent().get_node("Jogador").global_position.x)
	global_position.x += direcao_recuo * recuo

	if pode_animar:
		pode_animar = false
		recuperando = true

		# CAIR NO CHAO
		var queda = create_tween()
		queda.set_parallel(true)
		queda.tween_property($CorpoOponente, "rotation_degrees", 90.0, 0.15)
		queda.tween_property($CorpoOponente, "position:y", -10.0, 0.15)

		await queda.finished

		$CorpoOponente.modulate = Color.WHITE

		if vida <= 0:
			derrotado = true
			$CorpoOponente.modulate = Color(0.3, 0.3, 0.3)
			print("OPONENTE DERROTADO!")
		else:
			# TEMPO DE RECUPERACAO
			await get_tree().create_timer(0.5).timeout

			# LEVANTAR
			var levantar = create_tween()
			levantar.set_parallel(true)
			levantar.tween_property($CorpoOponente, "rotation_degrees", 0.0, 0.2)
			levantar.tween_property($CorpoOponente, "position:y", -50.0, 0.2)

			await levantar.finished

		recuperando = false
		pode_animar = true

		
		
		
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += 980.0 * delta
	else:
		velocity.y = 0

	move_and_slide()
