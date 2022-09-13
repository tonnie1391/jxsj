-- 文件名　：gm_player.lua
-- 创建者　：FanZai
-- 创建时间：2008-10-10 12:21:04
-- 文件说明：GM指令——多玩家操作系列

local tbGmPlayer	= GM.tbPlayer or {};

GM.tbPlayer	= tbGmPlayer;

tbGmPlayer.MAX_RECENTPLAYER	= 5;	-- 最近操作玩家列表

tbGmPlayer.tbRemoteList	= {};	-- 全服玩家列表，每次开主菜单刷新

function tbGmPlayer:Main()
	local tbOpt	= {
		{"输出玩家列表", self.OutputAllPlayer, self},
		{"召唤所有玩家", self.ComeHereAll, self},
		{"选定玩家操作", self.ListAllPlayer, self},
	};
	
	-- 最近操作玩家
	local tbRecentPlayerList	= me.GetTempTable("GM").tbRecentPlayerList or {};
	for nIndex, nPlayerId in ipairs(tbRecentPlayerList) do
		local tbInfo	= self.tbRemoteList[nPlayerId];
		if (tbInfo) then
			tbOpt[#tbOpt+1]	= {"<color=green>"..tbInfo[1], self.SelectPlayer, self, nPlayerId, tbInfo[1]};
		end
	end
	tbOpt[#tbOpt + 1]	= {"<color=gray>Kết thúc đối thoại"};

	Dialog:Say("你想干什么？<pic=20>", tbOpt);

	-- 更新全服玩家列表
	self.tbRemoteList	= {};
	GlobalExcute({"GM.tbPlayer:RemoteList_Fetch", me.nId})
	
	-- 每次都重载这个脚本
	DoScript("\\script\\misc\\gm_player.lua");
end

function tbGmPlayer:OutputAllPlayer()
	me.Msg(" ", "当前服务器玩家列表");
	for nPlayerId, tbInfo in pairs(self.tbRemoteList) do
		local szMsg	= string.format("%d级 %s %s", tbInfo[2],
			Player:GetFactionRouteName(tbInfo[3], tbInfo[4]), GetMapNameFormId(tbInfo[5]));
		me.Msg(szMsg, tbInfo[1]);
	end
end

function tbGmPlayer:ComeHereAll()
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	me.Msg("全体集合！");
	self:RemoteCall_ApplyAll("me.NewWorld", nMapId, nMapX, nMapY);
end

function tbGmPlayer:ListAllPlayer()
	local tbOpt	= {};
	for nPlayerId, tbInfo in pairs(self.tbRemoteList) do
		tbOpt[#tbOpt+1]	= {"<color=green>"..tbInfo[1], self.SelectPlayer, self, nPlayerId, tbInfo[1]};
	end
	tbOpt[#tbOpt + 1]	= {"<color=gray>Kết thúc đối thoại"};
	Dialog:Say("你想找哪个？<pic=58>", tbOpt);
end

function tbGmPlayer:SelectPlayer(nPlayerId, szPlayerName)
	-- 插入最近操作玩家
	local tbPlayerData			= me.GetTempTable("GM");
	local tbRecentPlayerList	= tbPlayerData.tbRecentPlayerList or {};
	tbPlayerData.tbRecentPlayerList	= tbRecentPlayerList;
	for nIndex, nRecentPlayerId in ipairs(tbRecentPlayerList) do
		if (nRecentPlayerId == nPlayerId) then
			table.remove(tbRecentPlayerList, nIndex);
			break;
		end
	end
	if (#tbRecentPlayerList >= self.MAX_RECENTPLAYER) then
		table.remove(tbRecentPlayerList);
	end
	table.insert(tbRecentPlayerList, 1, nPlayerId);
	
	local tbInfo	= self.tbRemoteList[nPlayerId];
	if (not tbInfo) then
		me.Msg(string.format("[%s]消失得无影无踪...", szPlayerName));
		return;
	end
	
	local szMsg	= string.format("名字：%s\n等级：%d级\n路线：%s\n位置：%s",
		tbInfo[1], tbInfo[2], Player:GetFactionRouteName(tbInfo[3], tbInfo[4]),
		GetMapNameFormId(tbInfo[5]));
	
	Dialog:Say(szMsg,
		{"拉他过来", self.CallSomeoneHere, self, nPlayerId},
		{"送我过去", self.RemoteCall_ApplyOne, self, nPlayerId, "GM.tbPlayer:CallSomeoneHere", me.nId},
		{"踢他下线", self.RemoteCall_ApplyOne, self, nPlayerId, "me.KickOut"},
		{"<color=gray>Kết thúc đối thoại"}
	);
end

function tbGmPlayer:CallSomeoneHere(nPlayerId)
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	self:RemoteCall_ApplyOne(nPlayerId, "me.NewWorld", nMapId, nMapX, nMapY);
end


--== 全服玩家列表 ==--
-- 将本服务器玩家列表发送出去
function tbGmPlayer:RemoteList_Fetch(nToPlayerId)
	local tbLocalPlayer = KPlayer.GetAllPlayer();
	local tbRemoteList	= {};
	for _, pPlayer in pairs(tbLocalPlayer) do
		tbRemoteList[pPlayer.nId]	= {
			pPlayer.szName,
			pPlayer.nLevel,
			pPlayer.nFaction,
			pPlayer.nRouteId,
			pPlayer.nMapId,
		};
	end
	GlobalExcute({"GM.tbPlayer:RemoteList_Receive", nToPlayerId, tbRemoteList})
end
-- 收到传回的玩家列表
function tbGmPlayer:RemoteList_Receive(nToPlayerId, tbRemoteList)
	local pPlayer	= KPlayer.GetPlayerObjById(nToPlayerId);
	if (not pPlayer) then
		return;
	end
	for nPlayerId, tbInfo in pairs(tbRemoteList) do
		self.tbRemoteList[nPlayerId]	= tbInfo;
	end
end


--== 全服/单一玩家执行 ==--
-- 申请为全服玩家执行
function tbGmPlayer:RemoteCall_ApplyAll(...)
	GlobalExcute({"GM.tbPlayer:RemoteCall_DoAll", arg})
end
-- 为本服务器玩家执行
function tbGmPlayer:RemoteCall_DoAll(tbCallBack)
	local tbLocalPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbLocalPlayer) do
		pPlayer.Call(unpack(tbCallBack));
	end
end
-- 申请为单一玩家执行
function tbGmPlayer:RemoteCall_ApplyOne(nToPlayerId, ...)
	GlobalExcute({"GM.tbPlayer:RemoteCall_DoOne", nToPlayerId, arg})
end
-- 为本服务器玩家执行
function tbGmPlayer:RemoteCall_DoOne(nToPlayerId, tbCallBack)
	local pPlayer	= KPlayer.GetPlayerObjById(nToPlayerId);
	if (pPlayer) then
		pPlayer.Call(unpack(tbCallBack));
	end
end

--GM快捷指令
function tbGmPlayer:GMShortcutailasCmd()
	local szMsg = "你好！！这里有一些常用的GM工具，你想要做什么？？？\n\n该功能脚本文件位置：script\\misc\\gm_player.lua";
	local tbOpt = {
		{"生成服务器列表", self.CreateServerList, self},
		{"生成任务列表", self.CreateTaskList, self},
		{"生成成就列表", self.CreateAchievementList, self},
		{"没啥了"},
	};
	Dialog:Say(szMsg, tbOpt);
end

--任务
function tbGmPlayer:CreateTaskList()
	me.CallClientScript({"ServerEvent:CreateTaskList"});
end

--成就
function tbGmPlayer:CreateAchievementList()
	me.CallClientScript({"ServerEvent:CreateAchievementList"});
end

--生成服务器列表
function tbGmPlayer:CreateServerList(nFlag)
	if not nFlag then
		local szMsg = "  请把从网站下载下来的serverlist.ini，放在你客户端的如下位置：\\setting\\serverlist.ini\n\n如果已经放好，是否现在生成serverlistcfg.txt？\n\n增量生成：读取包文件，在上面保留老服为主服。\n全新生成:不读包文件，按列表全新生成。";
		local tbOpt = {
			{"下载列表", self.DownLoadServerList, self},
			{"确定生成(增量)-推荐", self.CreateServerList, self, 1},
			{"确定生成(全新)", self.CreateServerList, self, 2},
			{"Quay lại", self.GMShortcutailasCmd ,self},
			};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	if nFlag == 1 then
		me.CallClientScript({"ServerEvent:CSList_Modiff", "\\setting\\serverlist.ini"});
	else
		me.CallClientScript({"ServerEvent:CSList", "\\setting\\serverlist.ini"});
	end
end

function tbGmPlayer:DownLoadServerList()
	me.CallClientScript({"OpenWebSite", "http://jxsj.autoupdate.kingsoft.com/jxsj/serverlist/serverlist.ini"});
	local szMsg = "已经通过IE浏览器打开并下载最新的服务器列表，请保存到客户端的如下位置：\\setting\\serverlist.ini\n\n我已经保存好了，现在马上生成最新的服务器列表配置文件吗？";
	local tbOpt = {
			{"确定生成", self.CreateServerList, self, 1},
			{"Quay lại", self.GMShortcutailasCmd ,self},
	};
	Dialog:Say(szMsg, tbOpt);
end