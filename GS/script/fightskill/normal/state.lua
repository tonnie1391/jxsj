--各种状态
local tb	= {
	--新手buff
	trangthaibaoho={
		skilldamageptrim={{{1,50},{2,51}}},
		skillselfdamagetrim={{{1,50},{2,51}}},
		lifemax_v=	{{{1,250},{2,300}}},
		manamax_v=	{{{1,250},{2,300}}},
		damage_all_resist={{{1,30},{2,31}}},
		fastwalkrun_p={{{1,50},{2,50}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	noobbuff={
		lifemax_p={{{1,5},{2,8},{3,12},{4,16},{5,20},{6,25},{7,30},{8,36},{9,43},{10,50}}},
		lifemax_v={{{1,60},{2,96},{3,144},{4,192},{5,240},{6,300},{7,360},{8,432},{9,516},{10,600}}},
		damage_all_resist={{{1,10},{2,16},{3,23},{4,31},{5,40},{6,50},{7,61},{8,73},{9,86},{10,100}}},
		autoskill={{{1,106},{2,106}},{{1,1},{2,2}}},
		skill_statetime={18*90*60},
	},
	noobbuff_child={
		dynamicmagicshield_v	={{{1,99999},{10,99999}},{{1,85},{10,85}}},
		posionweaken			={{{1,99999},{10,99999}},{{1,85},{10,85}}},
		skill_statetime={18*10},
	},
	
	--越南版某buff
	vn_some_state={
		lifemax_p=	{{{1,5},{2,10}}},
		manamax_p=	{{{1,5},{2,10}}},
	},

--普攻转化成五行攻击
	changeseriesdammage={
		magic_turnphysicaldammage={{{1,80},{2,80}}},
		skill_statetime={18*60*60*2},
	},

	enhance_exp={
		expenhance_p={{{1,10},{2,20}}},
		skill_statetime={18*10}
	},
	
	enhance_luck={
		lucky_v={{{1,5},{2,10},{3,2},{4,5},{5,9},{6,14},{7,20}}},
		skill_statetime={18*60*30}
	},
	pray_exp={
		expenhance_p={{{1,10},{2,15},{3,20},{4,30},{5,50}}},
		skill_statetime={18}
	},
	
	pray_luck={
		lucky_v={{{1,10},{2,15},{3,20},{4,30},{5,50}}},
		skill_statetime={18*60*30}
	},
	
	addtion_exp={
		skillexpaddtionp={{{1,100},{2,150}}},
		skill_statetime={18}
	},
	
	open_xiuwei={
		expxiuwei_v={0},
		skill_statetime={18}
	},
	lockstate={
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,1},{10,1}},
			[2] = {{1,0},{10,0}},
			[3] = {{1,0},{10,0}},
			},
	},  
	state_exp={
		expenhance_p={{{1,5},{2,10}}},
	},
	npc_resistseriesrate={
		state_hurt_resistrate={{{1,10},{10,100},{20,180}}},						
		state_weak_resistrate={{{1,10},{10,100},{20,180}}},					
		state_slowall_resistrate={{{1,10},{10,100},{20,180}}},						
		state_burn_resistrate={{{1,10},{10,100},{20,180}}},		
		state_stun_resistrate={{{1,10},{10,100},{20,180}}},	
	},
	npc_resistseriestime={
		state_hurt_resisttime={{{1,10},{10,100},{20,180}}},						
		state_weak_resisttime={{{1,10},{10,100},{20,180}}},					
		state_slowall_resisttime={{{1,10},{10,100},{20,180}}},						
		state_burn_resisttime={{{1,10},{10,100},{20,180}}},		
		state_stun_resisttime={{{1,10},{10,100},{20,180}}},				
	},
	npc_ignoreseriesstate={
	ignoredebuff = {{{1,32767},{10,32767}}},
	--[[
		state_hurt_ignore={1},
		state_weak_ignore={1},
		state_slowall_ignore={1},
		state_burn_ignore={1},
		state_stun_ignore={1},
		state_fixed_ignore={1},
		state_palsy_ignore={1},
		--state_slowrun_ignore={1},
		--state_freeze_ignore={1},
		state_confuse_ignore={1},
		state_knock_ignore={1},
		state_drag_ignore={1},
		--state_silence_ignore={1},--魔法属性太多,删除 ]]
	},
	longtimefood={
		fastlifereplenish_v={{{1,15},{2,30},{3,45},{4,60},{5,75},{6,75},{7,75}}},
		fastmanareplenish_v={{{1,15},{2,30},{3,45},{4,60},{5,75},{6,75},{7,75}}},
		skill_statetime={{{1,18*60*30},{5,18*60*30},{6,18*60*60*24*7},{7,18*60*60*24*30}}},
	},
	noob_lifereplenish={
		fastlifereplenish_v={999},
		skill_statetime={{{1,18*60*30},{5,18*60*30}}},
	},
	mapprotect={
		protected={1},
	},
	--装备附带技能
	tianyuanxinfa={ --联赛黄金衣服
		subexplose={{{1,80},{2,85}}},
		damage_all_resist={{{1,35},{2,45}}},
	},
	tongweixianhua={ --领土帽子
		autoskill={{{1,32},{2,32}},{{1,1},{2,2}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	tongweixianhua_child1={ --领土帽子_队友
		npcdamageadded={{{1,15},{2,20}}},
	},
	tongweixianhua_child2={ --领土帽子_自身
		npcdamageadded={{{1,35},{2,50}}},
		lifemax_p={{{1,30},{2,40}}},
		manamax_p={{{1,30},{2,40}}},
	},
	bootskill={ --白银/黄金鞋子
		autoskill={{{1,51},{2,51}},{{1,1},{2,2}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	bootskill_team={ --白银/黄金鞋子_队友
		fastwalkrun_p={{{1,10},{2,10}}},
		seriesenhance={{{1,50},{2,100}}},
		seriesabate={{{1,50},{2,100}}},
	},
	bootskill_self={ --白银/黄金鞋子_自身
		fastwalkrun_p={{{1,10},{2,20}}},
		seriesenhance={{{1,300},{2,500}}},
		seriesabate={{{1,300},{2,500}}},
	},
	cuffskill_self={ --白银/黄金护腕
		staminareplenish_v={{{1,50},{2,100}}},
		allspecialstateresistrate={{{1,100},{2,245}}},
	},
	zixiashengong={ --高级披风
		allspecialstateresisttime={{{1,100},{2,245},{3,500}}},
		seriesenhance={{{1,0},{2,FightSkill.IVER_nZiXiaShenGongSeriersAbate},{3,FightSkill.IVER_nZiXiaShenGongSeriersAbate+200}}},
		seriesabate={{{1,0},{2,FightSkill.IVER_nZiXiaShenGongSeriersAbate},{4,FightSkill.IVER_nZiXiaShenGongSeriersAbate+200}}},
	},
	tianxiashengong={ --濒死无敌
		autoskill={{{1,52},{2,52}},{{1,1},{2,1}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	tianxiashengong_child={ --触发无敌
		prop_invincibility={1},
		defense_dummy = {1},
		skill_statetime={{{1,18*5},{2,18*5}}},
	},
	
	xixasuitskill={ --西夏套装属性
		autoskill={{{1,111},{2,111}},{{1,1},{2,2}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	xixasuitskill_child1={ --清除自身状态
		removestate={{{1,1996},{2,1996}}},--开始时清除自身原buff
	},
	xixasuitskill_child2={ --叠加buff
		redeivedamage_dec_p2={{{1,7},{2,7}}},
		superposemagic={{{1,14},{10,14}}},
		missile_missrate={{{1,50},{2,50}}},
		skill_statetime={{{1,18*5},{2,18*5}}},
	},
	
	dispute_defend={
		lifemax_p={{{1,5},{2,8},{3,12},{4,16},{5,20},{6,25},{7,30},{8,36},{9,43},{10,50}}},
		lifemax_v={{{1,60},{2,96},{3,144},{4,192},{5,240},{6,300},{7,360},{8,432},{9,516},{10,600}}},
		damage_all_resist={{{1,10},{2,16},{3,23},{4,31},{5,40},{6,50},{7,61},{8,73},{9,86},{10,100}}},
		addphysicsdamage_p={{{1,20},{2,32},{3,46},{4,62},{5,80},{6,100},{7,122},{8,146},{9,172},{10,200}}},
		addphysicsmagic_p={{{1,20},{2,32},{3,46},{4,62},{5,80},{6,100},{7,122},{8,146},{9,172},{10,200}}},
		skill_statetime={18}
	},
	
	chuzhanshachang={
		lifemax_p={{{1,5},{2,8},{3,12},{4,16},{5,20},{6,25},{7,30},{8,36},{9,43},{10,50}}},
		lifemax_v={{{1,60},{2,96},{3,144},{4,192},{5,240},{6,300},{7,360},{8,432},{9,516},{10,600}}},
		damage_all_resist={{{1,10},{2,16},{3,23},{4,31},{5,40},{6,50},{7,61},{8,73},{9,86},{10,100}}},
		addphysicsdamage_p={{{1,20},{2,32},{3,46},{4,62},{5,80},{6,100},{7,122},{8,146},{9,172},{10,200}}},
		addphysicsmagic_p={{{1,20},{2,32},{3,46},{4,62},{5,80},{6,100},{7,122},{8,146},{9,172},{10,200}}},
		skill_statetime={18}
	},
	
	--领土头衔技能，抵御攻击
	ignoreattack_skill={
		ignoreattack={
			[1]={	--(lvl自己-划分等级)*成长值
				{1, (3-FightSkill.tbParam.nTitleLevel)*FightSkill.tbParam.nTitleGrowValue}, 
				{2, (4-FightSkill.tbParam.nTitleLevel)*FightSkill.tbParam.nTitleGrowValue}, 
				{3, (5-FightSkill.tbParam.nTitleLevel)*FightSkill.tbParam.nTitleGrowValue}, 
				{4, (6-FightSkill.tbParam.nTitleLevel)*FightSkill.tbParam.nTitleGrowValue}, 
				{5, (7-FightSkill.tbParam.nTitleLevel)*FightSkill.tbParam.nTitleGrowValue}, 
				{6, (8-FightSkill.tbParam.nTitleLevel)*FightSkill.tbParam.nTitleGrowValue}, 
				{7, (9-FightSkill.tbParam.nTitleLevel)*FightSkill.tbParam.nTitleGrowValue},
				},	
			[2]={	--等级修正 =  [100+(lvl自己-划分等级)^2*c] /100
				{1, 100+((3-FightSkill.tbParam.nTitleLevel)^FightSkill.tbParam.nTitleLevelPower)*FightSkill.tbParam.nTitleLevelAdjust}, 
				{2, 100+((4-FightSkill.tbParam.nTitleLevel)^FightSkill.tbParam.nTitleLevelPower)*FightSkill.tbParam.nTitleLevelAdjust}, 
				{3, 100+((5-FightSkill.tbParam.nTitleLevel)^FightSkill.tbParam.nTitleLevelPower)*FightSkill.tbParam.nTitleLevelAdjust}, 
				{4, 100+((6-FightSkill.tbParam.nTitleLevel)^FightSkill.tbParam.nTitleLevelPower)*FightSkill.tbParam.nTitleLevelAdjust}, 
				{5, 100+((7-FightSkill.tbParam.nTitleLevel)^FightSkill.tbParam.nTitleLevelPower)*FightSkill.tbParam.nTitleLevelAdjust}, 
				{6, 100+((8-FightSkill.tbParam.nTitleLevel)^FightSkill.tbParam.nTitleLevelPower)*FightSkill.tbParam.nTitleLevelAdjust}, 
				{7, 100+((9-FightSkill.tbParam.nTitleLevel)^FightSkill.tbParam.nTitleLevelPower)*FightSkill.tbParam.nTitleLevelAdjust}, 
				},	
			[3]={{1, 4}, {6, 4}},	--初始值
			},
	},
	chopskill={ --官印属性共享用技能
		autoskill={{{1,33},{2,33}},{{1,1},{2,2}}},
		skill_statetime={{{1,-1},{2,-1}}}
	},
	chopskill_team={ --官印属性共享用技能_队友
		missile_hitcount			={{{1,10},{2,10},{8,10}}},
		skilldamageptrim			={{{1, 5*0.5},{2,10*0.5},{8,10*0.5}}},
		allseriesstateresistrate	={{{1,30*0.5},{2,50*0.5},{8,50*0.5}}},
		lifemax_p					={{{1,30*0.5},{2,50*0.5},{8,50*0.5}}},
		manamax_p					={{{1,30*0.5},{2,50*0.5},{8,50*0.5}}},
		seriesstate_added			={{{1,30*0.5},{2,50*0.5},{8,50*0.5}}},
	},
	chopskill_self={ --官印属性共享用技能_自身
		skilldamageptrim			={{{1, 5},{2,10},{8,10}}},
		allseriesstateresistrate	={{{1,30},{2,50},{8,50}}},
		lifemax_p					={{{1,30},{2,50},{8,50}}},
		manamax_p					={{{1,30},{2,50},{8,50}}},
		seriesstate_added			={{{1,30},{2,50},{8,50}}},
	},

-------------------激活装备属性-------------
	xkd_avtive_equip={ --buff激活装备属性
		skill_activeequipattrib ={{{1,1},{2,2}}},
	},
	armor_reduce_speed={ -- 装备耐久度下降的速度
		magic_item_abrade_p={{{1,10},{2,20}}},
	},
	
	dulonggiac={
		fastwalkrun_p={{{1,30},{20,30}}},
		seriesenhance={{{1,50},{2,50}}},
		seriesabate={{{1,50},{2,50}}},
		-- skill_statetime={{{1,-1},{2,-1}}},
	},
}

FightSkill:AddMagicData(tb)

local tbSkill	= FightSkill:GetClass("tongweixianhua");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("\nCách %s giây thi triển ：<color=green>Thông Vi Hiển Hóa<color>\n<color=blue>Hiệu quả bản thân::<color>\nSát thương quái: +<color=gold>%s%%<color>\nSinh lực tối đa: +<color=gold>%s%%<color>\nNội lực tối đa: +<color=gold>%s%%<color>\n<color=blue>Hiệu quả đồng đội:<color>\nSát thương quái: +<color=gold>%s%%<color>\nDuy trì<color=gold>%s giây<color>",
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime),
		tbChildInfo2.tbWholeMagic["npcdamageadded"][1],
		tbChildInfo2.tbWholeMagic["lifemax_p"][1],
		tbChildInfo2.tbWholeMagic["manamax_p"][1],
		tbChildInfo.tbWholeMagic["npcdamageadded"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("bootskill");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	local szMsg	= string.format("\nCách %s giây thi triển： <color=green>Du Long Chân Khí<color>\n<color=blue>Hiệu quả bản thân:<color>\nTốc độ di chuyển: +<color=gold>%s%%<color>\nCường hóa tương khắc ngũ hành: +<color=gold>%s<color>\nNhược hóa tương khắc ngũ hành: +<color=gold>%s<color>\n<color=blue>Hiệu quả đồng đội:<color>\nTốc độ di chuyển: +<color=gold>%s%%<color>\nCường hóa tương khắc ngũ hành: +<color=gold>%s<color>\nNhược hóa tương khắc ngũ hành: +<color=gold>%s<color>\nDuy trì <color=gold>%s giây<color>",
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime),
		tbChildInfo2.tbWholeMagic["fastwalkrun_p"][1],
		tbChildInfo2.tbWholeMagic["seriesenhance"][1],
		tbChildInfo2.tbWholeMagic["seriesabate"][1],
		tbChildInfo.tbWholeMagic["fastwalkrun_p"][1],
		tbChildInfo.tbWholeMagic["seriesenhance"][1],
		tbChildInfo.tbWholeMagic["seriesabate"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("chopskill");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nStartSkillId, tbChildInfo.tbEvent.nLevel);
	
	local tb = {
			"Tỷ lệ gây thọ thương: +<color=gold>",
			"Tỷ lệ suy nhược: +<color=gold>",
			"Tỷ lệ làm chậm: +<color=gold>",
			"Tỷ lệ bỏng: +<color=gold>",
			"Tỷ lệ choáng: +<color=gold>",
			"Tỷ lệ hiệu quả ngũ hành: +<color=gold>",
		};
	local nSeries = me.nSeries;
	if (nSeries >  6 or nSeries <=0) then
		nSeries = 6;
	end;
	
	local szMsg1 = tb[nSeries] .. tbChildInfo2.tbWholeMagic["seriesstate_added"][1] .. "<color>";
	local szMsg2 = tb[nSeries] .. tbChildInfo.tbWholeMagic["seriesstate_added"][1] .. "<color>";
	
	local szMsg	= string.format("\n<color=blue>Hiệu quả bản thân:<color>\nPhát huy lực tấn công cơ bản: +<color=gold>%s%%<color>\nXác suất trạng thái ngũ hành: -<color=gold>%s<color>\nTỷ lệ sinh mạng: +<color=gold>%s%%<color>\nTỷ lệ nội lực: +<color=gold>%s%%<color>\n%s\n<color=blue>Hiệu quả đồng đội:<color>\nPhát huy lực tấn công cơ bản: +<color=gold>%s%%<color>\nXác suất trạng thái ngũ hành: -<color=gold>%s<color>\nTỷ lệ sinh lực: +<color=gold>%s%%<color>\nTỷ lệ nội lực: +<color=gold>%s%%<color>\n%s\nSố mục tiêu ảnh hưởng lớn nhất: <color=gold>%s<color>\nDuy trì <color=gold>%s giây<color>",
		tbChildInfo2.tbWholeMagic["skilldamageptrim"][1],
		tbChildInfo2.tbWholeMagic["allseriesstateresistrate"][1],
		tbChildInfo2.tbWholeMagic["lifemax_p"][1],
		tbChildInfo2.tbWholeMagic["manamax_p"][1],
		szMsg1,
		tbChildInfo.tbWholeMagic["skilldamageptrim"][1],
		tbChildInfo.tbWholeMagic["allseriesstateresistrate"][1],
		tbChildInfo.tbWholeMagic["lifemax_p"][1],
		tbChildInfo.tbWholeMagic["manamax_p"][1],
		szMsg2,
		tbChildInfo.tbWholeMagic["missile_hitcount"][1],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("tianxiashengong");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("Tự kích hoạt khi trọng thương: <color=gold>%d%%<color>\nMiễn nhiễm sát thương, duy trì <color=Gold>%s giây<color>\nGiãn cách thi triển: <color=Gold>%s giây<color>",
		tbAutoInfo.nPercent,
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill = FightSkill:GetClass("changeseriesdammage")

function tbSkill:GetExtraDesc(tbInfo)
	if (not tbInfo) then
		return "";
	end

	local szMsg	= string.format("<color=gray>(状态下再次使用可关闭技能)<color>");
	return szMsg;
end

local tbSkill	= FightSkill:GetClass("noobbuff");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local szMsg	= string.format("Khi sinh lực giảm dưới 50%% tự động kích hoạt:\n    <color=green>Chân Khí Hộ Thể<color>\n    Hóa giải sát thương <color=Gold>%s%%<color>, duy trì <color=Gold>%s giây<color>\n    Thời gian giãn cách: <color=Gold>%s giây<color>",
		tbChildInfo.tbWholeMagic["dynamicmagicshield_v"][2],
		FightSkill:Frame2Sec(tbChildInfo.nStateTime),
		FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime));
	return szMsg;
end;

local tbSkill	= FightSkill:GetClass("xixasuitskill");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2 = KFightSkill.GetSkillInfo(1996, tbAutoInfo.nSkillLevel);
	
	local tbMsg = {};
	local szMsg = "";
	--szMsg = szMsg.."<color=green>黯相望<color>\n";
	szMsg = szMsg.."Mỗi đồng đội ở gần giúp đạt trạng thái:\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo2, 0);
	for i=1, #tbMsg do
		szMsg = szMsg.."    "..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	--szMsg = szMsg.."\n<color=gold>非隐身状态叠加速度加倍<color>";
	return szMsg;
end;
