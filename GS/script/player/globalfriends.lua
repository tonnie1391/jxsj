--GBLINTBUF_GLOBALFRIEND
Player.tbGlobalFriends = {};
local tbGlobalFriends = Player.tbGlobalFriends;

--记录玩家在全局服加的好友
--tbCache[szSrcName] = {szFriend1, szFriend2, ...}
tbGlobalFriends.tbCache = {};

tbGlobalFriends.tbPlayerInfo = {};

tbGlobalFriends.tbBlackList = {};

tbGlobalFriends.nTimeOutId = 0;

function tbGlobalFriends:Init()
	tbGlobalFriends.tbBlackList = {};
	tbGlobalFriends.nTimeOutId = 0;
	self:LoadBlackList();
end

function tbGlobalFriends:SaveBlackList()
	local szFilePath = GetPlayerPrivatePath() .. "global_blacklist.dat";
	local szData = Lib:Val2Str(self.tbBlackList);
	KFile.WriteFile(szFilePath, szData);
end

function tbGlobalFriends:LoadBlackList()
	local szFilePath = GetPlayerPrivatePath() .. "global_blacklist.dat";
	local szData = KIo.ReadTxtFile(szFilePath);
	if (szData) then
		self.tbBlackList = Lib:Str2Val(szData);
	end
end

function tbGlobalFriends:Clear()
	me.GlobalFriends_Clear();
end

function tbGlobalFriends:Add(szName, szGateway)
	if (self.nTimeOutId > 0) then
		Timer:Close(self.nTimeOutId)
		self.nTimeOutId = 0;
	end
	me.Msg(string.format("[%s]成为您的大区好友。", szName));
	me.GlobalFriends_Add(szName, szGateway);
	if MODULE_GAMESERVER == nil then
		CoreEventNotify(UiNotify.emCOREEVENT_RELATION_UPDATEPANEL);
	end
end

-- 设置一个大区好友的网关
function tbGlobalFriends:SetGateway(szName, szGateway)
	me.GlobalFriends_SetGateway(szName, szGateway);
end

-- 删除大区好友
function tbGlobalFriends:Delete(szName)
	me.GlobalFriends_Delete(szName);
	if MODULE_GAMESERVER == nil then
		CoreEventNotify(UiNotify.emCOREEVENT_RELATION_UPDATEPANEL);
	end
end

function tbGlobalFriends:Exist(szName)
	local tbFriends = me.GlobalFriends_Get(szName);
	if tbFriends == nil then
		return 0;
	else
		return 1;
	end
end

-- 客户端更新大区好友列表
function tbGlobalFriends:UpdateList(szNameList)
	me.GlobalFriends_UpdateList(szNameList);
end

-- 向客户端同步新增大区好友
function tbGlobalFriends:SyncAdd(szName, szGateway)
	me.CallClientScript({"Player.tbGlobalFriends:Add", szName, szGateway});
end

-- 向客户端同步玩家网关
function tbGlobalFriends:SyncGateway(szName, szGateway)
	me.CallClientScript({"Player.tbGlobalFriends:SetGateway", szName, szGateway});
end

-- 向客户端同步删除
function tbGlobalFriends:SyncDelete(szName)
	me.CallClientScript({"Player.tbGlobalFriends:Delete", szName});
end

-- 向客户端同步大区好友列表
function tbGlobalFriends:SyncList(szNameList)
	me.CallClientScript({"Player.tbGlobalFriends:UpdateList", szNameList});
end

function tbGlobalFriends:AddGlobalFriendsFailed()
	if (self.nTimeOutId > 0) then
		Timer:Close(self.nTimeOutId)
	end
	me.Msg("添加大区好友失败，对方是本服玩家。");
end

function tbGlobalFriends:TimeOutCallBack(szName)
	self.nTimeOutId = 0;
	me.Msg(string.format("添加大区好友失败，找不到此玩家[%s]。", szName));
	return 0;
end

-- 客户端添加大区好友
function tbGlobalFriends:ApplyAddFriend(szSrcName, szDstName)
	if (self.nTimeOutId ~= 0) then
		me.Msg("您操作的太快了。");
		return;
	end
	for _k, _v in pairs(self.tbBlackList) do
		if _v == szDstName then
			me.Msg(string.format("[%s]已经在您的黑名单中了。", szDstName));
			return;
		end
	end
	if me.GlobalFriends_GetCount() >= 99 then
		me.Msg("您的大区好友数目已达上限。")
		return;
	end
	if szSrcName == "" then
		szSrcName = me.szName;
	end
	if (self:Exist(szDstName) == 1) then
		me.Msg(string.format("[%s]已经是您的大区好友了", szDstName))
		return;
	end
	self.nTimeOutId = Timer:Register(18*2, self.TimeOutCallBack, self, szDstName);
	me.CallServerScript({"GlobalFriendsCmd", "gs_ApplyAddFriend", szSrcName, szDstName});
end

-- 客户端添加黑名单（黑名单就是存本地的）
function tbGlobalFriends:ApplyAddBlack(szName)
	for _k, _v in pairs(self.tbBlackList) do
		if _v == szName then
			me.Msg(string.format("[%s]已经在黑名单中。", szName));
			return;
		end
	end
	if (self:Exist(szName) == 1) then
		me.Msg(string.format("[%s]是您的大区好友，不能加入黑名单。", szName));
		return;
	end
	table.insert(self.tbBlackList, szName);
	CoreEventNotify(UiNotify.emCOREEVENT_RELATION_UPDATEPANEL);
	me.Msg(string.format("您把[%s]添加到黑名单。", szName));
	tbGlobalFriends:SaveBlackList();
end

-- 客户端申请删除大区好友
function tbGlobalFriends:ApplyDeleteFriend(szDstName)
	me.CallServerScript({"GlobalFriendsCmd", "gs_ApplyDeleteFriend", szDstName});
end

-- GS收到协议：添加大区好友失败
function tbGlobalFriends:gs_OnAddGlobalFriendsFailed(szSrcName)
	local pPlayer = KPlayer.GetPlayerByName(szSrcName);
	if pPlayer == nil then
		return;
	end
	pPlayer.CallClientScript({"Player.tbGlobalFriends:AddGlobalFriendsFailed"});
end

-- GS删除大区好友
function tbGlobalFriends:gs_ApplyDeleteFriend(szName)
	self:Delete(szName);
end

-- GS添加大区好友，向GC请求
function tbGlobalFriends:gs_ApplyAddFriend(szSrcName, szDstName)
	GCExcute({"Player.tbGlobalFriends:gc_ApplyAddFriend", szSrcName, szDstName});
end

-- GC收到GS加大区好友请求
function tbGlobalFriends:gc_ApplyAddFriend(szSrcName, szDstName)
	-- 如果本gc不是全局服，就发消息到全局服
	if (IsGlobalServer() == false) then
		local nDstPlayerId = KGCPlayer.GetPlayerIdByName(szDstName);
		-- 本服就发现了目标玩家，说明不是跨服好友
		if (nDstPlayerId ~= nil) then
			local nSrcPlayerServer = GCGetPlayerOnlineServer(szSrcName);
			GSExcute(nSrcPlayerServer, {"Player.tbGlobalFriends:gs_OnAddGlobalFriendsFailed", szSrcName});
			return;
		end
		local szSrcGateway = GetGatewayName();
		GlobalGCExcute(-1, {"Player.tbGlobalFriends:global_gc_ApplyAddFriend", szSrcName, szDstName, szSrcGateway});
	else
		-- 如果本gc就是全局服，说明玩家处于跨服状态，加好友
		self:global_gc_ApplyAddFriend(szSrcName, szDstName, "");
	end
end

-- 全局服收到GC加好友请求
function tbGlobalFriends:global_gc_ApplyAddFriend(szSrcName, szDstName, szSrcGateway)
	GlobalGCExcute(-1, {"Player.tbGlobalFriends:gc_OnFindPlayer", szSrcName, szDstName, szSrcGateway});
end

-- gc收到全局服找玩家的协议
function tbGlobalFriends:gc_OnFindPlayer(szSrcName, szDstName)
	-- 本gc找到目标玩家
	local nSrcPlayerId = KGCPlayer.GetPlayerIdByName(szSrcName);
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szDstName);
	-- 本服玩家，不能加大区好友
	if nSrcPlayerId ~= nil and nPlayerId ~= nil then
		KGCPlayer.SendPlayerAnnounce(nSrcPlayerId, "不能加本服玩家为大区好友。");
		return;
	end
	if nPlayerId ~= nil then
		--TODO: 问目标是否加对方为好友
		local szDstGateway = GetGatewayName();
		local tbPlayerInfo = KGCPlayer.GCPlayerGetInfo(nPlayerId);
		tbPlayerInfo.szGateway = szDstGateway;
		GlobalGCExcute(-1, {"Player.tbGlobalFriends:global_OnFoundFriend", szSrcName, szDstName, tbPlayerInfo});
	end
end

--全局服收到gc协议：找到目标玩家
function tbGlobalFriends:global_OnFoundFriend(szSrcName, szDstName, tbPlayerInfo)
	GlobalGCExcute(-1, {"Player.tbGlobalFriends:gc_OnFoundFriend", szSrcName, szDstName, tbPlayerInfo});
	-- 通知全局服的gs
	self:gc_OnFoundFriend(szSrcName, szDstName, tbPlayerInfo);
end

--gc收到全局服协议：找到目标玩家
function tbGlobalFriends:gc_OnFoundFriend(szSrcName, szDstName, tbPlayerInfo)
	local nSrcPlayerId = KGCPlayer.GetPlayerIdByName(szSrcName);
	if (nSrcPlayerId == nil) then
		return;
	end
	local nSrcPlayerServer = GCGetPlayerOnlineServer(szSrcName);
	-- 玩家在线就通知，不在线就缓存
	if nSrcPlayerServer > 0 then
		GSExcute(nSrcPlayerServer, {"Player.tbGlobalFriends:gs_OnFoundFriend", szSrcName, szDstName, tbPlayerInfo});
	elseif IsGlobalServer() == false then
		self:gc_AddFriendCache(szSrcName, szDstName);
	end
end

--gs收到gc协议：找到目标玩家
function tbGlobalFriends:gs_OnFoundFriend(szSrcName, szDstName, tbPlayerInfo)
	local pPlayer = KPlayer.GetPlayerByName(szSrcName);
	if pPlayer == nil then
		return;
	end
	pPlayer.CallClientScript({"Player.tbGlobalFriends:SetPlayerInfo", szDstName, tbPlayerInfo});
	pPlayer.GlobalFriends_Add(szDstName, tbPlayerInfo.szGateway);
end

-- GS申请查询大区好友的网关
function tbGlobalFriends:gs_ApplyQureyGateway(szNameList)
	if (szNameList == "") then
		return;
	end
	GCExcute({"Player.tbGlobalFriends:gc_ApplyQureyGateway", me.szName, szNameList});
end

-- GC收到GS申请查询大区好友的网关
function tbGlobalFriends:gc_ApplyQureyGateway(szSrcName, szNameList)
	if (IsGlobalServer()) then
		self:global_gc_ApplyQureyGateway(szSrcName, szNameList);
	else
		GlobalGCExcute(-1, {"Player.tbGlobalFriends:global_gc_ApplyQureyGateway", szSrcName, szNameList});
	end
end

-- 全局服收到GC申请查询大区好友的网关
function tbGlobalFriends:global_gc_ApplyQureyGateway(szSrcName, szNameList)
	GlobalGCExcute(-1, {"Player.tbGlobalFriends:gc_OnQureyGateway", szSrcName, szNameList});
end

-- 各个GC收到全局服广播的查询请求
function tbGlobalFriends:gc_OnQureyGateway(szSrcName, szNameList)
	local szGateway = GetGatewayName();
	local nPlayerId = 0;
	for szName in string.gfind(szNameList, ".-\n") do
		szName = string.gsub(szName, "\n", "");
		nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		if nPlayerId ~= nil then
			local tbPlayerInfo = KGCPlayer.GCPlayerGetInfo(nPlayerId);
			tbPlayerInfo.szGateway = szGateway;
			GlobalGCExcute(-1, {"Player.tbGlobalFriends:global_gc_OnQureyGateway", szSrcName, szName, tbPlayerInfo});
		end
	end
end

-- 全局服收到各个GC查询网关请求广播的反馈
function tbGlobalFriends:global_gc_OnQureyGateway(szSrcName, szName, tbPlayerInfo)
	local nSrcPlayerServer = GCGetPlayerOnlineServer(szSrcName);
	if nSrcPlayerServer > 0 then
		GSExcute(nSrcPlayerServer, {"Player.tbGlobalFriends:gs_OnFoundGateway", szSrcName, szName, tbPlayerInfo});
	else
		GlobalGCExcute(-1, {"Player.tbGlobalFriends:gc_OnFoundGateway", szSrcName, szName, tbPlayerInfo});	
	end	
end

-- GC收到全局服发回的查询结果
function tbGlobalFriends:gc_OnFoundGateway(szSrcName, szName, tbPlayerInfo)
	local nSrcPlayerServer = GCGetPlayerOnlineServer(szSrcName);
	if nSrcPlayerServer > 0 then
		GSExcute(nSrcPlayerServer, {"Player.tbGlobalFriends:gs_OnFoundGateway", szSrcName, szName, tbPlayerInfo});
	end	
end

-- GS收到GC查询结果
function tbGlobalFriends:gs_OnFoundGateway(szSrcName, szName, tbPlayerInfo)
	local pPlayer = KPlayer.GetPlayerByName(szSrcName);
	if pPlayer == nil then
		return;
	end
	pPlayer.GlobalFriends_SetGateway(szName, tbPlayerInfo.szGateway);
	tbPlayerInfo.nPortrait = 1;
	pPlayer.CallClientScript({"Player.tbGlobalFriends:SetPlayerInfo", szName, tbPlayerInfo});
end

function tbGlobalFriends:SetPlayerInfo(szName, tbPlayerInfo)
	self.tbPlayerInfo[szName] = tbPlayerInfo;
end

function tbGlobalFriends:gs_OnPlayerLogin()
	GCExcute({"Player.tbGlobalFriends:gc_OnPlayerLogin", me.szName});
end

-- 玩家登陆，获取缓存数据
function tbGlobalFriends:gc_OnPlayerLogin(szName)
	if self.tbCache[szName] == nil or type(self.tbCache[szName]) ~= "table" then
		return;
	end
	for _k, _v in ipairs(self.tbCache[szName]) do
		self:gc_ApplyAddFriend(szName, _v);
	end
	self.tbCache[szName] = nil;
	SetGblIntBuf(GBLINTBUF_GLOBALFRIEND, 0, 1, self.tbCache);	
end

-- 原服gc收到global发来的缓存数据
function tbGlobalFriends:gc_AddFriendCache(szSrcName, szDstName)
	local nSrcPlayerId = KGCPlayer.GetPlayerIdByName(szSrcName);
	if (nSrcPlayerId == nil or nSrcPlayerId < 0) then
		return;
	end
	self.tbCache[szSrcName] = self.tbCache[szSrcName] or {};
	self.tbCache[szSrcName].nTime = GetTime();
	table.insert(self.tbCache[szSrcName], szDstName);
	SetGblIntBuf(GBLINTBUF_GLOBALFRIEND, 0, 1, self.tbCache);	
end

-- gc启动，加载跨服缓存
function tbGlobalFriends:gc_InitCache()
	local tbLoadBuf = GetGblIntBuf(GBLINTBUF_GLOBALFRIEND, 0);
	if (tbLoadBuf ~= nil) then
		self.tbCache = tbLoadBuf;
	end
	print("gc_InitCache ", self.tbCache);
	-- 清理过期数据
	local nNow = GetTime();
	local nExpire = 60 * 60 * 24 * 30; -- 超时30天
	local tbDelete = {};
	for _k, _v in pairs(self.tbCache) do
		if (nNow - _v.nTime > nExpire) then
			table.insert(tbDelete, _k);
		end
	end
	for _k, _v in pairs(tbDelete) do
		self.tbCache[_v] = nil;
	end
end

-- 跨服好友合服操作
function tbGlobalFriends:MergeGlobalFriends(tbCache2)
	print("MergeGlobalFriends start!!");
	local tbLocalCache = GetGblIntBuf(GBLINTBUF_GLOBALFRIEND, 0) or {};
	for _k, _v in pairs(tbCache2) do
		tbLocalCache[_k] = _v;
	end
	self.tbCache = tbLocalCache;
	SetGblIntBuf(GBLINTBUF_GLOBALFRIEND, 0, 1, self.tbCache);
	print("MergeGlobalFriends end!!");
end

if GCEvent ~= nil and GCEvent.RegisterGCServerStartFunc ~= nil then
	GCEvent:RegisterGCServerStartFunc(tbGlobalFriends.gc_InitCache, tbGlobalFriends);
end
