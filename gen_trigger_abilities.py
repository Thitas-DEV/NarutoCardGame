import os
import json

# Format: name, desc, yin_cost, yang_cost, type, target, anim, scripts, is_exhaust, qte_diff
abilities = {
    "chidori": {
        "name": "Chidori: Mil Pássaros", "desc": "QTE Sucesso: 35 Dano. Falha: 12 dano próprio.",
        "yin": 2, "yang": 1, "type": 1, "target": 0, "anim": "chidori", "exhaust": "false", "qte": 3,
        "scripts": [
            {"trigger": "on_qte_success", "effect": "damage", "value": 35},
            {"trigger": "on_qte_failure", "effect": "self_damage", "value": 12}
        ]
    },
    "kirin": {
        "name": "Kirin: Descarga Celestial", "desc": "QTE Sucesso: 48 Dano em área. Falha: 20 dano e zera Chakra.",
        "yin": 3, "yang": 0, "type": 1, "target": 1, "anim": "ougi_rasengan", "exhaust": "false", "qte": 4,
        "scripts": [
            {"trigger": "on_qte_success", "effect": "damage", "value": 48},
            {"trigger": "on_qte_failure", "effect": "self_damage", "value": 20},
            {"trigger": "on_qte_failure", "effect": "lose_all_chakra", "value": 0}
        ]
    },
    "shiki_fujin": {
        "name": "Contrato Shiki Fūjin", "desc": "Causa 50 de Dano Puro e exaure. Reduz Vida Máxima em 10.",
        "yin": 0, "yang": 0, "type": 5, "target": 0, "anim": "ougi_ura_renge", "exhaust": "true", "qte": 0,
        "scripts": [
            {"trigger": "on_play", "effect": "damage", "value": 50},
            {"trigger": "on_play", "effect": "reduce_max_hp", "value": 10}
        ]
    },
    "katon_gokakyu": {
        "name": "Katon: Bola de Fogo", "desc": "12 Dano + Queimadura.",
        "yin": 2, "yang": 0, "type": 1, "target": 0, "anim": "attack", "exhaust": "false", "qte": 0,
        "scripts": [
            {"trigger": "on_play", "effect": "damage", "value": 12},
            {"trigger": "on_play", "effect": "apply_status", "status": "burn", "value": 3}
        ]
    },
    "doton_wall": {
        "name": "Doton: Parede de Terra", "desc": "Concede 16 de Escudo.",
        "yin": 1, "yang": 1, "type": 1, "target": 2, "anim": "guard", "exhaust": "false", "qte": 0,
        "scripts": [
            {"trigger": "on_play", "effect": "shield", "value": 16}
        ]
    }
}

template = """[gd_resource type="Resource" script_class="AbilityData" load_steps=2 format=3]

[ext_resource type="Script" path="res://src/core/ability_data.gd" id="1_abdt"]

[resource]
script = ExtResource("1_abdt")
id = "{id}"
name = "{name}"
description = "{desc}"
yin_cost = {yin}
yang_cost = {yang}
is_exhaust = {exhaust}
ability_type = {type}
target_type = {target}
scripts = {scripts_str}
animation_key = "{anim}"
qte_difficulty = {qte}
support_name = ""
allowed_character_ids = Array[String]([])
allowed_tags = Array[String]([])
"""

for a_id, data in abilities.items():
    scripts_gd = "Array[Dictionary](["
    for s in data["scripts"]:
        scripts_gd += json.dumps(s).replace("'", '"') + ", "
    if len(data["scripts"]) > 0:
        scripts_gd = scripts_gd[:-2]
    scripts_gd += "])"
    
    content = template.format(
        id=a_id, name=data["name"], desc=data["desc"], 
        yin=data["yin"], yang=data["yang"], exhaust=data["exhaust"],
        type=data["type"], target=data["target"], 
        scripts_str=scripts_gd, anim=data["anim"], qte=data["qte"]
    )
    with open(os.path.join("data", "abilities", f"{a_id}.tres"), "w", encoding="utf-8") as f:
        f.write(content)

print("Abilities with QTE and Failure triggers generated.")
