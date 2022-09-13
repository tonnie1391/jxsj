-- 文件名　：kinplant_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-08 20:17:49
-- 功能    ：

if (not MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\event\\jieri\\201110_nationnalday\\kinplant\\kinplant_def.lua");
local tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011;

tbKinPlant_2011.nStep = 0;

--init家族活动信息(不用同步其他啦，家园只能在一个服务器的)
function tbKinPlant_2011:InitKinPlant(nKinId)
	self.tbPlantInfo[nKinId] = {};
	for i = 1, #self.tbNpcPoint do
		table.insert(self.tbPlantInfo[nKinId], {"", 1, 0, 0});	
	end
	self:SaveBuff_GC();
end

--摘果子
function tbKinPlant_2011:DelSeed_GC(dwKinId, nNum, nFlag)
	if not self.tbPlantInfo[dwKinId] then
		return 0;
	end
	if nFlag then
		self.tbPlantInfo[dwKinId][nNum][4] = self.tbPlantInfo[dwKinId][nNum][4]  - self.nPerGetOther;
	else
		self.tbPlantInfo[dwKinId][nNum][3] = 0;
	end
	self:AddStep();
end

--设置玩家种树情况
function tbKinPlant_2011:SetPlantState_GC(dwKinId, szName, nType, nNum, nAward, nRemand)
	if not self.tbPlantInfo[dwKinId] then
		return 0;
	end
	self.tbPlantInfo[dwKinId][nNum] = {szName, nType, self.tbPlantInfo[dwKinId][nNum][3] + nAward, nRemand};
	self:AddStep();	
end

--每100步存一次
function tbKinPlant_2011:AddStep()
	self.nStep = self.nStep + 1;
	if self.nStep >= 100 then
		self:SaveBuff_GC();
		self.nStep = 0;
	end
end

--load
function tbKinPlant_2011:LoadBuff_GC()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if self:GetState() ==  0 and (nDate < self.nAwardTime or nDate > self.nGetAwardTime) then
		return;
	end
	local tbBuf = GetGblIntBuf(GBLINTBUF_KIN_PLANT, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbPlantInfo = tbBuf;
	end
end

--save
function tbKinPlant_2011:SaveBuff_GC()
	if self:GetState() ==  0 then
		return;
	end
	SetGblIntBuf(GBLINTBUF_KIN_PLANT, 0, 0, self.tbPlantInfo);	
end

--Sync
function tbKinPlant_2011:SyncData()
	for nKinId, tbKinInfoEx in pairs(self.tbPlantInfo) do
		GlobalExcute({"SpecialEvent.tbKinPlant_2011:ServerStartFunc", nKinId, tbKinInfoEx});
	end
end

function SpecialEvent:NpcGetAward_KinPlant()
	 if SpecialEvent.tbKinPlant_2011:GetState() == 1 or tonumber(GetLocalDate("%Y%m%d")) == SpecialEvent.tbKinPlant_2011.nAwardTime then
	 	SpecialEvent.tbKinPlant_2011:NpcGetAward_KinPlant();
	end
end

function tbKinPlant_2011:NpcGetAward_KinPlant()
	local nFreshDay = KGblTask.SCGetDbTaskInt(DBTASK_KINPLANT_TASK_ID);
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	if nFreshDay == nNowDay then
		return;
	end
	for dwKinId, tbKinPlantInfo in pairs(self.tbPlantInfo) do
		for i, tb in ipairs(tbKinPlantInfo) do
			if tb[2] == self.nMaxIndex - 1 then
				self.tbPlantInfo[dwKinId][i][2] = 2;
				self.tbPlantInfo[dwKinId][i][3] = self.tbPlantInfo[dwKinId][i][3] + self.tbPlantInfo[dwKinId][i][4];
				self.tbPlantInfo[dwKinId][i][4] = 0;
			elseif tb[2] == self.nMaxIndex then
				self.tbPlantInfo[dwKinId][i][2] = 2;
			end
		end
	end
	self:SaveBuff_GC();
	GlobalExcute({"SpecialEvent.tbKinPlant_2011:NpcGetAward"});
	KGblTask.SCSetDbTaskInt(DBTASK_KINPLANT_TASK_ID, nNowDay);
end

--活动期间每天0点收获
function tbKinPlant_2011:RegisterScheduleTask_GC()
	self:LoadBuff_GC();
	local nTaskId = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "NpcGetAward_KinPlant");
	KScheduleTask.RegisterTimeTask(nTaskId, 0005, 1);	
	self:NpcGetAward_KinPlant()
end

if tbKinPlant_2011.IS_OPEN == 1 then
	GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbKinPlant_2011.RegisterScheduleTask_GC, SpecialEvent.tbKinPlant_2011);	
	GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.tbKinPlant_2011.SaveBuff_GC, SpecialEvent.tbKinPlant_2011);
end
