module LOL
    ITEMS = {
    '3001' => 'Abyssal Scepter',
    '3105' => 'Aegis of the Legion',
    '1052' => 'Amplifying Tome',
    '3003' => 'Archangel\'s Staff',
    '3005' => 'Atma\'s Impaler',
    '3093' => 'Avarice Blade',
    '1038' => 'B. F. Sword',
    '3102' => 'Banshee\'s Veil',
    '3006' => 'Berserker\'s Greaves',
    '3144' => 'Bilgewater Cutlass',
    '1026' => 'Blasting Wand',
    '3117' => 'Boots of Mobility',
    '1001' => 'Boots of Speed',
    '3009' => 'Boots of Swiftness',
    '1051' => 'Brawler\'s Gloves',
    '3010' => 'Catalyst the Protector',
    '1031' => 'Chain Vest',
    '3028' => 'Chalice of Harmony',
    '1018' => 'Cloak of Agility',
    '1029' => 'Cloth Armor',
    '1042' => 'Dagger',
    '3128' => 'Deathfire Grasp',
    '1055' => 'Doran\'s Blade',
    '1056' => 'Doran\'s Ring',
    '1054' => 'Doran\'s Shield',
    '2038' => 'Elixir of Agility',
    '2039' => 'Elixir of Brilliance',
    '2037' => 'Elixir of Fortitude',
    '3097' => 'Emblem of Valour',
    '3123' => 'Executioner\'s Calling',
    '1004' => 'Faerie Charm',
    '3108' => 'Fiendish Codex',
    '3109' => 'Force of Nature',
    '3110' => 'Frozen Heart',
    '3022' => 'Frozen Mallet',
    '1011' => 'Giant\'s Belt',
    '3024' => 'Glacial Shroud',
    '3026' => 'Guardian Angel',
    '3124' => 'Guinsoo\'s Rageblade',
    '3136' => 'Haunting Guise',
    '2003' => 'Health Potion',
    '3132' => 'Heart of Gold',
    '3146' => 'Hextech Gunblade',
    '3145' => 'Hextech Revolver',
    '3031' => 'Infinity Edge',
    '3032' => 'Innervating Locket',
    '3098' => 'Kage\'s Lucky Pick',
    '3035' => 'Last Whisper',
    '3138' => 'Leviathan',
    '3100' => 'Lich Bane',
    '1036' => 'Long Sword',
    '3126' => 'Madred\'s Bloodrazor',
    '3106' => 'Madred\'s Razors',
    '3114' => 'Malady',
    '3037' => 'Mana Manipulator',
    '2004' => 'Mana Potion',
    '3041' => 'Mejai\'s Soulstealer',
    '1005' => 'Meki Pendant',
    '3111' => 'Mercury\'s Treads',
    '3115' => 'Nashor\'s Tooth',
    '1058' => 'Needlessly Large Rod',
    '1057' => 'Negatron Cloak',
    '3047' => 'Ninja Tabi',
    '1033' => 'Null-Magic Mantle',
    '2042' => 'Oracle\'s Elixir',
    '3044' => 'Phage',
    '3046' => 'Phantom Dancer',
    '3096' => 'Philosopher\'s Stone',
    '1037' => 'Pickaxe',
    '3140' => 'Quicksilver Sash',
    '3143' => 'Randuin\'s Omen',
    '1043' => 'Recurve Bow',
    '1007' => 'Regrowth Pendant',
    '1006' => 'Rejuvenation Bead',
    '3027' => 'Rod of Ages',
    '1028' => 'Ruby Crystal',
    '3116' => 'Rylai\'s Crystal Scepter',
    '1027' => 'Sapphire Crystal',
    '3057' => 'Sheen',
    '2044' => 'Sight Ward',
    '3020' => 'Sorcerer\'s Shoes',
    '3099' => 'Soul Shroud',
    '3065' => 'Spirit Visage',
    '3050' => 'Stark\'s Fervor',
    '3101' => 'Stinger',
    '3068' => 'Sunfire Cape',
    '3131' => 'Sword of the Divine',
    '3141' => 'Sword of the Occult',
    '3070' => 'Tear of the Goddess',
    '3071' => 'The Black Cleaver',
    '3072' => 'The Bloodthirster',
    '3134' => 'The Brutalizer',
    '3075' => 'Thornmail',
    '3077' => 'Tiamat',
    '3078' => 'Trinity Force',
    '1053' => 'Vampiric Scepter',
    '2043' => 'Vision Ward',
    '3135' => 'Void Staff',
    '3082' => 'Warden\'s Mail',
    '3083' => 'Warmog\'s Armor',
    '3152' => 'Will of the Ancients',
    '3091' => 'Wit\'s End',
    '3142' => 'Youmuu\'s Ghostblade',
    '3086' => 'Zeal',
    '3089' => 'Zhonya\'s Ring'
  }
  
  CHAMPIONS = {
    'SadMummy' => 'Amumu',
    'Armordillo' => 'Rammus',
    'Yeti' => 'Nunu',
    'DarkChampion' => 'Tryndamere',
    'Bowmaster' => 'Ashe',
    'Chronokeeper' => 'Zilean',
    'Judicator' => 'Kayle',
    'GemKnight' => 'Taric',
    'Jester' => 'Shaco',
    'GreenTerror' => 'Cho\'Gath',
    'Cryophoenix' => 'Anivia',
    'FallenAngel' => 'Morgana',
    'Permission' => 'Veigar',
    'XenZhao' => 'Xin Zhao',
    'MasterYi' => 'Master Yi',
    'Lich' => 'Karthus',
    'FiddleSticks' => 'Fiddlesticks',
    'KogMaw' => 'Kog\'Maw',
    'SteamGolen' => 'Blitzcrank',
    'Voidwalker' => 'Kassadin',
    'CardMaster' => 'Twisted Fate',
    'Wolfman' => 'Warwick',
    'SteamGolem' => 'Blitzcrank',
    'Armsmaster' => 'Jax',
    'ChemicalMan' => 'Singed',
    'Minotaur' => 'Alistair',
    'Pirate' => 'Gangplank',
    'DrMundo' => 'Dr. Mundo'
  }
  
  MAPS = {
    '1' => 'Summoner\'s Rift',
    '2' => 'Summoner\'s Rift (Winter)',
    '3' => 'Unknown Map',
    '4' => 'Twisted Treeline'
  }

  STATISTICS = {
    '2' => 'Gold',
    '4' => 'Deaths',
    '5' => 'Barracks Destroyed',
    '6' => 'Turrets Destroyed',
    '7' => 'Minions Slain',
    '8' => 'Kills',
    '10' => 'Damage Dealt',
    '11' => 'Damage taken',
    '22' => 'Largest killing spree',
    '23' => 'Largest multi kill',
    '28' => 'Neutral Monsters Slain',
    '32' => 'Magic Damage Dealt',
    '33' => 'Physical damage taken',
    '34' => 'Magic damage taken',
    '39' => 'Largest Critical Strike',
    '42' => 'Time Spent Dead',
    '43' => 'Health restored',
    '48' => 'Assists'
  }
end