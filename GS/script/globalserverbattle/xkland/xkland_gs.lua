-------------------------------------------------------
-- 文件名　：xkland_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-04-08 15:27:18
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

-------------------------------------------------------
-- 战争状态
-------------------------------------------------------

-- 初始化游戏
function Xkland:InitGame_GS()
	
	if self.tbMissionGame and self.tbMissionGame:IsOpen() ~= 0 then
		self.tbMissionGame:Close();
	end
	
	-- 清空几个表
	self.tbResource = {};
	self.tbBoat = {};
	self.tbRevival = {};
	
	if self:GetSession() == 1 then
		self.tbThrone = {nPreGroup = 0, nOwnerGroup = 0, szPlayerName = "", nModify = 0, nMinute = 0};
	else
		self.tbThrone = {nPreGroup = 1, nOwnerGroup = 1, szPlayerName = "", nModify = 0, nMinute = 0};
	end

	-- 遍历地图id表
	for nIndex, nMapId in pairs(self.MAP_LIST) do
		
		-- 找到本服加载的地图
		if SubWorldID2Idx(nMapId) >= 0 then
			
			-- 创建mission类
			self.tbMissionGame = Lib:NewClass(self.Mission);
			self.tbMissionGame:InitGame(GetTime());
			break;
		end
	end
	
	-- 战争状态
	self.nWarState = 1;
end

-- 开始游戏
function Xkland:StartGame_GS()
	if self.tbMissionGame then
		self.tbMissionGame:StartGame(GetTime());
	end
	self.nWarState = 2;
end

-- 结束游戏
function Xkland:EndGame_GS(nWinGroup)
	
	if self.tbMissionGame then
			
		-- 频道公告
		local szGroupName = self:GetGroupNameByIndex(nWinGroup);
		local szCaptainName = self.tbGroupBuffer[nWinGroup].tbCaptain.szPlayerName;
		local szMsg = string.format("<color=green>%s<color>的领袖<color=green>%s<color>成为铁浮城城主。", szGroupName, szCaptainName);
	
		self.tbMissionGame:BroadCast(szMsg, self.BOTTOM_BLACK_MSG);
		self:BroadCast_GS(szMsg, self.TOP_YELLOW_MSG);
		self:BroadCast_GS(szMsg, self.SYSTEM_CHANNEL_MSG);
		
		self.tbMissionGame:Close();	
		self.tbMissionGame = nil;
	end
	
	-- 清地图npc
	for nIndex, nMapId in pairs(self.MAP_LIST) do
		if SubWorldID2Idx(nMapId) >= 0 then		
			ClearMapNpc(nMapId);
		end
	end
	
	-- 清空几个表
	self.tbResource = {};
	self.tbBoat = {};
	self.tbRevival = {};
	self.tbThrone = {nPreGroup = 0, nOwnerGroup = 0, szPlayerName = "", nModify = 0, nMinute = 0}
	
	-- 战争状态
	self.nWarState = 0;
end

-------------------------------------------------------
-- 检测函数
-------------------------------------------------------

-- 处理届数
function Xkland:RectifySession(pPlayer)
	local nSession = pPlayer.GetTask(self.TASK_GID, self.TASK_SESSION);
	if nSession ~= self:GetSession() then
		pPlayer.SetTask(self.TASK_GID, self.TASK_COMP_COIN, 0);
		pPlayer.SetTask(self.TASK_GID, self.TASK_WAR_GROUP, 0);
		pPlayer.SetTask(self.TASK_GID, self.TASK_SESSION, self:GetSession());
		pPlayer.SetTask(self.TASK_GID, self.TASK_AWARD_MONEY, 0);
	end
end

-- 清理竞标金币
function Xkland:RectifyCompCoin(pPlayer)
	local nComp = pPlayer.GetTask(self.TASK_GID, self.TASK_COMP_COIN);
	if nComp > 0 then
		if self:CheckCaptainLocal(pPlayer) == 1 then
			local nRet = pPlayer.UnFreezeCoin(nComp, Player.emKCOIN_FREEZE_XKLAND);
			if nRet ~= 1 then
				return 0;
			end
			local nLarge = math.floor(nComp / self.BIDDING_MONEY[2][2]);
			if nLarge > 0 then
				pPlayer.ApplyAutoBuyAndUse(self.BIDDING_MONEY[2][1], nLarge);
			end
			
			local nMod = math.mod(nComp, self.BIDDING_MONEY[2][2]);
			if nMod > 0 then
				local nSmall = math.floor(nMod / self.BIDDING_MONEY[1][2]);
				if nSmall > 0 then
					pPlayer.ApplyAutoBuyAndUse(self.BIDDING_MONEY[1][1], nSmall);
				end
			end
			pPlayer.SetTask(self.TASK_GID, self.TASK_COMP_COIN, 0);
			Dbg:WriteLog("Xkland", "跨服城战", pPlayer.szAccount, pPlayer.szName, string.format("清理竞标金币：%s", nComp));		
			
			return 1;
		end
	end
	return 0;
end

-- 判断帮会首领
function Xkland:CheckTongPresident(pPlayer)
	
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

-- 本服判断军团领袖
function Xkland:CheckCaptainLocal(pPlayer)

	for nIndex, tbInfo in pairs(self.tbSyncCompBuffer) do
		if self:GetSession() == 1 then
			if nIndex <= self.MAX_GROUP and pPlayer.szName == tbInfo[1] then
				return 1;
			end
		else
			if nIndex == 1 and pPlayer.szName == tbInfo[1] then
				return 1;
			end
		end
	end
	
	return 0;
end

-- 判断城主
function Xkland:CheckCastleOwner(szPlayerName)
	if self:CheckIsGlobal() ~= 1 then
		return (self.tbLocalCastleBuffer.szPlayerName == szPlayerName) and 1 or 0;
	else
		return (self.tbCastleBuffer.szPlayerName == szPlayerName) and 1 or 0;
	end
end

-- 获得本服选择阵营
function Xkland:GetLocalGroupIndex(pPlayer)
	return pPlayer.GetTask(self.TASK_GID, self.TASK_WAR_GROUP);
end

-- 获得军团索引
function Xkland:GetGroupIndex(pPlayer)
	return GetPlayerSportTask(pPlayer.nId, self.GA_TASK_GID, self.GA_TASK_WAR_GROUP) or 0;
end

-- 获得玩家头衔
function Xkland:GetPlayerRank(pPlayer)
	if not self.tbPlayerBuffer[pPlayer.szName] then
		return 0;
	end
	return self.tbPlayerBuffer[pPlayer.szName].nRank;
end

-- 通过帮会名字找军团
function Xkland:GetGroupIndexByTongName(szTongName)
	for nGroupIndex, tbInfo in pairs(self.tbGroupBuffer) do
		for szTmpName, _ in pairs(tbInfo.tbTong) do
			if szTmpName == szTongName then
				return nGroupIndex;
			end
		end
	end 
	return 0;
end

-- 获取军团总人数
function Xkland:GetGroupMemberCount(nGroupIndex)
	if not self.tbGroupBuffer[nGroupIndex] then
		return 0;
	end
	local szGroupName = self.tbGroupBuffer[nGroupIndex].szGroupName;
	return League:GetMemberCount(self.LEAGUE_TYPE, szGroupName) or 0;
end

-- 获取军团领袖编号，0为非领袖
function Xkland:GetCaptainIndex(pPlayer)
	local tbGroup = (self:CheckIsGlobal() == 1) and self.tbGroupBuffer or self.tbLocalGroupBuffer;
	for nGroupIndex, tbInfo in pairs(tbGroup) do
		if pPlayer.szName == tbInfo.tbCaptain.szPlayerName then
			return nGroupIndex;
		end
	end 
	return 0;
end

-------------------------------------------------------
-- 竞标相关
-------------------------------------------------------

-- 获得玩家竞标排名
function Xkland:GetPlayerCompRank_GS(pPlayer)
	GCExcute({"Xkland:GetPlayerCompRank_GC", pPlayer.szName});
end

-- 获取大区竞标排行(第一次)
function Xkland:GetCompetitiveRank()
	
	if #self.tbSyncCompBuffer <= 0 then
		return nil;
	end
	
	local tbRet = {};
	for nIndex, tbInfo in pairs(self.tbSyncCompBuffer) do
		tbRet[nIndex] = {};
		tbRet[nIndex].szPlayerName = tbInfo[1];
		tbRet[nIndex].szGateway =  tbInfo[2];
		tbRet[nIndex].nCompetitive = tbInfo[3];
		tbRet[nIndex].szTongName = tbInfo[4];
	end
	
	return tbRet;
end

-- 返回玩家竞标排名
function Xkland:OnGetPlayerCompRank_GS(szPlayerName, nSort)

	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		
		-- 大区竞标排名(前6名)
		local tbRank = Xkland:GetCompetitiveRank();
		
		-- 客户端打开竞标界面
		pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_COMPETITIVE"});
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_COMPETITIVE", "OnRecvData", nSort, tbRank});	
	end
end

-- 确定竞标
function Xkland:OnCompetitiveBidding_GS(nCoin)

	-- 关闭界面
	me.CallClientScript({"UiManager:CloseWindow", "UI_COMPETITIVE"});
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 竞标期
	if self:GetPeriod() ~= self.PERIOD_COMPETITIVE then
		Dialog:Say("<color=yellow>对不起，现在不是竞标期，无法参加竞标。<color><enter><color=green>竞标期：<color>每周日、周一、周四");
		return 0;
	end
	
	-- 密码锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法参加竞标。");
		return 0;
	end
	
	-- 判断城主
	if self:CheckCastleOwner(me.szName) == 1 then
		Dialog:Say("<color=yellow>对不起，您已经是铁浮城城主，不需要参加竞标。<color><enter>城主会自动成为守城军团领袖。");
		return 0;
	end
	
	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say("<color=yellow>您的等级不足。<color><enter>竞标条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风。");
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say("<color=yellow>您还未加入门派。<color><enter>竞标条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风。");
		return 0;
	end
	
	-- 判断披风(雏凤)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < self.MANTLE_LEVEL then
		Dialog:Say("<color=yellow>此去极其凶险，您没有足以保护自己的披风，怎能匆忙应战？<color><enter>竞标条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风。");
		return 0;	
	end
	
	-- 帮会名字
	local szTongName = "Vô";
	local pTong = KTong.GetTong(me.dwTongId);
	if pTong then
		szTongName = pTong.GetName();
	end
	
	-- 城主帮会不允许竞标
	if szTongName ~= "Vô" and szTongName == self.tbLocalCastleBuffer.szTongName then
		Dialog:Say("<color=yellow>铁浮城城主所在的帮会，将自动加入守城军团，不需要参加竞标。<color>");
		return 0;	
	end
	
	-- 判断数额
	if nCoin < self.MIN_COMPETITIVE then
		Dialog:Say(string.format("对不起，每次最少投入<color=yellow>%s<color>金币。", self.MIN_COMPETITIVE));
		return 0;
	end
	
	-- 为1000的整数倍
	if math.mod(nCoin, self.MIN_COMPETITIVE) ~= 0 then
		Dialog:Say(string.format("对不起，每次投入的金币必须为<color=yellow>%s<color>的整数倍。", self.MIN_COMPETITIVE));
		return 0;
	end

	-- 判断金币
	if me.nCoin < nCoin then
		Dialog:Say("您身上金币不足，无法完成本次竞标。");
		return 0;
	end
	
	-- 竞标限制
	local nCompetitive = me.GetTask(self.TASK_GID, self.TASK_COMP_COIN);
	if nCompetitive + nCoin > self.TOTAL_COMPETITIVE then
		Dialog:Say("对不起，您的竞标额将超出系统限制，无法完成本次竞标。");
		return;
	end
	
	-- 冻结金币，记任务变量
	local nRet = me.FreezeCoin(nCoin, Player.emKCOIN_FREEZE_XKLAND);
	if nRet ~= 1 then
		return 0;
	end
	
	-- 取当前网关
	local szGateway = Transfer:GetMyGateway(me);
		
	-- 是否帮会首领
	local nRight = self:CheckTongPresident(me);
	
	-- 设置竞标变量
	me.SetTask(self.TASK_GID, self.TASK_COMP_COIN, nCompetitive + nCoin);
	GCExcute({"Xkland:OnCompetitiveBidding_GC", me.szName, nCoin, szGateway, szTongName, me.nSex, nRight});
	
	me.Msg(string.format("您已投入<color=yellow>%s<color>金币。若竞标失败，可以到铁浮城远征大将那里领取回来。", nCoin));

	-- log
	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("投入竞标金币：%s", nCoin));
end

-- 竞标结束公告
function Xkland:OnCompetitiveEnd_GS(tbInfo)
	
	if not tbInfo then
		return 0;
	end
	
	local szPlayerName = tbInfo.szPlayerName;
	local szTongName = tbInfo.szTongName;
	local szGateway = tbInfo.szGateway;
	local nCompetitive = tonumber(tbInfo.nCompetitive);
	
	-- 系统消息
	local szMsg = string.format("<color=orange>%s<color>（%s）以<color=green>%s<color>金币的价格竞标成功，成为<color=orange>%s的军团<color>的领袖，各个帮会可找各大主城的铁浮城远征大将申请加入！", szPlayerName, ServerEvent:GetServerNameByGateway(szGateway), nCompetitive, szPlayerName);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	KDialog.Msg2SubWorld(szMsg);
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
		
	-- 频道公告
	szMsg = string.format("您已竞标成功，并成为<color=yellow>%s的军团<color>的领袖！<color=yellow>您可批准各大帮会加入军团的申请，与他们并肩作战！您也可设置赏金。<color>", szPlayerName);
	pPlayer.Msg(szMsg);
	
	szMsg = string.format("帮会首领%s以%s金币的价格竞标成功，并成为%s的军团的领袖。本帮的英雄们可直接参加跨服城战，无须报名。", szPlayerName, nCompetitive, szPlayerName);
	Player:SendMsgToKinOrTong(pPlayer, szMsg, 1);
end

-------------------------------------------------------
-- 选择军团相关
-------------------------------------------------------

-- 帮会申请加入军团
function Xkland:OnSelectGroupTong_GS(nGroupIndex)

	-- 关闭界面
	if Xkland:GetSession() == 1 then
		me.CallClientScript({"UiManager:CloseWindow", "UI_SELECTGROUP_FR"});
	else
		me.CallClientScript({"UiManager:CloseWindow", "UI_SELECTGROUP_NR"});
	end
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 判断时期
	if Xkland:GetPeriod() ~= self.PERIOD_SELECT_GROUP then
		Dialog:Say("<color=yellow>对不起，现在不是加入军团的时间。<color><enter><color=green>加入军团时间：<color><enter>    每周二00:00-周三19:29；<enter>    每周五00:00-周六19:29");
		return 0;
	end
	
	-- 密码锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("您的账号处于锁定状态，无法选择军团。");
		return 0;
	end
	
	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say("<color=yellow>您的等级不足。<color><enter>报名条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、帮会首领代表全帮报名。");
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say("<color=yellow>您还未加入门派。<color><enter>报名条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、帮会首领代表全帮报名。");
		return 0;
	end
	
	-- 判断披风(雏凤)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < self.MANTLE_LEVEL then
		Dialog:Say("<color=yellow>此去极其凶险，您没有足以保护自己的披风，怎能匆忙应战？<color><enter>报名条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、帮会首领代表全帮报名。");
		return 0;	
	end
	
	-- 超出战队限制
	if nGroupIndex < 0 or nGroupIndex > self.MAX_GROUP then
		return 0;
	end
	
	-- 是否第一届
	if self:GetSession() ~= 1 and nGroupIndex > self.MIN_GROUP then
		return 0;
	end
	
	-- 判断首领
	if self:CheckTongPresident(me) ~= 1 then
		Dialog:Say("<color=yellow>对不起，您不是帮会首领！<color><enter><enter><color=green>请帮会首领前来代表本帮报名，本帮成员可直接参战。无帮派人士不可参加！<color>");
		return 0;
	end
	
	-- 判断军团领袖
	if self:CheckCaptainLocal(me) == 1 then
		Dialog:Say("<color=yellow>对不起，您已经是军团领袖，不需要再加入军团。<color><enter>本帮成员可直接参战。");
		return 0;
	end
	
	-- 判断城主
	if self:CheckCastleOwner(me.szName) == 1 then
		Dialog:Say("<color=yellow>对不起，您是铁浮城城主，已经是守方军团的领袖。<color><enter>本帮成员可直接参战。");
		return 0;
	end
	
	local szGateway = Transfer:GetMyGateway(me);
	local szTongName = KTong.GetTong(me.dwTongId).GetName();
	
	-- 判断是否为城主帮会
	if self.tbLocalCastleBuffer.szTongName and szTongName == self.tbLocalCastleBuffer.szTongName then
		Dialog:Say("<color=yellow>对不起，铁浮城城主所在的帮会成员自动成为守方，可直接参战。");
		return 0;
	end
	
	-- 判断是否已经选择
	for nGroupIndex, tbInfo in pairs(self.tbLocalGroupBuffer) do
		if self.tbLocalGroupBuffer[nGroupIndex].tbPreTong[szTongName] then
			Dialog:Say("<color=yellow>对不起，您已经申请加入了军团！<enter>您可以先撤销申请后再选择其它军团。<color>");
			return 0;
		end
		if self.tbLocalGroupBuffer[nGroupIndex].tbTong[szTongName] then
			Dialog:Say("<color=yellow>对不起，您已经加入了军团，无需再次申请。<color>");
			return 0;
		end	
	end
	
	GCExcute({"Xkland:OnSelectGroupTong_GC", me.szName, nGroupIndex, szGateway, szTongName});
	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("[%s]帮会[%s]申请加入军团：%s", szGateway, szTongName, nGroupIndex));
end

-- 帮会取消申请
function Xkland:OnCancelGroupTong_GS(nGroupIndex)
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 关闭界面
	if Xkland:GetSession() == 1 then
		me.CallClientScript({"UiManager:CloseWindow", "UI_SELECTGROUP_FR"});
	else
		me.CallClientScript({"UiManager:CloseWindow", "UI_SELECTGROUP_NR"});
	end
	
	-- 非法军团编号
	if not self.tbLocalGroupBuffer[nGroupIndex] then
		return 0;
	end
	
	-- 判断时期
	if Xkland:GetPeriod() ~= self.PERIOD_SELECT_GROUP then
		Dialog:Say("<color=yellow>对不起，现在不是加入军团的时间。<color><enter><color=green>加入军团时间：<color><enter>    每周二00:00-周三19:29；<enter>    每周五00:00-周六19:29");
		return 0;
	end
	
	-- 判断首领
	if self:CheckTongPresident(me) ~= 1 then
		Dialog:Say("<color=yellow>对不起，您不是帮会首领！<color><enter><enter><color=green>请帮会首领前来代表本帮报名，本帮成员可直接参战。无帮派人士不可参加！<color>");
		return 0;
	end
	
	local szGateway = Transfer:GetMyGateway(me);
	local szTongName = KTong.GetTong(me.dwTongId).GetName();
	
	-- 不在申请表内
	if not self.tbLocalGroupBuffer[nGroupIndex].tbPreTong[szTongName] then
		Dialog:Say("<color=yellow>对不起，您所在的帮会没有加入任何军团。<color>。");
		return 0;
	end

	GCExcute({"Xkland:OnCancelGroupTong_GC", me.szName, nGroupIndex, szGateway, szTongName});	
	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("[%s]帮会[%s]取消选择军团：%s", szGateway, szTongName, nGroupIndex));
end

-- 领袖同意申请
function Xkland:OnApplyPermitGroupTong_GS(szTongName)

	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 判断时期
	if Xkland:GetPeriod() ~= self.PERIOD_SELECT_GROUP then
		Dialog:Say("<color=yellow>对不起，现在不是加入军团的时间。<color><enter><color=green>加入军团时间：<color><enter>    每周二00:00-周三19:29；<enter>    每周五00:00-周六19:29");
		return 0;
	end
	
	-- 判断领袖
	local nGroupIndex = self:GetCaptainIndex(me);
	if nGroupIndex <= 0 then
		Dialog:Say("对不起，你不是军团领袖，无法批准帮会加入申请。");
		return 0;
	end
	
	-- 不在军团列表中
	if not self.tbLocalGroupBuffer[nGroupIndex].tbPreTong[szTongName] then
		Dialog:Say("<color=yellow>对不起，该帮会没有申请加入您的军团。<color>");
		return 0;
	end

	GCExcute({"Xkland:OnPermitGroupTong_GC", me.szName, nGroupIndex, szTongName});
	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("第%s军团领袖同意[%s]帮会加入军团", nGroupIndex, szTongName));
end

-- 开启成员赏金界面
function Xkland:OnApplyOpenMemberAward(nGroupIndex)

	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 判断时期
	if Xkland:GetPeriod() ~= self.PERIOD_SELECT_GROUP and Xkland:GetPeriod() ~= self.PERIOD_WAR_REST then
		return 0;
	end
	
	if not self.tbLocalGroupBuffer[nGroupIndex] then
		return 0;
	end
	
	-- 先关闭军团界面
	if Xkland:GetSession() == 1 then
		me.CallClientScript({"UiManager:CloseWindow", "UI_SELECTGROUP_FR"});
	else
		me.CallClientScript({"UiManager:CloseWindow", "UI_SELECTGROUP_NR"});
	end
	
	-- 开启界面
	me.CallClientScript({"UiManager:OpenWindow", "UI_SHANGJIN"});
	
	-- 判断军团领袖
	local nCaptainIndex = self:GetCaptainIndex(me);
	local tbData = self.tbLocalGroupBuffer[nGroupIndex].tbAward;
	me.CallClientScript({"Ui:ServerCall", "UI_SHANGJIN", "OnRecvData", nGroupIndex, tbData});
	
	if nCaptainIndex <= 0 or nCaptainIndex ~= nGroupIndex then
		me.CallClientScript({"Ui:ServerCall", "UI_SHANGJIN", "DisableAll"});
	end
end

-- 设置成员奖励
function Xkland:OnSetMemberAward(nGroupIndex, tbAward)
	
	-- 关闭界面
	me.CallClientScript({"UiManager:CloseWindow", "UI_SHANGJIN"});
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 判断时期
	if Xkland:GetPeriod() ~= self.PERIOD_SELECT_GROUP and Xkland:GetPeriod() ~= self.PERIOD_WAR_REST then
		Dialog:Say("<color=yellow>对不起，现在不是设置赏金的时间。<color><enter><enter><color=green>您可在报名期设置赏金，城战结束当天追加赏金。<color>");
		return 0;
	end
	
	-- 密码锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("您的账号处于锁定状态，无法设置军团赏金。");
		return 0;
	end
	
	-- 判断军团领袖
	local nCaptainIndex = self:GetCaptainIndex(me);
	if nCaptainIndex <= 0 or nCaptainIndex ~= nGroupIndex then
		Dialog:Say("对不起，你不是该军团领袖，无法设置军团赏金。");
		return 0;
	end
	
	if not tbAward or not tbAward.nAwardCount or type(tbAward.nAwardCount) ~= "number"
		or not tbAward.nMultiple or type(tbAward.nMultiple) ~= "number"
		or not tbAward.nForceSend or type(tbAward.nForceSend) ~= "number"
		or not tbAward.nExtraBox or type(tbAward.nExtraBox) ~= "number" then
		Dialog:Say("对不起，请设置有效的军团赏金。");
		return 0;
	end
	
	-- 赏金上限5倍
	if tbAward.nMultiple > 5 then
		Dialog:Say("对不起，请设置有效的军团赏金。");
		return 0;
	end
	
	-- temp
	tbAward.nExtraBox = 0;

	-- 计算跨服绑银总消耗
	local nCostMoney = self:CalcMemberAward(tbAward.nAwardCount, tbAward.nMultiple);
	if nCostMoney <= 0 or nCostMoney > self.MAX_OVERFLOW then
		Dialog:Say("对不起，请设置有效的军团赏金。");
		return 0;
	end
	
	-- 计算补充的差值
	local nAwardMoney = me.GetTask(self.TASK_GID, self.TASK_AWARD_MONEY);
	local nAddMoney = nCostMoney - nAwardMoney;
	if nAddMoney <= 0 then
		Dialog:Say("对不起，请设置有效的军团赏金。");
		return 0;
	end
	
	-- 扣除跨服绑银
	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney < nAddMoney then
		Dialog:Say("<color=yellow>对不起，您的跨服绑银不足，无法设置军团赏金。<color><enter><enter><color=green>按Ctrl+G打开奇珍阁，购买跨服活动专用绑银，可增加您的跨服绑银。<color>");
		return 0;
	end
	me.CostGlbBindMoney(nAddMoney);
	
	-- 设任务变量
	me.SetTask(self.TASK_GID, self.TASK_AWARD_MONEY, nCostMoney);
	GCExcute({"Xkland:OnSetMemberAward_GC", me.szName, nGroupIndex, tbAward});
	
	-- log
	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, 
		string.format("本服领袖设置奖励，军团编号：%s, 人数：%s，倍数：%s，强制发放：%s，额外城主箱子：%s", 
		nGroupIndex, tbAward.nAwardCount, tbAward.nMultiple, tbAward.nForceSend, tbAward.nExtraBox));
end

-- 帮会申请加入军团消息
function Xkland:OnSelectGroupTongEnd_GS(szPlayerName, szGroupName)
	if not szPlayerName or not szGroupName then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	local szMsg = string.format("<color=yellow>您的帮会已经申请加入%s，请等待军团领袖批准！<color>", szGroupName);
	pPlayer.Msg(szMsg);
end

-- 帮会取消加入军团申请
function Xkland:OnCancelGroupTongEnd_GS(szPlayerName, szGroupName)
	if not szPlayerName or not szGroupName then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	local szMsg = string.format("<color=yellow>您的帮会已经撤销加入%s的申请，可以重新申请加入其他军团！<color>", szGroupName);
	pPlayer.Msg(szMsg);
end

-- 领袖同意申请
function Xkland:OnPermitGroupTongEnd_GS(szPlayerName, nGroupIndex, szTongName, szGroupName)

	if not szPlayerName or not szGroupName then
		return 0;
	end
	local szMsg = string.format("<color=yellow>%s帮会已经加入%s，即将参加跨服城战！<color>", szTongName, szGroupName);
	KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	if self:GetSession() == 1 then
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_SELECTGROUP_FR", "OnRecvData", self.tbLocalGroupBuffer, 1});
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_SELECTGROUP_FR", "UpdateDetailInfo", nGroupIndex});
	else
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_SELECTGROUP_NR", "OnRecvData", self.tbLocalGroupBuffer, 1});
	end
end

-------------------------------------------------------
-- 资源点、积分相关
-------------------------------------------------------

-- 添加资源点
function Xkland:AddResource(nNpcId, tbPos, nOwnerGroup)
	local pNpc = KNpc.Add2(nNpcId, 120, -1, tbPos[1], tbPos[2], tbPos[3]);
	if pNpc then
		if not self.tbResource[pNpc.dwId] then
			self.tbResource[pNpc.dwId] = {};
		end
		self.tbResource[pNpc.dwId].nNpcId = nNpcId;
		self.tbResource[pNpc.dwId].tbPos = tbPos;
		self.tbResource[pNpc.dwId].nOwnerGroup = nOwnerGroup or 0;
		
		if nOwnerGroup and nOwnerGroup > 0 then
			pNpc.SetVirtualRelation(Player.emKPK_STATE_EXTENSION, nOwnerGroup);
			pNpc.szName = string.format("%s的资源点", self.NORMAL_TITLE[nOwnerGroup]);
		end
	end
	return 0;
end

-- 玩家占领资源点
function Xkland:OnGetResouce(pPlayer, nNpcDwId)
	
	local nGroupIndex = 0;
	local szPlayerName = "";
	
	if pPlayer then
		nGroupIndex = self:GetGroupIndex(pPlayer);
		szPlayerName = pPlayer.szName;
		self:AddPoint(pPlayer, self.RESOURCE_POINT);
	end
	
	local tbInfo = self.tbResource[nNpcDwId];
	
	-- 重置所有权
	GCExcute({"Xkland:OnGetResouce_GA", szPlayerName, nGroupIndex, tbInfo.nOwnerGroup}); 
	
	-- 增加新的资源点
	Timer:Register(Env.GAME_FPS, self.AddResource, self, tbInfo.nNpcId, tbInfo.tbPos, nGroupIndex);
	
	-- 删除用来的
	self.tbResource[nNpcDwId] = nil;
end

-- 玩家护卫资源点
function Xkland:OnProtectResource(pPlayer, nPoint)
	
	local nGroupIndex = self:GetGroupIndex(pPlayer);
	
	-- 增加积分
	self:AddPoint(pPlayer, self.PROTECT_POINT);
	
	-- 记录数据
	GCExcute({"Xkland:OnProtectResource_GA", pPlayer.szName}); 
end

-- 个人和军团增加积分
function Xkland:AddPoint(pPlayer, nPoint)

	local nGroupIndex = self:GetGroupIndex(pPlayer);
	
	-- 个人加分
	GCExcute({"Xkland:AddPlayerPoint_GA", pPlayer.szName, nPoint}); 
	 
	-- 给军团加分
	GCExcute({"Xkland:AddGroupPoint_GA", nGroupIndex, nPoint});
end

-- 杀人处理
function Xkland:OnKillPlayer(pKiller, pDied)
	
	-- 计算积分
	local nDiedRank = Xkland:GetPlayerRank(pDied);
	local nKillerRank = Xkland:GetPlayerRank(pKiller);
	
	local nPoint = math.floor((10 - (nKillerRank - nDiedRank)) / 10) * self.KILLER_BOUNS;
	
	-- 增加积分
	self:AddPoint(pKiller, nPoint);
	
	-- 处理杀人数
	local nSeriesKill = pKiller.GetTask(self.TASK_GID, self.TASK_SERIES_KILL);
	GCExcute({"Xkland:AddPlayerKill_GA", pKiller.szName, nSeriesKill})
	
	if nSeriesKill ~= 1 then
		pKiller.SetTask(self.TASK_GID, self.TASK_SERIES_KILL, 1);
	end
	
	pDied.SetTask(self.TASK_GID, self.TASK_SERIES_KILL, 0);
end

-- gc同步战斗数据后
function Xkland:TimerSyncDate_GS()
	
	if self.tbMissionGame then
		
		-- 1. 重置buffer
		for nGroupIndex, tbInfo in pairs(self.tbWarBuffer) do
			local nBufferLevel = tbInfo.nResource;
			self.tbMissionGame:SetGroupBuffer(self.RESOURCE_BUFFER, nGroupIndex, nBufferLevel);
		end
		
		-- 2. 更新头衔
		self.tbMissionGame:UpdatePlayerRank();
		
		-- 3. 玩家排名
		self.tbSortPlayer = {};
		for szPlayerName, tbInfo in pairs(self.tbPlayerBuffer) do
			table.insert(self.tbSortPlayer, {szPlayerName = szPlayerName, nPoint = tbInfo.nPoint});
		end
		table.sort(self.tbSortPlayer, function(a, b) return a.nPoint > b.nPoint end);
		
		-- 4. 军团排名
		self.tbSortGroup = {};
		for nGroupIndex, tbInfo in pairs(self.tbWarBuffer) do
			table.insert(self.tbSortGroup, {nGroupIndex = nGroupIndex, nPoint = tbInfo.nPoint, nThronePoint = tbInfo.nThronePoint});
		end
		table.sort(self.tbSortGroup, function(a, b) return a.nThronePoint > b.nThronePoint end);
		
		-- 5. 右侧信息
		self.tbMissionGame:UpdateAllRightUI();
		
		-- 6. 平衡buffer
		local nRet, tbBalance = self:CalcBalanceBuffer();
		if nRet == 1 then
			for nGroupIndex, tbInfo in pairs(self.tbWarBuffer) do
				self.tbMissionGame:SetGroupBuffer(self.BALANCE_BUFFER, nGroupIndex, tbBalance[nGroupIndex]);
			end
		end
	end
end

-- 计算平衡
function Xkland:CalcBalanceBuffer()
	
	-- 第一届不算
	if self:GetSession() == 1 then
		return 0;
	end
	
	local tbBalance = {};
	for szPlayerName, tbInfo in pairs(self.tbPlayerBuffer) do
		if not tbBalance[tbInfo.nGroupIndex] then
			tbBalance[tbInfo.nGroupIndex] = {};
			tbBalance[tbInfo.nGroupIndex].nPlayerCount = 0;
		end
		tbBalance[tbInfo.nGroupIndex].nPlayerCount = tbBalance[tbInfo.nGroupIndex].nPlayerCount + 1;
 	end
 	
 	if not tbBalance[1] or not tbBalance[2] then
 		return 0;
 	end
 	
 	local nSmall = 0;
 	local nLarge = 0;
 	local nBalanceLevel = 0;
 	local nBalanceGroup = 0;
 	local tbRet = {[1] = 0, [2] = 0};
 	
 	if tbBalance[1].nPlayerCount > tbBalance[2].nPlayerCount then
		nSmall = tbBalance[2].nPlayerCount;
		nLarge = tbBalance[1].nPlayerCount;
		nBalanceGroup = 2;
	else
		nSmall = tbBalance[1].nPlayerCount;
		nLarge = tbBalance[2].nPlayerCount;
		nBalanceGroup = 1;
 	end

	local nRate = math.floor(100 * nSmall / nLarge);
	for i, nRadio in ipairs(self.BALANCE_LEVEL) do
		if nRate <= nRadio then
			nBalanceLevel = i;
		end
	end
	
	if nBalanceLevel == 0 then
		return 0;
	end

	tbRet[nBalanceGroup] = nBalanceLevel;
	return 1, tbRet;
end

-- 增加渡船点
function Xkland:AddBoat(nNpcId, tbPos)
	local pNpc = KNpc.Add2(nNpcId, 120, -1, tbPos[1], tbPos[2], tbPos[3]);
	if pNpc then
		self.tbBoat[pNpc.dwId] = 1;
	end
end

-- 删除渡船点
function Xkland:RemoveBoat()
	for nNpcDwId, _ in pairs(self.tbBoat) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			pNpc.Delete();
		end
		self.tbBoat[nNpcDwId] = nil;
	end
end

-- 复活点3归属
function Xkland:OnGetRevival(nMapId, nGroupIndex)
	if not self.tbRevival[nMapId] then
		for _, tbInfo in pairs(self.REVIVAL_LIST[nMapId] or {}) do
			KNpc.Add2(tbInfo.nNpcId, 120, -1, tbInfo.tbPos[1], tbInfo.tbPos[2], tbInfo.tbPos[3]);
		end
	end	
	self.tbRevival[nMapId] = nGroupIndex;
end

-- 获取归属
function Xkland:GetRevivalOwner(nMapId)
	return self.tbRevival[nMapId] or 0;
end

-- 判断是否可以占领王座
function Xkland:CheckOccupyThrone(nGroupIndex)
	
	if self.tbThrone.nOwnerGroup == 0 then
		return 1;
	end
	
	if nGroupIndex == self.ATTACK_GROUP_INDEX and self.tbThrone.szPlayerName == "" then
		return 1;
	end
	
	return 0;
end

-- 获得王座增加积分
function Xkland:GetThronePoint(nMinute, nModify)
	
	if not self.tbThroneScore[nMinute] then
		return 0;
	end
	
	if nModify > self.MAX_OCCUPY_DEATHS then
		return self.tbThroneScore[nMinute][self.MAX_OCCUPY_DEATHS];
	end
	
	return self.tbThroneScore[nMinute][nModify];
end
	
-- 占领王座回调
function Xkland:OnOccupyThrone(szPlayerName, nGroupIndex)
	
	-- 设置归属
	self.tbThrone.nOwnerGroup = nGroupIndex;
	self.tbThrone.szPlayerName = szPlayerName;
	self.tbThrone.nOccupyTime = GetTime();
	
	-- 不等于之前的
	if nGroupIndex ~= self.tbThrone.nPreGroup then
		local nPoint = self:GetThronePoint(0, self.tbThrone.nModify);
		GCExcute({"Xkland:AddGroupThronePoint_GA", nGroupIndex, nPoint});
		self.tbThrone.nModify = self.tbThrone.nModify + 1;
		self.tbThrone.nPreGroup = nGroupIndex;
	end
end

-- 每分钟增加王座积分
function Xkland:AddThronePoint()
	
	if SubWorldID2Idx(self.THRONE_MAP_ID) < 0 then
		return 0;
	end

	-- 分钟增加
	self.tbThrone.nMinute = self.tbThrone.nMinute + 1;
	
	-- 增加积分
	if self.tbThrone.nOwnerGroup > 0 then
		local nPoint = self:GetThronePoint(self.tbThrone.nMinute, self.tbThrone.nModify);
		GCExcute({"Xkland:AddGroupThronePoint_GA", self.tbThrone.nOwnerGroup, nPoint});
	end
	
	-- 广播王座情况
	if self.tbThrone.nOccupyTime then
		local nTime = GetTime() - self.tbThrone.nOccupyTime;
		local szGroupName = self:GetGroupNameByIndex(self.tbThrone.nOwnerGroup);
		local szPlayerName = self.tbThrone.szPlayerName;	
		local szMsg = string.format("<color=green>%s<color>的<color=green>%s<color>已经在王座上坐了<color=red>%s<color>", szGroupName, szPlayerName, Lib:TimeDesc(nTime));
		self:BroadCast_GS(szMsg, self.BOTTOM_BLACK_MSG);
		
		-- 增加积分
		local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
		if pPlayer then
			self:AddPoint(pPlayer, self.THRONE_POINT);
		end
	end
end

-- 占领人死亡回调
function Xkland:OnLoseThrone(szPlayerName, nGroupIndex)
	
	local szGroupName = self:GetGroupNameByIndex(nGroupIndex);
	local szPlayerName = self.tbThrone.szPlayerName;
	local szMsg = string.format("%s的%s失去了王座，停止累计个人积分与王座积分！", szGroupName, szPlayerName);
	self:BroadCast_GS(szMsg, self.MIDDLE_RED_MSG);
	self:BroadCast_GS(szMsg, self.SYSTEM_CHANNEL_MSG);
	
	-- 设置归属
	self.tbThrone.nOwnerGroup = 0;
	self.tbThrone.szPlayerName = "";
	self.tbThrone.nOccupyTime = nil;
end

-- 同步地图人数
function Xkland:SyncMapPlayerCount_GS(tbInfo)
	self.tbMapPlayerCount = tbInfo;
end

-- 增加地图人数
function Xkland:AddMapPlayerCount_GA(nMapId, nCount)
	GCExcute({"Xkland:AddMapPlayerCount_GA", nMapId, nCount});
end

-- 获取地图人数
function Xkland:GetMapPlayerCount(nMapId)
	return self.tbMapPlayerCount[nMapId] or 0;
end

-------------------------------------------------------
-- 奖励相关
-------------------------------------------------------

-- 增加城池基金
function Xkland:AddCastleMoney_GS(nCastleMoney)
	GCExcute({"Xkland:AddCastleMoney_GA", nCastleMoney});
end

-- 增加系统基金
function Xkland:AddSystemMoney_GS(nSystemMoney)
	GCExcute({"Xkland:AddSystemMoney_GA", nSystemMoney});
end

-- 免费复活检测
function Xkland:CheckFreeRevival(pPlayer)
	
	if self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	if self:GetCaptainIndex(pPlayer) <= 0 then
		Dialog:Say("对不起，只有军团领袖才可以设置本军团的军需库。");
		return 0;
	end
	
	if self:GetPeriod() ~= self.PERIOD_SELECT_GROUP and self:GetPeriod() ~= self.PERIOD_WAR_OPEN then
		Dialog:Say("对不起，现在无法设置本军团的军需库。");
		return 0;
	end
	
	return 1;
end

-- 增加免费复活基金
function Xkland:AddFreeRevival_GS(nCount)
	
	if self:CheckFreeRevival(me) ~= 1 then
		return 0;
	end
	
	local nCaptainIndex = self:GetCaptainIndex(me);
	if self:CheckCastleOwner(me.szName) == 1 then
		local nCastleMoney = self.tbCastleBuffer.nCastleMoney or 0;
		if me.GetBindMoney() + nCastleMoney < nCount then
			Dialog:Say("对不起，您的跨服绑银不足，无法设置指定的数额。");
			return 0;
		end
		if nCastleMoney > nCount then
			GCExcute({"Xkland:AddCastleMoney_GA", -nCount});
		else
			GCExcute({"Xkland:AddCastleMoney_GA", -nCastleMoney});
			me.CostBindMoney(nCount - nCastleMoney);
		end
	else
		if me.GetBindMoney() < nCount then
			Dialog:Say("对不起，您的跨服绑银不足，无法设置指定的数额。");
			return 0;
		end
		me.CostBindMoney(nCount);
	end
	
	GCExcute({"Xkland:AddFreeRevival_GA", nCaptainIndex, nCount});
	me.Msg(string.format("您已经成功为本军团的军需库增加了<color=yellow>%s<color>两绑银。", nCount));
	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("增加军需库绑银：%s", nCount));
end

-- 设置各披风等级复活次数
function Xkland:SetMantleRevival_GS(nType, nCount)
	
	if self:CheckFreeRevival(me) ~= 1 then
		return 0;
	end

	if nCount <= 0 then
		return 0;
	end
	
	local nCaptainIndex = self:GetCaptainIndex(me);
	GCExcute({"Xkland:SetMantleRevival_GA", nCaptainIndex, nType, nCount});
	me.Msg(string.format("<color=yellow>%s<color>的免费征战次数设置为<color=yellow>%s<color>", Xkland.MANTLE_TYPE[nType], nCount));
end

-- 分配奖励结果
function Xkland:OnDistributeResult(tbInfo)
	
	-- 关闭界面
	me.CallClientScript({"UiManager:CloseWindow", "UI_DISTRIBUTE"});
	
	if self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	if self:CheckCastleOwner(me.szName) ~= 1 then
		Dialog:Say("对不起，只有城主才能分配奖励");
		return 0
	end
	
	if self:GetPeriod() ~= self.PERIOD_WAR_REST then
		Dialog:Say("<color=yellow>对不起，现在不是奖励分配期。<color><enter>分奖期：城战结束的当天21:30-23:59");
		return 0;
	end	
	
	local tbType = {[1] = 1, [2] = 1};
	if not tbInfo or not tbInfo.nType or not tbType[tbInfo.nType] then
		return 0;
	end
	
	for _, tbTongInfo in pairs(tbInfo.tbTongInfo or {}) do
		local szTongName = tbTongInfo.szTongName;
		local nCount = tbTongInfo.nCurPoint;
		if szTongName and type(szTongName) == "string" and nCount and type(nCount) == "number" then
			if self.tbCastleBuffer.tbTong[szTongName] then
				GCExcute({"Xkland:OnDistributeResult_GA", szTongName, nCount, tbInfo.nType});
			end
		end
	end
end

-- 判断城主令牌
function Xkland:CheckLadderAward(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_COMPETITIVE then
		Dialog:Say("对不起，现在无法领取奖励。");
		return 0;
	end
	
	if self:GetSession() == 1 then
		Dialog:Say("对不起，现在无法领取奖励。");
		return 0;
	end
	
	if self:CheckCastleOwner(pPlayer.szName) ~= 1 then
		Dialog:Say("对不起，您不是城主，无法领取奖励");
		return 0;
	end
	
	local nAward = self.tbLocalCastleBuffer.nChengZhuLingPai;
	if not nAward or nAward <= 0 then
		Dialog:Say("对不起，您没有城主奖励可以领取！");
		return 0;
	end
	
	-- 叠加物品背包空间
	local nNeed = KItem.GetNeedFreeBag(self.CHENGZHU_LINGPAI_ID[1], self.CHENGZHU_LINGPAI_ID[2], self.CHENGZHU_LINGPAI_ID[3], self.CHENGZHU_LINGPAI_ID[4], nil, nAward);
	if pPlayer.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	return 1;
end

-- 检查城主奖励
function Xkland:CheckCastleAward(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_COMPETITIVE then
		Dialog:Say("对不起，现在无法领取奖励。");
		return 0;
	end
	
	if self:GetSession() == 1 then
		Dialog:Say("对不起，现在无法领取奖励。");
		return 0;
	end
	
	-- 判断首领
	if Xkland:CheckCastleOwner(pPlayer.szName) ~= 1 and Xkland:CheckTongPresident(pPlayer) ~= 1 then
		Dialog:Say("<color=yellow>您不是帮会的首领，无法领取奖励！<color><enter>该奖励由帮会首领自行分配。");
		return 0;
	end
	
	local nRetBox = 0;
	local nRetLingPai = 0;
	
	if self:CheckCastleOwner(pPlayer.szName) == 1 then
		if self.tbLocalCastleBuffer.nCastleBox <= 0 and self.tbLocalCastleBuffer.nLingPai <= 0 then
			Dialog:Say("对不起，您没有奖励可以领取！");
			return 0;
		end
		nRetBox = self.tbLocalCastleBuffer.nCastleBox;
		nRetLingPai = self.tbLocalCastleBuffer.nLingPai;
	else
		
		local pTong = KTong.GetTong(pPlayer.dwTongId);
		if not pTong then
			Dialog:Say("对不起，您没有帮会，无法领取奖励！");
			return 0;
		end
		
		local szTongName = pTong.GetName();
		if not self.tbLocalCastleBuffer.tbTong then
			Dialog:Say("对不起，您所在的帮会没有奖励可以领取！");
			return 0;
		end
		local tbAward = self.tbLocalCastleBuffer.tbTong[szTongName];
		if not tbAward or (tbAward.nBox <= 0 and tbAward.nLingPai <= 0) then
			Dialog:Say("对不起，您所在的帮会没有奖励可以领取！");
			return 0;
		end
		nRetBox = tbAward.nBox;
		nRetLingPai = tbAward.nLingPai;
	end	
	
	-- 叠加物品背包空间
	local nNeed = KItem.GetNeedFreeBag(self.CASTLE_BOX_ID[1], self.CASTLE_BOX_ID[2], self.CASTLE_BOX_ID[3], self.CASTLE_BOX_ID[4], nil, nRetBox);
	nNeed = nNeed + KItem.GetNeedFreeBag(self.LINGPAI_ID[1], self.LINGPAI_ID[2], self.LINGPAI_ID[3], self.LINGPAI_ID[4], nil, nRetLingPai);
	
	if pPlayer.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	return 1;
end

-- gs申请领取城主令牌
function Xkland:GetLadderAward_GS(szPlayerName)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end	
	
	if self:CheckLadderAward(pPlayer) ~= 1 then
		return 0;
	end
	
	-- 锁住玩家
	pPlayer.AddWaitGetItemNum(1);
	GCExcute({"Xkland:GetLadderAward_GC", szPlayerName});
end

-- gs申请领取城主奖励
function Xkland:GetCastleAward_GS(szPlayerName)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	if self:CheckCastleAward(pPlayer) ~= 1 then
		return 0;
	end
	
	local pTong = KTong.GetTong(pPlayer.dwTongId);
	local szTongName = pTong and pTong.GetName() or "";
	
	-- 锁住玩家
	pPlayer.AddWaitGetItemNum(1);
	GCExcute({"Xkland:GetCastleAward_GC", szPlayerName, szTongName});
end

-- gs城主令牌奖励回调
function Xkland:OnGetLadderAward_GS(szPlayerName, nChengZhuLingPai)

	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	-- 先解锁
	pPlayer.AddWaitGetItemNum(-1);
	
	-- 解锁玩家
	if nChengZhuLingPai > 0 then
		pPlayer.AddStackItem(self.CHENGZHU_LINGPAI_ID[1], self.CHENGZHU_LINGPAI_ID[2], self.CHENGZHU_LINGPAI_ID[3], self.CHENGZHU_LINGPAI_ID[4], nil, nChengZhuLingPai);
		local szMsg = string.format("本届城主%s领取了%s个铁浮城城主令",szPlayerName, nChengZhuLingPai);
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		KDialog.Msg2SubWorld(szMsg);
		Dbg:WriteLog("Xkland", "跨服城战", pPlayer.szAccount, pPlayer.szName, string.format("领取城主令牌：%s", nChengZhuLingPai));
	else
		pPlayer.Msg("对不起，您已经领取完城主令牌了！");
	end
end

-- gs城主奖励回调
function Xkland:OnGetCastleAward_GS(szPlayerName, szTongName, nCastleBox, nLingPai)

	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	-- 解锁玩家
	pPlayer.AddWaitGetItemNum(-1);
	
	local szMsg = "";
	local szMsg1 = "";
	local szMsg2 = "";
	
	if nCastleBox > 0 then
		pPlayer.AddStackItem(self.CASTLE_BOX_ID[1], self.CASTLE_BOX_ID[2], self.CASTLE_BOX_ID[3], self.CASTLE_BOX_ID[4], nil, nCastleBox);
		szMsg1 = string.format("%s个辉煌战功箱", nCastleBox);
	end
	
	if nLingPai > 0 then
		pPlayer.AddStackItem(self.LINGPAI_ID[1], self.LINGPAI_ID[2], self.LINGPAI_ID[3], self.LINGPAI_ID[4], nil, nLingPai);
		szMsg2 = string.format("%s个铁浮城英雄令", nLingPai);
	end
	
	if szTongName then
		szMsg = string.format("%s帮会的首领%s领取了：%s %s", szTongName, szPlayerName, szMsg1, szMsg2);
	else
		szMsg = string.format("本届城主%s领取了：%s %s", szPlayerName, szMsg1, szMsg2);
	end
	
	KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	KDialog.Msg2SubWorld(szMsg);
	
	Dbg:WriteLog("Xkland", "跨服城战", pPlayer.szAccount, pPlayer.szName, string.format("领取城主奖励：%s个辉煌战功箱，%s个铁浮城英雄令", nCastleBox, nLingPai));
end

-- 城主领奖失败
function Xkland:OnGetCastleAwardFailed_GS(szPlayerName)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.Msg("对不起，您已经领取完所有的奖励了！");
end

-- 城主令牌领取失败
function Xkland:OnGetLadderAwardFailed_GS(szPlayerName)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.Msg("对不起，您已经领取完城主令牌了！");
end

-- 判断个人奖励
function Xkland:CheckSingleAward(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_COMPETITIVE then
		Dialog:Say("对不起，现在无法领取赏金。");
		return 0;
	end
	
	local nPointBox = GetPlayerSportTask(me.nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX) or 0;
	local nGetBox = me.GetTask(self.TASK_GID, self.TASK_WAR_BOX);
	local nRet = nPointBox - nGetBox;
	if nRet <= 0 then
		Dialog:Say("对不起，您没有赏金可以领取。");
		return 0;
	end
	
	return nRet;
end

-- gs领取个人奖励
function Xkland:GetSingleAward_GS()
		
	local nSingleBox = self:CheckSingleAward(me);
	if nSingleBox <= 0 then
		return 0;
	end
	
	-- 叠加物品背包空间
	local nNeed = KItem.GetNeedFreeBag(self.NORMAL_BOX_ID[1], self.NORMAL_BOX_ID[2], self.NORMAL_BOX_ID[3], self.NORMAL_BOX_ID[4], nil, nSingleBox);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	me.AddStackItem(self.NORMAL_BOX_ID[1], self.NORMAL_BOX_ID[2], self.NORMAL_BOX_ID[3], self.NORMAL_BOX_ID[4], nil, nSingleBox);
	me.SetTask(self.TASK_GID, self.TASK_WAR_BOX, me.GetTask(self.TASK_GID, self.TASK_WAR_BOX) + nSingleBox);
	
	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("领取赏金宝箱：%s", nSingleBox));
end

-- 判断经验奖励
function Xkland:CheckExtraAward(pPlayer)
	
	if self:GetPeriod() ~= self.PERIOD_COMPETITIVE then
		Dialog:Say("对不起，现在无法领取经验和威望。");
		return 0;
	end
	
	local nPointExp = GetPlayerSportTask(me.nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP) or 0;
	local nGetExp = me.GetTask(self.TASK_GID, self.TASK_WAR_EXP);
	local nRet = nPointExp - nGetExp;
	if nRet <= 0 then
		Dialog:Say("对不起，您没有经验和威望可以领取。");
		return 0;
	end
	
	return nRet;
end

-- gs领取经验威望
function Xkland:GetExtraAward_GS()
		
	local nExtraAward = Xkland:CheckExtraAward(me);
	if nExtraAward <= 0 then
		return 0;
	end
	
	local nRepute = (nExtraAward >= 500) and 50 or 0;
	
	me.AddExp(nExtraAward * 10000);
	me.AddKinReputeEntry(nRepute);
	me.SetTask(self.TASK_GID, self.TASK_WAR_EXP, me.GetTask(self.TASK_GID, self.TASK_WAR_EXP) + nExtraAward);

	Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("领取经验：%s，威望：%s", nExtraAward, nRepute));
end

-- 领取返还的跨服绑银
function Xkland:OnGetBackMoney_GS(szPlayerName, nMoney)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	-- 先解锁
	pPlayer.AddWaitGetItemNum(-1);
	
	-- 解锁玩家
	if nMoney > 0 then
		pPlayer.AddGlbBindMoney(nMoney);
		Dbg:WriteLog("Xkland", "跨服城战", pPlayer.szAccount, pPlayer.szName, string.format("领取返还跨服绑银：%s", nMoney));
	else
		pPlayer.Msg("对不起，您已经领取完剩余的跨服绑银了！");
	end	
end

-- 自定义头衔
function Xkland:AddPlayerTitle(pPlayer, nGroupIndex)
	
	if not pPlayer then
		return 0;
	end
	
	local nLevel = 1;
	if self.tbPlayerBuffer[pPlayer.szName] then
		nLevel = self.tbPlayerBuffer[pPlayer.szName].nRank + 1;
	end
	
	if nLevel > #self.RANK_POINT then
		nLevel = #self.RANK_POINT;
	end
	
	local szTitle = "";
	if Xkland:GetSession () == 1 then
		szTitle = string.format("第%s军团%s", Lib:Transfer4LenDigit2CnNum(nGroupIndex), self.RANK_POINT[nLevel][2]);
	else
		szTitle = string.format("%s%s", self.NORMAL_TITLE[nGroupIndex], self.RANK_POINT[nLevel][2]);
	end
	pPlayer.AddSpeTitle(szTitle, GetTime() + 60 * 60 * 24, self.GROUP_COLOR[nGroupIndex]);
end

-- 删除所有自定义称号
function Xkland:RemovePlayerTitle(pPlayer, nGroupIndex)
	
	if not pPlayer then
		return 0;
	end
	
	for i = 1, #self.RANK_POINT do	
		local szTitle = "";
		if Xkland:GetSession () == 1 then
			szTitle = string.format("第%s军团%s", Lib:Transfer4LenDigit2CnNum(nGroupIndex), self.RANK_POINT[i][2]);
		else
			szTitle = string.format("%s%s", self.NORMAL_TITLE[nGroupIndex], self.RANK_POINT[i][2]);
		end	
		pPlayer.RemoveSpeTitle(szTitle, GetTime() + 60 * 60 * 24, self.GROUP_COLOR[nGroupIndex]);			
	end
end

-- 更新城主雕像
function Xkland:UpdateCastleStatue_GS(szPlayerName, nPlayerSex, nCenter)
	
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
				pNpc.szName = string.format("%s的雄伟雕像", szPlayerName);
				self.tbCastleNpcId[nMapId] = pNpc.dwId;
			end
		end
	end
end

-------------------------------------------------------
-- c2s call
-------------------------------------------------------

-- 客户端金币竞标
function c2s:ApplyCompetitiveJoin(nCoin)
	Xkland:RectifySession(me);
	Xkland:OnCompetitiveBidding_GS(nCoin);
end

-- 帮会申请加入
function c2s:ApplySelectGroupTong(nGroupIndex)
	Xkland:RectifySession(me);
	Xkland:OnSelectGroupTong_GS(nGroupIndex);
end

-- 帮会取消申请
function c2s:ApplyCancelGroupTong(nGroupIndex)
	Xkland:RectifySession(me);
	Xkland:OnCancelGroupTong_GS(nGroupIndex);
end

-- 领袖同意申请
function c2s:ApplyPermitGroupTong(szTongName)
	Xkland:RectifySession(me);
	Xkland:OnApplyPermitGroupTong_GS(szTongName)
end

-- 城主分配奖励
function c2s:ApplyDistributeResult(tbInfo)
	Xkland:RectifySession(me);
	Xkland:OnDistributeResult(tbInfo);
end

-- 开启成员赏金界面
function c2s:ApplyOpenMemberAward(nGroupIndex)
	Xkland:RectifySession(me);
	Xkland:OnApplyOpenMemberAward(nGroupIndex);
end

-- 设置成员奖励
function c2s:ApplySetMemberAward(nGroupIndex, tbAward)
	Xkland:RectifySession(me);
	Xkland:OnSetMemberAward(nGroupIndex, tbAward);
end

-------------------------------------------------------
-- 系统相关
-------------------------------------------------------

-- gm enter
function Xkland:GM_EnterMap()
	self.GMPlayerList = self.GMPlayerList or {};
	if me.GetCamp() == 6 then
		self.GMPlayerList[me.nId] = 1;
		return 1;
	end
	return 0;
end

-- gm leave
function Xkland:GM_LeaveMap()
	self.GMPlayerList = self.GMPlayerList or {};
	if me.GetCamp() == 6 then
		self.GMPlayerList[me.nId] = nil;
		return 1;
	end
	return 0;
end

-- 广播系统
function Xkland:BroadCast_GS(szMsg, nType)
	if nType == self.TOP_YELLOW_MSG then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	else
		GCExcute({"Xkland:BroadCast_GA", szMsg, nType});
	end
end

-- 广播回调
function Xkland:OnBroadCast_GS(szMsg, nType)
	if self.tbMissionGame then
		self.tbMissionGame:BroadCast(szMsg, nType);
	end
end

-- 开战公告
function Xkland:Announce_GS()
	
	local szMsg = "";
	local nPeriod = self:GetPeriod();
	
	if self:CheckWarTaskOpen() == 1 then
		if nPeriod == self.PERIOD_SELECT_GROUP then
			szMsg = "<color=yellow>【跨服城战】进入最后报名阶段，帮会首领可代表本帮在各大主城的铁浮城远征大将处申请加入军团！无帮派人士不可参加！<color><color=green>城战于今日19:30开启！<color>";
		elseif nPeriod == self.PERIOD_WAR_OPEN then
			local nTime = tonumber(GetLocalDate("%H%M"));
			if nTime < 2000 then
				szMsg = "<color=yellow>【跨服城战】已开启，19:30-20:00为准备阶段，侠士可在各大主城的铁浮城远征大将处进入英雄岛-铁浮城！<color><color=green>城战于今日20:00打响！<color>";
			elseif nTime < 2130 then
				szMsg = "<color=yellow>【跨服城战】各路英雄正在铁浮城中浴血奋战！<color><color=green>城战于今日21:30结束！<color>";
			else
				return 0;
			end
		elseif nPeriod == self.PERIOD_WAR_REST then
			szMsg = "<color=yellow>【跨服城战】已结束！请城主分配胜方奖励！（21:30-23:59）<color><color=green>请各位英雄于明日在主城的铁浮城远征大将处领取奖励！<color>";
		else
			return 0;
		end
	elseif nPeriod == self.PERIOD_COMPETITIVE then
		szMsg = "<color=yellow>【跨服城战】今日为领奖、竞标期，等级达到100级、已加入门派、佩戴雏凤及以上披风的侠士可用金币在各大主城的铁浮城远征大将处竞取军团领袖的资格！<color><color=green>请及时领取上次城战奖励！<color>";
	elseif nPeriod == self.PERIOD_SELECT_GROUP then
		szMsg = "<color=yellow>【跨服城战】今日为报名期，帮会首领可代表本帮在各大主城的铁浮城远征大将处申请加入军团！无帮派人士不可参加！<color><color=green>报名将于明日19:29截止！<color>";
	else
		return 0;
	end
	
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	KDialog.Msg2SubWorld(szMsg);
end

-- 载入本地global buffer
function Xkland:LoadBuffer_GS(nBufferIndex)
	
	local szBuffer = self.VAILD_GBLBUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	local tbLoadBuffer = GetGblIntBuf(nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self[szBuffer] = tbLoadBuffer;
	end
end

-- 置空本地global buffer
function Xkland:ClearBuffer_GS(nBufferIndex)

	local szBuffer = self.VAILD_GBLBUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	self[szBuffer] = {};
end

-- 载入中心服务器buffer
function Xkland:LoadCenterBuffer_GS(nBufferIndex)
	
	local szBuffer = self.VAILD_CENTER_BUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	local tbLoadBuffer = GetGlobalSportBufTask(self.GA_INTBUF_GID, nBufferIndex);
	if tbLoadBuffer then
		local tbTmp = Lib:Str2Val(tbLoadBuffer);
		if type(tbTmp) == "table" then
			self[szBuffer] = tbTmp;
		end
	end
end

-- 清空中心服务器buffer
function Xkland:ClearCenterBuffer_GS(nBufferIndex)
	
	local szBuffer = self.VAILD_CENTER_BUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	self[szBuffer] = {};
end

-- gs启动事件
function Xkland:StartEvent_GS()
	
	if self:CheckIsGlobal() == 1 then
		for i = GBLINTBUF_XK_COMPETITIVE, GBLINTBUF_XK_CASTLE do
			self:LoadBuffer_GS(i);
		end
		if self.tbCastleBuffer.szPlayerName then
			self:UpdateCastleStatue_GS(self.tbCastleBuffer.szPlayerName, self.tbCastleBuffer.nPlayerSex, 1);
		end
	else
		for i = GBLINTBUF_XKL_GROUP, GBLINTBUF_XKL_CASTLE do
			self:LoadBuffer_GS(i);
		end
		if self.tbLocalCastleBuffer.szPlayerName then
			self:UpdateCastleStatue_GS(self.tbLocalCastleBuffer.szPlayerName, self.tbLocalCastleBuffer.nPlayerSex, 0);
		end
	end
	
	for nBufferIndex, _ in pairs(self.VAILD_CENTER_BUFFER) do
		self:LoadCenterBuffer_GS(nBufferIndex);
	end
	
	local tbThroneScore = {};
	local tbFile = Lib:LoadTabFile(self.THRONE_SCORE_PATH);
	for _, tbRow in pairs(tbFile or {}) do
		local nMinute = tonumber(tbRow.Minute);
		tbThroneScore[nMinute] = {};
		for i = 0, self.MAX_OCCUPY_DEATHS do
			local szTimes = string.format("Death%s", i);
			local nPoint = tbRow[szTimes] or 0;
			tbThroneScore[nMinute][i] = tonumber(nPoint);
		end
	end
	self.tbThroneScore = tbThroneScore;
end

-- 注册启动事件
--ServerEvent:RegisterServerStartFunc(Xkland.StartEvent_GS, Xkland);

-- 测试指令
function Xkland:_ShowPlayerLocalTask()
	me.Msg("复活点许可证："..me.GetTask(self.TASK_GID, self.TASK_PASSPORT));
	me.Msg("金币竞标数量："..me.GetTask(self.TASK_GID, self.TASK_COMP_COIN));
	me.Msg("本服军团编号："..me.GetTask(self.TASK_GID, self.TASK_WAR_GROUP));
	me.Msg("帮会名称："..me.GetTaskStr(self.TASK_GID, self.TASK_TONGNAME));
	me.Msg("连斩标志："..me.GetTask(self.TASK_GID, self.TASK_SERIES_KILL));
	me.Msg("参加的届数："..me.GetTask(self.TASK_GID, self.TASK_SESSION));
	me.Msg("已经兑换的箱子："..me.GetTask(self.TASK_GID, self.TASK_WAR_BOX));
end
