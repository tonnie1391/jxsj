-- 文件名　：201108_tanabata_gs.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-20 11:03:16
-- 描述：2011七夕gs

if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201108_Tanabata\\201108_tanabata_def.lua");

SpecialEvent.Tanabata201108 =  SpecialEvent.Tanabata201108 or {};
local Tanabata201108 = SpecialEvent.Tanabata201108;

--是否开启活动
function Tanabata201108:CheckEventOpen()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate >= self.nStartDay and nNowDate <= self.nEndDay then
		return 1;
	end
	return 0;	
end


--刷喜鹊,启动服务器要进行一次，每日0:00要进行一次
function Tanabata201108:AddXiQue(nFlag)
	if nFlag and nFlag == 1 then
		if self.pXiqueNpc then
			self.pXiqueNpc.Delete();
		end
	end
	if self:CheckEventOpen() ~= 1 then
		return 0;
	end
	local nMapId = self.tbXiquePos[1];
	if not nMapId or IsMapLoaded(nMapId) ~= 1 then
		return 0;
	end
	if not self.pXiqueNpc then
		self.pXiqueNpc = KNpc.Add2(self.nXiQueTemplateId,10,-1,unpack(self.tbXiquePos));
	end
end

--刷小boss
function Tanabata201108:AddWorldNormalBoss_GS(tbInfo)
	if self:CheckEventOpen() ~= 1 then
		return 0;
	end
	if not tbInfo then
		return 0;
	end
	local tbMap = {};
	if not self.tbNormalBoss then
		self.tbNormalBoss = {};
	end
	for _,tbPos in pairs(tbInfo) do
		local nMapId,nX,nY = tbPos[1],tbPos[2],tbPos[3];
		table.insert(tbMap,nMapId);
		if IsMapLoaded(nMapId) == 1 then
			local pBoss = KNpc.Add2(self.nLengqingjueTemplateId,130,-1,nMapId,nX,nY);
			if pBoss then
				pBoss.SetMaxLife(10203597);
				table.insert(self.tbNormalBoss,pBoss.dwId);
			end
		end
	end
	self.nDelNormalBossTimer = Timer:Register(self.nDelBossTime * Env.GAME_FPS,self.DelNormalBoss,self);
	local szMap = "";
	for _,nMapId in pairs(tbMap) do
		szMap = szMap .. GetMapNameFormId(nMapId) .. "、";	
	end
	szMap = string.sub(szMap,1,-3);
	local szMsg = string.format("纤云弄巧，飞星传恨。王母手下大将冷情绝在<color=green>%s<color>出现，请大家速速前往挑战。",szMap);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL,szMsg);
	KDialog.Msg2SubWorld(szMsg);
end

--刷大boss
function Tanabata201108:AddWorldBigBoss_GS(tbInfo)
	if self:CheckEventOpen() ~= 1 then
		return 0;
	end
	if not tbInfo then
		return 0;
	end
	local tbMap = {};
	if not self.tbBigBoss then
		self.tbBigBoss = {};
	end
	for _,tbPos in pairs(tbInfo) do
		local nMapId,nX,nY = tbPos[1],tbPos[2],tbPos[3];
		table.insert(tbMap,nMapId);
		if IsMapLoaded(nMapId) == 1 then
			local pBoss = KNpc.Add2(self.nLengqingwangmuTemplateId,130,-1,nMapId,nX,nY);
			if pBoss then
				pBoss.SetMaxLife(10203597);
				local bStoneBorn = KGblTask.SCGetDbTaskInt(DBTASK_QX_STONE_BORN);
				if bStoneBorn == 1 then
					local nBookIndex = MathRandom(11,12);
					pBoss.AddDropItem(18,1,1356,nBookIndex,-1);
					pBoss.AddDropItem(18,1,1356,nBookIndex,-1);
				end
				table.insert(self.tbBigBoss,pBoss.dwId);
			end
		end
	end
	self.nDelBigBossTimer = Timer:Register(self.nDelBossTime * Env.GAME_FPS,self.DelBigBoss,self);
	local szMap = "";
	local tbLevel = {};
	for _,nMapId in pairs(tbMap) do
		local tbInfo = Map.tbMapIdList[nMapId];	--紧急处理，写的很戳
		local nIsLevelExist = 0;
		for _,nLevel in pairs(tbLevel) do
			if nLevel == tbInfo.nMapLevel then
				nIsLevelExist = 1;
			end
		end	
		if nIsLevelExist ~= 1 then
			table.insert(tbLevel,tbInfo.nMapLevel);
		end
	end
	for _,nLevel in pairs(tbLevel) do
		szMap = szMap .. tostring(nLevel) .. "级、";	
	end
	szMap = string.sub(szMap,1,-3);
	local szMsg = string.format("冷情王母出现在<color=green>%s<color>野外地图，欲阻止织女牛郎七夕相会，请江湖各路侠士速去前往挑战。",szMap);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL,szMsg);
	KDialog.Msg2SubWorld(szMsg);	
end


function Tanabata201108:DelNormalBoss()
	if not self.tbNormalBoss then
		self.nDelNormalBossTimer = 0;
		return 0;
	end
	for _,nNpcId in pairs(self.tbNormalBoss) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbNormalBoss = nil;
	self.nDelNormalBossTimer = 0;
	return 0;
end


function Tanabata201108:DelBigBoss()
	if not self.tbBigBoss then
		self.nDelBigBossTimer = 0;
		return 0;
	end
	for _,nNpcId in pairs(self.tbBigBoss) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbBigBoss = nil;
	self.nDelNormalBossTimer = 0;
	return 0;
end


--服务器启动事件
function Tanabata201108:OnServerStart()
	if self:CheckEventOpen() == 1 then
		self:AddXiQue();
	end
end

--注册启动回调
if tonumber(GetLocalDate("%Y%m%d")) <= Tanabata201108.nEndDay then
	ServerEvent:RegisterServerStartFunc(Tanabata201108.OnServerStart, Tanabata201108);
end