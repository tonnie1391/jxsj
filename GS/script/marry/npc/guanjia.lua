-- 文件名　：guanjia.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-28 21:11:54
-- 功能描述：结婚系统npc（管家）

local tbNpc = Npc:GetClass("marry_guanjia");

--=============================================================

-- 在不同地图的管家npc可以给玩家释放的buff信息
tbNpc.TB_SKILL_INFO  = {
	["city"] = {
		{nSkillId = 876, nSkillLevel = 8},
		{nSkillId = 877, nSkillLevel = 8},
		{nSkillId = 878, nSkillLevel = 8},
		},
	["village"] = {
		{nSkillId = 876, nSkillLevel = 5},
		{nSkillId = 877, nSkillLevel = 5},
		{nSkillId = 878, nSkillLevel = 5},
		},
	};

--=============================================================

function tbNpc:OnDialog()
	local szMsg = self:GetChatMsg();
	if not szMsg then
		return;
	end
	local tbOpt = 
	{
		{"现在就领取祝福", self.GetBuffDlg, self},
		{"以后再来吧"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetChatMsg()
	local szMsg = "";
	local szMapClass = GetMapType(me.nMapId) or "";
	if (szMapClass ~= "village" and szMapClass ~= "city") then
		return;
	end
	
	local tbNpcData = him.GetTempTable("Marry");
	if (not tbNpcData) then
		return;
	end
	
	local szMaleName = tbNpcData.szMaleName;
	local szFemaleName = tbNpcData.szFemaleName;
	if (not szMaleName or not szFemaleName) then
		return;
	end
	
	if (szMapClass == "city") then
		szMsg = string.format("今天我家主人<color=yellow>%s<color>和<color=yellow>%s<color>举办<color=yellow>皇家典礼<color>，大家赶快去找江津村老月参加。我在此为大家送上祝福！",
			szMaleName, szFemaleName);
	elseif (szMapClass == "village") then
		szMsg = string.format("今天我家主人<color=yellow>%s<color>和<color=yellow>%s<color>举办<color=yellow>王侯典礼<color>，大家赶快去找江津村老月参加。我在此为大家送上祝福！",
			szMaleName, szFemaleName);
	else 
		return;
	end
	
	szMsg = szMsg .. "\n领取祝福条件：\n    1. 等级达到69级，已入门派。\n    2. 江湖威望排名达到5000名。";
	return szMsg;
end


function tbNpc:GetBuffDlg()
	local szMapClass = GetMapType(me.nMapId) or "";
	if (szMapClass ~= "village" and szMapClass ~= "city") then
		Dialog:Say("地面花海只能在城市、新手村、典礼场地使用。");
		return 0;
	end
	
	if (me.nLevel < 69) then
		Dialog:Say("你的等级不足69级，不能领取祝福。");
		return 0;
	end
	
	if (me.nFaction == 0) then
		Dialog:Say("你还没有加入门派，不能领取祝福。");
		return 0;
	end
	
	local nPrestige = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PRESTIGE)
	if nPrestige == 0 then
		Dialog:Say("系统尚未进行威望排序，目前不能领取祝福。");
		return 0;
	end
	
	if (nPrestige > me.nPrestige) then
		Dialog:Say("您的威望排名不够，不能够领取祝福。\n只有威望排名前5000者才能领取祝福。");
		return 0;
	end
	
	local tbSkillInfo = self.TB_SKILL_INFO[szMapClass];
	if (not tbSkillInfo) then
		return 0;
	end
	
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nLastGetBuffDate = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_DATE_GETBUFF);
	if (nCurDate == nLastGetBuffDate) then
		Dialog:Say("你今天已经领取过祝福了，不能再次领取。");
		return 0;
	end
	
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	GeneralProcess:StartProcess("领取祝福...", 5 * Env.GAME_FPS,
		{self.GetBuff, self, me.szName, tbSkillInfo}, nil, tbEvent);
end

function tbNpc:GetBuff(szName, tbSkillInfo)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return 0;
	end
	
	for _, tbInfo in pairs(tbSkillInfo) do
		pPlayer.AddSkillState(tbInfo.nSkillId, tbInfo.nSkillLevel, 1, 32400, 1, 0, 1);
	end
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	pPlayer.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_DATE_GETBUFF, nCurDate);
	pPlayer.Msg("你已经收到祝福。");
end
