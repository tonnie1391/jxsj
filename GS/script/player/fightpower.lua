-- 文件名　：fightpower.lua
-- 创建者　：zhaoyu
-- 创建时间：2010/7/2 17:14:07

Player.tbFightPower = Player.tbFightPower or {};

local tbFightPower = Player.tbFightPower;

tbFightPower.TASK_GROUP = 2132;
tbFightPower.TASK_TOTAL_RANK		= 1; -- 总排名
tbFightPower.TASK_ACHIEVEMENT_RANK	= 2; -- 成就排名
tbFightPower.TASK_LEVEL_RANK		= 3; -- 等级排名
tbFightPower.TASK_ZHENYUAN_RANK		= {4, 5, 6}; -- 真元排名
tbFightPower.TASK_LOGTIME			= 9;  -- 上次记录玩家战斗力Log的时间
tbFightPower.TASK_FIGHTPOWER		= 10; -- 玩家战斗力
tbFightPower.TASK_MAX_LEVEL_FLAG	= 11; -- 满级战斗力都按第一名加标志

tbFightPower.ZHENYUAN_COUNT			= 3;	-- 真元个数

tbFightPower.nFightPowerEffect		= 1;

-- 获取成就排名加成的战斗力
function tbFightPower:GetPlayerAchievementPoint(pPlayer)
	return self:GetAchievementPoint(pPlayer.GetTask(self.TASK_GROUP, self.TASK_ACHIEVEMENT_RANK));
end

-- 获取等级排名加成的战斗力
function tbFightPower:GetPlayerLevelPoint(pPlayer)
	if pPlayer.GetTask(self.TASK_GROUP, self.TASK_MAX_LEVEL_FLAG) == 1 then
		return self.tbLevelPoint100[1];
	end
	return self:GetLevelPoint(pPlayer.GetTask(self.TASK_GROUP, self.TASK_LEVEL_RANK));
end

-- 获取真元附加的战斗力
function tbFightPower:GetPlayerZhenYuanPoint(pPlayer)
	local nPower = 0;
	for i = 1, self.ZHENYUAN_COUNT do
		local x = i + Item.EQUIPPOS_ZHENYUAN_MAIN - 1;
		local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, x, 0);
		if pItem then
			nPower = nPower + Item.tbZhenYuan:GetFightPower(pItem);
		end
	end
	return nPower;
end

-- 获取玩家的总战斗力
function tbFightPower:GetFightPower(pPlayer)
	if (self:IsFightPowerValid() ~= 1) then
		return 0;
	end
	local nPower = 0;
	nPower = nPower + self:GetPlayerAchievementPoint(pPlayer);
	nPower = nPower + self:GetPlayerLevelPoint(pPlayer);
	nPower = nPower + self:GetPlayerZhenYuanPoint(pPlayer);
	nPower = nPower + self:GetEquipFightPower(pPlayer);
	nPower = nPower + self:GetPiFengPower(pPlayer);
	nPower = nPower + self:GetMiJiPower(pPlayer);
	nPower = nPower + self:GetGuanYinPower(pPlayer);
	nPower = nPower + self:GetZhenFaPower(pPlayer);
	nPower = nPower + self:Get5XingYinPower(pPlayer);
	if (pPlayer.nPartnerCount > 0) then
		--nPower = nPower + self:GetPartnerEquipPower(pPlayer);
		nPower = nPower + self:GetAllPartnerFightPower(pPlayer);
	end
	return nPower;
end

function tbFightPower:PrintFightPower(pPlayer)
	local nPower = 0;
	print("成就", self:GetPlayerAchievementPoint(pPlayer));
	print("等级", self:GetPlayerLevelPoint(pPlayer));
	print("真元", self:GetPlayerZhenYuanPoint(pPlayer));
	print("装备", self:GetEquipFightPower(pPlayer));
	print("披风", self:GetPiFengPower(pPlayer));
	print("秘籍", self:GetMiJiPower(pPlayer));
	print("官印", self:GetGuanYinPower(pPlayer));
	print("阵法", self:GetZhenFaPower(pPlayer));
	print("五行印", self:Get5XingYinPower(pPlayer));
	if (pPlayer.nPartnerCount >= 0) then
		--print("同伴装备", self:GetPartnerEquipPower(pPlayer));
		print("同伴", self:GetAllPartnerFightPower(pPlayer));
	end
	print(pPlayer.szName, "总战斗力:", self:GetFightPower(pPlayer));
end

-- 数据埋点
function tbFightPower:LogFightPower(pPlayer)
	local szLog = "";
    local pItem;
    local nPower = 0;
    for nKey, tbRoomInfo in ipairs(self.tbEquipRoomInfo) do
		for x = 0, 9 do
			pItem = pPlayer.GetItem(tbRoomInfo.nRoomId, x, 0);
			if pItem then
				nPower = tbRoomInfo:GetFightPower(pItem) or 0;
				szLog = szLog .. nPower;
			end
			szLog = szLog .. ",";
		end
	end
	szLog = szLog .. string.format("%g,", self:GetMiJiPower(pPlayer));
	szLog = szLog .. string.format("%g,", self:GetZhenFaPower(pPlayer));
	szLog = szLog .. string.format("%g,", self:Get5XingYinPower(pPlayer));
	szLog = szLog .. string.format("%g,", self:GetPiFengPower(pPlayer));
	szLog = szLog .. string.format("%g,", self:GetGuanYinPower(pPlayer));
	szLog = szLog .. string.format("%g,", self:GetPlayerLevelPoint(pPlayer));		
	szLog = szLog .. string.format("%g,", self:GetPlayerAchievementPoint(pPlayer));		
	szLog = szLog .. string.format("%g,", self:GetPlayerZhenYuanPoint(pPlayer));		
	if (pPlayer.nPartnerCount >= 0) then
		szLog = szLog .. string.format("%g,", self:GetAllPartnerFightPower(pPlayer));
	else
		szLog = szLog .. "0,";
	end
	--if pPlayer.nActivePartner >= 0 then
		--szLog = szLog .. string.format("%g,", self:GetPartnerEquipPower(pPlayer));
	--else
		--szLog = szLog .. "0,";
	--end
	szLog = "(" .. szLog .. ")";
	Dbg:WriteLog("FightPower", "PlayerEquip", pPlayer.szAccount, pPlayer.szName, szLog);
end

-- 获取总战斗力排名
function tbFightPower:GetRank(pPlayer)
	return pPlayer.GetTask(self.TASK_GROUP, self.TASK_TOTAL_RANK);
end

-- 获取成就排名
function tbFightPower:GetAchievementRank(pPlayer)
	return pPlayer.GetTask(self.TASK_GROUP, self.TASK_ACHIEVEMENT_RANK);
end

-- 获取等级排名
function tbFightPower:GetLevelRank(pPlayer)
	return pPlayer.GetTask(self.TASK_GROUP, self.TASK_LEVEL_RANK);
end

-- 根据成就排名，获取可以加的战斗力点数
function tbFightPower:GetAchievementPoint(nRank)
	if (nRank == 0 or nRank > 3000) then
		return 0;
	elseif (nRank > 0 and nRank <= 100) then
		while (self.tbAchievementPoint100[nRank] == nil) do
			nRank = nRank + 1;
		end
		return self.tbAchievementPoint100[nRank];
	else
		for _, tbInfo in ipairs(self.tbAchievementPoint3000) do
			if nRank >= tbInfo[1] and nRank <= tbInfo[2] then
				return math.floor(tbInfo[4] + (nRank - tbInfo[1]) / (tbInfo[2] - tbInfo[1]) * (tbInfo[3] - tbInfo[4]));
			end
		end
	end	
end

-- 根据等级排名，获取可以加的战斗力点数
function tbFightPower:GetLevelPoint(nRank)
	if (nRank == 0 or nRank > 3000) then
		return 0;
	elseif (nRank > 0 and nRank <= 100) then
		while (self.tbLevelPoint100[nRank] == nil) do
			nRank = nRank + 1;
		end
		return self.tbLevelPoint100[nRank];
	else
		for _, tbInfo in ipairs(self.tbLevelPoint3000) do
			if nRank >= tbInfo[1] and nRank <= tbInfo[2] then
				return math.floor(tbInfo[4] + (nRank - tbInfo[1]) / (tbInfo[2] - tbInfo[1]) * (tbInfo[3] - tbInfo[4]));
			end
		end
	end
end

-- 装备总战斗力
function tbFightPower:GetEquipFightPower(pPlayer)
    local nTotal = 0;
    local pItem;
    for _, tbRoomInfo in ipairs(self.tbEquipRoomInfo) do
		for x = 0, 9 do
			pItem = pPlayer.GetItem(tbRoomInfo.nRoomId, x, 0);
			if pItem then
				nTotal = nTotal + tbRoomInfo:GetFightPower(pItem);
			end
		end
	end
    return nTotal;
end

--设置排名到任务变量
function tbFightPower:UpdatePowerByRank(pPlayer)
	if IsGlobalServer() then
		return;
	end
	local nTotalRank = GetPlayerHonorRank(pPlayer.nId, 17, 0, 0);
	local nAchievementRank = GetPlayerHonorRank(pPlayer.nId, 18, 0, 0);
	local nLevelRank = GetPlayerHonorRank(pPlayer.nId, 19, 0, 0);
	for i = 1, self.ZHENYUAN_COUNT do
		local x = i + Item.EQUIPPOS_ZHENYUAN_MAIN - 1;
		local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, x);
		if pItem then
			local nRank, nValue = Ladder.tbGuidLadder:FindByGuid(Item.tbZhenYuan:GetLadderId(pItem), pItem.szGUID);
			pPlayer.SetTask(self.TASK_GROUP, self.TASK_ZHENYUAN_RANK[i], nRank + 1);
		else
			pPlayer.SetTask(self.TASK_GROUP, self.TASK_ZHENYUAN_RANK[i], 0);
		end
	end
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_TOTAL_RANK, nTotalRank);
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_ACHIEVEMENT_RANK, nAchievementRank);	
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_LEVEL_RANK, nLevelRank);
	-- 满级满经验之后战斗力就按第一名算，实时刷新，不需要等到3点排行
	if GetPlayerHonor(pPlayer.nId, PlayerHonor.HONOR_CLASS_LEVEL, 0) == 15100 then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_MAX_LEVEL_FLAG, 1);
	else
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_MAX_LEVEL_FLAG, 0);
	end
end

-- 获取所有同伴可以加的战斗力点数
function tbFightPower:GetAllPartnerFightPower(pPlayer)
	local nSum = 0;
	local tbPartnerFightPower = {};
	for i = 1, pPlayer.nPartnerCount do
		local pPartner = pPlayer.GetPartner(i - 1);
		if pPartner then
			table.insert(tbPartnerFightPower, i, self:GetPartnerFightPower(pPartner, pPlayer));
		end
	end
	
	table.sort(tbPartnerFightPower, function(a, b) return a > b end );
	
	for i = 1, Partner.VALUE_CALC_MAX_NUM do
		if (tbPartnerFightPower[i]) then
			nSum = nSum + tbPartnerFightPower[i];
		end
	end
	
	return nSum;	
end


-- 获取某个同伴可以加的战斗力点数
function tbFightPower:GetPartnerFightPower(pPartner, pPlayer)
	local nValue = Partner:GetPartnerValue(pPartner);
	local nRate = 100;
	if  pPartner.nPartnerIndex ~= pPlayer.nActivePartner then
		nRate = Partner.FIGHTPOWER_RATE_UNREADY;
	end
	return nValue / 20000000 * nRate/100;
end

-- 刷新所有玩家战斗力
function tbFightPower:RefreshAllPlayer()
	print("刷新所有玩家战斗力");
	for _, pPlayer in pairs(KPlayer.GetAllPlayer()) do
		Item.tbZhenYuan:UpdateLadderInfo(pPlayer);
		self:RefreshFightPower(pPlayer);
	end
end

-- 有某些操作影响战斗力时，刷新的函数
function tbFightPower:RefreshFightPower(pPlayer, bNotSyncToGC)
	if (self:IsFightPowerValid() == 0) then
		return;
	end
	self:UpdatePowerByRank(pPlayer);
	local nPower = self:GetFightPower(pPlayer);
	--print("RefreshFightPower", pPlayer.szName, nPower);
	local nRet = pPlayer.SetFightPower(math.floor(nPower * 100));
	if nRet ~= 1 then
		Dbg:WriteLog("FightPower", "SetFailed", nRet);
		debug.traceback();
	end
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_FIGHTPOWER, nPower * 100);
	if not bNotSyncToGC then
		GCExecute({"SetPlayerHonor", pPlayer.nId, PlayerHonor.HONOR_CLASS_FIGHTPOWER_TOTAL, 1, nPower * 100});
	end
	pPlayer.CallClientScript({"Player.tbFightPower:OnSyncFightPower", math.floor(nPower * 100)});
	local nLastLogTime = pPlayer.GetTask(self.TASK_GROUP, self.TASK_LOGTIME);
	if os.date("%y-%m-%d", nLastLogTime) ~= os.date("%y-%m-%d", GetTime()) then
		self:LogFightPower(pPlayer);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_LOGTIME, GetTime());
	end
end

function tbFightPower:OnSyncFightPower(nPower)
	--print("OnSyncFightPower", nPower);
	if UiVersion == Ui.Version001 then
		Ui(Ui.UI_PLAYERSTATE):UpdateFightPower(math.floor(nPower / 100));
	end
	Ui(Ui.UI_PLAYERPANEL):UpdateFightPower(nPower / 100);
end

function tbFightPower:OnPlayerLogin()
	if (self:IsFightPowerValid() == 0) then
		me.CallClientScript({"Player.tbFightPower:SetFightPowerEffect", 0});
		return;
	end
	self:UpdatePowerByRank(me);
	self:RefreshFightPower(me);
	--local nPower = self:GetFightPower(me);
	--me.SetFightPower(nPower);
end

if (MODULE_GAMESERVER) then
	-- 注册通用上线事件
	PlayerEvent:RegisterGlobal("OnLogin", tbFightPower.OnPlayerLogin, tbFightPower);
	--PlayerEvent:RegisterOnLoginEvent(tbFightPower.OnPlayerLogin, tbFightPower);
end

function tbFightPower:UpdatePlayerExp(nPlayerId, nLevel, nExpPercent)
	if GetPlayerHonor(nPlayerId, PlayerHonor.HONOR_CLASS_LEVEL, 0) == 15100 then
		return 0;
	end
	SetPlayerHonor(nPlayerId, PlayerHonor.HONOR_CLASS_LEVEL, 0, nLevel * 100 + nExpPercent);
	KGCPlayer.OptSetTask(nPlayerId, 10, nExpPercent);
	GSExecute(-1, {"KGCPlayer.OptSetTask", nPlayerId, 10, nExpPercent});
end

-- 披风加的战斗力
function tbFightPower:GetPiFengPower(pPlayer, pItem)
	pItem = pItem or pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem then
		return 0;
	end
	return pItem.nFightPower;
end

-- 秘籍加的战斗力
function tbFightPower:GetMiJiPower(pPlayer, pItem)
	pItem = pItem or pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_BOOK, 0);
	if not pItem then
		return 0;
	end
	return pItem.nFightPower;
end

-- 官印加的战斗力
function tbFightPower:GetGuanYinPower(pPlayer, pItem)
	pItem = pItem or pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_CHOP, 0);
	if not pItem then
		return 0;
	end
	return pItem.nFightPower;
end

-- 阵法加的战斗力
function tbFightPower:GetZhenFaPower(pPlayer, pItem)
	pItem = pItem or pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHEN, 0);
	if not pItem then
		return 0;
	end
	return pItem.nFightPower;
end

-- 五行印加的战斗力
function tbFightPower:Get5XingYinPower(pPlayer, pItem)
	pItem = pItem or pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_SIGNET, 0);
	if not pItem then
		return 0;
	end
	return pItem.nValue / 10000000;
end

-- 同伴装备加的战斗力
function tbFightPower:GetPartnerEquipPower(pPlayer)
	local nPower = 0;
	for i = Item.PARTNEREQUIP_WEAPON, Item.PARTNEREQUIP_NUM - 1 do
		nPower = nPower + self:GetPartnerEquipPowerByPos(pPlayer, i);
	end
	return nPower;
end

function tbFightPower:GetPartnerEquipPowerByItem(pItem)
	local nPower = 0;
	if pItem then
		nPower = nPower + pItem.nValue / 10000000;
	end
	return nPower;
end

function tbFightPower:GetPartnerEquipPowerByPos(pPlayer, nPos)
	if nPos < Item.PARTNEREQUIP_WEAPON or nPos >= Item.PARTNEREQUIP_NUM then
		return 0;
	end
	local pItem = pPlayer.GetItem(Item.ROOM_PARTNEREQUIP, nPos, 0);
	local nPower = 0;
	if pItem then
		nPower = nPower + pItem.nValue / 10000000;
	end
	return nPower;
end

-- 战斗力开关
function tbFightPower:IsFightPowerValid()
	if (MODULE_GAMESERVER or MODULE_GC_SERVER) then
		return GlobalFightPowerEffect();
	else
		return self.nFightPowerEffect;
	end
end

function tbFightPower:SetFightPowerEffect(nEffect)
	self.nFightPowerEffect = nEffect;
end

-- 开放战斗力
function tbFightPower:OnOpenFightPower()
	if (MODULE_GC_SERVER) then
		GSExecute(-1, {"Player.tbFightPower:OnOpenFightPower"});
	elseif (MODULE_GAMESERVER) then
		GlobalFightPowerEffect(1);
		self:RefreshAllPlayer();
		for _, pPlayer in pairs(KPlayer.GetAllPlayer()) do
			pPlayer.CallClientScript({"Player.tbFightPower:SetFightPowerEffect", 1});
		end
	end
end

-- 关闭战斗力
function tbFightPower:OnCloseFightPower()
	if (MODULE_GC_SERVER) then
		GSExecute(-1, {"Player.tbFightPower:OnCloseFightPower"});
	elseif (MODULE_GAMESERVER) then
		GlobalFightPowerEffect(0);
		for _, pPlayer in pairs(KPlayer.GetAllPlayer()) do
			pPlayer.CallClientScript({"Player.tbFightPower:OnSyncFightPower", 0});
			pPlayer.CallClientScript({"Player.tbFightPower:SetFightPowerEffect", 0});
		end
	end
end

function tbFightPower:OnServerStart(nEffect)
	if (EventManager.IVER_bOpenFightPowerNoLevelLimit == 1) then
		if nEffect == 1 then
			GlobalFightPowerEffect(1);
		else
			GlobalFightPowerEffect(0);
		end
		return;		
	end
	
	if nEffect == 1 and KPlayer.GetMaxLevel() >= 100 then
		GlobalFightPowerEffect(1);
	else
		GlobalFightPowerEffect(0);
	end
end

function tbFightPower:GetFightPowerRank()
	return me.GetTask(self.TASK_GROUP, self.TASK_TOTAL_RANK);
end

tbFightPower.tbLevelPoint100 = 
{
	[1]		= 50;
	[2]		= 49;
	[3]		= 48;
	[4]		= 47;
	[5]		= 46;
	[10]	= 45;
	[20]	= 44;
	[30]	= 43;
	[40]	= 42;
	[50]	= 41;
	[60]	= 40;
	[70]	= 39;
	[80]	= 38;
	[90]	= 37;
	[100]	= 36;
};

tbFightPower.tbLevelPoint3000 = 
{
	{101,	250,	31,	35};
	{251,	450,	26,	30};
	{451,	700,	21,	25};
	{701,	1000,	16,	20};
	{1001,	1500,	11,	15};
	{1501,	2000,	6,	10};
	{2001,	3000,	1,	5};
};

tbFightPower.tbAchievementPoint100 = 
{
	[1]		= 45;
	[2]		= 44;
	[3]		= 43;
	[4]		= 42;
	[5]		= 41;
	[10]	= 40;
	[20]	= 39;
	[30]	= 38;
	[40]	= 37;
	[50]	= 36;
	[60]	= 35;
	[70]	= 34;
	[80]	= 33;
	[90]	= 32;
	[100]	= 31;
};

tbFightPower.tbAchievementPoint3000 = 
{
	{101,	300,	26,	30};
	{301,	600,	21,	25};
	{601,	1000,	16,	20};
	{1001,	1500,	11,	15};
	{1501,	2000,	6,	10};
	{2001,	3000,	1,	5};
};

-- 用来获取装备战斗力
tbFightPower.tbEquipRoomInfo	=
{
	{
		nRoomId = Item.ROOM_EQUIP,	
		GetFightPower = function(self, pItem)
			return pItem.CalcFightPower();
		end
	},
	{
		nRoomId = Item.ROOM_EQUIPEX,
		GetFightPower = function(self, pItem)
			return pItem.CalcExtraFightPower(pItem.nEnhTimes, 0);
		end
	},
	{
		nRoomId = Item.ROOM_EQUIPEX2,
		GetFightPower = function(self, pItem)
			return pItem.CalcExtraFightPower(pItem.nEnhTimes, 0) / 2;
		end
	},
};
