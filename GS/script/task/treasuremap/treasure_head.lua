
-- ====================== 文件信息 ======================

-- 剑侠世界藏宝图系统头文件
-- Edited by peres
-- 2008/01/10 PM 17:41

-- ======================================================
TreasureMap.szTreasurePosFilePath = "\\setting\\task\\treasuremap\\treasuremap_pos.txt";


TreasureMap.MAX_POSOFFSET				= 6;	-- 挖宝时的最大偏移量
TreasureMap.TreasureMapEntranceNpcId 	= 2679;	-- 入口npc模板Id

TreasureMap.nMuggerId					= 2689;	-- 藏宝贼模板Id
TreasureMap.nMuggerId_Level2			= 2690;	-- 藏宝贼模板Id（中级）
TreasureMap.nMuggerId_Level3			= 2756;	-- 藏宝贼模板Id（高级）

TreasureMap.nTreasureBoxId				= 2680;	-- 宝箱的模板Id
TreasureMap.nAdviceRange 				= 300;	-- 局部消息范围
TreasureMap.nTiredSkillId 				= 389;	-- 挖掘劳累buff
TreasureMap.nTiredDuration 				= 30 * Env.GAME_FPS;	-- 劳累持续时间
TreasureMap.tbBurrowSkill 				= {2010, 1};	-- 记录成功挖掘次数的任务变量
TreasureMap.ItemGenIdx_IsIdentify 		= 1;
TreasureMap.ItemGenIdx_nTreaaureId 		= 2;
TreasureMap.nTreasureBoxDropCount 		= 9;
TreasureMap.nDuoBaoZeiDropCount 		= 1;
TreasureMap.nInstancingCheckTime 		= Env.GAME_FPS;
TreasureMap.nMaxPlayer					= 6;

-- 野外带锁的宝箱掉落
TreasureMap.tbBaoXiangDropFilePath		= {
	[1] = "\\setting\\npc\\droprate\\treasuremap\\chujibaoxiang.txt",	--正常类型玩家
	[2] = "\\setting\\npc\\droprate\\treasuremap\\chujibaoxiang_act.txt",	--工作室玩家
	};
TreasureMap.tbBoxOutsideDrop			= {
	[1] = "\\setting\\npc\\droprate\\treasuremap\\level2\\box_outside.txt";--正常类型玩家
	[2] = "\\setting\\npc\\droprate\\treasuremap\\level2\\box_outside_act.txt";--工作室玩家
}
TreasureMap.tbBoxOutsideDrop_Level3		= {
	[1] = "\\setting\\npc\\droprate\\treasuremap\\level3\\box_outside.txt";--正常类型玩家
	[2] = "\\setting\\npc\\droprate\\treasuremap\\level3\\box_outside_act.txt";--工作室玩家
}

-- 产出超限后不在产出银两的掉落表
TreasureMap.tbDropWhenOverLimit =
{
	[1] = "\\setting\\npc\\droprate\\treasuremap\\chujibaoxiang_nomoney.txt",
	[2] = "\\setting\\npc\\droprate\\treasuremap\\level2\\box_outside_nomoney.txt",
	[3] = "\\setting\\npc\\droprate\\treasuremap\\level3\\box_outside_nomoney.txt",
};


-- 副本宝箱室内
TreasureMap.szBaoXiangShiNeiDropFilePath	= "\\setting\\npc\\droprate\\treasuremap\\fuben_obj.txt";
TreasureMap.szInstancingBox_Level3			= "\\setting\\npc\\droprate\\treasuremap\\level3\\box_inside.txt";

-- 夺宝贼的掉落
TreasureMap.szDuoBaoZeiDropFilePath		= "\\setting\\npc\\droprate\\treasuremap\\duobaozei.txt";
TreasureMap.szDuoBaoZeiDrop_Level2		= "\\setting\\npc\\droprate\\treasuremap\\level2\\duobaozei.txt";
TreasureMap.szDuoBaoZeiDrop_Level3		= "\\setting\\npc\\droprate\\treasuremap\\level3\\duobaozei.txt";

TreasureMap.szBossDropPath_1 = "\\setting\\npc\\droprate\\treasuremap\\boss.txt";

-- 中级藏宝图的 droprate
TreasureMap.tbDrop_Level_2	= {
	["Npc_Normal"]		= "\\setting\\npc\\droprate\\treasuremap\\level2\\duobaozei.txt",
	["Box_Outside"]		= "\\setting\\npc\\droprate\\treasuremap\\level2\\box_outside.txt",
	["Box_Inside"]		= "\\setting\\npc\\droprate\\treasuremap\\level2\\box_inside.txt",
	["Npc_Boss1"]		= "\\setting\\npc\\droprate\\treasuremap\\level2\\boss_normal.txt",
	["Npc_Boss2"]		= "\\setting\\npc\\droprate\\treasuremap\\level2\\boss_hard.txt",		
}

-- 高级藏宝图的 droprate
TreasureMap.tbDrop_Level_3	= {
	["Npc_Normal"]		= "\\setting\\npc\\droprate\\treasuremap\\level3\\duobaozei.txt",
	["Box_Outside"]		= "\\setting\\npc\\droprate\\treasuremap\\level3\\box_outside.txt",
	["Box_Inside"]		= "\\setting\\npc\\droprate\\treasuremap\\level3\\box_inside.txt",
	["Npc_Boss1"]		= "\\setting\\npc\\droprate\\treasuremap\\level3\\boss_normal.txt",
	["Npc_Boss2"]		= "\\setting\\npc\\droprate\\treasuremap\\level3\\boss_hard.txt",		
}

TreasureMap.szAwardTreaBoxPath		= "\\setting\\task\\treasuremap\\award_treabox.txt";
TreasureMap.szAwardTreaBox_Level2	= "\\setting\\task\\treasuremap\\award_treabox_level2.txt";
TreasureMap.szAwardTreaBox_Level3	= "\\setting\\task\\treasuremap\\award_treabox_level3.txt";

TreasureMap.tbAwardTreaBox	= {};	-- 精制宝箱的奖励概率

TreasureMap.TSKGID				= 2015;    	-- 任务变量 
TreasureMap.TSK_LIMITWEIWANG	= 1;		-- 保存威望周上限
TreasureMap.LIMITWEIWANG		= 30;		-- 威望周上限
TreasureMap.TSK_OPENBOX			= 40;		-- 记录玩家每周开箱子的次数

TreasureMap.TSK_OPEN_TREABOX_LIMIT	= 100;		-- 每天限制打开箱子的次数
TreasureMap.TSK_OPEN_TREABOX_DATE	= 101;		-- 限制日期

TreasureMap.TSK_INS_TASK_TAO		= 201;		-- 副本金钱任务（陶朱公疑冢）
TreasureMap.TSK_INS_TASK_DAMO		= 202;		-- 副本金钱任务（大漠古城）
TreasureMap.TSK_INS_TASK_QIANQIONG	= 203;		-- 副本金钱任务（千琼宫）
TreasureMap.TSK_INS_TASK_WANHUAGU	= 204;		-- 副本金钱任务（万花谷）

TreasureMap.MAXOPENTIME_PERWEEK		= 30;
TreasureMap.TSK_INS_TBTASK = 
{
	--        主人ID，队友ID，主任务ID，队友主任务ID
	[254]	= {201, 301, "DB", "159"},	-- 疑冢
	[272]	= {202, 302, "DC", "15A"},	-- 大漠
	[287]	= {203, 303, "E0", "15B"},	-- 千琼
	[344]	= {204, 304, "12D", "15C"},	-- 万花
}

TreasureMap.tbBurrowCostTime = 							-- 挖掘消耗的时间	
{
	{0, 10 * Env.GAME_FPS},
	{10, 8 * Env.GAME_FPS},
	{30, 6 * Env.GAME_FPS},
	{80, 4 * Env.GAME_FPS},
	{100, 3 * Env.GAME_FPS},
};

-- 贼的分布规则
TreasureMap.tbTreasureMuggerPos = 
{
	{0, -3},{-2, -2},{0, -2}, {1, -2}, {-2, -1}, {-1, -1}, {1, -1}, {2, -1}, {-2, 0}, {-1, 0}, {1, 0}, {2, 0}, {-1, 1}, {0, 1}, {1, 1}, {0, 3}
}

TreasureMap.nRecordBurrowMaxTime = 10000;
TreasureMap.tbTitleList		 =
{ 
	--{1000, {}},
}
-- 获得一个位置相对于玩家位置的大体方位和距离
function TreasureMap:GetDirection(tbOrigin, tbTarget)
	local tbStr = {"Tây Nam", "Nam", "Đông Nam", "Đông", "Đông Bắc", "Bắc", "Tây Bắc", "Tây"};
	
	local nX	= tbOrigin[2] - tbTarget[2];
	local nY	= tbTarget[1] - tbOrigin[1];
	
	local nDeg	= math.atan2(tbOrigin[2] - tbTarget[2], tbTarget[1] - tbOrigin[1]);
	local nDirection = math.floor(nDeg*4/math.pi+4.5);
	
	if (nDirection <= 0) then
		nDirection = nDirection + 8;
	end;
	
	-- 具体的距离，取整数
	local nDistance = math.floor(math.sqrt(nX*nX + nY*nY));
	
	return tbStr[nDirection], nDistance;
end;


-- 给附近的玩家发送一条信息
function TreasureMap:NotifyAroundPlayer(pPlayer, szMsg)
	local tbPlayerList = KPlayer.GetAroundPlayerList(pPlayer.nId, TreasureMap.nAdviceRange);
	if tbPlayerList then
		for _, player in ipairs(tbPlayerList) do
			player.Msg(szMsg);
		end
	end
end

-- 对副本各种剧情任务的处理
function TreasureMap:InstancingTask(pPlayer, MapId)
	if self.TSK_INS_TBTASK[MapId] then
		if pPlayer.GetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][1]) == 1 then
			pPlayer.SetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][1], 2, 1);
		end;
		
		if pPlayer.GetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][2]) == 1 then
			pPlayer.SetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][2], 2, 1);
		end;
	end;
end;

function TreasureMap:_Debug(...)
	print ("[Treasure Map]: ", unpack(arg));
end


