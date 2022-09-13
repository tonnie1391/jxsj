 -- 文件名　：s2gcevent.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-11 16:19:41
-- 描  述  ：gs启好后通知Gc回调


GCEvent.SERVER_COUNT = 7;   --Gc配置的Gs服务器数目

--配置文件初始化
function GCEvent:GCConfig_Init()
	local tbHostSet = Lib:LoadIniFile("\\gc_config.ini");
	if not tbHostSet or type(tbHostSet["Init"]) ~= "table" or not tonumber(tbHostSet["Init"]["ServerCount"]) then
		tbHostSet = Lib:LoadIniFile("\\setting\\hostset.ini");
	end
	if not tbHostSet or type(tbHostSet["Init"]) ~= "table" or not tonumber(tbHostSet["Init"]["ServerCount"]) then
		return;
	end
	
	self.SERVER_COUNT = tonumber(tbHostSet["Init"]["ServerCount"]) or 7;	--服务器数量配置
end
GCEvent:GCConfig_Init();

--Gs启动通知GC，Gs没完全启动完毕
function GCEvent:OnRecConnectEvent(nConnectId)
	SpecialEvent.Girl_Vote:OnRecConnectEvent(nConnectId);	--美女评选初选Buf同步
	Lottery:OnRecConnectEvent(nConnectId); -- 09年8月促销抽奖活动
	Wldh.Qualification:OnRecConnectEvent(nConnectId);	-- 武林大会资格认定
	IbShop:OnRecConnectEvent(nConnectId); --奇珍阁物品上架状态
	NewLottery:OnRecConnectEvent(nConnectId);-- 09年9月促销抽奖活动
	VipPlayer.VipTransfer:OnRecConnectEvent(nConnectId);	-- Vip转服功能
	
	-- 执行服务器连接上gc启动函数
	if self.tbStartGS2GCConnectFun then
		for i, tbStart in ipairs(self.tbStartGS2GCConnectFun) do
			local tbFun = {unpack(tbStart.tbParam)};
			table.insert(tbFun, nConnectId);
			tbStart.fun(unpack(tbFun));
		end
	end	

end

-- 注册GS连接上GC执行函数，最后一个参数为连接号nConnectId
function GCEvent:RegisterGS2GCServerStartFunc(fnStartFun, ...)
	if not self.tbStartGS2GCConnectFun then
		self.tbStartGS2GCConnectFun = {}
	end
	table.insert(self.tbStartGS2GCConnectFun, {fun=fnStartFun, tbParam=arg});
end


--Gs启动完毕后通知GC
function GCEvent:OnRecConnectGsStartEvent(nConnectId)
	if self.tbStartedGS2GCConnectFun then
		print("*******GS"..nConnectId.."Restart!******");
		for i, tbStart in ipairs(self.tbStartedGS2GCConnectFun) do
			local tbFun = {unpack(tbStart.tbParam)};
			table.insert(tbFun, nConnectId);
			tbStart.fun(unpack(tbFun));
		end
	end	
	self:OnServerStartEvent(nConnectId);   -- 应该放在服务器加载完毕而后通知GC的消息里
	if not GCEvent.nGCExecuteFromId or GCEvent.nGCExecuteFromId <= 0 then	-- 设置连接号
		assert(false);
		print("找不到连接ID");
		return;
	end
	GSExcute(GCEvent.nGCExecuteFromId,{"ServerEvent:SetConnectId_GS", GCEvent.nGCExecuteFromId});
end

--服务器启动后检查是否所有服务器启动完毕
function GCEvent:OnServerStartEvent(nConnectId)
	self.tbServer = self.tbServer or {};
	self.tbServer[nConnectId] = 1;
	local nCount = 0;
 	for nConnectId , _ in pairs(self.tbServer) do
 		nCount = nCount + 1;
 	end

 	if nCount == self.SERVER_COUNT then
		self:OnAllServerStartEvent();
		KGblTask.SCSetTmpTaskInt(DBTASK_VILLAGELIST_FLAG, 1);
	end
end

--所有服务器启动完毕后执行事件
function GCEvent:OnAllServerStartEvent()
	EventManager.KingEyes:GSReloadEvent();
	GM:AutoDoCommand();
	-- 执行注册事件 add by zhangjinpin
	for i, tbStart in ipairs(self.tbAllStartFun or {}) do
		print(i, tbStart);
		local tbCallBack = {tbStart.fun, unpack(tbStart.tbParam)};
		Lib:CallBack(tbCallBack);
	end
	-- 内存管理启动
	MemoryMgr:Start();	
end

--所有服务器启动完毕后回调注册事件 add by zhangjinpin
function GCEvent:RegisterAllServerStartFunc(fnStartFun, ...)
	if not self.tbAllStartFun then
		self.tbAllStartFun = {}
	end
	table.insert(self.tbAllStartFun, {fun=fnStartFun, tbParam=arg});
end

-- 注册GS启动后连接上GC执行函数
function GCEvent:RegisterGS2GCServerStartedFunc(fnStartFun, ...)
	if not self.tbStartedGS2GCConnectFun then
		self.tbStartedGS2GCConnectFun = {}
	end
	table.insert(self.tbStartedGS2GCConnectFun, {fun=fnStartFun, tbParam=arg});
end
