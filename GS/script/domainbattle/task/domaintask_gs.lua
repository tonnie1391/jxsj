-------------------------------------------------------
-- 文件名　：domaintask_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-18 05:35:02
-- 文件描述：
-------------------------------------------------------

Require("\\script\\domainbattle\\task\\domaintask_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

local tbDomainTask = Domain.DomainTask;

-- 0 -- not open
-- 1 -- intime
-- 2 -- over
function tbDomainTask:CheckState()
	
	if self.nState ~= 0 then
		return self.nState;
	end
	
	local nDomainOpenTime = KGblTask.SCGetDbTaskInt(DBTASK_DOMAINTASK_OPENTIME);
	
	if nDomainOpenTime == 0 then
		return 0;
	end
	
	local nStep = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_STEP);
	
	if nStep > 2 then
		return 2;
	end

	return 1;
end

function tbDomainTask:_SetState(nState)
	self.nState = nState;
end

-- load npc pos config
function tbDomainTask:LoadNpcPos()

	local tbMap = {};	
	local tbFile = Lib:LoadTabFile(self.NPC_POS_PATH);
	
	if not tbFile then
		return;
	end

	-- { [nMapId] = { nTemplateId, nMapX, nMapX } }
	for _, tbRow in pairs(tbFile) do
		
		local nMapId = tonumber(tbRow.nMapId);

		if not tbMap[nMapId] then
			tbMap[nMapId]= {};
		end
		
		table.insert(tbMap[nMapId],
			{	
				nTemplateId = tonumber(tbRow.nTemplateId), 
				nMapX = tonumber(tbRow.nMapX), 
				nMapY = tonumber(tbRow.nMapY),
			}
		);
	end
	
	self.tbNpcPos = tbMap;
end

function tbDomainTask:Init()
	self:LoadNpcPos();
	self:DistributeMap();
end

-- add npc by map id
function tbDomainTask:AddNpc(nMapId)
	
	local tbMap = self.tbNpcPos[nMapId];
	
	if not tbMap then
		return;
	end

	-- travel table
	for _, tbRow in pairs(tbMap) do
		
		-- get id, x, y
		local nTemplateId = tbRow.nTemplateId;
		local nMapX = tbRow.nMapX;
		local nMapY = tbRow.nMapY;
		
		-- add npc 
		local pNpc = KNpc.Add2(nTemplateId, 115, -1, nMapId, nMapX/32, nMapY/32, 1);
		
		if not pNpc then
			print("call npc failed:"..nTemplateId);
		end
	end
	
	local szMsg = string.format("<color=green>%s<color> xuất hiện thủ vệ lãnh thổ!", GetMapNameFormId(nMapId));
	KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
	KDialog.MsgToGlobal(szMsg);	
end

-- maplist, server only
function tbDomainTask:DistributeMap()
			
	local tbMap = {};
	
	for nMapId, tbRow in pairs(self.tbNpcPos or {}) do
		
		local nMapIndex = SubWorldID2Idx(nMapId);
	
		if nMapIndex > 0 then
			table.insert(tbMap, nMapId);
		end		
	end
	
	self.tbMapList = tbMap;
end

-- daliy event to fresh npc
function tbDomainTask:AddDefender_GS()
	
	if self:CheckState() ~= 1 then
		return;
	end
	
	local nLength = #self.tbMapList;
	
	if nLength < self.MIN_MAP_COUNT then
		return;
	end
	
	local nNum1 = MathRandom(1, nLength);
	local nNum2 = MathRandom(1, nLength);
	
	while nNum2 == nNum1 do
		nNum2 = MathRandom(1, nLength);
	end
	
	self:AddNpc(self.tbMapList[nNum1]);
	self:AddNpc(self.tbMapList[nNum2]);
end

-- clear npc
function tbDomainTask:ClearDefender_GS()
	for _, nMapId in pairs(self.tbMapList or {}) do
		ClearMapNpcWithName(nMapId, "Thủ vệ lãnh thổ");
	end
end

-- on player death drop item
function tbDomainTask:OnPlayerDeath()
	
	-- get map id, x, y
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	
	-- not in special map
	if not self.tbNpcPos[nMapId] then
		return;
	end
	
	-- get item count in bags
	local nCount = me.GetItemCountInBags(22, 1, 71, 1);
	
	-- found
	if nCount > 0  then
		
		-- consume item
		local bRet = me.ConsumeItemInBags2(1, 22, 1, 71, 1);
		
		-- success
		if bRet == 0 then
			KItem.AddItemInPos(nMapId, nMapX, nMapY, 22, 1, 71, 1, -1);	
		end	
	end
end

-- 检查是否开启补偿功能
function tbDomainTask:CheckBuChangState()
	if (self.BUCHANG_OPEN_FLAG ~= 1) then
		return 0, "Bồi thường hoạt động chưa mở!";
	end
	
	-- 如果霸主之印没开过，或者进行中都不能开启补偿
	local nState = self:CheckState();
	if (2 ~= nState) then
		return 0, "Hoạt động kết thúc có thể tiến hành trao đổi Bá chủ ấn.";
	end
	
	-- 如果补偿服务器table为空，说明是全局服务器开补偿
	if (self.BUCHANG_OPEN_ALLSERVER_FLAG == 1) then
		return 1;
	end
	local szGateWay = GetGatewayName();
	for _, szName in pairs(self.BUCHANG_OPEN_SERVER) do
		if (szGateWay == szName) then
			return 1;
		end
	end
	return 0, "Hoạt động kết thúc có thể tiến hành trao đổi Bá chủ ấn.";	
end

-- register event
PlayerEvent:RegisterGlobal("OnDeath", Domain.DomainTask.OnPlayerDeath, Domain.DomainTask);

ServerEvent:RegisterServerStartFunc(Domain.DomainTask.Init, Domain.DomainTask);
