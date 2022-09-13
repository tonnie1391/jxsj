
-- 藏宝图
local tbItem = Item:GetClass("treasuremap");
tbItem.IdentifyDuration = Env.GAME_FPS * 10;

tbItem.tbLevelLimit	= {
	[1] = 20,
	[2]	= 50,
	[3]	= 70,	
}

-- 不同等级对应藏宝图挖出后果不同的概率
--tbItem.tbAwardRate	= {
--	[1]	= {0, 93, 7},
--	[2]	= {0, 95, 5},
--	[3]	= {0, 94, 2, 4},
--}


function tbItem:InitGenInfo()
	if (MODULE_GAMESERVER) then
		it.SetGenInfo(TreasureMap.ItemGenIdx_IsIdentify, 0);
		local tbTreasure = TreasureMap:GetTreasureTableInfo(it.nLevel);
		local nRandomIdx = MathRandom(#tbTreasure);
		it.SetGenInfo(TreasureMap.ItemGenIdx_nTreaaureId, tbTreasure[nRandomIdx].TreasureId);
		it.Sync();
	end
end



function tbItem:OnUse()
	local nTreasureId 		= it.GetGenInfo(TreasureMap.ItemGenIdx_nTreaaureId); -- 所对应宝藏的编号
	local nIdentify 		= it.GetGenInfo(TreasureMap.ItemGenIdx_IsIdentify);	-- 是否是辨认过的藏宝图
	local tbTreasureInfo	= TreasureMap:GetTreasureInfo(nTreasureId);
	local nMapId			= tbTreasureInfo.MapId;
	
	local nMapLevel			= tbTreasureInfo.Level;
	
	if me.nLevel < self.tbLevelLimit[nMapLevel] then
		Dialog:SendInfoBoardMsg(me, "<color=red>Hiện tại cấp của bạn chưa đủ để mở Tàng Bảo Đồ này!<color>");
		return;
	end;
	
	if (not nMapId or nMapId <= 0) then
		TreasureMap:_Debug("Không tồn tại bản đồ tàng bảo tương ứng!", nTreasureId, nMapId);
		assert(false);
		return 0;
	end
	local szMapName			= GetMapNameFormId(nMapId)
	if (nIdentify == 0) then
		Dialog:Say("Đây là Tàng Bảo Đồ số <color=yellow>"..szMapName.."<color>, bạn phải phân biệt được Tàng Bảo Đồ mới biết được vị trí của kho báu.\n\n",
			{"Bắt đầu đọc", self.IdentifyTreasureMap, self, me, nTreasureId, it},
			{"Đóng"}
			);
	elseif (nIdentify == 1) then
		local szPosDesc = tbTreasureInfo.Desc;
		local szPic = "<pic:"..tbTreasureInfo.Pic..">";
		Dialog:Say(szPic.."Đây là Tàng Bảo Đồ số <color=yellow>"..szMapName.."<color>, trên đó hiển thị vị trí Tàng Bảo Đồ ở <color=yellow>"..szPosDesc.."<color>, bạn có thể dùng <color=yellow>La bàn bán ở các tiệm tạp hóa<color> để biết vị trí Tàng Bảo Đồ này đánh dấu.\n\n",
		{"Bắt đầu đào", self.BurrowTreasure, self, me, nTreasureId, it},
		{"Đóng"}
		);
	else
		assert(false);
	end
	
	return 0;
end

-- 辨认
function tbItem:IdentifyTreasureMap(pPlayer, nTreasureId, pTreasureMap)
	-- TODO: liuchang 玩家身上有绘制过的地图册
	
	local tbEvent = 
	{
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	
	-- TODO: liuchang pTreasureMap 得做保护，不能直接传对象，要传Id 
	GeneralProcess:StartProcess("Đang đọc...", self.IdentifyDuration, {self.SuccessIdentify, self, pPlayer.nId, pTreasureMap.dwId}, nil, tbEvent);
end

-- 辨认成功
function tbItem:SuccessIdentify(nPlayerId, nItemId)
	local pTreasureMap = KItem.GetObjById(nItemId);
	if (MODULE_GAMESERVER) then
		pTreasureMap.SetGenInfo(TreasureMap.ItemGenIdx_IsIdentify, 1);
		pTreasureMap.Sync();
	end
end


-- 挖掘
function tbItem:BurrowTreasure(pPlayer, nTreasureId, pTreasureMap)
	-- TODO: liuchang
	if (pPlayer.nTeamId == 0) then
		pPlayer.Msg("Chỉ có tổ đội mới có thể đào kho báu!");
		return;
	end
	
	local tbEvent = 
	{
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	
	local nBurrowTimes = pPlayer.GetTask(TreasureMap.tbBurrowSkill[1], TreasureMap.tbBurrowSkill[2]);
	local nBurrowCostTime = 10 * Env.GAME_FPS;
	for i = 1, #TreasureMap.tbBurrowCostTime do
		if (nBurrowCostTime >= TreasureMap.tbBurrowCostTime[i][1]) then
			nBurrowCostTime = TreasureMap.tbBurrowCostTime[i][2];
		else
			break;
		end
	end

	GeneralProcess:StartProcess("Đào kho báu", nBurrowCostTime, {self.AccomplishBurrow, self, pPlayer.nId, nTreasureId, pTreasureMap.dwId}, {pPlayer.Msg, "Bị gián đoạn khi đào."}, tbEvent);
end


-- 完成挖掘
function tbItem:AccomplishBurrow(nPlayerId, nTreasureId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pTreasureMap = KItem.GetObjById(nItemId);
	if (not pTreasureMap) then
		return;
	end
	if (pPlayer.nTeamId == 0) then
		pPlayer.Msg("Chỉ có tổ đội mới có thể đào!");
		return;
	end
	local nMyMapId, nMyPosX, nMyPosY	= pPlayer.GetWorldPos();
	local tbTreasureInfo	= TreasureMap:GetTreasureInfo(nTreasureId);
	local nDestMapId 		= tbTreasureInfo.MapId;
	local nDestPosX			= tbTreasureInfo.MapX;
	local nDestPosY			= tbTreasureInfo.MapY;
	
	local _, nDistance = TreasureMap:GetDirection({nMyPosX, nMyPosY}, {nDestPosX, nDestPosY})
	if (nDistance > TreasureMap.MAX_POSOFFSET or nMyMapId ~= nDestMapId) then
		self:ErrorTreasurePos(pPlayer, nTreasureId, pTreasureMap);
	else
		self:SuccessBurrowTreasure(pPlayer, nTreasureId, pTreasureMap);
	end
end


-- 挖掘失败
function tbItem:ErrorTreasurePos(pPlayer, nTreasureId, pTreasureMap)
	pPlayer.Msg("Bạn đào mãi ở đây, không đào được gì...");
end

-- 挖掘成功
function tbItem:SuccessBurrowTreasure(pPlayer, nTreasureId, pTreasureMap)
	assert(pPlayer)
	local tbTreasureInfo	= TreasureMap:GetTreasureInfo(nTreasureId);
	local nMapLevel			= tbTreasureInfo.Level;
	
	local nMapId, nPosX, nPosY	= pPlayer.GetWorldPos();
	local szTypeMsg = "";
	
	local nRet = pTreasureMap.Delete(pPlayer);
	if (not nRet or nRet ~= 1) then
		pPlayer.Msg("Bạn chưa có Tàng bảo đồ chỉ định!");
		return;
	end	
	
--	local tbBurrowAward		= self.tbAwardRate[nMapLevel];

	--local nRandom = MathRandom(100);
	local nId = 0;
	-- 取消藏宝图的令牌产出
	--[[local nLingpaiLevel =  TreasureMap2:GetWabaoLingPaiLevel(pPlayer);
	if TreasureMap2.LINGPAI_WABAO[nLingpaiLevel] then
		for i, tbAward in ipairs(TreasureMap2.LINGPAI_WABAO[nLingpaiLevel]) do
			if tbAward.nPro >= nRandom then
				nId = i;
				break;
			end
			nRandom = nRandom - tbAward.nPro;
		end
	end	
	]]--
	local nValue = pPlayer.GetTask(TreasureMap.tbBurrowSkill[1], TreasureMap.tbBurrowSkill[2]);
	nValue = nValue + 1;
	if (nValue > TreasureMap.nRecordBurrowMaxTime) then
		nValue = TreasureMap.nRecordBurrowMaxTime;
	end
	pPlayer.SetTask(TreasureMap.tbBurrowSkill[1], TreasureMap.tbBurrowSkill[2], nValue);
	
	if nId == 0 then
		-- 宝箱
		TreasureMap:AddTreasureBox(pPlayer, nTreasureId);
	
		-- 再给开出箱子的玩家加一个精致的盒子
		local pItem = pPlayer.AddItem(18, 1, 290, nMapLevel, 0, 0, 0, nil, nil, 0, 0, Player.emKITEMLOG_TYPE_STOREHOUSE);
		if pItem then		
			szTypeMsg = " đào được 1 <color=red>Bảo rương cổ<color>!";
		end
	end
	
	
	if nId ~= 0 and  me.CountFreeBagCell() > 0 then
		local pItem = me.AddItem(unpack(TreasureMap2.LINGPAI_WABAO[nLingpaiLevel][nId].tbItem));
		if pItem then
			pItem.Bind(1);
			me.Msg(string.format("Bạn nhận được 1 <color=yellow>%s<color>!",pItem.szName));
			szTypeMsg = string.format("Nhận được 1 <color=yellow>%s<color>!",pItem.szName);
			TreasureMap2:WriteLog("Tình hình sản xuất lệnh bài",string.format("%s, %s, tìm kho báu, 1" ,me.szName,pItem.szName));
			Dialog:SendBlackBoardMsg(me, string.format("Tìm được %s, mang về cho Quan Quân Nhu (nghĩa quân)!",pItem.szName));
			-- 保质期 15 天
			--me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600 * 24 * 15));
			pItem.Sync();
		end
	end
		
	local szMapName	= GetMapNameFormId(nMapId);
	local nShowX = math.ceil(nPosX/8);
	local nShowY = math.ceil(nPosY/16);
	local szMsg = pPlayer.szName.." tại <color=yellow>"..szMapName.."<color>"..szTypeMsg;
	
	TreasureMap:AwardWeiWangAndXinde(pPlayer, 0, 5, 1, 100000);
	
	-- 通知附近的玩家
	TreasureMap:NotifyAroundPlayer(pPlayer, szMsg);
	
	-- 记录挖宝次数
	local nNum = pPlayer.GetTask(StatLog.StatTaskGroupId , 3) + 1;
	pPlayer.SetTask(StatLog.StatTaskGroupId , 3, nNum);
	-- 添加好友亲密度
	local tbTeamList = pPlayer.GetTeamMemberList();
	TreasureMap:AddFriendFavor(tbTeamList, nMapId, 4);
	
	-- 师徒成就：挖掘藏宝图
	self:GetAchievement(tbTeamList, nMapId, nMapLevel);
	
	-- 增加玩家参加挖宝活动的计数
	Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_CANGBAOTU, 1, 1);
	
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 37);		--挖掘藏宝图活跃度
end

function tbItem:GetAchievement(tbTeamList, nMapId, nMapLevel)
	if (not tbTeamList or not nMapId or nMapId <= 0) then
		return;
	end
	local nAchievementId = 0;
	if (1 == nMapLevel) then
		nAchievementId = Achievement_ST.CANGBAOTU_CHUJI;		-- 成就：初级藏宝图
	elseif (2 == nMapLevel) then
		nAchievementId = Achievement_ST.CANGBAOTU_ZHONGJI;		-- 成就：中级藏宝图
	elseif (3 == nMapLevel) then
		nAchievementId = Achievement_ST.CANGBAOTU_GAOJI;		-- 成就：高级藏宝图
	end
	TreasureMap:GetAchievement(tbTeamList, nAchievementId, nMapId)
end


function tbItem:GetTip()
	local nTreasureId 	= it.GetGenInfo(TreasureMap.ItemGenIdx_nTreaaureId);
	local nIdentify 	= it.GetGenInfo(TreasureMap.ItemGenIdx_IsIdentify);
	local nItemLevel	= it.nLevel;
	
	local tbInfo	= TreasureMap:GetTreasureInfo(nTreasureId);
	
	if not tbInfo then
		-- return "<color=red>错误的藏宝图信息，请检查你的客户端是否为最新！<color>";
		return "Tàng Bảo Đồ\n\nTấm bản đồ này được vẽ trên tấm da dê cũ nát";
	end;
	
	local tbLevelString		= {[1] = "Tàng bảo đồ (sơ)", [2] = "Tàng bảo đồ (trung)", [3] = "Tàng bảo đồ (cao)"};
	local nMapId			= tbInfo.MapId;
	local szMapName			= GetMapNameFormId(nMapId);
	local szImage			= tbInfo.Pic;
	local szPosDesc 		= tbInfo.Desc;
	
	local szIdentify 	= "<color=red>(chưa giám định)<color>";
	
	if nIdentify == 1 then
		szIdentify	= "<color=green>(đã giám định)<color>";
	end;
	
	local szMain	= "";
	szMain	= szMain.."1 Tàng Bảo Đồ ở "..szMapName.."."..szIdentify.."\n\n";
	szMain	= szMain.."<color=white>"..tbLevelString[nItemLevel].."<color>\n\n";
	
	if nIdentify == 1 then
		szMain	= szMain.."Đây là Tàng Bảo Đồ số <color=yellow>"..szMapName.."<color>, trên đó hiển thị vị trí Tàng Bảo Đồ ở <color=yellow>"..szPosDesc.."<color>.\n";
	else
		szMain	= szMain.."Đây là Tàng Bảo Đồ số <color=yellow>"..szMapName.."<color>, bạn có thể dùng <color=yellow>La bàn bán ở các tiệm tạp hóa<color> để biết vị trí Tàng Bảo Đồ này đánh dấu.\n";
	end;
	
	return szMain;
end
