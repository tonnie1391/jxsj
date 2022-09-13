--任务技能
local tb	= {
	task_avatar1={ --新手任务npc变身
		--参数1,变身npcid,参数2变身npc等级,参数3变身类型:1变外观,2变属性,4改变技能
		domainchangeself={{{1,10159},{2,10165},{3,10165}},{{1,15},{2,15}},{{1,1},{2,1}}},
		fastwalkrun_p={{{1,-60},{2,0},{3,0}}},
		defense_state={1},
		skill_statetime={{{1,60*18},{2,5*60*18},{3,5*60*18}}},
	},
	task_autoatk={ --子书青自动释放伤害技能_10
		autoskill={{{1,39},{2,39}},{{1,1},{10,10}}},
		skill_statetime={-1},
	},
}

FightSkill:AddMagicData(tb)


local tbSkill	= FightSkill:GetClass("task_autoatk");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	
	local tbMsg = {};
	local szMsg = "";
	local szSkillName = FightSkill:GetSkillName(tbAutoInfo.nSkillId);
	szMsg = szMsg.."\n每<color=gold>"..FightSkill:Frame2Sec(tbAutoInfo.nPerCastTime).."<color>秒自动释放以下技能：\n";
	
	szMsg = szMsg.."<color=green>["..szSkillName.."]<color>\n";
	FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
	for i=1, #tbMsg do
		szMsg = szMsg..""..tostring(tbMsg[i])..(i ~= #tbMsg and "\n" or "");
	end
	return szMsg;
end;
