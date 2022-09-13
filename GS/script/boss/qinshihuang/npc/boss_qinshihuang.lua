-------------------------------------------------------
-- 文件名　：boss_qinshihuang.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-11 19:56:05
-- 文件描述：
-------------------------------------------------------

-- 配置文件("\\setting\\npc\npc.txt")

-- 记录日志
local function WriteStateLog(tbItem)
	
	-- 列清单
	local nCount = 0;
	for _, nItemId in pairs(tbItem or {}) do
		local pItem = KItem.GetObjById(nItemId);
		if (pItem) then				
			if (pItem.SzGDPL() == string.format("%d,%d,%d,%d", unpack(Boss.Qinshihuang.tbDropStone))) then
				nCount = nCount + 1;
			end
		end
	end
		
	-- 记录日志
	if (nCount > 0) then
		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "huangling", 0, string.format("%d_%d_%d_%d", unpack(Boss.Qinshihuang.tbDropStone)), nCount);
	end
end

-------------------------------------------------------
-- 秦始皇boss
local tbQinshihuangBoss	= Npc:GetClass("boss_qinshihuang");

-- 对话事件
function tbQinshihuangBoss:OnDialog()
	me.Msg("……");
end

-- 掉落物品回调
function tbQinshihuangBoss:DeathLoseItem(tbLoseItem)
	
	local tbItem = tbLoseItem.Item;
	local tbList = {};
	
	-- 列清单
	local nCount = 0;
	local bDropStone = 0;			-- 是否掉落石头公告秦始皇的身份
	for _, nItemId in pairs(tbItem or {}) do
		local pItem = KItem.GetObjById(nItemId);
		if pItem then
			local szName = pItem.szName;					
			if not tbList[szName] then
				tbList[szName] = 1;
			else
				tbList[szName] = tbList[szName] + 1;
			end
		end
		nCount = nCount + 1;
		-- 写死，没时间弄了
		if (pItem.SzGDPL() == string.format("%d,%d,%d,%d", unpack(Boss.Qinshihuang.tbDropStone))) then
			bDropStone = 1;
		end
	end
	
	local szMsg = "";
	if nCount >= 32 then
		szMsg = string.format("<color=yellow>恭喜您！%s就是真正的秦始皇！\n", him.szName);
	else
		szMsg = string.format("<color=yellow>很遗憾！%s不是真正的秦始皇！\n", him.szName);
	end
	if (bDropStone == 0) then
		szMsg = szMsg .. string.format("<color=green>%s掉落了物品：<color>\n", him.szName);
	else
		szMsg = string.format("<color=green>%s掉落了物品：<color>\n", him.szName);
	end
	
	for szItemName, nCount in pairs(tbList or {}) do
		szMsg = szMsg .. "<color=yellow>" .. szItemName .. " - " .. nCount .. "个<color>\n";
		StatLog:WriteStatLog("stat_info", "qingling", "boss_drop", 0, szItemName, nCount);
	end
	
	Boss.Qinshihuang:BroadCast(Boss.Qinshihuang.MSG_CHANNEL, szMsg);
	
	-- 记录日志	
	if (bDropStone == 1) then
		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "huangling", 0, string.format("%d_%d_%d_%d", unpack(Boss.Qinshihuang.tbDropStone)), nCount);
	end
end

-- 死亡事件
function tbQinshihuangBoss:OnDeath(pNpcKiller)
	
	-- 关键之处：清除召唤表
	Boss.tbUniqueBossCallOut[him.nTemplateId] = nil;

	local nMapId = him.GetWorldPos();
	local nIndex = Boss.Qinshihuang.tbMapIndex[nMapId];
	
	-- 动态掉落表
	local nReal = 0;
	local nPlayerId = pNpcKiller.GetPlayer() and pNpcKiller.GetPlayer().nId or 0;
	if nMapId == Boss.Qinshihuang.tbBoss.nRealMap then
		local tbBoss = Boss.Qinshihuang.tbBoss[nIndex];
		nReal = 1;
		him.DropRateItem(Boss.Qinshihuang.BIG_BOSS_DROP_FILE, 32, -1, -1, nPlayerId);
		-- todo zjq 因为额外掉落只有宝石，所以通过宝石开关来控制，如果其他系统要用到额外掉落表，需要另外处理
		if (Item.tbStone:GetOpenDay() ~= 0) then
			-- 额外掉落，宝石
			him.DropRateItem(Boss.Qinshihuang.EXTERN_DROP_BIGBOSS[1], Boss.Qinshihuang.EXTERN_DROP_BIGBOSS[2], -1, -1, nPlayerId);			
		end
	else
		him.DropRateItem(Boss.Qinshihuang.SMALL_BOSS_DROP_FILE, 16, -1, -1, nPlayerId);
		-- todo zjq 因为额外掉落只有宝石，所以通过宝石开关来控制，如果其他系统要用到额外掉落，需要另外处理
		if (Item.tbStone:GetOpenDay() ~= 0) then
			-- 额外掉落，宝石
			him.DropRateItem(Boss.Qinshihuang.EXTERN_DROP_SMALLBOSS[1], Boss.Qinshihuang.EXTERN_DROP_SMALLBOSS[2], -1, -1, nPlayerId)
		end
	end
	
	-- 清除传送NPC和信息
	if nIndex then
		Boss.Qinshihuang:ClearInfo(nIndex);
	end
	
	-- 找到玩家
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end	
	
	-- 增加威望
	local nTeamId = pPlayer.nTeamId;
	if nTeamId == 0 then
		pPlayer.AddKinReputeEntry(5, "boss_qinshihuang");
	else
		local tbPlayerId, nMemberCount = KTeam.GetTeamMemberList(nTeamId);
		for i, nPlayerId in pairs(tbPlayerId) do
			local pTeamPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if (pTeamPlayer and pTeamPlayer.nMapId == him.nMapId) then
				pTeamPlayer.AddKinReputeEntry(5, "boss_qinshihuang");
			end
		end
	end
	
	-- 频道公告
	local szMsg = "Hảo hữu ["..pPlayer.szName.."] đã đánh bại "..him.szName..".";
	pPlayer.SendMsgToFriend(szMsg);
	Player:SendMsgToKinOrTong(pPlayer, " đã đánh bại "..him.szName..".", 0);
	
	local szMsg = string.format("Tổ đội <color=green>%s<color> đánh bại %s!", pPlayer.szName, him.szName);
	Boss.Qinshihuang:BroadCast(Boss.Qinshihuang.MSG_CHANNEL, szMsg);
	
	if nReal == 1 then
		local szMsg = string.format("Tổ đội <color=green>%s<color> đánh bại Tần Thủy Hoàng thật!!!", pPlayer.szName);
		Boss.Qinshihuang:BroadCast(Boss.Qinshihuang.MSG_TOP, szMsg);
	end
	
	-- 股份和荣誉
	local nStockBaseCount = 1500;
	local nHonor = 20;

	--增加建设资金和帮主、族长、个人的股份
	Tong:AddStockBaseCount_GS1(pPlayer.nId, nStockBaseCount, 0.1, 0.5, 0.1, 0.1, 0.3);	
	
	-- 额外奖励回调
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("QinlingBoss", pPlayer);
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	
	-- 队友共享
	local tbMember = pPlayer.GetTeamMemberList();
	if tbMember then
		for _, pMember in ipairs(tbMember) do
			if pMember.nId ~= pPlayer.nId then		
				Tong:AddStockBaseCount_GS1(pMember.nId, nStockBaseCount, 0.1, 0.5, 0.1, 0.1, 0.3);
				local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("QinlingBoss", pMember);
				SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
			end
		end
	end
	
	-- 增加族长和帮主的领袖荣誉
	local nKinId , nMemberId = pPlayer.GetKinMember();	
	local pKin = KKin.GetKin(nKinId);
	local pTong = KTong.GetTong(pPlayer.dwTongId);
	
	if pTong then
		
		-- 增加帮主的领袖荣誉
		local nMasterId = Tong:GetMasterId(pPlayer.dwTongId);
		if nMasterId ~= 0 then	
			PlayerHonor:AddPlayerHonorById_GS(nMasterId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonor);
		end
		
		-- 增加非帮主族长的领袖荣誉			
		local pKinItor = pTong.GetKinItor()
		local nKinInTongId = pKinItor.GetCurKinId();
		while (nKinInTongId > 0) do
			local pKinInTong = KKin.GetKin(nKinInTongId);
			local nCaptainId = Kin:GetPlayerIdByMemberId(nKinInTongId, pKinInTong.GetCaptain());
			if nMasterId ~= nCaptainId then
				PlayerHonor:AddPlayerHonorById_GS(nCaptainId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonor/2);
			end
			nKinInTongId = pKinItor.NextKinId();
		end
		
	elseif pKin then
		
		-- 增加无帮会族长的领袖荣誉
		local nCaptainId = Kin:GetPlayerIdByMemberId(nKinId, pKin.GetCaptain());
		PlayerHonor:AddPlayerHonorById_GS(nCaptainId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonor/2);
	end

	local szTongName = "无帮会";
	local szBossName = "秦始皇" .. ((nReal == 1) and "（真）" or "（假）");
	local szKillPlayerName = pPlayer.szName;
	local pTong = KTong.GetTong(pPlayer.dwTongId);
	if pTong then
		szTongName = pTong.GetName();
	end
	
	DataLog:WriteELog(szKillPlayerName, 2, 1, him.nTemplateId);
	Dbg:WriteLog("[BossDeath]", szBossName, szKillPlayerName, szTongName);
end

-- 血量触发
function tbQinshihuangBoss:OnLifePercentReduceHere(nLifePercent)
	
	local pNpc = him;
	local nMapId = pNpc.GetWorldPos();
	if not Boss.Qinshihuang.tbBossPos[nMapId] then
		return 0;
	end
	
	local nMapX = Boss.Qinshihuang.tbBossPos[nMapId][2];
	local nMapY = Boss.Qinshihuang.tbBossPos[nMapId][3];
	local nIndex = Boss.Qinshihuang.tbMapIndex[nMapId];

	if nLifePercent == 80 then
		
		if Boss.Qinshihuang:GetBossStep(nIndex) == 0 then

			local szMsg = "寡人，累了。";
			pNpc.SendChat(szMsg);
			Boss.Qinshihuang:BroadCast(Boss.Qinshihuang.MSG_CHANNEL, string.format("%s说道：%s", pNpc.szName, szMsg));
						
			-- 增加对话Npc
			local pTempNpc = KNpc.Add2(2450, 120, -1, nMapId, nMapX, nMapY);
			
			-- 记录一些状态
			Boss.Qinshihuang:OnProtectBoss(nIndex, pTempNpc.dwId, 1, pNpc.GetDamageTable());
		
			-- 增加4个兵马桶
			KNpc.Add2(2439, 120, -1, nMapId, nMapX - 15, nMapY);
			KNpc.Add2(2439, 120, -1, nMapId, nMapX + 15, nMapY);
			KNpc.Add2(2439, 120, -1, nMapId, nMapX, nMapY - 15);
			KNpc.Add2(2439, 120, -1, nMapId, nMapX, nMapY + 15);
			
			-- 增加两个传送npc
--			if nMapId == 1540 then		
--				local pNpc1 = KNpc.Add2(2456, 120, -1, 1539, 1609, 3899);
--				local pNpc2 = KNpc.Add2(2457, 120, -1, 1539, 1985, 3532);
--				Boss.Qinshihuang.tbBoss.nPassId1 = pNpc1.dwId;
--				Boss.Qinshihuang.tbBoss.nPassId2 = pNpc2.dwId;
--			end
			
			pNpc.Delete();
		end
		
	elseif nLifePercent == 50 then
		
		if Boss.Qinshihuang:GetBossStep(nIndex) == 1 then

			local szMsg = "你们，再陪远来的客人们玩一会。";
			pNpc.SendChat(szMsg);
			Boss.Qinshihuang:BroadCast(Boss.Qinshihuang.MSG_CHANNEL, string.format("%s说道：%s", pNpc.szName, szMsg));
						
			-- 增加对话Npc
			local pTempNpc = KNpc.Add2(2450, 120, -1, nMapId, nMapX, nMapY);
			
			-- 记录一些状态
			Boss.Qinshihuang:OnProtectBoss(nIndex, pTempNpc.dwId, 2, pNpc.GetDamageTable());
			
			-- 增加4个招魂师
			KNpc.Add2(2440, 120, -1, nMapId, nMapX - 15, nMapY);
			KNpc.Add2(2440, 120, -1, nMapId, nMapX + 15, nMapY);
			KNpc.Add2(2440, 120, -1, nMapId, nMapX, nMapY - 15);
			KNpc.Add2(2440, 120, -1, nMapId, nMapX, nMapY + 15);
			
			pNpc.Delete();
		end
		
	elseif nLifePercent == 20 then
		
		if Boss.Qinshihuang:GetBossStep(nIndex) == 2 then
			
			local szMsg = "寡人，要休息了，你们走吧……";
			pNpc.SendChat(szMsg);
			Boss.Qinshihuang:BroadCast(Boss.Qinshihuang.MSG_CHANNEL, string.format("%s说道：%s", pNpc.szName, szMsg));
			
			-- 增加对话Npc
			local pTempNpc = KNpc.Add2(2450, 120, -1, nMapId, nMapX, nMapY);
			
			-- 记录一些状态
			Boss.Qinshihuang:OnProtectBoss(nIndex, pTempNpc.dwId, 3, pNpc.GetDamageTable());
			
			-- 增加2个兵马桶，2个招魂师
			KNpc.Add2(2439, 120, -1, nMapId, nMapX - 15, nMapY);
			KNpc.Add2(2439, 120, -1, nMapId, nMapX + 15, nMapY);
			KNpc.Add2(2440, 120, -1, nMapId, nMapX, nMapY - 15);
			KNpc.Add2(2440, 120, -1, nMapId, nMapX, nMapY + 15);
				
			pNpc.Delete();
		end
	end
end

-------------------------------------------------------
-- 兵马俑
local tbBingmayong = Npc:GetClass("boss_bingmayong");

function tbBingmayong:OnDeath(pNpcKiller)
	local nMapId = him.GetWorldPos();
	local nIndex = Boss.Qinshihuang.tbMapIndex[nMapId];
	if nIndex then
		Boss.Qinshihuang:AddDeathCount(nIndex);
	end
	local pPlayer = pNpcKiller.GetPlayer();
	if pPlayer then
		DataLog:WriteELog(pPlayer.szName, 2, 1, him.nTemplateId);
	end
end

-------------------------------------------------------
-- 招魂师
local tbZhaohunshi = Npc:GetClass("boss_zhaohunshi");
function tbZhaohunshi:OnDeath(pNpcKiller)
	local nMapId = him.GetWorldPos();
	local nIndex = Boss.Qinshihuang.tbMapIndex[nMapId];
	if nIndex then
		Boss.Qinshihuang:AddDeathCount(nIndex);
	end
	local pPlayer = pNpcKiller.GetPlayer();
	if pPlayer then
		DataLog:WriteELog(pPlayer.szName, 2, 1, him.nTemplateId);
	end
end

-------------------------------------------------------
-- 精英
local tbJingying = Npc:GetClass("boss_qinjingying");
function tbJingying:OnDeath(pNpcKiller)
	
	Boss.tbUniqueBossCallOut[him.nTemplateId] = nil;
	
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	
	-- 额外奖励回调
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("QinlingBoss", pPlayer);
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	
	-- 队友共享
	local tbMember = pPlayer.GetTeamMemberList();
	if tbMember then
		for _, pMember in ipairs(tbMember) do
			if pMember.nId ~= pPlayer.nId then		
				local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("QinlingBoss", pMember);
				SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
			end
		end
	end
	DataLog:WriteELog(pPlayer.szName, 2, 1, him.nTemplateId);
end

function tbJingying:ExternDropOnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		return;
	end
	-- todo zjq 因为额外掉落只有宝石，所以通过宝石开关来控制，如果其他系统要用到额外掉落，需要另外处理
	if (Item.tbStone:GetOpenDay() == 0) then
		return;
	end
	him.SetLoseItemCallBack(1);
	him.DropRateItem(Boss.Qinshihuang.EXTERN_DROP_JINYING[1], Boss.Qinshihuang.EXTERN_DROP_JINYING[2], -1, -1, pPlayer.nId);
	him.SetLoseItemCallBack(0);
end

function tbJingying:DeathLoseItem(tbLoseItem)	
	WriteStateLog(tbLoseItem.Item);
end

-------------------------------------------------------
-- 小boss
local tbSmallBoss = Npc:GetClass("boss_qinlingsmall");
function tbSmallBoss:OnDeath(pNpcKiller)
	
	Boss.tbUniqueBossCallOut[him.nTemplateId] = nil;
	
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	
	-- 额外奖励回调
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("QinlingBoss", pPlayer);
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	
	-- 队友共享
	local tbMember = pPlayer.GetTeamMemberList();
	if tbMember then
		for _, pMember in ipairs(tbMember) do
			if pMember.nId ~= pPlayer.nId then		
				local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("QinlingBoss", pMember);
				SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
			end
		end
	end
	
	pPlayer.SendMsgToFriend("Hảo hữu ["..pPlayer.szName.."] đã đánh bại "..him.szName..".");
	Player:SendMsgToKinOrTong(pPlayer, " đã đánh bại "..him.szName..".", 0);
	Boss.Qinshihuang:BroadCast(Boss.Qinshihuang.MSG_CHANNEL, string.format("<color=green>%s<color> đã đánh bại %s!", pPlayer.szName, him.szName));
	
	local szTongName = "无帮会";
	local szBossName = him.szName;
	local szKillPlayerName = pPlayer.szName;
	local pTong = KTong.GetTong(pPlayer.dwTongId);
	if pTong then
		szTongName = pTong.GetName();
	end
	
	DataLog:WriteELog(szKillPlayerName, 2, 1, him.nTemplateId);
	Dbg:WriteLog("[BossDeath]", szBossName, szKillPlayerName, szTongName);	
end

function tbSmallBoss:ExternDropOnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		return;
	end
	-- todo zjq 因为额外掉落只有宝石，所以通过宝石开关来控制，如果其他系统要用到额外掉落，需要另外处理
	if (Item.tbStone:GetOpenDay() == 0) then
		return;
	end
	him.SetLoseItemCallBack(1);
	him.DropRateItem(Boss.Qinshihuang.EXTERN_DROP_SMALLBOSS[1], Boss.Qinshihuang.EXTERN_DROP_SMALLBOSS[2], -1, -1, pPlayer.nId);
	him.SetLoseItemCallBack(0);
end

function tbSmallBoss:DeathLoseItem(tbLoseItem)
	WriteStateLog(tbLoseItem.Item);	
end

-------------------------------------------------------
-- 每层小头目
local tbFloorLeader = Npc:GetClass("floorleader_qinling");
function tbFloorLeader:OnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		return;
	end
	-- todo zjq 因为额外掉落只有宝石，所以通过宝石开关来控制，如果其他系统要用到额外掉落，需要另外处理
	if (Item.tbStone:GetOpenDay() == 0) then
		return;
	end
	him.SetLoseItemCallBack(1);
	-- 一层的不掉落宝石
	if him.nTemplateId == 2431 then			-- 二层头目，百夫长（跟三层的同名不同NPC）
		him.DropRateItem(Boss.Qinshihuang.EXTERN_DROP_LEADER_FLOOR2[1], Boss.Qinshihuang.EXTERN_DROP_LEADER_FLOOR2[2], -1, -1, pPlayer.nId);
	elseif him.nTemplateId == 2434 then		-- 三层头目，百夫长（跟二层的同名不同NPC）
		him.DropRateItem(Boss.Qinshihuang.EXTERN_DROP_LEADER_FLOOR3[1], Boss.Qinshihuang.EXTERN_DROP_LEADER_FLOOR3[2], -1, -1, pPlayer.nId);
	elseif him.nTemplateId == 2437 then		-- 四层头目，巨灵战士
		him.DropRateItem(Boss.Qinshihuang.EXTERN_DROP_LEADER_FLOOR4[1], Boss.Qinshihuang.EXTERN_DROP_LEADER_FLOOR4[2], -1, -1, pPlayer.nId);
	end		
	him.SetLoseItemCallBack(0);
end

function tbFloorLeader:DeathLoseItem(tbLoseItem)	
	WriteStateLog(tbLoseItem.Item);
end
