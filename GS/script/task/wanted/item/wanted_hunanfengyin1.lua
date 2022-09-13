-- 文件名　：wanted_hunanfengyin.lua
-- 创建者　：sunduoliang
-- 创建时间：2010-08-19 14:36:33

local tbItem = Item:GetClass("wanted_hunanfengyin1");
tbItem.tbCallBossRate = {	
					{nNpcId = 6895, nLevel = 120, nRate = 2000},	--夏小倩
					{nNpcId = 6896, nLevel = 120, nRate = 2000},	--秦仲
					{nNpcId = 6897, nLevel = 120, nRate = 2000},	--木超
					{nNpcId = 6898, nLevel = 120, nRate = 2000},	--紫苑
					{nNpcId = 6910, nLevel = 120, nRate = 1000},		--莺莺
					{nNpcId = 6916, nLevel = 120, nRate = 500},		--叶静
					{nNpcId = 6917, nLevel = 120, nRate = 500},		--宝玉
				};


function tbItem:OnUse()
	self:CallProcess(it.dwId);
	return 0;	
end

function tbItem:CallProcess(nItemId, nSure)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return
	end
	if me.nLevel < 80 then
		me.Msg("你的等级太低了，达到80级才允许使用！");
		return 0;
	end
	if me.nFightState == 0 then
		Dialog:Say("昏暗封印只能在野外地图和家族关卡的战斗区域使用。");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return 0;
	end
	if not nSure then
		local szMsg = string.format("您确定要召唤吗？");
		local tbOpt = {
			{"我确定要召唤", self.CallProcess, self, nItemId, 1},
			{"Để ta suy nghĩ lại"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nItemCount = pItem.nCount;
	if nItemCount <= 1 then
		if me.DelItem(pItem) ~= 1 then
			return;
		end
	else
		pItem.SetCount(nItemCount - 1, Item.emITEM_DATARECORD_REMOVE);
	end
	
	local tbBoss = self:GetRandomBossInfor();
	if not tbBoss then
		Dbg:WriteLog("Wanted", "Item", "HunAnFengYinTeShu", "CallBossF");
		return;
	end
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	local pNpc = KNpc.Add2(tbBoss.nNpcId, tbBoss.nLevel, -1, nMapId, nPosX, nPosY, 0, 1);
	if pNpc then
		me.Msg(string.format("您成功召唤出了%s。", pNpc.szName));
		
		local szLog = tostring(tbBoss.nNpcId);
		if (me.GetTeamId()) then
			local tbTeam = me.GetTeamMemberList();
			for i, pPlayer in pairs(tbTeam) do
				szLog = szLog..string.format(",%s", pPlayer.szName);
			end
		end
		
		StatLog:WriteStatLog("stat_info", "dadao", "usereal_teshu", me.nId, szLog);
	end
end

function tbItem:GetRandomBossInfor()
	local nMaxRandom = 0;
	for i, tbInfo in ipairs(self.tbCallBossRate) do
		nMaxRandom = nMaxRandom + tbInfo.nRate;
	end
	local nRateSum = 0;
	local nCurRate = MathRandom(1, nMaxRandom);
	for i, tbInfo in ipairs(self.tbCallBossRate) do
		nRateSum = nRateSum + tbInfo.nRate;
		if nCurRate <= nRateSum then
			return tbInfo;
		end
	end
	return nil;
end
