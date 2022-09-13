-------------------------------------------------------
-- 文件名　：marry_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 00:02:36
-- 文件描述：
-------------------------------------------------------

-- system switch
Marry.OPEN_STATE				= EventManager.IVER_bOpenMarry;		-- 系统开关

-- task group
Marry.TASK_GROUP_ID 			= 2114;		-- 任务变量组

-- task marry
Marry.TASK_QINGHUA_DAILY		= 1;		-- 每日获得情花数量	
Marry.TASK_CANCEL_QIUHUN		= 2; 		-- 申请解除求婚时间
Marry.TASK_QIUHUN_NAME			= 3;		-- 8位名字(3-10)

-- task item
Marry.TASK_TIME_XUANYAN			= 11;		-- 上次发表宣言的时间
Marry.TASK_TIME_RESELECTDATE	= 12;		-- 重新选择婚礼日期的次数
Marry.TASK_COUPLE_LEVEL			= 13;		-- 姻缘等级
Marry.TASK_GET_WEDDIGN_HORSE	= 14;		-- 是否领取了婚姻坐骑
Marry.TASK_CUR_DISH_COUNT		= 15;		-- 玩家当前领过了第几道菜
Marry.TASK_EXP_RATE				= 16;		-- 打怪经验倍率
Marry.TASK_GET_WEDDING_RING		= 17;		-- 是否领取了结婚戒指
Marry.TASK_WEDDING_LEVEL		= 18;		-- 婚礼档次（1~4对应平民~皇家）
Marry.TASK_RESERVE_DATE			= 19;		-- 预订的婚礼日期（年月日）
Marry.TASK_RESERVE_MAPLEVEL		= 20;		-- 预订的婚礼场地等级
Marry.TASK_GET_WEDDING_TITLE	= 21;		-- 是否领取了结婚称号（称号会附带光环）
Marry.TASK_DATE_GETBUFF			= 22;		-- 玩家上次领取祝福的日期（从城市或新手村的管家出领取）
Marry.TASK_GM_INTELVAL 			= 23;		-- gm道具使用间隔
Marry.TASK_DIVORCE_QUALITY		= 24;		-- 离婚资格
Marry.TASK_DIVORCE_INTERVAL		= 25;		-- 离婚间隔
Marry.TASK_DIVORCE_TIMES		= 26;		-- 离婚次数

-- const
Marry.MAX_QINGHUA_DAILY			= 4;		-- 每日情花获得上限
Marry.MAX_DIVORCE_TIMES			= 4;		-- 离婚扣物品倍数上限

-- item
Marry.ITEM_QINGHUA_ID			= {18, 1, 597, 1};	-- 情花物品Id
Marry.ITEM_YAOQINGHAN_ID		= {18, 1, 591, 1};	-- 邀请函物品Id
Marry.ITEM_HUABAN_ID			= {22, 1, 95, 1};	-- 花瓣Id
Marry.ITEM_GM_ID				= {18, 1, 615, 1};	-- gm道具

-- 平民 + 贵族 = 30
Marry.MAX_MAP_APPLY 			= 30;
Marry.MAX_MAP_LEVEL1			= 20;
Marry.MAX_MAP_LEVEL2			= 10;
Marry.MAX_SERVER				= 7;
Marry.MAX_MAP_PLAYER			= 200;

-- 解除求婚费用
Marry.CANCEL_QIUHUN_COST		= 100000;
Marry.SINGLE_QIUHUN_COST		= 200000;

-- 系统开启时间
Marry.START_TIME				= 201002021200;

-- 模板地图
Marry.MAP_TEMPLATE_INFO =
{
	[1] = {494, 1622, 3313},	-- 平民
	[2] = {495, 1480, 3280},	-- 贵族
	[3] = {496, 1594, 3184},	-- 王侯
	[4] = {497, 1501, 3371},	-- 皇家
};

-- 地图名字
Marry.MAP_LEVEL_NAME = 
{
	[1] = "Hiệp Sĩ Danh Cư",
	[2] = "Trang Viên Quý Tộc",
	[3] = "Bãi Biển Vương Hầu",
	[4] = "Hoàng Gia Tiên Cảnh",
};

-- 婚礼等级
Marry.WEDDING_LEVEL_NAME = 
{
	[1] = "Lễ cưới Hiệp Sĩ",
	[2] = "Lễ cưới Quý Tộc",
	[3] = "Lễ cưới Vương Hầu",
	[4] = "Lễ cưới Hoàng Gia",
};

-- 参观地图
Marry.MAP_PREVIEW_INFO =
{
	[1] = {498, 1622, 3313},
	[2] = {499, 1480, 3280},
	[3] = {500, 1594, 3184},
	[4] = {575, 1501, 3371},
};

-- 准备场坐标
Marry.MAP_SIGNUP_POS = 
{
	[1] = {576, 1580, 3468},
	[2] = {577, 1580, 3468},
	[3] = {578, 1580, 3468},
	[4] = {579, 1580, 3468},
	[5] = {580, 1580, 3468},
	[6] = {581, 1580, 3468},
	[7] = {582, 1580, 3468},
};

-- 传送点名字
Marry.MAP_TRAP_NAME = 
{
	[1] = "trap_in_match_%d",	
	[2] = "trap_in_stage_%d",
}

-- 传送点坐标
Marry.MAP_TRAP_POS = 
{
	[1] = {{1640, 3285, 1}, {1756, 3159, 4}},
	[2] = {{1500, 3279, 1}, {1598, 3179, 4}},
	[3] = {{1626, 3151, 1}, {1686, 3092, 4}},
	[4] = {{1506, 3366, 1}, {1583, 3223, 4}},
}

-- 婚礼台子中心坐标
Marry.MAP_STAGE_POS =
{
	[1] = {1763, 3150},
	[2] = {1603, 3171},
	[3] = {1695, 3084},
	[4] = {1591, 3215},
}

-- 仪式右侧信息
Marry.PERFORM_STEP = 
{
	[1] = "<color=orange>Xin ý kiến Cát Tường mở lễ<color>",
	[2] = "<color=orange>Buổi lễ bắt đầu, chờ đợi thực khách<color>",
	[3] = "<color=orange>Tiếp tục chờ đợi để thờ phượng<color>",
	[4] = "<color=orange>Bái đường, chờ tiệc<color>",
	[5] = "<color=orange>Tiệc rượu, trò chơi, kết thúc<color>",
}

-- 婚姻称号
Marry.TITLE_ID = 
{
	[1] = {13, 1, 1, 0},
	[2] = {13, 1, 2, 0},
};

-- 补偿道具
Marry.TB_COMPENSATION = {
	[1] = {tbGDPL = {18, 1, 613, 1}, nCount = 1},
	[2] = {tbGDPL = {18, 1, 613, 1}, nCount = 4},
	[3] = {tbGDPL = {18, 1, 613, 1}, nCount = 16},
	[4] = {tbGDPL = {18, 1, 613, 1}, nCount = 64},
	};

-- 城市刷npc点
Marry.MARRY_NPC_POS_PATH = "\\setting\\marry\\marry_npc_pos.txt";

-- mission列表(以动态地图id为索引)
Marry.tbMissionList = Marry.tbMissionList or {};

-- mission info列表，gc加载并同步给gs，记录全局婚礼名字、等级、日期等，下标索引
Marry.tbMissionInfo = Marry.tbMissionInfo or {};

-- mission map列表，gs加载动态地图后回调给gc，保存全局动态地图id
Marry.tbMissionMap = Marry.tbMissionMap or {};

-- 用来保存申请数据 nWeddingLevel
--Marry.tbGlobalBuffer = 
--{
--	[1] = {[20091201] = {[1] = {szMaleName, szFemaleName, nMapLevel}, ...}, ...},
--	[2] = {[20091201] = {[1] = {szMaleName, szFemaleName, nMapLevel}, ...}, ...},
--	[3] = {[20091201] = {szMaleName, szFemaleName, nMapLevel}, ...},
--	[4] = {[20091201] = {szMaleName, szFemaleName, nMapLevel}, ...},
--}
Marry.tbGlobalBuffer = Marry.tbGlobalBuffer or {[1] = {}, [2] = {},	[3] = {}, [4] = {}};

-- 存放待解除求婚关系的名字
Marry.tbProposalBuffer = Marry.tbProposalBuffer or {};

-- 合服婚期数据备份
Marry.tbCozoneBuffer = Marry.tbCozoneBuffer or {[1] = {}, [2] = {},	[3] = {}, [4] = {}};

-- 待离婚的名字
Marry.tbDivorceBuffer = Marry.tbDivorceBuffer or {};

-- 系统开关
function Marry:CheckState()
	return self.OPEN_STATE;
end

Marry.nLiJinAllSum = 0;
Marry.tbGblBuffer_Lijin = Marry.tbGblBuffer_Lijin or {};

-- 判断是否能预定
function Marry:CheckAddWedding(nWeddingLevel, nDate)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 侠士婚礼
	if nWeddingLevel == 1 then
		local nCount = 0;
		for nIndex, tbInfo in pairs(self.tbGlobalBuffer[nWeddingLevel][nDate] or {}) do
			if type(tbInfo) == "table" then
				nCount = nCount + 1;
			end
		end
		if nCount >= self.MAX_MAP_LEVEL1 then
			return 0;
		end
		return 1;
	
	-- 贵族婚礼
	elseif nWeddingLevel == 2 then
		local nCount = 0;
		for nIndex, tbInfo in pairs(self.tbGlobalBuffer[nWeddingLevel][nDate] or {}) do
			if type(tbInfo) == "table" then
				nCount = nCount + 1;
			end
		end
		if nCount >= self.MAX_MAP_LEVEL2 then
			return 0;
		end
		return 1;
		
	-- 王侯婚礼
	elseif nWeddingLevel == 3 then
		if self.tbGlobalBuffer[nWeddingLevel][nDate] then
			return 0;
		end
		return 1;
	
	-- 皇家婚礼	
	elseif nWeddingLevel == 4 then
		if self.tbGlobalBuffer[nWeddingLevel][nDate] then
			return 0;
		end
		local nTime = Lib:GetDate2Time(nDate);
		local tbTime = os.date("*t", nTime);
		for i = 1, 7 do
			local nTmpDay = 0;
			if tbTime.wday > 2 then
				nTmpDay = i + 2;
			else
				nTmpDay = i - 5;
			end

			local nTmpDate = tonumber(os.date("%Y%m%d", nTime + nTmpDay * 24 * 3600 - tbTime.wday * 24 * 3600));
			if self.tbGlobalBuffer[nWeddingLevel][nTmpDate] then
				return 0;
			end
		end
		return 1;
	end
		
	return 0;
end

-- 判断是否预订过婚期
function Marry:CheckPreWedding(szName)
	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		for nDate, tbRow in pairs(tbMap) do
			if nWeddingLevel <= 2 then
				for nIndex, tbInfo in pairs(tbRow) do
					if szName == tbInfo[1] then
						return 1, tbInfo[2], nDate, nWeddingLevel, tbInfo[3];
					elseif szName == tbInfo[2] then
						return 1, tbInfo[1], nDate, nWeddingLevel, tbInfo[3];
					end
				end
			else
				if szName == tbRow[1] then
					return 1, tbRow[2], nDate, nWeddingLevel, tbRow[3];
				elseif szName == tbRow[2] then
					return 1, tbRow[1], nDate, nWeddingLevel, tbRow[3];
				end
			end
		end
	end
	return 0;
end
