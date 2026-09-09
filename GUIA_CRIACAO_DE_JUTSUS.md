# 📜 Guia de Criação e Edição de Jutsus & Cartas

Este documento explica detalhadamente como criar, editar e configurar novas habilidades (Jutsus, Taijutsus, Defesas e Ultimates) no projeto **Naruto: Shinobi Clash**, além de indicar onde armazenar artes, ícones e parâmetros de combate.

---

## 1. Onde ficam salvos os Jutsus e os Ícones?

*   **Definição das Cartas (Dados & Lógica)**:  
    Ficam na pasta `res://data/abilities/` como arquivos de recurso `.tres` (ex: `katon_gokakyu.tres`, `rasengan.tres`, `chidori.tres`).
    > O script `Database.gd` faz o escaneamento e carregamento automático de todos os arquivos `.tres` dessa pasta ao iniciar o jogo.
*   **Imagens e Ilustrações das Cartas**:  
    Ficam na pasta `res://assets/cards/` (em formato `.png` ou `.webp`).  
    *Resolução recomendada para o ícone/arte*: **`256 x 256`** ou **`512 x 512`** pixels (quadrada) ou proporção **`4:3`** (ex: `400 x 300`).

---

## 2. Como Editar um Jutsu Existente

### Pela Interface da Godot Engine (Recomendado)
1. No painel **FileSystem** (canto inferior esquerdo da Godot), abra a pasta `res://data/abilities/`.
2. Dê **dois cliques** na carta desejada (ex: `katon_gokakyu.tres`).
3. No painel **Inspector** (canto direito), edite os campos disponíveis:

| Campo | O que faz | Exemplo de Valor |
| :--- | :--- | :--- |
| **`id`** | Identificador único no código | `"katon_gokakyu"` |
| **`name`** | Nome que aparece no topo da carta | `"Katon: Bola de Fogo"` |
| **`description`** | Texto explicativo dos efeitos | `"Dispara uma imensa esfera de chamas..."` |
| **`icon`** | Ilustração da carta | Arraste a imagem de `assets/cards/` |
| **`required_element`** | Elemento de Chakra exigido | `NONE` (Taijutsu), `WATER`, `FIRE`, `WIND`, `EARTH`, `LIGHTNING` |
| **`element_cost`** | Quantidade de chakra necessária | `0` para Taijutsu, ou `1`, `2`, `3` para Jutsus elementais |
| **`ability_type`** | Categoria da carta | `TAIJUTSU`, `NINJUTSU`, `GENJUTSU`, `TRAP`, `SUPPORT`, `ULTIMATE` |
| **`target_type`** | Tipo de mira | `SINGLE_ENEMY` (mira vermelha), `SELF` (auto-alvo), `ALL_ENEMIES` |
| **`animation_key`** | Animação do ninja na arena | `"attack"`, `"rasengan"`, `"chidori"`, `"katon"`, `"lotus"`, `"guard"` |
| **`qte_difficulty`** | Dificuldade do QTE de selos ninja | `0` (desativado) ou `3` a `5` (para Ougis / Ultimates) |

---

## 3. Tabela de Naturezas de Chakra (`required_element`)

| Valor Numérico | Nome do Elemento | Ícone | Tipo de Chakra |
| :---: | :--- | :---: | :--- |
| **0** | `NONE` | 🥋 | **Taijutsu / Neutro** (Custo 0, universal) |
| **1** | `WATER` | 💧 | **Suiton (Água)** |
| **2** | `FIRE` | 🔥 | **Katon (Fogo)** |
| **3** | `WIND` | 🌪️ | **Fuuton (Vento)** |
| **4** | `EARTH` | ⛰️ | **Doton (Terra)** |
| **5** | `LIGHTNING` | ⚡ | **Raiton (Raio)** |

---

## 4. Como Configurar Dano, Escudo e Efeitos (`scripts`)

O sistema de batalha utiliza um **Motor de Triggers** (`scripts: Array[Dictionary]`). Cada entrada na lista é uma instrução executada no combate:

### Exemplos de Efeitos Comuns:

*   **Dano Simples**:
    ```json
    {"trigger": "on_play", "effect": "damage", "value": 25, "combo": 1, "hits": 1}
    ```
    *   `value`: Quantidade de dano base causado ao alvo.
    *   `combo`: Quantos pontos adiciona ao medidor de combo Storm 4.
    *   `hits`: Número de golpes computados no contador de hits.

*   **Escudo / Guarda (Defesa)**:
    ```json
    {"trigger": "on_play", "effect": "shield", "value": 15}
    ```

*   **Cura de Vida**:
    ```json
    {"trigger": "on_play", "effect": "heal", "value": 20}
    ```

*   **Armadilha de Substituição (Kawarimi)**:
    ```json
    {"trigger": "on_play", "effect": "plant_trap", "value": "kawarimi"}
    ```

*   **Jutsu Secreto / QTE com Sucesso e Falha** (ex: Chidori / Kirin):
    ```json
    {"trigger": "on_qte_success", "effect": "damage", "value": 50}
    {"trigger": "on_qte_failure", "effect": "self_damage", "value": 10}
    ```

---

## 5. Exemplo Completo: Criando um Jutsu Novo

Criando o jutsu **Katon: Chamas do Dragão** para o Sasuke:

1. Na Godot, clique com o **botão direito** na pasta `res://data/abilities/` -> **Create New... -> Resource**.
2. Na barra de busca, digite `AbilityData` e clique em **Create**.
3. Salve o arquivo como `katon_ryuka.tres`.
4. Preencha os campos no Inspector:
   - **ID**: `katon_ryuka`
   - **Name**: `Katon: Chamas do Dragão`
   - **Description**: `Dispara rajadas lineares de fogo que causam dano concentrado.`
   - **Required Element**: `FIRE` (Fogo)
   - **Element Cost**: `2`
   - **Ability Type**: `NINJUTSU`
   - **Target Type**: `SINGLE_ENEMY`
   - **Animation Key**: `katon`
   - **Scripts**:
     - Entrada 0: `{"trigger": "on_play", "effect": "damage", "value": 26, "combo": 2, "hits": 3}`

### Formato de Texto Direto do `.tres`:
Se preferir criar ou editar diretamente em um editor de código (VS Code, Bloco de Notas):

```ini
[gd_resource type="Resource" script_class="AbilityData" load_steps=2 format=3]

[ext_resource type="Script" path="res://src/core/ability_data.gd" id="1_abdt"]

[resource]
script = ExtResource("1_abdt")
id = "katon_ryuka"
name = "Katon: Chamas do Dragão"
description = "Dispara rajadas lineares de fogo que causam dano concentrado."
required_element = 2
element_cost = 2
is_exhaust = false
ability_type = 1
target_type = 0
scripts = Array[Dictionary]([{"combo": 2, "effect": "damage", "hits": 3, "trigger": "on_play", "value": 26}])
animation_key = "katon"
qte_difficulty = 0
support_name = ""
allowed_character_ids = Array[String]([])
allowed_tags = Array[String]([])
```

---

## 6. Como Vincular a Nova Carta ao Baralho do Ninja

Para que o personagem comece com essa nova carta em seu baralho:

1. Abra o arquivo do personagem em `res://data/characters/` (ex: `sasuke.tres`).
2. No Inspector, localize o campo **Starting Deck**.
3. Adicione um novo item no array e arraste o seu arquivo `katon_ryuka.tres` para ele.
