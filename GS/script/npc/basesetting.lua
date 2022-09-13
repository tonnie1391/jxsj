-- AI基础模板
Npc.tbAIBase	= {
	ai0	= {
		AIMode		= 0,
		AIParam1	= 0,
		AIParam2	= 0,
		AIParam3	= 0,
		AIParam4	= 0,
		AIParam5	= 0,
		AIParam6	= 0,
		AIParam7	= 0,
		AIParam8	= 0,
		AIParam9	= 0,
		AIParam10	= 0,
	},
	stup	= {
		AIMode		= 1,			--1号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	passivenormal	= {				--被动,巡逻,单技能,无逃跑,无治疗,无特技
		AIMode		= 4,			--4号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	passivenormal2	= {				--被动,巡逻,双技能,无逃跑,无治疗,无特技
		AIMode		= 4,			--4号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 66,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 33,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	passivenormal2ex	= {				--被动,巡逻,双技能,无逃跑,无治疗,无特技
		AIMode		= 4,			--4号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 80,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 20,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	passivenormal3	= {				--被动,巡逻,双技能,无逃跑,无治疗,无特技
		AIMode		= 4,			--4号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 50,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 30,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 20,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	passivenormal3ex	= {				--被动,巡逻,双技能,无逃跑,无治疗,无特技
		AIMode		= 4,			--4号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 80,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 10,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 10,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	passiveflee	= {					--被动,巡逻,单技能,逃跑,无治疗,无特技
		AIMode		= 5,			--5号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 15,			--血量低于15%时
		AIParam3	= 100,			--逃跑概率
		AIParam4	= 0,			--不治疗
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 0,			--无用
	},
	passiveflee2ex	= {				--主动,巡逻,2技能,逃跑,无治疗,无特技
		AIMode		= 5,			--5号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 15,			--血量低于15%时
		AIParam3	= 100,			--逃跑概率
		AIParam4	= 0,			--不治疗
		AIParam5	= 80,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 20,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 0,			--无用
	},
	passiveheal	= {					--被动,巡逻,单技能,逃跑(无法治疗时),治疗,无特技
		AIMode		= 5,			--5号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 20,			--血量低于15%时
		AIParam3	= 100,			--治疗概率
		AIParam4	= 100,			--不逃跑
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 1,			--最大治疗次数
	},

	passiveskill	= {				--被动,巡逻,单技能,逃跑(无法使用特技时),无治疗,特技
		AIMode		= 6,			--5号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 20,			--血量低于15%时
		AIParam3	= 50,			--特技触发概率
		AIParam4	= 100,			--不逃跑
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 1,			--最大治疗次数
	},

	activenormal	= {				--主动,巡逻,单技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	activenormal2	= {				--主动,巡逻,双技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 50,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 50,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	activenormal2ex	= {				--主动,巡逻,双技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 80,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 20,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	activenormal3	= {				--主动,巡逻,3技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 50,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 30,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 20,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	activenormal3ex	= {				--主动,巡逻,3技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 80,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 10,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 10,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	activeflee	= {					--主动,巡逻,单技能,逃跑,无治疗,无特技
		AIMode		= 2,			--2号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 15,			--血量低于15%时
		AIParam3	= 100,			--逃跑概率
		AIParam4	= 0,			--不治疗
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 0,			--无用
	},

	fleeactive2ex	= {				--主动,巡逻,2技能,逃跑,无治疗,无特技
		AIMode		= 2,			--2号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 15,			--血量低于15%时
		AIParam3	= 100,			--逃跑概率
		AIParam4	= 0,			--不治疗
		AIParam5	= 80,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 20,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 0,			--无用
	},

	activeheal	= {					--主动,巡逻,单技能,逃跑(无法治疗时),治疗,无特技
		AIMode		= 2,			--2号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 20,			--血量低于15%时
		AIParam3	= 100,			--治疗概率
		AIParam4	= 100,			--不逃跑
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 1,			--最大治疗次数
	},

	activeskill	= {					--主动,巡逻,单技能,逃跑(无法使用特技时),无治疗,特技
		AIMode		= 3,			--3号AI模式,被动治疗
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 20,			--血量低于15%时
		AIParam3	= 50,			--特技触发概率
		AIParam4	= 100,			--不逃跑
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 1,			--最大治疗次数
	},

	noaction	= {					--被动,巡逻,挨打无反应
		AIMode		= 4,			--4号AI模式,被动治疗
		AIParam1	= 0,			--无敌人时,巡逻概率
		AIParam2	= 0,
		AIParam3	= 0,
		AIParam4	= 0,
		AIParam5	= 0,
		AIParam6	= 100,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 0,
		AIParam8	= 0,
		AIParam9	= 0,
		AIParam10	= 0,
	},

	activeinstancing	= {			--主动,无巡逻,单技能,无逃跑,无治疗,无特技（副本专用小怪  by peres）
		AIMode		= 1,			--1号AI模式
		AIParam1	= 0,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 10,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	activeboss	= {					--主动bossAI
		AIMode		= 99,			--BossAI模式,配置成此模式时会读相关BossAI配置文件
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 10,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 0,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	activeboss_bai	= {				--主动,不巡逻,3技能,无逃跑,无治疗,无特技
		AIMode		= 99,			--1号AI模式
		AIParam1	= 0,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 0,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 0,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	activestup	= {					--主动静止怪,不巡逻,不移动,单技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式
		AIParam1	= 0,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 100,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 0,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},

	passivestup	= {					--被动静止怪,不巡逻,不移动,单技能,无逃跑,无治疗,无特技
		AIMode		= 4,			--4号AI模式
		AIParam1	= 0,			--无敌人时,巡逻概率
		AIParam2	= 100,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 100,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 0,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	fleewuxinggu	= {				--不还击,巡逻,单技能,逃跑,无治疗,无特技
		AIMode		= 5,			--5号AI模式
		AIParam1	= 50,			--无敌人时,巡逻概率
		AIParam2	= 0,			--血量低于100%时
		AIParam3	= 100,			--逃跑概率
		AIParam4	= 0,			--不治疗
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 0,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 50,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 0,			--无用
	},
	fleecaibaotu	= {				--不还击,巡逻,单技能,逃跑,无治疗,无特技
		AIMode		= 5,			--5号AI模式
		AIParam1	= 50,			--无敌人时,巡逻概率
		AIParam2	= 100,			--血量低于100%时
		AIParam3	= 100,			--逃跑概率
		AIParam4	= 0,			--不治疗
		AIParam5	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam6	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam7	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam8	= 0,			--敌人在攻击范围之外时,待机的概率
		AIParam9	= 50,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam10	= 0,			--无用
		AIParam11	= 200,			--无用
	},
	yingziwushi	= {					--影子武士ai
		AIMode		= 99,			--BossAI模式,配置成此模式时会读相关BossAI配置文件
		AIParam1	= 50,			--无敌人时,巡逻概率
		AIParam2	= 0,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 0,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 0,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 50,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	cangbaotuboss2	= {				--主动静止怪,不巡逻,不移动,双技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式--主动
		AIParam1	= 0,			--无敌人时,巡逻概率
		AIParam2	= 4,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 100,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 0,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
	cangbaotuboss1	= {				--主动,巡逻,双技能,无逃跑,无治疗,无特技
		AIMode		= 1,			--1号AI模式主动
		AIParam1	= 15,			--无敌人时,巡逻概率
		AIParam2	= 60,			--技能的概率 对应SkillList里面的技能 1
		AIParam3	= 100,			--技能的概率 对应SkillList里面的技能 2
		AIParam4	= 0,			--技能的概率 对应SkillList里面的技能 3
		AIParam5	= 0,			--技能的概率 对应SkillList里面的技能 4
		AIParam6	= 25,			--敌人在攻击范围之外时,待机的概率
		AIParam7	= 10,			--敌人在攻击范围之外时,巡逻的概率为AIParam7-AIParam6;追击敌人的概率为100-Param7
		AIParam8	= 0,			--无用
		AIParam9	= 0,			--无用
		AIParam10	= 0,			--无用
	},
};

--五行定义
Npc.tbSeriesIndex = {
	[Env.SERIES_NONE]	= 1,
	[Env.SERIES_METAL]	= 2,
	[Env.SERIES_WOOD]	= 3,
	[Env.SERIES_WATER]	= 4,
	[Env.SERIES_FIRE]	= 5,
	[Env.SERIES_EARTH]	= 6,
};

-- 技能基础模板

--技能id表
Npc.tbSkillId =	{  	["sk"]						= {308, 309, 310, 311, 312, 313},		--近身单体
					["singleskillmelee"] 		= {308, 309, 310, 311, 312, 313},		--近身单体
					["singleskillmidrange"]		= {314, 315, 316, 317, 318, 319},		--中程单体
					["singleskillrange"]		= {320, 321, 322, 323, 324, 325},		--远程单体
					--近身普通攻击技能
					["singleskillfist"]			= {308, 309, 310, 311, 312, 313},		--拳单体
					["singleskillsword"]		= {338, 339, 340, 341, 342, 343},		--剑单体
					["singleskillblade"]		= {344, 345, 346, 347, 348, 349},		--刀单体
					["singleskillstick"]		= {350, 351, 352, 353, 354, 355},		--棍单体
					["singleskillspear"]		= {356, 357, 358, 359, 360, 361},		--枪单体
					["singleskillhammer"]		= {362, 363, 364, 365, 366, 367},		--锤单体
					["singleskillarrow"]		= {368, 369, 370, 371, 372, 373},		--箭单体
					["meleehack2"]				= {700, 700, 701, 702, 703, 704},		--近身2次砍击(第1套动作)
					["meleefist2"]				= {705, 705, 706, 707, 708, 709},		--近身2次拳攻击(第1套动作)
					--远程气攻击技能为匹配npc动作（刺,挥砍,拳）制作
					["rangestab"]				= {749, 749, 750, 751, 752, 753},		--远程尖锐的气攻击(第2套动作)
					["rangehack"]				= {754, 754, 755, 756, 757, 758},		--远程锋利的气攻击(第2套动作)
					["rangegas"]				= {320, 321, 322, 323, 324, 325},		--远程气攻击(第2套动作)
					["accidence"]				= {900, 900, 917, 925, 931, 941},		--各门派远程单体入门技能
					["advanced"]				= {1032, 1032, 1044, 1046, 1056, 1058},		--各门派高级范围攻击技能
					--特殊攻击方式的技能
					["rangetwiceskill"]			= {507, 507, 508, 509, 510, 511},		--远程2次攻击（第2套动作）
					["roundskill"]				= {512, 512, 513, 514, 515, 516},		--范围 圆形
					["semiroundskill"]			= {517, 517, 518, 519, 520, 521},		--范围 半圆
					["parallelskill"]			= {522, 522, 523, 524, 525, 526},		--范围 平衡
					["followskill"]				= {527, 527, 528, 529, 530, 531},		--跟踪
					["certainnormalskill"]		= {532, 532, 533, 534, 535, 536},		--定点普通
					["certainflyskill"]			= {537, 537, 538, 539, 540, 541},		--定点飞行
					["certainroundskill"]		= {542, 542, 543, 544, 545, 546},		--定点范围
					--npc第二套动作专用技能(为匹配npc各种奇怪的第二套动作制作)
					["meleehack3"]				= {710, 710, 711, 712, 713, 714},		--近身3次砍击（第2套动作）
					["meleehack2ex"]			= {715, 715, 716, 717, 718, 719},		--近身2次砍击（第2套动作）
					["meleestab"]				= {720, 720, 721, 722, 723, 724},		--近身刺击（第2套动作）
					["meleestab4"]				= {725, 725, 726, 727, 728, 729},		--近身4次刺击（第2套动作）
					["selfround"]				= {730, 730, 731, 732, 733, 734},		--自身范围攻击（第2套动作）
					["targetround"]				= {735, 735, 735, 735, 735, 735},		--目标范围攻击（第2套动作）
					["sectorgas"]				= {736, 736, 737, 738, 739, 740},		--扇形气攻击（第2套动作）
					["sectordart"]				= {741, 741, 741, 741, 741, 741},		--散花镖（第2套动作）
					["rainarrow"]				= {742, 742, 742, 742, 742, 742},		--箭雨（第2套动作）
					["midpenetrable"]			= {744, 744, 745, 746, 747, 748},		--中程穿透气攻击（第2套动作）
					["rangepenetrable"]			= {1677,1677,1678,1679,1680,1681},		--远程穿透气攻击（第2套动作）
					["rangehack2"]				= {507, 507, 508, 509, 510, 511},		--远程2段锋锐的气攻击（第2套动作）
					--定点多次攻击技能
					["powerful"]				= {1029, 1029, 1130, 1116, 978, 1121},		--远程2段锋锐的气攻击（第2套动作）
					["xiakedaoskill"]			= {1804},		--侠客岛
				}
--技能等级与角色等级的关联表
Npc.tbSkillLv = {	{1,1},{9,1},
					{10,2},{19,2},
					{20,3},{29,3},
					{30,4},{39,4},
					{40,5},{49,5},
					{50,6},{59,6},
					{60,7},{69,7},
					{70,8},{79,8},
					{80,9},{89,9},
					{90,10},{100,10},
					}

--根据SkillType返回合适的技能函数
local function GetSkillId(SkillType)
	local function sss(nSeries)
		local nIndex	= Npc.tbSeriesIndex[nSeries];
		local nSkilId	= Npc.tbSkillId[SkillType][nIndex];
		return nSkilId;
	end
	return sss;
end

Npc.tbSkillBase	= {
	xkdsk	= {
		Skill1				= GetSkillId("xiakedaoskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	sk	= {
		Skill1				= GetSkillId("sk"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	noskill	= {
		Skill1				= 0,
		Level1				= 0,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	singleskill	= {
		Skill1				= 1,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	singleskillmelee	= {
		Skill1				= GetSkillId("singleskillmelee"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--中程
	singleskillmidrange	= {
		Skill1				= GetSkillId("singleskillmidrange"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--远程气攻击
	singleskillpenetrable	= { --穿透
		Skill1				= GetSkillId("rangepenetrable"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	singleskillrange	= {
		Skill1				= GetSkillId("singleskillrange"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--拳,拳+中程,拳+远程
	singleskillfist	= {
		Skill1				= GetSkillId("singleskillfist"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fistandrangegas	= {
		Skill1				= GetSkillId("singleskillfist"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangegas"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fistandsectordart	= {
		Skill1				= GetSkillId("singleskillfist"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("sectordart"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fistandsectorgas	= {
		Skill1				= GetSkillId("singleskillfist"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("sectorgas"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fistandmidpenetrable	= {
		Skill1				= GetSkillId("singleskillfist"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("midpenetrable"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fistandselfround	= {
		Skill1				= GetSkillId("singleskillfist"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("selfround"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--近身2拳+扇形气攻击
	meleefist2andsectorgas	= {
		Skill1				= GetSkillId("meleefist2"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("sectorgas"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--箭系列
	singleskillarrow	= {
		Skill1				= GetSkillId("singleskillarrow"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	arrowandrangegas	= {
		Skill1				= GetSkillId("singleskillarrow"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangegas"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	arrowandrangetwice	= {
		Skill1				= GetSkillId("singleskillarrow"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangetwiceskill"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	arrowandrangehack	= {
		Skill1				= GetSkillId("singleskillarrow"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	arrowandrainarrow	= {
		Skill1				= GetSkillId("singleskillarrow"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rainarrow"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	arrowandsectordart	= {
		Skill1				= GetSkillId("singleskillarrow"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("sectordart"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	arrowandselfround	= {
		Skill1				= GetSkillId("singleskillarrow"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("selfround"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--剑,剑+中程,剑+远程
	singleskillsword	= {
		Skill1				= GetSkillId("singleskillsword"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	swordandrangehack	= {
		Skill1				= GetSkillId("singleskillsword"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	swordandrangestab	= {
		Skill1				= GetSkillId("singleskillsword"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangestab"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	swordandmeleestab4	= {
		Skill1				= GetSkillId("singleskillsword"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("meleestab4"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	swordandselfround	= {
		Skill1				= GetSkillId("singleskillsword"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("selfround"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--刀系列
	singleskillblade	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	bladeandmeleehack2ex	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("meleehack2ex"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	bladeandrangegas	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangegas"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	bladeandrangehack	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	bladeandrangehack2	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack2"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	bladeandrangestab	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangestab"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	bladeandmeleestab	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("meleestab"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	bladeandselfround	= {
		Skill1				= GetSkillId("singleskillblade"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("selfround"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--刀2段攻击+2次远程挥砍攻击
	meleehack2andrange	= {
		Skill1				= GetSkillId("meleehack2"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack2"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--刀3段攻击+自身范围
	meleehack3andrangehack2	= {
		Skill1				= GetSkillId("meleehack3"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack2"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--棍,棍+中程,棍+远程
	singleskillstick	= {
		Skill1				= GetSkillId("singleskillstick"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	stickandrangegas	= {
		Skill1				= GetSkillId("singleskillstick"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangegas"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	stickandrangehack	= {
		Skill1				= GetSkillId("singleskillstick"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	stickandselfround	= {
		Skill1				= GetSkillId("singleskillstick"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("selfround"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--枪,枪+中程,枪+远程
	singleskillspear	= {
		Skill1				= GetSkillId("singleskillspear"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	spearandrangehack	= {
		Skill1				= GetSkillId("singleskillspear"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangehack"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	spearandmeleestab4	= {
		Skill1				= GetSkillId("singleskillspear"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("meleestab4"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	spearandmeleehack2ex	= {
		Skill1				= GetSkillId("singleskillspear"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("meleehack2ex"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--锤,锤+中程,锤+远程
	singleskillhammer	= {
		Skill1				= GetSkillId("singleskillhammer"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	hammerandrangegas	= {
		Skill1				= GetSkillId("singleskillhammer"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("rangegas"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	hammerandselfround	= {
		Skill1				= GetSkillId("singleskillhammer"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("selfround"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	hammerandtargetround	= {
		Skill1				= GetSkillId("singleskillhammer"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("targetround"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--逃跑系
	fleeskill	= {
		Skill1				= 0,
		Level1				= 0,
		Skill2				= 1,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fleeskillmelee	= {
		Skill1				= 0,
		Level1				= 0,
		Skill2				= GetSkillId("singleskillmelee"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fleeskillmidrange	= {
		Skill1				= 0,
		Level1				= 0,
		Skill2				= GetSkillId("singleskillmidrange"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fleeskillrange	= {
		Skill1				= 0,
		Level1				= 0,
		Skill2				= GetSkillId("singleskillrange"),
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	healskill	= {
		Skill1				= 133,
		Level1				= 1,
		Skill2				= 1,
		Level2				= 1,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	specialskill	= {
		Skill1				= 45,
		Level1				= 1,
		Skill2				= 1,
		Level2				= 1,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	qiangtianskill	= {			--类似枪天王攻击技能
		Skill1				= 501,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	chuitianskill	= {			--类似锤天王攻击技能
		Skill1				= 503,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	fireskill	= {				--类似弹指烈焰攻击技能
		Skill1				= 505,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	coldskill	= {				--类似冰效果攻击技能
		Skill1				= 506,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	rangetwiceskill	= {			--远程,2次攻击
		Skill1				= GetSkillId("rangetwiceskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	roundskill	= {				--范围,圆形
		Skill1				= GetSkillId( "roundskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	semiroundskill	= {			--范围,半圆形
		Skill1				= GetSkillId("semiroundskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	parallelskill	= {			--范围,平衡
		Skill1				= GetSkillId("parallelskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	followskill	= {				--子弹跟踪
		Skill1				= GetSkillId("followskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	certainnormalskill	= {		--定点普通
		Skill1				= GetSkillId("certainnormalskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	certainflyskill	= {			--定点飞行效果
		Skill1				= GetSkillId("certainflyskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	certainroundskill	= {		--定点范围
		Skill1				= GetSkillId("certainroundskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	skill759	= {		--定点范围多次晕眩,
		Skill1				= 759,--该技能使用的一阳指的class,1级50%晕眩,攻击2次
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--家族副本用各路线npc技能
	daoshao		={		--刀少
		Skill1				= 900,
		Level1				= Npc.tbSkillLv,
		Skill2				= 901,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	gunshao		={		--棍少
		Skill1				= 902,
		Level1				= Npc.tbSkillLv,
		Skill2				= 903,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	qiangtian		={		--枪天
		Skill1				= 904,
		Level1				= Npc.tbSkillLv,
		Skill2				= 906,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	chuitian		={		--锤天
		Skill1				= 908,
		Level1				= Npc.tbSkillLv,
		Skill2				= 910,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	nutang		={		--弩唐
		Skill1				= 912,
		Level1				= Npc.tbSkillLv,
		Skill2				= 913,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	kengtang		={		--坑唐
		Skill1				= 915,
		Level1				= Npc.tbSkillLv,
		Skill2				= 994,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	daodu		={		--刀毒
		Skill1				= 917,
		Level1				= Npc.tbSkillLv,
		Skill2				= 918,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhangdu		={		--掌毒
		Skill1				= 919,
		Level1				= Npc.tbSkillLv,
		Skill2				= 920,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhange		={		--掌峨
		Skill1				= 921,
		Level1				= Npc.tbSkillLv,
		Skill2				= 922,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	fue		={		--辅娥
		Skill1				= 924,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jiancui		={		--剑翠
		Skill1				= 925,
		Level1				= Npc.tbSkillLv,
		Skill2				= 926,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	daocui		={		--刀翠
		Skill1				= 927,
		Level1				= Npc.tbSkillLv,
		Skill2				= 928,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhanggai		={		--掌丐
		Skill1				= 929,
		Level1				= Npc.tbSkillLv,
		Skill2				= 930,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	gungai		={		--棍丐
		Skill1				= 931,
		Level1				= Npc.tbSkillLv,
		Skill2				= 932,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhanren		={		--战忍
		Skill1				= 933,
		Level1				= Npc.tbSkillLv,
		Skill2				= 934,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	moren		={		--魔忍
		Skill1				= 935,
		Level1				= Npc.tbSkillLv,
		Skill2				= 936,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	qiwu		={		--气武
		Skill1				= 937,
		Level1				= Npc.tbSkillLv,
		Skill2				= 938,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jianwu		={		--剑武
		Skill1				= 939,
		Level1				= Npc.tbSkillLv,
		Skill2				= 940,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	daokun		={		--刀昆
		Skill1				= 941,
		Level1				= Npc.tbSkillLv,
		Skill2				= 942,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jiankun		={		--剑昆
		Skill1				= 943,
		Level1				= Npc.tbSkillLv,
		Skill2				= 944,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	chuiming		={		--锤明
		Skill1				= 946,
		Level1				= Npc.tbSkillLv,
		Skill2				= 948,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jianming		={		--剑明
		Skill1				= 949,
		Level1				= Npc.tbSkillLv,
		Skill2				= 950,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhiduan		={		--指段
		Skill1				= 952,
		Level1				= Npc.tbSkillLv,
		Skill2				= 954,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jianduan		={		--剑段
		Skill1				= 956,
		Level1				= Npc.tbSkillLv,
		Skill2				= 957,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	--藏宝图
	cangbaotuboss2sk	= {		--藏宝图boss2的定点攻击和怒气
		Skill1				= 666,
		Level1				= 10,
		Skill2				= 671,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotuboss2717	= {		--副本第一个BOSS
		Skill1				= 971,
		Level1				= Npc.tbSkillLv,
		Skill2				= 967,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotuboss2718	= {		--副本第二个BOSS
		Skill1				= 690,
		Level1				= 10,
		Skill2				= 970,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2713		= {		--副本第1种小怪
		Skill1				= 968,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2714		= {		--副本第2种小怪
		Skill1				= 969,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2715		= {		--副本第3种小怪
		Skill1				= 970,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2716		= {		--副本第4种小怪
		Skill1				= 967,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2732		= {		--高级藏宝图小怪
		Skill1				= 1010,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2733		= {		--高级藏宝图小怪
		Skill1				= 1010,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1016,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2734		= {		--高级藏宝图小怪
		Skill1				= 1006,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1005,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	cangbaotu2735		= {		--高级藏宝图小怪
		Skill1				= 938,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1015,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--某副本用小怪ai
	certainroundskillandbellow		= {		--定点范围+狮子吼
		Skill1				= 938,
		Level1				= Npc.tbSkillLv,
		Skill2				= 31,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--80-90级任务副本用小怪ai
	npc4001		= {		--天罡地煞+冻结+迟缓陷阱
		Skill1				= 920,
		Level1				= 1,
		Skill2				= 1016,
		Level2				= 2,
		Skill3				= 71,
		Level3				= 20,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4005		= {		--自身范围攻击+断魂
		Skill1				= 1005,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 1,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4007		= {		--伏魔棍法+狮子吼
		Skill1				= 903,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,--989,
		Level2				= 0,--5,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4008		= {		--近身2段攻击+断魂刺
		Skill1				= GetSkillId("meleehack2"),
		Level1				= 8,
		Skill2				= 983,
		Level2				= 1,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4009		= {		--扇形箭攻击,带击退效果
		Skill1				= 986,
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4089		= {		--定点冰心仙子
		Skill1				= 1008,
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	xoyo3249	= {		--弹幕
		Skill1				= 1096,
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	duanjinren	= {		--断筋刃+定点攻击
		Skill1				= 266,
		Level1				= 10,
		Skill2				= certainroundskill,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	moyinshipo	= {		--自身范围攻击+混乱
		Skill1				= 1005,
		Level1				= Npc.tbSkillLv,
		Skill2				= 148,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	toutianhuanri	= {		--自身范围攻击+偷天换日
		Skill1				= 1005,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1093,
		Level2				= 1,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zuixiancuogu	= {		--自身范围攻击+醉仙错骨
		Skill1				= 1005,
		Level1				= Npc.tbSkillLv,
		Skill2				= 699,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	huanyingzhuihunqiang	= {		--自身范围攻击+幻影追魂枪
		Skill1				= 1005,
		Level1				= Npc.tbSkillLv,
		Skill2				= 484,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc2759	= {		--天竺绝刀+无我无剑
		Skill1				= 1032,
		Level1				= 10,
		Skill2				= 938,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc2775	= {		--天竺绝刀
		Skill1				= 1032,
		Level1				= 10,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc2782	= {		--狂雷震地+大范围回血技能
		Skill1				= 943,
		Level1				= 10,
		Skill2				= 1132,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc2776	= {		--近身2次攻击+断魂刺
		Skill1				= GetSkillId("meleehack2"),
		Level1				= 10,
		Skill2				= 983,
		Level2				= 1,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc2761	= {		--无我无剑+怒雷连环击
		Skill1				= 938,
		Level1				= 10,
		Skill2				= 1131,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc2764	= {		--六脉神剑+冰踪无影
		Skill1				= 1069,
		Level1				= 10,
		Skill2				= 1050,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
-------------------宋金------------------------
	song	= {		--天地无极
		Skill1				= 1058,
		Level1				= 20,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jin	= {			--天外流星
		Skill1				= 1056,
		Level1				= 20,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--------------------任务
	npc4126_1		={		--刀毒10技能
		Skill1				= 917,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4127_3	={		--掌毒90+技能，会放诅咒，掌毒50级技能（小几率）
		Skill1				= 917,
		Level1				= Npc.tbSkillLv,
		Skill2				= 920,
		Level2				= Npc.tbSkillLv,
		Skill3				= 801,
		Level3				= 20,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4128_1		={		--刀毒50技能
		Skill1				= 918,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4131_2		={		--锤明10级技能+断筋刃
		Skill1				= 946,
		Level1				= Npc.tbSkillLv,
		Skill2				= 266,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4132_2		={		--剑翠90+50
		Skill1				= 1048,
		Level1				= Npc.tbSkillLv,
		Skill2				= 926,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4136_2		={		--枪天90+断魂
		Skill1				= 1034,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4142_1		={		--刀翠90
		Skill1				= 1050,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4145_2		={		--战忍90+拉人
		Skill1				= 1055,
		Level1				= Npc.tbSkillLv,
		Skill2				= 492,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4146_2		={		--魔忍90+诅咒
		Skill1				= 1056,
		Level1				= Npc.tbSkillLv,
		Skill2				= 154,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4148_2		={		--剑昆50+90
		Skill1				= 944,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1063,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4152_3		={		--阴风蚀骨,小李飞刀,乱环击
		Skill1				= 1044,
		Level1				= Npc.tbSkillLv,
		Skill2				= 915,
		Level2				= Npc.tbSkillLv,
		Skill3				= 1039,
		Level3				= Npc.tbSkillLv,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4153_1		={		--风霜碎影
		Skill1				= 1046,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4156_2		={		--锤天90+断魂
		Skill1				= 1036,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4157_3		={		--小李飞刀,勾魂阱,缠身刺
		Skill1				= 915,
		Level1				= Npc.tbSkillLv,
		Skill2				= 71,
		Level2				= 20,
		Skill3				= 73,
		Level3				= 20,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4159_1		={		--六脉神剑
		Skill1				= 1069,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4160_3		={		--龙吞式+断魂刺
		Skill1				= 1064,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4162_1		={		--飞龙在天
		Skill1				= 1052,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4170_1		={		--追星逐月
		Skill1				= 1052,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
-------区域争夺战---------
	domain_soldier	= {		--直线单体+直线穿透
		Skill1				= 1033,
		Level1				= 10,
		Skill2				= 1032,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	domain_general	= {		--自身范围+自身特大范围攻击
		Skill1				= 1139,
		Level1				= 20,
		Skill2				= 1140,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
---------------师徒任务--------------------
	shitu01	= {		--山寨先锋
		Skill1				= 1034,
		Level1				= 20,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	shitu02	= {		--山寨弓手
		Skill1				= 1056,
		Level1				= 20,
		Skill2				= 992,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	shitu03	= {		--山寨巫医
		Skill1				= GetSkillId("sectorgas"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 801,
		Level2				= 20,
		Skill3				= 147,
		Level3				= 10,
		Skill4				= 0,
		Level4				= 0,
	},
------------------120-130任务--------------------------
	npc4488	= {		--陷阱:小李,乱环,缠身
		Skill1				= 915,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1039,
		Level2				= 20,
		Skill3				= 73,
		Level3				= 20,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4489	= {		--袖箭:暴雨,天罗,断筋
		Skill1				= 992,
		Level1				= Npc.tbSkillLv,
		Skill2				= 913,
		Level2				= Npc.tbSkillLv,
		Skill3				= 266,
		Level3				= 10,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4490	= {		--飞镖:散花+九宫
		Skill1				= 741,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1162,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4498	= {		--掌毒:阴风+悲魔
		Skill1				= 1144,
		Level1				= Npc.tbSkillLv,
		Skill2				= 801,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4499	= {		--掌毒:玄阴斩
		Skill1				= 1042,
		Level1				= Npc.tbSkillLv,
		Skill2				= 269,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4500	= {		--刀昆:傲雪啸风
		Skill1				= 1061,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4501	= {		--刀昆:狂风骤电
		Skill1				= 942,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4507	= {		--掌峨:风霜碎影
		Skill1				= 1046,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4512	= {		--战忍:云龙击,魔音
		Skill1				= 1055,
		Level1				= Npc.tbSkillLv,
		Skill2				= 148,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4519	= {		--战忍:云龙击
		Skill1				= 1055,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4521	= {		--锤天:乘龙+断魂
		Skill1				= 1036,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	fleenpc4521	= {		--锤天:乘龙+断魂
		Skill1				= 0,
		Level1				= 0,
		Skill2				= 1036,
		Level2				= Npc.tbSkillLv,
		Skill3				= 983,
		Level3				= 10,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4525	= {		--锤明:龙吞+困虎
		Skill1				= 1064,
		Level1				= Npc.tbSkillLv,
		Skill2				= 958,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	fleenpc4525	= {		--锤明:龙吞+困虎
		Skill1				= 0,
		Level1				= 0,
		Skill2				= 1064,
		Level2				= Npc.tbSkillLv,
		Skill3				= 958,
		Level3				= 10,
		Skill4				= 0,
		Level4				= 0,

	},
	npc4531	= {		--魔忍:天外流星+慑魂乱心
		Skill1				= 1056,
		Level1				= Npc.tbSkillLv,
		Skill2				= 155,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4543	= {		--枪天:追星+断魂
		Skill1				= 1064,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	fleenpc4543	= {		--枪天:追星+断魂
		Skill1				= 0,
		Level1				= 0,
		Skill2				= 1064,
		Level2				= Npc.tbSkillLv,
		Skill3				= 983,
		Level3				= 10,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4544	= {		--剑翠:冰心+雨打梨花
		Skill1				= 1048,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1209,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4548	= {		--刀少:天竺绝刀
		Skill1				= 1032,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	fleenpc4548	= {		--刀少:天竺绝刀
		Skill1				= 0,
		Level1				= 0,
		Skill2				= 1032,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4548_2	= {		--刀少:天竺绝刀_近身攻击
		Skill1				= 2053,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc4550	= {		--剑明:90+50
		Skill1				= 1066,
		Level1				= Npc.tbSkillLv,
		Skill2				= 950,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
-------------各路线使用90级技能-------------
	daoshao90_1		={		--刀少
		Skill1				= 1032,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	gunshao90_2		={		--棍少
		Skill1				= 1033,
		Level1				= Npc.tbSkillLv,
		Skill2				= 989,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	gunshao90_3		={		--棍少
		Skill1				= 1033,
		Level1				= Npc.tbSkillLv,
		Skill2				= 989,
		Level2				= 10,
		Skill3				= 821,
		Level3				= 10,
		Skill4				= 0,
		Level4				= 0,
	},
	qiangtian90_2		={		--枪天
		Skill1				= 1034,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	chuitian90_2		={		--锤天
		Skill1				= 1036,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	nutang90_2		={		--弩唐
		Skill1				= 992,
		Level1				= Npc.tbSkillLv,
		Skill2				= 266,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	kengtang90_2		={		--坑唐
		Skill1				= 994,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1039,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	kengtang90_3		={		--坑唐
		Skill1				= 915,
		Level1				= Npc.tbSkillLv,
		Skill2				= 994,
		Level2				= Npc.tbSkillLv,
		Skill3				= 1039,
		Level3				= Npc.tbSkillLv,
		Skill4				= 0,
		Level4				= 0,
	},
	daodu90_2		={		--刀毒
		Skill1				= 1042,
		Level1				= Npc.tbSkillLv,
		Skill2				= 774,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhangdu90_2		={		--掌毒
		Skill1				= 1044,
		Level1				= Npc.tbSkillLv,
		Skill2				= 801,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhange90_1		={		--掌峨
		Skill1				= 1046,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	fue90_1		={		--辅娥
		Skill1				= 924,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jiancui90_2		={		--剑翠
		Skill1				= 1048,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1209,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	daocui90_1		={		--刀翠
		Skill1				= 1050,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhanggai90_1		={		--掌丐
		Skill1				= 1052,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	gungai90_2		={		--棍丐
		Skill1				= 1054,
		Level1				= Npc.tbSkillLv,
		Skill2				= 491,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	zhanren90_3		={		--战忍
		Skill1				= 1055,
		Level1				= Npc.tbSkillLv,
		Skill2				= 492,
		Level2				= 10,
		Skill3				= 148,
		Level3				= 20,
		Skill4				= 0,
		Level4				= 0,
	},
	moren90_3		={		--魔忍
		Skill1				= 1056,
		Level1				= Npc.tbSkillLv,
		Skill2				= 936,
		Level2				= Npc.tbSkillLv,
		Skill3				= 155,
		Level3				= 20,
		Skill4				= 0,
		Level4				= 0,
	},
	qiwu90_1		={		--气武
		Skill1				= 1058,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jianwu90_2		={		--剑武
		Skill1				= 1059,
		Level1				= Npc.tbSkillLv,
		Skill2				= 1216,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	daokun90_1		={		--刀昆
		Skill1				= 1061,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jiankun90_3		={		--剑昆
		Skill1				= 943,
		Level1				= Npc.tbSkillLv,
		Skill2				= 944,
		Level2				= Npc.tbSkillLv,
		Skill3				= 1063,
		Level3				= Npc.tbSkillLv,
		Skill4				= 0,
		Level4				= 0,
	},
	chuiming90_2		={		--锤明
		Skill1				= 1064,
		Level1				= Npc.tbSkillLv,
		Skill2				= 983,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jianming90_3		={		--剑明
		Skill1				= 949,
		Level1				= Npc.tbSkillLv,
		Skill2				= 950,
		Level2				= Npc.tbSkillLv,
		Skill3				= 1066,
		Level3				= Npc.tbSkillLv,
		Skill4				= 0,
		Level4				= 0,
	},
	zhiduan90_2		={		--指段
		Skill1				= 1067,
		Level1				= Npc.tbSkillLv,
		Skill2				= 216,
		Level2				= 10,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	jianduan90_2		={		--剑段
		Skill1				= 1069,
		Level1				= Npc.tbSkillLv,
		Skill2				= 957,
		Level2				= Npc.tbSkillLv,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},

	--逍遥谷2期
	xoyo_jiancui		={		--剑翠90
		Skill1				= 1048,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--秦始皇陵
	bmy_normalskill		={		--各种远程单体技能
		Skill1				= GetSkillId("accidence"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--范围攻击+高威力技能
	roundandpowerful	= {
		Skill1				= GetSkillId("advanced"),
		Level1				= Npc.tbSkillLv,
		Skill2				= GetSkillId("powerful"),
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--逍遥谷3期
	xoyo4660_1	= {
		Skill1				= 1427,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	xoyo4661_1	= {
		Skill1				= 1056,
		Level1				= Npc.tbSkillLv,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--清明节活动
	plant	= {--植物
		Skill1				= {{1,1603},{2,1604},{3,1605},{4,1605}},
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	corpse	= {--僵尸
		Skill1				= {{1,1617},{2,1618},{3,1619},{4,1619}},
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--年兽攻城
	nianshou_2011_3		={		--年兽
		Skill1				= 1078,
		Level1				= 11,
		Skill2				= 1323,
		Level2				= 11,
		Skill3				= 1137,
		Level3				= 11,
		Skill4				= 0,
		Level4				= 0,
	},
--hellxoyo
	xoyo7345		={		--旋转子弹
		Skill1				= 2111,
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	xoyo7343		={		--扇形火焰
		Skill1				= 2125,
		Level1				= 2,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	xoyo6745		={		--测试用必杀技
		Skill1				= 475,
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	xoyo7388		={		--春_夏
		Skill1				= 2192,
		Level1				= 1,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	xoyo7389		={		--夏_秋
		Skill1				= 2193,
		Level1				= 2,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	xoyo7390		={		--秋_冬
		Skill1				= 2194,
		Level1				= 3,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	xoyo7391		={		--冬_冬
		Skill1				= 2195,
		Level1				= 4,
		Skill2				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
--夜岚关npc AI
	npc7180			={		--棍单体+断魂
		Skill1				= GetSkillId("singleskillstick"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 1675,
		Level2				= 5,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc7183			={		--定点群攻+队友慈航
		Skill1				= GetSkillId("certainroundskill"),
		Level1				= Npc.tbSkillLv,
		Skill2				= 1683,
		Level2				= 4,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	carriertest		= {
		Skill1 				= 475,
		Level1				= 20,
		Skill2 				= 604,
		Level2				= 20,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	carrierboat1	= {		--竹筏单体攻击
		Skill1 				= 2975,
		Level1				= 10,
		Skill2 				= 0,
		Level2				= 0,
		Skill3				= 0,
		Level3				= 0,
		Skill4				= 0,
		Level4				= 0,
	},
	npc11001			={		--战车技能，直线攻击
		Skill1				= 2940,
		Level1				= 1,
		Skill2				= 2978,
		Level2				= 1,
		Skill3				= 2942,
		Level3				= 1,
		Skill4				= 2946,
		Level4				= 1,
	},
	npc11002			={		--箭塔炮塔技能，定点攻击
		Skill1				= 2945,
		Level1				= 1,
		Skill2				= 2948,
		Level2				= 1,
		Skill3				= 2949,
		Level3				= 1,
		Skill4				= 2950,
		Level4				= 1,
	},
};

--强度基础模板
--根据数据表返回多倍数值
--tbDataTemplet:	数值表的name
--multiple:			最终对应级别的数值是攻击表内的值的倍数,可不填,默认为1
local function GetData(tbDataTemplet, multiple)
	local function eee(nSeries, nLevel)
		local data = {};--攻击表
		data = tbDataTemplet
		multiple = multiple or 1;
		local data_v = math.floor( Lib.Calc:Link(nLevel, data) * multiple);
		return data_v;
	end;
	return eee;
end

--五行相克表,表中的值表示该行属性的NPC的列抗性高低(均按"无金木水火土"的顺序)
Npc.tbXiangKe	=	{	{ 2, 2, 2, 2, 2 },
						{ 2, 3, 2, 1, 2 },
						{ 1, 2, 2, 2, 3 },
						{ 2, 2, 2, 3, 1 },
						{ 3, 2, 1, 2, 2 },
						{ 2, 1, 3, 2, 2 }}

--根据tbResist和s返回合适的抗性函数
local function GetResist(tbResist, s)
	local function rrr(nSeries,nLevel)
		local rs = {};
		local nIndex = Npc.tbSeriesIndex[nSeries];
		local xk 	= Npc.tbXiangKe[nIndex][s];
		rs =  tbResist[xk];
--		local sz = ""
		local rs_v = Lib.Calc:Link(nLevel,rs);
--		sz = "nSeries="..nSeries..",DefSeries="..s..",xk="..xk..",nLevel"..nLevel..",rs_v="..rs_v;
--		print(sz)
		return rs_v;
	end;
	return rrr;
end

--根据期望的3种抗性百分比来设定该npc为s五行时对应等级的抗性值
local function SetResistByRis_p(tbRis, s)
	local function rrr(nSeries,nLevel)
		local tbRis_p = tbRis;
		local nIndex = Npc.tbSeriesIndex[nSeries];
		local xk 	= Npc.tbXiangKe[nIndex][s];
		local ris_v = math.floor(tbRis_p[xk]*(nLevel*10+200)/(1.7-tbRis_p[xk]));
		return ris_v;
	end;
	return rrr;
end
--npc五行属性与五行攻击的关系表,行五行的npc的列属性攻击
Npc.tbSeriesAtk	=	{	{ 1, 0, 0, 0, 0 },
						{ 1, 0, 0, 0, 0 },
						{ 0, 2, 0, 0, 0 },
						{ 0, 0, 1, 0, 0 },
						{ 0, 0, 0, 1, 0 },
						{ 0, 0, 0, 0, 1 }}
--根据五行和需要的攻击属性返回合适的攻击函数
--tbAtk:	攻击表的name
--s:		五行
--multiple:	最终攻击是攻击表内的值的倍数,可不填,默认为1
local function GetAtack(tbAtk, s, multiple)
	local function xxx(nSeries, nLevel)
		local atk = {};--攻击表
		local nIndex	= Npc.tbSeriesIndex[nSeries];
		local atktype 	= Npc.tbSeriesAtk[nIndex][s];
		local sz = ""
		if atktype == 2 then
			atk = tbAtk[atktype];
		elseif atktype == 1 then
			atk = tbAtk[atktype];
		else atk = 0;
		end;
		multiple = multiple or 1;
		local atk_v = math.floor( Lib.Calc:Link(nLevel,atk) * multiple);
		return atk_v;
	end;
	return xxx;
end

--根据五行返回合适的数值
local function GetSeriesData(tbData)
	local function ppp(nSeries)
		local nIndex	= Npc.tbSeriesIndex[nSeries];
		local nData	= tbData[nIndex];
		return nData;
	end
	return ppp;
end

--根据五行和等级返回合适的数值
local function GetSLData(tbData, multiple)
	local function ppp(nSeries, nLevel)
		local nIndex	= Npc.tbSeriesIndex[nSeries];
		local Data = {};
		Data = tbData[nIndex];
		multiple = multiple or 1;
		local Data_v = math.floor( Lib.Calc:Link(nLevel, Data) * multiple);
		return Data_v;
	end
	return ppp;
end

--常用数据表
--主要为与等级相关的数据,用于强度中放大数值
Npc.tbDataTemplet={
	intensity99 = {		--练级怪经验表
					{  1,   50},{  9,   50},
					{ 10,  100},{ 19,  100},
					{ 20,  150},{ 29,  150},
					{ 30,  200},{ 39,  200},
					{ 40,  300},{ 49,  300},
					{ 50,  400},{ 59,  400},
					{ 60,  500},{ 69,  500},
					{ 70,  650},{ 79,  650},
					{ 80,  800},{ 89,  800},
					{ 90,  850},{ 99,  850},
					{100,  900},{109,  900},
					{110,  950},{119,  950},
					{120,  1000},{129, 1000},
					{130,  1100},{139, 1100},
					{140,  1250},{150, 1250},
				 },
	cangbaotuboss1_Exp		= { {  1,     50},{  9,     50},
								{ 10,   2690},{ 19,   2708},
								{ 20,   2990},{ 29,   3008},
								{ 30,   5950},{ 39,   6040},
								{ 40,  65000},{ 49,  65000},
								{ 50,  65000},{ 59,  65000},
								{ 60, 150000},{ 69, 150000},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90, 300000},{ 99, 300000},
								{100, 300000},{109, 300000},
								{110,   3300},{119,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
	cangbaotuboss2_Exp		= { {  1,     50},{  9,     50},
								{ 10,   2690},{ 19,   2708},
								{ 20,   2990},{ 29,   3008},
								{ 30,   5950},{ 39,   6040},
								{ 40,  65000},{ 49,  65000},
								{ 50,  65000},{ 59,  65000},
								{ 60, 150000},{ 69, 150000},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90, 600000},{ 99, 600000},
								{100, 600000},{109, 600000},
								{110,   3300},{119,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
	mingfuyuanhunLife	= {		--冥府冤魂生命值表
							{1,180},{9,360},{10,54800},{60,1279400},{100,2924400},
							},
	intensity99_Life	= {		--练级怪生命值表,战斗时间3秒
							{1,90},{9,180},{10,250},{20,980},{30,2370},{40,3610},{50,4810},{60,6730},{90,14440},{100,19690},
							},
	domain_Life			= {		--练级怪生命值表,战斗时间3秒
							{1,90},{9,180},{10,250},{20,980},{30,2370},{40,3610},{50,4810},{60,6730},{90,14440},{100,19690},{105,29000},{120,39247},
							},
	intensity2_Life		= {		--强度2怪的生命值表
							{1,90},{9,180},{10,2400},{30,21200},{60,64000},{100,146200},
							},
	intensity3_Life		= {		--强度3怪的生命值表
							{1,90},{9,180},{10,3400},{30,30300},{60,82000},{100,246100},
							},
	intensity4_Life		= {
							{1,90},{9,180},{10,6100},{30,53800},{60,159900},{100,365500},
							},
	intensity5_Life		= {		--强度5怪的生命值表
							{1,90},{9,180},{10,9100},{60,213200},{100,487400},
							},
	intensity6_Life		= {		--强度6怪的生命值表
							{1,90},{9,180},{10,13700},{60,319800},{100,731100},
							},
	intensity7_Life		= {
							{1,90},{9,180},{10,18300},{60,426500},{100,974800},
							},
	intensity8_Life		= {		--强度8怪的生命值表
							{1,90},{9,180},{10,27400},{60,639700},{100,1462200},
							},
	intensity9_Life		= {		--强度9怪的生命值表
							{1,90},{9,180},{10,54800},{60,1300000},{100,3000000},
							},
	battle2_Life		= {		--宋金校尉的生命值表
							{1,90},{60,24700},{90,49300},{100,65800},
							},
	battle3_Life		= {		--宋金统领的生命值表
							{1,90},{60,64000},{90,109700},{100,146200},
							},
	battle4_Life		= {		--宋金副将的生命值表
							{1,90},{60,137100},{90,274200},{100,365500},
							},

	battle5_Life		= {		--宋金大将的生命值表
							{1,90},{9,180},{10,27400},{60,639700},{100,1462200},
							},
	battle6_Life		= {		--宋金大将的生命值表
							{1,90},{9,180},{10,27400},{60,639700},{100,1462200},
							},
--区域争夺战
--+8套
	dispute8_Life		= {		--全身+8的玩家生命值表
							{1,90},{9,180},{85,5000},{95,6000},{105,6300},{115,7000},
							},
--+10套
	dispute10_Life		= {		--全身+10的玩家生命值表
							{1,90},{9,180},{85,5800},{95,6700},{105,7000},{115,7750},
							},
--+12套
	dispute12_Life		= {		--全身+12的玩家生命值表
							{1,90},{9,180},{85,6250},{95,7200},{105,7650},{115,8500},
							},
--+14套
	dispute14_Life		= {		--全身+14的玩家生命值表
							{1,90},{9,180},{85,6850},{95,8000},{105,8500},{115,9500},
							},
	wanted_LifeReplenish	= {	--通缉任务npc回血速度
								{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}
								},
	worldboss_LifeReplenish	= {	--通缉任务npc回血速度
								{1,160*0.9},{55,7125000*0.9},{100,21930000*0.9}
								},
--逍遥谷怪基础生命值表,基本上和练级怪血量相同,战斗时间3秒
	XoyoBaseLife		= { --基本上和强度0的怪的血量相同
							{1,90},{9,180},{10,250},{30,2370*0.6},{60,6730*0.6},{100,19690},{110,22930},
							},
	XoyoBaseLife2		= {		--强度2怪的生命值表
							{1,90},{9,180},{10,2400},{30,21200*0.6},{60,64000*0.6},{100,146200},{110,166750},
							},
	XoyoBaseLife3		= {		--强度3怪的生命值表
							{1,90},{9,180},{10,3400},{30,30300*0.6},{60,82000*0.6},{100,246100},{110,287125},
							},
	XoyoBaseLife4		= {
							{1,90},{9,180},{10,6100},{30,53800*0.6},{60,159900*0.6},{100,365500},{110,416900},
							},
	XoyoBaseLife5		= {		--强度5怪的生命值表
							{1,90},{9,180},{10,9100*0.6},{60,213200*0.6},{100,487400},{110,555950},
							},
	XoyoBaseLife6		= {		--强度6怪的生命值表
							{1,90},{9,180},{10,13700*0.6},{60,319800*0.6},{100,731100},{110,833925},
							},
	XoyoBaseLife7		= {
							{1,90},{9,180},{10,18300*0.6},{60,426500*0.6},{100,974800},{110,1111875},
							},
	XoyoBaseLife8		= {		--强度8怪的生命值表
							{1,90},{9,180},{10,27400*0.6},{60,639700*0.6},{100,1462200},{110,1667825},
							},
	XoyoBaseLife9		= {		--强度9怪的生命值表
							{1,90},{9,180},{10,54800*0.6},{60,1300000*0.6},{100,3000000},{110,3425000},
							},
	zhangdu120_Life		= {		--掌毒120技能傀儡的生命值表
							{1,15*18/10*1*200},{9,15*18/10*9*200},{10,15*18/10*10*200},{120,15*18/10*120*200},
							},
	BaseLife_new	= {		--新npc基础血量,90~150级,参考职业:14套,15%攻击披风刀少,战斗时间1秒
							{1,32434},{90,32434},{99,33694},{100,39045},{109,42982},{110,43122},{150,48763},
							},
	}

--抗性表
Npc.tbResist = {
	--pp级怪,未使用
	pp 		=	{	[1] = {{1, 5},{20, 10},{50, 18},{100, 30}},--低抗
					[2] = {{1,20},{20, 50},{50,150},{100,350}},--中抗
					[3] = {{1,40},{20,120},{50,300},{100,800}},--高抗
				},

	--普通强度怪
	--练级怪intensity0,fellow0-5全部跟随npc,宋金士兵,白虎堂普通npc
	normal		=	{	[1] = {{1,20},{9, 28},{10, 65},{100,245}},--低抗
						[2] = {{1,20},{9, 28},{10, 65},{100,245}},--中抗
						[3] = {{1,20},{9, 28},{10, 90},{ 30,130},{50,210},{100,260}},--高抗
					},
	--高强度怪
	--intensity1-intensity5,宋金校尉,统领,副将和大将,
	special	=	{	[1] = {{1,20},{9,28},{10, 50},{100,270}},--低抗
					[2] = {{1,20},{9,28},{10, 90},{100,360}},--中抗
					[3] = {{1,20},{9,28},{10,150},{100,528}},--高抗
				},
	--boss级怪
	--intensity6-intensity8,宋金元帅,白虎堂boss,世界boss1
	boss1 		=	{	[1] = {{1,20},{9,28},{10, 54},{100,288}},--低抗
						[2] = {{1,20},{9,28},{10,105},{100,420}},--中抗
						[3] = {{1,20},{9,28},{10,160},{100,565}},--高抗
				},
	--逍遥谷用怪物抗性
	--普通强度怪
	--练级怪intensity0,fellow0-5全部跟随npc,宋金士兵,白虎堂普通npc
	xoyo_normal		=	{
						[1] = {{1,20},{9, 28},{10,120/4},{100,120}},--低抗
						[2] = {{1,20},{9, 28},{10,240/4},{100,240}},--中抗
						[3] = {{1,20},{9, 28},{10,360/4},{100,360}},--高抗
					},
	--高强度怪
	--intensity1-intensity5,宋金校尉,统领,副将和大将,
	xoyo_special	=	{
						[1] = {{1,20},{9,28},{10,240/4},{100,240}},--低抗
						[2] = {{1,20},{9,28},{10,360/4},{100,360}},--中抗
						[3] = {{1,20},{9,28},{10,480/4},{100,480}},--高抗
				},
	--boss级怪
	--intensity6-intensity8,宋金元帅,白虎堂boss,世界boss1
	xoyo_boss1 		=	{
						[1] = {{1,20},{9,28},{10,360/4},{100,360}},--低抗
						[2] = {{1,20},{9,28},{10,480/4},{100,480}},--中抗
						[3] = {{1,20},{9,28},{10,600/4},{100,600}},--高抗
				},
--区域争夺战
--+8套
	dispute8	= {		--全身+8的玩家抗性表
						[1] = {{1,20},{9,28},{85,115},{95,133},{105,150},{115,150}},--低抗
						[2] = {{1,20},{9,28},{85,215},{95,233},{105,250},{115,250}},--中抗
						[3] = {{1,20},{9,28},{85,315},{95,333},{105,350},{115,350}},--高抗
						},
--+10套
	dispute10	= {		--全身+8的玩家抗性表
						[1] = {{1,20},{9,28},{85,138},{95,152},{105,165},{115,165}},--低抗
						[2] = {{1,20},{9,28},{85,238},{95,252},{105,265},{115,265}},--中抗
						[3] = {{1,20},{9,28},{85,338},{95,352},{105,365},{115,365}},--高抗
						},
--+12套
	dispute12	= {		--全身+8的玩家抗性表
						[1] = {{1,20},{9,28},{85,156},{95,171},{105,180},{115,180}},--低抗
						[2] = {{1,20},{9,28},{85,256},{95,271},{105,280},{115,280}},--中抗
						[3] = {{1,20},{9,28},{85,356},{95,371},{105,380},{115,380}},--高抗
						},
--+14套
	dispute14	= {		--全身+14的玩家抗性表
						[1] = {{1,20},{9,28},{85,185},{95,200},{105,210},{115,210}},--低抗
						[2] = {{1,20},{9,28},{85,285},{95,300},{105,310},{115,310}},--中抗
						[3] = {{1,20},{9,28},{85,485},{95,500},{105,510},{115,510}},--高抗
						},
--秦始皇陵,小兵抗性
	bmy	= {		--全身+14的玩家抗性表
						[1] = {{1,   1},{9,   1}},--低抗
						[2] = {{1, 375},{9, 375}},--中抗
						[3] = {{1,1500},{9,1500}},--高抗
						},
};

--攻击力表
Npc.tbDamage = {
	--pp级怪,未使用
	pp 			=	{	[1] = {	{1, 1},{9,10},{10,20},{60,260},{100,420} },	--正常攻击
						[2] = { {1, 1},{9, 5},{10,10},{60,130},{100,210} },	--毒伤害
					},
	--练级怪intensity0~1,跟随怪fellow0-2
	intensity0		=	{	[1] = { {1, 1},{9,10},{10,20},{30,45},{60,120},{100,230} },	--正常攻击
							[2] = { {1, 1},{9, 5},{10,10},{30,20},{60, 60},{100,115} }, --毒伤害
						},
	--特殊怪intensity2~5,宋金士兵,白虎堂普通Npc
	intensity1		=	{	[1] = { {1, 1},{9,10},{10,25},{30,62},{60,180},{100,345} },	--正常攻击
							[2] = { {1, 1},{9, 5},{10,12},{30,30},{60, 90},{100,170} },	--毒伤害
						},
	--特殊怪intensity6~8,宋金校尉,统领,副将
	intensity2 	=	{	[1] = { {1, 1},{9,10},{10,35},{30,75},{60,240},{100,460} },	--正常攻击
						[2] = { {1, 1},{9, 5},{10,16},{30,35},{60,120},{100,230} }, --毒伤害
					},
	--宋金大将,白虎堂boss,藏宝图小怪
	intensity3 	=	{	[1] = { {1,10},{9,25},{10,51},{60,350},{100,575} },	--正常攻击
						[2] = { {1, 5},{9,12},{10,26},{60,170},{100,290} },	--毒伤害
					},
	--宋金元帅
	intensity4 	=	{	[1] = { {1,10},{9,25},{10,54},{60,420},{100,690} },	--正常攻击
						[2] = { {1, 5},{9,18},{10,27},{60,210},{100,345} },	--毒伤害
					},
	--
	intensity5 	=	{	[1] = { {1,10},{9,25},{10,76},{60,490},{100,800} },	--正常攻击
						[2] = { {1, 5},{9,17},{10,38},{60,245},{100,400} },	--毒伤害
					},
	--藏宝图boss
	intensity6 	=	{	[1] = { {1,10},{9,25},{10,78},{60,560},{100,920} },	--正常攻击
						[2] = { {1, 5},{9,13},{10,39},{60,280},{100,460} },	--毒伤害
					},
	--特殊怪fellow3,4,5
	fellow3	 	=	{	[1] = { {1,80},{9,182},{10,487},{60,2084},{100,3360} },	--正常攻击
						[2] = { {1,40},{9, 91},{10,243},{60,1042},{100,1680} },	--毒伤害
					},
	--世界boss1
	boss1		 	=	{	[1] = { {1,10},{55,107},{75,1},{95,1750},{100,1} },	--正常攻击
							[2] = { {1, 5},{55, 53},{75,1},{95,1000},{100,1} },	--毒伤害
						},
	--新宋金元帅,大将攻击,120级等于boss1
	battle6_new		 	=	{	[1] = { {1,1750},{95,1750} },	--正常攻击
								[2] = { {1,1000},{95,1000} },	--毒伤害
							},
	--藏宝图boss1
	cangbaotuboss1	=	{	[1] = { {1,15},{9,40},{10,110},{60,580},{100,800} },	--正常攻击
							[2] = { {1, 7},{9,20},{10, 55},{60,290},{100,400} },	--毒伤害
						},
	--家族副本_心魔
	xinmo			=	{	[1] = { {1, 1},{9,10},{10,20},{30,45},{60,180},{100,345} },	--正常攻击
							[2] = { {1, 1},{9, 5},{10,10},{30,20},{60, 90},{100,170} },	--毒伤害
						},
--区域争夺战
	--全身+8的玩家攻击力表
	dispute8		=	{	[1] = { {1, 1},{9,10},{85,6000},{95,7000},{105,9000},{115,9500} },	--正常攻击
							[2] = { {1, 1},{9, 5},{85,4000},{95,4700},{105,6000},{115,6365} },	--毒伤害
						},
	--全身+10的玩家攻击力表
	dispute10		=	{	[1] = { {1, 1},{9,10},{85,6500},{95,7500},{105,9500},{115,10750} },	--正常攻击
							[2] = { {1, 1},{9, 5},{85,4000},{95,4700},{105,6000},{115, 6365} },	--毒伤害
						},
	--全身+12的玩家攻击力表
	dispute12		=	{	[1] = { {1, 1},{9,10},{85,7000},{95,8000},{105,10000},{115,12000} },	--正常攻击
							[2] = { {1, 1},{9, 5},{85,4690},{95,5360},{105, 6700},{115, 8040} },	--毒伤害
						},
	--全身+14的玩家攻击力表
	dispute14		=	{	[1] = { {1, 1},{9,10},{85,7750},{95,8800},{105,11000},{115,14000} },	--正常攻击
							[2] = { {1, 1},{9, 5},{85,5200},{95,5900},{105, 7370},{115, 9380} },	--毒伤害
						},
	--区域争夺战npc,100级以后攻击提高
	domainatk	=	{	[1] = { {1,80},{9,182},{10,487},{85,2881*1.1},{95,3200*1.2},{105,3520*1.3},{120,3700*1.3} },	--正常攻击
						[2] = { {1,40},{9, 91},{10,243},{85,1440*1.1},{95,1600*1.2},{105,1760*1.3},{120,1850*1.3} },	--毒伤害
					},
---秦始皇陵
	bmy_soldier1=	{	[1] = { {1,1000},{9,1000}},	--正常攻击
						[2] = { {1, 500},{9, 500}},	--毒伤害
					},
	bmy_soldier2=	{	[1] = { {1,1384},{9,1384}},	--正常攻击
						[2] = { {1, 692},{9, 692}},	--毒伤害
					},
	bmy_soldier3=	{	[1] = { {1,1600},{9,1600}},	--正常攻击
						[2] = { {1, 800},{9, 800}},	--毒伤害
					},
	bmy_soldier4=	{	[1] = { {1,2000},{9,2000}},	--正常攻击
						[2] = { {1,1000},{9,1000}},	--毒伤害
					},

	bmy_leader1	=	{	[1] = { {1,1300},{9,1300}},	--正常攻击
						[2] = { {1, 650},{9, 650}},	--毒伤害
					},
	bmy_leader2	=	{	[1] = { {1,1500},{9,1500}},	--正常攻击
						[2] = { {1, 750},{9, 750}},	--毒伤害
					},
	bmy_leader3	=	{	[1] = { {1,2000},{9,2000}},	--正常攻击
						[2] = { {1,1000},{9,1000}},	--毒伤害
					},
	bmy_leader4	=	{	[1] = { {1,2200},{9,2200}},	--正常攻击
						[2] = { {1,1100},{9,1100}},	--毒伤害
					},

	bmy_elite1	=	{	[1] = { {1,1600},{9,1600}},	--正常攻击
						[2] = { {1, 800},{9, 800}},	--毒伤害
					},
	bmy_elite2	=	{	[1] = { {1,1600},{9,1600}},	--正常攻击
						[2] = { {1, 800},{9, 800}},	--毒伤害
					},
	bmy_elite3	=	{	[1] = { {1,2400},{9,2400}},	--正常攻击
						[2] = { {1,1200},{9,1200}},	--毒伤害
					},
	bmy_elite4	=	{	[1] = { {1,2800},{9,2800}},	--正常攻击
						[2] = { {1,1400},{9,1400}},	--毒伤害
					},

	bmy_fellow1=	{	[1] = { {1,2166},{9,2166}},	--正常攻击
						[2] = { {1,1083},{9,1083}},	--毒伤害
					},
	bmy_fellow2=	{	[1] = { {1,2166},{9,2166}},	--正常攻击
						[2] = { {1,1083},{9,1083}},	--毒伤害
					},
	--xoyo
	xoyo_intensity1		=	{	[1] = { {1, 1},{9,10},{10,25},{30,62},{60,180},{100,345} },	--正常攻击
								[2] = { {1, 1},{9, 5},{10,12},{30,30},{60, 90},{100,170} },	--毒伤害
							},
	xoyo_intensity2 	=	{	[1] = { {1, 1},{9,10},{10,35},{30,75},{60,240},{100,460} },	--正常攻击
								[2] = { {1, 1},{9, 5},{10,16},{30,35},{60,120},{100,230} }, --毒伤害
							},
	--14套,怪物攻击, 	120级时2000攻击力
	BaseAtk_new			=	{	[1] = { {1, 1480},{90,1480},{99,1526},{100,1898},{150,2151}},	--正常攻击
								[2] = { {1,  740},{90, 740},{99, 763},{100, 949},{150,1075}},	--毒伤害
							},			
	BaseAtk_noob		=	{	[1] = { {1, 10},{90,10}},	--正常攻击
								[2] = { {1,  5},{90, 5}},	--毒伤害
							},
	--初级藏宝图攻击力
	basecangbaotu1		=	{	[1]	= { {1,10},{25,70},{50,160},{130,1800}},	--正常攻击
								[2] = { {1, 5},{25,20},{50,80},{130,900}},		--毒伤害
							},									
};


Npc.tbPropBase	= {
	pp	= {
		Exp					= 0,
		Life				= {{1,90},{9,180},{10,250},{20,1150},{60,8480},{100,21880},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750}, },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,3},{30,17*0.4},{31,20*0.4},{60,45*0.4},{61,50*0.4},{80,70*0.4},{81,86*0.4},{91,113*0.6},{100,122*0.4}, },
		MaxDamage			= {{1,3},{30,17*0.6},{31,20*0.6},{60,45*0.6},{61,50*0.6},{80,70*0.6},{81,86*0.6},{91,113*0.6},{100,122*0.6}, },
		PhysicsResist		= GetResist(Npc.tbResist.pp, 1),
		PoisonResist		= GetResist(Npc.tbResist.pp, 2),
		ColdResist			= GetResist(Npc.tbResist.pp, 3),
		FireResist 			= GetResist(Npc.tbResist.pp, 4),
		LightResist			= GetResist(Npc.tbResist.pp, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.pp, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.pp, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.pp, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.pp, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.pp, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.pp, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.pp, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.pp, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.pp, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.pp, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	intensity0_atk20	= {
		Exp					= 1,
		Life				=  GetData(Npc.tbDataTemplet.intensity99_Life, 1),
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750}, },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,3},{100,3},},
		
		tbRisBase			= {SetResistByRis_p,{0.1,0.1,0.1}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.intensity0, 0.2},
		
		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity0	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,250},{20,980},{30,2370},{40,3610},{50,4810},{60,6730},{90,14440},{100,19690},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750}, },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity1	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{100,65800},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity2	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,2400},{30,21200},{60,64000},{100,146200},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity3	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,3400},{30,30300},{60,82000},{100,246100},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity4	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,6100},{30,53800},{60,159900},{100,365500},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity5	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,9100},{60,213200},{100,487400},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity6	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,13700},{60,319800},{100,731100},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity7	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,18300},{60,426500},{100,974800},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity8	= {
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,27400},{60,639700},{100,1462200},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity9	= {
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity9_Life),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,5},{11,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity10	= {--任务用bt怪
		Exp					= 0,
		Life				= {{1,90000},{9,180000},{10,274000},{60,6397000},{100,14622000},},
		LifeReplenish		= 999999,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	task9	= {
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity9_Life,1.3),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,5},{11,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	intensity99	= {--练级怪,绝大部分杀怪经验由此强度npc提供
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life				= {{1,90},{9,180},{10,250},{20,980},{30,2370},{40,3610},{50,4810},{60,6730},{90,14440},{100,19690},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750}, {150,750},},
		AR					= {{1,30},{10,70},{100,700},{150,1050},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},{150,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	fellow0	= {		--护送NPC强度类型0：血量小于同等级玩家血量,伤害与同等级地图NPC的伤害相同
		Exp					= 0,
		Life				= {{1,175},{100,3000},},
		LifeReplenish		= {{1,5}, {10,20}, {20,35}, {60,90}, {100,150},	 },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	fellow1	= {		--护送NPC强度类型1：血量与同等级玩家血量接近；伤害与同等级地图NPC伤害接近
		Exp					= 0,
		Life				= {{1,375},{100,6300},},
		LifeReplenish		= {{1,5}, {10,20}, {20,35}, {60,90}, {100,150},	 },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	fellow2	= {		--护送NPC强度类型2：血量为同等级玩家血量3倍；伤害与同等级地图NPC伤害接近
		Exp					= 0,
		Life				= {{1,750},{100,12600},},
		LifeReplenish		= {{1,5}, {10,20}, {20,35}, {60,90}, {100,150},	 },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity0, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity0, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity0, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity0, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity0, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	fellow3	= {		--护送NPC强度类型3：血量为同等级玩家血量3倍；伤害为同等级地图NPC伤害的8倍
		Exp					= 0,
		Life				= {{1,1500},{100,25000},},
		LifeReplenish		= {{1,5}, {10,20}, {20,35}, {60,90}, {100,150},	 },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	fellow4	= {		--血量为强度8的怪的血量,100级时攻击10W
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity8_Life),
		LifeReplenish		= {{1,5}, {10,20}, {20,35}, {60,90}, {100,150},	 },
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 30),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 30),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 30),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 30),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 30),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 30),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 30),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 30),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 30),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 30),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	fellow5	= {
		Exp					= 0,
		Life				= {{1,2500},{100,42000},},
		LifeReplenish		= {{1,5}, {10,20}, {20,35}, {60,90}, {100,150},	 },
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	battle1	= {		--宋金士兵强度
		Exp					= 0,
		Life				= {{1,90},{60,16825},{90,36100},{100,49225},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	battle2	= {		--宋金校尉强度
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.battle2_Life, 1.5),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	battle3	= {		--宋金统领强度
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.battle3_Life, 1.5),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	battle4	= {		--宋金副将强度
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.battle4_Life, 1.5),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity2, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity2, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity2, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity2, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	battle5	= {		--宋金大将强度
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.battle5_Life, 1.2),
		LifeReplenish		= {{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	battle6	= {		--宋金元帅强度
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.battle6_Life, 1.2),
		LifeReplenish		= {{1,25}, {10,75}, {20,300}, {60,1500}, {90,3000}, {100,4000}, },
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	guidon	= {		--宋金旗手
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.dispute14_Life, 1),
		LifeReplenish		= 0,
		AR					= {{1,30},{100,3000},},
		Defense				= {{1,10},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.dispute14, 1),
		PoisonResist		= GetResist(Npc.tbResist.dispute14, 2),
		ColdResist			= GetResist(Npc.tbResist.dispute14, 3),
		FireResist 			= GetResist(Npc.tbResist.dispute14, 4),
		LightResist			= GetResist(Npc.tbResist.dispute14, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.dispute14, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.dispute14, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.dispute14, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.dispute14, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.dispute14, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.dispute14, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.dispute14, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.dispute14, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.dispute14, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.dispute14, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--新宋金大将强度
	battle5_new	= {		--宋金大将强度
		Exp					= 0,
		Life				= 18256500,
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.battle6_new, 3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.battle6_new, 3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.battle6_new, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.battle6_new, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.battle6_new, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.battle6_new, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.battle6_new, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.battle6_new, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.battle6_new, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.battle6_new, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	battle6_new	= {		--宋金元帅强度
		Exp					= 0,
		Life				= 18256500*3,
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.battle6_new, 1, 2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.battle6_new, 2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.battle6_new, 3, 2),
		FireDamageBase		= GetAtack(Npc.tbDamage.battle6_new, 4, 2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.battle6_new, 5, 2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.battle6_new, 1, 2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.battle6_new, 2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.battle6_new, 3, 2),
		FireMagicBase		= GetAtack(Npc.tbDamage.battle6_new, 4, 2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.battle6_new, 5, 2),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	newbattletransform	= {		--新宋金变身
		Exp					= 0,
		Life				= 19999,
		LifeReplenish		= 0,
		AR					= 8888,
		Defense				= 1999,
		MinDamage			= 1,
		MaxDamage			= 1,
		PhysicsResist		= 1500,
		PoisonResist		= 1500,
		ColdResist			= 1500,
		FireResist 			= 1500,
		LightResist			= 1500,

		PhysicalDamageBase	= 30000/5,
		PoisonDamageBase	= 30000/10,
		ColdDamageBase		= 30000/5,
		FireDamageBase		= 30000/5,
		LightingDamageBase	= 30000/5,

		PhysicalMagicBase	= 30000/5,
		PoisonMagicBase		= 30000/10,
		ColdMagicBase		= 30000/5,
		FireMagicBase		= 30000/5,
		LightingMagicBase	= 30000/5,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	spbattle_guard1	= {		--营地护卫
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*30*0.6),
		LifeReplenish		= 0,--{{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= 5000,
		Defense				= 2000,
		MinDamage			= 1,
		MaxDamage			= 1,
		tbRisBase 			= {SetResistByRis_p, {0.3, 0.4, 0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new,1.0*.3},--120级2000*1.5攻击,打人1500一下

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
		PasstSkillId1		= 1411,
		PasstSkillLevel1	= 1,
		PasstSkillId2		= 1407,
		PasstSkillLevel2	= 11,
	},
	spbattle_guard2	= {		--元帅护卫
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*30*0.6),
		LifeReplenish		= 0,--{{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= 5000,
		Defense				= 2000,
		MinDamage			= 1,
		MaxDamage			= 1,
		tbRisBase 			= {SetResistByRis_p, {0.3, 0.4, 0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new,0.8},--120级2000*2.5攻击,打人2500一下

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
		PasstSkillId1		= 1411,
		PasstSkillLevel1	= 1,
		PasstSkillId2		= 1407,
		PasstSkillLevel2	= 11,
	},
	spbattle_guard3	= {		--平台护卫骁勇战将
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*90*0.6),
		LifeReplenish		= 0,--{{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= 5000,
		Defense				= 2000,
		MinDamage			= 1,
		MaxDamage			= 1,
		tbRisBase 			= {SetResistByRis_p, {0.3, 0.4, 0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new,0.8},--120级2000*1.5攻击,打人1500一下

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
		PasstSkillId1		= 1411,
		PasstSkillLevel1	= 1,
		PasstSkillId2		= 1407,
		PasstSkillLevel2	= 11,
	},
	leftgeneral	= {		--左将军
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*3*60*0.6),
		LifeReplenish		= 0,--{{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= 5000,
		Defense				= 2000,
		MinDamage			= 1,
		MaxDamage			= 1,
		tbRisBase 			= {SetResistByRis_p, {0.3, 0.4, 0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new,1},--120级2000*1.0攻击,打人1000一下

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1243,
		PasstSkillLevel		= 10,
		PasstSkillId1		= 1411,
		PasstSkillLevel1	= 1,
		PasstSkillId2		= 1407,
		PasstSkillLevel2	= 11,
	},
	rightgeneral	= {		--右将军
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*3*60*0.6),
		LifeReplenish		= 0,--{{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= 5000,
		Defense				= 2000,
		MinDamage			= 1,
		MaxDamage			= 1,
		tbRisBase 			= {SetResistByRis_p, {0.3, 0.4, 0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new,1},--120级2000*1.5攻击,打人1500一下

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1257,
		PasstSkillLevel		= 10,
		PasstSkillId1		= 1411,
		PasstSkillLevel1	= 1,
		PasstSkillId2		= 1407,
		PasstSkillLevel2	= 11,
	},
	marshal	= {		--元帅
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 20*6*60*0.4),
		LifeReplenish		= 0,--{{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= 5000,
		Defense				= 2000,
		MinDamage			= 1,
		MaxDamage			= 1,
		tbRisBase 			= {SetResistByRis_p, {0.6, 0.6, 0.6}},
		tbAtkBase			= 2000,--120级2000攻击,打人1000一下

		AuraSkillId			= 1634,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
		PasstSkillId1		= 1411,
		PasstSkillLevel1	= 1,
		PasstSkillId2		= 1407,
		PasstSkillLevel2	= 11,
	},
	marshal2	= {		--元帅
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 20*6*60*0.6),
		LifeReplenish		= 0,--{{1,25}, {10,75}, {20,300}, {60,600}, {90,1200}, {100,1600}, },
		AR					= 5000,
		Defense				= 2000,
		MinDamage			= 1,
		MaxDamage			= 1,
		tbRisBase 			= {SetResistByRis_p, {0.6, 0.6, 0.6}},
		tbAtkBase			= 2000,--120级2000攻击,打人1000一下

		AuraSkillId			= 1634,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2219,--免疫npc无效技能(主要是李代桃僵...)
		PasstSkillLevel		= 10,
		PasstSkillId1		= 1111,--化解伤害
		PasstSkillLevel1	= 10,
		PasstSkillId2		= 1411,
		PasstSkillLevel2	= 1,
		PasstSkillId3		= 1407,
		PasstSkillLevel3	= 11,
	},
	baihutang1	= {	--白虎堂普通NPC
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life				={{1,90},{9,180},{10,250},{20,980},{30,2370},{40,3610},{50,4810},{60,6730},{90,14440},{100,19690},{110,25000},{115,30000},{120,35000}}, 
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1, 1},{100, 1},{110,200},{120,200}},
		MaxDamage			= {{1,10},{100,10},{110,300},{120,300}},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	baihutang2	= {	--白虎堂BOSS
		Exp					= { {  1,     50},{  9,     50},
								{ 10,   3590},{ 19,   3608},
								{ 20,   3990},{ 29,   4008},
								{ 30,   7950},{ 39,   8040},
								{ 40, 100000},{ 49, 100000},
								{ 50, 150000},{ 59, 150000},
								{ 60, 200000},{ 69, 200000},
								{ 70, 250000},{ 79, 250000},
								{ 80, 300000},{ 89, 300000},
								{ 90, 350000},{ 99, 350000},
								{100, 400000},{109, 400000},
								{110, 450000},{119, 450000},
								{120, 500000},{129, 500000},
								{130, 550000},{139, 550000},
								{140, 600000},{150, 600000},
							  },
		Life				= {{1,90},{60,657600},{100,1754400},{110,2500000},{115,3000000},{120,3500000}}, 
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1, 1},{100, 1},{110,250},{120,250}},
		MaxDamage			= {{1,10},{100,10},{110,400},{120,400}},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--第1套家族副本强度
	KinEctype_b1	= {	--家族副本房间b内的npc(地宫门卫)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{100,65800},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_c1	= {	--家族副本房间c内的npc(图腾卫士),无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90},{9,180},{10,2400},{30,21200},{60,64000},{100,146200},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 1963,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_d1	= {	--家族副本房间d内的npc(罗汉铜人)反弹光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{100,65800},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 25,	--反弹光环,20级反弹45%
		AuraSkillLevel		= 7,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_e1	= {	--家族副本房间e内的npc(机关骷髅)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= {{1,90},{9,180},{10,27400},{60,639700},{100,1462200},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_f1	= {	--家族副本房间f内的npc(雷鸣机关兽)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{100,65800},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_g1	= {	--家族副本房间g和j内的npc(天地日月,青龙白虎朱雀玄武守卫和凶神)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{100,65800},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_k1	= {	--家族副本房间k内的npc(影子武士)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{100,65800},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_l1	= {	--家族副本房间l内的npc(飞速机关兽)无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90},{9,180},{10,2400},{30,21200},{60,64000},{100,146200},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 1963,	--无形蛊
		AuraSkillLevel		= 20,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_o1	= {	--家族副本房间o内的npc(冥府冤魂)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= GetData(Npc.tbDataTemplet.mingfuyuanhunLife, 0.85),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5),

		AuraSkillId			= 765,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--第2套家族副本强度
	KinEctype_b2	= {	--家族副本房间b内的npc(地宫门卫)
		Exp					= GetData(Npc.tbDataTemplet.intensity99,1),
		Life    			= {{1,90*1.5},{9,180*1.5},{10,1000*1.5},{19,3800*1.5},{20,3920*1.5},{30,10100*1.5},{60,24700*1.5},{100,65800*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_c2	= {	--家族副本房间c内的npc(图腾卫士),无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*1.5},{9,180*1.5},{10,2400*1.5},{30,21200*1.5},{60,64000*1.5},{100,146200*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.1),

		AuraSkillId			= 1963,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_d2	= {	--家族副本房间d内的npc(罗汉铜人)反弹光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*1.5},{9,180*1.5},{10,1000*1.5},{19,3800*1.5},{20,3920*1.5},{30,10100*1.5},{60,24700*1.5},{100,65800*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		AuraSkillId			= 25,	--反弹光环,20级反弹45%
		AuraSkillLevel		= 7,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_e2	= {	--家族副本房间e内的npc(机关骷髅)
		Exp					= GetData(Npc.tbDataTemplet.intensity99,30),
		Life				= {{1,90*1.5},{9,180*1.5},{10,27400*1.5},{60,639700*1.5},{100,1462200*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.1),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_f2	= {	--家族副本房间f内的npc(雷鸣机关兽)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*1.5},{9,180*1.5},{10,1000*1.5},{19,3800*1.5},{20,3920*1.5},{30,10100*1.5},{60,24700*1.5},{100,65800*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_g2	= {	--家族副本房间g和j内的npc(天地日月,青龙白虎朱雀玄武守卫和凶神)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*1.5},{9,180*1.5},{10,1000*1.5},{19,3800*1.5},{20,3920*1.5},{30,10100*1.5},{60,24700*1.5},{100,65800*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_k2	= {	--家族副本房间k内的npc(影子武士)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90*1.5},{9,180*1.5},{10,1000*1.5},{19,3800*1.5},{20,3920*1.5},{30,10100*1.5},{60,24700*1.5},{100,65800*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_l2	= {	--家族副本房间l内的npc(飞速机关兽)无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*1.5},{9,180*1.5},{10,2400*1.5},{30,21200*1.5},{60,64000*1.5},{100,146200*1.5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.1),

		AuraSkillId			= 1963,	--无形蛊
		AuraSkillLevel		= 20,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_o2	= {	--家族副本房间o内的npc(冥府冤魂)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= GetData(Npc.tbDataTemplet.mingfuyuanhunLife, 1.275),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.1),

		AuraSkillId			= 765,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--第3套家族副本强度
	KinEctype_b3	= {	--家族副本房间b内的npc(地宫门卫)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90*3},{9,180*3},{10,1000*3},{19,3800*3},{20,3920*3},{30,10100*3},{60,24700*3},{100,65800*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_c3	= {	--家族副本房间c内的npc(图腾卫士),无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*3},{9,180*3},{10,2400*3},{30,21200*3},{60,64000*3},{100,146200*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.2),

		AuraSkillId			= 1963,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_d3	= {	--家族副本房间d内的npc(罗汉铜人)反弹光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*3},{9,180*3},{10,1000*3},{19,3800*3},{20,3920*3},{30,10100*3},{60,24700*3},{100,65800*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		AuraSkillId			= 25,	--反弹光环,20级反弹45%
		AuraSkillLevel		= 7,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_e3	= {	--家族副本房间e内的npc(机关骷髅)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= {{1,90*3},{9,180*3},{10,27400*3},{60,639700*3},{100,1462200*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.2),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_f3	= {	--家族副本房间f内的npc(雷鸣机关兽)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*3},{9,180*3},{10,1000*3},{19,3800*3},{20,3920*3},{30,10100*3},{60,24700*3},{100,65800*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_g3	= {	--家族副本房间g和j内的npc(天地日月,青龙白虎朱雀玄武守卫和凶神)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*3},{9,180*3},{10,1000*3},{19,3800*3},{20,3920*3},{30,10100*3},{60,24700*3},{100,65800*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_k3	= {	--家族副本房间k内的npc(影子武士)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90*3},{9,180*3},{10,1000*3},{19,3800*3},{20,3920*3},{30,10100*3},{60,24700*3},{100,65800*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_l3	= {	--家族副本房间l内的npc(飞速机关兽)无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*3},{9,180*3},{10,2400*3},{30,21200*3},{60,64000*3},{100,146200*3},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.2),

		AuraSkillId			= 1963,	--无形蛊
		AuraSkillLevel		= 20,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_o3	= {	--家族副本房间o内的npc(冥府冤魂)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= GetData(Npc.tbDataTemplet.mingfuyuanhunLife, 2.55),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.2),

		AuraSkillId			= 765,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--第4套家族副本强度
	KinEctype_b4	= {	--家族副本房间b内的npc(地宫门卫)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90*4},{9,180*4},{10,1000*4},{19,3800*4},{20,3920*4},{30,10100*4},{60,24700*4},{100,65800*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_c4	= {	--家族副本房间c内的npc(图腾卫士),无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*4},{9,180*4},{10,2400*4},{30,21200*4},{60,64000*4},{100,146200*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.3),

		AuraSkillId			= 1963,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_d4	= {	--家族副本房间d内的npc(罗汉铜人)反弹光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*4},{9,180*4},{10,1000*4},{19,3800*4},{20,3920*4},{30,10100*4},{60,24700*4},{100,65800*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		AuraSkillId			= 25,	--反弹光环,20级反弹45%
		AuraSkillLevel		= 7,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_e4	= {	--家族副本房间e内的npc(机关骷髅)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= {{1,90*4},{9,180*4},{10,27400*4},{60,639700*4},{100,1462200*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.3),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_f4	= {	--家族副本房间f内的npc(雷鸣机关兽)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*4},{9,180*4},{10,1000*4},{19,3800*4},{20,3920*4},{30,10100*4},{60,24700*4},{100,65800*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_g4	= {	--家族副本房间g和j内的npc(天地日月,青龙白虎朱雀玄武守卫和凶神)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*4},{9,180*4},{10,1000*4},{19,3800*4},{20,3920*4},{30,10100*4},{60,24700*4},{100,65800*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_k4	= {	--家族副本房间k内的npc(影子武士)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90*4},{9,180*4},{10,1000*4},{19,3800*4},{20,3920*4},{30,10100*4},{60,24700*4},{100,65800*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_l4	= {	--家族副本房间l内的npc(飞速机关兽)无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*4},{9,180*4},{10,2400*4},{30,21200*4},{60,64000*4},{100,146200*4},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.3),

		AuraSkillId			= 1963,	--无形蛊
		AuraSkillLevel		= 20,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_o4	= {	--家族副本房间o内的npc(冥府冤魂)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= GetData(Npc.tbDataTemplet.mingfuyuanhunLife, 3.4),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.3),

		AuraSkillId			= 765,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--第5套家族副本强度
	KinEctype_b5	= {	--家族副本房间b内的npc(地宫门卫)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90*5},{9,180*5},{10,1000*5},{19,3800*5},{20,3920*5},{30,10100*5},{60,24700*5},{100,65800*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_c5	= {	--家族副本房间c内的npc(图腾卫士),无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*5},{9,180*5},{10,2400*5},{30,21200*5},{60,64000*5},{100,146200*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1.5),

		AuraSkillId			= 1963,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_d5	= {	--家族副本房间d内的npc(罗汉铜人)反弹光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*5},{9,180*5},{10,1000*5},{19,3800*5},{20,3920*5},{30,10100*5},{60,24700*5},{100,65800*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		AuraSkillId			= 25,	--反弹光环,20级反弹45%
		AuraSkillLevel		= 7,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_e5	= {	--家族副本房间e内的npc(机关骷髅)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= {{1,90*5},{9,180*5},{10,27400*5},{60,639700*5},{100,1462200*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_f5	= {	--家族副本房间f内的npc(雷鸣机关兽)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*5},{9,180*5},{10,1000*5},{19,3800*5},{20,3920*5},{30,10100*5},{60,24700*5},{100,65800*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_g5	= {	--家族副本房间g和j内的npc(天地日月,青龙白虎朱雀玄武守卫和凶神)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life    			= {{1,90*5},{9,180*5},{10,1000*5},{19,3800*5},{20,3920*5},{30,10100*5},{60,24700*5},{100,65800*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_k5	= {	--家族副本房间k内的npc(影子武士)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 1),
		Life    			= {{1,90*5},{9,180*5},{10,1000*5},{19,3800*5},{20,3920*5},{30,10100*5},{60,24700*5},{100,65800*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_l5	= {	--家族副本房间l内的npc(飞速机关兽)无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90*5},{9,180*5},{10,2400*5},{30,21200*5},{60,64000*5},{100,146200*5},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 1.5),

		AuraSkillId			= 1963,	--无形蛊
		AuraSkillLevel		= 20,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_o5	= {	--家族副本房间o内的npc(冥府冤魂)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= GetData(Npc.tbDataTemplet.mingfuyuanhunLife, 4.25),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.5),

		AuraSkillId			= 765,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	KinEctype_m	= {	--家族副本房间m内的npc(复制机关人)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 3),
		Life			    = {{1,90},{9,180},{10,2400},{30,21200},{60,64000},{100,146200},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	KinEctype_p	= {	--家族副本房间p内的npc(心魔)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4),
		Life				= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{40,14970},{50,39680},{60,65867},{70,93267},{80,135750},{90,222100},{100,263200},},
		LifeReplenish		= {{1,5}, {10,10}, {20,65}, {60,250}, {100,750},},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xinmo, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xinmo, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xinmo, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xinmo, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xinmo, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xinmo, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xinmo, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xinmo, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xinmo, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xinmo, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	worldboss1	= {	--世界BOSS
		Exp					= { {  1,     50},{  9,     50},
								{ 10,   4490},{ 19,   4508},
								{ 20,   4990},{ 29,   5008},
								{ 30,   9950},{ 39,  10040},
								{ 40, 150000},{ 49, 150000},
								{ 50, 150000},{ 59, 150000},
								{ 60,   1200},{ 69,   1290},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90, 450000},{ 99, 450000},
								{100,   2800},{109,   3025},
								{110,   3300},{109,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
		Life				= {{1,160*0.9},{55,7125000*0.9},{100,21930000*0.9},},
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	
	intensity999	= {	--Du Long Giac
		Exp					= { {  1,     50},{  9,     50},
								{ 10,   4490},{ 19,   4508},
								{ 20,   4990},{ 29,   5008},
								{ 30,   9950},{ 39,  10040},
								{ 40, 150000},{ 49, 150000},
								{ 50, 150000},{ 59, 150000},
								{ 60,   1200},{ 69,   1290},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90, 450000},{ 99, 450000},
								{100,   2800},{109,   3025},
								{110,   3300},{109,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
		Life				= {{1,160*0.9},{55,7125000*0.9},{100,21930000*0.9},},
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),
		
		AuraSkillId			= 3014,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	kinworldboss1	= {	--家族副本世界BOSS
		Exp					= { {  1,     50},{  9,     50},
								{ 10,   4490},{ 19,   4508},
								{ 20,   4990},{ 29,   5008},
								{ 30,   9950},{ 39,  10040},
								{ 40, 150000},{ 49, 150000},
								{ 50, 150000},{ 59, 150000},
								{ 60,   1200},{ 69,   1290},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90,   2300},{ 99,   2480},
								{100,   2800},{109,   3025},
								{110,   3300},{109,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
		Life				= {{1,160*0.9},{55,5500000},{75,9000000},},
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	worldboss1_call	= {	--世界BOSS
		Exp					= { {  1,     50},{  9,     50},
								{ 10,   4490},{ 19,   4508},
								{ 20,   4990},{ 29,   5008},
								{ 30,   9950},{ 39,  10040},
								{ 40, 150000},{ 49, 150000},
								{ 50, 150000},{ 59, 150000},
								{ 60,   1200},{ 69,   1290},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90, 450000},{ 99, 450000},
								{100,   2800},{109,   3025},
								{110,   3300},{109,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
		Life				= {{1,160*0.9*0.7},{55,7125000*0.9*0.7},{100,21930000*0.9*0.7},},
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1, 0.7),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2, 0.7),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3, 0.7),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4, 0.7),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5, 0.7),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1, 0.7),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2, 0.7),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3, 0.7),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4, 0.7),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5, 0.7),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	BossFellow2412	= {	--世界BOSS召唤怪ID2412常用小兵
		Exp					= 0,
		Life				= {{1,45},{9,90},{10,500},{19,1900},{20,1910},{30,5050},{60,12900},{75,50000},{100,32900,}},
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	BossFellow2413	= {	--世界BOSS召唤怪ID2413高攻小兵,低血高回复
		Exp					= 0,
		Life				= {{1,90},{9,180},{10,250},{20,980},{30,2370},{40,3610},{50,4810},{60,6730},{75,10000},{90,14440},{100,19690},},
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 976,
		AuraSkillLevel		= 2,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	BossFellow2414	= {	--世界BOSS召唤怪ID2414诅咒小兵,高血低攻击
		Exp					= 0,
		Life				= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{75,150000},{100,65800},},
		LifeReplenish		= 0,
		AR					= {{1,1000},{55,10000},{75,30000},{95,50000},{100,50000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	BossFellow2415	= {	--世界BOSS召唤怪ID2415无形蛊小兵,高血
		Exp					= 0,
		Life				= {{1,90},{9,180},{10,1000},{19,3800},{20,3920},{30,10100},{60,24700},{75,250000},{100,65800},},
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,1},{55,1},{75,1},{95,1},{100,1},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 652,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	BossFellow2416	= {	--世界BOSS召唤怪ID2416群攻小兵
		Exp					= 0,
		Life				= {{1,45},{9,90},{10,500},{19,1900},{20,1910},{30,5050},{60,12900},{75,100000},{100,32900},},
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	BossFellow2417	= {	--世界BOSS召唤怪ID2417,自我复制小兵
		Exp					= 0,
		Life				= {{1,90},{9,180},{10,250},{20,980},{30,2370},{40,3610},{50,4810},{60,6730},{75,100000},{90,14440},{100,19690},},
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	BossFellow2418	= {	--世界BOSS召唤怪ID2418弱弹幕小兵
		Exp					= 0,
		Life				= {{1,45},{9,90},{10,500},{19,1900},{20,1910},{30,5050},{60,12900},{75,150000},{100,32900},},
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	BossFellow2419	= {	--世界BOSS召唤怪ID2419强弹幕小兵
		Exp					= 0,
		Life				= {{1,45},{9,90},{10,500},{19,1900},{20,1910},{30,5050},{60,12900},{75,200000},{100,32900},},
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.boss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.boss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.boss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.boss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.boss1, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
---------------------------秦始皇陵-----------------------------------
	worldboss3	= {	--120级世界boss秦始皇
		Exp					= 900000,
		Life				= 20596680,--{{1,160*0.9},{55,7125000*0.9},{100,21930000*0.9},},
		LifeReplenish		= 0,
		AR					= 667,
		Defense				= 1500,
		MinDamage			= 1,
		MaxDamage			= 2166,--1000,
		PhysicsResist		= 800,
		PoisonResist		= 800,
		ColdResist			= 800,
		FireResist 			= 800,
		LightResist			= 800,

		PhysicalDamageBase	= 2166/5,--700,
		PoisonDamageBase	= 2166/10,--700,
		ColdDamageBase		= 2166/5,--700,
		FireDamageBase		= 2166/5,--700,
		LightingDamageBase	= 2166/5,--700,

		PhysicalMagicBase	= 2166/5,--700,
		PoisonMagicBase		= 2166/10,--700,
		ColdMagicBase		= 2166/5,--700,
		FireMagicBase		= 2166/5,--700,
		LightingMagicBase	= 2166/5,--700,

		AuraSkillId			= 1410,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1407,--提高500%命中,并无视抗性
		PasstSkillLevel		= 11,
	},

	bmy_soldier1	= {	--秦始皇陵1层士兵
		Exp					= 20000,
		Life				= 845440,
		LifeReplenish		= 70000,
		AR					= 3000,
		Defense				= 1000,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.bmy,1),
		PoisonResist		= GetResist(Npc.tbResist.bmy,2),
		ColdResist			= GetResist(Npc.tbResist.bmy,3),
		FireResist 			= GetResist(Npc.tbResist.bmy,4),
		LightResist			= GetResist(Npc.tbResist.bmy,5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier1, 1, 0.8),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier1, 2, 0.8),
		ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier1, 3, 0.8),
		FireDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier1, 4, 0.8),
		LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier1, 5, 0.8),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier1, 1, 0.8),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier1, 2, 0.8),
		ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier1, 3, 0.8),
		FireMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier1, 4, 0.8),
		LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier1, 5, 0.8),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	bmy_leader1	= {	--秦始皇陵1层头领
		Exp					= 45000,
		Life				= 845440,
		LifeReplenish		= 70000,
		AR					= 3000,
		Defense				= 1000,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.bmy,1),
		PoisonResist		= GetResist(Npc.tbResist.bmy,2),
		ColdResist			= GetResist(Npc.tbResist.bmy,3),
		FireResist 			= GetResist(Npc.tbResist.bmy,4),
		LightResist			= GetResist(Npc.tbResist.bmy,5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_leader1, 1, 0.8),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.bmy_leader1, 2, 0.8),
		ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_leader1, 3, 0.8),
		FireDamageBase		= GetAtack(Npc.tbDamage.bmy_leader1, 4, 0.8),
		LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_leader1, 5, 0.8),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_leader1, 1, 0.8),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_leader1, 2, 0.8),
		ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_leader1, 3, 0.8),
		FireMagicBase		= GetAtack(Npc.tbDamage.bmy_leader1, 4, 0.8),
		LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_leader1, 5, 0.8),

		AuraSkillId			= 594,--GetSeriesData({1091,1091,1007,1133,1362,1133}),
		AuraSkillLevel		= 1,--GetSeriesData({   2,   2,   2,   3,   2,  20}),
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	bmy_elite1	= {	--秦始皇陵1层精英
		Exp					= 45000*1.25,
		Life				= 1710362,
		LifeReplenish		= 70000,
		AR					= 3000,
		Defense				= 1000,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.bmy,1),
		PoisonResist		= GetResist(Npc.tbResist.bmy,2),
		ColdResist			= GetResist(Npc.tbResist.bmy,3),
		FireResist 			= GetResist(Npc.tbResist.bmy,4),
		LightResist			= GetResist(Npc.tbResist.bmy,5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_elite1, 1, 0.8),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.bmy_elite1, 2, 0.8),
		ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_elite1, 3, 0.8),
		FireDamageBase		= GetAtack(Npc.tbDamage.bmy_elite1, 4, 0.8),
		LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_elite1, 5, 0.8),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_elite1, 1, 0.8),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_elite1, 2, 0.8),
		ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_elite1, 3, 0.8),
		FireMagicBase		= GetAtack(Npc.tbDamage.bmy_elite1, 4, 0.8),
		LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_elite1, 5, 0.8),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	smallboss	= {	--秦始皇陵小boss
		Exp					= 600000,
		Life				= {{1,160*0.45},{55,7125000*0.45},{100,21930000*0.45},},
		LifeReplenish		= 70000,
		AR					= 667,
		Defense				= 1500,
		MinDamage			= 1,
		MaxDamage			= 500,
		PhysicsResist		= 300,
		PoisonResist		= 300,
		ColdResist			= 300,
		FireResist 			= 300,
		LightResist			= 300,

		PhysicalDamageBase	= 700,
		PoisonDamageBase	= 700,
		ColdDamageBase		= 700,
		FireDamageBase		= 700,
		LightingDamageBase	= 700,

		PhysicalMagicBase	= 700,
		PoisonMagicBase		= 700,
		ColdMagicBase		= 700,
		FireMagicBase		= 700,
		LightingMagicBase	= 700,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1407,--提高500%命中
		PasstSkillLevel		= 10,
	},

---------------------------------------------------------------
	cangbaotunormal1	= {  --藏宝图小怪
		Exp					= { {  1,    50},{  9,    50},
								{ 10,   290},{ 19,   308},
								{ 20,   390},{ 29,   408},
								{ 30,  2000},{ 39,  2000},
								{ 40,  4000},{ 49,  4000},
								{ 50,  5000},{ 59,  5000},
								{ 60,  6000},{ 69,  6000},
								{ 70, 12000},{ 79, 12000},
								{ 80,  2000},{ 89,  2090},
								{ 90,  2300},{ 99,  2480},
								{100,  2800},{109,  3025},
								{110,  3300},{109,  3525},
								{120,  3900},{129,  4170},
								{130,  4500},{139,  4950},
								{140,  5200},{150,  5500},
							  },
		Life				= {{1,90},{9,180},{10,3400},{30,30300},{60,82000},{65,159900},{75,205600},{100,365500},},
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss1	= {
		Exp					= { {  1,     50},{  9,     50},
								{ 10,   2690},{ 19,   2708},
								{ 20,   2990},{ 29,   3008},
								{ 30,   5950},{ 39,   6040},
								{ 40,  75000},{ 49,  75000},
								{ 50,  75000},{ 59,  75000},
								{ 60, 150000},{ 69, 150000},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90,   2300},{ 99,   2480},
								{100,   2800},{109,   3025},
								{110,   3300},{109,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
		Life				= {{1,90*0.9},{9,180*0.9},{10,27400*0.9},{45,438600*0.9},{55,570240*0.9},{65,1151460*0.9},{75,1480500*0.9},{100,2631960*0.9},},
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity6, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity6, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity6, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity6, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity6, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity6, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity6, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity6, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity6, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity6, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss2	= {
		Exp					= { {  1,     50},{  9,     50},
								{ 10,   2690},{ 19,   2708},
								{ 20,   2990},{ 29,   3008},
								{ 30,   5950},{ 39,   6040},
								{ 40,  65000},{ 49,  65000},
								{ 50,  65000},{ 59,  65000},
								{ 60, 150000},{ 69, 150000},
								{ 70, 300000},{ 79, 300000},
								{ 80,   2000},{ 89,   2090},
								{ 90,   2300},{ 99,   2480},
								{100,   2800},{109,   3025},
								{110,   3300},{109,   3525},
								{120,   3900},{129,   4170},
								{130,   4500},{139,   4950},
								{140,   5200},{150,   5500},
							  },
		Life				= {{1,90*0.9},{9,180*0.9},{10,27400*0.9},{45,438600*0.9},{55,570240*0.9},{65,1151460*0.9},{75,1480500*0.9},{100,2631960*0.9},},
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotuboss3	= {
		Exp					= GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 164*Npc.IVER_CangBaoTuNpcStrong),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss4	= {
		Exp					= GetData(Npc.tbDataTemplet.cangbaotuboss2_Exp),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 164*Npc.IVER_CangBaoTuNpcStrong),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss2740	= {--带无形蛊光环
		Exp					= GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 164*Npc.IVER_CangBaoTuNpcStrong),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 1007,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotuboss2736	= {--图腾柱带回复光环,5个人10秒围杀
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 12*Npc.IVER_CangBaoTuNpcStrong),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 1,
		PoisonDamageBase	= 1,
		ColdDamageBase		= 1,
		FireDamageBase		= 1,
		LightingDamageBase	= 1,

		PhysicalMagicBase	= 1,
		PoisonMagicBase		= 1,
		ColdMagicBase		= 1,
		FireMagicBase		= 1,
		LightingMagicBase	= 1,

		AuraSkillId			= 1018,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotunormalEX	= {  --藏宝图精英级怪
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 20),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 80*Npc.IVER_CangBaoTuNpcStrong),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2, 1*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1, 1*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2, 1*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3, 1*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4, 1*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5, 1*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotuboss2760	= {
		Exp					= GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp),
		Life				= 3200000*Npc.IVER_CangBaoTuNpcStrong,
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotunormal2759	= {  --铁莫西
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 20),
		Life				= 1000000*Npc.IVER_CangBaoTuNpcStrong,
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.35*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.35*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.35*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotunormal2775	= {  --蛮族战士
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 10),
		Life				= 500000*Npc.IVER_CangBaoTuNpcStrong,
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.25*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.25*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotunormal2782	= {  --蛮族医师
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 7),
		Life				= 350000*Npc.IVER_CangBaoTuNpcStrong,
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.3*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.3*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.3*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotunormal2776	= {  --黑熊
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 6),
		Life				= 300000*Npc.IVER_CangBaoTuNpcStrong,
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.25*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.25*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.25*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotunormal2778	= {  --花豹
		Exp					= 90000,
		Life				= 3000000,
		LifeReplenish		= 0,
		AR					= {{1,100},{100,3000},},
		Defense				= {{1,10},{10,100},{11,110},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 100),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 100),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 100),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 100),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 100),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 100),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 100),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 100),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 100),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 100),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotufellow2761	= {  --陶子
		Exp					= 0,
		Life				= 300000,
		LifeReplenish		= 0,
		AR					= {{1,100},{100,3000},},
		Defense				= 1,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 0,
		PoisonResist		= 0,
		ColdResist			= 0,
		FireResist 			= 0,
		LightResist			= 0,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.3),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.3),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.3),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotufellow2764	= {  --青青
		Exp					= 0,
		Life				= 500000,
		LifeReplenish		= 0,
		AR					= {{1,100},{100,3000},},
		Defense				= 1,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 0,
		PoisonResist		= 0,
		ColdResist			= 0,
		FireResist 			= 0,
		LightResist			= 0,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
-------------------------藏宝图改版---------------------------
	cangbaotunormal_01	= {  --百年天牢藏宝图小怪
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 3),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 13),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss1_01	= {  --百年天牢藏宝图boss1
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 23.5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 94),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity6, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity6, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity6, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity6, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity6, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity6, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity6, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity6, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity6, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity6, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss2_01	= {  --百年天牢藏宝图boss2
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 23.5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 94),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotunormal_02	= {  --陶朱公墓藏宝图小怪
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 20),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss1_02	= {  --陶朱公墓藏宝图boss1
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 32.5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 130),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity6, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity6, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity6, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity6, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity6, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity6, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity6, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity6, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity6, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity6, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss2_02	= {  --陶朱公墓藏宝图boss2
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 32.5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 130),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotunormal_03	= {  --古城之谜藏宝图小怪
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 4.75),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life,19),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss2_03	= {  --古城之谜藏宝图boss2
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 31.5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 126),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	cangbaotunormal_04	= {  --千琼宫藏宝图小怪
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 20),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss3_04	= {  --千琼宫藏宝图boss3
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 41),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 164*Npc.IVER_CangBaoTuNpcStrong),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotuboss4_04	= {  --千琼宫藏宝图boss4
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 82),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 164*Npc.IVER_CangBaoTuNpcStrong),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1, 2*Npc.IVER_CangBaoTuNpcStrong),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2, 2*Npc.IVER_CangBaoTuNpcStrong),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3, 2*Npc.IVER_CangBaoTuNpcStrong),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4, 2*Npc.IVER_CangBaoTuNpcStrong),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5, 2*Npc.IVER_CangBaoTuNpcStrong),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotu_lmfj_normal1	= { -- 藏宝图-龙门飞剑 小怪1
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 2.5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 15),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotu_lmfj_normal2	= { -- 藏宝图-龙门飞剑 小怪2
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 5),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 20),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotu_lmfj_boss1	= { -- 藏宝图-龙门飞剑 Boss1
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 40),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 160),
		LifeReplenish		=  {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotu_lmfj_boss2	= { -- 藏宝图-龙门飞剑 Boss2
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 80),
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 180),
		LifeReplenish		=  {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.cangbaotuboss1, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.cangbaotuboss1, 5),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cangbaotu_lmfj_dancer	= { -- 藏宝图-龙门飞剑 舞娘 autoskill
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 2),
		LifeReplenish		=  0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 2436,
		PasstSkillLevel		= 2,
	},
	cangbaotu_lmfj_trap = { -- 藏宝图-龙门飞剑 机关
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 10),
		LifeReplenish		=  0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity3, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity3, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity3, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity3, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 1475,
		PasstSkillLevel		= 10,
	},
	
	muren	= {
		Exp					= 0,
		Life				= {{1,100},{10,1000},{20,3000},{30,5000},{40,10000},{50,30000},{60,50000},{70,100000},},
		LifeReplenish		= 0,
		AR					= 0,
		Defense				= 0,
		MinDamage			= 1,
		MaxDamage			= 2,
		PhysicsResist		= 0,
		PoisonResist		= 0,
		ColdResist			= 0,
		FireResist 			= 0,
		LightResist			= 0,

		PhysicalDamageBase	= 1,
		PoisonDamageBase	= 1,
		ColdDamageBase		= 1,
		FireDamageBase		= 1,
		LightingDamageBase	= 1,

		PhysicalMagicBase	= 1,
		PoisonMagicBase		= 1,
		ColdMagicBase		= 1,
		FireMagicBase		= 1,
		LightingMagicBase	= 1,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	
	xisuidaomuren	= {
		Exp					= 0,
		Life				= {{1,100},{10,1000},{20,3000},{30,5000},{40,10000},{50,30000},{60,50000},{70,100000},{90,20000000}},
		LifeReplenish		= 0,
		AR					= 0,
		Defense				= 0,
		MinDamage			= 1,
		MaxDamage			= 2,
		PhysicsResist		= 0,
		PoisonResist		= 0,
		ColdResist			= 0,
		FireResist 			= 0,
		LightResist			= 0,

		PhysicalDamageBase	= 1,
		PoisonDamageBase	= 1,
		ColdDamageBase		= 1,
		FireDamageBase		= 1,
		LightingDamageBase	= 1,

		PhysicalMagicBase	= 1,
		PoisonMagicBase		= 1,
		ColdMagicBase		= 1,
		FireMagicBase		= 1,
		LightingMagicBase	= 1,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	
	wanted		= {		--通缉任务
		Exp					= {{1,100},{10,1000},{20,3000},{30,5000},{40,10000},{55,1},{65,1},{75,1},{85,1},{95,1}},
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 140),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{100,3000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity5, 1, 2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity5, 2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity5, 3, 2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity5, 4, 2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity5, 5, 2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity5, 1, 2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity5, 2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity5, 3, 2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity5, 4, 2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity5, 5, 2),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
wanted2		= {		--高级通缉任务
		Exp					= 0,
		Life				= 14176800,
		LifeReplenish		= 30000,
		AR					= 3000,
		Defense				= 300,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 2000/0.6/5,
		PoisonDamageBase	= 2000/0.6/5/2,
		ColdDamageBase		= 2000/0.6/5,
		FireDamageBase		= 2000/0.6/5,
		LightingDamageBase	= 2000/0.6/5,

		PhysicalMagicBase	= 2000/0.6/5,
		PoisonMagicBase		= 2000/0.6/5/2,
		ColdMagicBase		= 2000/0.6/5,
		FireMagicBase		= 2000/0.6/5,
		LightingMagicBase	= 2000/0.6/5,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
zhaohuanboss1  	= {		--大盗召唤boss
		Exp					= 10000,
		Life				= 2362800,
		LifeReplenish		= 5000,
		AR					= 3000,
		Defense				= 300,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 500/0.6/5,
		PoisonDamageBase	= 500/0.6/5/2,
		ColdDamageBase		= 500/0.6/5,
		FireDamageBase		= 500/0.6/5,
		LightingDamageBase	= 500/0.6/5,

		PhysicalMagicBase	= 500/0.6/5,
		PoisonMagicBase		= 500/0.6/5/2,
		ColdMagicBase		= 500/0.6/5,
		FireMagicBase		= 500/0.6/5,
		LightingMagicBase	= 500/0.6/5,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
zhaohuanboss2  	= {		--大盗召唤boss
		Exp					= 10000*2,
		Life				= 2362800*2,
		LifeReplenish		= 5000*2,
		AR					= 3000,
		Defense				= 300,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 500/0.6/5,
		PoisonDamageBase	= 500/0.6/5/2,
		ColdDamageBase		= 500/0.6/5,
		FireDamageBase		= 500/0.6/5,
		LightingDamageBase	= 500/0.6/5,

		PhysicalMagicBase	= 500/0.6/5,
		PoisonMagicBase		= 500/0.6/5/2,
		ColdMagicBase		= 500/0.6/5,
		FireMagicBase		= 500/0.6/5,
		LightingMagicBase	= 500/0.6/5,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
zhaohuanboss3  	= {		--大盗召唤boss
		Exp					= 10000*3,
		Life				= 2362800*3,
		LifeReplenish		= 5000*3,
		AR					= 3000,
		Defense				= 300,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 500*2/0.6/5,
		PoisonDamageBase	= 500*2/0.6/5/2,
		ColdDamageBase		= 500*2/0.6/5,
		FireDamageBase		= 500*2/0.6/5,
		LightingDamageBase	= 500*2/0.6/5,

		PhysicalMagicBase	= 500*2/0.6/5,
		PoisonMagicBase		= 500*2/0.6/5/2,
		ColdMagicBase		= 500*2/0.6/5,
		FireMagicBase		= 500*2/0.6/5,
		LightingMagicBase	= 500*2/0.6/5,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
zhaohuanboss4  	= {		--大盗召唤boss
		Exp					= 10000*4,
		Life				= 2362800*4,
		LifeReplenish		= 5000*4,
		AR					= 3000,
		Defense				= 300,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 500*3/0.6/5,
		PoisonDamageBase	= 500*3/0.6/5/2,
		ColdDamageBase		= 500*3/0.6/5,
		FireDamageBase		= 500*3/0.6/5,
		LightingDamageBase	= 500*3/0.6/5,

		PhysicalMagicBase	= 500*3/0.6/5,
		PoisonMagicBase		= 500*3/0.6/5/2,
		ColdMagicBase		= 500*3/0.6/5,
		FireMagicBase		= 500*3/0.6/5,
		LightingMagicBase	= 500*3/0.6/5,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
zhaohuanboss5  	= {		--大盗召唤boss
		Exp					= 10000*6,
		Life				= 2362800*6,
		LifeReplenish		= 5000*6,
		AR					= 3000,
		Defense				= 300,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 500*4/0.6/5,
		PoisonDamageBase	= 500*4/0.6/5/2,
		ColdDamageBase		= 500*4/0.6/5,
		FireDamageBase		= 500*4/0.6/5,
		LightingDamageBase	= 500*4/0.6/5,

		PhysicalMagicBase	= 500*4/0.6/5,
		PoisonMagicBase		= 500*4/0.6/5/2,
		ColdMagicBase		= 500*4/0.6/5,
		FireMagicBase		= 500*4/0.6/5,
		LightingMagicBase	= 500*4/0.6/5,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
zhaohuanboss6  	= {		--大盗召唤boss
		Exp					= 10000*10,
		Life				= 2362800*10,
		LifeReplenish		= 5000*10,
		AR					= 3000,
		Defense				= 300,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 500*6/0.6/5,
		PoisonDamageBase	= 500*6/0.6/5/2,
		ColdDamageBase		= 500*6/0.6/5,
		FireDamageBase		= 500*6/0.6/5,
		LightingDamageBase	= 500*6/0.6/5,

		PhysicalMagicBase	= 500*6/0.6/5,
		PoisonMagicBase		= 500*6/0.6/5/2,
		ColdMagicBase		= 500*6/0.6/5,
		FireMagicBase		= 500*6/0.6/5,
		LightingMagicBase	= 500*6/0.6/5,

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	xiakedao_jianzhu		= {		--侠客岛基建筑
		Exp					= 0,
		Life				= 50000,
		LifeReplenish		= {{1,500},{120,500}},
		AR					= {{1,0},{120,0}},
		Defense				= {{1,0},{120,0}},
		MinDamage			= {{1,0},{100,0},},
		MaxDamage			= {{1,0},{100,0},},
		PhysicsResist		= 1500,
		PoisonResist		= 1500,
		ColdResist			= 1500,
		FireResist 			= 0,
		LightResist			= 1500,

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= 0,
		ColdDamageBase		= 0,
		FireDamageBase		= 0,
		LightingDamageBase	= 0,
                              
		PhysicalMagicBase	= 0,
		PoisonMagicBase		= 0,
		ColdMagicBase		= 0,
		FireMagicBase		= 0,
		LightingMagicBase	= 0,


		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},

	xiakedao_home		= {		--侠客岛基地
		Exp					= 0,
		Life				= 200000,
		LifeReplenish		= {{1,1000},{120,1000}},
		AR					= {{1,0},{120,0}},
		Defense				= {{1,0},{120,0}},
		MinDamage			= {{1,0},{100,0},},
		MaxDamage			= {{1,0},{100,0},},
		PhysicsResist		= 1500,
		PoisonResist		= 1500,
		ColdResist			= 1500,
		FireResist 			= 0,
		LightResist			= 1500,

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= 0,
		ColdDamageBase		= 0,
		FireDamageBase		= 0,
		LightingDamageBase	= 0,
                              
		PhysicalMagicBase	= 0,
		PoisonMagicBase		= 0,
		ColdMagicBase		= 0,
		FireMagicBase		= 0,
		LightingMagicBase	= 0,


		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xiakedao_jianta		= {		--侠客岛箭塔
		Exp					= 0,
		Life				= 50000,
		LifeReplenish		= {{1,100},{120,100}},
		AR					= {{1,0},{120,0}},
		Defense				= {{1,0},{120,0}},
		MinDamage			= {{1,0},{100,0},},
		MaxDamage			= {{1,0},{100,0},},
		PhysicsResist		= 1200,
		PoisonResist		= 1200,
		ColdResist			= 1200,
		FireResist 			= 0,
		LightResist			= 1200,

		PhysicalDamageBase	= 2000,
		PoisonDamageBase	= 0,
		ColdDamageBase		= 0,
		FireDamageBase		= 0,
		LightingDamageBase	= 0,
                              
		PhysicalMagicBase	= 2000,
		PoisonMagicBase		= 0,
		ColdMagicBase		= 0,
		FireMagicBase		= 0,
		LightingMagicBase	= 0,


		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 802,
		PasstSkillLevel		= 20,
	},
	xiakedao_jin		= {		--侠客岛傲天
		Exp					= 0,
		Life				= {{1,1},{90,1},{100,4000},{110,8000},{120,16000}},
		LifeReplenish		= {{1,0},{120,0}},
		AR					= {{1,3000},{120,3000}},
		Defense				= {{1,3000},{120,3000}},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= {{1,0},{90,0},{100,500},{110,550},{120,590}},
		PoisonResist		= {{1,0},{90,0},{100,500},{110,550},{120,590}},
		ColdResist			= {{1,0},{90,0},{100,260},{110,280},{120,300}},
		FireResist 			= {{1,0},{90,0},{100,1200},{110,1300},{120,1400}},
		LightResist			= {{1,0},{90,0},{100,500},{110,550},{120,590}},

		PhysicalDamageBase	= {{1,0},{90,0},{100,400},{110,400},{120,800}},
		PoisonDamageBase	= {{1,0},{90,0},{100,200},{110,200},{120,400}},
		ColdDamageBase		= {{1,0},{90,0},{100,200},{110,200},{120,400}},
		FireDamageBase		= 0,
		LightingDamageBase	= {{1,0},{90,0},{100,200},{110,200},{120,400}},

		PhysicalMagicBase	= {{1,0},{90,0},{100,400},{110,800},{120,1600}},
		PoisonMagicBase		= {{1,0},{90,0},{100,200},{110,400},{120,800}},
		ColdMagicBase		= {{1,0},{90,0},{100,200},{110,400},{120,800}},
		FireMagicBase		= 0,
		LightingMagicBase	= {{1,0},{90,0},{100,200},{110,400},{120,800}},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 802,
		PasstSkillLevel		= 16,
	},
	xiakedao_mu		= {		--侠客岛晨曦
		Exp					= 0,
		Life				= {{1,0},{90,0},{100,2500},{110,3500},{120,4500}},
		LifeReplenish		= {{1,0},{120,0}},
		AR					= {{1,3000},{120,3000}},
		Defense				= {{1,3000},{100,1000},{110,1500},{120,2000}},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= {{1,0},{90,0},{100,500},{110,550},{120,590}},
		PoisonResist		= {{1,0},{90,0},{100,850},{110,900},{120,980}},
		ColdResist			= {{1,0},{90,0},{100,160},{110,175},{120,190}},
		FireResist 			= {{1,0},{90,0},{100,500},{110,550},{120,590}},
		LightResist			= {{1,0},{90,0},{100,160},{110,175},{120,190}},

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= {{1,0},{90,0},{100,2000},{110,3500},{120,5000}},
		ColdDamageBase		= 0,
		FireDamageBase		= 0,
		LightingDamageBase	= 0,

		PhysicalMagicBase	= 0,
		PoisonMagicBase		= {{1,0},{90,0},{100,2000},{110,3500},{120,5000}},
		ColdMagicBase		= 0,
		FireMagicBase		= 0,
		LightingMagicBase	= 0,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 802,
		PasstSkillLevel		= 18,  
	},
		xiakedao_shui		= {		--侠客岛皓月
		Exp					= 0,
		Life				= {{1,1},{90,1},{100,3000},{110,4500},{120,6000}},
		LifeReplenish		= {{1,0},{120,0}},
		AR					= {{1,3000},{120,3000}},
		Defense				= {{1,3000},{120,5000}},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= {{1,0},{90,0},{100,400},{110,450},{120,500}},
		PoisonResist		= {{1,0},{90,0},{100,400},{110,450},{120,500}},
		ColdResist			= {{1,0},{90,0},{100,300},{110,450},{120,700}},
		FireResist 			= {{1,0},{90,0},{100,1200},{110,1300},{120,1400}},
		LightResist			= {{1,0},{90,0},{100,160},{110,190},{120,300}},

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= 0,
		ColdDamageBase		= {{1,0},{90,0},{100,500},{110,500},{120,1000}},
		FireDamageBase		= 0,
		LightingDamageBase	= 0,

		PhysicalMagicBase	= 0,
		PoisonMagicBase		= 0,
		ColdMagicBase		= {{1,0},{90,0},{100,500},{110,500},{120,1000}},
		FireMagicBase		= 0,
		LightingMagicBase	= 0,

		AuraSkillId			= 0,    
		AuraSkillLevel		= 0,    
		PasstSkillId		= 802, 
		PasstSkillLevel		= 10,    
	},
	xiakedao_huo		= {		--侠客岛焚情,无甲，高攻
		Exp					= 0,
		Life				= {{1,0},{90,0},{100,1500},{110,1500},{120,3000}},
		LifeReplenish		= {{1,0},{120,0}},
		AR					= {{1,3000},{120,3000}},
		Defense				= 0,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= {{1,0},{90,0},{100,0},{110,0},{120,0}},
		PoisonResist		= {{1,0},{90,0},{100,0},{110,0},{120,0}},
		ColdResist			= {{1,0},{90,0},{100,0},{110,0},{120,0}},
		FireResist 			= {{1,0},{90,0},{100,0},{110,0},{120,0}},
		LightResist			= {{1,0},{90,0},{100,0},{110,0},{120,0}},

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= 0,
		ColdDamageBase		= 0,
		FireDamageBase		= {{1,0},{90,0},{100,2000},{110,4000},{120,8000}},
		LightingDamageBase	= 0,

		PhysicalMagicBase	= 0,
		PoisonMagicBase		= 0,
		ColdMagicBase		= 0,
		FireMagicBase		= {{1,0},{90,0},{100,2000},{110,4000},{120,8000}},
		LightingMagicBase	= 0,

		AuraSkillId			= 0,    
		AuraSkillLevel		= 0,    
		PasstSkillId		= 1411, 
		PasstSkillLevel		= 1,    
	},
	xiakedao_tu		= {		--侠客岛正阳
		Exp					= 0,
		Life				= {{1,0},{90,0},{100,2000},{110,4000},{120,4000}},
		LifeReplenish		= {{1,0},{120,0}},
		AR					= {{1,3000},{120,4000}},
		Defense				= {{1,3000},{120,4000}},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= {{1,0},{90,0},{100,260},{110,280},{120,300}},
		PoisonResist		= {{1,0},{90,0},{100,150},{110,200},{120,250}},
		ColdResist			= {{1,0},{90,0},{100,850},{110,900},{120,980}},
		FireResist 			= {{1,0},{90,0},{100,850},{110,900},{120,980}},
		LightResist			= {{1,0},{90,0},{100,260},{110,280},{120,300}},

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= 0,
		ColdDamageBase		= 0,
		FireDamageBase		= 0,
		LightingDamageBase	= {{1,0},{90,0},{100,1000},{110,1000},{120,2000}},

		PhysicalMagicBase	= 0,
		PoisonMagicBase		= 0,
		ColdMagicBase		= 0,
		FireMagicBase		= 0,
		LightingMagicBase	= {{1,0},{90,0},{100,1000},{110,1000},{120,2000}},

		AuraSkillId			= 0,    
		AuraSkillLevel		= 0,    
		PasstSkillId		= 802, 
		PasstSkillLevel		= 16,    
	},
	kuafubaihu		= {	--跨服白虎
		Exp					= {{1,0},{10,0}},
		Life				= {{1,1},{100,100000},{110,7000000},{120,7400000}},
		LifeReplenish		= {{1,1},{100,100},{110,74000},{120,74000}},
		AR					= 3000,
		Defense				= 300,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 300,
		PoisonResist		= 300,
		ColdResist			= 300,
		FireResist 			= 300,
		LightResist			= 300,

		PhysicalDamageBase	= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},
		PoisonDamageBase	= {{1,0},{90,0},{100,5},{110,3000/5/0.7/2},{120,3000/5/0.7/2}},
		ColdDamageBase		= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},
		FireDamageBase		= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},
		LightingDamageBase	= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},

		PhysicalMagicBase	= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},
		PoisonMagicBase		= {{1,0},{90,0},{100,5},{110,3000/5/0.7/2},{120,3000/5/0.7/2}},
		ColdMagicBase		= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},
		FireMagicBase		= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},
		LightingMagicBase	= {{1,0},{90,0},{100,10},{110,3000/5/0.7},{120,3000/5/0.7}},

		AuraSkillId			= 0,    
		AuraSkillLevel		= 0,    
		PasstSkillId		= 1411, 
		PasstSkillLevel		= 1,    

	},
	npc4006		= {
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 125*1.5),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.7),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.7),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.7),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.7),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.7),
		
		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.7),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.7),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.7),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.7),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.7),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	npc4004		= {
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 223*1.5),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.7),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.7),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.7),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.7),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.7),
		
		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.7),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.7),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.7),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.7),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.7),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	npc4002		= {
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 279*1.5),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.88),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.88),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.88),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.88),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.88),
		
		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.88),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.88),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.88),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.88),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.88),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	npc2773		= {		--暗哨
		Exp					= 0,
		Life				= {{1,90},{9,180},{10,6100},{30,53800},{60,159900},{100,365500},},
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= 1,
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.35},

		AuraSkillId			= 988,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	jy_unreturn		= {		--不反弹怪
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 6*5/3),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= 1,
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.3},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 1411,
		PasstSkillLevel		= 1,
	},
	jy_bereturn		= {		--反弹小怪
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 6.6),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= 1,
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.35},

		AuraSkillId			= 1091,
		AuraSkillLevel		= 4,
		PasstSkillId		= 1411,
		PasstSkillLevel		= 1,
	},

	npc7314		= {		--白素素
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 279*1.5*2),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		tbRisBase			= 1,
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.88},


		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	npc4074		= {		--雪魂珠和仙乳灵石
		Exp					= 0,
		Life				= {{1,90},{9,180},{10,6100},{30,53800},{60,159900},{100,365500},},
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 1,
		PoisonDamageBase	= 1,
		ColdDamageBase		= 1,
		FireDamageBase		= 1,
		LightingDamageBase	= 1,

		PhysicalMagicBase	= 1,
		PoisonMagicBase		= 1,
		ColdMagicBase		= 1,
		FireMagicBase		= 1,
		LightingMagicBase	= 1,

		AuraSkillId			= 1018,
		AuraSkillLevel		= 2,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	npc4097		= {		--机关,强度4
		Exp					= 1,
		Life				= {{1,90},{9,180},{10,6100},{30,53800},{60,159900},{100,365500},},
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity1, 1, 0.5),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity1, 2, 0.5),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity1, 3, 0.5),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity1, 4, 0.5),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity1, 5, 0.5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity1, 1, 0.5),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity1, 2, 0.5),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity1, 3, 0.5),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity1, 4, 0.5),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity1, 5, 0.5),

		AuraSkillId			= 1024,--1024无形蛊击退,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
-------------------碧落谷新---------------------------
		bossbiluogu_new		= {		--新碧落谷Boss
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life,220),
		LifeReplenish		= 0,
		AR					= {{1,100},{100,1000},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack,Npc.tbDamage.basecangbaotu1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 1411,
		PasstSkillLevel		= 1,
	},	
-----------------------------------------------------
	npc4241		= {		--任务副本,帅
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity5_Life),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.4),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.4),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.4),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.4),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.4),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.4),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.4),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.4),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	npc4242		= {		--任务副本,仕
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity2_Life),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2),

		AuraSkillId			= 1018,--回血光环,半秒2W
		AuraSkillLevel		= 4,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	npc4243		= {		--任务副本,相
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity2_Life),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2),

		AuraSkillId			= 1362,--提高友方攻击光环,3级30%
		AuraSkillLevel		= 3,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
----------------区域争夺战---------------
	dispute_boss  	= {		--区域争夺战boss
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.domain_Life, 156*6),--15人打1分钟
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),
		--100级攻击1600左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.domainatk, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.domainatk, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.domainatk, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.domainatk, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.domainatk, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.domainatk, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.domainatk, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.domainatk, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.domainatk, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.domainatk, 5),

		AuraSkillId			= 594,--免疫五行状态光环,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	dispute_general  	= {		--区域争夺战将领
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.domain_Life, 156*1.4),--15人打1分钟
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),
		--100级攻击1600左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.4),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.domainatk, 2, 0.4),
		ColdDamageBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.4),
		FireDamageBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.4),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.4),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.domainatk, 2, 0.4),
		ColdMagicBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.4),
		FireMagicBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.4),

		AuraSkillId			= 594,--免疫五行状态光环,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	dispute_soldier  	= {		--区域争夺战士兵
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.domain_Life, 24.5*1.4),--15人打0.25分钟
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,25},{10,250},{100,2500},},
		Defense				= {{1,7},{10,75},{100,750},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),
		--100级攻击800左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.25),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.domainatk, 2, 0.25),
		ColdDamageBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.25),
		FireDamageBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.25),
		LightingDamageBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.25),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.25),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.domainatk, 2, 0.25),
		ColdMagicBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.25),
		FireMagicBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.25),
		LightingMagicBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.25),

		AuraSkillId			= 594,--免疫五行状态光环,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	dispute_pillar  	= {		--非主城龙柱
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 334),--12人打2分钟
		LifeReplenish		= 0,
		AR					= 1,
		Defense				= 1,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),
		--100级攻击800左右
		PhysicalDamageBase	= 1,
		PoisonDamageBase	= 1,
		ColdDamageBase		= 1,
		FireDamageBase		= 1,
		LightingDamageBase	= 1,

		PhysicalMagicBase	= 1,
		PoisonMagicBase		= 1,
		ColdMagicBase		= 1,
		FireMagicBase		= 1,
		LightingMagicBase	= 1,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 1411,
		PasstSkillLevel		= 1,
	},
	dispute_tank10  	= {		--攻城车
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.dispute10_Life, 4),
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.dispute10, 1),
		PoisonResist		= GetResist(Npc.tbResist.dispute10, 2),
		ColdResist			= GetResist(Npc.tbResist.dispute10, 3),
		FireResist 			= GetResist(Npc.tbResist.dispute10, 4),
		LightResist			= GetResist(Npc.tbResist.dispute10, 5),
		--100级攻击1600左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.dispute10, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.dispute10, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.dispute10, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.dispute10, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.dispute10, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.dispute10, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.dispute10, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.dispute10, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.dispute10, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.dispute10, 5),

		AuraSkillId			= 0,--免疫五行状态光环,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	dispute_tank12  	= {		--攻城车
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.dispute12_Life, 4),
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.dispute12, 1),
		PoisonResist		= GetResist(Npc.tbResist.dispute12, 2),
		ColdResist			= GetResist(Npc.tbResist.dispute12, 3),
		FireResist 			= GetResist(Npc.tbResist.dispute12, 4),
		LightResist			= GetResist(Npc.tbResist.dispute12, 5),
		--100级攻击1600左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.dispute12, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.dispute12, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.dispute12, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.dispute12, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.dispute12, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.dispute12, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.dispute12, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.dispute12, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.dispute12, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.dispute12, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	dispute_tank14  	= {		--攻城车
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.dispute14_Life, 4),
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.dispute14, 1),
		PoisonResist		= GetResist(Npc.tbResist.dispute14, 2),
		ColdResist			= GetResist(Npc.tbResist.dispute14, 3),
		FireResist 			= GetResist(Npc.tbResist.dispute14, 4),
		LightResist			= GetResist(Npc.tbResist.dispute14, 5),
		--100级攻击1600左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.dispute14, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.dispute14, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.dispute14, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.dispute14, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.dispute14, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.dispute14, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.dispute14, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.dispute14, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.dispute14, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.dispute14, 5),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	dispute_mercenary_atk  	= {		--区域争夺战雇佣兵攻击型
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 110),
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),
		--100级攻击1600左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.4),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.4),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.4),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.4),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.4),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.4),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.4),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.4),

		AuraSkillId			= 0,--免疫五行状态光环,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	dispute_mercenary_def  	= {		--区域争夺战雇佣兵防御型
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 312),--15人打2分钟
		LifeReplenish		= 0,--{{1,1*5},{10,375*5},{20,1500*5},{30,3250*5},{40,4500*5},{50,5500*5},{60,7500*5},{90,15000*5},{100,20000*5}},
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),
		--100级攻击1600左右
		PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 0.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2),

		AuraSkillId			= 0,--免疫五行状态光环,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
----------------游龙阁--------------------
	youlonggegongzhu  	= {		--游龙阁公主
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 10),--1个人打20s
		LifeReplenish		= 0,
		AR					= {{1,30},{10,300},{100,3000},},
		Defense				= {{1,5},{10,100},{100,1000},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,100},{100,100},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity5, 1, 0.1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity5, 2, 0.1),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity5, 3, 0.1),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity5, 4, 0.1),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity5, 5, 0.1),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity5, 1, 0.1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity5, 2, 0.1),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity5, 3, 0.1),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity5, 4, 0.1),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity5, 5, 0.1),

		AuraSkillId			= 594,--免疫五行状态光环,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
----------------逍遥谷---------------
----------------简单逍遥谷---------------
	xoyo_easy_lv15 = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 3*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	
	xoyo_easy_lv15poison = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 3*0.9*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 2},

		AuraSkillId			= 1092,
		AuraSkillLevel		= 10,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv15b = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 3*3*10*1.5*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 3},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv15c = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 3*1.14*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 1.2},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv15d = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 3*1.5*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 1.2},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16 = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*4*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 1.2},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16b = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*2*4*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 1.2},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16c = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*0.7*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 0.7},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16d = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*1.5*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 0.7},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16e = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*3*10*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 1.5},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16f = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*0.5*2*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16g = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*15*2*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 3},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv16hu = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*15*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 2},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv17 = { -- 简单逍遥谷
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.4*3*5*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 3},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_easy_lv17_boss = { -- 简单逍遥谷_boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.4*3*3*3*20*2*(1-0.4)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 8},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
-------------逍遥谷特殊怪------------
	xoyo3	= {--强度3的怪,2.7倍攻击
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife3),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.special, 1),
		PoisonResist		= GetResist(Npc.tbResist.special, 2),
		ColdResist			= GetResist(Npc.tbResist.special, 3),
		FireResist 			= GetResist(Npc.tbResist.special, 4),
		LightResist			= GetResist(Npc.tbResist.special, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 2.7);
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 2.7);
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 2.7);
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 2.7);
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 2.7);

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 2.7);
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 2.7);
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 2.7);
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 2.7);
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 2.7);

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo6	= {
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife6),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2),

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyo_rebound	= {--xoyo谷特殊怪1,高反弹,需要断断续续的打
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife),--血量降低为普通怪血量
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= 0,
		PoisonResist		= 0,
		ColdResist			= 0,
		FireResist 			= 0,
		LightResist			= 0,

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5),

		AuraSkillId			= 1091,
		AuraSkillLevel		= 4,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xoyoboss3180	= {--xoyo谷boss4分钟
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 365),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,--取消清除纯阳无极
		PasstSkillLevel		= 0,
	},
	xoyoboss3200	= {--xoyo谷boss6分钟
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 500),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2),

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,--取消清除纯阳无极
		PasstSkillLevel		= 0,
	},
	xoyoboss3201	= {--xoyo谷boss8分钟
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 550),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 220,--弑元诀
		PasstSkillLevel		= 20,
	},
	xoyoboss3216	= {--xoyo谷boss10分钟
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 550),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,--取消清除纯阳无极
		PasstSkillLevel		= 0,
	},
	xoyoboss3221	= {--xoyo谷boss7分钟
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 650),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,--取消清除纯阳无极
		PasstSkillLevel		= 0,
	},
	xoyoboss3316	= {--xoyo谷boss7分钟
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 650),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,--取消清除纯阳无极
		PasstSkillLevel		= 0,
	},
	xoyoboss3320	= {--xoyo谷boss8分钟*1.3
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 710),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},   --5秒回血
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3),
		FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3),
		LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3),

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 220,--弑元诀
		PasstSkillLevel		= 20,
	},
------------------------逍遥谷地狱关卡--------------------------
--银花婆婆
	hellxoyo7303	= {
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*6*0.6*1.2),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.boss1, 1),
		PoisonResist		= GetResist(Npc.tbResist.boss1, 2),
		ColdResist			= GetResist(Npc.tbResist.boss1, 3),
		FireResist 			= GetResist(Npc.tbResist.boss1, 4),
		LightResist			= GetResist(Npc.tbResist.boss1, 5),

		PhysicalDamageBase	= 400,
		PoisonDamageBase	= 400/2,
		ColdDamageBase		= 400,
		FireDamageBase		= 400,
		LightingDamageBase	= 400,

		PhysicalMagicBase	= 400,
		PoisonMagicBase		= 400/2,
		ColdMagicBase		= 400,
		FireMagicBase		= 400,
		LightingMagicBase	= 400,

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
--多多
	hellxoyo_7332	= {
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*10*0.6),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= SetResistByRis_p({0.2,0.3,0.4},1),
		PoisonResist		= SetResistByRis_p({0.2,0.3,0.4},2),
		ColdResist			= SetResistByRis_p({0.2,0.3,0.4},3),
		FireResist 			= SetResistByRis_p({0.2,0.3,0.4},4),
		LightResist			= SetResistByRis_p({0.2,0.3,0.4},5),

		PhysicalDamageBase	= 400,
		PoisonDamageBase	= 400/2,
		ColdDamageBase		= 400,
		FireDamageBase		= 400,
		LightingDamageBase	= 400,

		PhysicalMagicBase	= 400,
		PoisonMagicBase		= 400/2,
		ColdMagicBase		= 400,
		FireMagicBase		= 400,
		LightingMagicBase	= 400,

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	hellxoyo6735	= {--xoyo谷boss6分钟--红莲使者火蓬春
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*6*0.9*0.9),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.9},

		AuraSkillId			= 594,--免疫负面效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 376,--取消清除纯阳无极
		PasstSkillLevel		= 1,
	},
	hellxoyo6736	= {--xoyo谷boss6分钟--风雪女王风雪晴
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*6*0.72),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.9},
		
		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	hellxoyo_handan	= {
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*6*0.72),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.95},
		
		AuraSkillId			= 2043,--无影毒+免疫光环
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	hellxoyo_yuanding	= { --百草园丁_7级boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*10*0.6),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 1.2},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	hellxoyo_lixin	= { --礼信_7级boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*3*0.6*1.1*0.85*0.65),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 1.2},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	hellxoyo_yejing	= { --叶静_7级boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*10*0.6*0.65),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 1.2},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	hellxoyo_baiqiulin	= { --影之白秋琳_7级boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*10*0.6*1.2*1.1),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 1.25},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	hellxoyo_guzhu	= { --逍遥谷主_8级boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*12*0.6*2*0.75),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 1.75},

		AuraSkillId			= 1410,
		AuraSkillLevel		= 1,
		PasstSkillId		= 853,
		PasstSkillLevel		= 13,
	},
----------清明节活动npc----------
	plant	= {--蘑菇
		Exp					= 0,
		Life				= {{1,100},{2,200},{3,300},{4,300}},
		LifeReplenish		= 0,   --5秒回血
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= 0,
		MinDamage			= {{1,20},{2,25},{3,30},},
		MaxDamage			= {{1,20},{2,25},{3,30},},
		PhysicsResist		= 0,
		PoisonResist		= 0,
		ColdResist			= 0,
		FireResist 			= 0,
		LightResist			= 0,

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= 0,
		ColdDamageBase		= 0,
		FireDamageBase		= 0,
		LightingDamageBase	= 0,

		PhysicalMagicBase	= 0,
		PoisonMagicBase		= 0,
		ColdMagicBase		= 0,
		FireMagicBase		= 0,
		LightingMagicBase	= 0,

		AuraSkillId			= GetSeriesData({1606,1606,1607,1608,1609,1610}),
		AuraSkillLevel		= GetSLData({		{{1,2},{2,3},{3,4}},
												{{1,2},{2,3},{3,4}},
												{{1,20},{2,26},{3,33}},
												{{1,1},{2,1},{3,1}},
												{{1,2},{2,3},{3,4}},
												{{1,3},{2,5},{3,8}}	}),
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	corpse	= {--僵尸
		Exp					= 0,
		Life				= {{1,200},{2,500},{3,900},{4,7000}},
		LifeReplenish		= 0,   --5秒回血
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= 0,
		MinDamage			= {{1,5},{2,8},{3,25},{4,100},},
		MaxDamage			= {{1,5},{2,8},{3,25},{4,100},},
		PhysicsResist		= 0,
		PoisonResist		= 0,
		ColdResist			= 0,
		FireResist 			= 0,
		LightResist			= 0,

		PhysicalDamageBase	= 0,
		PoisonDamageBase	= 0,
		ColdDamageBase		= 0,
		FireDamageBase		= 0,
		LightingDamageBase	= 0,

		PhysicalMagicBase	= 0,
		PoisonMagicBase		= 0,
		ColdMagicBase		= 0,
		FireMagicBase		= 0,
		LightingMagicBase	= 0,

		AuraSkillId			= {{1,0},{2,374},{3,375},{4,376},{5,376}},
		AuraSkillLevel		= {{1,0},{2,1},{3,1}},
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	kf_bht_npc1= { --白虎堂boss召唤npc
		Exp					= 0,
		Life				= 2000000,
		LifeReplenish		= 0,   --5秒回血
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= 0,
		MinDamage			= 1,
		MaxDamage			= 10,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 500,
		PoisonDamageBase	= 500,
		ColdDamageBase		= 500,
		FireDamageBase		= 500,
		LightingDamageBase	= 500,

		PhysicalMagicBase	= 500,
		PoisonMagicBase		= 500,
		ColdMagicBase		= 500,
		FireMagicBase		= 500,
		LightingMagicBase	= 500,

		AuraSkillId			= 1835,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,
		PasstSkillLevel		= 1,
	},
	nianshou_2011= { ----攻城年兽
		Exp					= 0,
		Life				= 600000,
		LifeReplenish		= 0,   --5秒回血
		AR					= {{1,9999},{10,9999},{100,9999},},
		Defense				= 0,
		MinDamage			= 1,
		MaxDamage			= 1,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 50,
		PoisonDamageBase	= 50,
		ColdDamageBase		= 50,
		FireDamageBase		= 50,
		LightingDamageBase	= 50,

		PhysicalMagicBase	= 50,
		PoisonMagicBase		= 50,
		ColdMagicBase		= 50,
		FireMagicBase		= 50,
		LightingMagicBase	= 50,

		AuraSkillId			= 594,--免疫效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 1480,--免疫各种攻击
		PasstSkillLevel		= 20,
	},
	qiuyi_2011= { ----被攻城白秋琳
		Exp					= 0,
		Life				= 105000,
		LifeReplenish		= 1200,   --5秒回血
		AR					= {{1,9999},{10,9999},{100,9999},},
		Defense				= 0,
		MinDamage			= 1,
		MaxDamage			= 1,
		PhysicsResist		= 1,
		PoisonResist		= 1,
		ColdResist			= 1,
		FireResist 			= 1,
		LightResist			= 1,

		PhysicalDamageBase	= 1,
		PoisonDamageBase	= 1,
		ColdDamageBase		= 1,
		FireDamageBase		= 1,
		LightingDamageBase	= 1,

		PhysicalMagicBase	= 1,
		PoisonMagicBase		= 1,
		ColdMagicBase		= 1,
		FireMagicBase		= 1,
		LightingMagicBase	= 1,

		AuraSkillId			= 594,--免疫效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
-----------------------------楼兰古城---------------------------------
	loulan_sp01= { --楼兰古城_精英怪_1
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 5*60*2*0.7),
		LifeReplenish		= 0,   --5秒回血
		AR					= {{1,9999},{10,9999},{100,9999},},
		Defense				= 0,
		MinDamage			= 1,
		MaxDamage			= 1,

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},

		PhysicalDamageBase	= 330,
		PoisonDamageBase	= 330/2,
		ColdDamageBase		= 330,
		FireDamageBase		= 330,
		LightingDamageBase	= 330,

		PhysicalMagicBase	= 330,
		PoisonMagicBase		= 330/2,
		ColdMagicBase		= 330,
		FireMagicBase		= 330,
		LightingMagicBase	= 330,

		AuraSkillId			= 594,--免疫效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	loulan_nm00= { --楼兰古城_精英怪_召唤小怪
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 5*8*0.7),
		LifeReplenish		= 0,   --5秒回血
		AR					= {{1,9999},{10,9999},{100,9999},},
		Defense				= 0,
		MinDamage			= 1,
		MaxDamage			= 1,

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},

		PhysicalDamageBase	= 200,
		PoisonDamageBase	= 200/2,
		ColdDamageBase		= 200,
		FireDamageBase		= 200,
		LightingDamageBase	= 200,

		PhysicalMagicBase	= 200,
		PoisonMagicBase		= 200/2,
		ColdMagicBase		= 200,
		FireMagicBase		= 200,
		LightingMagicBase	= 200,

		AuraSkillId			= 594,--免疫效果
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
----------------------新藏宝图：阴阳时光殿-------------------------
	cbt_lichunfeng	= { --第一关 : 李淳风
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new,  1*3*3*(1-0.4)*1.4*1*1),---时间 * 人数 * (1-抗性百分比）* 暴击系数 * 装备强度系数 * 实际站桩输出时间系数
		LifeReplenish		= 0,
		AR					= 1,
		Defense				= 2000,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cbt_fangshi	= { --第一关 : 方士
		Exp					= 1,
		Life				= GetData(Npc.tbDamage.BaseAtk_new[1], 2),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},
		
		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cbt_yuantiangang	= { --第一关 : 袁天罡
		Exp					= 960000,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 4*60*6*(1-0.4)*1.4*1*0.6),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new,3.4},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_wangyifeng_1	= { --第二关 : 王遗风_阶段1
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1.5*60*6*(1-0.4)*1.4*1*0.77),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 3.3},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_wangyifeng_2	= { --第二关 : 王遗风_阶段2
		Exp					= 480000,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new,2*60*6*(1-0.4)*1.4*1*0.75),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 3.3},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_xiaotaijian	= { --第三关 : 小太监
		Exp					= 1440000,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 5*60*6*(1-0.4)*1.4*1*0.75),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 3.5},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_xiaotaijian_s	= { --第三关 : 小太监分身
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 0.5*60*2*(1-0.4)*1.4*1*0.75),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 0.1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cbt_helper	= { --第三关 : 援助者
		Exp					= 1,
		Life				= GetData(Npc.tbDamage.BaseAtk_new[1], 10),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 5},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cbt_zixuan	= { --第四关 : 紫轩
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 5*60*6*(1-0.4)*1.4*1*1),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_zhuofeifan	= { --第四关  : 卓非凡
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 3*60*6*(1-0.4)*1.4*1*0.75),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 3.5},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_nalanzhen	= { --第四关  : 纳兰真
		Exp					= 3840000,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 4*60*6*(1-0.4)*1.4*1*0.6),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new,2.5},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_dasiming	= { --第五关  : 大司命
		Exp					= 2880000,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 5*60*6*(1-0.4)*1.4*1*0.6),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 3},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_shiren	= { --第五关  : 尸人（五个五行怪）
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*30*1.2*(1-0.4)*1.4*1*0.9),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1.6},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_kuilei_1	= { --第五关  : 傀儡非战斗
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*5*1.5*(1-0.4)*1.4*1*1),--应该和<傀儡战斗激活>的一样
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 0.5},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	cbt_kuilei_2	= { --第五关  : 傀儡战斗激活
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*5*1.5*(1-0.4)*1.4*1*1),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 0.5},

		AuraSkillId			= 1963,
		AuraSkillLevel		= 60,
		PasstSkillId		= 594,
		PasstSkillLevel		= 1,
		PasstSkillId1		= 2331,
		PasstSkillLevel1		= 1,
	},
	cbt_movingbomb	= { --第五关  : 人肉炸弹,移动AOE
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*3*2*(1-0.4)*1.4*1*1),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2288,
		PasstSkillLevel		= 1,
	},
	cbt_xingshizourou	= { --第五关  : 行尸走肉（同时击杀）
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1.5*60*3*(1-0.4)*1.4*1*0.9),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 2},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_defender_1	= { --第五关  : 守护者（把玩家拉进黑水）
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*5*3*(1-0.4)*1.4*1*1),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
	cbt_defender_2	= { --第五关  : 心魔阵眼（房间内）
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*5*1*(1-0.4)*1.4*1*1),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2331,
		PasstSkillLevel		= 1,
	},
-------铁浮城状态战旗
	xkd_buffflag1	= { --鼓舞战旗
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 9999),
		LifeReplenish		= GetData(Npc.tbDataTemplet.BaseLife_new, 9999),
		AR					= 0,
		Defense				= 0,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,1},{100,1},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= 5,

		AuraSkillId			= 1964,--友方免疫所有状态
		AuraSkillLevel		= 1,
		PasstSkillId		= 2219,--闪避李代桃僵
		PasstSkillLevel		= 1,
	},
	xkd_buffflag2	= { --迷乱之柱
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 10*(1-.4)*5),--10个人打5秒
		LifeReplenish		= 0,
		AR					= 0,
		Defense				= 0,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,1},{100,1},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= 5,

		AuraSkillId			= 1966,--友方npc无敌,自身不受此无敌影响
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xkd_buffflag3	= { --奉献战旗
		Exp					= 0,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 10*(1-.4)*10/2),--10个人打10秒,由于自身受伤害少50%
		LifeReplenish		= 0,
		AR					= 0,
		Defense				= 0,
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,1},{100,1},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.4,0.5}},
		tbAtkBase			= 5,

		AuraSkillId			= 1968,--友方受到伤害减少50%
		AuraSkillLevel		= 10,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--------------------新战场载具-----------------------
	npc11001	= { --战场战车强度
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 66),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,1500},{100,1500},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 10},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	npc11002	= { --战场箭塔强度
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 17),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{100,5}},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 10},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	npc11003	= { --战场炮塔强度
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 51),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,1500},{100,1500},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 10},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
	npc11004	= { --龙脉强度
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 68),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,1500},{100,1500},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},

		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 10},

		AuraSkillId			= 376,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1411,--被动免疫
		PasstSkillLevel		= 1,
	},
----------------------10级新手副本-------------------------
	boss_jin	= { --金系小boss
		Exp					= 1,
		Life				= 2500,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 20,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	boss_mu	= { --木系小boss
		Exp					= 1,
		Life				= 2500,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 20,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	boss_tu	= { --土系小boss
		Exp					= 1,
		Life				= 2500,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 20,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	boss_shui	= { --水系小boss
		Exp					= 1,
		Life				= 2500,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 20,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	boss_huo	= { --火系小boss
		Exp					= 1,
		Life				= 2500,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 20,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	luzhanfeng	= { --陆展风
		Exp					= 1,
		Life				= 7500,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 30,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	yijunshibing	= { --义军士兵
		Exp					= 1,
		Life				= 625,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xizuo	= { --细作
		Exp					= 1,
		Life				= 3750,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
----------------------20级新手副本-------------------------
	duchong	= { --植物1-刺荆藤
		Exp					= 1,
		Life				= 900,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 100,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	plant_1	= { --植物2-血蒺藜
		Exp					= 1,
		Life				= 900,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	bossplant_1	= { --蛇皇刺
		Exp					= 1,
		Life				= 1350,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	bossplant_2	= { --龙爪花
		Exp					= 1,
		Life				= 1350,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	bossplant_3	= { --蝎尾藤
		Exp					= 1,
		Life				= 1350,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	mushroom	= { --蘑菇-负面效果
		Exp					= 1,
		Life				= 2260,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	duyifeng	= { --毒一风
		Exp					= 1,
		Life				= 20340,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 50,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_noob, 10},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	duxie	= { --毒蝎
		Exp					= 1,
		Life				= 2260,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 10,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	fangbaixi	= { --方西白
		Exp					= 1,
		Life				= 27120,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_noob, 11},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	surong	= { --夙融
		Exp					= 1,
		Life				= 27120,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_noob, 11},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xiyan	= { --夕焱
		Exp					= 1,
		Life				= 27120,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_noob, 12},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xilan	= { --夕岚
		Exp					= 1,
		Life				= 33900,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_noob, 12},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	xiting	= { --夕亭
		Exp					= 1,
		Life				= 81360,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_noob, 13},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	tianjiushu	= { --甜酒叔
		Exp					= 1,
		Life				= 542400,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 0,
		MaxDamage			= 0,
		
		tbRisBase			= 0,
		tbAtkBase			= 0,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
--------------------新手藏宝图碧落谷-----------------------	
	pochuan	= { --竹筏
		Exp					= 1,
		Life				= 10086,
		LifeReplenish		= 0,
		AR					= 300,
		Defense				= 5,
		MinDamage			= 1,
		MaxDamage			= 2,
		
		tbRisBase			= 0,
		tbAtkBase			= 19999,

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,	
	},
----------------------2011年圣诞活动-------------------------	
	christ_oldman_1 = { -- 圣诞老人_驾车
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 3.75*60*6*(1-0.2)*1.4), --血量和下面的圣诞boss一样
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.2,0.2}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.cangbaotuboss1, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 1111,
		PasstSkillLevel		= 10,
	},
	christ_oldman_2 = { -- 圣诞老人_boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 3.75*60*6*(1-0.2)*1.4), -- 6个人打10分钟
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.2,0.2}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.cangbaotuboss1, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	christ_girl = { -- 圣诞少女
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 5*6*1.4), -- 6个人打5秒
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0,0,0}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.intensity2, 1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	christ_elk= { -- 圣诞麋鹿
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 5*6*1.4), -- 6个人打5秒
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0,0,0}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.intensity2, 1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	muzixue2	= {	--家族副本房间o内的npc(冥府冤魂)
		Exp					= GetData(Npc.tbDataTemplet.intensity99, 30),
		Life				= GetData(Npc.tbDataTemplet.mingfuyuanhunLife, 2.55),
		LifeReplenish		= {{1,1},{10,375},{20,1500},{30,3250},{40,4500},{50,5500},{60,7500},{90,15000},{100,20000}},
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		PhysicsResist		= GetResist(Npc.tbResist.normal, 1),
		PoisonResist		= GetResist(Npc.tbResist.normal, 2),
		ColdResist			= GetResist(Npc.tbResist.normal, 3),
		FireResist 			= GetResist(Npc.tbResist.normal, 4),
		LightResist			= GetResist(Npc.tbResist.normal, 5),

		PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.2),
		PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity4, 2, 1.2),
		ColdDamageBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.2),
		FireDamageBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.2),
		LightingDamageBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.2),

		PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity4, 1, 1.2),
		PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity4, 2, 1.2),
		ColdMagicBase		= GetAtack(Npc.tbDamage.intensity4, 3, 1.2),
		FireMagicBase		= GetAtack(Npc.tbDamage.intensity4, 4, 1.2),
		LightingMagicBase	= GetAtack(Npc.tbDamage.intensity4, 5, 1.2),

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	keyimen_boss1_1	= {
		Exp					= 1,
		Life				=     291600000,
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.5,0.5,0.5}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1.5},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 2651,
		PasstSkillLevel		= 1,
	},
	keyimen_boss2	= {	--克夷门战场，小Boss
		Exp					= 1,
		Life				=      51030000,
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.3,0.3,0.3}},

		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1.2},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	keyimen_boss3	= {	--克夷门战场，随机Boss
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 3*20*(1-0.2)),
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.2,0.2}},

		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	keyimen_boss_guard1	= {	--克夷门战场，大Boss召唤怪1
		Exp					= 1,
		Life				=        10935000,
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.1,0.1,0.1}},

		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	keyimen_boss_guard2	= {	--克夷门战场，大Boss召唤怪2
		Exp					= 1,
		Life				=        291600000,
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.1,0.1,0.1}},

		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 2724,
		PasstSkillLevel		= 10,
		PasstSkillId1		= 1411,
		PasstSkillLevel1	= 1,
	},
	keyimen_flag_xx	= {	--克夷门战场，西夏军旗
		Exp					= 1,
		Life				=        291600000,
		LifeReplenish		= 0,
		AR					= {{1,100},{55,1000},{75,3000},{95,5000},{100,5000},},
		Defense				= {{1,5},{55,300},{75,300},{95,300},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.1,0.1,0.1}},

		tbAtkBase			= {GetAtack, Npc.tbDamage.BaseAtk_new, 1},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 2651,
		PasstSkillLevel		= 1,
	},
	

--------------新手任务副本------------
	tasknoob_10259	= {--金军统领
		Exp					= 1,
		Life				=  GetData(Npc.tbDataTemplet.intensity99_Life, 20),
		LifeReplenish		= 0,
		AR					= {{1,200},{100,6000},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,3},{100,3},},
		
		tbRisBase			= {SetResistByRis_p,{0.1,0.1,0.1}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.intensity0, 1.0},
		
		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	tasknoob_10261	= {--许仕伟
		Exp					= 1,
		Life				=  GetData(Npc.tbDataTemplet.intensity99_Life, 9),
		LifeReplenish		= 0,
		AR					= {{1,30},{10,70},{100,700},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,3},{100,3},},
		
		tbRisBase			= {SetResistByRis_p,{0.1,0.1,0.1}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.intensity0, 0.7},
		
		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	tasknoob_10256	= {--陆往生
		Exp					= 1,
		Life				= 12300,--GetData(Npc.tbDataTemplet.intensity99_Life, 20),
		LifeReplenish		= 0,
		AR					= 200,
		Defense				= 1,
		MinDamage			= 1,
		MaxDamage			= 3,
		
		tbRisBase			= 0,
		tbAtkBase			= {GetAtack, {8,8/2}},
		
		AuraSkillId			= 594,
		AuraSkillLevel		= 1,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
	},
	tasknoob_10301	= {--子书青跟宠
		Exp					= 1,
		Life				=  GetData(Npc.tbDataTemplet.intensity99_Life, 20),
		LifeReplenish		= 0,
		AR					= {{1,1},{10,1},{100,1},},
		Defense				= {{1,5},{10,5},{11,10},{100,200},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,1},{100,1},},
		
		tbRisBase			= 0,
		tbAtkBase			= 1,
		
		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 2861,
		PasstSkillLevel		= 1,
	},
	bird_test_11053 = { -- 青螺岛飞行信鸽
		Exp					= 1,
		Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 1.2*3*1.5*3*(1-0.3)),
		LifeReplenish		=  0,
		AR					= 3000,
		Defense				= {{1,5},{10,5},{11,30},{100,300},},
		MinDamage			= {{1,1},{100,1},},
		MaxDamage			= {{1,10},{100,10},},
		
		tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}},
		tbAtkBase			= {GetAtack, Npc.tbDamage.xoyo_intensity1, 0.7},

		AuraSkillId			= 0,
		AuraSkillLevel		= 0,
		PasstSkillId		= 0,
		PasstSkillLevel		= 0,
		BaseHeight			= 150,
	},
	
};

--楼兰古城_召唤小怪_地狱追命使
Npc.tbPropBase.loulan_nm01	= Lib:CopyTB1(Npc.tbPropBase.loulan_nm00);
Npc.tbPropBase.loulan_nm01.PhysicalDamageBase	= 550;
Npc.tbPropBase.loulan_nm01.PoisonDamageBase		= 550/2;
Npc.tbPropBase.loulan_nm01.ColdDamageBase		= 550;
Npc.tbPropBase.loulan_nm01.FireDamageBase		= 550;
Npc.tbPropBase.loulan_nm01.LightingDamageBase	= 550;
Npc.tbPropBase.loulan_nm01.PhysicalMagicBase	= 550;
Npc.tbPropBase.loulan_nm01.PoisonMagicBase		= 550/2;
Npc.tbPropBase.loulan_nm01.ColdMagicBase		= 550;
Npc.tbPropBase.loulan_nm01.FireMagicBase		= 550;
Npc.tbPropBase.loulan_nm01.LightingMagicBase	= 550;
Npc.tbPropBase.loulan_nm01.AuraSkillId			= 594;
Npc.tbPropBase.loulan_nm01.AuraSkillLevel		= 1;
Npc.tbPropBase.loulan_nm01.PasstSkillId			= 1901;
Npc.tbPropBase.loulan_nm01.PasstSkillLevel		= 1;


--楼兰古城_精英怪_2
Npc.tbPropBase.loulan_sp02	= Lib:CopyTB1(Npc.tbPropBase.loulan_sp01);


--楼兰古城_召唤小怪_火焰使者
Npc.tbPropBase.loulan_nm02	= Lib:CopyTB1(Npc.tbPropBase.loulan_nm00);

--楼兰古城BOSS_1
Npc.tbPropBase.loulan_boss01	= Lib:CopyTB1(Npc.tbPropBase.loulan_sp01);
Npc.tbPropBase.loulan_boss01.Life = GetData(Npc.tbDataTemplet.BaseLife_new, 5*60*5*0.7);
Npc.tbPropBase.loulan_boss01.PhysicalDamageBase	= 1400;
Npc.tbPropBase.loulan_boss01.PoisonDamageBase	= 1400/2;
Npc.tbPropBase.loulan_boss01.ColdDamageBase		= 1400;
Npc.tbPropBase.loulan_boss01.FireDamageBase		= 1400;
Npc.tbPropBase.loulan_boss01.LightingDamageBase	= 1400;
Npc.tbPropBase.loulan_boss01.PhysicalMagicBase	= 1400;
Npc.tbPropBase.loulan_boss01.PoisonMagicBase	= 1400/2;
Npc.tbPropBase.loulan_boss01.ColdMagicBase		= 1400;
Npc.tbPropBase.loulan_boss01.FireMagicBase		= 1400;
Npc.tbPropBase.loulan_boss01.LightingMagicBase	= 1400;

--楼兰古城_精英怪_2召唤小怪_灵魂摆渡者
Npc.tbPropBase.loulan_nm03	= Lib:CopyTB1(Npc.tbPropBase.loulan_nm00);
--楼兰古城_逃跑羚羊怪
Npc.tbPropBase.loulan_flee	= Lib:CopyTB1(Npc.tbPropBase.loulan_sp01);
Npc.tbPropBase.loulan_flee.Life = 6*12*20;
Npc.tbPropBase.loulan_flee.PasstSkillId	= 1111;
Npc.tbPropBase.loulan_flee.PasstSkillLevel	= 10;
Npc.tbPropBase.loulan_flee.PasstSkillId1	= 2219;
Npc.tbPropBase.loulan_flee.PasstSkillLevel1	= 10;

--剑贼
Npc.tbPropBase.intensity0_sword	= Lib:CopyTB1(Npc.tbPropBase.wanted);
Npc.tbPropBase.intensity0_sword.Exp = 0;
Npc.tbPropBase.intensity0_sword.LifeReplenish		= GetData(Npc.tbDataTemplet.wanted_LifeReplenish);
Npc.tbPropBase.intensity0_sword.PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity5, 1, 1.6);
Npc.tbPropBase.intensity0_sword.PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity5, 2, 1.6);
Npc.tbPropBase.intensity0_sword.ColdDamageBase		= GetAtack(Npc.tbDamage.intensity5, 3, 1.6);
Npc.tbPropBase.intensity0_sword.FireDamageBase		= GetAtack(Npc.tbDamage.intensity5, 4, 1.6);
Npc.tbPropBase.intensity0_sword.LightingDamageBase	= GetAtack(Npc.tbDamage.intensity5, 5, 1.6);
Npc.tbPropBase.intensity0_sword.PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity5, 1, 1.6);
Npc.tbPropBase.intensity0_sword.PoisonMagicBase		= GetAtack(Npc.tbDamage.intensity5, 2, 1.6);
Npc.tbPropBase.intensity0_sword.ColdMagicBase		= GetAtack(Npc.tbDamage.intensity5, 3, 1.6);
Npc.tbPropBase.intensity0_sword.FireMagicBase		= GetAtack(Npc.tbDamage.intensity5, 4, 1.6);
Npc.tbPropBase.intensity0_sword.LightingMagicBase	= GetAtack(Npc.tbDamage.intensity5, 5, 1.6);
Npc.tbPropBase.intensity0_sword.AuraSkillId			= 1007;
Npc.tbPropBase.intensity0_sword.AuraSkillLevel		= 1;
Npc.tbPropBase.intensity0_sword.PasstSkillId		= 973;
Npc.tbPropBase.intensity0_sword.PasstSkillLevel		= 1;
--刀贼
Npc.tbPropBase.intensity1_blade	= Lib:CopyTB1(Npc.tbPropBase.intensity0_sword);
Npc.tbPropBase.intensity1_blade.Exp = 0;
Npc.tbPropBase.intensity1_blade.LifeReplenish		= GetData(Npc.tbDataTemplet.wanted_LifeReplenish,2);
Npc.tbPropBase.intensity1_blade.AuraSkillId			= 1007;
Npc.tbPropBase.intensity1_blade.AuraSkillLevel		= 1;
Npc.tbPropBase.intensity1_blade.PasstSkillId		= 973;
Npc.tbPropBase.intensity1_blade.PasstSkillLevel		= 1;
--枪贼
Npc.tbPropBase.intensity3_lance	= Lib:CopyTB1(Npc.tbPropBase.intensity0_sword);
Npc.tbPropBase.intensity3_lance.Exp = 0;
Npc.tbPropBase.intensity3_lance.LifeReplenish		= 999999;
Npc.tbPropBase.intensity3_lance.AuraSkillId			= 0;
Npc.tbPropBase.intensity3_lance.AuraSkillLevel		= 0;
Npc.tbPropBase.intensity3_lance.PasstSkillId		= 973;
Npc.tbPropBase.intensity3_lance.PasstSkillLevel		= 1;

--白斩鸡
Npc.tbPropBase.intensity6_4111	= Lib:CopyTB1(Npc.tbPropBase.intensity6);
--宠物鸡
Npc.tbPropBase.intensity0_4112	= Lib:CopyTB1(Npc.tbPropBase.intensity0);
Npc.tbPropBase.intensity0_4112.Life			= GetData(Npc.tbDataTemplet.intensity99_Life, 4);
Npc.tbPropBase.intensity0_4112.Defense		= {{1,100},{10,100},{11,200},{100,4000},};

--逍遥谷
--强度3的怪,2.7倍攻击	--转移到上方
--强度3的怪,2.7倍攻击,死亡爆伤害
Npc.tbPropBase.xoyo3_deadatk		= Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_deadatk.PasstSkillId		= 272;
Npc.tbPropBase.xoyo3_deadatk.PasstSkillLevel	= 10;
--强度3的怪,2.7倍攻击,全屏回血光环
Npc.tbPropBase.xoyo3_auracure		= Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_auracure.AuraSkillId		= 1018;
Npc.tbPropBase.xoyo3_auracure.AuraSkillLevel	= {{1,11},{10,11},{100,20}};
--强度3的怪,2.7倍攻击,无形蛊光环
Npc.tbPropBase.xoyo3_poison		= Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_poison.AuraSkillId			= 1092;
Npc.tbPropBase.xoyo3_poison.AuraSkillLevel		= 10;
--忽略外功系攻击的intensity3_xoyo
Npc.tbPropBase.xoyo3_ignore1 = Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_ignore1.PasstSkillId		= 1099;
Npc.tbPropBase.xoyo3_ignore1.PasstSkillLevel	= 20;
--忽略内功系攻击的intensity3
Npc.tbPropBase.xoyo3_ignore2 = Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_ignore2.PasstSkillId		= 1100;
Npc.tbPropBase.xoyo3_ignore2.PasstSkillLevel	= 20;
--免疫五行状态的intensity3
Npc.tbPropBase.xoyo3_ignore3 = Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_ignore3.AuraSkillId		= 594;
Npc.tbPropBase.xoyo3_ignore3.AuraSkillLevel		= 1;
--强度3的怪,高血量
Npc.tbPropBase.xoyo3_hp200		= Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_hp200.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife3, 2);

--强度4的怪,2.7倍攻击
Npc.tbPropBase.xoyo4 = Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo4.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife4);
--带无形蛊光环强度4的怪,2.7倍攻击
Npc.tbPropBase.xoyo4_poison = Lib:CopyTB1(Npc.tbPropBase.xoyo4);
Npc.tbPropBase.xoyo4_poison.AuraSkillId		= 1092;
Npc.tbPropBase.xoyo4_poison.AuraSkillLevel	= 10;
--强度4的怪,免疫五行状态
Npc.tbPropBase.xoyo4_ignore3		= Lib:CopyTB1(Npc.tbPropBase.xoyo4);
Npc.tbPropBase.xoyo4_ignore3.AuraSkillId 	= 594;
Npc.tbPropBase.xoyo4_ignore3.AuraSkillLevel = 1;

--强度5的怪,2.7倍攻击
Npc.tbPropBase.xoyo5 = Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo5.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife5);
--强度5的怪,3.6倍攻击
Npc.tbPropBase.xoyo5_atk150 = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_atk150.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 3.6);
Npc.tbPropBase.xoyo5_atk150.PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 3.6);
Npc.tbPropBase.xoyo5_atk150.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 3.6);
Npc.tbPropBase.xoyo5_atk150.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 3.6);
Npc.tbPropBase.xoyo5_atk150.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 3.6);
Npc.tbPropBase.xoyo5_atk150.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 3.6);
Npc.tbPropBase.xoyo5_atk150.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 3.6);
Npc.tbPropBase.xoyo5_atk150.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 3.6);
Npc.tbPropBase.xoyo5_atk150.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 3.6);
Npc.tbPropBase.xoyo5_atk150.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 3.6);
--带无形蛊的intensity5_xoyo
Npc.tbPropBase.xoyo5_poison = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_poison.AuraSkillId			= 1092;
Npc.tbPropBase.xoyo5_poison.AuraSkillLevel		= 10;
--全屏回血的intensity5_xoyo
Npc.tbPropBase.xoyo5_auracure = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_auracure.AuraSkillId		= 1018;
Npc.tbPropBase.xoyo5_auracure.AuraSkillLevel	= {{1,11},{10,11},{100,20}};
--忽略外功系攻击的intensity5_xoyo
Npc.tbPropBase.xoyo5_ignore1 = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_ignore1.PasstSkillId		= 1099;
Npc.tbPropBase.xoyo5_ignore1.PasstSkillLevel	= 20;
--忽略内功系攻击的intensity5_xoyo
Npc.tbPropBase.xoyo5_ignore2 = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_ignore2.PasstSkillId		= 1100;
Npc.tbPropBase.xoyo5_ignore2.PasstSkillLevel	= 20;
--强度5的怪,1.5倍血
Npc.tbPropBase.xoyo5_hp150 = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_hp150.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife5, 1.5);
--强度5的怪,免疫五行状态
Npc.tbPropBase.xoyo5_ignore3 = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_ignore3.AuraSkillId		= 594;
Npc.tbPropBase.xoyo5_ignore3.AuraSkillLevel		= 1;

--强度6的怪,2倍攻击--转移到上方
--强度6的怪,2倍攻击
Npc.tbPropBase.xoyo6_ignore3 = Lib:CopyTB1(Npc.tbPropBase.xoyo6);
Npc.tbPropBase.xoyo6_ignore3.AuraSkillId		= 594;
Npc.tbPropBase.xoyo6_ignore3.AuraSkillLevel		= 1;

--强度7的怪,2倍攻击
Npc.tbPropBase.xoyo7 = Lib:CopyTB1(Npc.tbPropBase.xoyo6);
Npc.tbPropBase.xoyo7.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife7, 4);
Npc.tbPropBase.xoyo7.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 5);
Npc.tbPropBase.xoyo7.PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 5);
Npc.tbPropBase.xoyo7.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 5);
Npc.tbPropBase.xoyo7.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 5);
Npc.tbPropBase.xoyo7.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 5);
Npc.tbPropBase.xoyo7.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 5);
Npc.tbPropBase.xoyo7.PoisonMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 5);
Npc.tbPropBase.xoyo7.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 5);
Npc.tbPropBase.xoyo7.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 5);
Npc.tbPropBase.xoyo7.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 5);
Npc.tbPropBase.xoyo7.AuraSkillId		= 594;
Npc.tbPropBase.xoyo7.AuraSkillLevel		= 1;
--强度8的怪,2倍攻击
Npc.tbPropBase.xoyo8 = Lib:CopyTB1(Npc.tbPropBase.xoyo6);
Npc.tbPropBase.xoyo8.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife8);
Npc.tbPropBase.xoyo8.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2);
Npc.tbPropBase.xoyo8.PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2);
Npc.tbPropBase.xoyo8.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2);
Npc.tbPropBase.xoyo8.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2);
Npc.tbPropBase.xoyo8.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2);
Npc.tbPropBase.xoyo8.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2);
Npc.tbPropBase.xoyo8.PoisonMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2);
Npc.tbPropBase.xoyo8.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2);
Npc.tbPropBase.xoyo8.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2);
Npc.tbPropBase.xoyo8.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2);
--强度8的怪,2.2倍攻击
Npc.tbPropBase.xoyo8_atk110 = Lib:CopyTB1(Npc.tbPropBase.xoyo8);
Npc.tbPropBase.xoyo8_atk110.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2.2);
Npc.tbPropBase.xoyo8_atk110.PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2.2);
Npc.tbPropBase.xoyo8_atk110.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2.2);
Npc.tbPropBase.xoyo8_atk110.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2.2);
Npc.tbPropBase.xoyo8_atk110.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2.2);
Npc.tbPropBase.xoyo8_atk110.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2.2);
Npc.tbPropBase.xoyo8_atk110.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2.2);
Npc.tbPropBase.xoyo8_atk110.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2.2);
Npc.tbPropBase.xoyo8_atk110.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2.2);
Npc.tbPropBase.xoyo8_atk110.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2.2);
--强度8的怪,2倍血,2.5倍攻击
Npc.tbPropBase.xoyo8_hp200_atk125 = Lib:CopyTB1(Npc.tbPropBase.xoyo8);
Npc.tbPropBase.xoyo8_hp200_atk125.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife8, 2);
Npc.tbPropBase.xoyo8_hp200_atk125.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.PoisonDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.PhysicalMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.ColdMagicBase			= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.FireMagicBase			= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 2.5);
Npc.tbPropBase.xoyo8_hp200_atk125.LightingMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 2.5);
--强度8的怪,4倍血,3倍攻击,命名不对..
Npc.tbPropBase.xoyo8_hp400_atk300 = Lib:CopyTB1(Npc.tbPropBase.xoyo8);
Npc.tbPropBase.xoyo8_hp400_atk300.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife8, 4);
Npc.tbPropBase.xoyo8_hp400_atk300.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.PoisonDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.PhysicalMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.ColdMagicBase			= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.FireMagicBase			= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.LightingMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 3);
Npc.tbPropBase.xoyo8_hp400_atk300.AuraSkillId = 594;
Npc.tbPropBase.xoyo8_hp400_atk300.AuraSkillLevel = 1;
--强度8的怪,3.6倍血,3倍攻击,免疫负面状态光环
Npc.tbPropBase.xoyo8_hp360_atk300_immunity = Lib:CopyTB1(Npc.tbPropBase.xoyo8_hp400_atk300);
Npc.tbPropBase.xoyo8_hp360_atk300_immunity.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife8, 3.6);
Npc.tbPropBase.xoyo8_hp360_atk300_immunity.AuraSkillId = 594;
Npc.tbPropBase.xoyo8_hp360_atk300_immunity.AuraSkillLevel = 1;

--极弱护送怪,血量为同等级练级怪的3倍
Npc.tbPropBase.xoyofellow = Lib:CopyTB1(Npc.tbPropBase.intensity99);
Npc.tbPropBase.xoyofellow.Exp = 0;
Npc.tbPropBase.xoyofellow.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 3);

--护送怪,强度2的1.5倍血
Npc.tbPropBase.xoyofellow2 = Lib:CopyTB1(Npc.tbPropBase.intensity2);
Npc.tbPropBase.xoyofellow2.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife2, 1.5);

--护送怪,极强
Npc.tbPropBase.xoyofellow3 = Lib:CopyTB1(Npc.tbPropBase.intensity10);
Npc.tbPropBase.xoyofellow3.LifeReplenish = 200000;
Npc.tbPropBase.xoyofellow3.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 10);
Npc.tbPropBase.xoyofellow3.PoisonDamageBase		= GetAtack(Npc.tbDamage.fellow3, 2, 10);
Npc.tbPropBase.xoyofellow3.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 10);
Npc.tbPropBase.xoyofellow3.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 10);
Npc.tbPropBase.xoyofellow3.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 10);
Npc.tbPropBase.xoyofellow3.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 10);
Npc.tbPropBase.xoyofellow3.PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2, 10);
Npc.tbPropBase.xoyofellow3.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 10);
Npc.tbPropBase.xoyofellow3.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 10);
Npc.tbPropBase.xoyofellow3.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 10);
--护送怪,极强2
Npc.tbPropBase.xoyofellow3_2 = Lib:CopyTB1(Npc.tbPropBase.xoyofellow3);
Npc.tbPropBase.xoyofellow3_2.AuraSkillId		= 594;
Npc.tbPropBase.xoyofellow3_2.AuraSkillLevel		= 1;

--萨达姆1
Npc.tbPropBase.xoyo_saddam1 = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo_saddam1.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife5, 3);
Npc.tbPropBase.xoyo_saddam1.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 6);
Npc.tbPropBase.xoyo_saddam1.PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 6);
Npc.tbPropBase.xoyo_saddam1.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 6);
Npc.tbPropBase.xoyo_saddam1.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 6);
Npc.tbPropBase.xoyo_saddam1.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 6);
Npc.tbPropBase.xoyo_saddam1.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 6);
Npc.tbPropBase.xoyo_saddam1.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 6);
Npc.tbPropBase.xoyo_saddam1.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 6);
Npc.tbPropBase.xoyo_saddam1.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 6);
Npc.tbPropBase.xoyo_saddam1.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 6);
--萨达姆2
Npc.tbPropBase.xoyo_saddam2 = Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo_saddam2.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife5);
Npc.tbPropBase.xoyo_saddam2.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 2);
Npc.tbPropBase.xoyo_saddam2.PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 2);
Npc.tbPropBase.xoyo_saddam2.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 2);
Npc.tbPropBase.xoyo_saddam2.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 2);
Npc.tbPropBase.xoyo_saddam2.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 2);
Npc.tbPropBase.xoyo_saddam2.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 1, 2);
Npc.tbPropBase.xoyo_saddam2.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 2, 2);
Npc.tbPropBase.xoyo_saddam2.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 3, 2);
Npc.tbPropBase.xoyo_saddam2.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity1, 4, 2);
Npc.tbPropBase.xoyo_saddam2.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity1, 5, 2);
--强度8的怪,6倍攻击
Npc.tbPropBase.xoyo8_atk666 = Lib:CopyTB1(Npc.tbPropBase.xoyo8);
Npc.tbPropBase.xoyo8_atk666.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 6);
Npc.tbPropBase.xoyo8_atk666.PoisonDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 6);
Npc.tbPropBase.xoyo8_atk666.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 6);
Npc.tbPropBase.xoyo8_atk666.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 6);
Npc.tbPropBase.xoyo8_atk666.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 6);
Npc.tbPropBase.xoyo8_atk666.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 6);
Npc.tbPropBase.xoyo8_atk666.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 6);
Npc.tbPropBase.xoyo8_atk666.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 6);
Npc.tbPropBase.xoyo8_atk666.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 6);
Npc.tbPropBase.xoyo8_atk666.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 6);
Npc.tbPropBase.xoyo8_atk666.AuraSkillId			= 594;
Npc.tbPropBase.xoyo8_atk666.AuraSkillLevel		= 1;
--强度8的怪,4倍攻击
Npc.tbPropBase.xoyo8_atk66 = Lib:CopyTB1(Npc.tbPropBase.xoyo8);
Npc.tbPropBase.xoyo8_atk66.PhysicalDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 4);
Npc.tbPropBase.xoyo8_atk66.PoisonDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 4);
Npc.tbPropBase.xoyo8_atk66.ColdDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 4);
Npc.tbPropBase.xoyo8_atk66.FireDamageBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 4);
Npc.tbPropBase.xoyo8_atk66.LightingDamageBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 4);
Npc.tbPropBase.xoyo8_atk66.PhysicalMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 1, 4);
Npc.tbPropBase.xoyo8_atk66.PoisonMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 2, 4);
Npc.tbPropBase.xoyo8_atk66.ColdMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 3, 4);
Npc.tbPropBase.xoyo8_atk66.FireMagicBase		= GetAtack(Npc.tbDamage.xoyo_intensity2, 4, 4);
Npc.tbPropBase.xoyo8_atk66.LightingMagicBase	= GetAtack(Npc.tbDamage.xoyo_intensity2, 5, 4);
Npc.tbPropBase.xoyo8_atk66.AuraSkillId			= 594;
Npc.tbPropBase.xoyo8_atk66.AuraSkillLevel		= 1;

--逍遥谷拔萝卜变身
Npc.tbPropBase.pluckupradish = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.pluckupradish.Life = 15;
--逍遥谷LV5机关
Npc.tbPropBase.xoyo3_poison_lv5						= Lib:CopyTB1(Npc.tbPropBase.xoyo3);
Npc.tbPropBase.xoyo3_poison_lv5.AuraSkillId			= 1092;--无形蛊
Npc.tbPropBase.xoyo3_poison_lv5.AuraSkillLevel		= 10;
Npc.tbPropBase.xoyo3_poison_lv5.PasstSkillId		= 1111;--减少100%受到的伤害
Npc.tbPropBase.xoyo3_poison_lv5.PasstSkillLevel		= 10;

Npc.tbPropBase.xoyo7_lv5						    = Lib:CopyTB1(Npc.tbPropBase.xoyo7);
Npc.tbPropBase.xoyo7_lv5.Life 						= GetData(Npc.tbDataTemplet.XoyoBaseLife7, 1.5);

Npc.tbPropBase.xoyo_dong							= Lib:CopyTB1(Npc.tbPropBase.xoyo8_atk110);
Npc.tbPropBase.xoyo_dong.Life 						= GetData(Npc.tbDataTemplet.XoyoBaseLife8);
Npc.tbPropBase.xoyo_dong.AuraSkillId				= 594;
Npc.tbPropBase.xoyo_dong.AuraSkillLevel				= 1;

Npc.tbPropBase.xoyo_xi								= Lib:CopyTB1(Npc.tbPropBase.xoyo8_atk110);
Npc.tbPropBase.xoyo_xi.Life 						= GetData(Npc.tbDataTemplet.XoyoBaseLife8);
Npc.tbPropBase.xoyo_xi.AuraSkillId					= 594;
Npc.tbPropBase.xoyo_xi.AuraSkillLevel				= 1;

Npc.tbPropBase.xoyo_nan								= Lib:CopyTB1(Npc.tbPropBase.xoyo8_atk110);
Npc.tbPropBase.xoyo_nan.Life 						= GetData(Npc.tbDataTemplet.XoyoBaseLife8);
Npc.tbPropBase.xoyo_nan.AuraSkillId					= 594;
Npc.tbPropBase.xoyo_nan.AuraSkillLevel				= 1;

Npc.tbPropBase.xoyo_bei								= Lib:CopyTB1(Npc.tbPropBase.xoyo8_atk110);
Npc.tbPropBase.xoyo_bei.Life 						= GetData(Npc.tbDataTemplet.XoyoBaseLife8);
Npc.tbPropBase.xoyo_bei.AuraSkillId					= 594;
Npc.tbPropBase.xoyo_bei.AuraSkillLevel				= 1;

Npc.tbPropBase.xoyo5_poison_lv5						= Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_poison_lv5.AuraSkillId			= 1092;--无形蛊
Npc.tbPropBase.xoyo5_poison_lv5.AuraSkillLevel		= 10;
Npc.tbPropBase.xoyo5_poison_lv5.PasstSkillId		= 1111;--减少100%受到的伤害
Npc.tbPropBase.xoyo5_poison_lv5.PasstSkillLevel		= 10;
--受到伤害减半
Npc.tbPropBase.xoyo5_half							= Lib:CopyTB1(Npc.tbPropBase.xoyo5);
Npc.tbPropBase.xoyo5_half.PasstSkillId				= 1111;--减少50%受到的伤害
Npc.tbPropBase.xoyo5_half.PasstSkillLevel			= 5;

--逍遥谷3期
Npc.tbPropBase.xoyo4660				= Lib:CopyTB1(Npc.tbPropBase.intensity99);
Npc.tbPropBase.xoyo4660.Exp			= 0;
Npc.tbPropBase.xoyo4660.Life		= GetData(Npc.tbDataTemplet.XoyoBaseLife);

Npc.tbPropBase.xoyo4661						= Lib:CopyTB1(Npc.tbPropBase.xoyo4660)
Npc.tbPropBase.xoyo4661.Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 5*15/2);--5个人打15秒
Npc.tbPropBase.xoyo4661.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3,1,0.5);
Npc.tbPropBase.xoyo4661.PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3,2,0.5);
Npc.tbPropBase.xoyo4661.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3,3,0.5);
Npc.tbPropBase.xoyo4661.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3,4,0.5);
Npc.tbPropBase.xoyo4661.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3,5,0.5);
Npc.tbPropBase.xoyo4661.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3,1,0.5);
Npc.tbPropBase.xoyo4661.PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3,2,0.5);
Npc.tbPropBase.xoyo4661.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3,3,0.5);
Npc.tbPropBase.xoyo4661.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3,4,0.5);
Npc.tbPropBase.xoyo4661.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3,5,0.5);
Npc.tbPropBase.xoyo4661.AuraSkillId			= 1018;--全屏回血
Npc.tbPropBase.xoyo4661.AuraSkillLevel		= {{1,11},{10,11},{100,20}};
Npc.tbPropBase.xoyo4661.PasstSkillId		= 1411;--被动免疫负面效果
Npc.tbPropBase.xoyo4661.PasstSkillLevel		= 1;

Npc.tbPropBase.xoyo4662						= Lib:CopyTB1(Npc.tbPropBase.xoyo4660)
Npc.tbPropBase.xoyo4662.Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 5*20/2);--5个人打20秒
Npc.tbPropBase.xoyo4662.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3,1,0.5);
Npc.tbPropBase.xoyo4662.PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3,2,0.5);
Npc.tbPropBase.xoyo4662.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3,3,0.5);
Npc.tbPropBase.xoyo4662.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3,4,0.5);
Npc.tbPropBase.xoyo4662.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3,5,0.5);
Npc.tbPropBase.xoyo4662.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3,1,0.5);
Npc.tbPropBase.xoyo4662.PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3,2,0.5);
Npc.tbPropBase.xoyo4662.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3,3,0.5);
Npc.tbPropBase.xoyo4662.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3,4,0.5);
Npc.tbPropBase.xoyo4662.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3,5,0.5);
Npc.tbPropBase.xoyo4662.PasstSkillId		= 1411;--被动免疫负面效果
Npc.tbPropBase.xoyo4662.PasstSkillLevel		= 1;

Npc.tbPropBase.xoyo4663						= Lib:CopyTB1(Npc.tbPropBase.xoyo4660)
Npc.tbPropBase.xoyo4663.Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 5*30/2);--5个人打30秒
Npc.tbPropBase.xoyo4663.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3,1,0.5);
Npc.tbPropBase.xoyo4663.PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3,2,0.5);
Npc.tbPropBase.xoyo4663.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3,3,0.5);
Npc.tbPropBase.xoyo4663.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3,4,0.5);
Npc.tbPropBase.xoyo4663.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3,5,0.5);
Npc.tbPropBase.xoyo4663.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3,1,0.5);
Npc.tbPropBase.xoyo4663.PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3,2,0.5);
Npc.tbPropBase.xoyo4663.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3,3,0.5);
Npc.tbPropBase.xoyo4663.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3,4,0.5);
Npc.tbPropBase.xoyo4663.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3,5,0.5);
Npc.tbPropBase.xoyo4663.AuraSkillId			= 1429;--提高20%攻击
Npc.tbPropBase.xoyo4663.AuraSkillLevel		= 2;
--Npc.tbPropBase.xoyo4663.PasstSkillId		= 1411;
--Npc.tbPropBase.xoyo4663.PasstSkillLevel		= 1;

Npc.tbPropBase.xoyo4664					= Lib:CopyTB1(Npc.tbPropBase.xoyo4660)
Npc.tbPropBase.xoyo4664.Life				= GetData(Npc.tbDataTemplet.XoyoBaseLife, 5*60/2);--5个人打60秒
Npc.tbPropBase.xoyo4664.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3,1,0.75);
Npc.tbPropBase.xoyo4664.PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3,2,0.75);
Npc.tbPropBase.xoyo4664.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3,3,0.75);
Npc.tbPropBase.xoyo4664.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3,4,0.75);
Npc.tbPropBase.xoyo4664.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3,5,0.75);
Npc.tbPropBase.xoyo4664.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3,1,0.75);
Npc.tbPropBase.xoyo4664.PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3,2,0.75);
Npc.tbPropBase.xoyo4664.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3,3,0.75);
Npc.tbPropBase.xoyo4664.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3,4,0.75);
Npc.tbPropBase.xoyo4664.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3,5,0.75);
Npc.tbPropBase.xoyo4664.PasstSkillId		= 1411;--被动免疫负面效果
Npc.tbPropBase.xoyo4664.PasstSkillLevel		= 1;
-----------------------------------------逍遥谷结束的分割线----------------------------------------
-----------------------财宝兔活动-------------------
--2点血的npc
Npc.tbPropBase.xoyo2hpnnpc = Lib:CopyTB1(Npc.tbPropBase.intensity0);
Npc.tbPropBase.xoyo2hpnnpc.Life = 2;
--财宝兔
Npc.tbPropBase.rabbit1 = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.rabbit1.Life = 50;
Npc.tbPropBase.rabbit1.AuraSkillId		= 594;
Npc.tbPropBase.rabbit1.AuraSkillLevel	= 1;
Npc.tbPropBase.rabbit1.PasstSkillId		= 1111;--受到五行伤害降低10W点
Npc.tbPropBase.rabbit1.PasstSkillLevel	= 10;

--小财宝兔
Npc.tbPropBase.rabbit2 = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.rabbit2.Life = 15;
Npc.tbPropBase.rabbit2.AuraSkillId		= 0;
Npc.tbPropBase.rabbit2.AuraSkillLevel	= 0;
Npc.tbPropBase.rabbit2.PasstSkillId		= 1111;--受到五行伤害降低10W点
Npc.tbPropBase.rabbit2.PasstSkillLevel	= 10;

--玉兔
Npc.tbPropBase.moonrabbit = Lib:CopyTB1(Npc.tbPropBase.intensity0);
Npc.tbPropBase.moonrabbit.AuraSkillId		= 1166;--特效光环
Npc.tbPropBase.moonrabbit.AuraSkillLevel	= 1;

--高经验练级怪
Npc.tbPropBase.intensity99ex = Lib:CopyTB1(Npc.tbPropBase.intensity99);
Npc.tbPropBase.intensity99ex.Exp	= GetData(Npc.tbDataTemplet.intensity99, 2);
-------------旧100级藏宝图----------
Npc.tbPropBase.cangbaotuboss2766 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss2760);
Npc.tbPropBase.cangbaotuboss2766.Exp  = GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp);
Npc.tbPropBase.cangbaotuboss2766.Life = 2800000*Npc.IVER_CangBaoTuNpcStrong;

Npc.tbPropBase.cangbaotuboss2767 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss2766);
Npc.tbPropBase.cangbaotuboss2767.Exp  = GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp);
Npc.tbPropBase.cangbaotuboss2767.Life = 2800000*Npc.IVER_CangBaoTuNpcStrong;
Npc.tbPropBase.cangbaotuboss2767.AuraSkillId		= 1007;
Npc.tbPropBase.cangbaotuboss2767.AuraSkillLevel		= 1;

Npc.tbPropBase.cangbaotuboss2768 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss2760);
Npc.tbPropBase.cangbaotuboss2768.Exp  = GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp);
Npc.tbPropBase.cangbaotuboss2768.Life = 2500000*Npc.IVER_CangBaoTuNpcStrong;

Npc.tbPropBase.cangbaotuboss2769 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss2768);
Npc.tbPropBase.cangbaotuboss2769.Exp  = GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp);
Npc.tbPropBase.cangbaotuboss2769.Life = 2500000*Npc.IVER_CangBaoTuNpcStrong;
Npc.tbPropBase.cangbaotuboss2769.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.PoisonMagicBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.cangbaotuboss2769.AuraSkillId		= 1133;
Npc.tbPropBase.cangbaotuboss2769.AuraSkillLevel		= 20;

Npc.tbPropBase.cangbaotuboss2772 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss2768);
Npc.tbPropBase.cangbaotuboss2772.Exp  = GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp);
Npc.tbPropBase.cangbaotuboss2772.Life = 3000000*Npc.IVER_CangBaoTuNpcStrong;

Npc.tbPropBase.cangbaotuboss2773 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss2768);
Npc.tbPropBase.cangbaotuboss2773.Exp  = GetData(Npc.tbDataTemplet.cangbaotuboss1_Exp);
Npc.tbPropBase.cangbaotuboss2773.Life = 3500000*Npc.IVER_CangBaoTuNpcStrong;
-------------new_藏宝图_千琼宫----------
Npc.tbPropBase.new_cangbaotuboss2740 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss3_04);
Npc.tbPropBase.new_cangbaotuboss2740.AuraSkillId = 1007;
Npc.tbPropBase.new_cangbaotuboss2740.AuraSkillLevel = 1;
-------------new_藏宝图_万花谷----------
--铁浮屠
Npc.tbPropBase.new_cangbaotuboss2760 = Lib:CopyTB1(Npc.tbPropBase.cangbaotuboss2760);
Npc.tbPropBase.new_cangbaotuboss2760.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 3200000/20000*Npc.IVER_CangBaoTuNpcStrong);--3200000*Npc.IVER_CangBaoTuNpcStrong,
--铁莫西
Npc.tbPropBase.new_cangbaotunormal2759 = Lib:CopyTB1(Npc.tbPropBase.cangbaotunormal2759);
Npc.tbPropBase.new_cangbaotunormal2759.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 1000000/20000*Npc.IVER_CangBaoTuNpcStrong);--1000000*Npc.IVER_CangBaoTuNpcStrong,
--蛮族战士
Npc.tbPropBase.new_cangbaotunormal2775 = Lib:CopyTB1(Npc.tbPropBase.cangbaotunormal2775);
Npc.tbPropBase.new_cangbaotunormal2775.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 1000000/20000*Npc.IVER_CangBaoTuNpcStrong);--1000000*Npc.IVER_CangBaoTuNpcStrong,
--蛮族医师
Npc.tbPropBase.new_cangbaotunormal2782 = Lib:CopyTB1(Npc.tbPropBase.cangbaotunormal2782);
Npc.tbPropBase.new_cangbaotunormal2782.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 350000/20000*Npc.IVER_CangBaoTuNpcStrong);--350000*Npc.IVER_CangBaoTuNpcStrong,
--黑熊,羚羊
Npc.tbPropBase.new_cangbaotunormal2776 = Lib:CopyTB1(Npc.tbPropBase.cangbaotunormal2776);
Npc.tbPropBase.new_cangbaotunormal2776.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 300000/20000*Npc.IVER_CangBaoTuNpcStrong);--300000*Npc.IVER_CangBaoTuNpcStrong,
--花豹
Npc.tbPropBase.new_cangbaotunormal2778 = Lib:CopyTB1(Npc.tbPropBase.cangbaotunormal2778);
--陶子
Npc.tbPropBase.new_cangbaotufellow2761 = Lib:CopyTB1(Npc.tbPropBase.cangbaotufellow2761);
Npc.tbPropBase.new_cangbaotufellow2761.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 300000/20000*Npc.IVER_CangBaoTuNpcStrong);--300000*Npc.IVER_CangBaoTuNpcStrong,
--青青
Npc.tbPropBase.new_cangbaotufellow2764 = Lib:CopyTB1(Npc.tbPropBase.cangbaotufellow2764);
Npc.tbPropBase.new_cangbaotufellow2764.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 500000/20000*Npc.IVER_CangBaoTuNpcStrong);--500000*Npc.IVER_CangBaoTuNpcStrong,

-------------100级藏宝图_新----------
--百羽
Npc.tbPropBase.new_cangbaotuboss2766 = Lib:CopyTB1(Npc.tbPropBase.new_cangbaotuboss2760);
Npc.tbPropBase.new_cangbaotuboss2766.Exp  = GetData(Npc.tbDataTemplet.intensity99, 2800000/20000/4);
Npc.tbPropBase.new_cangbaotuboss2766.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 2800000/20000*Npc.IVER_CangBaoTuNpcStrong);--500000*Npc.IVER_CangBaoTuNpcStrong;
--黄散一
Npc.tbPropBase.new_cangbaotuboss2767 = Lib:CopyTB1(Npc.tbPropBase.new_cangbaotuboss2766);
Npc.tbPropBase.new_cangbaotuboss2767.Exp  = GetData(Npc.tbDataTemplet.intensity99, 2800000/20000/4);
Npc.tbPropBase.new_cangbaotuboss2767.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 2800000/20000*Npc.IVER_CangBaoTuNpcStrong);--2800000*Npc.IVER_CangBaoTuNpcStrong;
Npc.tbPropBase.new_cangbaotuboss2767.AuraSkillId		= 1007;
Npc.tbPropBase.new_cangbaotuboss2767.AuraSkillLevel		= 1;
--柳生
Npc.tbPropBase.new_cangbaotuboss2768 = Lib:CopyTB1(Npc.tbPropBase.new_cangbaotuboss2760);
Npc.tbPropBase.new_cangbaotuboss2768.Exp  = GetData(Npc.tbDataTemplet.intensity99, 2500000/20000/4);
Npc.tbPropBase.new_cangbaotuboss2768.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 2500000/20000*Npc.IVER_CangBaoTuNpcStrong);--2500000*Npc.IVER_CangBaoTuNpcStrong;
--贾茹
Npc.tbPropBase.new_cangbaotuboss2769 = Lib:CopyTB1(Npc.tbPropBase.new_cangbaotuboss2768);
Npc.tbPropBase.new_cangbaotuboss2769.Exp  = GetData(Npc.tbDataTemplet.intensity99, 2500000/20000/4);
Npc.tbPropBase.new_cangbaotuboss2769.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 2500000/20000*Npc.IVER_CangBaoTuNpcStrong);--2500000*Npc.IVER_CangBaoTuNpcStrong;
Npc.tbPropBase.new_cangbaotuboss2769.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.PoisonMagicBase	= GetAtack(Npc.tbDamage.fellow3, 2, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5, 0.2*Npc.IVER_CangBaoTuNpcStrong);
Npc.tbPropBase.new_cangbaotuboss2769.AuraSkillId		= 1133;
Npc.tbPropBase.new_cangbaotuboss2769.AuraSkillLevel		= 20;
--谷仙仙
Npc.tbPropBase.new_cangbaotuboss2772 = Lib:CopyTB1(Npc.tbPropBase.new_cangbaotuboss2768);
Npc.tbPropBase.new_cangbaotuboss2772.Exp  = GetData(Npc.tbDataTemplet.intensity99, 3000000/20000/4);
Npc.tbPropBase.new_cangbaotuboss2772.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 3000000/20000*Npc.IVER_CangBaoTuNpcStrong);--3000000*Npc.IVER_CangBaoTuNpcStrong;
--醉僧
Npc.tbPropBase.new_cangbaotuboss2773 = Lib:CopyTB1(Npc.tbPropBase.new_cangbaotuboss2768);
Npc.tbPropBase.new_cangbaotuboss2773.Exp  = GetData(Npc.tbDataTemplet.intensity99, 3500000/20000/4);
Npc.tbPropBase.new_cangbaotuboss2773.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 3500000/20000*Npc.IVER_CangBaoTuNpcStrong);--3500000*Npc.IVER_CangBaoTuNpcStrong;
-------------------------------------藏宝图副本改造_end-------------------------------------
--勾魂玉召唤的金系boss血量降低
Npc.tbPropBase.worldboss1_call_jin = Lib:CopyTB1(Npc.tbPropBase.worldboss1_call);
Npc.tbPropBase.worldboss1_call_jin.Life = {{1,160*0.9*0.7*0.33},{55,7125000*0.9*0.7*0.33},{100,21930000*0.9*0.7*0.33},};
--宋金战场大营光环npc
Npc.tbPropBase.battlefieldaura = Lib:CopyTB1(Npc.tbPropBase.intensity0);
Npc.tbPropBase.battlefieldaura.AuraSkillId = 1154;
Npc.tbPropBase.battlefieldaura.AuraSkillLevel = 1;
--天牢boss
Npc.tbPropBase.tianlaoboss = Lib:CopyTB1(Npc.tbPropBase.intensity10);
Npc.tbPropBase.tianlaoboss.LifeReplenish = 9999999;
Npc.tbPropBase.tianlaoboss.PasstSkillId	= 1111;
Npc.tbPropBase.tianlaoboss.PasstSkillLevel	= 10;
Npc.tbPropBase.tianlaoboss.PasstSkillId1	= 2219;
Npc.tbPropBase.tianlaoboss.PasstSkillLevel1	= 10;

---100级任务
Npc.tbPropBase.task6_rebound = Lib:CopyTB1(Npc.tbPropBase.intensity6);
Npc.tbPropBase.task6_rebound.AuraSkillId = 1158;
Npc.tbPropBase.task6_rebound.AuraSkillLevel = 1;--1级10%反弹

Npc.tbPropBase.task6_poison = Lib:CopyTB1(Npc.tbPropBase.intensity6);
Npc.tbPropBase.task6_poison.AuraSkillId = 1159;--npc无形蛊,无特效
Npc.tbPropBase.task6_poison.AuraSkillLevel = 1;

Npc.tbPropBase.task8_poison = Lib:CopyTB1(Npc.tbPropBase.intensity8);
Npc.tbPropBase.task8_poison.PhysicalDamageBase	= GetAtack(Npc.tbDamage.fellow3, 1);
Npc.tbPropBase.task8_poison.PoisonDamageBase	= GetAtack(Npc.tbDamage.fellow3, 2);
Npc.tbPropBase.task8_poison.ColdDamageBase		= GetAtack(Npc.tbDamage.fellow3, 3);
Npc.tbPropBase.task8_poison.FireDamageBase		= GetAtack(Npc.tbDamage.fellow3, 4);
Npc.tbPropBase.task8_poison.LightingDamageBase	= GetAtack(Npc.tbDamage.fellow3, 5);
Npc.tbPropBase.task8_poison.PhysicalMagicBase	= GetAtack(Npc.tbDamage.fellow3, 1);
Npc.tbPropBase.task8_poison.PoisonMagicBase		= GetAtack(Npc.tbDamage.fellow3, 2);
Npc.tbPropBase.task8_poison.ColdMagicBase		= GetAtack(Npc.tbDamage.fellow3, 3);
Npc.tbPropBase.task8_poison.FireMagicBase		= GetAtack(Npc.tbDamage.fellow3, 4);
Npc.tbPropBase.task8_poison.LightingMagicBase	= GetAtack(Npc.tbDamage.fellow3, 5);
Npc.tbPropBase.task8_poison.AuraSkillId = 1159;
Npc.tbPropBase.task8_poison.AuraSkillLevel = 1;

Npc.tbPropBase.task2_hide = Lib:CopyTB1(Npc.tbPropBase.intensity2);
Npc.tbPropBase.task2_hide.PasstSkillId = 1157;
Npc.tbPropBase.task2_hide.PasstSkillLevel = 10;

Npc.tbPropBase.task7_cure = Lib:CopyTB1(Npc.tbPropBase.intensity7);
Npc.tbPropBase.task7_cure.AuraSkillId = 1018;
Npc.tbPropBase.task7_cure.AuraSkillLevel = 1;

Npc.tbPropBase.task7_cri = Lib:CopyTB1(Npc.tbPropBase.intensity7);
Npc.tbPropBase.task7_cri.AuraSkillId = 201;
Npc.tbPropBase.task7_cri.AuraSkillLevel = 10;

--新年活动:打雪仗变身后强度
Npc.tbPropBase.snowballchild = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.snowballchild.Life = 100000;

--新年活动:打雪仗用可攻击玩家但不能被攻击的npc
Npc.tbPropBase.snowballtusha = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.snowballtusha.Life = 100000;
Npc.tbPropBase.snowballtusha.PasstSkillId = 1475;
Npc.tbPropBase.snowballtusha.PasstSkillLevel = 10;

--新年活动:年兽
Npc.tbPropBase.newyearmonster = Lib:CopyTB1(Npc.tbPropBase.wanted);

-- 师徒任务
Npc.tbPropBase.shitu01 = Lib:CopyTB1(Npc.tbPropBase.intensity5);
Npc.tbPropBase.shitu01.AR = {{1,30},{10,300},{100,3000},};
Npc.tbPropBase.shitu01.Defense = {{1,10},{10,100},{100,1000},};
Npc.tbPropBase.shitu01.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 2.5);

---------------------领土争夺战-----------------------------
--反扑将领
Npc.tbPropBase.dispute_general_kickback				= Lib:CopyTB1(Npc.tbPropBase.dispute_general);
Npc.tbPropBase.dispute_general_kickback.PhysicalDamageBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.405);
Npc.tbPropBase.dispute_general_kickback.PoisonDamageBase	= GetAtack(Npc.tbDamage.domainatk, 2, 0.405);
Npc.tbPropBase.dispute_general_kickback.ColdDamageBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.405);
Npc.tbPropBase.dispute_general_kickback.FireDamageBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.405);
Npc.tbPropBase.dispute_general_kickback.LightingDamageBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.405);
Npc.tbPropBase.dispute_general_kickback.PhysicalMagicBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.405);
Npc.tbPropBase.dispute_general_kickback.PoisonMagicBase		= GetAtack(Npc.tbDamage.domainatk, 2, 0.405);
Npc.tbPropBase.dispute_general_kickback.ColdMagicBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.405);
Npc.tbPropBase.dispute_general_kickback.FireMagicBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.405);
Npc.tbPropBase.dispute_general_kickback.LightingMagicBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.405);
--反扑士兵
Npc.tbPropBase.dispute_soldier_kickback				= Lib:CopyTB1(Npc.tbPropBase.dispute_soldier);
Npc.tbPropBase.dispute_soldier_kickback.PhysicalDamageBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.PoisonDamageBase	= GetAtack(Npc.tbDamage.domainatk, 2, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.ColdDamageBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.FireDamageBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.LightingDamageBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.PhysicalMagicBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.PoisonMagicBase		= GetAtack(Npc.tbDamage.domainatk, 2, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.ColdMagicBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.FireMagicBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.25);
Npc.tbPropBase.dispute_soldier_kickback.LightingMagicBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.25);

--新手村元帅
Npc.tbPropBase.dispute_boss_dorp				= Lib:CopyTB1(Npc.tbPropBase.dispute_boss);
--新手村将领
Npc.tbPropBase.dispute_general_dorp				= Lib:CopyTB1(Npc.tbPropBase.dispute_general);
Npc.tbPropBase.dispute_general_dorp.PhysicalDamageBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.28);
Npc.tbPropBase.dispute_general_dorp.PoisonDamageBase	= GetAtack(Npc.tbDamage.domainatk, 2, 0.28);
Npc.tbPropBase.dispute_general_dorp.ColdDamageBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.28);
Npc.tbPropBase.dispute_general_dorp.FireDamageBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.28);
Npc.tbPropBase.dispute_general_dorp.LightingDamageBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.28);
Npc.tbPropBase.dispute_general_dorp.PhysicalMagicBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.28);
Npc.tbPropBase.dispute_general_dorp.PoisonMagicBase		= GetAtack(Npc.tbDamage.domainatk, 2, 0.28);
Npc.tbPropBase.dispute_general_dorp.ColdMagicBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.28);
Npc.tbPropBase.dispute_general_dorp.FireMagicBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.28);
Npc.tbPropBase.dispute_general_dorp.LightingMagicBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.28);
--新手村士兵
Npc.tbPropBase.dispute_soldier_dorp				= Lib:CopyTB1(Npc.tbPropBase.dispute_soldier);
Npc.tbPropBase.dispute_soldier_dorp.PhysicalDamageBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.PoisonDamageBase	= GetAtack(Npc.tbDamage.domainatk, 2, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.ColdDamageBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.FireDamageBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.LightingDamageBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.PhysicalMagicBase	= GetAtack(Npc.tbDamage.domainatk, 1, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.PoisonMagicBase		= GetAtack(Npc.tbDamage.domainatk, 2, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.ColdMagicBase		= GetAtack(Npc.tbDamage.domainatk, 3, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.FireMagicBase		= GetAtack(Npc.tbDamage.domainatk, 4, 0.175);
Npc.tbPropBase.dispute_soldier_dorp.LightingMagicBase	= GetAtack(Npc.tbDamage.domainatk, 5, 0.175);
--0级主城龙柱
Npc.tbPropBase.dispute_pillar0					= Lib:CopyTB1(Npc.tbPropBase.dispute_pillar);
--1级主城龙柱
Npc.tbPropBase.dispute_pillar1					= Lib:CopyTB1(Npc.tbPropBase.dispute_pillar);
Npc.tbPropBase.dispute_pillar1.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 400);
--2级主城龙柱
Npc.tbPropBase.dispute_pillar2					= Lib:CopyTB1(Npc.tbPropBase.dispute_pillar);
Npc.tbPropBase.dispute_pillar2.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 420*1.2);
--3级主城龙柱
Npc.tbPropBase.dispute_pillar3					= Lib:CopyTB1(Npc.tbPropBase.dispute_pillar);
Npc.tbPropBase.dispute_pillar3.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 420*1.3);
Npc.tbPropBase.dispute_pillar3.LifeReplenish	= GetData(Npc.tbDataTemplet.intensity99_Life, 420*1.3*0.01*0.25);
--4级主城龙柱
Npc.tbPropBase.dispute_pillar4					= Lib:CopyTB1(Npc.tbPropBase.dispute_pillar);
Npc.tbPropBase.dispute_pillar4.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 420*1.5);
Npc.tbPropBase.dispute_pillar4.LifeReplenish	= GetData(Npc.tbDataTemplet.intensity99_Life, 420*1.5*0.01*0.5);

--雕像
Npc.tbPropBase.effigy					= Lib:CopyTB1(Npc.tbPropBase.dispute_pillar);
Npc.tbPropBase.effigy.AuraSkillId		= {{100,0},{120,1165},{150,1164}};
Npc.tbPropBase.effigy.AuraSkillLevel	= 1;
----------秦始皇陵---------

--秦始皇陵2层小兵
Npc.tbPropBase.bmy_soldier2				= Lib:CopyTB1(Npc.tbPropBase.bmy_soldier1);
Npc.tbPropBase.bmy_soldier2.Life				= 845440;
Npc.tbPropBase.bmy_soldier2.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier2, 1, 0.8);
Npc.tbPropBase.bmy_soldier2.PoisonDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier2, 2, 0.8);
Npc.tbPropBase.bmy_soldier2.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier2, 3, 0.8);
Npc.tbPropBase.bmy_soldier2.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier2, 4, 0.8);
Npc.tbPropBase.bmy_soldier2.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier2, 5, 0.8);
Npc.tbPropBase.bmy_soldier2.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier2, 1, 0.8);
Npc.tbPropBase.bmy_soldier2.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier2, 2, 0.8);
Npc.tbPropBase.bmy_soldier2.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier2, 3, 0.8);
Npc.tbPropBase.bmy_soldier2.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier2, 4, 0.8);
Npc.tbPropBase.bmy_soldier2.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier2, 5, 0.8);
--秦始皇陵2层头领
Npc.tbPropBase.bmy_leader2				= Lib:CopyTB1(Npc.tbPropBase.bmy_leader1);
Npc.tbPropBase.bmy_leader2.Life					= 845440;
Npc.tbPropBase.bmy_leader2.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_leader2, 1, 0.8);
Npc.tbPropBase.bmy_leader2.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_leader2, 2, 0.8);
Npc.tbPropBase.bmy_leader2.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_leader2, 3, 0.8);
Npc.tbPropBase.bmy_leader2.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_leader2, 4, 0.8);
Npc.tbPropBase.bmy_leader2.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_leader2, 5, 0.8);
Npc.tbPropBase.bmy_leader2.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_leader2, 1, 0.8);
Npc.tbPropBase.bmy_leader2.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_leader2, 2, 0.8);
Npc.tbPropBase.bmy_leader2.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_leader2, 3, 0.8);
Npc.tbPropBase.bmy_leader2.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_leader2, 4, 0.8);
Npc.tbPropBase.bmy_leader2.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_leader2, 5, 0.8);
--秦始皇陵2层精英
Npc.tbPropBase.bmy_elite2				= Lib:CopyTB1(Npc.tbPropBase.bmy_elite1);
Npc.tbPropBase.bmy_elite2.Life					= 1710362;
Npc.tbPropBase.bmy_elite2.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_elite2, 1, 0.8);
Npc.tbPropBase.bmy_elite2.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_elite2, 2, 0.8);
Npc.tbPropBase.bmy_elite2.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_elite2, 3, 0.8);
Npc.tbPropBase.bmy_elite2.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_elite2, 4, 0.8);
Npc.tbPropBase.bmy_elite2.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_elite2, 5, 0.8);
Npc.tbPropBase.bmy_elite2.PhysicalMagicBase		= GetAtack(Npc.tbDamage.bmy_elite2, 1, 0.8);
Npc.tbPropBase.bmy_elite2.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_elite2, 2, 0.8);
Npc.tbPropBase.bmy_elite2.ColdMagicBase			= GetAtack(Npc.tbDamage.bmy_elite2, 3, 0.8);
Npc.tbPropBase.bmy_elite2.FireMagicBase			= GetAtack(Npc.tbDamage.bmy_elite2, 4, 0.8);
Npc.tbPropBase.bmy_elite2.LightingMagicBase		= GetAtack(Npc.tbDamage.bmy_elite2, 5, 0.8);

--秦始皇陵3层小兵
Npc.tbPropBase.bmy_soldier3				= Lib:CopyTB1(Npc.tbPropBase.bmy_soldier1);
Npc.tbPropBase.bmy_soldier3.Life				= 1439422;
Npc.tbPropBase.bmy_soldier3.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier3, 1, 0.8);
Npc.tbPropBase.bmy_soldier3.PoisonDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier3, 2, 0.8);
Npc.tbPropBase.bmy_soldier3.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier3, 3, 0.8);
Npc.tbPropBase.bmy_soldier3.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier3, 4, 0.8);
Npc.tbPropBase.bmy_soldier3.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier3, 5, 0.8);
Npc.tbPropBase.bmy_soldier3.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier3, 1, 0.8);
Npc.tbPropBase.bmy_soldier3.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier3, 2, 0.8);
Npc.tbPropBase.bmy_soldier3.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier3, 3, 0.8);
Npc.tbPropBase.bmy_soldier3.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier3, 4, 0.8);
Npc.tbPropBase.bmy_soldier3.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier3, 5, 0.8);
--秦始皇陵3层头领
Npc.tbPropBase.bmy_leader3				= Lib:CopyTB1(Npc.tbPropBase.bmy_leader1);
Npc.tbPropBase.bmy_leader3.Life					= 1439422;
Npc.tbPropBase.bmy_leader3.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_leader3, 1, 0.8);
Npc.tbPropBase.bmy_leader3.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_leader3, 2, 0.8);
Npc.tbPropBase.bmy_leader3.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_leader3, 3, 0.8);
Npc.tbPropBase.bmy_leader3.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_leader3, 4, 0.8);
Npc.tbPropBase.bmy_leader3.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_leader3, 5, 0.8);
Npc.tbPropBase.bmy_leader3.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_leader3, 1, 0.8);
Npc.tbPropBase.bmy_leader3.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_leader3, 2, 0.8);
Npc.tbPropBase.bmy_leader3.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_leader3, 3, 0.8);
Npc.tbPropBase.bmy_leader3.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_leader3, 4, 0.8);
Npc.tbPropBase.bmy_leader3.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_leader3, 5, 0.8);
--秦始皇陵3层精英
Npc.tbPropBase.bmy_elite3				= Lib:CopyTB1(Npc.tbPropBase.bmy_elite1);
Npc.tbPropBase.bmy_elite3.Life					= 1710362;
Npc.tbPropBase.bmy_elite3.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_elite3, 1, 0.8);
Npc.tbPropBase.bmy_elite3.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_elite3, 2, 0.8);
Npc.tbPropBase.bmy_elite3.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_elite3, 3, 0.8);
Npc.tbPropBase.bmy_elite3.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_elite3, 4, 0.8);
Npc.tbPropBase.bmy_elite3.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_elite3, 5, 0.8);
Npc.tbPropBase.bmy_elite3.PhysicalMagicBase		= GetAtack(Npc.tbDamage.bmy_elite3, 1, 0.8);
Npc.tbPropBase.bmy_elite3.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_elite3, 2, 0.8);
Npc.tbPropBase.bmy_elite3.ColdMagicBase			= GetAtack(Npc.tbDamage.bmy_elite3, 3, 0.8);
Npc.tbPropBase.bmy_elite3.FireMagicBase			= GetAtack(Npc.tbDamage.bmy_elite3, 4, 0.8);
Npc.tbPropBase.bmy_elite3.LightingMagicBase		= GetAtack(Npc.tbDamage.bmy_elite3, 5, 0.8);

--秦始皇陵4层小兵
Npc.tbPropBase.bmy_soldier4				= Lib:CopyTB1(Npc.tbPropBase.bmy_soldier1);
Npc.tbPropBase.bmy_soldier4.Exp					= 25000;
Npc.tbPropBase.bmy_soldier4.Life				= 1797003;
Npc.tbPropBase.bmy_soldier4.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier4, 1, 0.8);
Npc.tbPropBase.bmy_soldier4.PoisonDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier4, 2, 0.8);
Npc.tbPropBase.bmy_soldier4.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier4, 3, 0.8);
Npc.tbPropBase.bmy_soldier4.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_soldier4, 4, 0.8);
Npc.tbPropBase.bmy_soldier4.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_soldier4, 5, 0.8);
Npc.tbPropBase.bmy_soldier4.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier4, 1, 0.8);
Npc.tbPropBase.bmy_soldier4.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier4, 2, 0.8);
Npc.tbPropBase.bmy_soldier4.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier4, 3, 0.8);
Npc.tbPropBase.bmy_soldier4.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_soldier4, 4, 0.8);
Npc.tbPropBase.bmy_soldier4.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_soldier4, 5, 0.8);
--秦始皇陵4层头领
Npc.tbPropBase.bmy_leader4				= Lib:CopyTB1(Npc.tbPropBase.bmy_leader1);
Npc.tbPropBase.bmy_leader4.Exp					= 50000;
Npc.tbPropBase.bmy_leader4.Life					= 1797003;
Npc.tbPropBase.bmy_leader4.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_leader4, 1, 0.8);
Npc.tbPropBase.bmy_leader4.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_leader4, 2, 0.8);
Npc.tbPropBase.bmy_leader4.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_leader4, 3, 0.8);
Npc.tbPropBase.bmy_leader4.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_leader4, 4, 0.8);
Npc.tbPropBase.bmy_leader4.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_leader4, 5, 0.8);
Npc.tbPropBase.bmy_leader4.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_leader4, 1, 0.8);
Npc.tbPropBase.bmy_leader4.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_leader4, 2, 0.8);
Npc.tbPropBase.bmy_leader4.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_leader4, 3, 0.8);
Npc.tbPropBase.bmy_leader4.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_leader4, 4, 0.8);
Npc.tbPropBase.bmy_leader4.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_leader4, 5, 0.8);
--秦始皇陵4层精英
Npc.tbPropBase.bmy_elite4				= Lib:CopyTB1(Npc.tbPropBase.bmy_elite1);
Npc.tbPropBase.bmy_elite4.Exp					= 50000*1.25;
Npc.tbPropBase.bmy_elite4.Life					= 2736580;
Npc.tbPropBase.bmy_elite4.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_elite4, 1, 0.8);
Npc.tbPropBase.bmy_elite4.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_elite4, 2, 0.8);
Npc.tbPropBase.bmy_elite4.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_elite4, 3, 0.8);
Npc.tbPropBase.bmy_elite4.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_elite4, 4, 0.8);
Npc.tbPropBase.bmy_elite4.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_elite4, 5, 0.8);
Npc.tbPropBase.bmy_elite4.PhysicalMagicBase		= GetAtack(Npc.tbDamage.bmy_elite4, 1, 0.8);
Npc.tbPropBase.bmy_elite4.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_elite4, 2, 0.8);
Npc.tbPropBase.bmy_elite4.ColdMagicBase			= GetAtack(Npc.tbDamage.bmy_elite4, 3, 0.8);
Npc.tbPropBase.bmy_elite4.FireMagicBase			= GetAtack(Npc.tbDamage.bmy_elite4, 4, 0.8);
Npc.tbPropBase.bmy_elite4.LightingMagicBase		= GetAtack(Npc.tbDamage.bmy_elite4, 5, 0.8);

--秦始皇召唤的兵马俑boss
Npc.tbPropBase.bmy_fellow1				= Lib:CopyTB1(Npc.tbPropBase.bmy_leader4);
Npc.tbPropBase.bmy_fellow1.Exp					= 0;
Npc.tbPropBase.bmy_fellow1.Life					= 3612840;
Npc.tbPropBase.bmy_fellow1.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_fellow1,1);
Npc.tbPropBase.bmy_fellow1.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_fellow1,2);
Npc.tbPropBase.bmy_fellow1.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_fellow1,3);
Npc.tbPropBase.bmy_fellow1.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_fellow1,4);
Npc.tbPropBase.bmy_fellow1.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_fellow1,5);
Npc.tbPropBase.bmy_fellow1.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_fellow1,1);
Npc.tbPropBase.bmy_fellow1.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_fellow1,2);
Npc.tbPropBase.bmy_fellow1.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_fellow1,3);
Npc.tbPropBase.bmy_fellow1.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_fellow1,4);
Npc.tbPropBase.bmy_fellow1.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_fellow1,5);
Npc.tbPropBase.bmy_fellow1.AuraSkillId			= 594;
Npc.tbPropBase.bmy_fellow1.AuraSkillLevel		= 1;
--秦始皇召唤的招魂师boss
Npc.tbPropBase.bmy_fellow2				= Lib:CopyTB1(Npc.tbPropBase.bmy_leader4);
Npc.tbPropBase.bmy_fellow2.Exp					= 0;
Npc.tbPropBase.bmy_fellow2.Life					= 2408560;
Npc.tbPropBase.bmy_fellow2.PhysicalDamageBase	= GetAtack(Npc.tbDamage.bmy_fellow2,1);
Npc.tbPropBase.bmy_fellow2.PoisonDamageBase		= GetAtack(Npc.tbDamage.bmy_fellow2,2);
Npc.tbPropBase.bmy_fellow2.ColdDamageBase		= GetAtack(Npc.tbDamage.bmy_fellow2,3);
Npc.tbPropBase.bmy_fellow2.FireDamageBase		= GetAtack(Npc.tbDamage.bmy_fellow2,4);
Npc.tbPropBase.bmy_fellow2.LightingDamageBase	= GetAtack(Npc.tbDamage.bmy_fellow2,5);
Npc.tbPropBase.bmy_fellow2.PhysicalMagicBase	= GetAtack(Npc.tbDamage.bmy_fellow2,1);
Npc.tbPropBase.bmy_fellow2.PoisonMagicBase		= GetAtack(Npc.tbDamage.bmy_fellow2,2);
Npc.tbPropBase.bmy_fellow2.ColdMagicBase		= GetAtack(Npc.tbDamage.bmy_fellow2,3);
Npc.tbPropBase.bmy_fellow2.FireMagicBase		= GetAtack(Npc.tbDamage.bmy_fellow2,4);
Npc.tbPropBase.bmy_fellow2.LightingMagicBase	= GetAtack(Npc.tbDamage.bmy_fellow2,5);
Npc.tbPropBase.bmy_fellow2.AuraSkillId			= 594;
Npc.tbPropBase.bmy_fellow2.AuraSkillLevel		= 1;

-----------------师徒副本-----------------------
Npc.tbPropBase.shitu2459					= Lib:CopyTB1(Npc.tbPropBase.intensity99);
Npc.tbPropBase.shitu2459.Exp				= 0;
Npc.tbPropBase.shitu2459.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 16);
Npc.tbPropBase.shitu2459.LifeReplenish		= 0;
Npc.tbPropBase.shitu2459.PhysicalDamageBase	= GetAtack(Npc.tbDamage.intensity0, 1, 2);
Npc.tbPropBase.shitu2459.PoisonDamageBase	= GetAtack(Npc.tbDamage.intensity0, 2, 2);
Npc.tbPropBase.shitu2459.ColdDamageBase		= GetAtack(Npc.tbDamage.intensity0, 3, 2);
Npc.tbPropBase.shitu2459.FireDamageBase		= GetAtack(Npc.tbDamage.intensity0, 4, 2);
Npc.tbPropBase.shitu2459.LightingDamageBase	= GetAtack(Npc.tbDamage.intensity0, 5, 2);
Npc.tbPropBase.shitu2459.PhysicalMagicBase	= GetAtack(Npc.tbDamage.intensity0, 1, 2);
Npc.tbPropBase.shitu2459.PoisonMagicBase	= GetAtack(Npc.tbDamage.intensity0, 2, 2);
Npc.tbPropBase.shitu2459.ColdMagicBase		= GetAtack(Npc.tbDamage.intensity0, 3, 2);
Npc.tbPropBase.shitu2459.FireMagicBase		= GetAtack(Npc.tbDamage.intensity0, 4, 2);
Npc.tbPropBase.shitu2459.LightingMagicBase	= GetAtack(Npc.tbDamage.intensity0, 5, 2);

Npc.tbPropBase.shitu2460					= Lib:CopyTB1(Npc.tbPropBase.shitu2459);
Npc.tbPropBase.shitu2460.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 80);
Npc.tbPropBase.shitu2460.PasstSkillId		= 1480;
Npc.tbPropBase.shitu2460.PasstSkillLevel	= 20;

Npc.tbPropBase.shitu2462					= Lib:CopyTB1(Npc.tbPropBase.shitu2459);
Npc.tbPropBase.shitu2462.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 27);

Npc.tbPropBase.shitu2461					= Lib:CopyTB1(Npc.tbPropBase.shitu2459);
Npc.tbPropBase.shitu2461.Life				= GetData(Npc.tbDamage.intensity0[1], 6*20);
Npc.tbPropBase.shitu2461.PhysicalDamageBase	= 0;
Npc.tbPropBase.shitu2461.PoisonDamageBase	= 0;
Npc.tbPropBase.shitu2461.ColdDamageBase		= 0;
Npc.tbPropBase.shitu2461.FireDamageBase		= 0;
Npc.tbPropBase.shitu2461.LightingDamageBase	= 0;
Npc.tbPropBase.shitu2461.PhysicalMagicBase	= 0;
Npc.tbPropBase.shitu2461.PoisonMagicBase	= 0;
Npc.tbPropBase.shitu2461.ColdMagicBase		= 0;
Npc.tbPropBase.shitu2461.FireMagicBase		= 0;
Npc.tbPropBase.shitu2461.LightingMagicBase	= 0;

Npc.tbPropBase.shitu2464					= Lib:CopyTB1(Npc.tbPropBase.shitu2459);
Npc.tbPropBase.shitu2464.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 150*3);
Npc.tbPropBase.shitu2464.AuraSkillId		= 594;
Npc.tbPropBase.shitu2464.AuraSkillLevel		= 1;

Npc.tbPropBase.shitu2465					= Lib:CopyTB1(Npc.tbPropBase.shitu2464);
Npc.tbPropBase.shitu2465.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 150*2);

Npc.tbPropBase.shitu2467					= Lib:CopyTB1(Npc.tbPropBase.shitu2464);
Npc.tbPropBase.shitu2467.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 150*3.5);

Npc.tbPropBase.shitu2468					= Lib:CopyTB1(Npc.tbPropBase.shitu2461);
Npc.tbPropBase.shitu2468.PasstSkillId		= 1480;--免疫各种攻击
Npc.tbPropBase.shitu2468.PasstSkillLevel	= 20;

----七夕活动织女光环
Npc.tbPropBase.zhinv_7xi					= Lib:CopyTB1(Npc.tbPropBase.intensity3);
Npc.tbPropBase.zhinv_7xi.AuraSkillId		= 1630;
Npc.tbPropBase.zhinv_7xi.AuraSkillLevel		= 1;

----掌毒120技能npc
Npc.tbPropBase.zhangdu120					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.zhangdu120.Life				= GetData(Npc.tbDataTemplet.zhangdu120_Life);

Npc.tbPropBase.worldboss95_vn					= Lib:CopyTB1(Npc.tbPropBase.worldboss1);
Npc.tbPropBase.worldboss95_vn.Life					= {{1,160*0.9*2},{55,7125000*0.9*2},{100,21930000*0.9*2},};
Npc.tbPropBase.worldboss95_vn.PhysicalDamageBase	= GetAtack(Npc.tbDamage.boss1, 1, 1.2);
Npc.tbPropBase.worldboss95_vn.PoisonDamageBase		= GetAtack(Npc.tbDamage.boss1, 2, 1.2);
Npc.tbPropBase.worldboss95_vn.ColdDamageBase		= GetAtack(Npc.tbDamage.boss1, 3, 1.2);
Npc.tbPropBase.worldboss95_vn.FireDamageBase		= GetAtack(Npc.tbDamage.boss1, 4, 1.2);
Npc.tbPropBase.worldboss95_vn.LightingDamageBase	= GetAtack(Npc.tbDamage.boss1, 5, 1.2);
Npc.tbPropBase.worldboss95_vn.PhysicalMagicBase		= GetAtack(Npc.tbDamage.boss1, 1, 1.2);
Npc.tbPropBase.worldboss95_vn.PoisonMagicBase		= GetAtack(Npc.tbDamage.boss1, 2, 1.2);
Npc.tbPropBase.worldboss95_vn.ColdMagicBase			= GetAtack(Npc.tbDamage.boss1, 3, 1.2);
Npc.tbPropBase.worldboss95_vn.FireMagicBase			= GetAtack(Npc.tbDamage.boss1, 4, 1.2);
Npc.tbPropBase.worldboss95_vn.LightingMagicBase		= GetAtack(Npc.tbDamage.boss1, 5, 1.2);
-----------逍遥谷地狱难度--------------
--无敌npc,装子弹用的
Npc.tbPropBase.hellxoyo7304 = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.hellxoyo7304.Life = 100000000;
Npc.tbPropBase.hellxoyo7304.PhysicalDamageBase	= 600;
Npc.tbPropBase.hellxoyo7304.PoisonDamageBase	= 600/2;
Npc.tbPropBase.hellxoyo7304.ColdDamageBase		= 600;
Npc.tbPropBase.hellxoyo7304.FireDamageBase		= 600;
Npc.tbPropBase.hellxoyo7304.LightingDamageBase	= 600;
Npc.tbPropBase.hellxoyo7304.PhysicalMagicBase	= 600;
Npc.tbPropBase.hellxoyo7304.PoisonMagicBase		= 600/2;
Npc.tbPropBase.hellxoyo7304.ColdMagicBase		= 600;
Npc.tbPropBase.hellxoyo7304.FireMagicBase		= 600;
Npc.tbPropBase.hellxoyo7304.LightingMagicBase	= 600;
Npc.tbPropBase.hellxoyo7304.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7304.AuraSkillLevel		= 1;
Npc.tbPropBase.hellxoyo7304.PasstSkillId 		= 1853;--自动对周围敌人造成伤害
Npc.tbPropBase.hellxoyo7304.PasstSkillLevel 	= 4;

Npc.tbPropBase.hellxoyo7330 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo7304);
Npc.tbPropBase.hellxoyo7330.Life = GetData(Npc.tbDataTemplet.BaseLife_new, 6*6*0.6);
Npc.tbPropBase.hellxoyo7330.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7330.AuraSkillLevel		= 1;
Npc.tbPropBase.hellxoyo7330.PasstSkillId 		= 1854;--自动定身周围的敌人并造成伤害
Npc.tbPropBase.hellxoyo7330.PasstSkillLevel 	= 10;

Npc.tbPropBase.hellxoyo7350 = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.hellxoyo7350.Life = 9000000;
Npc.tbPropBase.hellxoyo7350.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7350.AuraSkillLevel		= 1;
--铜花,释放技能用npc
Npc.tbPropBase.hellxoyo7331 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo7304);
Npc.tbPropBase.hellxoyo7331.PasstSkillId 		= 1475;--不能被攻击
Npc.tbPropBase.hellxoyo7331.PasstSkillLevel 	= 1;

Npc.tbPropBase.hellxoyo7388 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo7331);
Npc.tbPropBase.hellxoyo7388.PasstSkillId 		= 1853;--不能被攻击并对周围伤害
Npc.tbPropBase.hellxoyo7388.PasstSkillLevel 	= 3;

Npc.tbPropBase.hellxoyo6737 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo6735);
Npc.tbPropBase.hellxoyo6737.AuraSkillId			= 2043;--无影毒+免疫光环
Npc.tbPropBase.hellxoyo6737.AuraSkillLevel		= 2;

Npc.tbPropBase.hellxoyo6738 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo6735);
Npc.tbPropBase.hellxoyo6738.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*60*6*0.9*0.8);
Npc.tbPropBase.hellxoyo6738.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo6738.AuraSkillLevel		= 1;

Npc.tbPropBase.hellxoyo7332 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo6735);
Npc.tbPropBase.hellxoyo7332.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7332.AuraSkillLevel		= 1;

Npc.tbPropBase.hellxoyo7351 = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.hellxoyo7351.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife, 50*0.6*0.1);
Npc.tbPropBase.hellxoyo7351.tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.1};
Npc.tbPropBase.hellxoyo7351.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7351.AuraSkillLevel		= 1;

Npc.tbPropBase.hellxoyo_liuyuning = Lib:CopyTB1(Npc.tbPropBase.hellxoyo_lixin);
Npc.tbPropBase.hellxoyo_liuyuning.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo_liuyuning.AuraSkillLevel		= 1;

Npc.tbPropBase.hellxoyo_yaya = Lib:CopyTB1(Npc.tbPropBase.hellxoyo_lixin);
Npc.tbPropBase.hellxoyo_yaya.tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 2};
Npc.tbPropBase.hellxoyo_yaya.AuraSkillId		= 594;--免疫光环
Npc.tbPropBase.hellxoyo_yaya.AuraSkillLevel		= 1;
Npc.tbPropBase.hellxoyo_yaya.PasstSkillId 		= 1475;--不能被攻击
Npc.tbPropBase.hellxoyo_yaya.PasstSkillLevel 	= 1;

Npc.tbPropBase.hellxoyo_shijing = Lib:CopyTB1(Npc.tbPropBase.hellxoyo_lixin);
Npc.tbPropBase.hellxoyo_shijing.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo_shijing.AuraSkillLevel		= 1;

Npc.tbPropBase.hellxoyo7342 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo7304);
Npc.tbPropBase.hellxoyo7342.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife, 6*9*0.6);
Npc.tbPropBase.hellxoyo7342.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7342.AuraSkillLevel		= 1;
Npc.tbPropBase.hellxoyo7342.PasstSkillId 		= 1854;--定身
Npc.tbPropBase.hellxoyo7342.PasstSkillLevel 	= 1;

Npc.tbPropBase.hellxoyo7345 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo7304);
Npc.tbPropBase.hellxoyo7345.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife, 6*9*0.6);
Npc.tbPropBase.hellxoyo7345.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7345.AuraSkillLevel		= 1;
Npc.tbPropBase.hellxoyo7345.PasstSkillId 		= 0;
Npc.tbPropBase.hellxoyo7345.PasstSkillLevel 	= 0;

Npc.tbPropBase.hellxoyo7337 = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.hellxoyo7337.Life = GetData(Npc.tbDataTemplet.XoyoBaseLife, 6*10);
Npc.tbPropBase.hellxoyo7337.tbAtkBase			= {GetAtack, Npc.tbDamage.fellow3, 0.65};
Npc.tbPropBase.hellxoyo7337.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo7337.AuraSkillLevel		= 1;
Npc.tbPropBase.hellxoyo7337.PasstSkillId 		= 2127;--npc变色
Npc.tbPropBase.hellxoyo7337.PasstSkillLevel 	= 1;

Npc.tbPropBase.hellxoyo_yexuan = Lib:CopyTB1(Npc.tbPropBase.hellxoyo_yejing);
Npc.tbPropBase.hellxoyo_yexuan.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo_yexuan.AuraSkillLevel		= 1;

Npc.tbPropBase.hellxoyo_baiqiulin = Lib:CopyTB1(Npc.tbPropBase.hellxoyo_yejing);
Npc.tbPropBase.hellxoyo_baiqiulin.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo_baiqiulin.AuraSkillLevel		= 1;

Npc.tbPropBase.hellxoyo_baiqiulin2 = Lib:CopyTB1(Npc.tbPropBase.hellxoyo_yejing);
Npc.tbPropBase.hellxoyo_baiqiulin2.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.hellxoyo_baiqiulin2.AuraSkillLevel		= 1;
Npc.tbPropBase.hellxoyo_baiqiulin2.PasstSkillId 		= 2158;--npc冰冻
Npc.tbPropBase.hellxoyo_baiqiulin2.PasstSkillLevel 	= 1;

Npc.tbPropBase.hellxoyo6757 = Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.hellxoyo6757.Life = 100000000;
---------------------军营调整--------------------
--7312,白无为
Npc.tbPropBase.npc7312 = Lib:CopyTB1(Npc.tbPropBase.npc4002);
Npc.tbPropBase.npc7312.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 279*2);

--7314,白素素
Npc.tbPropBase.npc7314 = Lib:CopyTB1(Npc.tbPropBase.npc4002);
Npc.tbPropBase.npc7314.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 279*2);
--7315,欧阳紫嫣
Npc.tbPropBase.npc7315 = Lib:CopyTB1(Npc.tbPropBase.npc4002);
Npc.tbPropBase.npc7315.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 300);
Npc.tbPropBase.npc7315.tbAtkBase	= {GetAtack, Npc.tbDamage.fellow3, 0.6};
--7316,欧阳梅
Npc.tbPropBase.npc7316 = Lib:CopyTB1(Npc.tbPropBase.npc4002);
Npc.tbPropBase.npc7316.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 300);
Npc.tbPropBase.npc7316.tbAtkBase	= {GetAtack, Npc.tbDamage.fellow3, 0.4};
--7320,慕容复
Npc.tbPropBase.npc7320 = Lib:CopyTB1(Npc.tbPropBase.npc7316);
Npc.tbPropBase.npc7320.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 150);
Npc.tbPropBase.npc7320.tbAtkBase	= {GetAtack, Npc.tbDamage.fellow3, 0.3};

--7318,混天豹
Npc.tbPropBase.npc7318 = Lib:CopyTB1(Npc.tbPropBase.npc4002);
Npc.tbPropBase.npc7318.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 279*2.6);

--7317,大力神,混天虎,幽冥神兽
Npc.tbPropBase.npc7317 = Lib:CopyTB1(Npc.tbPropBase.npc4002);
Npc.tbPropBase.npc7317.Life			= GetData(Npc.tbDataTemplet.intensity99_Life, 279*3);
Npc.tbPropBase.npc7317.tbAtkBase	= {GetAtack, Npc.tbDamage.fellow3, 0.6};

--7328,幽冥神兽分身
Npc.tbPropBase.npc7328 = Lib:CopyTB1(Npc.tbPropBase.npc7317);
Npc.tbPropBase.npc7328.Life			= GetData(Npc.tbDataTemplet.intensity99_Life, 3);
Npc.tbPropBase.npc7328.tbAtkBase	= {GetAtack, Npc.tbDamage.fellow3, 0.6};

--7326,海陵火蛇
Npc.tbPropBase.npc7326 = Lib:CopyTB1(Npc.tbPropBase.npc4002);
Npc.tbPropBase.npc7326.PasstSkillId 	= 1475;--不能被打
Npc.tbPropBase.npc7326.PasstSkillLevel 	= 1;
--7327,火焰花
Npc.tbPropBase.npc7327 = Lib:CopyTB1(Npc.tbPropBase.npc7326);
Npc.tbPropBase.npc7327.PasstSkillId 	= 1934;--自动释放冥火
Npc.tbPropBase.npc7327.PasstSkillLevel 	= 1;

--2倍intensity9血量
Npc.tbPropBase.intensity9_2 = Lib:CopyTB1(Npc.tbPropBase.intensity9);
Npc.tbPropBase.intensity9_2.Life = GetData(Npc.tbDataTemplet.intensity9_Life, 2);

--冰块
Npc.tbPropBase.prop_ice = Lib:CopyTB1(Npc.tbPropBase.intensity1);
Npc.tbPropBase.prop_ice.Life = GetData(Npc.tbDataTemplet.intensity99_Life, 15*5/3);
Npc.tbPropBase.prop_ice.AuraSkillId			= 594;--免疫光环
Npc.tbPropBase.prop_ice.AuraSkillLevel		= 1;
Npc.tbPropBase.prop_ice.PasstSkillId		= 1889;--死亡解除玩家的即死buff
Npc.tbPropBase.prop_ice.PasstSkillLevel		= 4;
--小工匠_不反弹
Npc.tbPropBase.npc7305					= Lib:CopyTB1(Npc.tbPropBase.jy_unreturn);
Npc.tbPropBase.npc7305.Life 			= GetData(Npc.tbDataTemplet.intensity99_Life, 10*4/3);
--工匠头领_反弹
Npc.tbPropBase.npc7306					= Lib:CopyTB1(Npc.tbPropBase.jy_bereturn);

--机关傀儡
Npc.tbPropBase.npc7313					= Lib:CopyTB1(Npc.tbPropBase.npc7305);
Npc.tbPropBase.npc7313.Life				= GetData(Npc.tbDataTemplet.intensity99_Life, 6*20/3);
Npc.tbPropBase.npc7313.tbAtkBase		= {GetAtack,Npc.tbDamage.fellow3, 1};
Npc.tbPropBase.npc7313.AuraSkillId		= 594;
Npc.tbPropBase.npc7313.AuraSkillLevel	= 1;

--海陵王boss血量*2
Npc.tbPropBase.task9_2	= Lib:CopyTB1(Npc.tbPropBase.task9);
Npc.tbPropBase.task9_2.Life = GetData(Npc.tbDataTemplet.intensity9_Life, 1.3*1.5);

--完颜亮
Npc.tbPropBase.npc4184	= Lib:CopyTB1(Npc.tbPropBase.task9_2);
Npc.tbPropBase.npc4184.Life = GetData(Npc.tbDataTemplet.intensity9_Life, 1.3*1.5*3);

--清明节白起
Npc.tbPropBase.qingming_lv3	= Lib:CopyTB1(Npc.tbPropBase.zhaohuanboss5);
Npc.tbPropBase.qingming_lv3.tbAtkBase = 1500;
Npc.tbPropBase.qingming_lv3.AuraSkillId			= 1410;
Npc.tbPropBase.qingming_lv3.AuraSkillLevel		= 1;
Npc.tbPropBase.qingming_lv3.PasstSkillId			= 1407;--提高500%命中
Npc.tbPropBase.qingming_lv3.PasstSkillLevel		= 11;

--清明节秦始皇
Npc.tbPropBase.qingming_lv4	= Lib:CopyTB1(Npc.tbPropBase.zhaohuanboss6);
Npc.tbPropBase.qingming_lv4.tbAtkBase = 1500;
Npc.tbPropBase.qingming_lv4.AuraSkillId			= 1410;
Npc.tbPropBase.qingming_lv4.AuraSkillLevel		= 1;
Npc.tbPropBase.qingming_lv4.PasstSkillId		= 1407;--提高500%命中
Npc.tbPropBase.qingming_lv4.PasstSkillLevel		= 11;
-----------------------------侠客岛------------------------------------
--傲天
Npc.tbPropBase.xiakedao_jinmid	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_jin);
Npc.tbPropBase.xiakedao_jinmid.PasstSkillId			= 1684;
Npc.tbPropBase.xiakedao_jinmid.PasstSkillLevel		= 18;

Npc.tbPropBase.xiakedao_jinsen	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_jin);
Npc.tbPropBase.xiakedao_jinsen.PasstSkillId			= 1684;
Npc.tbPropBase.xiakedao_jinsen.PasstSkillLevel		= 19;
--晨曦
Npc.tbPropBase.xiakedao_mumid	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_mu);
Npc.tbPropBase.xiakedao_mumid.PasstSkillId			= 802;
Npc.tbPropBase.xiakedao_mumid.PasstSkillLevel		= 20;

Npc.tbPropBase.xiakedao_musen	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_mu);
Npc.tbPropBase.xiakedao_musen.PasstSkillId			= 1686;
Npc.tbPropBase.xiakedao_musen.PasstSkillLevel		= 20;
--皓月
Npc.tbPropBase.xiakedao_shuimid	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_shui);
Npc.tbPropBase.xiakedao_shuimid.PasstSkillId			= 802;
Npc.tbPropBase.xiakedao_shuimid.PasstSkillLevel		= 12;

Npc.tbPropBase.xiakedao_shuisen	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_shui);
Npc.tbPropBase.xiakedao_shuisen.PasstSkillId			= 802;
Npc.tbPropBase.xiakedao_shuisen.PasstSkillLevel		= 14;
--焚情
Npc.tbPropBase.xiakedao_huomid	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_huo);
Npc.tbPropBase.xiakedao_huomid.PasstSkillId			= 802;
Npc.tbPropBase.xiakedao_huomid.PasstSkillLevel		= 5;

Npc.tbPropBase.xiakedao_huosen	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_huo);
Npc.tbPropBase.xiakedao_huosen.PasstSkillId			= 1682;
Npc.tbPropBase.xiakedao_huosen.PasstSkillLevel		= 5;
--正阳
Npc.tbPropBase.xiakedao_tumid	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_tu);
Npc.tbPropBase.xiakedao_tumid.PasstSkillId			= 1674;
Npc.tbPropBase.xiakedao_tumid.PasstSkillLevel		= 5;

Npc.tbPropBase.xiakedao_tusen	= Lib:CopyTB1(Npc.tbPropBase.xiakedao_tu);
Npc.tbPropBase.xiakedao_tusen.PasstSkillId			= 1674;
Npc.tbPropBase.xiakedao_tusen.PasstSkillLevel		= 10;
-----------------------高级家族副本--------------------------
--日月岛守护者
Npc.tbPropBase.jiugui					= Lib:CopyTB1(Npc.tbPropBase.wanted);
Npc.tbPropBase.jiugui.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 10*5*2*1.2);
Npc.tbPropBase.jiugui.Exp				= 0;
Npc.tbPropBase.jiugui.Exp				= 0;
Npc.tbPropBase.jiugui.LifeReplenish		= 0;
Npc.tbPropBase.jiugui.tbAtkBase			= 1000;
Npc.tbPropBase.jiugui.AuraSkillId			= 594;
Npc.tbPropBase.jiugui.AuraSkillLevel		= 1;
Npc.tbPropBase.jiugui.PasstSkillId			= 0;
Npc.tbPropBase.jiugui.PasstSkillLevel		= 0;
--酒鬼
Npc.tbPropBase.jiugui2					= Lib:CopyTB1(Npc.tbPropBase.jiugui);
Npc.tbPropBase.jiugui2.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 5);
--采花贼,百草书生,护岛机关人,火种机关人
Npc.tbPropBase.jiugui3					= Lib:CopyTB1(Npc.tbPropBase.jiugui);
Npc.tbPropBase.jiugui3.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 3);
Npc.tbPropBase.jiugui3.AuraSkillId			= 0;
Npc.tbPropBase.jiugui3.AuraSkillLevel		= 0;
--理学卫士
Npc.tbPropBase.lixueweishi					= Lib:CopyTB1(Npc.tbPropBase.jiugui);
Npc.tbPropBase.lixueweishi.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 10);
--逍遥书生
Npc.tbPropBase.xoyoshusheng						= Lib:CopyTB1(Npc.tbPropBase.wanted2);
Npc.tbPropBase.xoyoshusheng.Life						= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*5);
Npc.tbPropBase.xoyoshusheng.Exp					= 0;
Npc.tbPropBase.xoyoshusheng.LifeReplenish		= 0;
Npc.tbPropBase.xoyoshusheng.tbAtkBase			= 2000;
Npc.tbPropBase.xoyoshusheng.tbRisBase	=  {SetResistByRis_p,{0.3,0.4,0.5}};
Npc.tbPropBase.xoyoshusheng.AuraSkillId			= 594;
Npc.tbPropBase.xoyoshusheng.AuraSkillLevel		= 1;
--独孤若兰
Npc.tbPropBase.duguruolan						= Lib:CopyTB1(Npc.tbPropBase.xoyoshusheng);
Npc.tbPropBase.duguruolan.Life						= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*5/2);
Npc.tbPropBase.duguruolan.tbAtkBase				= 2000;
--东郭逸尘
Npc.tbPropBase.dongguoyichen						= Lib:CopyTB1(Npc.tbPropBase.duguruolan);
Npc.tbPropBase.dongguoyichen.Life					= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*5/2*1.2);
--白马俊杰
Npc.tbPropBase.baimajunjie						= Lib:CopyTB1(Npc.tbPropBase.xoyoshusheng);
Npc.tbPropBase.baimajunjie.Life					= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*2.4);
Npc.tbPropBase.baimajunjie.tbAtkBase			= 2100;
--白马yi
Npc.tbPropBase.baimayi						= Lib:CopyTB1(Npc.tbPropBase.xoyoshusheng);
Npc.tbPropBase.baimayi.Life						= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*5/2*1.2);
--司马雁南
Npc.tbPropBase.simayannan						= Lib:CopyTB1(Npc.tbPropBase.wanted2);
Npc.tbPropBase.simayannan.Life						= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*5);
Npc.tbPropBase.simayannan.tbAtkBase			= 2400;
Npc.tbPropBase.simayannan.tbRisBase	=  {SetResistByRis_p,{0.3,0.4,0.5}};
--西门飞雪
Npc.tbPropBase.ximenfeixue					= Lib:CopyTB1(Npc.tbPropBase.xoyoshusheng);
Npc.tbPropBase.ximenfeixue.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*6);
Npc.tbPropBase.ximenfeixue.tbAtkBase		= 2700;
--疯狂儒生
Npc.tbPropBase.fengkuangrusheng				= Lib:CopyTB1(Npc.tbPropBase.jiugui);
Npc.tbPropBase.fengkuangrusheng.Life		= GetData(Npc.tbDataTemplet.intensity99_Life, 10);
Npc.tbPropBase.fengkuangrusheng.tbRisBase	= {SetResistByRis_p,{0.3,0.4,0.5}};
--书童
Npc.tbPropBase.shutong				= Lib:CopyTB1(Npc.tbPropBase.fengkuangrusheng);
Npc.tbPropBase.shutong.tbRisBase	=  {SetResistByRis_p,{0.1,0.3,0.5}};
--伴读郎
Npc.tbPropBase.bandulang			= Lib:CopyTB1(Npc.tbPropBase.fengkuangrusheng);
Npc.tbPropBase.bandulang.tbRisBase	=  {SetResistByRis_p,{0.2,0.3,0.4}};
--假西门飞雪
Npc.tbPropBase.jiaximenfeixue				= Lib:CopyTB1(Npc.tbPropBase.ximenfeixue);
Npc.tbPropBase.jiaximenfeixue.tbAtkBase		= 500;
Npc.tbPropBase.jiaximenfeixue.tbRisBase	=  {SetResistByRis_p,{0.2,0.3,0.4}};
--酒缸
Npc.tbPropBase.jiugang						= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.jiugang.Exp					= 0;
Npc.tbPropBase.jiugang.AuraSkillId			= 594;
Npc.tbPropBase.jiugang.AuraSkillLevel		= 1;
--无忧
Npc.tbPropBase.wuyou						= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.wuyou.Exp					= 0;
Npc.tbPropBase.wuyou.AuraSkillId			= 1410;
Npc.tbPropBase.wuyou.AuraSkillLevel		= 1;
--俊杰之影
Npc.tbPropBase.junjiezhiying					= Lib:CopyTB1(Npc.tbPropBase.hellxoyo7337);
Npc.tbPropBase.junjiezhiying.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 5);
Npc.tbPropBase.junjiezhiying.Exp				= 0;
Npc.tbPropBase.junjiezhiying.tbAtkBase			= 500;
Npc.tbPropBase.junjiezhiying.AuraSkillId		= 594;
Npc.tbPropBase.junjiezhiying.AuraSkillLevel		= 1;
Npc.tbPropBase.junjiezhiying.PasstSkillId 		= 2127;--npc变色
Npc.tbPropBase.junjiezhiying.PasstSkillLevel 	= 1;
--书生大军
Npc.tbPropBase.shushengdajun				= Lib:CopyTB1(Npc.tbPropBase.hellxoyo7351);
Npc.tbPropBase.shushengdajun.Exp				= 0;
Npc.tbPropBase.shushengdajun.tbAtkBase		= 200;
--冰块
Npc.tbPropBase.kin_ice = Lib:CopyTB1(Npc.tbPropBase.prop_ice);
Npc.tbPropBase.kin_ice.Exp				= 0;
Npc.tbPropBase.kin_ice.PasstSkillId			= 1740;--死亡解除玩家的即死buff
Npc.tbPropBase.kin_ice.PasstSkillLevel		= 5;
--剑
Npc.tbPropBase.kin_sword 					= Lib:CopyTB1(Npc.tbPropBase.prop_ice);
Npc.tbPropBase.kin_sword.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 6*18*3/5/5);
Npc.tbPropBase.kin_sword.Exp				= 0;
Npc.tbPropBase.kin_sword.tbAtkBase			= 1000;
Npc.tbPropBase.kin_sword.AuraSkillId		= 1736;
Npc.tbPropBase.kin_sword.AuraSkillLevel		= 13;
Npc.tbPropBase.kin_sword.PasstSkillId		= 1411;
Npc.tbPropBase.kin_sword.PasstSkillLevel	= 1;
----------七夕活动
Npc.tbPropBase.npc9638					= Lib:CopyTB1(Npc.tbPropBase.worldboss1);
Npc.tbPropBase.npc9638.Exp				= 0;
Npc.tbPropBase.npc9638.LifeReplenish	= GetData(Npc.tbDataTemplet.worldboss_LifeReplenish, 0.01*5/2);
Npc.tbPropBase.npc9638.tbAtkBase			= 1000;
Npc.tbPropBase.npc9638.tbRisBase	=  {SetResistByRis_p,{0.2,0.3,0.4}};

Npc.tbPropBase.npc9639					= Lib:CopyTB1(Npc.tbPropBase.worldboss1);
Npc.tbPropBase.npc9639.Exp				= 0;
Npc.tbPropBase.npc9639.Life				= GetData(Npc.tbDataTemplet.worldboss_LifeReplenish, 1.5);
Npc.tbPropBase.npc9639.LifeReplenish	= GetData(Npc.tbDataTemplet.worldboss_LifeReplenish, 0.01*5/2);
Npc.tbPropBase.npc9639.tbAtkBase			= 1000;
Npc.tbPropBase.npc9639.tbRisBase	=  {SetResistByRis_p,{0.2,0.3,0.4}};
---------钓鱼活动npc------
Npc.tbPropBase.npc9658					= Lib:CopyTB1(Npc.tbPropBase.intensity7);
Npc.tbPropBase.npc9658.Exp				= 0;
Npc.tbPropBase.npc9658.AuraSkillId		= 2223;
Npc.tbPropBase.npc9658.AuraSkillLevel	= 1;
--Npc.tbPropBase.npc9658.PasstSkillId		= 2223;
--Npc.tbPropBase.npc9658.PasstSkillLevel	= 1;
--阴阳时光殿，定身花1
Npc.tbPropBase.poisonflower1 					= Lib:CopyTB1(Npc.tbPropBase.hellxoyo7342);
Npc.tbPropBase.poisonflower1.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*5*6*1*1.4*1*1);---时间 * 人数 * (1-抗性百分比）* 暴击系数 * 装备强度系数 * 实际站桩输出时间系数
Npc.tbPropBase.poisonflower1.PasstSkillId		= 2317;
Npc.tbPropBase.poisonflower1.PasstSkillLevel	= 1;

--阴阳时光殿，定身花2
Npc.tbPropBase.poisonflower2 					= Lib:CopyTB1(Npc.tbPropBase.hellxoyo7342);
Npc.tbPropBase.poisonflower2.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 1*5*1*1*1.4*1*1);
Npc.tbPropBase.poisonflower2.PasstSkillId		= 2329;
Npc.tbPropBase.poisonflower2.PasstSkillLevel	= 1;
--新服活动boss强度
Npc.tbPropBase.newboss 					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.newboss.AR				= 100;
Npc.tbPropBase.newboss.Life				= 15050000;
Npc.tbPropBase.newboss.tbAtkBase		= 125;
Npc.tbPropBase.newboss.AuraSkillId		= 1410;
Npc.tbPropBase.newboss.AuraSkillLevel	= 1;
--2011圣诞活动，穆紫雪
Npc.tbPropBase.muzixue					= Lib:CopyTB1(Npc.tbPropBase.xoyoshusheng);
Npc.tbPropBase.muzixue.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 10*60*6);
Npc.tbPropBase.muzixue.tbAtkBase		= 1350;
---------------------鄂伦河源-------------------------
	--赫赤勒
Npc.tbPropBase.hechile 					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.hechile.Life				= GetData(Npc.tbDamage.dispute12[1], 6*60*6*0.8/2);---时间 * 人数 * (1-抗性百分比）* 暴击系数 * 装备强度系数 * 实际站桩输出时间系数
Npc.tbPropBase.hechile.AR				= 5000;
Npc.tbPropBase.hechile.tbAtkBase		= 2100;
Npc.tbPropBase.hechile.PasstSkillId		= 1411;
Npc.tbPropBase.hechile.PasstSkillLevel	= 1;
	--哲昆
Npc.tbPropBase.zhekun 					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.zhekun.Life				= GetData(Npc.tbDamage.dispute12[1], 4*60*6*0.8*0.8);
Npc.tbPropBase.zhekun.AR				= 5000;
Npc.tbPropBase.zhekun.tbAtkBase		= 2100;
Npc.tbPropBase.zhekun.PasstSkillId		= 1411;
Npc.tbPropBase.zhekun.PasstSkillLevel	= 1;
	--查木儿&鄂木儿
Npc.tbPropBase.chamuer 					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.chamuer.Life				= GetData(Npc.tbDamage.dispute12[1], 4*60*5*0.7);
Npc.tbPropBase.chamuer.AR				= 5000;
Npc.tbPropBase.chamuer.tbAtkBase		= 2100;
Npc.tbPropBase.chamuer.PasstSkillId		= 1411;
Npc.tbPropBase.chamuer.PasstSkillLevel	= 1;
	--献火祭祀
Npc.tbPropBase.xianhuojisi 					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.xianhuojisi.Life				= GetData(Npc.tbDamage.dispute12[1], 5*4*0.6);
Npc.tbPropBase.xianhuojisi.AR				= 5000;
Npc.tbPropBase.xianhuojisi.PasstSkillId		= 1411;
Npc.tbPropBase.xianhuojisi.PasstSkillLevel	= 1;
	--大祭司
Npc.tbPropBase.dajisi 					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.dajisi.Life				= GetData(Npc.tbDamage.dispute12[1], 6*60*5*0.6);
Npc.tbPropBase.dajisi.AR				= 5000;
Npc.tbPropBase.dajisi.tbAtkBase		= 2300;
Npc.tbPropBase.dajisi.PasstSkillId		= 1411;
Npc.tbPropBase.dajisi.PasstSkillLevel	= 1;
	--旗子
Npc.tbPropBase.xinjunyingflag 					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.xinjunyingflag.Life				= GetData(Npc.tbDamage.dispute12[1], 4*10*0.65*0.5);
Npc.tbPropBase.xinjunyingflag.AR				= 5000;
Npc.tbPropBase.xinjunyingflag.PasstSkillId		= 1411;
Npc.tbPropBase.xinjunyingflag.PasstSkillLevel	= 1;
	--士兵
Npc.tbPropBase.junyinsoldier					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.junyinsoldier.Life				= GetData(Npc.tbDamage.dispute12[1], 2*10);
Npc.tbPropBase.junyinsoldier.AR				= 5000;
Npc.tbPropBase.junyinsoldier.tbAtkBase		= 1500;
Npc.tbPropBase.junyinsoldier.PasstSkillId		= 1411;
Npc.tbPropBase.junyinsoldier.PasstSkillLevel	= 1;
	--士兵2
Npc.tbPropBase.junyinsoldier2					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.junyinsoldier2.Life				= GetData(Npc.tbDamage.dispute12[1], 6*5*0.6);
Npc.tbPropBase.junyinsoldier2.AR				= 5000;
Npc.tbPropBase.junyinsoldier2.PasstSkillId		= 1411;
Npc.tbPropBase.junyinsoldier2.PasstSkillLevel	= 1;
	--托雷
Npc.tbPropBase.tuolei					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.tuolei.Life				= GetData(Npc.tbDamage.dispute12[1], 6*60*2*3);
Npc.tbPropBase.tuolei.AR				= 5000;
Npc.tbPropBase.tuolei.tbAtkBase		= 2500;
Npc.tbPropBase.tuolei.PasstSkillId		= 1411;
Npc.tbPropBase.tuolei.PasstSkillLevel	= 1;
	--木华黎
Npc.tbPropBase.muhuali					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.muhuali.Life				= GetData(Npc.tbDamage.dispute12[1], 6*60*6);
Npc.tbPropBase.muhuali.AR				= 5000;
Npc.tbPropBase.muhuali.tbAtkBase		= 2500;
Npc.tbPropBase.muhuali.PasstSkillId		= 1411;
Npc.tbPropBase.muhuali.PasstSkillLevel	= 1;
	--被套马的汉子套的马
Npc.tbPropBase.jy_horse					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.jy_horse.Life				= 1;

Npc.tbPropBase.jy_horseking					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.jy_horseking.Life				= 1;
Npc.tbPropBase.jy_horseking.AuraSkillId		= 374;
Npc.tbPropBase.jy_horseking.AuraSkillLevel	= 1;
	--铁木真
Npc.tbPropBase.tiemuzhen					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.tiemuzhen.Life				= GetData(Npc.tbDamage.dispute12[1], 6*60*6);
Npc.tbPropBase.tiemuzhen.AR				= 5000;
Npc.tbPropBase.tiemuzhen.tbAtkBase		= 3500;
Npc.tbPropBase.tiemuzhen.AuraSkillId		= 1410;
Npc.tbPropBase.tiemuzhen.AuraSkillLevel	= 1;
	--狩猎场动物普通
Npc.tbPropBase.shoulietuzi					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.shoulietuzi.Life				= GetData(Npc.tbDamage.dispute12[1], 3);
Npc.tbPropBase.shoulietuzi.AR				= 5000;
Npc.tbPropBase.shoulietuzi.tbAtkBase		= 1300;
Npc.tbPropBase.shoulietuzi.PasstSkillId		= 1411;
Npc.tbPropBase.shoulietuzi.PasstSkillLevel	= 1;

Npc.tbPropBase.shoulielu					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shoulielu.Life				= GetData(Npc.tbDamage.dispute12[1], 5);

Npc.tbPropBase.shoulieyelang					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shoulieyelang.Life				= GetData(Npc.tbDamage.dispute12[1], 7);

Npc.tbPropBase.shoulielaohu					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shoulielaohu.Life				= GetData(Npc.tbDamage.dispute12[1], 9);

Npc.tbPropBase.shouliexiong					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shouliexiong.Life				= GetData(Npc.tbDamage.dispute12[1], 11);
	--狩猎场动物精英
Npc.tbPropBase.shoulietuzi_j					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.shoulietuzi_j.Life				= GetData(Npc.tbDamage.dispute12[1], 14);
	
Npc.tbPropBase.shoulielu_j					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shoulielu_j.Life				= GetData(Npc.tbDamage.dispute12[1], 24);

Npc.tbPropBase.shoulieyelang_j					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shoulieyelang_j.Life				= GetData(Npc.tbDamage.dispute12[1], 34);

Npc.tbPropBase.shoulielaohu_j					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shoulielaohu_j.Life				= GetData(Npc.tbDamage.dispute12[1], 44);

Npc.tbPropBase.shouliexiong_j					= Lib:CopyTB1(Npc.tbPropBase.shoulietuzi);
Npc.tbPropBase.shouliexiong_j.Life				= GetData(Npc.tbDamage.dispute12[1], 54);
	--狩猎场动物特殊
Npc.tbPropBase.huli					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.huli.Life				= GetData(Npc.tbDamage.dispute12[1], 15);
Npc.tbPropBase.huli.AuraSkillId		= 374;
Npc.tbPropBase.huli.AuraSkillLevel	= 1;

Npc.tbPropBase.huli2					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.huli2.Life				= GetData(Npc.tbDamage.dispute12[1], 4);
---------------------------克夷门战场------------------------------------
--大Boss
Npc.tbPropBase.keyimen_boss1_2  =  Lib:CopyTB1(Npc.tbPropBase.keyimen_boss1_1);
Npc.tbPropBase.keyimen_boss1_2.PasstSkillId = 2650;
Npc.tbPropBase.keyimen_boss1_2.PasstSkillLevel = 1;
--蒙古军旗
Npc.tbPropBase.keyimen_flag_mg  =  Lib:CopyTB1(Npc.tbPropBase.keyimen_flag_xx);
Npc.tbPropBase.keyimen_flag_mg.PasstSkillId = 2650;
Npc.tbPropBase.keyimen_flag_mg.PasstSkillLevel = 1;
--任务怪，普通野外怪
Npc.tbPropBase.keyimen_wild  =  Lib:CopyTB1(Npc.tbPropBase.intensity99);
Npc.tbPropBase.keyimen_wild.Exp = GetData(Npc.tbDataTemplet.intensity99, 0.5);
--任务怪，强力小怪主
Npc.tbPropBase.keyimen_task_minion01  =  Lib:CopyTB1(Npc.tbPropBase.bmy_leader1);
Npc.tbPropBase.keyimen_task_minion01.Exp = 1;
--任务怪，强力小怪次
Npc.tbPropBase.keyimen_task_minion02  =  Lib:CopyTB1(Npc.tbPropBase.bmy_soldier1);
Npc.tbPropBase.keyimen_task_minion02.Exp = 1;
--任务怪，守护
Npc.tbPropBase.keyimen_task_def  =  Lib:CopyTB1(Npc.tbPropBase.bmy_soldier1);
Npc.tbPropBase.keyimen_task_def.Life = GetData(Npc.tbDataTemplet.BaseLife_new, 45*0.7);
Npc.tbPropBase.keyimen_task_def.Exp = 1;
--任务怪，头目
Npc.tbPropBase.keyimen_task_leader  =  Lib:CopyTB1(Npc.tbPropBase.bmy_leader1);
Npc.tbPropBase.keyimen_task_leader.Life = GetData(Npc.tbDataTemplet.BaseLife_new, 1.5*5*60*2*0.7);
Npc.tbPropBase.keyimen_task_leader.LifeReplenish = 0;
--柱子
Npc.tbPropBase.keyimen_pillar					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.keyimen_pillar.Life				= GetData(Npc.tbDataTemplet.BaseLife_new, 10*30/3);
Npc.tbPropBase.keyimen_pillar.AuraSkillId		= 1164;
Npc.tbPropBase.keyimen_pillar.AuraSkillLevel	= 1;
-----------------------辰虫阵------------------------
	--斥候风，林，火，山
Npc.tbPropBase.chihou					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.chihou.Life				= GetData(Npc.tbDamage.dispute14[1], 6*60/5);
Npc.tbPropBase.chihou.AR				= 5000;
Npc.tbPropBase.chihou.tbAtkBase		= 2300;
Npc.tbPropBase.chihou.PasstSkillId		= 1411;
Npc.tbPropBase.chihou.PasstSkillLevel	= 1;
	--木铎落
Npc.tbPropBase.muduoluo					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.muduoluo.Life				= GetData(Npc.tbDamage.dispute14[1], 6*60*7*0.8/1.3);
Npc.tbPropBase.muduoluo.Exp				= 0;--2400000*6;
Npc.tbPropBase.muduoluo.AR				= 5000;
Npc.tbPropBase.muduoluo.tbAtkBase		= 2500;
Npc.tbPropBase.muduoluo.PasstSkillId		= 1411;
Npc.tbPropBase.muduoluo.PasstSkillLevel	= 1;
	--平民
Npc.tbPropBase.pingmin					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.pingmin.Life				= GetData(Npc.tbDamage.dispute14[1], 2);
Npc.tbPropBase.pingmin.AR				= 5000;
Npc.tbPropBase.pingmin.PasstSkillId		= 1411;
Npc.tbPropBase.pingmin.PasstSkillLevel	= 1;
	--异兽
Npc.tbPropBase.strangeanimal					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.strangeanimal.Life				= GetData(Npc.tbDamage.dispute14[1], 6*60*7*0.8);
Npc.tbPropBase.strangeanimal.Exp				= 2800000*6;
Npc.tbPropBase.strangeanimal.AR				= 5000;
Npc.tbPropBase.strangeanimal.tbAtkBase		= 2700;
Npc.tbPropBase.strangeanimal.tbRisBase			=  {SetResistByRis_p,{0.2,0.3,0.4}};
Npc.tbPropBase.strangeanimal.PasstSkillId		= 1411;
Npc.tbPropBase.strangeanimal.PasstSkillLevel	= 1;
	--灯
Npc.tbPropBase.lamp					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.lamp.Life				= GetData(Npc.tbDamage.dispute14[1], 6*10);
Npc.tbPropBase.lamp.AR				= 5000;
Npc.tbPropBase.lamp.tbAtkBase		= 2700;
Npc.tbPropBase.lamp.AuraSkillId		= 1007;
Npc.tbPropBase.lamp.AuraSkillLevel	= 1;
Npc.tbPropBase.lamp.PasstSkillId	= 1411;
Npc.tbPropBase.lamp.PasstSkillLevel	= 1;
	--追兵头儿
Npc.tbPropBase.zhuibingtou					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.zhuibingtou.Life				= GetData(Npc.tbDamage.dispute14[1], 6*60*6*0.8*0.7);
Npc.tbPropBase.zhuibingtou.Exp				= 0;--3200000*6;
Npc.tbPropBase.zhuibingtou.AR				= 5000;
Npc.tbPropBase.zhuibingtou.tbAtkBase		= 2900*0.6;
Npc.tbPropBase.zhuibingtou.PasstSkillId		= 1411;
Npc.tbPropBase.zhuibingtou.PasstSkillLevel	= 1;
	--地鼠
Npc.tbPropBase.dishu					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.dishu.Life				= GetData(Npc.tbDamage.dispute14[1], 6*30);
Npc.tbPropBase.dishu.AR				= 5000;
Npc.tbPropBase.dishu.tbAtkBase		= 2200;
Npc.tbPropBase.dishu.PasstSkillId		= 2675;
Npc.tbPropBase.dishu.PasstSkillLevel	= 1;
	--地鼠2
Npc.tbPropBase.dishu2					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.dishu2.Life				= GetData(Npc.tbDamage.dispute14[1], 6*30);
Npc.tbPropBase.dishu2.AR				= 5000;
Npc.tbPropBase.dishu2.tbAtkBase		= 2200;
Npc.tbPropBase.dishu2.PasstSkillId		= 1411;
Npc.tbPropBase.dishu2.PasstSkillLevel	= 1;
	--拓跋浮樱
Npc.tbPropBase.tuobafuying					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.tuobafuying.Life				= GetData(Npc.tbDamage.dispute14[1], 6*60*16*2.2/2*1.2);
Npc.tbPropBase.tuobafuying.Exp				= 3600000*6;
Npc.tbPropBase.tuobafuying.AR				= 5000;
Npc.tbPropBase.tuobafuying.tbAtkBase		= 3300;
Npc.tbPropBase.tuobafuying.PasstSkillId		= 1411;
Npc.tbPropBase.tuobafuying.PasstSkillLevel	= 1;
	--火眼
Npc.tbPropBase.fireeye					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.fireeye.Life				= GetData(Npc.tbDamage.dispute14[1], 1);
Npc.tbPropBase.fireeye.AR				= 5000;
Npc.tbPropBase.fireeye.PasstSkillId		= 1475;
Npc.tbPropBase.fireeye.PasstSkillLevel	= 1;
	--棋灯卫
Npc.tbPropBase.qidengwei					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.qidengwei.Life				= GetData(Npc.tbDamage.dispute14[1], 5);
Npc.tbPropBase.qidengwei.AR				= 5000;
Npc.tbPropBase.qidengwei.tbAtkBase		= 11;
Npc.tbPropBase.qidengwei.PasstSkillId		= 1111;
Npc.tbPropBase.qidengwei.PasstSkillLevel	= 10;
	--棋灯卫
Npc.tbPropBase.qidengwei2					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.qidengwei2.Life				= GetData(Npc.tbDamage.dispute14[1], 6*15);
Npc.tbPropBase.qidengwei2.AR				= 5000;
Npc.tbPropBase.qidengwei2.tbAtkBase		= 800;
Npc.tbPropBase.qidengwei2.PasstSkillId		= 2730;
Npc.tbPropBase.qidengwei2.PasstSkillLevel	= 15;
	--九世星盘(对话npc)
Npc.tbPropBase.nineworldstarplatedialog					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.nineworldstarplatedialog.Life				= 65496816;
Npc.tbPropBase.nineworldstarplatedialog.LifeReplenish		= 100000;
Npc.tbPropBase.nineworldstarplatedialog.PasstSkillId		= 1475;
Npc.tbPropBase.nineworldstarplatedialog.PasstSkillLevel	= 10;
	--九世星盘
Npc.tbPropBase.nineworldstarplate					= Lib:CopyTB1(Npc.tbPropBase.nineworldstarplatedialog);
Npc.tbPropBase.nineworldstarplate.LifeReplenish		= 1000000;
Npc.tbPropBase.nineworldstarplate.AR				= 5000;
Npc.tbPropBase.nineworldstarplate.PasstSkillId		= 1475;
Npc.tbPropBase.nineworldstarplate.PasstSkillLevel	= 10;
Npc.tbPropBase.nineworldstarplate.AuraSkillId		= 2475;
Npc.tbPropBase.nineworldstarplate.AuraSkillLevel	= 2;
	--基友1
Npc.tbPropBase.jiyou1					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.jiyou1.Life				= 65491231;
Npc.tbPropBase.jiyou1.AR				= 5000;
Npc.tbPropBase.jiyou1.tbAtkBase		= 2000;
Npc.tbPropBase.jiyou1.PasstSkillId		= 2552;
Npc.tbPropBase.jiyou1.PasstSkillLevel	= 3;
	--基友2
Npc.tbPropBase.jiyou2					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.jiyou2.Life				= 65491231;
Npc.tbPropBase.jiyou2.AR				= 5000;
Npc.tbPropBase.jiyou2.tbAtkBase		= 2000;
Npc.tbPropBase.jiyou2.PasstSkillId		= 2553;
Npc.tbPropBase.jiyou2.PasstSkillLevel	= 1;
	--基友3
Npc.tbPropBase.jiyou3					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.jiyou3.Life				= 65491231;
Npc.tbPropBase.jiyou3.AR				= 5000;
Npc.tbPropBase.jiyou3.tbAtkBase		= 2000;
Npc.tbPropBase.jiyou3.PasstSkillId		= 2554;
Npc.tbPropBase.jiyou3.PasstSkillLevel	= 1;
	--九世星盘幻影
Npc.tbPropBase.xingpanshadow					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.xingpanshadow.Life				= 65491231/2;
Npc.tbPropBase.xingpanshadow.AR				= 5000;
Npc.tbPropBase.xingpanshadow.tbAtkBase		= 1000;
Npc.tbPropBase.xingpanshadow.tbRisBase			= {SetResistByRis_p,{0.2,0.3,0.4}};
Npc.tbPropBase.xingpanshadow.PasstSkillId		= 1411;
Npc.tbPropBase.xingpanshadow.PasstSkillLevel	= 1;
--------额仑河源侠客任务
	--白鹿神使
Npc.tbPropBase.xiake_bailushenshi					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.xiake_bailushenshi.Life				= GetData(Npc.tbDamage.dispute12[1], 6*60*6*0.8*1.5);
Npc.tbPropBase.xiake_bailushenshi.Exp				= 1;
Npc.tbPropBase.xiake_bailushenshi.AR				= 5000;
Npc.tbPropBase.xiake_bailushenshi.tbAtkBase			= 2700;
Npc.tbPropBase.xiake_bailushenshi.tbRisBase			=  {SetResistByRis_p,{0.2,0.3,0.4}};
Npc.tbPropBase.xiake_bailushenshi.AuraSkillId		= 594;
Npc.tbPropBase.xiake_bailushenshi.AuraSkillLevel	= 1;
Npc.tbPropBase.xiake_bailushenshi.PasstSkillId		= 2900;
Npc.tbPropBase.xiake_bailushenshi.PasstSkillLevel	= 10;
	--苍狼神使
Npc.tbPropBase.xiake_canglangshenshi					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.xiake_canglangshenshi.Life				= GetData(Npc.tbDamage.dispute12[1], 6*60*6*0.8*1.5);
Npc.tbPropBase.xiake_canglangshenshi.Exp				= 1;
Npc.tbPropBase.xiake_canglangshenshi.AR					= 5000;
Npc.tbPropBase.xiake_canglangshenshi.tbRisBase			=  {SetResistByRis_p,{0.2,0.3,0.4}};
Npc.tbPropBase.xiake_canglangshenshi.tbAtkBase			= 1800;
Npc.tbPropBase.xiake_canglangshenshi.AuraSkillId		= 594;
Npc.tbPropBase.xiake_canglangshenshi.AuraSkillLevel		= 1;
	--狼卫
Npc.tbPropBase.xiake_langwei					= Lib:CopyTB1(Npc.tbPropBase.muren);
Npc.tbPropBase.xiake_langwei.Life				= GetData(Npc.tbDamage.dispute12[1], 60);
Npc.tbPropBase.xiake_langwei.AR					= 5000;
Npc.tbPropBase.xiake_langwei.tbAtkBase			= 1300;
----------------------------------------------------------------------------
--如果npc强度表里使用了 tbRisBase,tbAtkBase 标记,将其转成各种五行的数据
for key, tb in pairs(Npc.tbPropBase) do
	if (tb.tbRisBase) then
		if (type(tb.tbRisBase) == "table") and (type(tb.tbRisBase[1]) == "function")  then
			tb.PhysicsResist = tb.tbRisBase[1](tb.tbRisBase[2], 1);
			tb.PoisonResist	 = tb.tbRisBase[1](tb.tbRisBase[2], 2);
			tb.ColdResist	 = tb.tbRisBase[1](tb.tbRisBase[2], 3);
			tb.FireResist	 = tb.tbRisBase[1](tb.tbRisBase[2], 4);
			tb.LightResist 	 = tb.tbRisBase[1](tb.tbRisBase[2], 5);
		elseif type(tb.tbRisBase) == "number"  then
			tb.PhysicsResist = tb.tbRisBase;
			tb.PoisonResist	 = tb.tbRisBase;
			tb.ColdResist	 = tb.tbRisBase;
			tb.FireResist	 = tb.tbRisBase;
			tb.LightResist 	 = tb.tbRisBase;
		end
	end
	if (tb.tbAtkBase) then
		if (type(tb.tbAtkBase) == "table") and (type(tb.tbAtkBase[1]) == "function")  then
			tb.tbAtkBase[3] = tb.tbAtkBase[3] or false;
			
			tb.PhysicalDamageBase	= tb.tbAtkBase[1](tb.tbAtkBase[2], 1, tb.tbAtkBase[3]);
			tb.PoisonDamageBase	    = tb.tbAtkBase[1](tb.tbAtkBase[2], 2, tb.tbAtkBase[3]);
			tb.ColdDamageBase		= tb.tbAtkBase[1](tb.tbAtkBase[2], 3, tb.tbAtkBase[3]);
			tb.FireDamageBase		= tb.tbAtkBase[1](tb.tbAtkBase[2], 4, tb.tbAtkBase[3]);
			tb.LightingDamageBase	= tb.tbAtkBase[1](tb.tbAtkBase[2], 5, tb.tbAtkBase[3]);
			
			tb.PhysicalMagicBase	= tb.tbAtkBase[1](tb.tbAtkBase[2], 1, tb.tbAtkBase[3]);
			tb.PoisonMagicBase		= tb.tbAtkBase[1](tb.tbAtkBase[2], 2, tb.tbAtkBase[3]);
			tb.ColdMagicBase		= tb.tbAtkBase[1](tb.tbAtkBase[2], 3, tb.tbAtkBase[3]);
			tb.FireMagicBase		= tb.tbAtkBase[1](tb.tbAtkBase[2], 4, tb.tbAtkBase[3]);
			tb.LightingMagicBase	= tb.tbAtkBase[1](tb.tbAtkBase[2], 5, tb.tbAtkBase[3]);
		elseif type(tb.tbAtkBase) == "number"  then
			tb.PhysicalDamageBase	= tb.tbAtkBase/5;
			tb.PoisonDamageBase	    = tb.tbAtkBase/10;
			tb.ColdDamageBase		= tb.tbAtkBase/5;
			tb.FireDamageBase		= tb.tbAtkBase/5;
			tb.LightingDamageBase	= tb.tbAtkBase/5;
	
			tb.PhysicalMagicBase	= tb.tbAtkBase/5;
			tb.PoisonMagicBase		= tb.tbAtkBase/10;
			tb.ColdMagicBase		= tb.tbAtkBase/5;
			tb.FireMagicBase		= tb.tbAtkBase/5;
			tb.LightingMagicBase	= tb.tbAtkBase/5;
		end
	end
	--后加的2个被动技能,懒得在上面填了
	if (not tb.PasstSkillId1) then
		tb.PasstSkillId1 = 0
	end
	if (not tb.PasstSkillLevel1) then
		tb.PasstSkillLevel1 = 0
	end
	if (not tb.PasstSkillId2) then
		tb.PasstSkillId2 = 0
	end
	if (not tb.PasstSkillLevel2) then
		tb.PasstSkillLevel2 = 0
	end
end
-----------------------------不要在之后加npc强度数据-------------------------
