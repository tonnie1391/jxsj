-------------------------------------------------------
-- 文件名　：newland_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-03 15:17:47
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

-------------------------------------------------------
-- 检测函数
-------------------------------------------------------

-- 判断帮会首领
function Newland:CheckTongCaptain(pPlayer)
	local pTong = KTong.GetTong(pPlayer.dwTongId);
	if not pTong then
		return 0;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if Tong:CheckPresidentRight(pPlayer.dwTongId, nKinId, nMemberId) ~= 1 then
		return 0;
	end
	return 1;
end

-- 处理届数
function Newland:RectifySession(pPlayer)
	local nSession = pPlayer.GetTask(self.TASK_GID, self.TASK_SESSION);
	if nSession ~= self:GetSession() then
		pPlayer.SetTask(self.TASK_GID, self.TASK_SESSION, self:GetSession());
		pPlayer.SetTask(self.TASK_GID, self.TASK_SIGNUP, 0);
	end
end

-- 获得玩家军团编号
function Newland:GetPlayerGroupIndex(pPlayer)
	return pPlayer.GetTask(self.TASK_GID, self.TASK_GROUP_INDEX);
end

-- 判断城主
function Newland:CheckCastleOwner(szPlayerName)
	return (self.tbCastleBuffer.szCaptainName == szPlayerName) and 1 or 0;
end

-- 判断是否可以占领王座
function Newland:CheckOccupyThrone(nGroupIndex)
	return (self.tbThrone.nOwnerGroup == 0) and 1 or 0; 
end

-- 获取军团总人数
function Newland:GetGroupMemberCount(nGroupIndex)
	return self.tbMemberCount[nGroupIndex] or 0;
end

-- 获取玩家总排名
function Newland:GetPlayerSort(szPlayerName)
	return self.tbSortPlayer2[szPlayerName] or 0;
end

-- 获取军团排名
function Newland:GetGroupSort(nGroupIndex)
	for nSort, tbInfo in ipairs(self.tbSortGroup) do
		if nGroupIndex == tbInfo.nGroupIndex then
			return nSort;
		end
	end
	return 0;
end

-- 获取地图等级
function Newland:GetMapLevel(nMapId)
	for nLevel, tbMapId in pairs(self.MAP_LIST) do
		for nIndex, nTmpMapId in pairs(tbMapId) do
			if nTmpMapId == nMapId then
				return nLevel;
			end
		end
	end
	return 0;
end

-- 获取分组地图
function Newland:GetLevelMapIdByIndex(nGroupIndex, nLevel)
	for nLevel2, tbGroup2 in pairs(self.tbGroupTree or self.tbBaseTree) do
		if type(tbGroup2) == "table" then
			for nLevel1, tbGroup1 in pairs(tbGroup2) do
				if type(tbGroup1) == "table" then
					for nIndex, nTmpGroupIndex in pairs(tbGroup1) do
						if nTmpGroupIndex == nGroupIndex then
							if nLevel == 1 then
								return tbGroup1[0];
							elseif nLevel == 2 then
								return tbGroup2[0];
							elseif nLevel == 3 then
								return self.THRONE_MAP_ID;
							end
							return 0;
						end
					end
				end
			end
		end
	end
	return 0;
end

-- 获取递进地图
function Newland:GetStepMapId(nMapId, nStepMap, nGroupIndex)
	local nLevel = self:GetMapLevel(nMapId) + nStepMap;
	return self:GetLevelMapIdByIndex(nGroupIndex, nLevel);
end

-- 获取分组树
function Newland:GetMapTreeByIndex(nGroupIndex)
	for nLevel2, tbGroup2 in pairs(self.tbGroupTree or self.tbBaseTree) do
		if type(tbGroup2) == "table" then
			for nLevel1, tbGroup1 in pairs(tbGroup2) do
				if type(tbGroup1) == "table" then
					for nIndex, nTmpGroupIndex in pairs(tbGroup1) do
						if nTmpGroupIndex == nGroupIndex then
							return {[0] = nIndex, [1] = nLevel1, [2] = nLevel2};
						end
					end
				end
			end
		end
	end
	return nil;
end

-- 获得玩家头衔
function Newland:GetPlayerRank(pPlayer)
	if not self.tbPlayerBuffer[pPlayer.szName] then
		return 0;
	end
	return self.tbPlayerBuffer[pPlayer.szName][6];
end

-- 获取占领龙柱数量
function Newland:GetMapPoleCount(nGroupIndex, nMapId)
	if not self.tbWarBuffer[nGroupIndex] then
		return 0;
	end
	local tbWarPole = self.tbWarBuffer[nGroupIndex].tbPole;
	if not tbWarPole[nMapId] then
		return 0;
	end
	return tbWarPole[nMapId];
end

-- 设置帮会名字
function Newland:SetTongName()
	local pTong = KTong.GetTong(me.dwTongId);
	if pTong then
		me.SetTaskStr(self.TASK_GID, self.TASK_TONGNAME, pTong.GetName());
	end
end

-------------------------------------------------------
-- 报名相关
-------------------------------------------------------

-- 帮会首领报名
function Newland:OnCaptainSignup_GS()

	-- 关闭界面
	me.CallClientScript({"UiManager:CloseWindow", "UI_TIEFUCHENGENROLL"});
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 报名阶段
	if self:GetPeriod() ~= self.PERIOD_SIGNUP then
		Dialog:Say("Xin lỗi, 现在不是跨服城战报名阶段。");
		return 0;
	end
	
	-- 密码锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("您的账号处于锁定状态，无法报名。");
		return 0;
	end
	
	-- 判断首领
	if self:CheckTongCaptain(me) ~= 1 then
		Dialog:Say("Xin lỗi, 您不是帮会首领，无法代表帮会报名。");
		return 0;
	end
	
	-- 个人是否报过名
	if me.GetTask(self.TASK_GID, self.TASK_SIGNUP) == 1 then
		Dialog:Say("Xin lỗi, ngươi đã đăng ký rồi.");
		return 0;
	end
	
	-- 帮会名字、网关
	local pTong = KTong.GetTong(me.dwTongId);
	local szTongName = pTong.GetName();
	local szGateway = Transfer:GetMyGateway(me);
	
	-- 帮会是否报过名
	local tbSignup = self.tbSignupBuffer[szTongName];
	if tbSignup then
		Dialog:Say("您所在的帮会已经报名参加跨服城战了。");
		return 0;
	end
	
	-- 达到帮会上限
	if self:GetSignupCount() >= self.MAX_GROUP then
		Dialog:Say("Xin lỗi, 报名成功的帮会数量已经达到上限。");
		return 0;
	end
	
	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, đẳng cấp còn quá thấp.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, ngươi chưa gia nhập môn phái.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 判断披风(雏凤)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < self.MANTLE_LEVEL then
		Dialog:Say(string.format("<color=yellow>Nguy hiểm, hãy trang bị phi phong thích hợp đã, ngươi vội quá rồi!<color><enter><color=green>Điều kiện tham gia:<enter>    1、Đạt cấp 100, đã gia nhập môn phái;<enter>    2、Phi phong thấp nhất là %s;<enter>    3、Thủ lĩnh đại diện khiêu chiến.<color>", Newland.MIN_MANTLE_LEVEL_NAME));
		return 0;
	end
	
	-- 完成报名
	me.SetTask(self.TASK_GID, self.TASK_SIGNUP, 1);
	GCExcute({"Newland:OnCaptainSignup_GC", me.szName, szGateway, szTongName, me.nSex});

	-- log
	Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, "首领报名参加跨服城战");
end

-- 帮会成员确认
function Newland:OnMemberSignup_GS(nIndex)

	-- 关闭界面
	me.CallClientScript({"UiManager:CloseWindow", "UI_TIEFUCHENGENROLL"});
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 报名阶段
	if self:GetPeriod() ~= self.PERIOD_SIGNUP then
		Dialog:Say("Xin lỗi, 现在不是跨服城战报名阶段。");
		return 0;
	end
	
	-- 密码锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("您的账号处于锁定状态，无法确认。");
		return 0;
	end
	
	-- 是否报过名
	if me.GetTask(self.TASK_GID, self.TASK_SIGNUP) == 1 then
		Dialog:Say("Xin lỗi, 您已经来确认过了。");
		return 0;
	end
	
	-- 判断帮会
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Xin lỗi, 您还没有加入帮会，无法确认参加跨服城战。");
		return 0;
	end
	
	-- 帮会名字、网关
	local szTongName = pTong.GetName();
	local szGateway = Transfer:GetMyGateway(me);
	
	-- 是否报名
	local tbSignup = self.tbSignupBuffer[szTongName];
	if not tbSignup then
		Dialog:Say("Xin lỗi, 您所在的帮会没有报名，无法确认参加跨服城战。");
		return 0;
	end
	
	-- 是否已经成功
	if tbSignup.nSuccess == 1 then
		Dialog:Say("您所在的帮会已经拥有参加本届城战的资格，无需再来确认了。");
		return 0;
	end
	
	-- 达到帮会上限
	if self:GetSignupCount() >= self.MAX_GROUP then
		Dialog:Say("Xin lỗi, 报名成功的帮会数量已经达到上限。");
		return 0;
	end
	
	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, đẳng cấp còn quá thấp.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, ngươi chưa gia nhập môn phái.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 判断披风(雏凤)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < self.MANTLE_LEVEL then
		Dialog:Say(string.format("<color=yellow>此去极其凶险，您没有足以保护自己的披风，怎能匆忙应战？<color><enter><color=green>参战条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有%s或以上的披风；<enter>    3、帮会首领代表全帮报名。<color>", Newland.MIN_MANTLE_LEVEL_NAME));
		return 0;
	end
	
	-- 完成报名
	me.SetTask(self.TASK_GID, self.TASK_SIGNUP, 1);
	GCExcute({"Newland:OnMemberSignup_GC", me.szName, szGateway, szTongName});
	
	local szMsg = "已在铁浮城远征大将处登记，请帮中其他兄弟姐妹也速速前往登记！";
	Player:SendMsgToKinOrTong(me, szMsg, 1);	
	
	-- log
	Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, "个人登记参加跨服城战");	
end

-- 帮会报名成功
function Newland:OnCaptainSignupEnd_GS(szCaptainName, szGateway, szTongName, nCaptainSex)
	
	-- 系统消息
	local szMsg = string.format("<color=green>[%s]<color>帮会申请参加跨服城战，请本帮豪杰前去登记！有志之士也可加入该帮商讨战事。", szTongName);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	KDialog.Msg2SubWorld(szMsg);
	
	local pPlayer = KPlayer.GetPlayerByName(szCaptainName);
	if not pPlayer then
		return 0;
	end
		
	-- 频道公告
	szMsg = string.format("本帮已申请参加本周六的跨服城战，请至少30位达到100级、已入门派、有%s及以上披风的帮会成员，在各大城市的铁浮城远征大将处登记！否则不能参战，截止时间：周六晚19:30。", Newland.MIN_MANTLE_LEVEL_NAME);
	pPlayer.SendMsgToKinOrTong(1, szMsg);
end

-- 帮会确认成功
function Newland:OnTongSignupSuccess_GS(szPlayerName, szGateway, szTongName)
	
	-- 系统消息
	local szMsg = string.format("%s<color=green>[%s]<color>帮会获得攻打铁浮城的资格！", ServerEvent:GetServerNameByGateway(szGateway), szTongName);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	KDialog.Msg2SubWorld(szMsg);
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
		
	-- 频道公告
	szMsg = string.format("本帮已获得攻打铁浮城的资格！请达到100级、已入门派、有%s及以上披风的帮会成员积极备战！", Newland.MIN_MANTLE_LEVEL_NAME);
	pPlayer.SendMsgToKinOrTong(1, szMsg);
end

-------------------------------------------------------
-- 战争相关
-------------------------------------------------------

-- 初始化游戏
function Newland:InitGame_GS()
	
	if self.tbMissionGame and self.tbMissionGame:IsOpen() ~= 0 then
		self.tbMissionGame:Close();
	end

	-- 生成三层分组树
	self.tbGroupTree = self:BuildTree(#self.tbGroupBuffer);
	
	-- 遍历地图id表
	for nLevel, tbMapId in pairs(self.MAP_LIST) do
		for _, nMapId in pairs(tbMapId) do
			
			-- 找到本服加载的地图
			if SubWorldID2Idx(nMapId) >= 0 then
				
				-- 创建mission类
				self.tbMissionGame = Lib:NewClass(self.Mission);
				self.tbMissionGame:InitGame(GetTime(), #self.tbGroupBuffer);
				break;
			end
		end
	end
	
	-- 战争状态
	self.nWarState = self.WAR_INIT;
	
	-- 初始化龙柱和王座
	self.tbPole = {};
	self.tbThrone = {nOwnerGroup = 0};
end

-- 开始游戏
function Newland:StartGame_GS()
	if self.tbMissionGame then
		self.tbMissionGame:StartGame(GetTime());
		self.tbMissionGame:BroadCastMission("Trận chiến bắt đầu! Hạ gục hết những ai cản đường ta.", self.BOTTOM_BLACK_MSG);
	end
	self.nWarState = self.WAR_START;
end

-- 结束游戏
function Newland:EndGame_GS(nWinGroup)
	
	if self.tbMissionGame then
			
		-- 频道公告
		local szGroupName = self:GetGroupNameByIndex(nWinGroup);
		local szCaptainName = self.tbGroupBuffer[nWinGroup].szCaptainName;
		local szMsg = string.format("<color=yellow>[%s]<color>-<color=green>[%s]<color> trở thành Thành Chủ mới!", szGroupName, szCaptainName);
		
		--向成为铁浮城主的玩家推送SNS通知
	    local pCaptain = KPlayer.GetPlayerByName(szCaptainName);
		if pCaptain then
			local szPopupMessage = "祝贺您成为新的<color=yellow>铁浮城城主<color>！\n把这个好消息分享给朋友们吧！";
			local szTweet = "#剑侠世界# 铁浮城跨服大战凯旋，我夺得铁浮城城主宝座啦！呵呵……";
			-- Sns:NotifyClientNewTweet(pCaptain, szPopupMessage, szTweet);
		end
	    
		self.tbMissionGame:BroadCastMission(szMsg, self.TOP_YELLOW_MSG);
		self.tbMissionGame:BroadCastMission(szMsg, self.BOTTOM_BLACK_MSG);
		self.tbMissionGame:BroadCastMission(szMsg, self.SYSTEM_CHANNEL_MSG);
		
		self.tbMissionGame:Close();	
		self.tbMissionGame = nil;
	end
	
	-- 清地图npc
	for nLevel, tbMapId in pairs(self.MAP_LIST) do
		for _, nMapId in pairs(tbMapId) do
			if SubWorldID2Idx(nMapId) >= 0 then		
				ClearMapNpc(nMapId);
			end
		end
	end
	
	-- 战争状态
	self.nWarState = self.WAR_END;
end

-- 显示玩家结果
function Newland:ShowPlayerResult(szPlayerName, nPoint, nSort, nBoxCount, nGroupSort, nGroupPoint)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		if nPoint >= self.PLAYER_POINT_LIMIT then
			pPlayer.Msg(string.format("Chúc mừng! nhận được <color=yellow>%s tích lũy<color>, xếp hạng <color=yellow>%s<color>, nhận được <color=yellow>%s điểm vinh dự Thiết Phù Thành<color> (Có thể mua rương Chiến Công tại Tướng Viễn Chinh Thiết Phù)", nPoint, nSort, nBoxCount));
		else
			pPlayer.Msg(string.format("Rất tiếc, bạn đạt được <color=yellow>%s tích lũy<color>, chưa đạt <color=yellow>500 tích lũy<color>, không đạt điểm vinh dự Thiết Phù Thành(Có thể mua rương Chiến Công tại Tướng Viễn Chinh Thiết Phù)", nPoint));
		end
	end
end

-------------------------------------------------------
-- 战场数据
-------------------------------------------------------

-- 增加个人积分
function Newland:AddPlayerPoint_GS(szPlayerName, nPoint)
	GCExcute({"Newland:AddPlayerPoint_GA", szPlayerName, nPoint});
end

-- 增加军团积分
function Newland:AddGroupPoint_GS(nGroupIndex, nPoint)
	GCExcute({"Newland:AddGroupPoint_GA", nGroupIndex, nPoint});	
end

-- gc同步战斗数据后
function Newland:TimerSyncDate_GS()
	
	if self.tbMissionGame then
		
		-- 更新头衔
		self.tbMissionGame:UpdatePlayerRank();
		
		-- 玩家排名
		self.tbSortPlayer = {};
		self.tbSortPlayer2 = {};
		self.tbMemberCount = {};
		
		for szPlayerName, tbInfo in pairs(self.tbPlayerBuffer) do
			table.insert(self.tbSortPlayer, {szPlayerName = szPlayerName, nPoint = tbInfo[2]});
			if not self.tbMemberCount[tbInfo[1]] then
				self.tbMemberCount[tbInfo[1]] = 0;
			end
			self.tbMemberCount[tbInfo[1]] = self.tbMemberCount[tbInfo[1]] + 1;
		end
		table.sort(self.tbSortPlayer, function(a, b) return a.nPoint > b.nPoint end);
		
		for nSort, tbInfo in ipairs(self.tbSortPlayer) do
			self.tbSortPlayer2[tbInfo.szPlayerName] = nSort;
		end
		
		-- 军团排名
		self.tbSortGroup = {};
		for nGroupIndex, tbInfo in pairs(self.tbWarBuffer) do
			table.insert(self.tbSortGroup, {nGroupIndex = nGroupIndex, szTongName = tbInfo.szTongName, nPoint = tbInfo.nPoint});
		end
		table.sort(self.tbSortGroup, function(a, b) return a.nPoint > b.nPoint end);
		
		-- 右侧信息
		self.tbMissionGame:UpdateAllRightUI();
		
		-- 同步战报
		self.tbMissionGame:TimerSyncReportData();
		
		-- 小地图
		self.tbMissionGame:UpdateMiniMap();
		
		-- Gm信息
		for nId in pairs(self.GMPlayerList or {}) do
			local pGmPlayer = KPlayer.GetPlayerObjById(nId);
			if pGmPlayer then
				self:OnUpdateMiniMap(pGmPlayer);
			end
		end
		
		-- add show friend
		for i = 1, #self.tbGroupBuffer do
			for nLevel, tbMapId in pairs(Newland.MAP_LIST) do
				for _, nMapId in pairs(tbMapId) do
					if SubWorldID2Idx(nMapId) >= 0 then
						SetMapHighLightPointEx(nMapId, 5, 12, 6000, 0, 1, i);
					end
				end 
			end
		end
	end
end

-- 刷新积分
function Newland:TimerUpdatePoint()
	
	if self.nWarState ~= self.WAR_START then
		return 0;
	end
	
	for nNpcDwId, tbInfo in pairs(self.tbPole) do
		
		-- 增加护卫积分
		local tbPlayerList = KNpc.GetAroundPlayerList(nNpcDwId, Newland.PROTECT_DISTANCE);
		for _, pPlayer in pairs(tbPlayerList or {}) do
			local nGroupIndex = self:GetPlayerGroupIndex(pPlayer);
			if nGroupIndex == tbInfo.nOwnerGroup then
				self:AddPlayerPoint_GS(pPlayer.szName, self.PROTECT_POINT);
				GCExcute({"Newland:OnProtectPole_GA", pPlayer.szName}); 
				pPlayer.Msg(string.format("Bảo vệ Long Trụ, nhận được <color=yellow>%s điểm<color> tích lũy cá nhân!", self.PROTECT_POINT));
			end
		end
		
		-- 增加军团积分
		if tbInfo.nOwnerGroup > 0 then
			local nPoint = math.floor(self.BASE_POLE_POINT * self.MAP_LEVEL_WEIGHT[tbInfo.nMapLevel]);
			self:AddGroupPoint_GS(tbInfo.nOwnerGroup, nPoint);
		end
	end
	
	-- 王座积分单独处理
	self:AddThronePoint();
end

-- 添加积分龙柱
function Newland:AddNewPole(nNpcId, nMapId, nMapX, nMapY, nOwnerGroup)
	local pNpc = KNpc.Add2(nNpcId, 120, -1, nMapId, nMapX, nMapY);
	if pNpc then
		if not self.tbPole[pNpc.dwId] then
			self.tbPole[pNpc.dwId] = {};
		end
		self.tbPole[pNpc.dwId].nMapId = nMapId;
		self.tbPole[pNpc.dwId].nMapX = nMapX;
		self.tbPole[pNpc.dwId].nMapY = nMapY;
		self.tbPole[pNpc.dwId].nOwnerGroup = nOwnerGroup or 0;
		self.tbPole[pNpc.dwId].nMapLevel = self:GetMapLevel(nMapId); 
		
		if nOwnerGroup and nOwnerGroup > 0 then
			pNpc.SetVirtualRelation(Player.emKPK_STATE_EXTENSION, nOwnerGroup);
			pNpc.szName = string.format("%s帮会的龙柱", self:GetGroupNameByIndex(nOwnerGroup));
		end
	end
	return 0;
end

-- 玩家占领龙柱
function Newland:OnOccupyPole(pPlayer, nNpcDwId)
	
	local nGroupIndex = 0;
	local szPlayerName = "";
	
	-- 若存在玩家则加分
	if pPlayer then
		szPlayerName = pPlayer.szName;
		nGroupIndex = self:GetPlayerGroupIndex(pPlayer);
		self:AddPlayerPoint_GS(szPlayerName, self.OCCUPY_POLE_POINT);
		pPlayer.Msg(string.format("Tấn công Long Trụ, nhận được <color=yellow>%s điểm<color> tích lũy cá nhân!", self.OCCUPY_POLE_POINT));
	end
	
	local nMapId = self.tbPole[nNpcDwId].nMapId;
	local nMapX = self.tbPole[nNpcDwId].nMapX;
	local nMapY = self.tbPole[nNpcDwId].nMapY;
	local nOwnerGroup = self.tbPole[nNpcDwId].nOwnerGroup;
	
	-- 重置所有权
	GCExcute({"Newland:OnOccupyPole_GA", szPlayerName, nGroupIndex, nOwnerGroup, nMapId}); 
	
	-- 增加新的资源点
	Timer:Register(Env.GAME_FPS, self.AddNewPole, self, Newland.POLE_ID, nMapId, nMapX, nMapY, nGroupIndex);
	
	-- 删除原来的
	self.tbPole[nNpcDwId] = nil;
end

-- 杀人处理
function Newland:OnKillPlayer(pKiller, pDied)
	
	-- 计算积分
	local nDiedRank = Newland:GetPlayerRank(pDied);
	local nKillerRank = Newland:GetPlayerRank(pKiller);
	local nPoint = math.floor((10 - (nKillerRank - nDiedRank)) / 10 * self.KILL_PLAYER_POINT);
	
	-- 增加积分
	self:AddPlayerPoint_GS(pKiller.szName, nPoint);
	
	-- 处理杀人数
	local nSeriesKill = pKiller.GetTask(self.TASK_GID, self.TASK_SERIES_KILL);
	GCExcute({"Newland:AddPlayerKill_GA", pKiller.szName, nSeriesKill})
	
	if nSeriesKill ~= 1 then
		pKiller.SetTask(self.TASK_GID, self.TASK_SERIES_KILL, 1);
	end
	
	pDied.SetTask(self.TASK_GID, self.TASK_SERIES_KILL, 0);
	pKiller.Msg(string.format("Hạ địch! Nhận được <color=yellow>%s điểm<color> tích lũy cá nhân!", nPoint));
end
	
-- 占领王座回调
function Newland:OnOccupyThrone(szPlayerName, nGroupIndex, nNpcDwId)
	self.tbThrone.nOwnerGroup = nGroupIndex;
	self.tbThrone.szPlayerName = szPlayerName;
	self.tbThrone.nOccupyTime = GetTime();
	self.tbThrone.nNpcDwId = nNpcDwId;
end

-- 失去王座回调
function Newland:OnLoseThrone(szPlayerName, nGroupIndex)
	
	local szGroupName = self:GetGroupNameByIndex(nGroupIndex);
	local szPlayerName = self.tbThrone.szPlayerName;
	local szMsg = string.format("<color=yellow>[%s]<color>-<color=green>[%s]<color> đã rời ngai vàng!", szGroupName, szPlayerName or "Không rõ");
	
	self:BroadCast_GS(szMsg, self.MIDDLE_RED_MSG);
	self:BroadCast_GS(szMsg, self.SYSTEM_CHANNEL_MSG);
	
	self.tbThrone.nOwnerGroup = 0;
	self.tbThrone.szPlayerName = nil;
	self.tbThrone.nOccupyTime = nil;
end

-- 王座积分特殊处理
function Newland:AddThronePoint()
	
	if SubWorldID2Idx(self.THRONE_MAP_ID) < 0 then
		return 0;
	end
	
	-- 增加军团积分
	if self.tbThrone.nOwnerGroup > 0 then
		self:AddGroupPoint_GS(self.tbThrone.nOwnerGroup, self.BASE_THRONE_POINT);
	end
	
	-- 增加个人积分
	local szPlayerName = self.tbThrone.szPlayerName;
	if szPlayerName then
		local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
		if pPlayer then
			self:AddPlayerPoint_GS(szPlayerName, self.PLAYER_THRONE_POINT);
			GCExcute({"Newland:OnOccupyThrone_GA", szPlayerName});
			pPlayer.Msg(string.format("Ngồi lên ngai vàng, nhận được <color=yellow>%s điểm<color> tích lũy cá nhân!", self.PLAYER_THRONE_POINT));
			
			-- 增加护卫积分
			local tbPlayerList = KPlayer.GetAroundPlayerList(pPlayer.nId, Newland.PROTECT_DISTANCE);
			for _, pTmpPlayer in pairs(tbPlayerList) do
				local nGroupIndex = self:GetPlayerGroupIndex(pTmpPlayer);
				if nGroupIndex == self.tbThrone.nOwnerGroup and pTmpPlayer.szName ~= szPlayerName then
					self:AddPlayerPoint_GS(pTmpPlayer.szName, self.PROTECT_POINT);
					GCExcute({"Newland:OnProtectPole_GA", pTmpPlayer.szName});
					pTmpPlayer.Msg(string.format("Hộ vệ ngai vàng, nhận được <color=yellow>%s điểm<color> tích lũy cá nhân!", self.PROTECT_POINT));
				end
			end
		end
	end
end

-------------------------------------------------------
-- 奖励相关
-------------------------------------------------------

-- 判断城主奖励
function Newland:CheckCastleAward(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_WAR_REST then
		Dialog:Say("Xin lỗi, không thể nhận thưởng lúc này!");
		return 0;
	end
	
	if self:CheckCastleOwner(pPlayer.szName) ~= 1 then
		Dialog:Say("Xin lỗi, ngươi không phải Thành chủ.");
		return 0;
	end
	
	if self.tbCastleBuffer.nAward ~= 1 then
		Dialog:Say("Xin lỗi, người không có phần thưởng thành chủ.");
		return 0;
	end
	
	local nNeed = 5;
	if pPlayer.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nNeed));
		return 0;
	end
	
	return 1;
end

-- gs申请领取城主奖励
function Newland:GetCastleAward_GS(szPlayerName)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	if self:CheckCastleAward(pPlayer) ~= 1 then
		return 0;
	end
	
	-- 锁住玩家
	pPlayer.AddWaitGetItemNum(1);
	GCExcute({"Newland:GetCastleAward_GC", szPlayerName});
end

-- gs城主领奖成功
function Newland:GetCastleAwardSuccess_GS(szPlayerName)

	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	-- 解锁玩家
	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.AddStackItem(self.CASTLE_BOX_ID[1], self.CASTLE_BOX_ID[2], self.CASTLE_BOX_ID[3], self.CASTLE_BOX_ID[4], nil, self.CASTLE_BOX);
	pPlayer.AddStackItem(self.CASTLE_PAD_ID[1], self.CASTLE_PAD_ID[2], self.CASTLE_PAD_ID[3], self.CASTLE_PAD_ID[4], nil, self.CASTLE_PAD);
	pPlayer.AddStackItem(self.NORMAL_PAD_ID[1], self.NORMAL_PAD_ID[2], self.NORMAL_PAD_ID[3], self.NORMAL_PAD_ID[4], nil, self.NORMAL_PAD);
	
	Dbg:WriteLog("Newland", "跨服城战", pPlayer.szAccount, pPlayer.szName, string.format("领取辉煌战功箱：%s个，城主令牌：%s个，侍卫令牌：%s个", self.CASTLE_BOX, self.CASTLE_PAD, self.NORMAL_PAD));
end

-- gs城主领奖失败
function Newland:GetCastleAwardFailed_GS(szPlayerName)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.Msg("Xin lỗi, ngươi đã nhận hết phần thưởng!");
end

-- 判断额外购买箱子
function Newland:CheckSellBox(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_WAR_REST then
		Dialog:Say("Xin lỗi, không thể nhận thưởng lúc này.");
		return 0;
	end
	
	if self:CheckCastleOwner(pPlayer.szName) ~= 1 then
		Dialog:Say("Xin lỗi, ngươi không phải là Thành chủ.");
		return 0;
	end
	
	if self.tbCastleBuffer.nSellBox <= 0 then
		Dialog:Say("Xin lỗi, ngươi không có rương để mua.");
		return 0;
	end
	
	local nNeed = 1;
	if pPlayer.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nNeed));
		return 0;
	end
	
	return self.tbCastleBuffer.nSellBox;
end

-- gs申请领购买城主宝箱
function Newland:BuyCastleBox_GS(nCount, nSure)
	
	local nSellBox = self:CheckSellBox(me);
	if nSellBox <= 0 or nCount <= 0 or nSellBox < nCount then
		return 0;
	end
	
	local nCostMoney = nCount * self.CASTLE_BOX_PRICE;
	if not nSure then
		local szMsg = string.format("Có thể mua <color=yellow>%s Rương Chiến Công Huy Hoàng<color>, tổng phí là <color=yellow>%s bạc khóa liên server<color>. Ngươi chắc chứ?", nCount, Item:FormatMoney(nCostMoney));
		local tbOpt =
		{
			{"Xác nhận", self.BuyCastleBox_GS, self, nCount, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	-- 叠加物品背包空间
	local nNeed = KItem.GetNeedFreeBag(self.CASTLE_BOX_ID[1], self.CASTLE_BOX_ID[2], self.CASTLE_BOX_ID[3], self.CASTLE_BOX_ID[4], nil, nCount);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nNeed));
		return 0;
	end
	
	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney < nCostMoney then
		Dialog:Say("<color=yellow>Xin lỗi, không đủ bạc khóa liên server để đổi thưởng<color><enter><enter><color=green>Ấn Ctrl+G để mở Kỳ Trân Các, mua bạc khóa liên server tại khu Hỗ trợ, có thể tăng lượng bạc khóa liên server!<color>");
		return 0;
	end
	
	-- 锁住玩家
	me.AddWaitGetItemNum(1);
	GCExcute({"Newland:BuyCastleBox_GC", me.szName, nCount});
end

-- gs购买成功
function Newland:BuyCastleBoxSuccess_GS(szPlayerName, nCount)

	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	-- 解锁玩家
	pPlayer.AddWaitGetItemNum(-1);
	
	-- 扣除跨服绑银
	local nCostMoney = nCount * self.CASTLE_BOX_PRICE;	
	pPlayer.CostGlbBindMoney(nCostMoney);	
	pPlayer.AddStackItem(self.CASTLE_BOX_ID[1], self.CASTLE_BOX_ID[2], self.CASTLE_BOX_ID[3], self.CASTLE_BOX_ID[4], nil, nCount);

	Dbg:WriteLog("Newland", "跨服城战", pPlayer.szAccount, pPlayer.szName, string.format("购买辉煌战功箱：%s个", nCount));
	StatLog:WriteStatLog("stat_info", "newland", "buy_castle", pPlayer.nId, nCount);
end

-- gs购买失败
function Newland:BuyCastleBoxFailed_GS(szPlayerName, nCount)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.Msg("Xin lỗi, không có rương để mua.");
end

-- 判断个人奖励
function Newland:CheckSingleAward(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_WAR_REST then
		Dialog:Say("Xin lỗi, không thể nhận lúc này.");
		return 0;
	end
	
	local nTotalBox = GetPlayerSportTask(me.nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX) or 0;
	local nGetBox = me.GetTask(self.TASK_GID, self.TASK_WAR_BOX);
	local nPoint = nTotalBox - nGetBox * 100;
	local nLeftBox = math.floor(nPoint / 100);
	if nLeftBox <= 0 then
		Dialog:Say(string.format("Tích lũy của ngươi là: <color=yellow>%s<color>, không thể mua bảo rương.", nPoint));
		return 0;
	end
	
	return nLeftBox, nPoint;
end

-- gs领取个人奖励
function Newland:GetSingleAward_GS(nCount, nSure)
		
	local nSingleBox = self:CheckSingleAward(me);
	if nSingleBox <= 0 or nCount <= 0 or nSingleBox < nCount then
		return 0;
	end
	
	local nCostMoney = nCount * self.NORMAL_BOX_PRICE;
	if not nSure then
		local szMsg = string.format("Có thể mua <color=yellow>%s Rương Chiến Công Trác Việt<color>, tổng phí là <color=yellow>%s bạc khóa liên server<color>. Ngươi chắc chứ?", nCount, Item:FormatMoney(nCostMoney));
		local tbOpt =
		{
			{"Xác nhận", self.GetSingleAward_GS, self, nCount, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	-- 叠加物品背包空间
	local nNeed = KItem.GetNeedFreeBag(self.NORMAL_BOX_ID[1], self.NORMAL_BOX_ID[2], self.NORMAL_BOX_ID[3], self.NORMAL_BOX_ID[4], {bForceBind = 1}, nCount);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nNeed));
		return 0;
	end
	
	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney < nCostMoney then
		Dialog:Say("<color=yellow>Xin lỗi, không đủ bạc khóa liên server để đổi thưởng<color><enter><enter><color=green>Ấn Ctrl+G để mở Kỳ Trân Các, mua bạc khóa liên server tại khu Hỗ trợ, có thể tăng lượng bạc khóa liên server!<color>");
		return 0;
	end
	
	me.CostGlbBindMoney(nCostMoney);	
	me.AddStackItem(self.NORMAL_BOX_ID[1], self.NORMAL_BOX_ID[2], self.NORMAL_BOX_ID[3], self.NORMAL_BOX_ID[4], {bForceBind = 1}, nCount);
	me.SetTask(self.TASK_GID, self.TASK_WAR_BOX, me.GetTask(self.TASK_GID, self.TASK_WAR_BOX) + nCount);
	
	Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("购买卓越战功箱：%s", nCount));
	StatLog:WriteStatLog("stat_info", "newland", "buy", me.nId, nCount);
end

-- 判断经验威望
function Newland:CheckExtraAward(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_WAR_REST then
		Dialog:Say("Xin lỗi, bây giờ không thể nhận thưởng!");
		return 0;
	end
	
	local nTotalTimes = GetPlayerSportTask(me.nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP) or 0;
	local nGetTimes = me.GetTask(self.TASK_GID, self.TASK_WAR_EXP);
	local nLeftTimes = nTotalTimes - nGetTimes;
	if nLeftTimes <= 0 then
		Dialog:Say("Xin lỗi, ngươi không có gì để nhận.");
		return 0;
	end

	return nLeftTimes;
end

-- gs领取个人奖励
function Newland:GetExtraAward_GS()
		
	local nTimes = self:CheckExtraAward(me); 
	if nTimes <= 0 then
		return 0;
	end
	
	me.AddExp(self.PLAYER_WAR_EXP * nTimes);
	me.AddKinReputeEntry(self.PLAYER_WAR_REPUTE * nTimes);
	me.SetTask(self.TASK_GID, self.TASK_WAR_EXP, me.GetTask(self.TASK_GID, self.TASK_WAR_EXP) + nTimes);
	
	SpecialEvent.ActiveGift:AddCounts(me, 36);		--领取跨服城战奖励完成活跃度
	
	Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("领取经验：%s，威望：%s", self.PLAYER_WAR_EXP * nTimes, self.PLAYER_WAR_REPUTE * nTimes));
end

-------------------------------------------------------
-- 系统相关
-------------------------------------------------------

-- gm enter
function Newland:GM_EnterMap()
	self.GMPlayerList = self.GMPlayerList or {};
	if me.GetCamp() == 6 then
		self.GMPlayerList[me.nId] = 1;
		return 1;
	end
	return 0;
end

-- gm leave
function Newland:GM_LeaveMap()
	self.GMPlayerList = self.GMPlayerList or {};
	if me.GetCamp() == 6 then
		self.GMPlayerList[me.nId] = nil;
		return 1;
	end
	return 0;
end

-- 同步地图人数
function Newland:SyncMapPlayerCount_GS(tbInfo)
	self.tbMapPlayerCount = tbInfo;
end

-- 增加地图人数
function Newland:AddMapPlayerCount_GS(nMapId, nCount)
	GCExcute({"Newland:AddMapPlayerCount_GA", nMapId, nCount});
end

-- 获取地图人数
function Newland:GetMapPlayerCount(nMapId)
	return self.tbMapPlayerCount[nMapId] or 0;
end

-- 广播系统
function Newland:BroadCast_GS(szMsg, nType)
	if nType == self.TOP_YELLOW_MSG then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	else
		GCExcute({"Newland:BroadCast_GA", szMsg, nType});
	end
end

-- 广播回调
function Newland:OnBroadCast_GS(szMsg, nType)
	if self.tbMissionGame then
		self.tbMissionGame:BroadCastMission(szMsg, nType);
	end
	for nId in pairs(self.GMPlayerList or {}) do
		local pGmPlayer = KPlayer.GetPlayerObjById(nId);
		if pGmPlayer then
			self:BroadCastPlayer(pGmPlayer, szMsg, nType);
		end
	end
end

-- 广播给单个player
function Newland:BroadCastPlayer(pPlayer, szMsg, nType)
	if nType == Newland.SYSTEM_CHANNEL_MSG then
		pPlayer.Msg(szMsg);
	elseif nType == Newland.BOTTOM_BLACK_MSG then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	elseif nType == Newland.MIDDLE_RED_MSG then
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
end

-- 自定义头衔
function Newland:AddPlayerTitle(pPlayer, nGroupIndex)
	if not pPlayer then
		return 0;
	end
	local nLevel = 1;
	if self.tbPlayerBuffer[pPlayer.szName] then
		nLevel = math.max(self.tbPlayerBuffer[pPlayer.szName][6], 1);
	end
	if nLevel > #self.RANK_POINT then
		nLevel = #self.RANK_POINT;
	end
	local szTitle = string.format("%s-%s", self:GetGroupNameByIndex(nGroupIndex), self.RANK_POINT[nLevel][2]);
	pPlayer.AddSpeTitle(szTitle, GetTime() + 60 * 60 * 24, self.RANK_POINT[nLevel][3]);
end

-- 删除自定义称号
function Newland:RemovePlayerTitle(pPlayer, nGroupIndex)
	if not pPlayer then
		return 0;
	end
	for i = 1, #self.RANK_POINT do	
		local szTitle = string.format("%s-%s", self:GetGroupNameByIndex(nGroupIndex), self.RANK_POINT[i][2]);
		pPlayer.RemoveSpeTitle(szTitle);			
	end
end

-- 更新龙柱坐标
function Newland:OnUpdateMiniMap(pPlayer)
	local nGroupIndex = self:GetPlayerGroupIndex(pPlayer);
	for nNpcDwId, tbInfo in pairs(self.tbPole) do
		if pPlayer.nMapId == tbInfo.nMapId then
			local pNpc = KNpc.GetById(nNpcDwId);
			if pNpc and tbInfo.nOwnerGroup > 0 then
				local _, nMapX, nMapY = pNpc.GetWorldPos();
				local nPic = (nGroupIndex == tbInfo.nOwnerGroup) and self.SELF_POLE_PIC or self.ENEMY_POLE_PIC;
				local szName = string.format("%s", self:GetGroupNameByIndex(tbInfo.nOwnerGroup));
				pPlayer.SetHighLightPoint(nMapX, nMapY, nPic, nNpcDwId, szName, 6000);
			end
		end
	end
	if pPlayer.nMapId == self.THRONE_MAP_ID then
		if self.tbThrone.nNpcDwId and self.tbThrone.nOwnerGroup > 0 then
			local pNpc = KNpc.GetById(self.tbThrone.nNpcDwId);
			if pNpc then
				local _, nMapX, nMapY = pNpc.GetWorldPos();
				local nPic = (nGroupIndex == nOwnerGroup) and self.SELF_POLE_PIC or self.ENEMY_POLE_PIC;
				local szName = string.format("%s", self:GetGroupNameByIndex(self.tbThrone.nOwnerGroup));
				pPlayer.SetHighLightPoint(nMapX, nMapY, nPic, self.tbThrone.nNpcDwId, szName, 6000);
			end
		end
	end
end

-- 清除龙柱坐标
function Newland:ClearMiniMap(pPlayer)
	local nGroupIndex = self:GetPlayerGroupIndex(pPlayer);
	for nNpcDwId, tbInfo in pairs(self.tbPole) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, 0, nNpcDwId, "", 0);
		end
	end
	if self.tbThrone.nNpcDwId then
		local pNpc = KNpc.GetById(self.tbThrone.nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, 0, self.tbThrone.nNpcDwId, "", 0);
		end
	end
end

-- 更新城主雕像
function Newland:UpdateCastleStatue_GS(szPlayerName, nPlayerSex, nCenter)

	local tbMapId = self.STATUE_POS[nCenter].tbMapId;
	local tbPos = self.STATUE_POS[nCenter].tbPos;
	if not tbMapId or not tbPos then
		return 0;
	end
	
	local nNpcId = self.STATUE_ID[nPlayerSex or 0];
	if not nNpcId then
		return 0;
	end

	for _, nMapId in pairs(tbMapId) do
		if SubWorldID2Idx(nMapId) >= 0 then
			if self.tbCastleNpcId[nMapId] then
				local pCastleNpc = KNpc.GetById(self.tbCastleNpcId[nMapId]);
				if pCastleNpc then
					pCastleNpc.Delete();
				end
			end
			local pNpc = KNpc.Add2(nNpcId, 120, -1, nMapId, tbPos[1], tbPos[2]);
			if pNpc then
				pNpc.szName = string.format("Tượng của %s", szPlayerName);
				self.tbCastleNpcId[nMapId] = pNpc.dwId;
			end
		end
	end
end

-- balance
function Newland:AddBalance(pPlayer)
	pPlayer.SetTask(self.TASK_GID, self.TASK_BASE_LEVEL, pPlayer.nLevel);
	if pPlayer.nLevel < self.OVE_LEVEL then
		pPlayer.RemoveSkillState(self.BAL_SKILL_ID);
		pPlayer.AddSkillState(self.BAL_SKILL_ID, 1, 1, 2 * 60 * 60 * Env.GAME_FPS, 1, 1);
	end
	if pPlayer.nLevel < self.AVE_LEVEL then
		pPlayer.AddLevel(self.AVE_LEVEL - pPlayer.nLevel);
	end
	-- 允许投点110技能
	pPlayer.SetTask(1022, 215, 4095);
	-- 阵法
	local tbZhen = {[1] = {18, 1, 320, 1}, [3] = {18, 1, 320, 3}};
	local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHEN);
	if pItem and tbZhen[pItem.nLevel] then
		pPlayer.AddItem(unpack(tbZhen[pItem.nLevel]));
	end
end

function Newland:RemoveBalance(pPlayer)
	local nBaseLevel = pPlayer.GetTask(self.TASK_GID, self.TASK_BASE_LEVEL);
	pPlayer.RemoveSkillState(self.BAL_SKILL_ID);
	pPlayer.AddLevel(nBaseLevel - pPlayer.nLevel);
end

-------------------------------------------------------
-- c2s call
-------------------------------------------------------

-- 帮会首领报名
function c2s:ApplyCaptainSignup()
	Newland:RectifySession(me);
	Newland:OnCaptainSignup_GS();
end

-- 帮会成员确认
function c2s:ApplyMemberSignup(nIndex)
	Newland:RectifySession(me);
	Newland:OnMemberSignup_GS(nIndex);
end

-------------------------------------------------------
-- buffer相关
-------------------------------------------------------

-- 载入本地global buffer
function Newland:LoadBuffer_GS(nBufferIndex)
	
	local szBuffer = self.GBLBUFFER_LIST[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	local tbLoadBuffer = GetGblIntBuf(nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self[szBuffer] = tbLoadBuffer;
	end
end

-- 置空本地global buffer
function Newland:ClearBuffer_GS(nBufferIndex)

	local szBuffer = self.GBLBUFFER_LIST[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	self[szBuffer] = {};
end

-------------------------------------------------------
-- 启动相关
-------------------------------------------------------

-- gs启动事件
function Newland:StartEvent_GS()
	
	-- load buffer
	for nBufferIndex, _ in pairs(self.GBLBUFFER_LIST) do
		self:LoadBuffer_GS(nBufferIndex);
	end
	
	-- update statue
	if self.tbCastleBuffer.szCaptainName then
		self:UpdateCastleStatue_GS(self.tbCastleBuffer.szCaptainName, self.tbCastleBuffer.nCaptainSex, self:CheckIsGlobal());
	end
	
	-- test tree
	self.tbBaseTree = self:BuildTree(self.MAX_GROUP);
end

-- 注册启动事件
ServerEvent:RegisterServerStartFunc(Newland.StartEvent_GS, Newland);

-- 注册同步数据
Transfer:RegisterSyncData(Newland.SetTongName, Newland);

-------------------------------------------------------
-- 测试指令
-------------------------------------------------------
function Newland:_ShowPlayerLocalTask()
	me.Msg("Tên Bang hội: " .. me.GetTaskStr(self.TASK_GID, self.TASK_TONGNAME));
	me.Msg("Số lần tham gia: " .. me.GetTask(self.TASK_GID, self.TASK_SESSION));
	me.Msg("Đăng ký: " .. me.GetTask(self.TASK_GID, self.TASK_SIGNUP));
	me.Msg("Bảo rương: " .. me.GetTask(self.TASK_GID, self.TASK_WAR_BOX));
	me.Msg("Kinh nghiệm: " .. me.GetTask(self.TASK_GID, self.TASK_WAR_EXP));
end

-- 计时器清除npc
function Newland:OnTimerDelNpc(nNpcDwId)
	local pNpc = KNpc.GetById(nNpcDwId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
	return 0;
end

function Newland:OnCallAtom(pNpc, nGroupIndex, nMapId, pPlayer)
	
	Timer:Register(30 * Env.GAME_FPS, self.OnTimerDelNpc, self, pNpc.dwId);
	
	if not self.tbAtom[nMapId] then
		self.tbAtom[nMapId] = {};
	end
	if not self.tbAtom[nMapId][nGroupIndex] then
		self.tbAtom[nMapId][nGroupIndex] = {};
	end
	local nOldDwId = self.tbAtom[nMapId][nGroupIndex][pNpc.nTemplateId];
	if nOldDwId then
		local pOldNpc = KNpc.GetById(nOldDwId);
		if pOldNpc then
			pOldNpc.Delete();
		end
	end
	self.tbAtom[nMapId][nGroupIndex][pNpc.nTemplateId] = pNpc.dwId;

	local szGroupName = self:GetGroupNameByIndex(nGroupIndex);
	local szMsg = string.format("<color=yellow>[%s]<color>-<color=green>[%s]<color> sử dụng %s!", szGroupName, pPlayer.szName, pNpc.szName);
	self:BroadCast_GS(szMsg, self.SYSTEM_CHANNEL_MSG);
end

function Newland:OnPlayerLogin()
	if self:CheckCastleOwner(me.szName) == 1 and GetTime() - me.GetTask(self.TASK_GID, self.TASK_INTERVAL) > 3600 * Env.GAME_FPS then
		local szMsg = string.format("Thiết Phù Thành Chủ <color=yellow>[%s]<color> đã đăng nhập.", me.szName);
		Dialog:GlobalMsg2SubWorld(szMsg);
		me.SetTask(self.TASK_GID, self.TASK_INTERVAL, GetTime());
	end
end

-- 注册登陆事件
if Newland.nEventLoginId then
	PlayerEvent:UnRegisterGlobal("OnLogin", Newland.nEventLoginId)	
end
Newland.nEventLoginId = PlayerEvent:RegisterGlobal("OnLogin", Newland.OnPlayerLogin, Newland);
