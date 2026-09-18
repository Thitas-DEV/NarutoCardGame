import os
import shutil
import re

AIR_FILE = '../sakura/Sakura.air'
IMG_DIR = '../sakura/'
OUT_DIR = 'assets/characters/sakura/'
OUT_TRES = 'data/characters/sakura_frames.tres'

MAPPING = {
    '0': 'idle',
    '20': 'walk',
    '200': 'attack',  # Basic attack
    '120': 'defense',
    '5000': 'hit',
    '1000': 'jutsu',
    '1001': 'kunai_defense',
    '1500': 'cast'
}

# 1. Parse AIR file
animations = {}
current_anim = None

if not os.path.exists(AIR_FILE):
    print(f"Error: {AIR_FILE} not found.")
    exit(1)

with open(AIR_FILE, 'r', encoding='latin1') as f:
    for line in f:
        line = line.strip()
        m = re.match(r'\[Begin Action (\d+)\]', line, re.IGNORECASE)
        if m:
            action_id = m.group(1)
            if action_id in MAPPING:
                current_anim = MAPPING[action_id]
                animations[current_anim] = []
            else:
                current_anim = None
            continue
            
        if current_anim and line and not line.startswith(';'):
            if 'Clsn' in line:
                continue
            parts = [p.strip() for p in line.split(',')]
            if len(parts) >= 5:
                try:
                    grp = int(parts[0])
                    img = int(parts[1])
                    if grp >= 0 and img >= 0:
                        animations[current_anim].append(f"{grp}-{img}.png")
                except ValueError:
                    pass

if 'defense' not in animations or len(animations['defense']) == 0:
    print("WARNING: No defense animation found.")

if 'kunai_defense' not in animations and 'defense' in animations:
    animations['kunai_defense'] = animations['defense']
if 'cast' not in animations and 'attack' in animations:
    animations['cast'] = animations['attack']

print(f"Found animations: {list(animations.keys())}")

# 2. Copy images
os.makedirs(OUT_DIR, exist_ok=True)
used_images = set()

copied = 0
for anim, frames in animations.items():
    valid_frames = []
    for frame in frames:
        src = os.path.join(IMG_DIR, frame)
        dst = os.path.join(OUT_DIR, frame)
        if os.path.exists(src):
            used_images.add(frame)
            valid_frames.append(frame)
            shutil.copy2(src, dst)
            copied += 1
        else:
            print(f"WARNING: Missing image {src}")
    animations[anim] = valid_frames

print(f"Copied {copied} images to {OUT_DIR}")

# 3. Generate Godot .tres file
tres_content = f'[gd_resource type="SpriteFrames" format=3]\n\n'

ext_id = 1
img_to_ext = {}
for img in used_images:
    tres_content += f'[ext_resource type="Texture2D" path="res://assets/characters/sakura/{img}" id="{ext_id}_tex"]\n'
    img_to_ext[img] = f'{ext_id}_tex'
    ext_id += 1

tres_content += '\n[resource]\n'
tres_content += 'animations = [{\n'

for i, (anim_name, frames) in enumerate(animations.items()):
    tres_content += f'  "frames": ['
    
    for j, f in enumerate(frames):
        tres_content += f'{{\n    "duration": 1.0,\n    "texture": ExtResource("{img_to_ext[f]}")\n  }}'
        if j < len(frames) - 1:
            tres_content += ', '
            
    tres_content += '],\n'
    tres_content += '  "loop": ' + ('1' if anim_name in ['idle', 'walk'] else '0') + ',\n'
    tres_content += '  "name": &"' + anim_name + '",\n'
    tres_content += '  "speed": ' + ('8.0' if anim_name == 'idle' else '12.0') + '\n'
    tres_content += '}'
    if i < len(animations) - 1:
        tres_content += ',\n{\n'
    else:
        tres_content += '\n'

tres_content += '}]\n'

with open(OUT_TRES, 'w') as f:
    f.write(tres_content)
    
print(f"Done creating {OUT_TRES}")
