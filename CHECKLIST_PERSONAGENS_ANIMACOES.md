# 📋 Checklist de Animações e Sprites dos Personagens

Este documento detalha o status atual das animações e spritesheets de todos os **29 personagens** presentes no *Naruto: Shinobi Clash*.

---

## 📊 Visão Geral

* **Total de Personagens:** 29
* **Com Sprites Animados (`SpriteFrames`):** 9 personagens (31%)
* **Com Renderização Procedural (Aguardando Sprites):** 20 personagens (69%)

> [!NOTE]
> O sistema do jogo ([`CharacterVisual.gd`](res://src/battle/CharacterVisual.gd)) possui **fallback automático**: personagens sem `SpriteFrames` utilizam um desenho procedural estilizado baseado em suas cores oficiais (`avatar_color` e `secondary_color`), garantindo que todos os 29 personagens sejam 100% jogáveis em combate e na tela de preparação de batalha sem qualquer crash.

---

## 🥷 1. Personagens com Animações Adicionadas

| Personagem | ID | Idle | Attack | Damage | Defesa/Guard | Kawarimi | Especiais | Arquivo de Frames |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Naruto Uzumaki** | `naruto` | ✅ | ✅ | ✅ | ✅ | ✅ | Rasengan, Run, Clones | `data/characters/naruto_frames.tres` |
| **Sasuke Uchiha** | `sasuke` | ✅ | ✅ | ✅ | 🔄* | ✅ | Chidori | `data/characters/sasuke_frames.tres` |
| **Rock Lee** | `rock_lee` | ✅ | ✅ | ✅ | 🔄* | ✅ | Lótus / Combo | `data/characters/rock_lee_frames.tres` |
| **Might Guy** | `might_guy` | ✅ | ✅ | ✅ | 🔄* | ✅ | Herda de Lee | Herda `rock_lee_frames.tres` |
| **Kakashi Hatake** | `kakashi` | ✅ | ✅ | ✅ | ✅ | ✅ | Raikiri / Chidori | `data/characters/kakashi_frames.tres` |
| **Gaara** | `gaara` | ✅ | ✅ | ✅ | 🔄* | ✅ | Sand Strike | `data/characters/gaara_frames.tres` |
| **Zabuza Momochi** | `zabuza` | ✅ | ✅ | ✅ | 🔄* | ✅ | Espada Kubikiribōchō | `data/characters/zabuza_frames.tres` |
| **Iruka Umino** | `iruka` | ✅ | ✅ | ✅ | ✅ | ✅ | Kunai Attack/Throw, Bomb, Run, Bravo | `data/characters/iruka_frames.tres` |

*\* Utiliza fallback automático caso a animação específica não esteja no frames.*

---

## ⏳ 2. Novos Personagens — Checklist de Animações Pendentes

Abaixo está o checklist de cada novo personagem adicionado na expansão da campanha. Marque as caixas à medida que novos spritesheets forem importados e convertidos em `SpriteFrames`:

### 🏫 Mundo 1: Academia Ninja & País das Ondas
- [ ] **Mizuki** (`mizuki`)
  - [ ] `idle`
  - [ ] `attack`
  - [ ] `damage`
  - [ ] `kawarimi` / especiais
  - *Pasta recomendada:* `assets/characters/mizuki/`
- [ ] **Sakura Haruno** (`sakura`)
  - [ ] `idle`
  - [ ] `attack`
  - [ ] `damage`
  - [ ] `guard` / cura
  - *Pasta recomendada:* `assets/characters/sakura/`
- [ ] **Haku Yuki** (`haku`)
  - [ ] `idle`
  - [ ] `attack`
  - [ ] `damage`
  - [ ] `espelhos_de_gelo` / especiais
  - *Pasta recomendada:* `assets/characters/haku/`

---

### 🏆 Mundo 2: Exame Chunin & Floresta da Morte
- [ ] **Orochimaru** (`orochimaru`)
  - [ ] `idle`
  - [ ] `attack`
  - [ ] `damage`
  - [ ] `jutsus_serpente` / especiais
  - *Pasta recomendada:* `assets/characters/orochimaru/`
- [ ] **Dosu Kinuta** (`dosu`)
  - [ ] `idle`
  - [ ] `attack`
  - [ ] `damage`
  - [ ] `som_ressonante`
  - *Pasta recomendada:* `assets/characters/dosu/`
- [ ] **Kiba Inuzuka** (`kiba`)
  - [ ] `idle`
  - [ ] `attack` (Gatsūga)
  - [ ] `damage`
  - [ ] `akamaru` / especiais
  - *Pasta recomendada:* `assets/characters/kiba/`
- [ ] **Hinata Hyūga** (`hinata`)
  - [ ] `idle`
  - [ ] `attack` (Juuken)
  - [ ] `damage`
  - [ ] `byakugan` / postura
  - *Pasta recomendada:* `assets/characters/hinata/`
- [ ] **Neji Hyūga** (`neji`)
  - [ ] `idle`
  - [ ] `attack` (64 Golpes)
  - [ ] `damage`
  - [ ] `kaiten` (Rotação Celestial)
  - *Pasta recomendada:* `assets/characters/neji/`

---

### 🍃 Mundo 3: Esmaga Konoha & Busca por Tsunade
- [ ] **Hiruzen Sarutobi (3º Hokage)** (`sarutobi`)
  - [ ] `idle`
  - [ ] `attack`
  - [ ] `damage`
  - [ ] `selo_ceifeiro` / `enma`
  - *Pasta recomendada:* `assets/characters/sarutobi/`
- [ ] **Itachi Uchiha** (`itachi`)
  - [ ] `idle`
  - [ ] `attack`
  - [ ] `damage`
  - [ ] `tsukuyomi` / `sharingan` / `corvos`
  - *Pasta recomendada:* `assets/characters/itachi/`
- [ ] **Kabuto Yakushi** (`kabuto`)
  - [ ] `idle`
  - [ ] `attack` (Bisturi de Chakra)
  - [ ] `damage`
  - [ ] `cura` / postura
  - *Pasta recomendada:* `assets/characters/kabuto/`
- [ ] **Jiraiya** (`jiraiya`)
  - [ ] `idle`
  - [ ] `attack` (Rasengan / Katon)
  - [ ] `damage`
  - [ ] `jutsus_sapo` / agulhas
  - *Pasta recomendada:* `assets/characters/jiraiya/`
- [ ] **Tsunade Senju** (`tsunade`)
  - [ ] `idle`
  - [ ] `attack` (Super Força de Chakra)
  - [ ] `damage`
  - [ ] `byakugou` / regeneração
  - *Pasta recomendada:* `assets/characters/tsunade/`

---

### ⚡ Mundo 4: Resgate do Sasuke & Quinteto do Som
- [ ] **Chouji Akimichi** (`chouji`)
  - [ ] `idle`
  - [ ] `attack` (Tanque de Carne / Pílula)
  - [ ] `damage`
  - [ ] `baika_no_jutsu`
  - *Pasta recomendada:* `assets/characters/chouji/`
- [ ] **Shikamaru Nara** (`shikamaru`)
  - [ ] `idle`
  - [ ] `attack` (Kagemane / Sombras)
  - [ ] `damage`
  - [ ] `estrategia` / pose
  - *Pasta recomendada:* `assets/characters/shikamaru/`
- [ ] **Jirōbō** (`jirobo`)
  - [ ] `idle`
  - [ ] `attack` (Doton / Punho Pesado)
  - [ ] `damage`
  - [ ] `selo_amaldicoado`
  - *Pasta recomendada:* `assets/characters/jirobo/`
- [ ] **Kidōmaru** (`kidomaru`)
  - [ ] `idle`
  - [ ] `attack` (Teias / Arco de Chakra)
  - [ ] `damage`
  - [ ] `selo_amaldicoado`
  - *Pasta recomendada:* `assets/characters/kidomaru/`
- [ ] **Sakon e Ukon** (`sakon_ukon`)
  - [ ] `idle`
  - [ ] `attack` (Fusão Celular / Chutes)
  - [ ] `damage`
  - [ ] `selo_amaldicoado`
  - *Pasta recomendada:* `assets/characters/sakon_ukon/`
- [ ] **Tayuya** (`tayuya`)
  - [ ] `idle`
  - [ ] `attack` (Flauta Demoníaca / Doki)
  - [ ] `damage`
  - [ ] `genjutsu_do_som`
  - *Pasta recomendada:* `assets/characters/tayuya/`
- [ ] **Kimimaro Kaguya** (`kimimaro`)
  - [ ] `idle`
  - [ ] `attack` (Dança dos Ossos / Yanagi)
  - [ ] `damage`
  - [ ] `selo_amaldicoado_nivel2`
  - *Pasta recomendada:* `assets/characters/kimimaro/`

---

## 🛠️ Como Adicionar Animações Automaticamente

O sistema do jogo utiliza **detecção por convenção**, o que significa que **nenhuma linha de código precisa ser alterada** para ativar sprites de um novo personagem!

### Passo a Passo:
1. **Coloque os frames PNG:**
   Crie a pasta do personagem em `res://assets/characters/<id>/` (ex: `res://assets/characters/sakura/idle/`).
2. **Crie o recurso `SpriteFrames`:**
   No Godot, crie um novo recurso do tipo `SpriteFrames` e salve-o em um dos dois caminhos aceitos automaticamente:
   * **Opção A (Recomendada):** `res://data/characters/<id>_frames.tres` (ex: `data/characters/sakura_frames.tres`)
   * **Opção B:** `res://assets/characters/<id>/<id>_frames.tres`
3. **Configure os nomes das animações:**
   * `idle`: Animação em repouso (obrigatória para a pose padrão e pré-luta).
   * `attack`: Animação de ataque físico ou comemoração de seleção na tela pré-luta.
   * `damage`: Animação ao sofrer dano em combate.
   * `kawarimi`: Animação ao executar Substituição.
   * `guard` ou `defense`: Postura de bloqueio.
4. **Pronto!**
   Assim que o arquivo `res://data/characters/<id>_frames.tres` existir, o [`CharacterVisual`](res://src/battle/CharacterVisual.gd) irá carregá-lo instantaneamente tanto nas batalhas quanto no painel de preparação do Modo História.
