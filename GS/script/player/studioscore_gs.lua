 
-- 用于给角色评分，该分值用于标记正常玩家角色和工作室角色

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\misc\\serverevent.lua");
Require("\\script\\player\\playerschemeevent.lua");
Require("\\script\\player\\studioscore_def.lua");

--- 任务变量组ID self.TASK_GROUP_ID
--  任务变量ID：
--  1, 日期
--  2, 当前记录用变量ID
--  3 - 9， 记录7天分值

StudioScore.TASK_GROUP_ID = 2170;

StudioScore.nServerStartDays = StudioScore.nServerStartDays or 0;

StudioScore.LOGINIP_LOGINROLE_MIN = 4; -- 登陆IP登陆的角色数大于等于这个值时开始减分
--StudioScore.LOGINIP_LOGINROLE_MAX = 50; -- 登陆IP登陆的角色数大于等于这个值时按这个值计算
StudioScore.tbLoginSettedCount = {}; -- 如果角色P登陆所用的IP为A，而有N个角色从A登陆，这个N会记录在P的任务变量中，这个表记录了P与其对应的N，

StudioScore.tbLevels =
{
	[1] = {60, 100},
	[2] = {50, 60},
	[3] = {40, 50},
	[4] = {30, 40},
	[5] = {20, 30},
	[6] = {10, 20},
	[7] = {0, 10},
}

StudioScore.tbIpData = {};

function StudioScore:GetLevel(pPlayer)
	if not pPlayer then
		return;
	end
	local nScore = 0;
	for i = 3, 9 do
		nScore = nScore + pPlayer.GetTask(self.TASK_GROUP_ID, i);
	end
	
	nScore = nScore / 7;
	
	if nScore >= 100 then
		nScore = 100;
	elseif nScore <= -100 then
		nScore = 0;
	end
	
	nScore = (nScore + 100) / 200 * 100;
	for k, v in pairs(self.tbLevels) do
		if nScore >= v[1] and nScore <= v[2] then
			return k;
		end
	end
end 

-- 获得等级对应的分数
function StudioScore:GetLevelScore(nLevel)
	return 0;
end


-- 获得财富对应的分数
function StudioScore:GetWealthScore(nWealth)
	if nWealth <= 0 then
		return 0;
	end
	
	return math.floor(nWealth / 2000);
end

-- 根据同账号下的角色特征计算加分项
function StudioScore:GetRolesScoreOfAccount(szAccount)
	do return 0 end;
	if not szAccount then
		return 0;
	end
	
	local tbRoles = KGCPlayer.GetRolesOfAccount(szAccount);
	if not tbRoles then
		return 0;
	end

	return -table.maxn(tbRoles);
end

-- 清算，计算分数，在跨天或者玩家当天首次登录的时候执行
function StudioScore:UpdateScore()
	local pPlayer = me;
	if not pPlayer then
		return;
	end
	local nDateNow = tonumber(GetLocalDate("%m%d"));
	if pPlayer.GetTask(self.TASK_GROUP_ID, 1) == nDateNow then
		return;
	end
	-- 旧的一天
	local nTaskId = pPlayer.GetTask(self.TASK_GROUP_ID, 2);
	if nTaskId >= 3 and nTaskId <= 9 then
		for k, v in pairs(self.tbTaskId2ScoreItem) do
			local nCount = pPlayer.GetTask(self.TASK_GROUP_ID, k);
			if nCount > 0 then
				if v.Score ~= 0 then
					local nScore = math.floor(v.Score * nCount);
					self:AddScore(pPlayer, nScore);
					nCount = math.floor(v.Score * nCount - nScore) / v.Score;
				else
					nCount = 0;
				end
			end
			if nCount < 0 then
				nCount = 0;
			end
			pPlayer.SetTask(self.TASK_GROUP_ID, k, nCount);
		end
	end
	
	-- 新的一天
	pPlayer.SetTask(self.TASK_GROUP_ID, 1, nDateNow);

	if nTaskId >= 3 and nTaskId < 9 then
		nTaskId = nTaskId + 1;
	else
		nTaskId = 3;
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, 2, nTaskId); --标记今天对应的任务变量的ID
	pPlayer.SetTask(self.TASK_GROUP_ID, nTaskId, 0); --新的一天，从0开始
	
	local nTotalScore = pPlayer.GetTask(self.TASK_GROUP_ID, nTaskId);
	-- 加今天的等级分
	nTotalScore = nTotalScore + self:GetLevelScore(pPlayer.nLevel);
	
	-- 加今天的财富分
	local nWealth = PlayerHonor:GetPlayerHonor(pPlayer.nId, PlayerHonor.HONOR_CLASS_MONEY , 0)
	nTotalScore = nTotalScore + self:GetWealthScore(nWealth);

	
	-- 加同账号下的角色数的分
	nTotalScore = nTotalScore + self:GetRolesScoreOfAccount(pPlayer.szAccount);
	
	pPlayer.SetTask(self.TASK_GROUP_ID, nTaskId, nTotalScore); -- 记分
end

-- 计算价值量的时候忽略的道具类型
StudioScore.tbIgnoredItemTypes = {}

function StudioScore:LoadIgnoredItemTypes(szFile)
	self.tbIgnoredItemTypes = {};
	
	local tbData = Lib:LoadTabFile(szFile);
	if not tbData then
		return;
	end
	
	for _, v in ipairs(tbData) do
		self.tbIgnoredItemTypes[v.ItemGDPL] = true;
	end
end

StudioScore:LoadIgnoredItemTypes("\\setting\\player\\ignoreditem_def.txt");

function StudioScore:GetItemValue(pItem)
	if not pItem then
		return 0;
	end
	
	local szGDPL = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	if self.tbIgnoredItemTypes[szGDPL] then
		return 0;
	end
	return pItem.nValue;
end

function StudioScore:OnOnePlayerTrade(nPlayerId, tbItemIndexes)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		print("error in StudioScore:OnOnePlayerTrade, not existed player!");
		return;
	end
	local fValue = 0;
	-- 计算下价值量
	for _, v in ipairs(tbItemIndexes) do
		local pItem = KItem.GetItemObj(v);
		fValue = fValue + self:GetItemValue(pItem);
	end

	self:OnActivityFinish("__tradeout",pPlayer, math.floor(fValue));
end

function StudioScore:OnTradeSuccess(nPlayerIdA, tbItemIndexesA, nPlayerIdB, tbItemIndexesB)
	self:OnOnePlayerTrade(nPlayerIdA, tbItemIndexesA);
	self:OnOnePlayerTrade(nPlayerIdB, tbItemIndexesB);
end

-- 活动回调
function StudioScore:OnActivityFinish(szActivity, pPlayer, nCount)
	if not szActivity or not pPlayer then
		return;
	end
	
	local tbItem = self.tbScoreSetting["activity"][szActivity];
	if not tbItem then
		print("StudioScore:OnActivityFinish, Unkonw activity type: ", szActivity);
		return;
	end
	
	nCount = nCount or 1;
	if nCount == 0 then
		return;
	end
	
	if tbItem.nTaskId == 0 then
		self:AddScore(pPlayer, tbItem.Score * nCount)
		return;
	end

	local nRecordedCount = pPlayer.GetTask(self.TASK_GROUP_ID, tbItem.nTaskId);
	if tbItem.nMaxCount and nRecordedCount >= tbItem.nMaxCount then
		return;
	end
	
	local nTotalCount = nCount + nRecordedCount;
	if tbItem.nMaxCount and nTotalCount > tbItem.nMaxCount then
		nTotalCount = tbItem.nMaxCount;
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, tbItem.nTaskId, nTotalCount);
end

function StudioScore:AddScore(pPlayer, nScore)
	if nScore == 0 then
		return;
	end
	
	local nTaskId = pPlayer.GetTask(self.TASK_GROUP_ID, 2);
	if nTaskId < 3 or nTaskId > 9 then
		nTaskId = 3;
		pPlayer.SetTask(self.TASK_GROUP_ID, 2, nTaskId);
	end
	
	local nCurScore = pPlayer.GetTask(self.TASK_GROUP_ID, nTaskId);
	pPlayer.SetTask(self.TASK_GROUP_ID, nTaskId, nCurScore + nScore);
end

function StudioScore:AuctionBuyCallback(pPlayer, szGoodsKey, nCount)
	if not self.bIsOpen then
		return;
	end
	
	local tbItem = self.tbScoreSetting["buy"][szGoodsKey];
	if not tbItem or tbItem.Score == 0 then
		return;
	end

	if tbItem.nTaskId == 0 then
		self:AddScore(pPlayer, tbItem.Score * nCount);
		return;
	end
	
	local nRecordedCount = pPlayer.GetTask(self.TASK_GROUP_ID, tbItem.nTaskId);
	if tbItem.nMaxCount and nRecordedCount >= tbItem.nMaxCount then
		return;
	end
	
	local nTotalCount = nCount + nRecordedCount;
	if tbItem.nMaxCount and nTotalCount >= tbItem.nMaxCount then
		nTotalCount = tbItem.nMaxCount;
	end

	pPlayer.SetTask(self.TASK_GROUP_ID, tbItem.nTaskId, nTotalCount);
	
end

function StudioScore:AuctionSellCallback(pPlayer, szGoodsKey, nCount)
	if not self.bIsOpen then
		return;
	end
		
	local tbItem = self.tbScoreSetting["sell"][szGoodsKey];
	if not tbItem or tbItem.Score == 0 then
		return;
	end
	
	if tbItem.nTaskId == 0 then
		self:AddScore(pPlayer, tbItem.Score * nCount);
		return;
	end
	
	local nRecordedCount = pPlayer.GetTask(self.TASK_GROUP_ID, tbItem.nTaskId);
	if tbItem.nMaxCount and nRecordedCount >= tbItem.nMaxCount then
		return;
	end
	
	local nTotalCount = nCount + nRecordedCount;
	if tbItem.nMaxCount and nTotalCount >= tbItem.nMaxCount then
		nTotalCount = tbItem.nMaxCount;
	end

	pPlayer.SetTask(self.TASK_GROUP_ID, tbItem.nTaskId, nTotalCount);
end

function StudioScore:AuctionTransactionCallback(szSellerName, szBuyerName, szGoodsKey, nCount)
	if not self.bIsOpen then
		return;
	end
	if szBuyerName then
		local pPlayer = KPlayer.GetPlayerByName(szBuyerName);
		if pPlayer then
			self:AuctionBuyCallback(pPlayer, szGoodsKey, nCount);
		end
	end
	
	if szSellerName then
		local pPlayer = KPlayer.GetPlayerByName(szSellerName);
		if pPlayer then
			self:AuctionSellCallback(pPlayer, szGoodsKey, nCount);
		end
	end
end

function StudioScore:Open()
	self.bIsOpen = true;
end

function StudioScore:Close()
	self.bIsOpen = false;
end

function StudioScore:SynIpData(tbData,nServerId)
	if nServerId and GetServerId() ~= nServerId then
		return;
	end
	self.tbIpData = tbData;
	self.tbLoginSettedCount = {};
end

function StudioScore:SynIpDataItem(dwIp, nPlayerId, nServerId)
	local tbDataItem = self.tbIpData[dwIp] or {};
	self.tbIpData[dwIp] = tbDataItem;
	if tbDataItem[nPlayerId] then
		return;
	end

	tbDataItem[nPlayerId] = true;
	tbDataItem.nCount = tbDataItem.nCount or 0;
	tbDataItem.nCount = tbDataItem.nCount + 1;
	
	local nCount = tbDataItem.nCount;
	if nCount < self.LOGINIP_LOGINROLE_MIN then
		return;
	end
	
	for k, _ in pairs(tbDataItem) do
		if type(k) == "number" then
			local pPlayer = KPlayer.GetPlayerObjById(k);
			if pPlayer then
				local nRecordedCount = self.tbLoginSettedCount[k] or 0;
				local nAddedCount = nCount - nRecordedCount;
				if nAddedCount > 0 then
					self:OnActivityFinish("__loginip", pPlayer, nAddedCount);
				end
				self.tbLoginSettedCount[k] = nCount;
			end
		end
	end
end

function StudioScore:LoadIpData()
	GCExcute{"StudioScore:RequestIpData", GetServerId()};
end

function StudioScore:StudioScoreOnLogin()
	self:UpdateScore();

	local szIp = me.GetPlayerIpAddress(); -- 这个还带端口的
	if not szIp then
		return;
	end
	
	local nIndex = string.find(szIp, ":");
	if not nIndex then
		return;
	end
	
	szIp = string.sub(szIp, 1, nIndex - 1);
	
	local dwIp = IpString2Dword(szIp);
	if not dwIp then
		return;
	end
	
	if self.tbIpData[dwIp] and self.tbIpData[dwIp][me.nId] then
		return;
	end
	GCExcute{"StudioScore:SynIpDataItem", dwIp, me.nId, GetServerId()};
end

function StudioScore:OnServerStart()
	self:LoadIpData()
	PlayerEvent:RegisterGlobal("OnLogin", self.StudioScoreOnLogin, self);
end


if not StudioScore.bIsServerStartEventRegistered then
	ServerEvent:RegisterServerStartFunc(StudioScore.OnServerStart, StudioScore);
	StudioScore.bIsServerStartEventRegistered = true;
end

if not StudioScore.bIsDailyEventRegistered  then
	PlayerSchemeEvent:RegisterGlobalDailyEvent({StudioScore.UpdateScore, StudioScore});
	StudioScore.bIsDailyEventRegistered = true;
end

--if not StudioScore.bIsDailyEventRegistered  then
	--PlayerSchemeEvent:RegisterGlobalDailyEvent({StudioScore.UpdateScore, StudioScore});
	--StudioScore.bIsDailyEventRegistered = true;
--end
--
--if not StudioScore.bIsPlayerLoginEventRegistered then
	--PlayerEvent:RegisterGlobal("OnLogin", StudioScore.OnLogin, StudioScore);
	--StudioScore.bIsPlayerLoginEventRegistered = true;
--end
--
--