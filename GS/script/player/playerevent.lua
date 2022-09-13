
if (not PlayerEvent.tbGlobalEvent) then
	PlayerEvent.tbGlobalEvent	= {};
end

-- 注册特定玩家事件回调
function PlayerEvent:Register(szEvent, varCallBack, varSelfParam)
	local tbPlayerData	= me.GetTempTable("PlayerEvent");
	local tbPlayerEvent	= tbPlayerData.tbPlayerEvent;
	if (not tbPlayerEvent) then
		tbPlayerEvent	= {};
		tbPlayerData.tbPlayerEvent	= tbPlayerEvent;
	end;
	local tbEvent	= tbPlayerEvent[szEvent];
	if (not tbEvent) then
		tbEvent	= {};
		tbPlayerEvent[szEvent]	= tbEvent;
	end;
	local nRegisterId	= #tbEvent + 1;
	tbEvent[nRegisterId]= {varCallBack, varSelfParam};
	return nRegisterId;
end;

-- 注销特定玩家事件回调
function PlayerEvent:UnRegister(szEvent, nRegisterId)
	local tbPlayerEvent	= me.GetTempTable("PlayerEvent").tbPlayerEvent;
	if (not tbPlayerEvent) then
		return;
	end;
	local tbEvent	= tbPlayerEvent[szEvent];
	if (not tbEvent or not tbEvent[nRegisterId]) then
		return;
	end
	tbEvent[nRegisterId]	= nil;
	return 1;
end;

-- 注册全局玩家事件回调
function PlayerEvent:RegisterGlobal(szEvent, varCallBack, varSelfParam)
	local tbEvent	= self.tbGlobalEvent[szEvent];
	if (not tbEvent) then
		tbEvent	= {};
		self.tbGlobalEvent[szEvent]	= tbEvent;
	end;
	local nRegisterId	= #tbEvent + 1;
	tbEvent[nRegisterId]= {varCallBack, varSelfParam};
	return nRegisterId;
end;

-- 注销全局玩家事件回调
function PlayerEvent:UnRegisterGlobal(szEvent, nRegisterId)
	local tbEvent	= self.tbGlobalEvent[szEvent];
	if (not tbEvent or not tbEvent[nRegisterId]) then
		return;
	end;
	tbEvent[nRegisterId]	= nil;
	return 1;
end;

-- 被系统调用，某事件发生
function PlayerEvent:OnEvent(szEvent, ...)
	-- 先检查全局注册回调
	self:_CallBack(self.tbGlobalEvent[szEvent], arg);
	
	-- 然后检查本玩家注册回调
	local tbPlayerEvent	= me.GetTempTable("PlayerEvent").tbPlayerEvent;
	if (not tbPlayerEvent) then
		return;
	end;
	self:_CallBack(tbPlayerEvent[szEvent], arg);
end;

function PlayerEvent:_CallBack(tbEvent, tbArg)
	if (not tbEvent) then
		return;
	end
	--为了防止循环中出现新注册导致出错，采用Copy方式
	for nRegisterId, tbCallFunc in pairs(Lib:CopyTB1(tbEvent)) do
		if (tbEvent[nRegisterId]) then	-- 检测是否未被删除
			local varCallBack	= tbCallFunc[1];
			local varSelfParam	= tbCallFunc[2];
			local tbCallBack	= nil;
			if (varSelfParam) then
				tbCallBack	= {varCallBack, varSelfParam, unpack(tbArg)};
			else
				tbCallBack	= {varCallBack, unpack(tbArg)};
			end
			Lib:CallBack(tbCallBack);
		end
	end
end


function PlayerEvent:OnLoginDelay(nStep)
	-- TODO: FanZai	改为注册式。可以考虑使用脚本实现延迟。
	-- 执行登陆后函数
	if self.tbLoginFun then
		for i, tbLogin in pairs(self.tbLoginFun) do
			if tbLogin.fun then
				tbLogin.fun(unpack(tbLogin.tbParam));
			end
		end
	end	
	
	-- 判断是否冻结，踢下线
	Player:OnLogin_CheckFreeze()

	return 1;	-- 返回1表示结束
end

--注册玩家登陆后执行事件
function PlayerEvent:RegisterOnLoginEvent(fnStartFun, ...)
	if not self.tbLoginFun then
		self.tbLoginFun = {}
	end
	local nRegisterId = #self.tbLoginFun + 1;
	self.tbLoginFun[nRegisterId]  = {fun=fnStartFun, tbParam=arg};	
	return nRegisterId;
end

--注销玩家登陆后执行事件
function PlayerEvent:UnRegisterOnLoginEvent(nRegisterId)
	if not self.tbLoginFun or not self.tbLoginFun[nRegisterId] then
		return;
	end
	self.tbLoginFun[nRegisterId] = nil;
	return 1;
end

-- 新键角色快捷栏默认放置的物品
local tbShortCutItem = {	
	{nGenre = 19, nDetail = 3, nParticular = 1, nLevel = 1, nSeries = 0},
	{nGenre = 17, nDetail = 1, nParticular = 1, nLevel = 1, nSeries = 0},
	{nGenre = 17, nDetail = 2, nParticular = 1, nLevel = 1, nSeries = 0},
};

local SHORTCUT_TASK_GROUP	= 3;		-- 快捷栏任务变量组号
local SHORTCUT_FLAG_TASK	= 21;		-- 类型标志任务变量号

local SHORT_CUT_VALUE = 
{
	{0,0,0},{0,0,0},{0,0,0}
};

	local nFlags = 0;
for nPosition = 1,3 do
	local tbObj = tbShortCutItem[nPosition];
	nFlags = Lib:SetBits(nFlags, 1, nPosition * 3 - 3, nPosition * 3 -1);
	local nLow  = Lib:SetBits(tbObj.nGenre, tbObj.nDetail, 16, 31);
	local nHigh = Lib:SetBits(tbObj.nParticular, tbObj.nLevel, 16, 23);
	nHigh = Lib:SetBits(nHigh, tbObj.nSeries, 24, 31);
	SHORT_CUT_VALUE[nPosition][1] = nFlags;
	SHORT_CUT_VALUE[nPosition][2] = nLow;
	SHORT_CUT_VALUE[nPosition][3] = nHigh;
end

-- 新建角色首次登录
function PlayerEvent:OnFirstLogin()
	-- 通知客户端首次登录
	--me.CallClientScript({"Ui:OnFirstLogin"});
	--设置快捷栏前三格
	for i = 1,3 do
		me.SetTask(SHORTCUT_TASK_GROUP, SHORTCUT_FLAG_TASK, SHORT_CUT_VALUE[i][1]);
		me.SetTask(SHORTCUT_TASK_GROUP, i * 2 - 1, SHORT_CUT_VALUE[i][2]);
		me.SetTask(SHORTCUT_TASK_GROUP, i * 2, SHORT_CUT_VALUE[i][3]);
		me.ClearAccountLock();
	end
	
	--设置新建角色技能
	for i = 1, 9 do
		me.AddFightSkill(i, 1);
	end
	me.AddFightSkill(281, 1);
	
	me.AddFightSkill(10, 20);
	me.AddFightSkill(3016, 1);
	
	me.ClearAccountLock();

	--by jiazhenwei 某个日期之前建立角色时奖励道具
	local tbBuffer = GetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0);
	if not tbBuffer or type(tbBuffer) ~= "table" then
		tbBuffer = {};
	end
	if tbBuffer[1] and tbBuffer[1][1] and Lib:GetDate2Time(tbBuffer[1][1]) > GetTime() then
		for _, tb in pairs(tbBuffer[1]) do
			if type(tb) == "table" and #tb == 6 then
				if tb[6] > 0 then
					for i = 1, tb[5] do
						local pItem  = me.AddItem(tb[1], tb[2], tb[3], tb[4]);
						if pItem then
							pItem.Bind(1);
							me.SetItemTimeout(pItem, tb[6], 0);
						end
					end
				else
					me.AddStackItem(tb[1], tb[2], tb[3], tb[4],{bForceBind = 1}, tb[5]);
				end
			end
		end
	end
	--end

	if (me.GetTask(2181,3) <= 0) then
		me.SetTask(2181, 3, me.GetRoleCreateDate());
	end
	
	--开放79级上限的服务器，自动开启直升系统（9月5日后，用通过的登陆事件,这里的代码可以删除）
	if tonumber(GetLocalDate("%Y%m%d")) <= 20120904 then
		if TimeFrame:GetState("OpenLevel79") == 1 then
			me.SetTask(SpecialEvent.tbVipInvite.TASK_GROUPID,  SpecialEvent.tbVipInvite.INVITED, 1);
		end
	end
	
	-- 对于新建号的玩家都加上2次逍遥谷
	XoyoGame:AddPlayerTimes(me, 14);
	
	SpecialEvent.PlayerLevelUpGift:GiveGift();
	
	me.AddStackItem(18, 1, 648, 1, {bForceBind=1}, 1);
	me.AddStackItem(18, 1, 1208, 1, {bForceBind=1}, 1);
	
	me.AddTitle(999,3,1,1);
	me.SetCurTitle(999,3,1,1);
end

PlayerEvent.tbProtocolRule = 
{
	--[89] = {szMsg = "警告！您使用道具的频度太高！"},
	--[169] = {szMsg = "您的插件涉及违规行为，继续使用可能会被强制下线甚至冻结帐号！"},
}

function PlayerEvent:OnTooManyProtocol(nProtocol)
	if self.tbProtocolRule[nProtocol] and self.tbProtocolRule[nProtocol].szMsg then
		me.Msg(self.tbProtocolRule[nProtocol].szMsg);
	end
end
