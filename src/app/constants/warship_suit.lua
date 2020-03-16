return {
  ["1"] = {
    id = 1,
    ["$warship_id"] = 70001,
    name = "探险者",
    desc = "探险者",
    hp_addition = {
      text = "10%",
      relative = 10.0,
      absolute = nil
    },
    hp_desc = "战舰血量增加10%",
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {

    },
    required_battery = {
      {
        item_id = 90001,
        count = 1
      },
      {
        item_id = 90101,
        count = 1
      },
      {
        item_id = 90201,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "battery_speed_1",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      },
      {
        buff_name = "battery_hp",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      },
      {
        buff_name = "battery_attack_1",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      }
    }
  },
  ["2"] = {
    id = 2,
    ["$warship_id"] = 70002,
    name = "穿梭者",
    desc = "穿梭者",
    hp_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    hp_desc = nil,
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {
      {
        buff_name = "warship_shield",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      }
    },
    required_battery = {
      {
        item_id = 90301,
        count = 1
      },
      {
        item_id = 90401,
        count = 1
      },
      {
        item_id = 90501,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_duration_1",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_energy",
        args = {
          {
            percent = 0.5,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_blood_1",
        args = {
          {
            percent = 0.05,
            delta = 0
          }
        }
      }
    }
  },
  ["3"] = {
    id = 3,
    ["$warship_id"] = 70003,
    name = "虚空",
    desc = "虚空",
    hp_addition = {
      text = "10%",
      relative = 10.0,
      absolute = nil
    },
    hp_desc = "战舰血量增加10%",
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "10%",
      relative = 10.0,
      absolute = nil
    },
    frequency_desc = "炮台攻速10%",
    buff_self = {

    },
    required_battery = {
      {
        item_id = 90601,
        count = 1
      },
      {
        item_id = 90701,
        count = 1
      },
      {
        item_id = 90801,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_attack_1",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_chance_1",
        args = {
          {
            percent = 0.2,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_duration_2",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      }
    }
  },
  ["4"] = {
    id = 4,
    ["$warship_id"] = 70004,
    name = "传说",
    desc = "传说",
    hp_addition = {
      text = "10%",
      relative = 10.0,
      absolute = nil
    },
    hp_desc = "战舰血量增加10%",
    attack_addition = {
      text = "10%",
      relative = 10.0,
      absolute = nil
    },
    attack_desc = "炮台伤害10%",
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {

    },
    required_battery = {
      {
        item_id = 90901,
        count = 1
      },
      {
        item_id = 91001,
        count = 1
      },
      {
        item_id = 91101,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_duration_3",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_buffattack_1",
        args = {
          {
            percent = 0.005,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_duration_4",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      }
    }
  },
  ["5"] = {
    id = 5,
    ["$warship_id"] = 70005,
    name = "强袭",
    desc = "强袭",
    hp_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    hp_desc = nil,
    attack_addition = {
      text = "20%",
      relative = 20.0,
      absolute = nil
    },
    attack_desc = "炮台伤害20%",
    frequency_addition = {
      text = "10%",
      relative = 10.0,
      absolute = nil
    },
    frequency_desc = "炮台攻速10%",
    buff_self = {

    },
    required_battery = {
      {
        item_id = 91201,
        count = 1
      },
      {
        item_id = 91301,
        count = 1
      },
      {
        item_id = 91401,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_chance_2",
        args = {
          {
            percent = 0.2,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_duration_5",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_attack_2",
        args = {
          {
            percent = 0.15,
            delta = 0
          }
        }
      }
    }
  },
  ["6"] = {
    id = 6,
    ["$warship_id"] = 70006,
    name = "暴风",
    desc = "暴风",
    hp_addition = {
      text = "15%",
      relative = 15.0,
      absolute = nil
    },
    hp_desc = "战舰血量增加15%",
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {
      {
        buff_name = "battery_conversion",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      }
    },
    required_battery = {
      {
        item_id = 91501,
        count = 1
      },
      {
        item_id = 91601,
        count = 1
      },
      {
        item_id = 91701,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_duration_6",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_duration_7",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_buffattack_2",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      }
    }
  },
  ["7"] = {
    id = 7,
    ["$warship_id"] = 70007,
    name = "决斗者",
    desc = "决斗者",
    hp_addition = {
      text = "20%",
      relative = 20.0,
      absolute = nil
    },
    hp_desc = "战舰血量增加20%",
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {
      {
        buff_name = "warship_shield",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      },
      {
        buff_name = "destroy_blood",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      }
    },
    required_battery = {
      {
        item_id = 91801,
        count = 1
      },
      {
        item_id = 91901,
        count = 1
      },
      {
        item_id = 92001,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_shield",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_duration_8",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_blood_2",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      }
    }
  },
  ["8"] = {
    id = 8,
    ["$warship_id"] = 70008,
    name = "胜利号",
    desc = "胜利号",
    hp_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    hp_desc = nil,
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {
      {
        buff_name = "warship_shield",
        args = {
          {
            percent = 0.1,
            delta = 0
          }
        }
      },
      {
        buff_name = "battery_conversion",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      },
      {
        buff_name = "battery_fullenergy",
        args = {
          {
            delta = 100.0,
            percent = 0
          }
        }
      }
    },
    required_battery = {
      {
        item_id = 92101,
        count = 1
      },
      {
        item_id = 92201,
        count = 1
      },
      {
        item_id = 92301,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_chance_3",
        args = {
          {
            percent = 0.2,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_duration_9",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_attack_3",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      }
    }
  },
  ["9"] = {
    id = 9,
    ["$warship_id"] = 70009,
    name = "战神",
    desc = "战神",
    hp_addition = {
      text = "30%",
      relative = 30.0,
      absolute = nil
    },
    hp_desc = "战舰血量增加30%",
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {
      {
        buff_name = "battery_conversion",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      },
      {
        buff_name = "battery_speed_2",
        args = {
          {
            percent = 0.3,
            delta = 0
          },
          {
            delta = 10.0,
            percent = 0
          }
        }
      }
    },
    required_battery = {
      {
        item_id = 92401,
        count = 1
      },
      {
        item_id = 92501,
        count = 1
      },
      {
        item_id = 92601,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_duration_10",
        args = {
          {
            delta = 2.0,
            percent = 0
          }
        }
      },
      {
        buff_name = "skill_chance_4",
        args = {
          {
            percent = 0.2,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_attack_4",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      }
    }
  },
  ["10"] = {
    id = 10,
    ["$warship_id"] = 70010,
    name = "曙光女神",
    desc = "曙光女神",
    hp_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    hp_desc = nil,
    attack_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    attack_desc = nil,
    frequency_addition = {
      text = "0",
      relative = nil,
      absolute = 0.0
    },
    frequency_desc = nil,
    buff_self = {
      {
        buff_name = "warship_shield",
        args = {
          {
            percent = 0.2,
            delta = 0
          }
        }
      },
      {
        buff_name = "battery_conversion",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      },
      {
        buff_name = "battery_attack_2",
        args = {
          {
            percent = 0.3,
            delta = 0
          },
          {
            delta = 10.0,
            percent = 0
          }
        }
      }
    },
    required_battery = {
      {
        item_id = 92701,
        count = 1
      },
      {
        item_id = 92801,
        count = 1
      },
      {
        item_id = 92901,
        count = 1
      }
    },
    buff_suit = {
      {
        buff_name = "skill_attack_5",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_chance_5",
        args = {
          {
            percent = 0.3,
            delta = 0
          }
        }
      },
      {
        buff_name = "skill_blood_3",
        args = {
          {
            percent = 0.2,
            delta = 0
          }
        }
      }
    }
  }
}