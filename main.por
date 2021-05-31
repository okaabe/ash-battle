programa
{
	inclua biblioteca Graficos
	inclua biblioteca Arquivos
	inclua biblioteca Teclado
	inclua biblioteca Texto
	inclua biblioteca Util
	inclua biblioteca Tipos
	inclua biblioteca Matematica


	/* 
	 *  Define se o jogo está sendo depurado ou não. Quando o jogo está em modo de depuração, 
	 *  algumas informações adicionais aparecem na tela como, por exemplo, a taxa de atualização,
	 *  isto é, a contagem de FPS
	 */
	const logico DEPURANDO = verdadeiro

	/* Constantes que definem as tela do jogo */
	const inteiro TELA_INICIAL = 0, TELA_DE_TURNOS = 1

	/* Constantes que definem os efeitos das habilidades */
	const inteiro EFEITO_STUN = 0, EFEITO_QUEIMADURA = 1
	
	/* Constantes que definem as habilidades do jogador */
	const cadeia JOGADOR_HABILIDADES_NOMES[5] = {"Olhar Da Heresia", "Decreto De Justiça", "Crusada", "Herois Relembrados", "Ataque Solene"}
	const inteiro JOGADOR_HABILIDADES_MANAS[5] = {16, 19, 19, 31, 44}
	const inteiro JOGADOR_HABILIDADES_NIVELS[5] = {10, 10, 10, 10, 10}
	const inteiro JOGADOR_HABILIDADES_EFEITOS[5] = {0, 1, 0, 1, 0}
	const inteiro JOGADOR_HABILIDADES_DANO[5][2] = {{3, 12}, {4, 10}, {4, 12}, {4, 10}, {5, 12}}

	/* Constantes que definem os status iniciais do jogador */
	const inteiro JOGADOR_HP_INICIAL = 300, JOGADOR_MP_INICIAL = 300

	/* Constantes que definem as cores */
	inteiro COR_CINZA = Graficos.criar_cor(211, 211, 211)
	inteiro COR_AZUL = Graficos.criar_cor(113, 146, 221)
	inteiro COR_QUEIMADURA = Graficos.criar_cor(142, 35, 35)
	inteiro COR_AZUL_MANA = Graficos.criar_cor(62, 185, 232)
	inteiro COR_VERDE_HP1 = Graficos.criar_cor(0, 166, 67)
	inteiro COR_VERDE_HP2 = Graficos.criar_cor(0, 214, 91)
	inteiro COR_VERDE_MP1 = Graficos.criar_cor(64, 134, 197)
	inteiro COR_VERDE_MP2 = Graficos.criar_cor(65, 185, 233)
	/* Variáveis utilizadas para controlar o FPS e o tempo de jogo */
	inteiro tempo_inicio_jogo = 0

	inteiro tempo_inicio = 0, tempo_decorrido = 0, tempo_restante = 0, tempo_quadro = 0
	
	inteiro tempo_inicio_fps = 0, tempo_fps = 0, frames = 0, fps = 0

	inteiro tempo_inicio_tela = 0, tempo_inicio_aceleracao = 0, tempo_escolhido_aceleracao = 0


	/* Variáveis que armazenam os endereços de memória das imagens utilizadas no jogo */
	inteiro imagem_background = 0, imagem_inimigo = 0, imagem_prox_turno = 0, imagem_habilidades[5] = {0, 0, 0, 0, 0}

	/* Define quantos quadros serão desenhados por segundo (FPS) */
	const inteiro TAXA_DE_ATUALIZACAO = 85

	/* Variável que definem os indices das entidades */
	inteiro JOGADOR = 0, INIMIGO = 1
	inteiro HP = 0, MP = 1, CON = 2, PREC = 3, AGI = 4, ATK = 5, LUK = 6
	
	inteiro turno_entidade = JOGADOR
	inteiro turno_contador = 0
	
	/* Variáveis que armazenam os status das entidades */
	inteiro MP_MAXIMO = 300, HP_MAXIMO = 300
	inteiro entidades[2][7] = {{300, 300, 10, 20, 80, 30, 15}, {300, 300, 10, 20, 10, 20, 10}}
	inteiro efeitos[2][2] = {{0, 0}, {0, 0}}
	
	/* Variável da habilidade selecionada */
	const inteiro PULAR_TURNO = 5
	inteiro opcao_selecionada = 1
	inteiro mostrar_opcoes_apartir = 0

	/* Variável que armazenam que será lida ou não as teclas pressionada */
	logico pode_teclar = verdadeiro
	/* Variável que armazenam as mensagens dos turnos */
	cadeia turnos[6] = {"", "", "", "", "", ""}


	const inteiro PASS_TURNO = 2, QUEIMADURA = 3
	
	inteiro tela_atual = TELA_INICIAL
	
	funcao inicio() {
		inicializar()

		enquanto (verdadeiro) {
			turno_inimigo()
			iniciar_sincronia_da_taxa_de_atualizacao()
			se (entidades[JOGADOR][HP] <= 0) {
				desenhar_tela_de_derrota()
			} senao se (entidades[INIMIGO][HP] <= 0) {
				desenhar_tela_de_vitoria()
			} senao {
				desenhar_tela_padrao()
				escolha (tela_atual) {
					caso TELA_INICIAL:
						desenhar_tela_inicial()
					pare
					caso TELA_DE_TURNOS:
						desenhar_tela_de_turnos()
					pare
				}
			}
			Graficos.renderizar()
			finalizar_sincronia_da_taxa_de_atualizacao()
		}
	}

	funcao desenhar_tela_de_vitoria () {
		desenhar_texto_com_sombra("VITORIA", 280, 200, Graficos.COR_BRANCO, 15.0)	
	}

	funcao desenhar_tela_de_derrota () {
		desenhar_texto_com_sombra("DERROTA", 280, 200, Graficos.COR_BRANCO, 15.0)	
	}
	
	funcao inicializar () {
		carregar_imagens()
		carregar_fontes()
		Graficos.iniciar_modo_grafico(verdadeiro);
	}

	funcao carregar_imagens () {
		imagem_background = Graficos.carregar_imagem("./imgs/background.jpg")
		imagem_inimigo = Graficos.carregar_imagem("./imgs/inimigo.png")
		imagem_prox_turno = Graficos.carregar_imagem("./imgs/prox_turno.png")

		para (inteiro i = 0; i < 5; i++) {
			imagem_habilidades[i] = Graficos.carregar_imagem("./imgs/habilidades/" + (i + 1) + ".png")
		}
	}

	funcao carregar_fontes () {
		cadeia arquivos[13] = {"", "", "", "", "", "", "", "", "", "", "", "", ""}
		Arquivos.listar_arquivos("./fonts/", arquivos)
		
		para (inteiro i = 0; i < 13; i++) {
			se (checar_se_e_fonte(arquivos[i])) {
				Graficos.carregar_fonte("./fonts/" + arquivos[i])
			}
		}
	}

	funcao iniciar_sincronia_da_taxa_de_atualizacao() {
		tempo_inicio = Util.tempo_decorrido() + tempo_restante
	}

	funcao finalizar_sincronia_da_taxa_de_atualizacao() {
		tempo_decorrido = Util.tempo_decorrido() - tempo_inicio
		tempo_restante = tempo_quadro - tempo_decorrido 

		enquanto (TAXA_DE_ATUALIZACAO > 0 e tempo_restante > 0)
		{
			tempo_decorrido = Util.tempo_decorrido() - tempo_inicio
			tempo_restante = tempo_quadro - tempo_decorrido
		}

		contar_taxa_de_fps()
	}

	funcao contar_taxa_de_fps() {
		frames = frames + 1
		tempo_fps = Util.tempo_decorrido() - tempo_inicio_fps

		se (tempo_fps >= 1000)
		{
			fps = frames
			tempo_inicio_fps = Util.tempo_decorrido() - (tempo_fps - 1000)
			frames = 0
		}
	}

	funcao desenhar_taxa_de_fps()
	{
		se (DEPURANDO)
		{
			Graficos.definir_tamanho_texto(12.0)
			Graficos.definir_cor(0xFFFFFF)
			Graficos.definir_estilo_texto(falso, verdadeiro, falso)
			Graficos.desenhar_texto(1, 1, "FPS: " + fps)
			Graficos.definir_estilo_texto(falso, falso, falso)
		}
	}

	funcao logico checar_se_e_fonte (cadeia arquivo) {
		inteiro caracteres = Texto.numero_caracteres(arquivo)
		cadeia ext = ""

		se (caracteres < 4) {
			retorne falso	
		}
		
		para (inteiro i = caracteres - 4; i < caracteres; i++) {
			ext += Texto.obter_caracter(arquivo, i)
		}
		
		se (ext === ".ttf") {
			retorne verdadeiro
		}
		
		retorne falso
	}

	funcao desenhar_tela_inicial () {
		desenhar_menu_de_habilidades()
		desenhar_seletor_de_hablidade()
		desenhar_informacoes_da_habilidade_selecionada()
		handle_de_teclado_tela_de_habilidade()
	}

	funcao desenhar_tela_de_turnos () {
		desenhar_bloco_rpg_maker(10, 365, 620, 108)
		para (inteiro x = 0; x < 6; x++) {
			se (Texto.numero_caracteres(turnos[x]) > 0) {
				inteiro distintor = pegar_distintor_e_remover(turnos[x])
			
				desenhar_texto_com_sombra(turnos[x], 15, 450 - (x * 15),  cor_do_distintor(distintor), 13.0)
			}
		}
		 handle_teclado_da_tela_de_turnos()
	}

	funcao handle_teclado_da_tela_de_turnos () {
		se (nao pode_teclar) {
			retorne
		}
		
		se (Teclado.tecla_pressionada(Teclado.TECLA_Z) e turno_entidade === JOGADOR) {
			tela_atual = TELA_INICIAL
			handle_do_delay_do_teclado()
		}
	}

	funcao inteiro cor_do_distintor (inteiro distintor) {
		se (distintor === JOGADOR) retorne Graficos.COR_VERDE
		se (distintor === INIMIGO) retorne Graficos.COR_VERMELHO
		se (distintor === PASS_TURNO) retorne Graficos.COR_AZUL
		se (distintor === QUEIMADURA) retorne Graficos.COR_AMARELO
		retorne Graficos.COR_BRANCO
	}

	funcao desenhar_tela_padrao () {
		desenhar_fundo()
		desenhar_inimigo()
		desenhar_status_do_jogador()
		desenhar_status_do_inimigo()
		desenhar_taxa_de_fps()
	}

	funcao desenhar_fundo () {
		Graficos.desenhar_imagem(0, 0, imagem_background)
	}

	funcao desenhar_menu_de_habilidades () {
		desenhar_bloco_da_lista_de_habilidades()
		desenhar_bloco_de_info_da_habilidade_selecionada()
		desenhar_lista_de_habilidades()
		// desenhar_opcao_de_pular_turno()
	}

	funcao desenhar_bloco_rpg_maker (inteiro x, inteiro y, inteiro w, inteiro h) {
		inteiro azul = Graficos.criar_cor(75, 110, 178)
		inteiro azul_escuro = Graficos.criar_cor(0, 18, 86)
		
		Graficos.definir_gradiente(Graficos.GRADIENTE_ABAIXO, azul, azul_escuro)
		Graficos.desenhar_retangulo(x, y, w, h, verdadeiro, verdadeiro)

		// Sombra da Borda
		desenhar_sombra_retangular(x + 1, y + 1, w, h, verdadeiro, falso, 100)
		desenhar_sombra_retangular(x - 1, y - 1, w, h, verdadeiro, falso, 100)
		
		// Borda
		Graficos.definir_cor(Graficos.COR_BRANCO)
		Graficos.desenhar_retangulo(x, y, w, h, verdadeiro, falso)
	}

	funcao desenhar_sombra_retangular (inteiro x, inteiro y, inteiro largura, inteiro altura, logico arredondar_cantos, logico preencher, inteiro opacidade) {
		Graficos.definir_cor(Graficos.COR_PRETO)
		Graficos.definir_opacidade(opacidade)
		Graficos.desenhar_retangulo(x, y, largura, altura, arredondar_cantos, preencher)
		Graficos.definir_opacidade(255)
	}
	
	funcao desenhar_bloco_da_lista_de_habilidades () {
		desenhar_bloco_rpg_maker(5, 365, 400, 108)
	}

	funcao desenhar_bloco_de_info_da_habilidade_selecionada () {
		desenhar_bloco_rpg_maker(430, 365, 200, 108)
	}
	
	funcao desenhar_lista_de_habilidades () {
		para (inteiro i = 0; i < 4; i++) {
			inteiro indice = i + mostrar_opcoes_apartir
			se (indice === 5) {
				desenhar_opcao_no_menu("Pass Turn", "", 15, pegar_posicao_y_da_habilidade(i))
			} senao se (indice > 5) {
				desenhar_habilidade(indice - 6, 15, pegar_posicao_y_da_habilidade(i))
			} senao {			
				desenhar_habilidade(indice, 15, pegar_posicao_y_da_habilidade(i))
			}
		}
	}

	funcao inteiro pegar_posicao_y_da_habilidade (inteiro endereco) {
		const inteiro y = 370
		se (endereco >= 4) {
			retorne ((endereco - 4) * 25) + y
		}
		retorne ((endereco) * 25) + y
	}

	funcao desenhar_opcao_no_menu (cadeia titulo, cadeia dano, inteiro x, inteiro, y) {
		desenhar_texto_com_sombra(titulo, x, y, Graficos.COR_BRANCO, 17.0)
		desenhar_texto_com_sombra(dano, x + 340, y, Graficos.COR_VERDE, 17.0)
	}
	
	funcao desenhar_habilidade (inteiro endereco, inteiro x, inteiro y) {
		desenhar_opcao_no_menu(JOGADOR_HABILIDADES_NOMES[endereco],  transformar_dano_da_habilidade_em_cadeia(endereco), x, y)
	}

	funcao cadeia transformar_dano_da_habilidade_em_cadeia (inteiro endereco) {
		retorne JOGADOR_HABILIDADES_DANO[endereco][0] + "d" + JOGADOR_HABILIDADES_DANO[endereco][1]
	}

	funcao desenhar_texto_com_sombra(cadeia titulo, inteiro x, inteiro y, inteiro cor, real tamanho) {
		Graficos.definir_tamanho_texto(tamanho)
		Graficos.definir_fonte_texto("Roboto")
		// sombra
		Graficos.definir_cor(Graficos.COR_PRETO)
		Graficos.desenhar_texto(x + 1, y + 6, titulo)

		Graficos.definir_cor(cor)
		Graficos.desenhar_texto(x + 2, y + 5, titulo)
	}

	funcao desenhar_seletor_de_hablidade () {
		inteiro y = pegar_pos_y_do_seletor()
		Graficos.definir_cor(Graficos.COR_BRANCO)
		// Borda
		Graficos.desenhar_retangulo(13, y, 385, 20, verdadeiro, falso)
		Graficos.definir_opacidade(30)
		Graficos.desenhar_retangulo(13, y, 385, 20, verdadeiro, verdadeiro)
		Graficos.definir_opacidade(255)
	}

	funcao inteiro pegar_pos_y_do_seletor () {
		para (inteiro i = 0; i < 4; i++) {
			se (pegar_opcao__mostrada(i) === opcao_selecionada) {
				retorne 370 + (i * 25)
			}
		}
		retorne 370
	}

	funcao inteiro pegar_opcao__mostrada (inteiro contador) {
		se (mostrar_opcoes_apartir + contador > 5) {
			retorne ((mostrar_opcoes_apartir + contador) % 5) - 1 
		}
		retorne mostrar_opcoes_apartir + contador
	}

	funcao handle_de_teclado_tela_de_habilidade () {
		se (nao pode_teclar) {
			retorne
		}
		
		se (Teclado.tecla_pressionada(Teclado.TECLA_SETA_ACIMA) ou Teclado.tecla_pressionada(Teclado.TECLA_W)) {
			se (mostrar_opcoes_apartir === opcao_selecionada) {
				mostrar_opcoes_apartir = pegar_opcao_anterior(mostrar_opcoes_apartir)
			}
			opcao_selecionada = pegar_opcao_anterior(opcao_selecionada)
			handle_do_delay_do_teclado()
		} senao se (Teclado.tecla_pressionada(Teclado.TECLA_SETA_ABAIXO) ou Teclado.tecla_pressionada(Teclado.TECLA_S)) {
			se (opcao_selecionada === pegar_opcao__mostrada(3)) {
				mostrar_opcoes_apartir = pegar_proxima_opcao(mostrar_opcoes_apartir)
			}
			opcao_selecionada = pegar_proxima_opcao(opcao_selecionada)
			handle_do_delay_do_teclado()
		}

		se (Teclado.tecla_pressionada(Teclado.TECLA_Z)) {
			turno(JOGADOR, opcao_selecionada)
			turno_inimigo()
			handle_do_delay_do_teclado()
		}
	}

	funcao inteiro pegar_opcao_anterior (inteiro atual) {
		se (atual <= 0) retorne 5
		retorne atual - 1
	}

	funcao inteiro pegar_proxima_opcao (inteiro atual) {
		se (atual >= 5) retorne 0
		retorne atual + 1
	}

	funcao desenhar_informacoes_da_habilidade_selecionada () {
		se (opcao_selecionada === 5) {
			retorne
		} senao {
			desenhar_titulo_e_icone_da_habilidade_no_bloco_de_informacao(opcao_selecionada)
			desenhar_informacao_da_habilidade(
				"Nivel", 
				Tipos.inteiro_para_cadeia(JOGADOR_HABILIDADES_NIVELS[opcao_selecionada], 10),
				Graficos.COR_BRANCO,
				600,
				0
			)
			desenhar_informacao_da_habilidade(
				"Dano", 
				transformar_dano_da_habilidade_em_cadeia(opcao_selecionada),
				Graficos.COR_BRANCO,
				580,
				1
			)
			desenhar_informacao_da_habilidade(
				"Mana",
				Tipos.inteiro_para_cadeia(JOGADOR_HABILIDADES_MANAS[opcao_selecionada], 10),
				COR_AZUL_MANA,
				600,
				2
			)
			desenhar_informacao_da_habilidade(
				"Efeito",
				pegar_nome_do_efeito_da_habilidade(JOGADOR_HABILIDADES_EFEITOS[opcao_selecionada]),
				Graficos.COR_AMARELO,
				pegar_y_do_efeito_da_habilidade(JOGADOR_HABILIDADES_EFEITOS[opcao_selecionada]),
				3
			)
		}
	}
	
 	funcao desenhar_titulo_e_icone_da_habilidade_no_bloco_de_informacao (inteiro endereco) {
 		Graficos.desenhar_porcao_imagem(440, 370, 0, 0, 20, 20, imagem_habilidades[endereco])
 		desenhar_texto_com_sombra(JOGADOR_HABILIDADES_NOMES[endereco], 465, 370, Graficos.COR_BRANCO, 17.0)
 	}
 	
	funcao desenhar_informacao_da_habilidade (cadeia titulo, cadeia valor, inteiro cor_do_valor, inteiro x_do_valor, inteiro ordem) {
		desenhar_texto_com_sombra(titulo, 440, 400 + (15 * ordem), COR_AZUL, 17.0)
		desenhar_texto_com_sombra(valor, x_do_valor, 400 + (15 * ordem), cor_do_valor, 17.0)
	}

	funcao cadeia pegar_nome_do_efeito_da_habilidade (inteiro efeito) {
		cadeia nome = "Nenhum"
		escolha (efeito)
		{
		caso EFEITO_STUN:
		 nome = "Stun"
		pare
		caso EFEITO_QUEIMADURA:	
		 nome = "Queimadura"
		pare
		}
		retorne nome
	}

	funcao inteiro pegar_y_do_efeito_da_habilidade (inteiro efeito) {
		inteiro y = 600
		escolha (efeito)
		{
		caso EFEITO_STUN:
		 y = 585
		pare
		caso EFEITO_QUEIMADURA:	
		 y = 528
		pare
		}
		retorne y
	}
	
	funcao handle_do_delay_do_teclado () {
		pode_teclar = falso
		Util.aguarde(170)
		pode_teclar = verdadeiro
	}

	funcao desenhar_status_do_jogador () {
		 desenhar_barra(5, 15, 0, COR_VERDE_HP1, COR_VERDE_HP2, entidades[JOGADOR][HP],  HP_MAXIMO)
		 desenhar_barra(5, 30, 0, COR_VERDE_MP1, COR_VERDE_MP2, entidades[JOGADOR][MP], MP_MAXIMO)
		
		 const inteiro local_maximo = 312
		 
		 cadeia hp =entidades[JOGADOR][HP] + "/" + HP_MAXIMO
		 desenhar_texto_de_barra("HP",  4, 7)
		 desenhar_texto_de_barra(hp, local_maximo - Graficos.largura_texto(hp), 10)
		 cadeia mp = entidades[JOGADOR][MP] + "/" + MP_MAXIMO
		 desenhar_texto_de_barra("MP",  4, 20)
		 desenhar_texto_de_barra(mp, local_maximo - Graficos.largura_texto(mp) , 25)
	}

	funcao desenhar_status_do_inimigo () {
		desenhar_barra(320, 15, 1, Graficos.COR_VERMELHO, Graficos.COR_VERMELHO, entidades[INIMIGO][HP],  HP_MAXIMO)
		desenhar_barra(320, 30, 1, COR_VERDE_MP1, COR_VERDE_MP2,entidades[INIMIGO][MP], MP_MAXIMO)
		
		 desenhar_texto_de_barra("HP",  615, 7)
		 desenhar_texto_de_barra(entidades[INIMIGO][HP] + "/" + HP_MAXIMO, 320, 10)
		 desenhar_texto_de_barra("MP",  615, 20)
		 desenhar_texto_de_barra(entidades[INIMIGO][MP] + "/" + MP_MAXIMO, 320, 25)
	}
	
	funcao desenhar_barra (inteiro x, inteiro y, inteiro barra, inteiro cor_da_barra1, inteiro cor_da_barra, inteiro quantidade_atual, inteiro quantidade_maxima) {
		const inteiro altura = 10, largura = 310
		// parte sem conteudo
		desenhar_sombra_retangular(x, y, largura, altura, falso, verdadeiro, 200)
		// conteudo da barra
		inteiro tamanho_da_barra = pegar_porcentagem(largura, quantidade_maxima, quantidade_atual)
		Graficos.definir_gradiente(Graficos.GRADIENTE_DIREITA, cor_da_barra, cor_da_barra)
		Graficos.desenhar_retangulo(
			pegar_x_da_barra_interna(barra, x, largura, tamanho_da_barra),
			y,
			tamanho_da_barra,
			altura,
			falso,
			verdadeiro
		)
		desenhar_borda_da_barra(x, y, largura, altura)
	}

	funcao inteiro pegar_x_da_barra_interna (inteiro lado, inteiro x, inteiro largura, inteiro tamanho_da_barra) {
		se (lado === 1) {
			retorne x
		}
		retorne (x + largura) - tamanho_da_barra
	}

	funcao desenhar_borda_da_barra (inteiro x, inteiro y, inteiro largura, inteiro altura) {
		// Sombra 
		desenhar_sombra_retangular(x + 1, y + 1, largura, altura, verdadeiro, falso, 100)
		desenhar_sombra_retangular(x - 1, y - 1, largura, altura, verdadeiro, falso, 100)
		
		// Borda
		Graficos.definir_cor(Graficos.COR_BRANCO)
		Graficos.desenhar_retangulo(x, y, largura, altura, verdadeiro, falso)
	}
 
	funcao desenhar_texto_de_barra (cadeia texto, inteiro x, inteiro y) {
		Graficos.definir_estilo_texto(falso, verdadeiro, falso)
		desenhar_texto_com_sombra(
			texto,
			x,
			y,
			Graficos.COR_BRANCO,
			10.0
		)
		Graficos.definir_estilo_texto(falso, falso, falso)
	}

	funcao inteiro pegar_porcentagem (inteiro x, inteiro y, inteiro por) {
		retorne Tipos.real_para_inteiro(Tipos.inteiro_para_real(x) / Tipos.inteiro_para_real(y) * por)
	}

	funcao desenhar_inimigo () {	
		Graficos.desenhar_imagem(30, 30, imagem_inimigo)
	}

	funcao turno (inteiro entidade, inteiro opcao_escolhida) {
		se (efeitos[entidade][EFEITO_STUN] > 0) {
			adicionar_mensagem(entidade_nome(entidade) + " esta stuando e perdeu seu turno", entidade)
			efeitos[entidade][EFEITO_STUN] -= 1
			trocar_de_turno(entidade)
			retorne
		}

		se (efeitos[entidade][EFEITO_QUEIMADURA] > 1) {
			entidades[entidade][HP] -= 3
			adicionar_mensagem(entidade_nome(entidade) + " esta queimando e perdeu 3 de vida", entidade)
			efeitos[entidade][EFEITO_QUEIMADURA] -= 1
		}
		
		se (opcao_escolhida === PULAR_TURNO) {
			entidades[entidade][MP] = adicionar(entidades[entidade][MP], 50, MP_MAXIMO)
			adicionar_mensagem(entidade_nome(entidade) + " pulou o turno e recuperou 50 de mana", entidade)
		} senao {
			se (entidades[entidade][MP] < JOGADOR_HABILIDADES_MANAS[opcao_escolhida]) {
				retorne
			}
			
			adicionar_mensagem(entidade_nome(entidade) + " usou " + JOGADOR_HABILIDADES_NOMES[opcao_escolhida], entidade)
			entidades[entidade][MP] -= JOGADOR_HABILIDADES_MANAS[opcao_escolhida]
			se (nao chance_de_esquivar(entidade)) {
				inteiro dano_causado = dano_da_habilidade(opcao_escolhida) + entidades[entidade][ATK]
				adicionar_mensagem(JOGADOR_HABILIDADES_NOMES[opcao_escolhida] + " causou " + dano_causado + " de dano", entidade)
				entidades[pegar_adversario(entidade)][HP] -= dano_causado
				se (causar_efeito(entidade, opcao_escolhida)) {
					efeitos[pegar_adversario(entidade)][JOGADOR_HABILIDADES_EFEITOS[opcao_escolhida]] += 1
					adicionar_mensagem(
						entidade_nome(pegar_adversario(entidade)) + " recebeu o efeito " + pegar_nome_do_efeito_da_habilidade(JOGADOR_HABILIDADES_EFEITOS[opcao_selecionada]),
						pegar_adversario(entidade)
						)
				} senao {
					adicionar_mensagem(
						entidade_nome(pegar_adversario(entidade)) + " não recebeu o efeito de " + pegar_nome_do_efeito_da_habilidade(JOGADOR_HABILIDADES_EFEITOS[opcao_selecionada]),
						pegar_adversario(entidade)			
						)
				}
			} senao {
				adicionar_mensagem(entidade_nome(pegar_adversario(entidade)) + " evadiu", pegar_adversario(entidade))
			}
		}

		trocar_de_turno(entidade)

		se (entidade === JOGADOR) {
			tela_atual = TELA_DE_TURNOS
		}
	}

	funcao trocar_de_turno (inteiro entidade) {
		turno_entidade = pegar_adversario(entidade)
		turno_contador += 1
	}
	
	funcao cadeia entidade_nome (inteiro entidade) {
		se (entidade === JOGADOR) {
			retorne "JOGADOR"
		}
		retorne "INIMIGO"
	}

	funcao inteiro dano_da_habilidade (inteiro habilidade) {
		retorne Util.sorteia(JOGADOR_HABILIDADES_DANO[habilidade][0], JOGADOR_HABILIDADES_DANO[habilidade][1])
	}

	funcao inteiro adicionar (inteiro valor, inteiro quantia, inteiro maximo) {
		se ((valor + quantia) > maximo) {
			retorne maximo
		} senao {
			retorne valor + quantia
		}
	}

	funcao inteiro pegar_adversario (inteiro entidade) {
		se (entidade === JOGADOR) {
			retorne INIMIGO
		}
		retorne JOGADOR
	}

	funcao logico chance_de_esquivar (inteiro entidade) {
		retorne Util.sorteia(0, 20) + entidades[entidade][PREC] > Util.sorteia(0, 16) + entidades[entidade][AGI]
	}

	funcao inteiro chance_de_causar_efeito (inteiro nivel_da_habilidade) {
		retorne (nivel_da_habilidade - 1) - 100
	}
	
	funcao logico causar_efeito (inteiro entidade, inteiro habilidade) {
		inteiro chance = Util.sorteia(1, 100) + entidades[entidade][LUK]
		se (chance >= chance_de_causar_efeito(JOGADOR_HABILIDADES_NIVELS[habilidade])) {
			retorne verdadeiro
		}
		retorne falso
	}

	funcao adicionar_mensagem (cadeia mensagem, inteiro entidade) {
		escreva(mensagem, "\n")
		add_valor(entidade + " " + mensagem)
	}

	funcao cadeia pegar_distintor_de_entidade (inteiro entidade) {
		se (entidade === JOGADOR) retorne ">>"
		retorne "<<"
	}

	funcao add_valor (cadeia novo) {
		cadeia proximo = novo
		para (inteiro i = 0; i < 6 e proximo !== ""; ++i) {
			cadeia valor = turnos[i]
			turnos[i] = proximo
			proximo = valor
			escreva("---", turnos[i], "\n")
		}
	}

	funcao turno_inimigo () {
		se (turno_entidade === INIMIGO) {
			turno(INIMIGO, Util.sorteia(0, 5))
		}
	}
	
	funcao inteiro pegar_distintor_e_remover(cadeia texto) {
		 caracter distintor = Texto.obter_caracter(texto, 0)
		 Texto.substituir(texto, Tipos.caracter_para_cadeia(distintor), "")
		 retorne Tipos.caracter_para_inteiro(distintor)
	}
	
}
/* $$$ Portugol Studio $$$ 
 * 
 * Esta seção do arquivo guarda informações do Portugol Studio.
 * Você pode apagá-la se estiver utilizando outro editor.
 * 
 * @POSICAO-CURSOR = 3540; 
 * @DOBRAMENTO-CODIGO = [147, 151, 164, 176, 188, 237, 245, 253, 257, 264, 280, 287, 295, 308, 316, 321, 325, 329, 340, 350, 359];
 * @PONTOS-DE-PARADA = ;
 * @SIMBOLOS-INSPECIONADOS = ;
 * @FILTRO-ARVORE-TIPOS-DE-DADO = inteiro, real, logico, cadeia, caracter, vazio;
 * @FILTRO-ARVORE-TIPOS-DE-SIMBOLO = variavel, vetor, matriz, funcao;
 */