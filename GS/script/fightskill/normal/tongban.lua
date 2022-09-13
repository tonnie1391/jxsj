Require("\\script\\fightskill\\fightskill.lua")
--同伴
local tb	= {
	yishouyinyang={ --益寿阴阳
		lifemax_p={{{1,12},{3,72*FightSkill.tbParam.nTongBan/100},{6,72},{7,72*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,6},{3,36*FightSkill.tbParam.nTongBan/100},{6,36},{7,36*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,120},{3,720*FightSkill.tbParam.nTongBan/100},{6,720},{7,720*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	yishouyinyang_jue={ --益寿阴阳·绝
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_hurt_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	yishouyinyang_ji={ --益寿阴阳·极
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_weak_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	yishouyinyang_zhen={ --益寿阴阳·震
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_slowall_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	yishouyinyang_han={ --益寿阴阳·寒
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_burn_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	yishouyinyang_ming={ --益寿阴阳·冥
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_stun_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	rumuchunfeng_jue={ --如沐春风·绝
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_hurt_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,6},{3,24*FightSkill.tbParam.nTongBan/100},{6,24},{7,24*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	rumuchunfeng_ji={ --如沐春风·极
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_weak_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,6},{3,24*FightSkill.tbParam.nTongBan/100},{6,24},{7,24*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
		rumuchunfeng_zhen={ --如沐春风·震
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_slowall_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,6},{3,24*FightSkill.tbParam.nTongBan/100},{6,24},{7,24*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	rumuchunfeng_han={ --如沐春风·寒
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_burn_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,6},{3,24*FightSkill.tbParam.nTongBan/100},{6,24},{7,24*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	rumuchunfeng_ming={ --如沐春风·冥
		lifemax_p={{{1,9},{3,56*FightSkill.tbParam.nTongBan/100},{6,56},{7,56*FightSkill.tbParam.nTAdd}}},
		manamax_p={{{1,5},{3,28*FightSkill.tbParam.nTongBan/100},{6,28},{7,28*FightSkill.tbParam.nTAdd}}},
		lifemax_v={{{1,90},{3,560*FightSkill.tbParam.nTongBan/100},{6,560},{7,560*FightSkill.tbParam.nTAdd}}},
		state_stun_resisttime={{{1,45},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,6},{3,24*FightSkill.tbParam.nTongBan/100},{6,24},{7,24*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	 wuxingwuxiang={ --五行无相
		damage_all_resist={{{1,14},{3,84*FightSkill.tbParam.nTongBan/100},{6,84},{7,84*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},			
	wuxingwuxiang_fushi={ --五行无相·伏石
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_physics_resist={{{1,7},{3,42*FightSkill.tbParam.nTongBan/100},{6,42},{7,42*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_zhuchan={ --五行无相·朱蟾
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_poison_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_nishui={ --五行无相·逆水
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_cold_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_yueguang={ --五行无相·越光
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_fire_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_jumu={ --五行无相·巨木
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_light_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	--寒武遗迹同伴
	wuxingwuxiang_jue={ --五行无相·绝
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_physics_resist={{{1,7},{3,42*FightSkill.tbParam.nTongBan/100},{6,42},{7,42*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,9},{3,36*FightSkill.tbParam.nTongBan/100},{6,36},{7,36*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_ji={ --五行无相·极
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_poison_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,9},{3,36*FightSkill.tbParam.nTongBan/100},{6,36},{7,36*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_zhen={ --五行无相·震
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_cold_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,9},{3,36*FightSkill.tbParam.nTongBan/100},{6,36},{7,36*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_han={ --五行无相·寒
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_fire_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,9},{3,36*FightSkill.tbParam.nTongBan/100},{6,36},{7,36*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wuxingwuxiang_ming={ --五行无相·冥
		damage_all_resist={{{1,11},{3,66*FightSkill.tbParam.nTongBan/100},{6,66},{7,66*FightSkill.tbParam.nTAdd}}},
		damage_light_resist={{{1,15},{3,90*FightSkill.tbParam.nTongBan/100},{6,90},{7,90*FightSkill.tbParam.nTAdd}}},
		expenhance_p={{{1,9},{3,36*FightSkill.tbParam.nTongBan/100},{6,36},{7,36*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	
	zhuiyingjue={ --追影诀
		ignoredefenseenhance_v={{{1,80},{3,480*FightSkill.tbParam.nTongBan/100},{6,480},{7,480*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	wunianjing={ --无念经
		ignoredefenseenhance_v={{{1,64},{3,384*FightSkill.tbParam.nTongBan/100},{6,384},{7,384*FightSkill.tbParam.nTAdd}}},
		attackratingenhance_p={{{1,28},{3,128*FightSkill.tbParam.nTongBan/100},{6,128},{7,128*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},		
	huishenjingxin={ --会神静心
		deadlystrikeenhance_r={{{1,60},{3,360*FightSkill.tbParam.nTongBan/100},{6,360},{7,360*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},			
	jinghongyiji={ --惊鸿一击
		deadlystrikeenhance_r={{{1,48},{3,288*FightSkill.tbParam.nTongBan/100},{6,288},{7,288*FightSkill.tbParam.nTAdd}}},
		deadlystrikedamageenhance_p={{{1,6},{3,36*FightSkill.tbParam.nTongBan/100},{6,36},{7,36*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	tabumizong={ --踏步迷踪
		adddefense_v={{{1,80},{3,480*FightSkill.tbParam.nTongBan/100},{6,480},{7,480*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	xukongshanying={ --虚空闪影
		adddefense_v={{{1,64},{3,384*FightSkill.tbParam.nTongBan/100},{6,384},{7,384*FightSkill.tbParam.nTAdd}}},
		defencedeadlystrikedamagetrim={{{1,5},{3,30*FightSkill.tbParam.nTongBan/100},{6,30},{7,30*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	xukongshanying3={ --虚空闪影_vip
		autoskill={{{1,108},{2,108}},{{1,1},{10,10}}},
		adddefense_v={{{1,64},{3,384*FightSkill.tbParam.nTongBan/100},{6,384},{7,384*FightSkill.tbParam.nTAdd}}},
		defencedeadlystrikedamagetrim={{{1,5},{3,30*FightSkill.tbParam.nTongBan/100},{6,30},{7,30*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},	
	xukongshanying3_team={ --虚空闪影_vip_队友
		ignoreskill={{{1,0},{3,0},{4,2},{6,6},{7,7}},0,{{1,9},{2,9}}},
		skill_statetime={{{1,5*18},{2,5*18}}},
	},	
	xukongshanying3_self={ --虚空闪影_vip_自身
		ignoreskill={{{1,0},{3,0},{4,4},{6,12},{7,14}},0,{{1,9},{2,9}}},
		skill_statetime={{{1,5*18},{2,5*18}}},
	},	
	miaoshouhuichun={ --妙手回春
		fastlifereplenish_v={{{1,25},{3,150*FightSkill.tbParam.nTongBan/100},{6,150},{7,150*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	cibeixiyu={ --慈悲细雨
		fastlifereplenish_v={{{1,20},{3,120*FightSkill.tbParam.nTongBan/100},{6,120},{7,120*FightSkill.tbParam.nTAdd}}},
		fastmanareplenish_v={{{1,16},{3,96*FightSkill.tbParam.nTongBan/100},{6,96},{7,96*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pokongzhanying={ --破空斩影
		skilldamageptrim={{{1,3},{3,18*FightSkill.tbParam.nTongBan/100},{6,18},{7,18*FightSkill.tbParam.nTAdd}}},
		skillselfdamagetrim={{{1,3},{3,18*FightSkill.tbParam.nTongBan/100},{6,18},{7,18*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pokongzhanying_xuanwu={ --破空斩影·玄武
		skilldamageptrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		skillselfdamagetrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		state_slowall_attacktime={{{1,40},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pokongzhanying_huanglong={ --破空斩影·黄龙
		skilldamageptrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		skillselfdamagetrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		state_stun_attacktime={{{1,40},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pokongzhanying_qinglong={ --破空斩影·青龙
		skilldamageptrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		skillselfdamagetrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		state_weak_attacktime={{{1,40},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pokongzhanying_baihu={ --破空斩影·白虎
		skilldamageptrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		skillselfdamagetrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		state_hurt_attacktime={{{1,40},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	pokongzhanying_zhuque={ --破空斩影·朱雀
		skilldamageptrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		skillselfdamagetrim={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		state_burn_attacktime={{{1,40},{3,280*FightSkill.tbParam.nTongBan/100},{6,280},{7,280*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
	ganyulinhua={ --甘雨霖华
		lifereplenish_p={{{1,4},{3,24*FightSkill.tbParam.nTongBan/100},{6,24},{7,24*FightSkill.tbParam.nTAdd}}},
		manareplenish_p={{{1,2},{3,12*FightSkill.tbParam.nTongBan/100},{6,12},{7,12*FightSkill.tbParam.nTAdd}}},
		skill_statetime={{{1,-1},{2,-1}}},
	},
}
FightSkill:AddMagicData(tb)


local tbSkill	= FightSkill:GetClass("xukongshanying3");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbChildInfo2	= KFightSkill.GetSkillInfo(tbChildInfo.tbEvent.nVanishedSkillId, tbChildInfo.tbEvent.nLevel, me, 8);
	if tbAutoInfo.nPercent == 0 then
		return "";
	end
	if tbChildInfo2.tbWholeMagic["ignoreskill"][1] == 0 then
		return "";
	end
	local szMsg	= string.format("<color=blue>Hiệu quả bản thân: <color>\nXác suất né tấn công đặc hiệu: tăng <color=gold>%s%%<color>\n<color=blue>Hiệu quả đồng đội: <color>\nXác suất né tấn công đặc hiệu: tăng <color=gold>%s%%<color>",
		tbChildInfo2.tbWholeMagic["ignoreskill"][1],
		tbChildInfo.tbWholeMagic["ignoreskill"][1]);
	return szMsg;
end;
