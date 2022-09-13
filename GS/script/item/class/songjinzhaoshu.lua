-----------------------------------------------------
--文件名		：	songjinzhaoshu.lua
--创建者		：	zongbeilei
--创建时间		：	2007-10-26
--功能描述		：	宋金诏书
------------------------------------------------------

local tbItemSongjinZhaoshu	= Item:GetClass("songjinzhaoshu");

tbItemSongjinZhaoshu.nTime	= 10;							-- 延时的时间(秒)
tbItemSongjinZhaoshu.tbCamp	= {"<color=orange>Báo danh phe Mông Cổ %s %s<color>", "<color=purple>Báo danh phe Tây Hạ %s %s<color>"};	-- 玩家的选项
tbItemSongjinZhaoshu.tbBattleSeq = {"", "", ""};
tbItemSongjinZhaoshu.tbItemId = 
{ 
	[27] = 1, --普通宋金诏书
	[86] = 0, --无限宋金诏书
	[195] = 0, --无限传送符（周）
	[235] = 0, --无限传送符（月）
};	-- 各种宋金诏书的Id,1为普通,0为无限传送符

-- OnUse函数中返回0表示该物品使用后不删除(无论能否正常使用都不会删除);返回1表示先在背包中删除再使用(无论能否正常使用都会先删除)
function tbItemSongjinZhaoshu:OnUse()
	local pPlayer = me;

	local nLevelId	= Battle:GetJoinLevel(pPlayer);	-- 能参加的宋金战役的等级(0玩家的等级不够不能参加,1初级,2中级,3高级)
	
	if (nLevelId == 0) then		-- 等级不够时,点击宋金诏书没有操作
		Dialog:Say("Đẳng cấp chưa đạt <color=green>60<color>, không thể vào!");
		return 0;
	end

	if (pPlayer.IsFreshPlayer() == 1) then
		Dialog:Say("你目前尚未加入门派，武艺不精，还是等加入门派后再来把！");
		return 0;
	end	
	
	--add by LQY 新战场入口
	local IsOpen = 0;
	for _, nOpen in pairs(NewBattle.tbNewBattleOpen[nLevelId]) do
		IsOpen = IsOpen + nOpen;
	end
	if IsOpen > 0 then
		self:SelectNewCamp(it.dwId, nLevelId, 0);
		-- me.Msg(""..nLevelId)
		return 0;
	end

	self:SelectCamp(it.dwId, nLevelId, 0);
	
	return 0;
end

-- add by LQY 新战场入口
-- 进入新战场报名点的入口
function tbItemSongjinZhaoshu:SelectNewCamp(nItemId, nLevelId, nWithOutItem)
	local tbOpt		= {};
	local szBattleMapName = Battle.NAME_GAMELEVEL[nLevelId]; 
	local nOpenCount = Battle:GetOpenCount(nLevelId, #NewBattle.tbNewBattleSeq[nLevelId]);
	local tbNewBattleSeq = NewBattle.tbNewBattleSeq[nLevelId];
	for j = 1,  nOpenCount do
		for i = 1, #self.tbCamp do
			local nMapId	= NewBattle.TB_MAP_BAOMING[nLevelId][j][i];				-- nMapId是被传送至的报名点的地图Id
			tbOpt[#tbOpt+1]	= {string.format(self.tbCamp[i], szBattleMapName, tbNewBattleSeq[j]), self.TransPlayer, self, nItemId, nMapId, 0, 1};	-- 赞一下,觉得table这样的用法很精妙
		end
	end
	tbOpt[#tbOpt + 1]	= {"Để ta suy nghĩ thêm"};	-- 退出
	local szMsgFmt	= "    Mông Cổ-Tây Hạ đại chiến đang diễn ra. Anh hùng hào kiệt hãy nhanh chân tham chiến để thể hiện bản lĩnh.\n";
	local nFlag		= 0;
	
	for i= 1, nOpenCount do
		local nSongnCampNum, nJinCampNum = Battle:GetPlayerCount(nLevelId, i);
		if (NewBattle.tbNewBattleOpen[nLevelId][i] ~= 1) then
			szMsgFmt	= szMsgFmt .. string.format("    Hiện tại <color=yellow>Mông Cổ-Tây Hạ<color> chưa bắt đầu ghi danh.\n");
		else	-- 报名已开始
			szMsgFmt	= szMsgFmt .. string.format("    Hiện tại <color=yellow>Mông Cổ-Tây Hạ<color> đã bắt đầu ghi danh.\n    <color=orange>Quân Mông Cổ: %d<color>\n    <color=purple>Quân Tây Hạ: %d<color>\n", nSongnCampNum + 1, nJinCampNum + 1);
			nFlag		= 1;
		end
	end
	
	if (nFlag == 1) then
		szMsgFmt = szMsgFmt .. "    Nếu chênh lệch số lượng 2 bên quá cao, bên có số lượng người tham gia nhiều hơn tạm thời không thể báo danh."
	end
	szMsgFmt = szMsgFmt .. " Ngươi muốn đến doanh trại phe nào?";
	Dialog:Say(szMsgFmt, tbOpt);
end

-- 功能:	玩家选择阵营
-- 参数:	nLevelId 参加哪个等级的宋金战役(nLevelId >= 1 && nLevelId <= 3)
function tbItemSongjinZhaoshu:SelectCamp(nItemId, nLevelId, nWithOutItem)
	local tbOpt		= {};
	local szBattleMapName				= Battle.NAME_GAMELEVEL[nLevelId]; 

	local nOpenCount = Battle:GetOpenCount(nLevelId, #Battle.MAPID_LEVEL_CAMP[nLevelId]);
	for j = 1,  nOpenCount do
		for i = 1, #self.tbCamp do
			local nMapId	= Battle.MAPID_LEVEL_CAMP[nLevelId][j][i];				-- nMapId是被传送至的报名点的地图Id
			tbOpt[#tbOpt+1]	= {string.format(self.tbCamp[i], szBattleMapName, self.tbBattleSeq[j]), self.TransPlayer, self, nItemId, nMapId, nWithOutItem};	-- 赞一下,觉得table这样的用法很精妙
		end
	end
	tbOpt[#tbOpt + 1]	= {"Để ta suy nghĩ thêm"};	-- 退出
	local szMsgFmt	= "    Mông Cổ-Tây Hạ đại chiến đang diễn ra. Anh hùng hào kiệt hãy nhanh chân tham chiến để thể hiện bản lĩnh.\n";
	local nFlag		= 0;
	
	for i=1, nOpenCount do
		local nSongnCampNum, nJinCampNum 	= Battle:GetPlayerCount(nLevelId, i);
		if (nSongnCampNum < 0 or not Battle.szLastMapName) then	-- 未开始报名时
			szMsgFmt	= szMsgFmt .. string.format("Hiện tại <color=yellow>%s %s<color> chưa thể đăng ký.\n", szBattleMapName, self.tbBattleSeq[i]);
		else	-- 报名已开始
			szMsgFmt	= szMsgFmt .. string.format("Hiện tại <color=yellow>%s %s<color> đã có thể đăng ký.\n<color=orange>Quân Mông Cổ: %d<color>；<color=purple>Quân Tây Hạ: %d<color>。\n", szBattleMapName, self.tbBattleSeq[i], nSongnCampNum, nJinCampNum);
			nFlag		= 1;
		end
	end
	if (nFlag == 1) then
		szMsgFmt = szMsgFmt .. "Nếu chênh lệch số lượng 2 bên quá cao, bên có số lượng người tham gia nhiều hơn tạm thời không thể báo danh."
	end
	szMsgFmt = szMsgFmt .. " Ngươi muốn đến doanh trại phe nào?";
	Dialog:Say(szMsgFmt, tbOpt);
end

-- 功能:	传送玩家去报名点
-- 参数:	nMapId 要传至的报名点的Id
function tbItemSongjinZhaoshu:TransPlayer(nItemId, nMapId, nWithOutItem, bNewBattle)
	local pPlayer = me;
	local tbEvent	= {						-- 会中断延时的事件
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	};
	if (0 == pPlayer.nFightState) then				-- 玩家在非战斗状态下传送无延时正常传送
		self:TransPlayerSucessFul(nItemId, nMapId, pPlayer.nId, nWithOutItem, bNewBattle);
		return 0;
	end

	GeneralProcess:StartProcess("Đang truyền tống...", self.nTime * Env.GAME_FPS, {self.TransPlayerSucessFul, self, nItemId, nMapId, pPlayer.nId, nWithOutItem, bNewBattle}, nil, tbEvent);	-- 在战斗状态下需要nTime秒的延时
end

function tbItemSongjinZhaoshu:TransPlayerSucessFul(nItemId, nMapId, nPlayerId, nWithOutItem, bNewBattle)
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer == nil then
		return 0;
	end
	local pItem = nil;
	if nWithOutItem ~= 1 then -- 跟道具无关不需要判断道具
		pItem = KItem.GetObjById(nItemId);
		if pItem == nil then
			pPlayer.Msg("您使用的宋金诏书已被删除，非法操作出现异常，请于GM联系。");
			return 0; 
		end	
		if self.tbItemId[pItem.nParticular] == nil then
			pPlayer.Msg("没有该宋金诏书，请于GM联系。");
			return 0;
		end
		--如果是普通宋金诏书，则删除
		if self.tbItemId[pItem.nParticular] == 1 then
			
			local nCount = pItem.nCount;
			if nCount <= 1 then
				if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
					pPlayer.Msg("删除宋金诏书失败！");
					return 0;
				end
			else
				pItem.SetCount(nCount - 1); 
			end
		end
	end
	
	if bNewBattle == 1 then
		local nLevelId	= Battle:GetJoinLevel(pPlayer);
		pPlayer.SetFightState(0);
		pPlayer.NewWorld(nMapId, unpack(NewBattle:GetRandomPoint(NewBattle.POS_BAOMING)));
		return;
	end
	Battle:EnterRegistPlace(nMapId, nPlayerId);
end

