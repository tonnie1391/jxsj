--生活技能的buff
local tb	= {
	lifeskill_lifemax_p={
		lifemax_p={{{1,5},{2,8},{3,12},{4,16},{5,20},{6,25},{7,30},{8,36},{9,43},{10,50}}},
		lifemax_v={{{1,60},{2,96},{3,144},{4,192},{5,240},{6,300},{7,360},{8,432},{9,516},{10,600}}},
		skill_statetime={18}
	},
	
	lifeskill_damage_all_resist={
		damage_all_resist={{{1,10},{2,16},{3,23},{4,31},{5,40},{6,50},{7,61},{8,73},{9,86},{10,100}}},
		skill_statetime={18}
	},
	
	lifeskill_modaoshi={
		addphysicsdamage_p={{{1,20},{2,32},{3,46},{4,62},{5,80},{6,100},{7,122},{8,146},{9,172},{10,200}}},
		addphysicsmagic_p={{{1,20},{2,32},{3,46},{4,62},{5,80},{6,100},{7,122},{8,146},{9,172},{10,200}}},
		skill_statetime={18}
	},
	lifeskill_seriesrestime={
		state_hurt_resisttime={{{1,10},{2,16},{3,25},{4,31},{5,41},{6,50},{7,61},{8,71},{9,88},{10,100}}},
		state_weak_resisttime={{{1,10},{2,16},{3,25},{4,31},{5,41},{6,50},{7,61},{8,71},{9,88},{10,100}}},
		state_slowall_resisttime={{{1,10},{2,16},{3,25},{4,31},{5,41},{6,50},{7,61},{8,71},{9,88},{10,100}}},
		state_burn_resisttime={{{1,10},{2,16},{3,25},{4,31},{5,41},{6,50},{7,61},{8,71},{9,88},{10,100}}},
		state_stun_resisttime={{{1,10},{2,16},{3,25},{4,31},{5,41},{6,50},{7,61},{8,71},{9,88},{10,100}}},
		skill_statetime={18}
	},
	
}

FightSkill:AddMagicData(tb)
