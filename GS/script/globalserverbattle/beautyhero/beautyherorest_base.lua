local tbMatchRestBase	= {};	-- 	门派战休息时间活动
BeautyHero.tbMatchRestBase = tbMatchRestBase;
tbMatchRestBase.tbPlayerIdList = {}; --玩家列表
tbMatchRestBase.NPC_TEMPID = 7018;	--刷npc的模版ID
tbMatchRestBase.POS_SUM	   = 32;
tbMatchRestBase.TRAP_CONFIG = "\\setting\\beautyhero\\trap.txt"; 	--npc刷新trap点绑定文件

--旗帜阶段性出现 时间单位秒
tbMatchRestBase.RESTSTATE =	
{
	[1] = {nEndTime = 70,}, --第90秒
	[2] = {nEndTime = 70,}, --第180秒
	[3] = {nEndTime = 70,}, --第270秒
	[4] = {nEndTime = 70,}, --第360秒
	[5] = {nEndTime = 60,}, --第420秒
}
local nTimeLastSum = 0;
for nRestState, tbTime in pairs(tbMatchRestBase.RESTSTATE) do
		nTimeLastSum = nTimeLastSum + tbTime.nEndTime;
end
tbMatchRestBase.STATE_TIEM_SUM = nTimeLastSum;	--记录总时间

--数据维护函数start-------------

function tbMatchRestBase:InitRest(nMapId)	--数据初始化
	self.nMapId  = nMapId; 	--nMapId:活动地图
	self.nState = 0;			 	--开启状态, 0未开启，1,2,3,4,5为各阶段
	self.tbNpcIdList = {} 	--刷所有npc的ID列表
	self.nTimerId = 0;			--刷npc所产生的定时器Id
	self.nTimeLastSum = self.STATE_TIEM_SUM;
end

function tbMatchRestBase:StartRest()	--开启活动
	if self.nState > 0 then
		print("活动进行开启，请完毕后再开启。不能重启开启。");
		return 0;
	end
	self.nTimerId = Timer:Register(self.RESTSTATE[1].nEndTime * Env.GAME_FPS ,  self.StartState,  self);	
	self:StartState();
end

function tbMatchRestBase:CallRandomNpc()
	self:RandomPos();
	self.tbNpcIdList = {};
	for nPos=1, self.POS_SUM do
		local pNPC = KNpc.Add2(self.NPC_TEMPID, 100, -1, self.nMapId * 1,math.floor(self.tbNpcPos[nPos].nX /32), math.floor(self.tbNpcPos[nPos].nY /32), 0, 0, 0)
		if  not pNPC then
			print("[ERR]tbMatchRestBase add npc failed");
		else
		--	local tbNpcInfo = pNPC.GetTempTable("FactionBattle");
		--	tbNpcInfo.tbBaseClass = self;
			self.tbNpcIdList[#self.tbNpcIdList+ 1] = pNPC.dwId;
		end
	end
end

function tbMatchRestBase:StartState()
	self.nState = self.nState + 1;
	if self.nState > #self.RESTSTATE then
		self:CloseRest();
		return 0;
	else
		if self.nState > 1 then
			self.nTimeLastSum = self.nTimeLastSum - self.RESTSTATE[self.nState - 1].nEndTime;
		end
		self:ClearNpc();	--清除上次npc
		self:CallRandomNpc(); --召唤npc
--		self:BroadcastMsg();	--公告
--		self:OpenShowMsg(); --打开所有玩家界面
		return self.RESTSTATE[self.nState].nEndTime * Env.GAME_FPS;
	end
	return 0;
end

function tbMatchRestBase:InitPos()		--从配置文件获得npc的trap
	local tbsortpos = Lib:LoadTabFile(self.TRAP_CONFIG);
	if not tbsortpos then
		print("[ERR]tbMatchRestBase LoadTabFile fail");
		return;
	end
	local nLineCount = #tbsortpos;
	local tbClassPos = {};
	for nLine=1, nLineCount do
		local nTrapX = tonumber(tbsortpos[nLine].TRAPX);
		local nTrapY = tonumber(tbsortpos[nLine].TRAPY);
		tbClassPos[#tbClassPos+1] = {nX = nTrapX, nY = nTrapY};
	end
	self.tbClassPos = tbClassPos;	
end

function tbMatchRestBase:RandomPos()
	local tbClassPos = self.tbClassPos;
	Lib:SmashTable(tbClassPos)
	self.tbNpcPos = tbClassPos;
end

function tbMatchRestBase:GetRandomList(tbitem, nmax)	--把table进行随机，返回随机表
	for ni = 1, nmax do
		local p = MathRandom(1, nmax);
		tbitem[ni], tbitem[p] = tbitem[p], tbitem[ni];
	end
	return tbitem;
end

function tbMatchRestBase:CloseRest()	--关闭基类
	self.nState = 0;
	if self.nTimerId ~= 0 then
		Timer:Close(self.nTimerId);
	end
	self.nTimerId = 0;		--刷npc所产生的定时器Id	
	self.nTimeLastSum = self.STATE_TIEM_SUM;
	self:ClearNpc();
end

function tbMatchRestBase:ClearNpc()	--清除npc
	if self.tbNpcIdList and #self.tbNpcIdList ~= 0 then 
		for nNpcNo=1, #self.tbNpcIdList do
			local pNpc = KNpc.GetById(self.tbNpcIdList[nNpcNo]);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbNpcIdList = {};	
end

tbMatchRestBase:InitPos();		--从配置文件获得npc的trap