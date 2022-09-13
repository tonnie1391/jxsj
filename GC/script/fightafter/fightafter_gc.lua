-- 文件名  : fightafter_gc.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-21 17:58:39
-- 描述    : 战后系统 GC

if not (MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\fightafter\\fightafter_def.lua");

function FightAfter:LoadGblBuf()
	self.tbInstanceBuffer = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_FIGHTAFTER, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbInstanceBuffer = tbBuf;
	end
	
	self:RefreshBuf(1);
	
	--生成tbPlayerInstanceList	
	for szInstanceId, tbInstance in pairs(self.tbInstanceBuffer) do
		self:AddInstance2Player(tbInstance);
	end
	
end

function FightAfter:SaveGblBuf()
	self.tbInstanceBuffer = self.tbInstanceBuffer or {};
	SetGblIntBuf(GBLINTBUF_FIGHTAFTER, 0, 1, self.tbInstanceBuffer);
end


--清除过期的活动
function FightAfter:RefreshBuf(nIsStart)	
	for szInstanceId, tbInstance in pairs(self.tbInstanceBuffer) do
		if self:CheckInstanceExpiry_base(szInstanceId) == 0 then
			self:DelInstance(szInstanceId);
			if not nIsStart or nIsStart ~= 1 then
				GlobalExcute({"FightAfter:DelInstance", szInstanceId});
			end
		end
	end	
	
	self:SaveGblBuf();	
end


--GC数据同步给GS
function FightAfter:OnRecConnectMsg(nConnectId)
	if self.tbInstanceBuffer then
		for szInstanceId, tbInstance in pairs(self.tbInstanceBuffer) do
			GSExcute(nConnectId, {"FightAfter:OnRecConnectMsg", tbInstance});
		end
	end
end

function FightAfter:CoZoneFightAfterBuf(tbSubBuf)
	print("CombinSubZoneAndMainZone CoZoneFightAfterBuf start");
	tbSubBuf = tbSubBuf or {};
	local tbBuffer = GetGblIntBuf(GBLINTBUF_FIGHTAFTER, 0);
	self.tbInstanceBuffer = {};
	if tbBuf and type(tbBuf)=="table"  then
		self.tbInstanceBuffer = tbBuf;
	end	
	for szInstanceId, tbInfo in pairs(tbSubBuf) do
		self.tbInstanceBuffer[szInstanceId] = tbInfo;
	end
	
	self:RefreshBuf(1);
	
	--生成tbPlayerInstanceList	
	for szInstanceId, tbInstance in pairs(self.tbInstanceBuffer) do
		self:AddInstance2Player(tbInstance);
	end
	print("CombinSubZoneAndMainZone CoZoneFightAfterBuf end");
end

GCEvent:RegisterGCServerStartFunc(FightAfter.LoadGblBuf, FightAfter);
GCEvent:RegisterGCServerShutDownFunc(FightAfter.SaveGblBuf, FightAfter);
GCEvent:RegisterGS2GCServerStartFunc(FightAfter.OnRecConnectMsg,FightAfter);
