import os
import glob

deck_cards = [
    "res://data/abilities/naruto_punch.tres",
    "res://data/abilities/naruto_punch.tres",
    "res://data/abilities/naruto_punch.tres",
    "res://data/abilities/iron_guard.tres",
    "res://data/abilities/iron_guard.tres",
    "res://data/abilities/katon_gokakyu.tres",
    "res://data/abilities/katon_gokakyu.tres",
    "res://data/abilities/kawarimi_trap.tres",
    "res://data/abilities/chidori.tres"
]

def process_character(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    if "starting_deck = Array[Resource(\"res://src/core/ability_data.gd\")]([])" not in content:
        print(f"Skipping {filepath} (Already populated or missing starting_deck field)")
        return

    ext_id = 2 
    ext_lines = []
    array_contents = []
    
    for path in deck_cards:
        ext_id_str = f"{ext_id}_ab"
        ext_lines.append(f'[ext_resource type="Resource" path="{path}" id="{ext_id_str}"]')
        array_contents.append(f'ExtResource("{ext_id_str}")')
        ext_id += 1

    parts = content.split("[resource]")
    if len(parts) != 2:
        print(f"Error parsing {filepath}")
        return
        
    top_part = parts[0].strip()
    bottom_part = parts[1]
    
    new_top = top_part + "\n" + "\n".join(ext_lines) + "\n\n[resource]"
    
    old_array = 'starting_deck = Array[Resource("res://src/core/ability_data.gd")]([])'
    new_array = f'starting_deck = Array[Resource("res://src/core/ability_data.gd")]([{", ".join(array_contents)}])'
    
    new_bottom = bottom_part.replace(old_array, new_array)
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(new_top + new_bottom)
        
    print(f"Successfully populated deck for {os.path.basename(filepath)}")

def main():
    target_dir = r"c:\Programacao\narutoCardGame\NarutoCardGame\data\characters\*.tres"
    for filepath in glob.glob(target_dir):
        process_character(filepath)

if __name__ == "__main__":
    main()
