# res://src/map/StoryCampaignData.gd
class_name StoryCampaignData
extends RefCounted

## Estrutura de dados centralizada dos 4 Mundos e 24 Fases do Modo História
const WORLDS = [
	{
		"id": 1,
		"title": "Mundo 1: Academia Ninja",
		"subtitle": "Os Primeiros Passos de um Shinobi & País das Ondas",
		"icon": "🏫",
		"stages": [
			{
				"id": "stage_1_0",
				"number": "1.0",
				"title": "Naruto e Iruka vs Mizuki",
				"subtitle": "O Pergaminho Proibido (Tutorial do Jogo)",
				"desc": "Mizuki enganou Naruto para roubar o Pergaminho dos Selos! Iruka protege seu aluno com a própria vida, e Naruto desperta o poder dos Clones das Sombras.",
				"hero_options": ["naruto", "iruka"],
				"enemy_id": "mizuki",
				"is_tutorial": true,
				"dialogue": [
					{"speaker": "Mizuki", "text": "Entregue o pergaminho, Naruto! Você nunca será aceito nesta vila... você é apenas o monstro da Raposa!"},
					{"speaker": "Iruka Umino", "text": "Naruto não é um monstro! Ele é um ninja brilhante de Konohagakure!"},
					{"speaker": "Naruto Uzumaki", "text": "Se você encostar um dedo no Iruka-sensei... EU TE MATO! Jutsu Multi-Clones das Sombras!"}
				]
			},
			{
				"id": "stage_1_1",
				"number": "1.1",
				"title": "Equipe 7 vs Kakashi",
				"subtitle": "O Treinamento dos Sinos",
				"desc": "O teste de sobrevivência de Kakashi Hatake. Apenas quem compreender o verdadeiro significado do trabalho em equipe passará!",
				"hero_options": ["naruto", "sasuke", "sakura"],
				"enemy_id": "kakashi",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Kakashi Hatake", "text": "Vocês têm até o meio-dia para pegar um desses guizos de mim. Venham com a intenção de matar!"},
					{"speaker": "Naruto Uzumaki", "text": "Eu vou pegar um desses sinos e virar Genin de verdade!"},
					{"speaker": "Sasuke Uchiha", "text": "Não fique no meu caminho, Naruto. Eu vou derrotar esse Jounin sozinho."}
				]
			},
			{
				"id": "stage_1_2",
				"number": "1.2",
				"title": "Kakashi vs Zabuza",
				"subtitle": "O Demônio da Névoa Oculta",
				"desc": "Zabuza Momochi ataca a ponte no País das Ondas envolto em uma névoa espessa. Kakashi revela o olho do Sharingan!",
				"hero_options": ["kakashi"],
				"enemy_id": "zabuza",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Zabuza Momochi", "text": "Kakashi do Olho Compartilhado... será uma honra manchar minha Kubikiribōchō com o seu sangue!"},
					{"speaker": "Kakashi Hatake", "text": "Sua ambição termina aqui, Zabuza. Vou mostrar o jutsu copiado de mil técnicas!"}
				]
			},
			{
				"id": "stage_1_3",
				"number": "1.3",
				"title": "Sasuke e Naruto vs Haku",
				"subtitle": "Os Espelhos Demoníacos de Gelo",
				"desc": "Presos dentro da cúpula de gelo de Haku, Naruto e Sasuke precisam lutar sincronizados para quebrar a velocidade absoluta do Kekkei Genkai.",
				"hero_options": ["naruto", "sasuke"],
				"enemy_id": "haku",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Haku Yuki", "text": "Eu não desejo matá-los, mas protegerei os sonhos de Zabuza com todo o meu ser."},
					{"speaker": "Sasuke Uchiha", "text": "Meus olhos... agora consigo ver a trajetória dele! Naruto, prepare o ataque!"},
					{"speaker": "Naruto Uzumaki", "text": "Não subestime a nossa determinação ninja!"}
				]
			}
		]
	},
	{
		"id": 2,
		"title": "Mundo 2: Exame Chunin",
		"subtitle": "A Floresta da Morte e o Torneio das Preliminares",
		"icon": "🏆",
		"stages": [
			{
				"id": "stage_2_0",
				"number": "2.0",
				"title": "Sasuke vs Rock Lee",
				"subtitle": "Desafio no Corredor da Academia",
				"desc": "Rock Lee desafia o gênio dos Uchiha antes da inscrição do Exame Chunin para provar o poder do esforço físico puro contra o Sharingan.",
				"hero_options": ["rock_lee"],
				"enemy_id": "sasuke",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Rock Lee", "text": "Uchiha Sasuke! Prove se a linhagem do Sharingan é capaz de acompanhar a velocidade do meu Taijutsu!"},
					{"speaker": "Sasuke Uchiha", "text": "Sobrancelhudo... você vai se arrepender de ter me desafiado!"}
				]
			},
			{
				"id": "stage_2_1",
				"number": "2.1",
				"title": "Equipe 7 vs Orochimaru",
				"subtitle": "Terror na Floresta da Morte",
				"desc": "O lendário Sannin Orochimaru infiltra-se na Floresta da Morte em busca do corpo de Sasuke, liberando um Chakra aterrorizante.",
				"hero_options": ["naruto", "sasuke", "sakura"],
				"enemy_id": "orochimaru",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Orochimaru", "text": "Que olhos fascinantes você tem, Sasuke-kun... Mostre-me todo o ódio que você guarda no coração!"},
					{"speaker": "Naruto Uzumaki", "text": "Ei, você com cara de cobra! Não ouse tocar nos meus companheiros!"}
				]
			},
			{
				"id": "stage_2_2",
				"number": "2.2",
				"title": "Rock Lee e Sakura vs Equipe Dosu",
				"subtitle": "Emboscada dos Ninjas do Som",
				"desc": "Com Naruto e Sasuke desacordados, Sakura e Rock Lee enfrentam Dosu, Zaku e Kin para proteger seus amigos.",
				"hero_options": ["rock_lee", "sakura"],
				"enemy_id": "dosu",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Dosu Kinuta", "text": "Garotinha patética, você não tem a menor chance contra as vibrações sonoras do nosso vilarejo."},
					{"speaker": "Sakura Haruno", "text": "Eu cansei de ser sempre aquela que é protegida pelas costas dos outros!"},
					{"speaker": "Rock Lee", "text": "A Fera Verde de Konoha chegou! Uma flor que desabrocha com tanta coragem deve ser defendida até o fim!"}
				]
			},
			{
				"id": "stage_2_3",
				"number": "2.3",
				"title": "Naruto vs Kiba",
				"subtitle": "Eliminatórias Chunin: Instinto Selvagem",
				"desc": "Kiba e Akamaru zombam do sonho de Naruto de ser Hokage. Uma luta imprevisível que testará a criatividade de Naruto!",
				"hero_options": ["naruto"],
				"enemy_id": "kiba",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Kiba Inuzuka", "text": "Desiste, Naruto! Você sempre foi o último da classe. Hokage? Você nem me passa!"},
					{"speaker": "Naruto Uzumaki", "text": "Nunca subestime quem nunca volta atrás na própria palavra! Vamos lá, Kiba!"}
				]
			},
			{
				"id": "stage_2_4",
				"number": "2.4",
				"title": "Hinata vs Neji",
				"subtitle": "O Conflito de Linhagem dos Hyuga",
				"desc": "Neji confronta sua prima Hinata na arena preliminar, afirmando friamente que os perdedores jamais podem mudar seu destino.",
				"hero_options": ["neji"],
				"enemy_id": "hinata",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Neji Hyuga", "text": "Um pássaro engaiolado não pode escolher seu voo, Hinata-sama. Desista agora ou será destruída."},
					{"speaker": "Hinata Hyuga", "text": "Eu nunca mais vou fugir... Vendo o Naruto-kun lutar, aprendi a ter coragem!"}
				]
			},
			{
				"id": "stage_2_5",
				"number": "2.5",
				"title": "Rock Lee vs Gaara",
				"subtitle": "Velocidade Extrema vs Defesa Absoluta",
				"desc": "A lendária batalha das preliminares Chunin! A areia de Gaara suportará a abertura dos Portões Internos de Lee?",
				"hero_options": ["gaara"],
				"enemy_id": "rock_lee",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Gaara", "text": "Minha areia existe apenas para se alimentar do seu sangue. Você não é nada diante de mim."},
					{"speaker": "Rock Lee", "text": "Guy-sensei... por favor, me deixe mostrar a ele o poder dos Oito Portões Internos!"}
				]
			},
			{
				"id": "stage_2_6",
				"number": "2.6",
				"title": "Naruto vs Neji",
				"subtitle": "A Grande Final: Mudando o Destino",
				"desc": "Naruto sobe à arena principal para honrar a promessa feita a Hinata e quebrar o dogma de Neji sobre o destino inevitável.",
				"hero_options": ["naruto"],
				"enemy_id": "neji",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Neji Hyuga", "text": "Perdedor uma vez, perdedor para sempre. O destino é imutável desde o nascimento."},
					{"speaker": "Naruto Uzumaki", "text": "Cala a boca com essa ladainha de destino! Quando eu for Hokage, vou mudar todo o Clã Hyuga!"}
				]
			},
			{
				"id": "stage_2_7",
				"number": "2.7",
				"title": "Sasuke vs Gaara",
				"subtitle": "O Chidori Perfura a Areia",
				"desc": "Sasuke surge no último segundo treinado por Kakashi, desferindo a eletricidade perfurante do Chidori contra a esfera de areia de Gaara.",
				"hero_options": ["sasuke"],
				"enemy_id": "gaara",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Gaara", "text": "Minha mãe clama pelo seu sangue... eu vou devorar a sua carne!"},
					{"speaker": "Sasuke Uchiha", "text": "Você fala demais. Vamos ver se a sua areia consegue segurar os mil pássaros relâmpago!"}
				]
			}
		]
	},
	{
		"id": 3,
		"title": "Mundo 3: Esmaga Konoha e Busca por Tsunade",
		"subtitle": "A Queda do Terceiro Hokage e a Batalha dos Três Sannin",
		"icon": "🐍",
		"stages": [
			{
				"id": "stage_3_0",
				"number": "3.0",
				"title": "Sarutobi vs Orochimaru",
				"subtitle": "O Sacrifício do Fogo (Shiki Fūjin)",
				"desc": "No topo do telhado protegido pela barreira dos Quatro do Som, o 3º Hokage invoca o Selo Ceifeiro da Morte para selar o mal de seu discípulo.",
				"hero_options": ["sarutobi"],
				"enemy_id": "orochimaru",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Orochimaru", "text": "Sarutobi-sensei... você está velho e fraco. Konoha será reduzida a cinzas sob o meu comando!"},
					{"speaker": "Hiruzen Sarutobi", "text": "Onde as folhas caem, o fogo queima... e novas folhas nascem! Não permitirei que destrua a nossa vila!"}
				]
			},
			{
				"id": "stage_3_1",
				"number": "3.1",
				"title": "Sasuke e Naruto vs Gaara",
				"subtitle": "O Despertar do Shukaku",
				"desc": "Nas florestas nos arredores de Konoha, Gaara perde o controle e inicia a transformação na Besta de Uma Cauda.",
				"hero_options": ["naruto", "sasuke"],
				"enemy_id": "gaara",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Gaara", "text": "Eu finalmente sou livre... O sangue de vocês será a oferenda para a minha existência!"},
					{"speaker": "Naruto Uzumaki", "text": "Sasuke está ferido... Se eu não parar esse cara agora, todo mundo vai morrer!"}
				]
			},
			{
				"id": "stage_3_2",
				"number": "3.2",
				"title": "Kakashi vs Itachi",
				"subtitle": "A Invasão da Akatsuki & O Pesadelo de 72 Horas",
				"desc": "Itachi e Kisame chegam a Konoha. Kakashi os intercepta sobre o lago, enfrentando a ilusão inescapável do Mangekyou Sharingan.",
				"hero_options": ["itachi"],
				"enemy_id": "kakashi",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Kakashi Hatake", "text": "Itachi Uchiha... o que você e sua organização estão buscando nesta aldeia?"},
					{"speaker": "Itachi Uchiha", "text": "Kakashi-san, você não possui a linhagem genuína. No mundo do Tsukuyomi, o tempo e o espaço são controlados por mim."}
				]
			},
			{
				"id": "stage_3_3",
				"number": "3.3",
				"title": "Naruto vs Kabuto",
				"subtitle": "A Conclusão do Rasengan",
				"desc": "Em um confronto tenso nos arredores de Tanzaku, Naruto arrisca a própria mão para prender Kabuto e desferir o Rasengan final!",
				"hero_options": ["naruto"],
				"enemy_id": "kabuto",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Kabuto Yakushi", "text": "Você é apenas uma criança imprestável, Naruto. Seus músculos foram cortados pelas minhas lâminas de chakra!"},
					{"speaker": "Naruto Uzumaki", "text": "Eu prometi para a vovó Tsunade que dominaria esse jutsu... TOMA ISSO! RASENGAN!"}
				]
			},
			{
				"id": "stage_3_4",
				"number": "3.4",
				"title": "Jiraiya e Tsunade vs Orochimaru",
				"subtitle": "O Duelo dos Lendários Três Sannin",
				"desc": "Gamabunta, Katsuyu e Manda colidem na maior batalha de invocações do Naruto Clássico. Tsunade supera sua fobia de sangue!",
				"hero_options": ["jiraiya", "tsunade"],
				"enemy_id": "orochimaru",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Orochimaru", "text": "Tsunade... você rejeitou a proposta de curar meus braços em troca daqueles que você ama. Agora sofrerá as consequências!"},
					{"speaker": "Tsunade Senju", "text": "A partir de agora, eu arriscarei minha própria vida! Eu sou a Quinta Hokage da Aldeia da Folha!"},
					{"speaker": "Jiraiya", "text": "Bora nessa, Tsunade! Vamos mostrar para essa cobra como se luta de verdade!"}
				]
			}
		]
	},
	{
		"id": 4,
		"title": "Mundo 4: Resgate do Sasuke",
		"subtitle": "A Travessia do País do Fogo e o Clímax no Vale do Fim",
		"icon": "🌲",
		"stages": [
			{
				"id": "stage_4_0",
				"number": "4.0",
				"title": "Naruto vs Sasuke",
				"subtitle": "Conflito no Telhado do Hospital",
				"desc": "Tomado pelo ciúme e complexo de inferioridade após o despertar do Selo Amaldiçoado, Sasuke desafia Naruto para um combate no telhado.",
				"hero_options": ["naruto"],
				"enemy_id": "sasuke",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Sasuke Uchiha", "text": "Naruto! Lute comigo agora! Eu quero saber o quanto você realmente melhorou!"},
					{"speaker": "Naruto Uzumaki", "text": "Sasuke, por que você está tão furioso?! Se é isso que você quer, eu não vou fugir!"}
				]
			},
			{
				"id": "stage_4_1",
				"number": "4.1",
				"title": "Chouji vs Jirobo",
				"subtitle": "A Pílula Vermelha da Coragem",
				"desc": "Chouji fica para trás enfrentando o brutamontes do Quarteto do Som para que seus amigos continuem a perseguição.",
				"hero_options": ["chouji"],
				"enemy_id": "jirobo",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Jirobo", "text": "Você é apenas o gordo inútil deixado para trás como lixo pelo seu bando."},
					{"speaker": "Chouji Akimichi", "text": "Você pode comer o último pedaço de carne... mas zombar do meu melhor amigo Shikamaru É IMPERDOÁVEL!"}
				]
			},
			{
				"id": "stage_4_2",
				"number": "4.2",
				"title": "Neji vs Kidomaru",
				"subtitle": "A Flecha Negra e o Ponto Cego",
				"desc": "Kidomaru descobre o ponto cego de 1 grau na nuca de Neji. Neji precisa usar seu próprio corpo como fio condutor de Chakra para contra-atacar!",
				"hero_options": ["neji"],
				"enemy_id": "kidomaru",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Kidomaru", "text": "Te peguei, passarinho! Minha flecha do Selo Nível 2 vai atravessar seu coração a quilômetros de distância!"},
					{"speaker": "Neji Hyuga", "text": "Naruto me disse que eu não sou um fracassado... Eu não vou perder até que Sasuke volte para casa!"}
				]
			},
			{
				"id": "stage_4_3",
				"number": "4.3",
				"title": "Kiba vs Sakon e Ukon",
				"subtitle": "A Fusão Demoníaca dos Irmãos Siameses",
				"desc": "Kiba e Akamaru enfrentam os gêmeos monstruosos do Som que são capazes de fundir suas células diretamente no corpo do oponente.",
				"hero_options": ["kiba"],
				"enemy_id": "sakon_ukon",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Sakon e Ukon", "text": "Que cachorro patético... Vamos entrar nos seus ossos e destruí-lo de dentro para fora!"},
					{"speaker": "Kiba Inuzuka", "text": "Akamaru, não temos medo! JINTŪROU: LOBO DE DUAS CABEÇAS!"}
				]
			},
			{
				"id": "stage_4_4",
				"number": "4.4",
				"title": "Shikamaru vs Tayuya",
				"subtitle": "Estratégia das Sombras contra a Flauta da Ilusão",
				"desc": "Shikamaru calcula dezenas de movimentos à frente para quebrar o ritmo dos golens espectrais de Tayuya quebrando os próprios dedos para escapar do Genjutsu.",
				"hero_options": ["shikamaru"],
				"enemy_id": "tayuya",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Tayuya", "text": "Moleque preguiçoso de merda... Minha melodia da morte vai triturar a sua mente!"},
					{"speaker": "Shikamaru Nara", "text": "Que saco... mulheres são tão problemáticas. Mas como líder desse pelotão, é meu dever vencer você aqui!"}
				]
			},
			{
				"id": "stage_4_5",
				"number": "4.5",
				"title": "Rock Lee e Gaara vs Kimimaro",
				"subtitle": "A Dança das Samambaias de Ossos",
				"desc": "Recém-operado, Lee chega para resgatar Naruto usando o Punho Embriagado, e recebe o apoio decisivo da areia de Gaara!",
				"hero_options": ["rock_lee", "gaara"],
				"enemy_id": "kimimaro",
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Kimimaro Kaguya", "text": "Eu sou o osso mais leal a Orochimaru-sama. Ninguém impedirá o recipiente de chegar até ele!"},
					{"speaker": "Rock Lee", "text": "Espere um minuto... acho que tomei o remédio errado, mas meu corpo está mais leve do que nunca!"},
					{"speaker": "Gaara", "text": "Eu não deixarei ninguém ferir aqueles que Naruto considera amigos. Sabaku Kyū!"}
				]
			},
			{
				"id": "stage_4_6",
				"number": "4.6",
				"title": "Naruto vs Sasuke",
				"subtitle": "O Confronto Final no Vale do Fim",
				"desc": "Rasengan de uma cauda contra Chidori do Selo Amaldiçoado. O destino dos dois laços que moldarão todo o futuro do mundo shinobi!",
				"hero_options": ["naruto", "sasuke"],
				"enemy_id": "sasuke", # Dinâmico: se Naruto for escolhido, oponente é Sasuke; se Sasuke for escolhido, oponente é Naruto
				"enemy_dynamic": true,
				"is_tutorial": false,
				"dialogue": [
					{"speaker": "Sasuke Uchiha", "text": "É tarde demais, Naruto! Meu irmão matou todo o meu clã... Meus olhos só enxergam a escuridão!"},
					{"speaker": "Naruto Uzumaki", "text": "Mesmo que eu tenha que quebrar os seus braços e pernas, eu vou te levar de volta para Konoha!"}
				]
			}
		]
	}
]

## Retorna a lista completa de mundos
static func get_all_worlds() -> Array:
	return WORLDS

## Retorna os dados de um mundo específico pelo ID (1 a 4)
static func get_world_by_id(world_id: int) -> Dictionary:
	for w in WORLDS:
		if w.get("id") == world_id:
			return w
	return {}

## Retorna os dados de uma fase pelo seu ID (ex: "stage_1_0")
static func get_stage_by_id(stage_id: String) -> Dictionary:
	for w in WORLDS:
		for s in w.get("stages", []):
			if s.get("id") == stage_id:
				return s
	return {}

## Retorna todas as 24 fases em uma lista linear única
static func get_all_stages_flat() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for w in WORLDS:
		for s in w.get("stages", []):
			result.append(s)
	return result

## Verifica se uma fase específica está desbloqueada
static func is_stage_unlocked(stage_id: String, completed_stages: Array[String]) -> bool:
	if stage_id == "stage_1_0":
		return true
	var all_stages = get_all_stages_flat()
	for i in range(all_stages.size()):
		if all_stages[i].id == stage_id:
			if i > 0:
				var prev_stage_id = all_stages[i - 1].id
				return completed_stages.has(prev_stage_id) or completed_stages.has(stage_id)
			return true
	return false

## Verifica se um mundo está desbloqueado
static func is_world_unlocked(world_id: int, completed_stages: Array[String]) -> bool:
	if world_id <= 1:
		return true
	# Mundo 2 exige 1.3 completo
	if world_id == 2:
		return completed_stages.has("stage_1_3")
	# Mundo 3 exige 2.7 completo
	if world_id == 3:
		return completed_stages.has("stage_2_7")
	# Mundo 4 exige 3.4 completo
	if world_id == 4:
		return completed_stages.has("stage_3_4")
	return false

## Retorna o oponente correto para a fase, resolvendo a regra dinâmica da fase 4.6
static func resolve_enemy_id(stage_data: Dictionary, selected_hero_id: String) -> String:
	if stage_data.get("enemy_dynamic", false) or stage_data.get("id") == "stage_4_6":
		if selected_hero_id == "naruto":
			return "sasuke"
		elif selected_hero_id == "sasuke":
			return "naruto"
	return stage_data.get("enemy_id", "ninja_renegado")

