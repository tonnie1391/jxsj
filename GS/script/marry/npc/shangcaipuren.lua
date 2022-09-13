-- 文件名　：shangcaipuren.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-14 17:26:50
-- 功能描述：上菜仆人

local tbNpc = Npc:GetClass("marry_shangcaipuren");

--=======================================================


tbNpc.SUM_DISH_COUNT = 12;	-- 最多12道菜
tbNpc.MAX_DISH_COUNT = 10	-- 每个npc多提供10道菜
tbNpc.TIME_PER_DISH = 60;	-- 每道菜上菜时间是60秒，之后就是下一道菜了

tbNpc.tbPosPath = {
	[1] = "\\setting\\marry\\shangcaipuren1.txt", -- 平民婚礼地图的上菜坐标
	[2] = "\\setting\\marry\\shangcaipuren2.txt", -- 贵族婚礼地图的上菜坐标
	[3] = "\\setting\\marry\\shangcaipuren3.txt", -- 王侯婚礼地图的上菜坐标
	[4] = "\\setting\\marry\\shangcaipuren4.txt", -- 皇家婚礼地图的上菜坐标
	};

tbNpc.tbShangcaiPurenId = {
	[1] = 6551,
	[2] = 6552,
	[3] = 6553,
	[4] = 6554,
	[5] = 6555,
	[6] = 6556,
	[7] = 6557,
	[8] = 6558,
	[9] = 6559,
	[10] = 6560,
	[11] = 6561,
	[12] = 6562,
	};

tbNpc.tbDishInfo = {
	[1] = {
		[1] = {szName = "全家欢乐", tbGDPL = {18, 1, 601, 1}},
		[2] = {szName = "比翼双飞", tbGDPL = {18, 1, 601, 2}},
		[3] = {szName = "万事如意", tbGDPL = {18, 1, 601, 3}},
		[4] = {szName = "琴瑟和鸣", tbGDPL = {18, 1, 601, 4}},
		[5] = {szName = "心想事成", tbGDPL = {18, 1, 601, 5}},
		[6] = {szName = "福星高照", tbGDPL = {18, 1, 601, 6}},
		[7] = {szName = "大鹏展翅", tbGDPL = {18, 1, 601, 7}},
		[8] = {szName = "万里奔腾", tbGDPL = {18, 1, 601, 8}},
		[9] = {szName = "甜甜蜜蜜", tbGDPL = {18, 1, 601, 9}},
		[10] = {szName = "欢欢喜喜", tbGDPL = {18, 1, 601, 10}},
		[11] = {szName = "热热闹闹", tbGDPL = {18, 1, 601, 11}},
		[12] = {szName = "圆圆满满", tbGDPL = {18, 1, 601, 12}},
		},
	[2] = {
		[1] = {szName = "全家欢乐", tbGDPL = {18, 1, 600, 1}},
		[2] = {szName = "比翼双飞", tbGDPL = {18, 1, 600, 2}},
		[3] = {szName = "万事如意", tbGDPL = {18, 1, 600, 3}},
		[4] = {szName = "琴瑟和鸣", tbGDPL = {18, 1, 600, 4}},
		[5] = {szName = "心想事成", tbGDPL = {18, 1, 600, 5}},
		[6] = {szName = "福星高照", tbGDPL = {18, 1, 600, 6}},
		[7] = {szName = "大鹏展翅", tbGDPL = {18, 1, 600, 7}},
		[8] = {szName = "万里奔腾", tbGDPL = {18, 1, 600, 8}},
		[9] = {szName = "甜甜蜜蜜", tbGDPL = {18, 1, 600, 9}},
		[10] = {szName = "欢欢喜喜", tbGDPL = {18, 1, 600, 10}},
		[11] = {szName = "热热闹闹", tbGDPL = {18, 1, 600, 11}},
		[12] = {szName = "圆圆满满", tbGDPL = {18, 1, 600, 12}},
		},
	[3] = {
		[1] = {szName = "全家欢乐", tbGDPL = {18, 1, 599, 1}},
		[2] = {szName = "比翼双飞", tbGDPL = {18, 1, 599, 2}},
		[3] = {szName = "万事如意", tbGDPL = {18, 1, 599, 3}},
		[4] = {szName = "琴瑟和鸣", tbGDPL = {18, 1, 599, 4}},
		[5] = {szName = "心想事成", tbGDPL = {18, 1, 599, 5}},
		[6] = {szName = "福星高照", tbGDPL = {18, 1, 599, 6}},
		[7] = {szName = "大鹏展翅", tbGDPL = {18, 1, 599, 7}},
		[8] = {szName = "万里奔腾", tbGDPL = {18, 1, 599, 8}},
		[9] = {szName = "甜甜蜜蜜", tbGDPL = {18, 1, 599, 9}},
		[10] = {szName = "欢欢喜喜", tbGDPL = {18, 1, 599, 10}},
		[11] = {szName = "热热闹闹", tbGDPL = {18, 1, 599, 11}},
		[12] = {szName = "圆圆满满", tbGDPL = {18, 1, 599, 12}},
		},
	[4] = {
		[1] = {szName = "全家欢乐", tbGDPL = {18, 1, 596, 1}},
		[2] = {szName = "比翼双飞", tbGDPL = {18, 1, 596, 2}},
		[3] = {szName = "万事如意", tbGDPL = {18, 1, 596, 3}},
		[4] = {szName = "琴瑟和鸣", tbGDPL = {18, 1, 596, 4}},
		[5] = {szName = "心想事成", tbGDPL = {18, 1, 596, 5}},
		[6] = {szName = "福星高照", tbGDPL = {18, 1, 596, 6}},
		[7] = {szName = "大鹏展翅", tbGDPL = {18, 1, 596, 7}},
		[8] = {szName = "万里奔腾", tbGDPL = {18, 1, 596, 8}},
		[9] = {szName = "甜甜蜜蜜", tbGDPL = {18, 1, 596, 9}},
		[10] = {szName = "欢欢喜喜", tbGDPL = {18, 1, 596, 10}},
		[11] = {szName = "热热闹闹", tbGDPL = {18, 1, 596, 11}},
		[12] = {szName = "圆圆满满", tbGDPL = {18, 1, 596, 12}},
		},
	}
	
--=======================================================

function tbNpc:GetShangcaiPos(nMapLevel)
	if (not self.tbPosPath[nMapLevel]) then
		return;
	end
	local tbPosSetting = Lib:LoadTabFile(self.tbPosPath[nMapLevel]);
	
	local tbPos = {};
	-- 加载上菜坐标列表
	for nRow, tbRowData in pairs(tbPosSetting) do
		local tbTemp = {};
		tbTemp[1] = tonumber(tbRowData["PosX"]);
		tbTemp[2] = tonumber(tbRowData["PosY"]);
		table.insert(tbPos, tbTemp);
	end
	return tbPos;
end

function tbNpc:GetCurDishNum(nMapId)
	return Marry:GetFoodStep(nMapId) or 0;
end

function tbNpc:SetCurDishNum(nMapId, nNum)
	Marry:SetFoodStep(nMapId, nNum);
end

function tbNpc:Init(nMapId)
	local tbShangcaiPos = self:GetShangcaiPos(Marry:GetWeddingMapLevel(nMapId)) or {};
	if (#tbShangcaiPos == 0) then
		return 0;
	end
	
	self:SetCurDishNum(nMapId, 1);
	local nCurDishNum = 0;
	for _, tbPos in pairs(tbShangcaiPos) do
		local pNpc = KNpc.Add2(self.tbShangcaiPurenId[1], 120, -1, nMapId, unpack(tbPos));
		if (pNpc) then
			pNpc.SetLiveTime(self.TIME_PER_DISH * Env.GAME_FPS);
			local tbNpcData = him.GetTempTable("Marry");
			tbNpcData.nCurDishCount = 0;
			nCurDishNum = tbNpcData.nCurDishCount;
		end
	end
	
	local tbPlayerList, _ = KPlayer.GetMapPlayer(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
	local szTimerPanelMsg = string.format("<color=Gold>第%s道菜：距下道菜<color>", nCurDishNum + 1);
		Dialog:SetTimerPanel(pPlayer, szTimerPanelMsg, self.TIME_PER_DISH - 2);
	end
	
	Timer:Register(self.TIME_PER_DISH * Env.GAME_FPS, self.NextDish, self, nMapId, tbShangcaiPos)
end

function tbNpc:NextDish(nMapId, tbShangcaiPos)
	local nLastIndex = self:GetCurDishNum(nMapId);
	if self.tbShangcaiPurenId[nLastIndex] then
		ClearMapNpcWithTemplateId(nMapId, self.tbShangcaiPurenId[nLastIndex]);
	end
	local nCurDishNum = nLastIndex + 1;
	if (nCurDishNum > self.SUM_DISH_COUNT) then
		return 0;
	end
	self:SetCurDishNum(nMapId, nCurDishNum);
	
	for _, tbPos in pairs(tbShangcaiPos) do
		local pNpc = KNpc.Add2(self.tbShangcaiPurenId[nCurDishNum], 120, -1, nMapId, unpack(tbPos));
		if (pNpc) then
			pNpc.SetLiveTime(self.TIME_PER_DISH * Env.GAME_FPS);
			local tbNpcData = him.GetTempTable("Marry");
			tbNpcData.nCurDishCount = 0;
		end
	end
	
	local tbPlayerList, _ = KPlayer.GetMapPlayer(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		local szTimerPanelMsg = string.format("<color=Gold>第%s道菜：距下道菜<color>", nCurDishNum);
		Dialog:SetTimerPanel(pPlayer, szTimerPanelMsg, self.TIME_PER_DISH - 2);
	end
	
	return self.TIME_PER_DISH * Env.GAME_FPS;
end

function tbNpc:CanGetDish()
	local szErrMsg = "";
	local nCurDishNum = self:GetCurDishNum(me.nMapId);
	local nMyDishCount = Marry:GetDinner(me.nMapId, me.szName);
	if (nMyDishCount >= nCurDishNum) then
		szErrMsg = "这道菜你已经品尝过了，请不要重复食用。";
		return 0, szErrMsg;
	end
	
	local tbNpcData = him.GetTempTable("Marry");
	tbNpcData.nCurDishCount = tbNpcData.nCurDishCount or 0;
	if (tbNpcData.nCurDishCount >= self.MAX_DISH_COUNT) then
		szErrMsg = "这道菜已经被领完了。";
		return 0, szErrMsg;
	end
	
	if (me.CountFreeBagCell() < 1) then
		szErrMsg  = "请清理出1格背包空间再来领取菜肴。";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local bCanGetDish, szErrMsg = self:CanGetDish();
	if (0 == bCanGetDish) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local nCurDishCount = self:GetCurDishNum(me.nMapId);
	local nWeddingLevel = Marry:GetWeddingLevel(me.nMapId);
	local tbInfo = self.tbDishInfo[nWeddingLevel][nCurDishCount];
	if (tbInfo) then
		local pItem = me.AddItem(unpack(tbInfo.tbGDPL));
		if (pItem) then
			local nCurDishNum = self:GetCurDishNum(me.nMapId);
			Marry:SetDinner(me.nMapId, me.szName, nCurDishNum);
			
			-- 记录每个npc当前发放了多少道菜
			local tbNpcData = him.GetTempTable("Marry");
			tbNpcData.nCurDishCount = tbNpcData.nCurDishCount or 0;
			tbNpcData.nCurDishCount = tbNpcData.nCurDishCount + 1;
		end
	end
end
