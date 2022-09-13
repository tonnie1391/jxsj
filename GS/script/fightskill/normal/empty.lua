--空属性
local tb	= {
	empty={
		fastwalkrun_p={0},
	},
	empty2={
		fastwalkrun_p={0},
		skill_statetime={18*2},
	},
	empty3={--子弹数量=技能等级
		fastwalkrun_p={0},
		skill_missilenum_v = {{{1,1},{2,2}}},
	},
	
	empty_hitcount={
		fastwalkrun_p={0},
		missile_hitcount={{{1,1},{10,10}}},
	},
	empty_lifetime={--子弹持续时间=技能等级*9帧
		fastwalkrun_p={0},
		missile_lifetime_v = {{{1,9},{2,18}}},
	},
	empty_waittime={--子弹持续时间=(技能等级-1)*9帧
		fastwalkrun_p={0},
		skill_waittime = {{{1,0},{2,9}}},
	},
}

FightSkill:AddMagicData(tb)
