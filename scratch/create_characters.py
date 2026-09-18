import os

characters = [
    {
        'id': 'iruka', 'name': 'Iruka Umino', 'title': 'Instrutor da Academia Ninja',
        'hp': 75, 'vigor': 80, 'affinities': [2, 1],
        'color': '0.45, 0.35, 0.25, 1', 'sec_color': '0.25, 0.2, 0.15, 1',
        'cards': ['naruto_punch', 'naruto_punch', 'iron_guard', 'iron_guard', 'kawarimi_trap', 'katon_gokakyu']
    },
    {
        'id': 'mizuki', 'name': 'Mizuki', 'title': 'Chunin Renegado',
        'hp': 70, 'vigor': 80, 'affinities': [],
        'color': '0.6, 0.65, 0.7, 1', 'sec_color': '0.3, 0.35, 0.4, 1',
        'cards': ['naruto_punch', 'naruto_punch', 'sasuke_slash', 'sasuke_slash', 'kawarimi_trap', 'iron_guard']
    },
    {
        'id': 'sakura', 'name': 'Sakura Haruno', 'title': 'Kunoichi da Equipe 7',
        'hp': 70, 'vigor': 90, 'affinities': [4, 1],
        'color': '0.95, 0.5, 0.65, 1', 'sec_color': '0.7, 0.2, 0.35, 1',
        'cards': ['naruto_punch', 'naruto_punch', 'iron_guard', 'iron_guard', 'kawarimi_trap', 'doton_wall']
    },
    {
        'id': 'haku', 'name': 'Haku Yuki', 'title': 'Kekkei Genkai do Gelo (Suiton & Fuuton)',
        'hp': 80, 'vigor': 80, 'affinities': [1, 3],
        'color': '0.4, 0.7, 0.85, 1', 'sec_color': '0.15, 0.35, 0.5, 1',
        'cards': ['sasuke_slash', 'sasuke_slash', 'suiton_suiryuudan', 'suiton_suiryuudan', 'kawarimi_trap', 'iron_guard']
    },
    {
        'id': 'orochimaru', 'name': 'Orochimaru', 'title': 'Sannin Lendário das Serpentes',
        'hp': 110, 'vigor': 90, 'affinities': [3, 4, 1],
        'color': '0.5, 0.2, 0.6, 1', 'sec_color': '0.2, 0.1, 0.3, 1',
        'cards': ['sasuke_slash', 'doton_wall', 'suiton_suiryuudan', 'shiki_fujin', 'kawarimi_trap', 'iron_guard']
    },
    {
        'id': 'dosu', 'name': 'Equipe Dosu', 'title': 'Trio do Som (Dosu, Zaku e Kin)',
        'hp': 85, 'vigor': 90, 'affinities': [3],
        'color': '0.65, 0.55, 0.45, 1', 'sec_color': '0.35, 0.25, 0.2, 1',
        'cards': ['naruto_punch', 'rock_lee_kick', 'rock_lee_kick', 'iron_guard', 'kawarimi_trap', 'holder_duplo']
    },
    {
        'id': 'kiba', 'name': 'Kiba Inuzuka', 'title': 'Presa Sobre Presa (Gatsuga)',
        'hp': 85, 'vigor': 100, 'affinities': [4],
        'color': '0.55, 0.35, 0.25, 1', 'sec_color': '0.3, 0.15, 0.1, 1',
        'cards': ['rock_lee_kick', 'rock_lee_kick', 'naruto_punch', 'dynamic_entry', 'kawarimi_trap', 'iron_guard']
    },
    {
        'id': 'hinata', 'name': 'Hinata Hyuga', 'title': 'Herdeira do Clã Hyuga (Byakugan)',
        'hp': 75, 'vigor': 90, 'affinities': [2, 5],
        'color': '0.5, 0.5, 0.8, 1', 'sec_color': '0.2, 0.2, 0.45, 1',
        'cards': ['naruto_punch', 'naruto_punch', 'iron_guard', 'iron_guard', 'kawarimi_trap']
    },
    {
        'id': 'neji', 'name': 'Neji Hyuga', 'title': 'Gênio dos Hyuga (Punho Gentil Juuken)',
        'hp': 90, 'vigor': 100, 'affinities': [2, 3, 1],
        'color': '0.85, 0.85, 0.95, 1', 'sec_color': '0.3, 0.3, 0.4, 1',
        'cards': ['naruto_punch', 'rock_lee_kick', 'dynamic_entry', 'iron_guard', 'kawarimi_trap', 'holder_duplo']
    },
    {
        'id': 'sarutobi', 'name': 'Hiruzen Sarutobi', 'title': '3º Hokage (O Professor dos 5 Elementos)',
        'hp': 95, 'vigor': 80, 'affinities': [2, 4, 1, 3, 5],
        'color': '0.8, 0.25, 0.2, 1', 'sec_color': '0.4, 0.1, 0.1, 1',
        'cards': ['katon_gokakyu', 'doton_wall', 'suiton_suiryuudan', 'shiki_fujin', 'iron_guard', 'kawarimi_trap']
    },
    {
        'id': 'itachi', 'name': 'Itachi Uchiha', 'title': 'Prodígio do Sharingan & Mestre do Tsukuyomi',
        'hp': 95, 'vigor': 85, 'affinities': [2, 1],
        'color': '0.25, 0.2, 0.3, 1', 'sec_color': '0.8, 0.15, 0.15, 1',
        'cards': ['katon_gokakyu', 'katon_gokakyu', 'sasuke_slash', 'suiton_suiryuudan', 'kawarimi_trap', 'iron_guard']
    },
    {
        'id': 'kabuto', 'name': 'Kabuto Yakushi', 'title': 'Mestre em Medicina & Espionagem',
        'hp': 85, 'vigor': 85, 'affinities': [4, 1],
        'color': '0.4, 0.45, 0.55, 1', 'sec_color': '0.2, 0.25, 0.3, 1',
        'cards': ['sasuke_slash', 'sasuke_slash', 'doton_wall', 'suiton_suiryuudan', 'iron_guard', 'kawarimi_trap']
    },
    {
        'id': 'jiraiya', 'name': 'Jiraiya', 'title': 'O Galante Sannin dos Sapos',
        'hp': 115, 'vigor': 100, 'affinities': [2, 4, 3],
        'color': '0.75, 0.2, 0.2, 1', 'sec_color': '0.2, 0.4, 0.25, 1',
        'cards': ['rasengan', 'katon_gokakyu', 'doton_wall', 'naruto_punch', 'iron_guard', 'kawarimi_trap']
    },
    {
        'id': 'tsunade', 'name': 'Tsunade Senju', 'title': 'Lendária Kunoichi Médica de Força Monstruosa',
        'hp': 120, 'vigor': 110, 'affinities': [5, 4, 1],
        'color': '0.3, 0.6, 0.4, 1', 'sec_color': '0.8, 0.75, 0.3, 1',
        'cards': ['naruto_punch', 'rock_lee_kick', 'dynamic_entry', 'dynamic_entry', 'iron_guard', 'holder_duplo']
    },
    {
        'id': 'chouji', 'name': 'Chouji Akimichi', 'title': 'Tanque de Carne (Baika no Jutsu)',
        'hp': 100, 'vigor': 100, 'affinities': [2, 4],
        'color': '0.85, 0.45, 0.35, 1', 'sec_color': '0.4, 0.2, 0.15, 1',
        'cards': ['naruto_punch', 'naruto_punch', 'dynamic_entry', 'iron_guard', 'iron_guard', 'holder_duplo']
    },
    {
        'id': 'jirobo', 'name': 'Jirobo', 'title': 'Portão Sul do Quarteto do Som (Doton)',
        'hp': 105, 'vigor': 95, 'affinities': [4],
        'color': '0.7, 0.5, 0.3, 1', 'sec_color': '0.35, 0.25, 0.15, 1',
        'cards': ['naruto_punch', 'rock_lee_kick', 'doton_wall', 'doton_wall', 'iron_guard']
    },
    {
        'id': 'kidomaru', 'name': 'Kidomaru', 'title': 'Portão Leste do Quarteto do Som (Arqueiro)',
        'hp': 85, 'vigor': 85, 'affinities': [],
        'color': '0.4, 0.3, 0.25, 1', 'sec_color': '0.2, 0.15, 0.1, 1',
        'cards': ['sasuke_slash', 'sasuke_slash', 'iron_guard', 'kawarimi_trap', 'kawarimi_trap']
    },
    {
        'id': 'sakon_ukon', 'name': 'Sakon e Ukon', 'title': 'Portão Oeste do Quarteto do Som',
        'hp': 90, 'vigor': 95, 'affinities': [],
        'color': '0.5, 0.5, 0.6, 1', 'sec_color': '0.25, 0.25, 0.35, 1',
        'cards': ['naruto_punch', 'rock_lee_kick', 'rock_lee_kick', 'kawarimi_trap', 'iron_guard', 'holder_duplo']
    },
    {
        'id': 'shikamaru', 'name': 'Shikamaru Nara', 'title': 'Estrategista das Sombras (Kagemane)',
        'hp': 80, 'vigor': 80, 'affinities': [2, 4],
        'color': '0.25, 0.5, 0.35, 1', 'sec_color': '0.1, 0.25, 0.15, 1',
        'cards': ['naruto_punch', 'sasuke_slash', 'iron_guard', 'kawarimi_trap', 'kawarimi_trap']
    },
    {
        'id': 'tayuya', 'name': 'Tayuya', 'title': 'Portão Norte do Quarteto do Som (Flauta)',
        'hp': 80, 'vigor': 75, 'affinities': [],
        'color': '0.75, 0.35, 0.45, 1', 'sec_color': '0.4, 0.15, 0.25, 1',
        'cards': ['sasuke_slash', 'sasuke_slash', 'kawarimi_trap', 'iron_guard', 'iron_guard']
    },
    {
        'id': 'kimimaro', 'name': 'Kimimaro Kaguya', 'title': 'Líder dos Cinco do Som (Dança dos Ossos)',
        'hp': 105, 'vigor': 110, 'affinities': [4, 3],
        'color': '0.85, 0.85, 0.9, 1', 'sec_color': '0.4, 0.15, 0.2, 1',
        'cards': ['sasuke_slash', 'rock_lee_kick', 'dynamic_entry', 'doton_wall', 'kawarimi_trap', 'holder_duplo']
    }
]

out_dir = r'c:\Programacao\Faculdade\NarutoCardGame\data\characters'

for c in characters:
    unique_cards = list(dict.fromkeys(c['cards']))
    ext_resources = [
        '[ext_resource type="Script" path="res://src/core/character_data.gd" id="1_chdt"]'
    ]
    card_map = {}
    idx = 2
    for card_id in unique_cards:
        res_id = f'{idx}_{card_id}'
        ext_resources.append(f'[ext_resource type="Resource" path="res://data/abilities/{card_id}.tres" id="{res_id}"]')
        card_map[card_id] = res_id
        idx += 1
        
    deck_refs = [f'ExtResource("{card_map[card_id]}")' for card_id in c['cards']]
    deck_str = ', '.join(deck_refs)
    affinities_str = ', '.join(str(a) for a in c['affinities'])
    
    content = f'''[gd_resource type="Resource" script_class="CharacterData" load_steps={len(ext_resources)} format=3]

{chr(10).join(ext_resources)}

[resource]
script = ExtResource("1_chdt")
id = "{c['id']}"
name = "{c['name']}"
title = "{c['title']}"
tags = Array[String]([])
max_hp = {c['hp']}
current_hp = {c['hp']}
max_vigor = {c['vigor']}
current_vigor = {c['vigor']}
attack_modifier = 1.0
avatar_color = Color({c['color']})
secondary_color = Color({c['sec_color']})
chakra_affinities = Array[int]([{affinities_str}])
starting_deck = Array[Resource("res://src/core/ability_data.gd")]([{deck_str}])
'''
    filepath = os.path.join(out_dir, f"{c['id']}.tres")
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Created {filepath}')

print('All 21 character resources successfully created!')
