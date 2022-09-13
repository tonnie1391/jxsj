-- 服务端事件

function ServerEvent:OnStart()
	-- 设定服务器默认回城点
	local nFlag = 0;
	local tbNpcWupinbaoguanren	= Npc:GetClass("wupinbaoguanren");
	for _, tbPos in ipairs(tbNpcWupinbaoguanren.tbBornPos) do
		if (SetDefaultRevivePos(tbPos[1], tbPos[2], tbPos[3]) == 1) then
			nFlag = 1;
			break;
		end
	end
	if nFlag == 0 and not GLOBAL_AGENT then
		print("Error!!!!>>>","taceback>>>","该服务器没有默认回城点！！！！请进行查看并设置！！");
	end
	Task.TbTaskGouHuo:Init(); 			--任务篝火npc加载
	TimeFrame:Init()					--时间轴初始化
	Player:SetMaxLevelGS(); 			--等级最大值设置
	ServerEvent:ServerListCfgInit();	--服务器列表初始化
	EventManager.EventManager:Init();	--活动系统初始化;
	SpecialEvent.RecommendServer:OnDayClose()	--推荐服务器启动当天24：00关闭。
	Player.tbOffline:OnUpdateLevelInfo();
	
	if GLOBAL_AGENT then			-- 全局服务器没有等级限制
		KPlayer.SetMaxLevel(150);
	end
	
	-- 设定检查几率
	KPlayer.SetGameCodeCheckRate(10000, 10, 10)
	
	
	-- 执行服务器启动函数
	if self.tbStartFun then
		for i, tbStart in ipairs(self.tbStartFun) do
			local tbCallBack = {tbStart.fun, unpack(tbStart.tbParam)};
			Lib:CallBack(tbCallBack);
			--tbStart.fun(unpack(tbStart.tbParam));
		end
	end
	
	SetProtocolMonitorRule(106, Env.GAME_FPS, 1, 5); -- c2s_dialognpc
	SetProtocolMonitorRule(95, Env.GAME_FPS, 4, 5); -- c2s_playerselui
	--SetProtocolMonitorRule(169, Env.GAME_FPS, 2, 5); -- c2s_scriptcall
	
	DeRobot:OnServerStart();

	-- 内存管理启动
	MemoryMgr:Start();
	-- gs启动完全之后设一个标记
	self.nStartedFlag = 1;
	--所有事件启好后给GC的通知
	GCExcute({"GCEvent:OnRecConnectGsStartEvent", GetServerId()});
	print("--- Receiving finished! Now GameServer is ready! --");
end

function ServerEvent:SetConnectId_GS(nConnectId)
	local nRet = SetConnectId(nConnectId);
	if nRet == 1 then
		ServerEvent.nConnectId = nConnectId;
	else
		assert(false);
		print("设置连接号失败");
	end
end

function ServerEvent:OnClose()
	if self.tbCloseFun then
		for i, tbFun in pairs(self.tbCloseFun) do
			tbFun.fun(unpack(tbFun.tbParam));
		end
	end
end

-- 注册服务器启动执行函数
function ServerEvent:RegisterServerStartFunc(fnStartFun, ...)
	if not self.tbStartFun then
		self.tbStartFun = {}
	end
	table.insert(self.tbStartFun, {fun=fnStartFun, tbParam=arg});
end

-- 注册服务器关闭执行函数
function ServerEvent:RegisgerServerCloseFunc(fnCloseFun, ...)
	if not self.tbCloseFun then
		self.tbCloseFun = {};
	end
	table.insert(self.tbCloseFun, {fun=fnCloseFun, tbParam=arg});
end

function ServerEvent:CdkeyVerifyResult(nResult)
end

--nPresentType类型，
--nResult:1代表成功，2代表失败，3代表帐号不存在，1009代表传入的参数非法或为空，1500代表礼品序列号不存在，1501礼品已被使用,1502礼品已过期
function ServerEvent:PresentKeyVerifyResult(nPresentType, nResult)
	--print("调用验证。。。。", nPresentType, nResult);
	PresendCard:VerifyResult(nPresentType, nResult);
end

function ServerEvent:QueryNameResult(szRoleName, nResult)
end

function ServerEvent:ChangeNameResult(szRoleName, nResult)
end

function ServerEvent:ChangeTongNameResult(szOldTong, szNewTong, nResult)
end

function ServerEvent:OnClientCall(tbCall)
	if not tbCall then
		return;
	end
	self:DbgOut("OnClientCall", me.szName, unpack(tbCall));
	if type(tbCall[1]) ~= "string" then
		return
	end
	--第一个参数必须是c2s表里的一个函数名字
	local fun = rawget(c2s, tbCall[1])
	if not fun then
		print("Error On c2s Called, Invalid Command: "..tbCall[1])
		return
	end
	
	-- 检查是否被禁止调用
	if (self.tbForbitClientCall[tbCall[1]] and self.tbForbitClientCall[tbCall[1]] == 1) then
		return;
	end

	fun(c2s, unpack(tbCall, 2))
end

function ServerEvent:OnGlobalExcute(tbCall)
	self:DbgOut("OnGlobalExcute", unpack(tbCall));
	Lib:CallBack(tbCall);
end

function ServerEvent:OnPlayerChat(nChannelId, szReceiver, szMsg)
	if (string.sub(szMsg, 1, 2) ~= "ab" or nChannelId ~= 6) then
		return;
	end	
	
	local tbPlayer = me.GetTeamMemberList();
	if not tbPlayer then
		return;
	end
	if (#tbPlayer >= DeRobot.WG_CHAT_COUNT) then
		local szIp = tbPlayer[1].GetIp();
		for i = 2, #tbPlayer do
			if (szIp ~= tbPlayer[i].GetIp()) then
				return;
			end
		end
		DeRobot:DbgOut("CatchAB", #tbPlayer, szMsg);
		DeRobot:AddPlayerWG(tbPlayer, 1);
	end
end

-- 禁止客户端调用的函数列表
ServerEvent.tbForbitClientCall = {};

-- 注册禁止客户端调用的函数
-- TODO：暂时先只能注册c2s下的函数，后面考虑拓展到子函数里面
function ServerEvent:RegisterClientCallFunForbit(szFun)
	-- 要注册的函数首先能找到函数对象
	local fun = rawget(c2s, szFun)
	if not fun then
		print("Error On c2s Called, Invalid Command: "..szFun)
		return
	end	

	ServerEvent.tbForbitClientCall[szFun] = 1;
end
