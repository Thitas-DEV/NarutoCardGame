import re
import os

air_file = '/home/thiago/CODE/GodotProject/sasuke/Sasuke.air'

# Common Mugen Actions
action_names = {
    0: "Idle",
    20: "Walk Forward",
    21: "Walk Backward",
    100: "Run Forward",
    105: "Run Backward",
    120: "Guard",
    200: "Combo 1 (Soco)",
    210: "Combo 2",
    220: "Combo 3",
    230: "Combo 4",
    600: "Combo Aire",
    1000: "Chidori",
    1400: "Katon Gokakyu",
    1500: "Katon Housenka",
    3000: "Katon Gouryuuka",
    5000: "Damage / Hit",
    550: "Awakening (CS2)",
    195: "Taunt / Genjutsu Sharingan",
    800: "Lions Barrage (Shishi Rendan)",
    1100: "Black Chidori"
}

current_action = None
actions = {}

with open(air_file, 'r', encoding='latin1') as f:
    for line in f:
        line = line.strip()
        m = re.match(r'\[Begin Action (\d+)\]', line, re.IGNORECASE)
        if m:
            current_action = int(m.group(1))
            actions[current_action] = []
        elif current_action is not None and not line.startswith(';') and ',' in line:
            parts = line.split(',')
            if len(parts) >= 2:
                try:
                    group = int(parts[0].strip())
                    image = int(parts[1].strip())
                    # Only add if it's a valid sprite (not -1)
                    if group != -1 and image != -1:
                        sprite_name = f"{group}-{image}.png"
                        if sprite_name not in actions[current_action]:
                            actions[current_action].append(sprite_name)
                except ValueError:
                    pass

print("=== PRINCIPAIS ANIMAÇÕES DO SASUKE ===")
for act_id, name in action_names.items():
    if act_id in actions and actions[act_id]:
        frames = actions[act_id]
        if len(frames) > 8:
            frames_str = ", ".join(frames[:4]) + " ... até ... " + ", ".join(frames[-2:])
        else:
            frames_str = ", ".join(frames)
        print(f"[{name}] (Action {act_id}) -> {len(actions[act_id])} frames")
        print(f"   Ordem dos arquivos: {frames_str}\n")

