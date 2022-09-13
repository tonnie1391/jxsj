-- 文件名　：kinplant_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-08 20:17:49
-- 功能    ：

if (not MODULE_GC_SERVER) then
	return 0;
end
Require("\\script\\kin\\kinplant\\kinplant_def.lua");

KinPlant.nStep = 0;

--init家族活动信息(不用同步其他啦，家园只能在一个服务器的)
function KinPlant:InitKinPlant(nKinId)
	self.tbPlantInfo[nKinId] = {};
	for i = 1, #self.tbNpcPoint do
		table.insert(self.tbPlantInfo[nKinId], {"", 0, 0, 0, 0, 0, 0});		--玩家，树阶段，对应的类型，剩余果子，健康度，天气，种植时间
	end
	self:SaveBuff_GC();
end

--摘果子
function KinPlant:DelSeed_GC(dwKinId, nNum, nPerGetOther)
	self.tbPlantInfo[dwKinId][nNum][4] = self.tbPlantInfo[dwKinId][nNum][4]  - nPerGetOther;	
	self:AddStep();
end

--设置玩家种树情况
function KinPlant:SetPlantState_GC(dwKinId, szName, nTreeIndex, nNum, nRemand, nIndex, nWeatherType, nHealth, nTime)
	if not self.tbPlantInfo[dwKinId] then
		return 0;
	end
	self.tbPlantInfo[dwKinId][nNum] = {szName, nTreeIndex, nIndex, nRemand, nWeatherType, nHealth, nTime};
	self:AddStep();	
end

--每100步存一次
function KinPlant:AddStep()
	self.nStep = self.nStep + 1;
	if self.nStep >= 100 then
		self:SaveBuff_GC();
		self.nStep = 0;
	end
end

--load
function KinPlant:LoadBuff_GC()
	if self:GetState() ==  0  then
		return;
	end
	local tbBuf = GetGblIntBuf(GBLINTBUF_KIN_PLANT_DAILY, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbPlantInfo = tbBuf;
	end
end

--save
function KinPlant:SaveBuff_GC()
	if self:GetState() ==  0 then
		return;
	end
	SetGblIntBuf(GBLINTBUF_KIN_PLANT_DAILY, 0, 1, self.tbPlantInfo);	
end

--Sync
function KinPlant:SyncData()
	for nKinId, tbKinInfoEx in pairs(self.tbPlantInfo) do
		GlobalExcute({"KinPlant:ServerStartFunc", nKinId, tbKinInfoEx});
	end
end

--世界公告
function KinPlant:Msg2World()
	local szWorldMsg = "Hoạt động trồng cây tại Lãnh Địa Gia Tộc đang diễn ra!";
	Dialog:GlobalNewsMsg_GC(szWorldMsg);
	Dialog:GlobalMsg2SubWorld_GC(szWorldMsg);
end

--活动期间每天0点收获
function KinPlant:RegisterScheduleTask_GC()	
	local nTaskId1 = KScheduleTask.AddTask("KinPlant", "KinPlant", "SaveBuff_GC");
	KScheduleTask.RegisterTimeTask(nTaskId1, 0005, 1);
	--种植期每个小时随即一个5分钟特殊天气
	local nTaskId2 = KScheduleTask.AddTask("KinPlant", "KinPlant", "RandWeatherReport");
	for i, nTime in ipairs(self.tbWeatherTime) do
		KScheduleTask.RegisterTimeTask(nTaskId2, nTime, i);
	end	
	--每周10点随即3个任务
	local nTaskId3 = KScheduleTask.AddTask("KinPlant", "KinPlant", "RandSpecialTask");	
	KScheduleTask.RegisterTimeTask(nTaskId3, 0000, 1);
	--1100-1400,1900-2300每个小时10分和40分的时候发世界公告
	local nTaskId4 = KScheduleTask.AddTask("KinPlant", "KinPlant", "Msg2World");
	for i, nTime in ipairs(self.tbMsg2Wolrd) do
		KScheduleTask.RegisterTimeTask(nTaskId4, nTime, i);
	end
	self:RepairTask();		--周五没有触发，之后重启服务器，重新随即任务
	self:LoadBuff_GC();		--LoadBuff
end

function KinPlant:CoZoneUpdateKinPlant(tbMainBuf, tbSubBuf)
	print("[GCEvent] CoZoneUpdateKinPlant start");
	self.tbPlantInfo = {};
	tbMainBuf	= tbMainBuf or {};
	tbSubBuf	= tbSubBuf or {};

	for szKinName, tbInfo in pairs(tbMainBuf) do
		local nKinId = KKin.GetKinNameId(szKinName);
		if (nKinId) then
			self.tbPlantInfo[nKinId] = tbInfo;
		else
			print("[GCEvent] CoZoneUpdateKinPlant tbMainBuf ", szKinName);
		end
	end

	for szKinName, tbInfo in pairs(tbSubBuf) do
		local nKinId = KKin.GetKinNameId(szKinName);
		if (nKinId) then
			self.tbPlantInfo[nKinId] = tbInfo;
		else
			print("[GCEvent] CoZoneUpdateKinPlant tbSubBuf ", szKinName);
		end
	end
	SetGblIntBuf(GBLINTBUF_KIN_PLANT_DAILY, 0, 1, self.tbPlantInfo);
	print("[GCEvent] CoZoneUpdateKinPlant end");
end

if KinPlant.IS_OPEN == 1 then
	GCEvent:RegisterGCServerStartFunc(KinPlant.RegisterScheduleTask_GC, KinPlant);	
	GCEvent:RegisterGCServerShutDownFunc(KinPlant.SaveBuff_GC, KinPlant);
end
