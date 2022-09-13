-- 文件名　：qingdian_yanhua.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-08-06 17:49:21
-- 描  述  ：
local tbClass = Item:GetClass("qingdian_yanhua")
tbClass.TASK_GROUP_ID = 2093;
tbClass.TASK_DAY	= 16;
tbClass.TASK_COUNT	= 17;
tbClass.MAX_COUNT_EVERYDAY	= 5;  -- 每个玩家每天最多使用5次
tbClass.tbAward =
{
	--概率，奖励经验倍率，公告(总概率10000)
	{5000, 10 , 0},
	{3000, 15 , 0},
	{1000, 20 , 0},
	{600, 30 , 0},
	{300, 40 , 0},
	{100, 50 , 1},
}

tbClass.tbTalk = {
	"您今天已经使用了%d个%s，不能再使用了，您可以把这个烟花送给您的朋友使用。",
	"您已经使用过了这个%s，不能再使用，但您可以把烟花赠送给您的朋友使用哦。",
	"您成功使用了%s。",
	"%s燃放了%s，为普天同庆贡献了自己的力量。",
	"烟花还能使用%s次，使用后能获得丰厚奖励。您是否确定使用呢？",
	"<color=yellow>您已使用过该烟花<color>",
};

tbClass.nDefaultSkillId = 307

function tbClass:OnUse()
	--使用物品
	self:SureUse(it.dwId);
	return 0;
end

function tbClass:InitGenInfo()
	--it.SetTimeOut(0, GetTime()+3 * 3600);
	local nTimeOut = it.GetExtParam(1);
	if nTimeOut and nTimeOut ~= 0 then
		it.SetTimeOut(0, GetTime() + nTimeOut);
	end
	return	{ };
end

function tbClass:SureUse(nItemId, nFlag)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	--local tbOption = self:GetOption();
	local nDay = tonumber(Lib:GetLocalDay());
	if nDay > me.GetTask(self.TASK_GROUP_ID,self.TASK_DAY) then
		me.SetTask(self.TASK_GROUP_ID,self.TASK_DAY, nDay);
		me.SetTask(self.TASK_GROUP_ID,self.TASK_COUNT, 0);
	end
	if me.GetTask(self.TASK_GROUP_ID,self.TASK_COUNT) >= self.MAX_COUNT_EVERYDAY then
		Dialog:Say(string.format(self.tbTalk[1], self.MAX_COUNT_EVERYDAY, pItem.szName));
		return 0
	end
	local tbId = {};
	for i=1, 4 do
		local nId = pItem.GetGenInfo(i,0);
		if nId > 0 then
			if nId == me.nId then
				Dialog:Say(string.format(self.tbTalk[2], pItem.szName));
				return 0;
			end
			table.insert(tbId, nId);
		end
	end
	if #tbId <= 0 or nFlag then
		if #tbId >= 4 then
			if me.DelItem(pItem) ~= 1 then
				return 0
			end
		else
			pItem.SetGenInfo(#tbId + 1,me.nId);
			pItem.Sync();
		end
		me.SetTask(self.TASK_GROUP_ID,self.TASK_COUNT, me.GetTask(self.TASK_GROUP_ID,self.TASK_COUNT) + 1);
		Dialog:Say(string.format(self.tbTalk[3], pItem.szName));
		--me.CastSkill(307, 1, -1, me.GetNpc().nIndex);
		local nExtParamId = 3;
		local tbSkills = {};
		local nSkillId = pItem.GetExtParam(nExtParamId)
		while (nSkillId and nSkillId ~= 0) do
			tbSkills[#tbSkills + 1] = nSkillId;
			nExtParamId = nExtParamId + 1;
			nSkillId = pItem.GetExtParam(nExtParamId);
		end
		local nRand = MathRandom(1, #tbSkills);
		local nSkill = tbSkills[nRand] or self.nDefaultSkillId;
		me.CastSkill(nSkill, 1, -1, me.GetNpc().nIndex);
		--获得奖励.
		local nRandom = MathRandom(1,10000)
		local nRandomCount = 0;
		for _, tbParam in pairs(self.tbAward) do
			nRandomCount = nRandomCount + tbParam[1];
			if nRandomCount >= nRandom then
				me.AddExp(me.GetBaseAwardExp() * tbParam[2] * (pItem.GetExtParam(2)/100));
				if tbParam[3] == 1 then
					local szAnnouce = string.format(self.tbTalk[4], me.szName, pItem.szName);
					KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szAnnouce);
				end
				return 0;
			end
		end
		
		return 0;
	end

	local szMsg = string.format("这枚烟花已经有%s个人使用过，他们是：\n<color=yellow>", #tbId);
	for _, nId in ipairs(tbId) do
		local szName = KGCPlayer.GetPlayerName(nId) or "神秘人物";
		szMsg = szMsg .. szName .. "\n";
	end
	szMsg = szMsg .. "<color>".. string.format(self.tbTalk[5], (5 - #tbId));
	local tbOpt = {
		{"确定使用", self.SureUse, self, nItemId, 1},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbClass:GetTip(nState)
	local nUseCount = 0;
	local nMeUse = 0;
	for i=1, 4 do
		local nId = it.GetGenInfo(i,0);
		if nId > 0 then
			if nId == me.nId then
				nMeUse = 1;
			end
			nUseCount = nUseCount + 1;
		end
	end	
	local szTip = "";
	szTip = szTip..string.format("<color=0x8080ff>右键点击使用<color>\n");
	szTip = szTip..string.format("<color=yellow>剩余使用次数: %s<color>\n", 5 - nUseCount);
	if nMeUse == 1 then
		szTip = szTip.. self.tbTalk[6];
	end
	return szTip;
end
