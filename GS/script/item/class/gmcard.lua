-- GM专用卡

local tbGMCard	= Item:GetClass("gmcard");

tbGMCard.MAX_RECENTPLAYER	= 15;

function tbGMCard:OnUse()
	local nIsHide	= GM.tbGMRole:IsHide();
	
	local tbOpt = {
		{(nIsHide == 1 and "取消隐身") or "开始隐身", "GM.tbGMRole:SetHide", 1 - nIsHide},
		{"输入角色名", self.AskRoleName, self},
		{"身边的玩家", self.AroundPlayer, self},
		{"最近操作玩家", self.RecentPlayer, self},
		{"自身等级调整", self.AdjustLevel, self},
		--{"重载脚本[临时]", self.Reload, self},
		{"<color=yellow>跨服竞技记者<color>", self.LookGlbBattle, self},
		{"<color=yellow>皇陵无极限<color>", self.SuperQinling, self},
		{"<color=yellow>楼兰古城观察员<color>", Atlantis.PlayerEnter, Atlantis},
		{"Kết thúc đối thoại"},
	};
	
	Dialog:Say("\n  客服同学们辛苦了！<pic=28>\n\n      ～～为人民服务<pic=98><pic=98><pic=98>", tbOpt);
	
	return 0;
end;

function tbGMCard:SuperQinling()
	me.NewWorld(1536, 1567, 3629);
	me.SetTask(2098, 1, 0);
	me.AddSkillState(1413, 4, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 1);
end

function tbGMCard:Reload()
	local nRet1	= DoScript("\\script\\item\\class\\gmcard.lua");
	local nRet2	= DoScript("\\script\\misc\\gm_role.lua");
	GCExcute({"DoScript", "\\script\\misc\\gm_role.lua"});
	local szMsg	= "Reloaded!!("..nRet1..","..nRet2..GetLocalDate(") %Y-%m-%d %H:%M:%S");
	me.Msg(szMsg);
	print(szMsg);
end

function tbGMCard:AskRoleName()
	Dialog:AskString("玩家角色名", 16, self.OnInputRoleName, self);
end

function tbGMCard:OnInputRoleName(szRoleName)
	local nPlayerId	= KGCPlayer.GetPlayerIdByName(szRoleName);
	if (not nPlayerId) then
		Dialog:Say("此角色名不存在！", {"重新输入", self.AskRoleName, self}, {"Kết thúc đối thoại"});
		return;
	end
	
	self:ViewPlayer(nPlayerId);
end

function tbGMCard:ViewPlayer(nPlayerId)
	-- 插入最近玩家列表
	local tbRecentPlayerList	= self.tbRecentPlayerList or {};
	self.tbRecentPlayerList		= tbRecentPlayerList;
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

	local szName	= KGCPlayer.GetPlayerName(nPlayerId);
	local tbInfo	= GetPlayerInfoForLadderGC(szName);
	local tbState	= {
		[0]		= "不在线",
		[-1]	= "处理中",
		[-2]	= "挂机？",
	};
	local nState	= KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_ONLINESERVER);
	local tbText	= {
		{"名字", szName},
		{"账号", tbInfo.szAccount},
		{"等级", tbInfo.nLevel},
		{"性别", (tbInfo.nSex == 1 and "女") or "男"},
		{"路线", Player:GetFactionRouteName(tbInfo.nFaction, tbInfo.nRoute)},
		{"家族", tbInfo.szKinName},
		{"帮会", tbInfo.szTongName},
		{"威望", KGCPlayer.GetPlayerPrestige(nPlayerId)},
		{"状态", (tbState[nState] or "<color=green>在线<color>") .. "("..nState..")"},
	}
	local szMsg	= "";
	for _, tb in ipairs(tbText) do
		szMsg	= szMsg .. "\n  " .. Lib:StrFillL(tb[1], 6) .. tostring(tb[2]);
	end
	local szButtonColor	= (nState > 0 and "") or "<color=gray>";
	local tbOpt = {
		{szButtonColor.."拉他过来", "GM.tbGMRole:CallHimHere", nPlayerId},
		{szButtonColor.."送我过去", "GM.tbGMRole:SendMeThere", nPlayerId},
		{szButtonColor.."踢他下线", "GM.tbGMRole:KickHim", nPlayerId},
		{"关入天牢", "GM.tbGMRole:ArrestHim", nPlayerId},
		{"解除天牢", "GM.tbGMRole:FreeHim", nPlayerId},
		{"发送邮件", self.SendMail, self, nPlayerId},
		{"Kết thúc đối thoại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbGMCard:RecentPlayer()
	local tbOpt	= {};
	for nIndex, nPlayerId in ipairs(self.tbRecentPlayerList or {}) do
		local szName	= KGCPlayer.GetPlayerName(nPlayerId);
		local nState	= KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_ONLINESERVER);
		tbOpt[#tbOpt+1]	= {((nState > 0 and "<color=green>") or "")..szName, self.ViewPlayer, self, nPlayerId};
	end
	tbOpt[#tbOpt + 1]	= {"Kết thúc đối thoại"};
	
	Dialog:Say("请选择需要的玩家：", tbOpt);
end

function tbGMCard:AroundPlayer()
	local tbPlayer	= {};
	local _, nMyMapX, nMyMapY	= me.GetWorldPos();
	for _, pPlayer in ipairs(KPlayer.GetAroundPlayerList(me.nId, 50)) do
		if (pPlayer.szName ~= me.szName) then
			local _, nMapX, nMapY	= pPlayer.GetWorldPos();
			local nDistance	= (nMapX - nMyMapX) ^ 2 + (nMapY - nMyMapY) ^ 2;
			tbPlayer[#tbPlayer+1]	= {nDistance, pPlayer};
		end
	end
	local function fnLess(tb1, tb2)
		return tb1[1] < tb2[1];
	end
	table.sort(tbPlayer, fnLess);
	local tbOpt	= {};
	for _, tb in ipairs(tbPlayer) do
		local pPlayer	= tb[2];
		tbOpt[#tbOpt+1]	= {pPlayer.szName, self.ViewPlayer, self, pPlayer.nId};
		if (#tbOpt >= 8) then
			break;
		end
	end
	tbOpt[#tbOpt + 1]	= {"Kết thúc đối thoại"};
	
	Dialog:Say("请选择需要的玩家：", tbOpt);
end

function tbGMCard:AdjustLevel()
	local nMaxLevel	= GM.tbGMRole:GetMaxAdjustLevel();
	Dialog:AskNumber("期望等级(1~"..nMaxLevel..")", nMaxLevel, "GM.tbGMRole:AdjustLevel");
end

function tbGMCard:SendMail(nPlayerId)
	Dialog:AskString("邮件内容", 500, "GM.tbGMRole:SendMail", nPlayerId);
end

function tbGMCard:LookGlbBattle()
	if not GLOBAL_AGENT then
		local szMsg = "跨服竞技记者入口<pic=98><pic=98><pic=98>";
		local tbOpt = {
			{"进入英雄岛", self.EnterGlobalServer, self},
			{"跨服白虎堂", self.LookKuaFuBaiHu, self},
			{"先等等"}};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local szMsg = "跨服竞技记者入口<pic=98><pic=98><pic=98>";
	local tbOpt = {
			{"返回英雄岛", self.ReturnGlobalServer, self},
			{"返回临安府", self.ReturnMyServer, self},
			{"观看武林大会决赛", self.LookWldh, self},
			{"观看铁浮城战", self.LookXkland, self},
			{"跨服白虎堂", self.LookKuaFuBaiHu, self},
			{"先等等"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbGMCard:LookWldh()
	local szMsg = "跨服竞技记者入口<pic=98><pic=98><pic=98>";
	local tbOpt = {
			{"观看单人赛决赛", self.Wldh_SelectFaction, self},
			{"观看双人赛决赛", self.Wldh_SelectVsState, self, 2, 1},
			{"观看三人赛决赛", self.Wldh_SelectVsState, self, 3, 1},
			{"观看五人赛决赛", self.Wldh_SelectVsState, self, 4, 1},
			{"观看团体赛决赛", self.Wldh_SelectBattleVsState, self},
			{"先等等"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbGMCard:ReturnMyServer()
	me.GlobalTransfer(29, 1694, 4037);
end

function tbGMCard:Wldh_SelectBattleVsState()
	local szMsg = "";
	local tbOpt = {
		{"冠军团体赛场（金方）", self.Wldh_EnterBattleMap, self, 1, 1},
		{"冠军团体赛场（宋方）", self.Wldh_EnterBattleMap, self, 1, 2},
		{"四强团体赛场（金一）", self.Wldh_EnterBattleMap, self, 1, 1},
		{"四强团体赛场（宋一）", self.Wldh_EnterBattleMap, self, 1, 2},
		{"四强团体赛场（金二）", self.Wldh_EnterBattleMap, self, 2, 1},
		{"四强团体赛场（宋二）", self.Wldh_EnterBattleMap, self, 2, 2},
		{"Quay lại", self.LookWldh, self},
		{"Kết thúc đối thoại"},		
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbGMCard:Wldh_EnterBattleMap(nAreaId, nCamp)
	local tbMap = {
		[1] = 1631,
		[2] = 1632,
	};
	local tbPos = {
		[1] = {1767, 2977},
		[2] = {1547, 3512},
	};	
	local nMapId = tbMap[nAreaId];
	
	me.NewWorld(nMapId, unpack(tbPos[nCamp]));
end

function tbGMCard:Wldh_SelectFaction()
	local szMsg = "请选择你想要观战的门派？";
	local tbOpt = {};
	for i=1, 12  do
		table.insert(tbOpt, {Player:GetFactionRouteName(i).."决赛", self.Wldh_SelectVsState, self, 1, i});
	end

	table.insert(tbOpt, {"Quay lại", self.LookWldh, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);	
end

function tbGMCard:Wldh_SelectVsState(nType, nReadyId)
	local szMsg = "请选择你想要观战的赛事？";
	local tbOpt = {
		{"冠军赛场", self.Wldh_SelectPkMap, self, nType, nReadyId, 1},
		{"四强赛场", self.Wldh_SelectPkMap, self, nType, nReadyId, 2},
		{"八强赛场", self.Wldh_SelectPkMap, self, nType, nReadyId, 4},
		{"十六强赛场", self.Wldh_SelectPkMap, self, nType, nReadyId, 8},
		{"三十二强赛场", self.Wldh_SelectPkMap, self, nType, nReadyId, 16},
		{"Quay lại", self.LookWldh, self},
		{"Kết thúc đối thoại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbGMCard:Wldh_SelectPkMap(nType, nReadyId, nMapCount)
	local szMsg = "请选择你想要观战的赛场？";
	local tbOpt = {};
	for i=1, nMapCount do
		local szSelect = string.format("赛场（%s）", i);
		table.insert(tbOpt, {szSelect, self.Wldh_EnterPkMap, self, nType, nReadyId, i});
	end
	table.insert(tbOpt, {"Quay lại", self.LookWldh, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});	
	Dialog:Say(szMsg, tbOpt);	
end

function tbGMCard:Wldh_EnterPkMap(nType, nReadyId, nAearId)
	local nMapId = Wldh:GetMapMacthTable(nType)[nReadyId];
	local nPosX, nPosY = unpack(Wldh:GetMapPKPosTable(nType)[nAearId]);
	me.NewWorld(nMapId, nPosX, nPosY);
end

function tbGMCard:EnterGlobalServer()
	Transfer:NewWorld2GlobalMap(me);
end

function tbGMCard:ReturnGlobalServer()
	Transfer:NewWorld2GlobalMap(me);
end

function tbGMCard:LookXkland(nFrom)
	
	if Newland:GetWarState() == Newland.WAR_END then
		Dialog:Say("铁浮城争夺战尚未开始，请届时再来。<enter><color=gold>详情按F12-详细帮助-跨服城战查询<color>");
		return 0;
	end
	
	local tbOpt = {};
	local szMsg = "请选择要观战的帮会？";
	local nCount = 8;
	local nLast = nFrom or 1;
	for i = nLast, #Newland.tbGroupBuffer do
		table.insert(tbOpt, {Newland.tbGroupBuffer[i].szTongName, self.SelectLookTong, self, i});
		nCount = nCount - 1;
		nLast = nLast + 1;
		if nCount <= 0 then
			table.insert(tbOpt, {"Trang sau", self.LookXkland, self, nLast});
			break;
		end	
	end
	
	table.insert(tbOpt, {"Ta hiểu rồi"});
	Dialog:Say(szMsg, tbOpt);
end

function tbGMCard:SelectLookTong(nGroupIndex)
	local nMapId = Newland:GetLevelMapIdByIndex(nGroupIndex, 1);
	local tbTree = Newland:GetMapTreeByIndex(nGroupIndex);
	if nMapId and tbTree then
		local nMapX, nMapY = unpack(Newland.REVIVAL_LIST[tbTree[0]]);
		me.SetTask(Newland.TASK_GID, Newland.TASK_GROUP_INDEX, nGroupIndex);
		me.NewWorld(nMapId, nMapX, nMapY);
	end
end


-------------跨服白虎记者--------------------------
function tbGMCard:LookKuaFuBaiHu()
	local szMsg = "请选择要去的场地?"
	local tbOpt = {};
	tbOpt[1] = {"进入准备场",self.LookKuaFuBaiHuWaitMap,self};
	tbOpt[2] = {"进入战斗场",self.LookKuaFuBaiHuFightMap,self};
	tbOpt[3] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg,tbOpt);
end

function tbGMCard:LookKuaFuBaiHuWaitMap()
	local szMsg = "请选择要去几号准备场?"
	local tbOpt = {};
	local nIndex = 1;
	for nTbIndex,tbWaitMap in ipairs(KuaFuBaiHu.tbWaitMapIdList) do
		for nMapIndex,nMapId in ipairs(tbWaitMap) do
			local szInfo = string.format("%d号准备场",nIndex)
			table.insert(tbOpt,{szInfo,self.TransferBaiHuWaitMap,self,nTbIndex,nMapIndex});
			nIndex = nIndex + 1;
		end
	end
	tbOpt[#tbOpt + 1] = {"返回上一层",self.LookKuaFuBaiHu,self}
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"}
	Dialog:Say(szMsg,tbOpt);
end

function tbGMCard:LookKuaFuBaiHuFightMap()
	local szMsg = "请选择要去几号战斗场?"
	local tbOpt = {};
	local nIndex = 1;
	for nTbIndex,tbWaitMap in ipairs(KuaFuBaiHu.tbFightMapIdList) do
		for nMapIndex,nMapId in ipairs(tbWaitMap) do
			local szInfo = string.format("%d号战斗场",nIndex)
			table.insert(tbOpt,{szInfo,self.TransferBaiHuFightMap,self,nTbIndex,nMapIndex});
			nIndex = nIndex + 1;
		end
	end
	tbOpt[#tbOpt + 1] = {"返回上一层",self.LookKuaFuBaiHu,self}
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"}
	Dialog:Say(szMsg,tbOpt);
end

function tbGMCard:TransferBaiHuWaitMap(nTbIndex,nIndex)
	local nMapId = KuaFuBaiHu.tbWaitMapIdList[nTbIndex][nIndex];
	local tbPos = KuaFuBaiHu.tbWaitMapPos[MathRandom(#KuaFuBaiHu.tbWaitMapPos)];
	if not nMapId then
		return 0;
	end
	if GLOBAL_AGENT then	
		local nCanSure = Map:CheckTagServerPlayerCount(nMapId);
		if nCanSure < 0 then
			me.Msg("Đường phía trước bị chặn.","系统提示");
			return 0;
		end		
		me.NewWorld(nMapId, tbPos.nX/32, tbPos.nY/32);	
	else
		local nCanSure = Map:CheckGlobalPlayerCount(nMapId);
		if nCanSure < 0 then
			me.Msg("Đường phía trước bị chặn.","系统提示");
			return 0;
		end
		me.GlobalTransfer(nMapId, tbPos.nX / 32, tbPos.nY /32);			
	end
end

function tbGMCard:TransferBaiHuFightMap(nTbIndex,nIndex)
	local nMapId = KuaFuBaiHu.tbFightMapIdList[nTbIndex][nIndex];
	local tbPos = KuaFuBaiHu.tbEnterPos[MathRandom(#KuaFuBaiHu.tbEnterPos)];
	if not nMapId then
		return 0;
	end
	if GLOBAL_AGENT then
		local nCanSure = Map:CheckTagServerPlayerCount(nMapId);
		if nCanSure < 0 then
			me.Msg("Đường phía trước bị chặn.","系统提示");
			return 0;
		end		
		me.NewWorld(nMapId, tbPos.nX/32, tbPos.nY/32);	
	else
		local nCanSure = Map:CheckGlobalPlayerCount(nMapId);
		if nCanSure < 0 then
			me.Msg("Đường phía trước bị chặn.","系统提示");
			return 0;
		end
		me.GlobalTransfer(nMapId, tbPos.nX / 32, tbPos.nY /32);			
	end
end