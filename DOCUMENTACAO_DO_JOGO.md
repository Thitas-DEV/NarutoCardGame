# 🥷 Naruto: Shinobi Clash — Documento de Design e Desenvolvimento (GDD & Guia Técnico)

Este documento serve como guia completo de continuidade para a equipe de desenvolvimento (programadores, artistas 2D, animadores e game designers) do projeto **Naruto: Shinobi Clash** desenvolvido na **Godot Engine 4.x**.

---

## 📑 Sumário
1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Estrutura de Pastas e Padrões de Arquitetura](#2-estrutura-de-pastas-e-padrões-de-arquitetura)
3. [Guia de Sprites e Animações 2D](#3-guia-de-sprites-e-animações-2d)
4. [Sistema de Cartas e Chakra](#4-sistema-de-cartas-e-chakra)
5. [Como Adicionar Novas Cartas e Jutsus](#5-como-adicionar-novas-cartas-e-jutsus)
6. [Como Adicionar Novos Ninjas e Inimigos](#6-como-adicionar-novos-ninjas-e-inimigos)
7. [Sistema de Combos Storm 4 e QTE](#7-sistema-de-combos-storm-4-e-qte)
8. [Batalhas Scriptadas e Transição de Fases](#8-batalhas-scriptadas-e-transição-de-fases)
9. [Modo História Chibi e Mapa de Missões](#9-modo-história-chibi-e-mapa-de-missões)
10. [Deck Builder e Sistema de Recompensas](#10-deck-builder-e-sistema-de-recompensas)
11. [Checklist de Tarefas para a Equipe](#11-checklist-de-tarefas-para-a-equipe)

---

## 1. Visão Geral do Projeto

- **Gênero**: Roguelike Deckbuilder Tático em Turnos (estilo *Slay the Spire*) com estética de anime e dinâmicas de luta de *Naruto: Ultimate Ninja Storm*.
- **Universo**: Naruto Clássico (Fase Genin: Exame Chunin, País das Ondas, Vale do Fim).
- **Engine**: **Godot Engine 4.x** (Forward+ ou Mobile, GDScript).
- **Resolução Base de Referência**: `1280x720` (Modo Stretch: `canvas_items`, Aspect: `expand`).
- **Autoloads Globais**:
  - `GameManager` (`res://src/autoload/GameManager.gd`)
  - `CardDatabase` (`res://src/autoload/CardDatabase.gd`)
  - `SoundManager` (`res://src/autoload/SoundManager.gd`)

---

## 2. Estrutura de Pastas e Padrões de Arquitetura

```text
res://
├── assets/
│   ├── characters/              # Spritesheets e frames dos ninjas
│   ├── cards/                   # Ilustrações e molduras das cartas
│   ├── backgrounds/             # Cenários de batalha e mapa do mundo
│   ├── vfx/                     # Efeitos de corte de anime, jutsus, partículas
│   └── audio/                   # Músicas (BGM) e efeitos sonoros (SFX)
├── src/
│   ├── autoload/
│   │   ├── GameManager.gd       # Estado global, save, personagem ativo, baralhos
│   │   ├── CardDatabase.gd      # Catálogo centralizado de todas as cartas do jogo
│   │   └── SoundManager.gd      # Gerenciador e sintetizador de áudio
│   ├── core/
│   │   ├── CardData.gd          # Resource de definição de cartas
│   │   ├── CharacterData.gd     # Resource de ninjas e atributos
│   │   └── StatusEffect.gd      # Constantes e cores dos efeitos de status
│   ├── battle/
│   │   ├── BattleField.gd/.tscn # Controlador da arena de combate e turnos
│   │   ├── CharacterVisual.gd/.tscn # Arena 2D com suporte a AnimatedSprite2D
│   │   ├── CardUI.gd/.tscn      # UI das cartas com física de arrastar e leque
│   │   ├── ComboMeter.gd/.tscn  # Contador de hits e níveis de combo Storm 4
│   │   ├── QTEOverlay.gd/.tscn  # Sequência de botões e selos para Jutsus Supremos
│   │   └── ScriptedPhaseManager.gd # Lutas com múltiplas fases / cutscenes
│   ├── map/
│   │   ├── StoryMap.gd/.tscn    # Mapa de navegação top-down chibi
│   │   └── ChibiPlayer.gd       # Ninja chibi no mapa
│   ├── deck_builder/
│   │   └── DeckBuilder.gd/.tscn # Interface de montagem e coleção de decks
│   └── ui/
│       ├── MainMenu.gd/.tscn    # Menu principal com seleção de heróis
│       └── RewardScreen.gd/.tscn# Escolha de cartas pós-batalha
└── project.godot
```

---

## 3. Guia de Sprites e Animações 2D

O sistema visual dos personagens em combate está centralizado em `CharacterVisual.tscn` / `CharacterVisual.gd`. Ele foi projetado para **suportar automaticamente spritesheets e animações 2D** através do nó `AnimatedSprite2D`.

### Como importar e plugar Sprites dos Ninjas:

1. **Coloque as imagens/spritesheets** na pasta `res://assets/characters/<nome_do_ninja>/`.
2. Abra a cena `res://src/battle/CharacterVisual.tscn` ou crie cenas herdadas para personagens específicos.
3. No nó `VisualRoot/AnimatedSprite2D`, crie um novo **SpriteFrames** no Inspector:
   - Defina as seguintes animações recomendadas:
     - `idle`: Animação de respiração / postura de combate em loop.
     - `attack`: Golpe físico básico (soco ou chute).
     - `charge`: Canalização de chakra (mãos em selo ninja com aura).
     - `hit`: Reação ao tomar dano.
     - `rasengan` / `chidori` / `jutsu`: Pose do jutsu característico.
     - `kawarimi`: Tronco de madeira ou fumaça.
     - `ko`: Personagem caído/derrotado.
4. **Fallback Automático**: Se nenhuma textura ou `SpriteFrames` estiver atribuído ao nó, o jogo utiliza automaticamente a renderização procedural estilizada, permitindo testar o jogo mesmo antes dos sprites estarem prontos!

```gdscript
# Exemplo de como disparar animações no CharacterVisual.gd:
func play_custom_animation(anim_name: String) -> void:
    if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_name):
        animated_sprite.play(anim_name)
```

---

## 4. Sistema de Cartas e Naturezas de Chakra (Estilo Pokémon TCG)

O jogo utiliza o sistema canônico das **5 Naturezas Básicas de Chakra** (*Godai Seishitsu Henka*):
- 💧 **Água (Suiton)**
- 🔥 **Fogo (Katon)**
- 🌪️ **Vento (Fuuton)**
- ⛰️ **Terra (Doton)**
- ⚡ **Raio (Raiton)**

### Regras de Energia e Afinidade:
1. **Afinidades dos Ninjas**: Cada personagem pode dominar de **0 até 5 elementos** (definido em `chakra_affinities` de `CharacterData`).
   - *Rock Lee*: 0 elementos (especialista puro em Taijutsu).
   - *Naruto*: Vento (*Fuuton*).
   - *Sasuke*: Fogo (*Katon*) e Raio (*Raiton*).
   - *Kakashi*: Raio (*Raiton*), Terra (*Doton*) e Água (*Suiton*).
   - *Gaara*: Terra (*Doton*) e Vento (*Fuuton*).
   - *Zabuza*: Água (*Suiton*).
2. **Geração por Turno**: A cada início de turno, o jogador ganha **1 carta** e sorteia **1 ponto de energia aleatório** dentre os elementos dominados por seu ninja (acumulado na reserva `player_chakra_pool`).
3. **Taijutsu Universal**: Golpes de Taijutsu (`required_element = NONE`, `element_cost = 0`) não consomem chakra elemental e são básicos de todos os ninjas.
4. **Condição de Lançamento**: Jutsus elementais só podem ser jogados se a reserva do elemento exigido for **igual ou maior** que o custo da carta (`reserva[elemento] >= element_cost`). Ao jogar, consome o chakra correspondente.

---

## 5. Como Adicionar Novas Cartas e Jutsus

As cartas são recursos `AbilityData` salvos na pasta `res://data/abilities/<id>.tres` e carregados automaticamente pelo `Database.gd`.

### Exemplo de recurso `.tres`:
```ini
[gd_resource type="Resource" script_class="AbilityData" load_steps=2 format=3]

[ext_resource type="Script" path="res://src/core/ability_data.gd" id="1_abdt"]

[resource]
script = ExtResource("1_abdt")
id = "katon_gokakyu"
name = "Katon: Bola de Fogo"
description = "Dispara uma esfera massiva de chamas ardentes."
required_element = 2 # ChakraElement.Type.FIRE
element_cost = 2
is_exhaust = false
ability_type = 1 # NINJUTSU
target_type = 0 # SINGLE_ENEMY
scripts = Array[Dictionary]([{"trigger": "on_play", "effect": "damage", "value": 22, "combo": 1, "hits": 1}])
animation_key = "katon"
qte_difficulty = 0
support_name = ""
allowed_character_ids = Array[String]([])
allowed_tags = Array[String]([])
```

---

## 6. Como Adicionar Novos Ninjas e Inimigos

Crie um arquivo `.tres` em `res://data/characters/<id>.tres` utilizando a classe `CharacterData`:

```ini
[gd_resource type="Resource" script_class="CharacterData" load_steps=5 format=3]

[ext_resource type="Script" path="res://src/core/character_data.gd" id="1_chdt"]
[ext_resource type="Resource" path="res://data/abilities/naruto_punch.tres" id="2_punch"]

[resource]
script = ExtResource("1_chdt")
id = "neji"
name = "Neji Hyuga"
title = "Gênio dos Hyuga (Byakugan)"
tags = Array[String]([])
max_hp = 80
current_hp = 80
attack_modifier = 1.0
avatar_color = Color(0.85, 0.85, 0.95, 1)
secondary_color = Color(0.2, 0.2, 0.3, 1)
chakra_affinities = Array[int]([]) # Neji no clássico foca em Taijutsu Juuken
starting_deck = Array[Resource("res://src/core/ability_data.gd")]([ExtResource("2_punch")])
```

---

## 7. Sistema de Combos Storm 4 e QTE

### Storm Combo Meter (`ComboMeter.gd`)
- Cada carta de golpe físico jogada dentro do mesmo turno acumula **Pontos de Combo** e **HITS**:
  - **Nível 1 (Início)**: Dano base `x1.0`.
  - **Nível 2 (Storm Pressure)**: Multiplicador `x1.25` + chance de crítico.
  - **Nível 3 (Storm Finisher)**: Multiplicador `x1.50` + bônus máximo.
- O combo reseta ao término do turno do jogador.

### Quick Time Event (`QTEOverlay.gd`)
- Ao jogar uma carta de tipo `ULTIMATE`, o jogo pausa o fluxo padrão e exibe a sequência de selos ninja.
- Teclas mapeadas: `W`, `A`, `S`, `D`, `SPACE` (e setas direcionais).
- Se o jogador acertar todas as entradas no tempo hábil, obtém classificação **PERFECT (+50% de dano)** ou **GREAT (+25% de dano)**.

---

## 8. Batalhas Scriptadas e Transição de Fases

O arquivo `res://src/battle/ScriptedPhaseManager.gd` cuida de eventos da narrativa onde o fluxo tradicional da batalha é alterado por transformações:

- **Exemplo: Rock Lee vs Gaara**:
  - Na Fase 1, o Gaara possui HP alto e escudo impenetrável.
  - Ao atingir o limiar de HP, a batalha entra em modo **Cutscene**.
  - O diálogo narra Lee tirando os pesos dos tornozelos.
  - Na Fase 2, o HP de Lee é restaurado, seu Chakra aumenta e cartas da *Lótus Oculta (5 Portões)* são injetadas em sua mão!

Para adicionar uma nova fase scriptada (ex: Naruto despertando as Nove Caudas ou Sasuke ativando o Selo Amaldiçoado), adicione a condição em `check_phase_triggers()` dentro de `ScriptedPhaseManager.gd`.

---

## 9. Modo História Chibi e Mapa de Missões

O mapa de missões (`res://src/map/StoryMap.gd`) organiza os arcos canônicos do anime:
1. **Treinamento dos Sinos** (Kakashi Hatake)
2. **País das Ondas** (Zabuza & Haku)
3. **Floresta da Morte** (Exame Chunin)
4. **Preliminares Chunin** (Rock Lee vs Gaara)
5. **Vale do Fim** (Naruto vs Sasuke)

Para adicionar um novo nó de missão, basta incluir uma nova entrada no array `story_nodes` em `StoryMap.gd` especificando posição, tipo (`battle` ou `event`), diálogos e id de encontro.

---

## 10. Deck Builder e Sistema de Recompensas

- **Coleção de Cartas**: Armazenada em `GameManager.player_collection_ids`.
- **Baralho Ativo**: `GameManager.player_deck_ids` (limite recomendado: 10 a 30 cartas).
- **Tela de Recompensas (`RewardScreen.gd`)**: Gera 3 cartas aleatórias compatíveis com o ninja ativo para que o jogador escolha uma ao final de cada vitória.

---

## 11. Checklist de Tarefas para a Equipe

### 🎨 Artistas 2D & UI
- [ ] Criar spritesheets dos personagens principais (*Naruto, Sasuke, Rock Lee, Sakura, Kakashi, Gaara, Zabuza*).
- [ ] Desenhar ilustrações personalizadas para as cartas em `res://assets/cards/`.
- [ ] Criar fundos 2D dos cenários de combate (*Campo de Treinamento, Floresta da Morte, Arena Chunin, Vale do Fim*).
- [ ] Desenhar o mapa estilizado de Konoha para o modo história chibi.

### 💻 Programadores
- [ ] Plugar os `SpriteFrames` importados nas cenas de `CharacterVisual.tscn`.
- [ ] Expandir o catálogo em `CardDatabase.gd` com novas cartas para Neji, Shikamaru, Kiba, Gaara, etc.
- [ ] Implementar sistema de salvamento local (`user://save_game.json`) para persistir o progresso do modo história e as cartas desbloqueadas.
- [ ] Adicionar novas lutas scriptadas com diálogos em `ScriptedPhaseManager.gd`.

### 🎵 Áudio & Trilha Sonora
- [ ] Adicionar músicas de fundo (BGM) empolgantes de batalha e tema de Konoha.
- [ ] Plugar dublagens ou efeitos sonoros de impacto dos jutsus em `SoundManager.gd`.
