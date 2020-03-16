return {
  ["50001"] = {
    id = 50001,
    name = "炙热切割",
    desc = "对单体目标造成%d%%伤害",
    skill_type = {
      type_1 = "1"
    },
    atk_base = {
      skill_damage = "144",
      buff_hitrate = "0",
      buff_effect = "0",
      buff_duration = "0"
    },
    atk_factor = 3,
    type_atkfactor = 0.08,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0,
    effecttype_factor = 0,
    effect_compensate = 0,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 1,
    targt = 0,
    buff_target = 0,
    condition = 0
  },
  ["50002"] = {
    id = 50002,
    name = "扩散射线",
    desc = "对全体目标造成%d%%伤害，并对目标造成火力干扰【攻击-%0.2f%%】，持续%0.2f秒",
    skill_type = {
      type_1 = "2",
      type_2 = "7"
    },
    atk_base = {
      skill_damage = "129",
      buff_hitrate = "100",
      buff_effect = "20",
      buff_duration = "3"
    },
    atk_factor = 1.8,
    type_atkfactor = 0.09,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.02,
    effecttype_factor = 1,
    effect_compensate = 1,
    timegrow_factor = 0.4,
    timetype_factor = 1.5,
    time_compensate = 1,
    attack_mode = 3,
    targt = 1,
    buff_target = 2,
    condition = 3
  },
  ["50003"] = {
    id = 50003,
    name = "极限爆破",
    desc = "对单体目标造成%d%%伤害",
    skill_type = {
      type_1 = "1"
    },
    atk_base = {
      skill_damage = "154",
      buff_hitrate = "0",
      buff_effect = "0",
      buff_duration = "0"
    },
    atk_factor = 2.9,
    type_atkfactor = 0.1,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0,
    effecttype_factor = 0,
    effect_compensate = 0,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 1,
    targt = 0,
    buff_target = 0,
    condition = 0
  },
  ["50004"] = {
    id = 50004,
    name = "狂热波动",
    desc = "对单体目标造成%d%%伤害，当自身生命值低于30%%时，额外造成50%%伤害",
    skill_type = {
      type_1 = "1",
      type_2 = "12"
    },
    atk_base = {
      skill_damage = "162",
      buff_hitrate = "100",
      buff_effect = "0",
      buff_duration = "0"
    },
    atk_factor = 3,
    type_atkfactor = 0.09,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0,
    effecttype_factor = 0,
    effect_compensate = 0,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 1,
    targt = 0,
    buff_target = 1,
    condition = 12
  },
  ["50005"] = {
    id = 50005,
    name = "炫光射线",
    desc = "对单体目标造成%d%%的技能伤害，并对我方生命值最低的炮台附加护盾【免伤+%0.2f%%】，持续%0.2f秒",
    skill_type = {
      type_1 = "1",
      type_2 = "10"
    },
    atk_base = {
      skill_damage = "153",
      buff_hitrate = "100",
      buff_effect = "15",
      buff_duration = "2.4"
    },
    atk_factor = 2.8,
    type_atkfactor = 0.1,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.005,
    effecttype_factor = 1.5,
    effect_compensate = 1,
    timegrow_factor = 0.4,
    timetype_factor = 1.5,
    time_compensate = 0.8,
    attack_mode = 2,
    targt = 0,
    buff_target = 103,
    condition = 10
  },
  ["50006"] = {
    id = 50006,
    name = "风暴速射",
    desc = "对单体目标造成%d%%的技能伤害，并对我方生命值最低的炮台恢复%0.2f%%的生命值",
    skill_type = {
      type_1 = "1",
      type_2 = "9"
    },
    atk_base = {
      skill_damage = "123",
      buff_hitrate = "100",
      buff_effect = "2",
      buff_duration = "0"
    },
    atk_factor = 2.9,
    type_atkfactor = 0.08,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.003,
    effecttype_factor = 1,
    effect_compensate = 0.8,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 2,
    targt = 0,
    buff_target = 103,
    condition = 5
  },
  ["50007"] = {
    id = 50007,
    name = "神罚之光",
    desc = "对单体目标造成%d%%伤害，当目标生命值低于50%%，则额外造成50%%伤害",
    skill_type = {
      type_1 = "1",
      type_2 = "12"
    },
    atk_base = {
      skill_damage = "182",
      buff_hitrate = "100",
      buff_effect = "0",
      buff_duration = "0"
    },
    atk_factor = 3,
    type_atkfactor = 0.1,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0,
    effecttype_factor = 0,
    effect_compensate = 0,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 2,
    targt = 0,
    buff_target = 19,
    condition = 12
  },
  ["50008"] = {
    id = 50008,
    name = "旋雷光球",
    desc = "对单体目标造成%d%%伤害，并有%0.2f%%概率对目标造成瘫痪【无法行动】，持续%0.2f秒，优先攻击生命值最低的目标。",
    skill_type = {
      type_1 = "1",
      type_2 = "4"
    },
    atk_base = {
      skill_damage = "155",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "3"
    },
    atk_factor = 2.8,
    type_atkfactor = 0.09,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1,
    effect_compensate = 1,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 1,
    attack_mode = 1,
    targt = 3,
    buff_target = 19,
    condition = 1
  },
  ["50009"] = {
    id = 50009,
    name = "螺旋冲击",
    desc = "对单体目标造成%d%%伤害，并有%0.2f%%概率对目标造成维修干扰【无法恢复血量】，持续%0.2f秒，优先攻击生命值最低的目标。",
    skill_type = {
      type_1 = "1",
      type_2 = "5"
    },
    atk_base = {
      skill_damage = "124",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "2.7"
    },
    atk_factor = 2.9,
    type_atkfactor = 0.08,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1.5,
    effect_compensate = 0.8,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 0.9,
    attack_mode = 1,
    targt = 3,
    buff_target = 19,
    condition = 7
  },
  ["50010"] = {
    id = 50010,
    name = "光棱散射",
    desc = "对全体目标造成%d%%伤害,当目标处于燃烧状态时有%0.2f%%概率对目标造成瘫痪【无法行动】，持续%0.2f秒",
    skill_type = {
      type_1 = "2",
      type_2 = "4"
    },
    atk_base = {
      skill_damage = "137",
      buff_hitrate = "15",
      buff_effect = "0",
      buff_duration = "1.8"
    },
    atk_factor = 2,
    type_atkfactor = 0.08,
    hitgrow_factor = 0.015,
    hittype_factor = 1,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1,
    effect_compensate = 0.8,
    timegrow_factor = 0.2,
    timetype_factor = 1,
    time_compensate = 0.9,
    attack_mode = 3,
    targt = 1,
    buff_target = 2,
    condition = 1
  },
  ["50011"] = {
    id = 50011,
    name = "炙热扫射",
    desc = "对全体目标造成%d%%伤害，并有%0.2f%%概率对目标造成燃烧【每0.5秒损失1%%生命，燃烧伤害上限2000】，持续%0.2f秒",
    skill_type = {
      type_1 = "2",
      type_2 = "3"
    },
    atk_base = {
      skill_damage = "130",
      buff_hitrate = "45",
      buff_effect = "0",
      buff_duration = "3"
    },
    atk_factor = 1.8,
    type_atkfactor = 0.09,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1,
    effect_compensate = 1,
    timegrow_factor = 0.3,
    timetype_factor = 1.5,
    time_compensate = 1,
    attack_mode = 4,
    targt = 1,
    buff_target = 2,
    condition = 2
  },
  ["50012"] = {
    id = 50012,
    name = "混沌雷击",
    desc = "对全体目标造成%d%%伤害，当目标处于瘫痪状态时有%0.2f%%概率对目标造成能量干扰【无法获得能量且释放技能】，持续%0.2f秒",
    skill_type = {
      type_1 = "2",
      type_2 = "6"
    },
    atk_base = {
      skill_damage = "145",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "2.4"
    },
    atk_factor = 1.9,
    type_atkfactor = 0.1,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1.5,
    effect_compensate = 0.9,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 0.8,
    attack_mode = 5,
    targt = 1,
    buff_target = 2,
    condition = 9
  },
  ["50013"] = {
    id = 50013,
    name = "脉冲波动",
    desc = "对单体目标造成%d%%伤害，并对处于瘫痪状态的目标额外造成50%%的伤害，且优先攻击处于瘫痪状态的目标。",
    skill_type = {
      type_1 = "1",
      type_2 = "12"
    },
    atk_base = {
      skill_damage = "165",
      buff_hitrate = "100",
      buff_effect = "0",
      buff_duration = "0"
    },
    atk_factor = 3,
    type_atkfactor = 0.09,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0,
    effecttype_factor = 0,
    effect_compensate = 0,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 1,
    targt = 10,
    buff_target = 19,
    condition = 12
  },
  ["50014"] = {
    id = 50014,
    name = "光辉散射",
    desc = "对全体目标造成%d%%伤害，有%0.2f%%概率造成能量干扰【无法获得能量且释放技能与释放技能】，持续%0.2f秒",
    skill_type = {
      type_1 = "2",
      type_2 = "6"
    },
    atk_base = {
      skill_damage = "117",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "2.7"
    },
    atk_factor = 1.8,
    type_atkfactor = 0.08,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1,
    effect_compensate = 0.8,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 0.9,
    attack_mode = 3,
    targt = 2,
    buff_target = 2,
    condition = 9
  },
  ["50015"] = {
    id = 50015,
    name = "极雷眩光",
    desc = "对单体目标造成%d%%伤害，并有%0.2f%%概率对目标造成瘫痪【无法行动】，持续%0.2f秒",
    skill_type = {
      type_1 = "1",
      type_2 = "4"
    },
    atk_base = {
      skill_damage = "157",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "2.4"
    },
    atk_factor = 2.9,
    type_atkfactor = 0.1,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1.5,
    effect_compensate = 0.9,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 0.8,
    attack_mode = 2,
    targt = 0,
    buff_target = 19,
    condition = 1
  },
  ["50016"] = {
    id = 50016,
    name = "斗志强击",
    desc = "对单体目标造成%d%%伤害，对燃烧状态的目标额外造成50%%的伤害，且优先攻击处于燃烧状态的目标。当自身处于火力增幅状态时额外伤害提升至100%%。",
    skill_type = {
      type_1 = "1",
      type_2 = "12"
    },
    atk_base = {
      skill_damage = "147",
      buff_hitrate = "100",
      buff_effect = "0",
      buff_duration = "0"
    },
    atk_factor = 3,
    type_atkfactor = 0.08,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0,
    effecttype_factor = 0,
    effect_compensate = 0,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 1,
    targt = 9,
    buff_target = 19,
    condition = 12
  },
  ["50017"] = {
    id = 50017,
    name = "毁灭之光",
    desc = "对单体目标造成%d%%伤害，有%0.2f%%概率对目标造成燃烧【每0.5秒损失1%%生命，燃烧伤害上限2000】，持续%0.2f秒，且优先攻击处于生命值最低的目标。当自身处于火力增幅状态燃烧命中率增加至100%%",
    skill_type = {
      type_1 = "1",
      type_2 = "3"
    },
    atk_base = {
      skill_damage = "184",
      buff_hitrate = "30",
      buff_effect = "0",
      buff_duration = "1.6"
    },
    atk_factor = 3,
    type_atkfactor = 0.1,
    hitgrow_factor = 0.015,
    hittype_factor = 1,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1,
    effect_compensate = 0.9,
    timegrow_factor = 0.3,
    timetype_factor = 1,
    time_compensate = 0.8,
    attack_mode = 2,
    targt = 3,
    buff_target = 19,
    condition = 2
  },
  ["50018"] = {
    id = 50018,
    name = "极限之击",
    desc = "对单体目标造成%d%%伤害，并对我方进攻型炮台附加火力增幅特效【攻击+%0.2f%%】，持续%0.2f秒",
    skill_type = {
      type_1 = "1",
      type_2 = "11"
    },
    atk_base = {
      skill_damage = "165",
      buff_hitrate = "100",
      buff_effect = "20",
      buff_duration = "2"
    },
    atk_factor = 3,
    type_atkfactor = 0.09,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.02,
    effecttype_factor = 1,
    effect_compensate = 0.9,
    timegrow_factor = 0.4,
    timetype_factor = 1,
    time_compensate = 1,
    attack_mode = 1,
    targt = 0,
    buff_target = 106,
    condition = 4
  },
  ["50019"] = {
    id = 50019,
    name = "双星爆散",
    desc = "对单体目标造成%d%%伤害，并对生命值＜50%%的目标额外造成50%%伤害，优先攻击生命值最低的炮台",
    skill_type = {
      type_1 = "1",
      type_2 = "12"
    },
    atk_base = {
      skill_damage = "167",
      buff_hitrate = "100",
      buff_effect = "0",
      buff_duration = "0"
    },
    atk_factor = 3,
    type_atkfactor = 0.09,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0,
    effecttype_factor = 0,
    effect_compensate = 0,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 1,
    targt = 3,
    buff_target = 19,
    condition = 12
  },
  ["50020"] = {
    id = 50020,
    name = "绝对领域",
    desc = "对单体目标造成%d%%伤害，并对我方全体附加护盾【免伤+%0.2f%%】，持续%0.2f秒",
    skill_type = {
      type_1 = "1",
      type_2 = "10"
    },
    atk_base = {
      skill_damage = "126",
      buff_hitrate = "100",
      buff_effect = "12",
      buff_duration = "2.7"
    },
    atk_factor = 2.8,
    type_atkfactor = 0.08,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.005,
    effecttype_factor = 1.5,
    effect_compensate = 0.8,
    timegrow_factor = 0.4,
    timetype_factor = 1.5,
    time_compensate = 0.9,
    attack_mode = 1,
    targt = 0,
    buff_target = 101,
    condition = 10
  },
  ["50021"] = {
    id = 50021,
    name = "高能渗透",
    desc = "对单体目标造成%d%%伤害，并对我方全体附加火力增幅【攻击+%0.2f%%】，持续%0.2f秒",
    skill_type = {
      type_1 = "1",
      type_2 = "11"
    },
    atk_base = {
      skill_damage = "159",
      buff_hitrate = "100",
      buff_effect = "27",
      buff_duration = "2.4"
    },
    atk_factor = 2.9,
    type_atkfactor = 0.1,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.02,
    effecttype_factor = 1,
    effect_compensate = 1,
    timegrow_factor = 0.4,
    timetype_factor = 1.5,
    time_compensate = 0.8,
    attack_mode = 1,
    targt = 0,
    buff_target = 101,
    condition = 4
  },
  ["50022"] = {
    id = 50022,
    name = "毁灭爆破",
    desc = "对全体目标造成%d%%伤害，并对目标造成火力干扰【攻击-%0.2f%%】，持续%0.2f秒，当自身生命值＜30%%时状态持续时间翻倍。",
    skill_type = {
      type_1 = "2",
      type_2 = "7"
    },
    atk_base = {
      skill_damage = "118",
      buff_hitrate = "100",
      buff_effect = "16",
      buff_duration = "2.7"
    },
    atk_factor = 1.8,
    type_atkfactor = 0.08,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.02,
    effecttype_factor = 1,
    effect_compensate = 0.8,
    timegrow_factor = 0.4,
    timetype_factor = 1.5,
    time_compensate = 0.9,
    attack_mode = 5,
    targt = 2,
    buff_target = 2,
    condition = 3
  },
  ["50023"] = {
    id = 50023,
    name = "电磁风暴",
    desc = "对全体目标造成%d%%伤害，并对我方防御型炮台附加护盾【免伤+%0.2f%%】，持续%0.2f秒，当自身生命值＜30%%时状态持续时间翻倍。",
    skill_type = {
      type_1 = "2",
      type_2 = "10"
    },
    atk_base = {
      skill_damage = "147",
      buff_hitrate = "100",
      buff_effect = "15",
      buff_duration = "2.4"
    },
    atk_factor = 1.8,
    type_atkfactor = 0.1,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.005,
    effecttype_factor = 1.5,
    effect_compensate = 1,
    timegrow_factor = 0.4,
    timetype_factor = 1.5,
    time_compensate = 0.8,
    attack_mode = 3,
    targt = 2,
    buff_target = 2,
    condition = 10
  },
  ["50024"] = {
    id = 50024,
    name = "致命扫射",
    desc = "对全体目标造成%d%%伤害，并对我方防御型炮台恢复%0.2f%%的生命值，当自身生命值＜30%%时恢复效果翻倍。",
    skill_type = {
      type_1 = "2",
      type_2 = "9"
    },
    atk_base = {
      skill_damage = "133",
      buff_hitrate = "100",
      buff_effect = "4",
      buff_duration = "0"
    },
    atk_factor = 1.8,
    type_atkfactor = 0.09,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.0015,
    effecttype_factor = 1.5,
    effect_compensate = 0.9,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 4,
    targt = 2,
    buff_target = 107,
    condition = 5
  },
  ["50025"] = {
    id = 50025,
    name = "神威之怒",
    desc = "对全体目标造成%d%%伤害，有%0.2f%%概率对目标造成燃烧【每0.5秒损失1%%生命，燃烧伤害上限2000】，持续%0.2f秒，当目标处于维修干扰状态时燃烧状态命中率提升至100%%",
    skill_type = {
      type_1 = "2",
      type_2 = "3"
    },
    atk_base = {
      skill_damage = "159",
      buff_hitrate = "30",
      buff_effect = "0",
      buff_duration = "2"
    },
    atk_factor = 2,
    type_atkfactor = 0.09,
    hitgrow_factor = 0.015,
    hittype_factor = 1,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1,
    effect_compensate = 1,
    timegrow_factor = 0.3,
    timetype_factor = 1,
    time_compensate = 1,
    attack_mode = 5,
    targt = 2,
    buff_target = 2,
    condition = 2
  },
  ["50026"] = {
    id = 50026,
    name = "究极爆弹",
    desc = "对单体目标造成%d%%伤害，若目标处于燃烧或维修干扰状态时对我方全体炮台恢复%0.2f%%的生命值。",
    skill_type = {
      type_1 = "1",
      type_2 = "9"
    },
    atk_base = {
      skill_damage = "127",
      buff_hitrate = "100",
      buff_effect = "4",
      buff_duration = "0"
    },
    atk_factor = 2.8,
    type_atkfactor = 0.08,
    hitgrow_factor = 0,
    hittype_factor = 0,
    hit_compensate = 0,
    effectgrow_factor = 0.0015,
    effecttype_factor = 1.5,
    effect_compensate = 0.8,
    timegrow_factor = 0,
    timetype_factor = 0,
    time_compensate = 0,
    attack_mode = 1,
    targt = 0,
    buff_target = 101,
    condition = 5
  },
  ["50027"] = {
    id = 50027,
    name = "灼热炼狱",
    desc = "对全体目标造成%d%%伤害，对%0.2f%%概率对目标造成维修干扰【无法恢复血量】，持续%0.2f秒，当目标处于燃烧状态时维修干扰命中率提升至100%%",
    skill_type = {
      type_1 = "2",
      type_2 = "5"
    },
    atk_base = {
      skill_damage = "150",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "2.4"
    },
    atk_factor = 1.9,
    type_atkfactor = 0.1,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1.5,
    effect_compensate = 0.9,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 0.8,
    attack_mode = 5,
    targt = 2,
    buff_target = 2,
    condition = 7
  },
  ["50028"] = {
    id = 50028,
    name = "末日审判",
    desc = "对全体目标造成%d%%伤害，并有%0.2f%%概率对目标造成维修干扰【无法恢复血量】，持续%0.2f秒，若目标是防守型炮台则状态命中率提升至100%%",
    skill_type = {
      type_1 = "2",
      type_2 = "5"
    },
    atk_base = {
      skill_damage = "120",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "2.7"
    },
    atk_factor = 1.9,
    type_atkfactor = 0.08,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1.5,
    effect_compensate = 0.8,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 0.9,
    attack_mode = 4,
    targt = 2,
    buff_target = 2,
    condition = 7
  },
  ["50029"] = {
    id = 50029,
    name = "雷神威压",
    desc = "对全体目标造成%d%%伤害，并有%0.2f%%概率对目标造成瘫痪【无法行动】，持续%0.2f秒，若目标是攻击型炮台则状态命中率提升至100%%",
    skill_type = {
      type_1 = "2",
      type_2 = "4"
    },
    atk_base = {
      skill_damage = "150",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "2.4"
    },
    atk_factor = 1.9,
    type_atkfactor = 0.1,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1.5,
    effect_compensate = 0.9,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 0.8,
    attack_mode = 5,
    targt = 2,
    buff_target = 2,
    condition = 1
  },
  ["50030"] = {
    id = 50030,
    name = "时空禁制",
    desc = "对全体目标造成%d%%伤害，并有%0.2f%%概率对目标造成能量干扰【无法获得能量且释放技能】，持续%0.2f秒，若目标是技能型炮台则状态命中率提升至100%%",
    skill_type = {
      type_1 = "2",
      type_2 = "6"
    },
    atk_base = {
      skill_damage = "135",
      buff_hitrate = "23",
      buff_effect = "0",
      buff_duration = "3"
    },
    atk_factor = 1.9,
    type_atkfactor = 0.09,
    hitgrow_factor = 0.015,
    hittype_factor = 1.5,
    hit_compensate = 1,
    effectgrow_factor = 0,
    effecttype_factor = 1.5,
    effect_compensate = 1,
    timegrow_factor = 0.2,
    timetype_factor = 1.5,
    time_compensate = 1,
    attack_mode = 3,
    targt = 2,
    buff_target = 2,
    condition = 9
  }
}