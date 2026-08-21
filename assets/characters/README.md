# 📁 Diretório de Sprites dos Personagens (res://assets/characters/)

Coloque os spritesheets, imagens PNG ou frames de animação dos ninjas nas respectivas pastas:

- `naruto/`: Sprites do Naruto Uzumaki (idle, ataque, rasengan, clones, etc.)
- `sasuke/`: Sprites do Sasuke Uchiha (idle, ataque, katon, chidori, sharingan)
- `rock_lee/`: Sprites do Rock Lee (idle, taijutsu, lótus, 5 portões abertos)
- `gaara/`: Sprites do Gaara (idle, escudo de areia, caixão de areia)
- `kakashi/`: Sprites do Kakashi Hatake (idle, raikiri, leitura do livro)
- `zabuza/`: Sprites do Zabuza Momochi (idle, espada kubikiribocho, dragão de água)
- `sakura/`: Sprites da Sakura Haruno (suporte, cura)

### Dicas de Configuração na Godot:
1. Ao adicionar arquivos `.png`, a Godot irá importá-los automaticamente.
2. Na aba **Import** do arquivo no Godot, para Pixel Art, configure o Filter como **Nearest** se desejar visual nítido de pixels.
3. Para configurar no jogo, abra a cena `res://src/battle/CharacterVisual.tscn`, selecione o nó `AnimatedSprite2D` e crie seu **SpriteFrames**.
