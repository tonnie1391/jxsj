-- 文件名  : jiayao_npc.lua
-- 创建者  : zhongjunqi
-- 创建时间: 2011-06-14 09:52:57
-- 描述    : 三周年庆 佳肴活动，菜的npc，桌子就不用了

if  not MODULE_GAMESERVER then
	return;
end

local tbNpc = Npc:GetClass("jiayao_npc");

--=======================================================
SpecialEvent.ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011 or {};
local ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011;


-- 桌子npc配置
tbNpc.nUseTimes			= 10;		-- 每个桌子可以使用10次
tbNpc.nProgress			= 90;		-- 吃菜读条花费5秒 5*18

-- 检测玩家是否可以吃这个菜
function tbNpc:CheckCanEat()
	if (me.nLevel < ZhouNianQing2011.nPlayerLevelLimit or me.nFaction <= 0) then
		return 0, "只有达到60级并且加入门派的玩家才能享用。";
	end

	if (me.CountFreeBagCell() < 1) then
		return 0, "Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!";
	end
	local tbNpcData = him.GetTempTable("SpecialEvent");
	if (tbNpcData[me.nId]) then
		return 0, "这桌宴席你已经品尝过了。";
	end
	if (tbNpc.nUseTimes <= Lib:CountTB(tbNpcData)) then
		return 0, "这桌宴席已经被享用完了。";
	end
	local nFlag = Player:CheckTask(ZhouNianQing2011.TASKGID, ZhouNianQing2011.TASK_JIAYAO_DATE, "%Y%m%d", 
									ZhouNianQing2011.TASK_JIAYAO_COUNT, ZhouNianQing2011.nCanEatTimesPerDay);
	if (nFlag == 0) then
		return 0, "你今天已经享用过"..ZhouNianQing2011.nCanEatTimesPerDay.."次宴席了，不能再多吃，改天再来。";
	end
	return 1;
end

function tbNpc:OnDialog()
	-- 检测活动状态
	if (ZhouNianQing2011.bIsOpen ~= 1) then
		return;
	end
	-- 检测玩家是否可以吃菜
	local bRet, szMsg = self:CheckCanEat();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		return;
	end
	-- 开始进度条计时
	local tbEvent = {
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	GeneralProcess:StartProcess("享用周年庆佳肴", tbNpc.nProgress, {self.OnProgressFull, self, me.nId, him.dwId}, nil, tbEvent);
end

-- 吃菜读条结束
function tbNpc:OnProgressFull(dwPlayerId, dwNpcId)
	-- 记录菜npc的被吃次数
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pNpc) then
		return Dialog:Say("这桌宴席已经被享用完了。");
	end
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if (not pPlayer) then
		return;
	end
	Setting:SetGlobalObj(pPlayer, pNpc)
	local bRet, szMsg = self:CheckCanEat();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		Setting:RestoreGlobalObj();
		return;
	end
	
	local tbNpcData = pNpc.GetTempTable("SpecialEvent");
	tbNpcData[dwPlayerId] = 1;
	
	--  给玩家奖励
	me.AddExp(math.floor(me.GetBaseAwardExp() * 60));		-- 经验
	local nRnd = MathRandom(1, 100);
	if (nRnd <= 8) then			-- 侠客令
		me.AddItemEx(18, 1, 1233, 1, {bForceBind = 1}, Player.emKITEMLOG_TYPE_JOINEVENT);
		StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 6, 1);
	elseif (nRnd <= 17) then	-- 六玄
		me.AddItemEx(18, 1, 1, 6, {bForceBind = 1}, Player.emKITEMLOG_TYPE_JOINEVENT);
		StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 4, 6);
	elseif (nRnd <= 25) then		-- 绑银
		me.AddBindMoney(50000, Player.emKITEMLOG_TYPE_JOINEVENT);
		StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 2, 50000);
	else					-- 绑金
		me.AddBindCoin(300, Player.emKITEMLOG_TYPE_JOINEVENT);
		StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 1, 300);
	end
	
	-- 记录玩家吃菜
	pPlayer.SetTask(ZhouNianQing2011.TASKGID, ZhouNianQing2011.TASK_JIAYAO_COUNT, 
					pPlayer.GetTask(ZhouNianQing2011.TASKGID, ZhouNianQing2011.TASK_JIAYAO_COUNT) + 1);
	StatLog:WriteStatLog("stat_info", "cele_3year", "join", me.nId, 2);
	-- 记录吃光状态
	if (tbNpc.nUseTimes <= Lib:CountTB(tbNpcData)) then
		ZhouNianQing2011:OnJiaYaoDeath(pNpc.dwId);
		pNpc.Delete();
	end
	Setting:RestoreGlobalObj();
end

