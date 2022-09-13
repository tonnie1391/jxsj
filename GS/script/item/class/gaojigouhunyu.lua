--高级勾魂玉
--sunduoliang
--2008.10.30

local tbItem = Item:GetClass("gaojigouhunyu");
tbItem.tbBoss = 
{
	--等级
	[95] = {
		--boss名称，Id，五行
		{"<color=gold>柔小翠（金）<color>", 2934 , 1},
		{"<color=green>张善德（木）<color>",2935, 2},
		{"<color=blue>贾逸山（水）<color>",2936, 3},
		{"<color=red>乌山青（火）<color>",2937, 4},
		{"<color=wheat>陈无命（土）<color>",2938, 5},
	}
}

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

function tbItem:OnUse()
	local nLevel = 95;
	local szMsg = string.format("请选择你想要召唤的%s级Boss", nLevel);
	local tbOpt = {};
	for nId, tbBoss in ipairs(self.tbBoss[nLevel]) do
		table.insert(tbOpt, {tbBoss[1], self.CallBoss, self, it.dwId, nId, nLevel});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:CallBoss(nItemId, nId, nLevel, nSure)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return
	end
	if me.nFightState == 0 then
		Dialog:Say("高级勾魂玉只能在野外地图和家族关卡的战斗区域使用。");
		return 0;
	end
	if not nSure then
		local szMsg = string.format("您确定要召唤%s吗？", self.tbBoss[nLevel][nId][1]);
		local tbOpt = {
			{"我确定要召唤", self.CallProcess, self, nItemId, nId, nLevel},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	if me.DelItem(pItem) ~= 1 then
		return;
	end
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	local pNpc = KNpc.Add2(self.tbBoss[nLevel][nId][2], nLevel, self.tbBoss[nLevel][nId][3], nMapId, nPosX, nPosY, 0, 1);
	if pNpc then
		me.Msg(string.format("您成功召唤出了%s。", self.tbBoss[nLevel][nId][1]));
	end
end

function tbItem:CallProcess(nItemId, nId, nLevel)
	GeneralProcess:StartProcess("召唤中...", 1 * Env.GAME_FPS, {self.CallBoss, self, nItemId, nId, nLevel, 1}, nil, tbEvent);
end
