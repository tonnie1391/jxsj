--Å­Æø¼¼ÄÜ
local tb	= {
	rage_normal={
		appenddamage_p= {{{1,0},{2,0}}},
		angerdamage_p={20},
		state_hurt_attack={{{1,90},{2,90}},{{1,18*1.5},{2,18*1.5}}},
		skill_deadlystrike_r={100000},
	},
	rage_gold={
		appenddamage_p= {{{1,0},{2,0}}},
		angerdamage_p={40},
		state_hurt_attack={{{1,90},{2,90}},{{1,18*1.5},{2,18*1.5}}},
		skill_deadlystrike_r={100000},
	},
	rage_wood={
		appenddamage_p= {{{1,0},{2,0}}},
		angerdamage_p={40,9},
		skill_deadlystrike_r={100000},
	},
	rage_water={
		appenddamage_p= {{{1,0},{2,0}}},
		state_slowall_attack={{{1,90},{2,90}},{{1,18*3},{2,18*3}}},
	},
	rage_water_child1={
		appenddamage_p= {{{1,0},{2,0}}},
		state_freeze_attack={{{1,90},{2,90}},{{1,18*2.5},{2,18*2.5}}},
	},
	rage_water_child2={
		appenddamage_p= {{{1,0},{2,0}}},
		angerdamage_p={223},
		skill_deadlystrike_r={100000},
	},
	rage_fire={
		appenddamage_p= {{{1,0},{2,0}}},
		angerdamage_p={67},
		skill_deadlystrike_r={100000},
	},
	rage_earth={
		appenddamage_p= {{{1,0},{2,0}}},
		angerdamage_p={10},
		state_stun_attack={{{1,90},{2,90}},{{1,18*1.5},{2,18*1.5}}},
		skill_deadlystrike_r={100000},
	},
	rage_earth_child={
		appenddamage_p= {{{1,0},{2,0}}},
		angerdamage_p={103},
		skill_deadlystrike_r={100000},
	},
}

FightSkill:AddMagicData(tb)
