--节日、活动技能
local tb	= {
	--跨服宋金死亡叠加buff
	spbt_zhanyi={
		redeivedamage_dec_p={{{1,20},{2,40}}},
	},
	--2009新年活动
	snowball_damage={
		appenddamage_p={{{1,0},{2,0}}},
		magicdamage_v={
			[1]={{1,1},{2,2},{3,3},{4,4}},
			[3]={{1,1},{2,2},{3,3},{4,4}}
		},
		missile_speed_v={40},
	},
	snowball_xuejinzhen={
		appenddamage_p={{{1,0},{2,0}}},
		magicdamage_v={
			[1]={{1,1},{2,2},{3,3},{4,3}},
			[3]={{1,1},{2,2},{3,3},{4,3}}
		},
		missile_speed_v={60},
	},
	snowball_fixed={
		state_fixed_attack={{{1,100},{2,100}},{{1,18*1},{2,18*1},{3,18*1},{4,18*2}}},
	},
	snowball_freeze={
		state_freeze_attack={{{1,100},{2,100}},{{1,18*2},{2,18*2},{3,18*2},{4,18*2}}},
	},
	snowball_confuse={
		state_confuse_attack={{{1,100},{2,100}},{{1,18*1},{2,18*1},{3,18*1},{4,18*1}}},
	},
	snowball_stun={
		state_stun_attack={{{1,100},{2,100}},{{1,18*1},{2,18*1},{3,18*1},{4,18*2}}},
	},
	snowball_slowall={
		state_slowall_attack={{{1,100},{2,100}},{{1,18*2},{2,18*2},{3,18*1},{4,18*2}}},
	},
	snowball_duixueji={
		state_stun_attack={{{1,100},{2,100}},{{1,18*1},{2,18*1},{3,18*1},{4,18*2}}},
		appenddamage_p={{{1,0},{2,0}}},
		magicdamage_v={
			[1]={{1,1},{2,2},{3,3},{4,3}},
			[3]={{1,1},{2,2},{3,3},{4,3}}
		},
		missile_speed_v={40},
	},
	snowball_water={
		state_slowall_attack={{{1,100},{2,100}},{{1,18*3},{5,18*3}}},
		appenddamage_p={{{1,0},{2,0}}},
		magicdamage_v={
			[1]={{1,1},{2,2},{3,3},{4,3}},
			[3]={{1,1},{2,2},{3,3},{4,3}}
		},
	},
	tabingjue={
		fastwalkrun_p={{{1,10},{2,20}}},
		skill_statetime={{{1,18*30},{2,18*30}}},
	},
	chengshuangshi={
		addenchant={21, {{1,1}, {2, 2}}},
		skill_statetime={{{1,18*30},{2,18*30}}},
	},
	snowglove={
		addenchant={22, {{1,1}, {2, 2}}},
		skill_statetime={{{1,18*30},{2,18*30}}},
	},
	xueyingwu={
		state_slowall_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		state_freeze_ignore={1},
		state_confuse_ignore={1},
		skill_statetime={{{1,18*30},{2,18*30}}},
	},
	jiangbinyu={
		prop_invincibility={1},
		skill_statetime={{{1,18*20},{2,18*20}}},
	},
	newyearmonsteratk={		--飞絮崖年兽攻击技能,11级为年兽攻城用
		appenddamage_p={{{1,0},{2,0},{10,0},{11,100}}},
		magicdamage_v={
			[1]={{1,1},{2,2},{3,3},{4,3}},
			[3]={{1,1},{2,2},{3,3},{4,3}}
		},
	},
	newyear_transmutation={ --变身技能
		domainchangeself={{{1,3605},{2,3606},{3,3607},{4,3608},{5,4286},{8,4289},{9,4483}},{{1,1},{2,1}}},
		adddomainskill1={{{1,1300},{4,1300},{5,1451},{8,1451},{9,1430}},{{1,1},{20,1}}},
		adddomainskill2={{{1,0},{4,0},{5,0},{8,0},{9,0}},{{1,2},{20,2}}},
		skill_statetime={{{1,18*60*30},{10,18*60*30},{11,18*60*30}}},
	},
	addpower1329={ --年兽冲刺攻击穿透攻击提高
		--addpowerwhencol = {1329, {{1,10}, {10, 10}}, {{1,200}, {10, 200}}},
		skill_statetime={{{1,18*60*30},{10,18*60*30},{11,18*60*30}}},
	},
---------------------------------------
--端午节龙舟技能
--1级天罚,2级固定机关,3级粽子,4级玩家学习,11级撞墙
	lz_chihuan={ --履冰,迟缓5秒
		state_slowall_attack	={{{1,100},{10,100},{11,1000}},{{1,18*5},{2,18*5},{10,18*5},{11,18*6}}},
	},
	lz_yunxuan={ --暗礁,晕眩2秒
		state_stun_attack		={{{1,100},{10,100},{11,1000}},{{1,18*2},{2,18*2},{10,18*2},{11,18*3}}},
	},
	lz_dingshen={ --掀浪,定身3秒
		state_fixed_attack		={{{1,100},{10,100},{11,1000}},{{1,18*3},{2,18*3},{10,18*3},{11,18*4}}},
	},
	lz_hunluan={ --漩涡,混乱2秒
		state_confuse_attack	={{{1,100},{10,100},{11,1000}},{{1,18*2},{2,18*3},{10,18*4},{11,18*3}}},
	},
	lz_lahui={ --龙吞,拉回定身
		state_drag_attack		={{{1,100},{10,100},{11,1000}},{{1,25},{10,25}},{{1,32},{2,32}}},
		state_fixed_attack		={{{1,100},{10,100},{11,1000}},{{1,18*3},{10,18*3},{11,18*3}}},
	},
	lz_jitui={ --扫尾,击退400
		state_knock_attack		={{{1,100},{10,100},{11,1000}},{{1,20},{10,20}},{{1,20},{2,20}}},
	},

--被动技能
	shifu={ --石肤,减迟缓和定身40%
		state_slowall_resistrate={{{1,166},{2,166}}},
		state_fixed_resistrate={{{1,166},{2,166}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	longxin={ --龙心,减迟缓和混乱40%
		state_slowall_resistrate={{{1,166},{2,166}}},
		state_confuse_resistrate={{{1,166},{2,166}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	haihun={ --海魂,减迟缓和晕眩40%
		state_slowall_resistrate={{{1,166},{2,166}}},
		state_stun_resistrate={{{1,166},{2,166}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	nilin={ --逆鳞,减所有负面几率30%
		allseriesstateresistrate={{{1,107},{2,107}}},
		allspecialstateresistrate={{{1,107},{2,107}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
--主动辅助
	zhuihunyin={ --追魂引,跑速提高50%,持续6秒
		fastwalkrun_p={{{1,50},{2,50}}},
		skill_statetime={{{1,6*18},{2,6*18}}},
	},
	zhaohunqu={ --招魂曲,免疫负面状态8秒
		state_fixed_ignore={1},
		state_stun_ignore={1},
		state_slowall_ignore={1},
		state_knock_ignore={1},
		state_drag_ignore={1},
		state_confuse_ignore={1},
		skill_statetime={{{1,8*18},{2,8*18}}},
	},
	huihunjue={ --回魂诀,隐身8秒
		hide={0,{{1,8*18},{2,8*18}}, 1},
	},

	longzhou_transmutation={ --变身技能
		domainchangeself={{{1,3645},{2,3646},{3,3647},{4,3648}},{{1,99},{2,99}}},
		skill_statetime={{{1,18*60*30},{10,18*60*30},{11,18*60*30}}},
	},
-----------------美女光环----------------------
	bellebuff={
		autoskill={{{1,50},{2,50}},{{1,1},{2,2}}},
	},
	bellebuff_team={
		expenhance_p=	{{{1,5},{2,10}}},
		lucky_v=		{{{1,5},{2,10}}},
	},
-------------------联赛观战--------------------
	spectator_state={
		hide_all={{{1,1},{10,1}}},
	},
------------------中秋及国庆---------------------
	defencestate={--不能被攻击
		defense_state={1}
	},
------------------结婚系统---------------------
	jiehunxitongyanhua={ --结婚系统烟花
		skill_startevent={{{1,1529},{2,1530}}},
		skill_showevent={{{1,1},{20,1}}},
		skill_startevent={{{1,1529},{2,1530}}},
		skill_showevent={{{1,1},{20,1}}},
	},
	jiehunxitongziti={ --结婚系统字体
		skill_startevent={{{1,1556},{2,1557}}},
		skill_showevent={{{1,1},{20,1}}},
		skill_startevent={{{1,1556},{2,1557}}},
		skill_showevent={{{1,1},{20,1}}},
	},
----------------------------------清明节植物大战僵尸-----------------------------------	
	npc_liferefleshstate2={	--每5秒生命回复
		lifereplenish_v={{{1,5},{2,10},{3,15}}},
	},
	npc_maxhpstate2={	--增加生命上限
		lifemax_p={{{1,5},{2,10}}},
	},
	qingming_transmutation={ --变身技能
		domainchangeself={{{1,6692},{6,6697}},{{1,100},{2,100}}},
		adddomainskill1={{{1,1616},{4,1616}},{{1,1},{20,1}}},
		adddomainskill2={{{1,0},{4,0},{5,0},{8,0},{9,0}},{{1,2},{20,2}}},
		skill_statetime={{{1,18*60*30},{10,18*60*30},{11,18*60*30}}},
	},
	npc_changehp={	--加减血
		fastlifereplenish_v={{{1,30},{2,-30}}},
	},
--清明节玩家控制技能
	qmj_chihuan={ --履冰,迟缓5秒
		state_slowall_attack	={{{1,100},{10,100},{11,1000}},{{1,18*5},{2,18*5},{10,18*5},{11,18*6}}},
		magicdamage_v={
			[1]={{1,2},{2,2}},
			[3]={{1,2},{2,2}}
		},
	},
	qmj_yunxuan={ --暗礁,晕眩2秒
		state_stun_attack		={{{1,100},{10,100},{11,1000}},{{1,18*2},{2,18*2},{10,18*2},{11,18*3}}},
		magicdamage_v={
			[1]={{1,2},{2,2}},
			[3]={{1,2},{2,2}}
		},
	},
	qmj_dingshen={ --掀浪,定身3秒
		state_fixed_attack		={{{1,100},{10,100},{11,1000}},{{1,18*3},{2,18*3},{10,18*3},{11,18*4}}},
		magicdamage_v={
			[1]={{1,2},{2,2}},
			[3]={{1,2},{2,2}}
		},
	},
	qmj_hunluan={ --漩涡,混乱2秒
		state_confuse_attack	={{{1,100},{10,100},{11,1000}},{{1,18*2},{2,18*3},{10,18*4},{11,18*3}}},
		magicdamage_v={
			[1]={{1,2},{2,2}},
			[3]={{1,2},{2,2}}
		},
	},
	qmj_lahui={ --龙吞,拉回定身
		state_drag_attack		={{{1,100},{10,100},{11,1000}},{{1,25},{10,25}},{{1,32},{2,32}}},
		state_fixed_attack		={{{1,100},{10,100},{11,1000}},{{1,18*3},{10,18*3},{11,18*3}}},
		magicdamage_v={
			[1]={{1,2},{2,2}},
			[3]={{1,2},{2,2}}
		},
	},
	qmj_jitui={ --扫尾,击退400
		state_knock_attack		={{{1,100},{10,100},{11,1000}},{{1,20},{10,20}},{{1,20},{2,20}}},
		magicdamage_v={
			[1]={{1,2},{2,2}},
			[3]={{1,2},{2,2}}
		},
	},
-------------------------------------侠客岛-------------------------------------------------
	xkd_buchangstate={ --跨服城战开服时间补偿buff
		skilldamageptrim={{{1,5},{20,5}}},
		skillselfdamagetrim={{{1,5},{20,5}}},
		damage_all_resist={{{1,60},{2,60}}},
	},
	xkd_occupy={ --资源占领buff
		--damage_inc_p=			{{{1,5},{2,10},{3,15},{4,20},{5,40},{6,45},{7,50},{8,55},{9,60},{10,60}}},
		redeivedamage_dec_p=	{{{1,10},{2,19},{3,27},{4,34},{5,49},{6,54},{7,59},{8,64},{9,69},{10,69}}},
	},
	xkd_renshucha={ --xkd_人数差buff
		redeivedamage_dec_p=	{{{1,8},{2,15},{3,24},{4,35},{5,41}}},
	},
	xkd_forbid={ --资源点debuff,覆盖占领状态的buff
		fastwalkrun_p={0},
	},
	xkd_lockstate={
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,1},{10,1}},
			[2] = {{1,0},{10,0}},
			[3] = {{1,0},{10,0}},
			},
		ignoredebuff = {{{1,19968},{2,19968},{3,19968}}},--免疫混乱,击退,拉回,浮空
	},  
-------------------------------------5.1活动-------------------------------------------------
	workday_transmutation={ --变身技能
		--参数1,变身npcid,参数2变身npc等级,参数3变身类型:1变外观,2变属性,4改变技能
		domainchangeself={{{1,6807},{5,6811},{6,6811}},{{1,100},{2,100}},{{1,1},{2,1}}},
		skill_statetime={{{1,18*60*60},{10,18*60*60},{11,18*60*60}}},
	},
-------------------------------------热血侠客岛-----------------------------------------------
	xiakedao_transmutation={ --变身技能
		defense_state={1},
		prop_invincibility={1},
		domainchangeself={{{1,6692},{6,6697}},{{1,100},{2,100}}},
		adddomainskill1={{{1,0},{20,0}},{{1,0},{20,0}}},
		adddomainskill2={{{1,0},{4,0}},{{1,0},{20,0}}},
		skill_statetime={{{1,18*60*30},{10,18*60*30},{11,18*60*30}}},
		defense_state={1},
	},	
	xiakedao_bishaji={	--侠客岛
		physicsdamage_v={
			[1]={{1,20000},{2,20000}},
			[3]={{1,20000},{2,20000}},
		},
		colddamage_v={
			[1]={{1,20000},{2,20000}},
			[3]={{1,20000},{2,20000}},
		},
		firedamage_v={
			[1]={{1,20000},{2,20000}},
			[3]={{1,20000},{2,20000}},
		},
		lightingdamage_v={
			[1]={{1,20000},{2,20000}},
			[3]={{1,20000},{2,20000}},
		},	
		--skill_mintimepercast_v={{{1,600*18},{10,600*18}}},
	},
	xiakedao_zibao= { --自爆
		autoskill={{{1,92},{2,92}},{{1,1},{20,20}}},
		damage_return_receive_p={{{1,5},{20,100}}},
		ignoredebuff = {{{1,32767},{10,32767}}}, --免疫五行效果
		skill_statetime={{{1,-1},{20,-1}}},
	},
	zibao_child={ --驱毒术子
		appenddamage_p= {{{1,50},{18,300},{19,350}}},
		missile_hitcount={{{1,1},{18,4},{19,5}}},
		missile_range={13,0,13},
	},
	npc_dmgrt_recieve_p={ --反弹抗性，每级5%
		damage_return_receive_p={{{1,5},{20,100}}},
		ignoredebuff = {{{1,32767},{10,32767}}}, --免疫五行效果
		skill_statetime={{{1,-1},{20,-1}}},
	},
	xiakedao_rebound={--反弹,每级5%
		autoskill={{{1,93},{2,93}},{{1,1},{19,10},{20,20}}},--触发刀少120
		rangedamagereturn_p={{{1,5},{10,50}}},
		meleedamagereturn_p={{{1,5},{10,50}}},
		poisondamagereturn_p={{{1,5},{10,90},{20,100}}},
		damage_return_receive_p={{{1,5},{5,80},{10,90}}},
		ignoredebuff = {{{1,32767},{10,32767}}}, --免疫五行效果
		skill_statetime={{{1,-1},{2,-1}}},
	},
	xiakedao_jianshang={ --刀少120
		dynamicmagicshield_v={{{1,20000},{20,20000}},99},
		posionweaken={{{1,20000},{20,20000}},99},
	},
	xiakedao_recdmgdec={ --减少受到的伤害,每级5%,5%到100%
		redeivedamage_dec_p2={{{1,5},{20,100}}},
		damage_return_receive_p={{{1,50},{20,50}}},
		ignoredebuff = {{{1,32767},{10,32767}}}, --免疫五行效果
		skill_statetime={{{1,-1},{10,-1}}},
	},
	xiakedao_dmgadd={ --穿透加攻击
		addpowerwhencol={1678, {{1, 100}, {20, 100}}, {{1, 500}, {20, 500}}},
		damage_return_receive_p={{{1,5},{20,100}}},
		ignoredebuff = {{{1,32767},{10,32767}}}, --免疫五行效果
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yelanguan_cihangpudu={ --慈航普渡
		lifereplenish_v={{
			{1,0},
			{2,0},		--高攻击小兵用
			{3,0},
			{4,   1500},
			--{5,   2000000},
			{20,50000},
		}},
		skill_statetime={{
			{1,0},
			{2,0},
			{3,0},
			{4,18*5.5},
			{5,18*5.5},
			{6,18*5.5},
		}}
	},
-------------------------------------年兽攻城-----------------------------------------------
	newyearbianpao={ --鞭炮攻击
		appenddamage_p={{{1,0},{2,0}}},
		magicdamage_v={
			[1]={{1,100},{2,200}},
			[3]={{1,100},{2,200}}
		},
	},
--------------------------美女活动2012--------------------------
	prettybuff={ --美女buff
		expenhance_p={{{1,2},{2,5},{3,10},{4,15}}},
		--subexplose={{{1,0},{2,10},{3,15}}},
		lucky_v=		{{{1,2},{2,5},{3,10},{4,15}}},
	},
	handsomebuff={ --帅哥buff
		expenhance_p={{{1,4},{2,5}}},
		subexplose={{{1,10},{2,15}}},
		--lucky_v=		{{{1,5},{2,10}}},
	},
-------------------------2012六一变身--------------------------------------------
	Children2012_transmutation={
		domainchangeself={
			{
			{1,10139},{2,2410},{3,2426},{4,4439},{5,3552},{6,4480},
			{7,3468},{8,4485},{9,6692},{10,6738},{11,7284},{12,9954},
			{13,4483},{14,4278},{15,4133},{16,2421},{17,4592},{18,3224},
			{19,3262},{20,3478},{21,3467},{22,4486},{23,6693},{24,7056},
			{25,9875},{26,4174},
			-- 以下是七夕活动变身
			{27,6709},{28,3681},{29,6762},{30,6712},{31,233},{32,6871},
			{33,3476},{34,3244},{35,6692},{36,4452},{37,9884},{38,9885},
			{39,1182},{40,1034},{41,1441},{42,1111},{43,3553},{44,3536}
			},
			nil,
			{
			{1,1},{27,1}
			}},
		skill_statetime={{{1,18*15*60},{32,18*15*60}}},
	},
-------------------------------------夏蒙战场-------------------------------------------------
	NewBattle_LongMaiXia={ --夏军龙脉变身
		--参数1,变身npcid,参数2变身npc等级,参数3变身类型:1变外观,2变属性,4改变技能
		domainchangeself={{{1,10274},{5,10274},{6,10274}},{{1,100},{2,100}},{{1,1},{1,1}}},
		skill_statetime={{{1,18*60*60},{10,18*60*60},{11,18*60*60}}},
	},
	NewBattle_LongMaiMeng={ --蒙军龙脉变身
		--参数1,变身npcid,参数2变身npc等级,参数3变身类型:1变外观,2变属性,4改变技能
		domainchangeself={{{1,10273},{5,10273},{6,10273}},{{1,100},{2,100}},{{1,1},{1,1}}},
		skill_statetime={{{1,18*60*60},{10,18*60*60},{11,18*60*60}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("bellebuff");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("\n每隔%s秒释放：<color=green>月华千里<color>\n幸运值：增加<color=gold>%s点<color>\n杀死敌人的经验：增加<color=gold>%s%%<color>\n持续时间<color=gold>%s秒<color>",
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime),
		tbChildInfo.tbWholeMagic["lucky_v"][1],
		tbChildInfo.tbWholeMagic["expenhance_p"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("xiakedao_zibao");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= "";
	--szMsg = 
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("xiakedao_rebound");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= "";
	--szMsg = 
	return szMsg;
end;