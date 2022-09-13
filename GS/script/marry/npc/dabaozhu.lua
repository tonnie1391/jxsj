-- FileName	: dabaozhu.lua
-- Author	: furuilei
-- Time		: 2010-1-22 15:59
-- Comment	: 游戏npc（大爆竹）

local tbNpc = Npc:GetClass("marry_dabaozhu");

--==============================================================

-- 大爆竹相关信息
tbNpc.nMaxRemainTime = 60;		-- 大爆竹最多倒计时时间（秒数）

-- 对应不同档次地图的npc模板
tbNpc.tbNpcId = {6565, 6565, 6565, 6565};
-- 刷出大爆竹的坐标
tbNpc.tbPos = {
	[1] = {1743, 3171},
	[2] = {1591, 3185},
	[3] = {1675, 3103},
	[4] = {1563, 3251},
	};

tbNpc.MAX_RANGE = 50;			-- 在活动结束的时候判断的爆竹周围的50范围

-- 不同倒计时的时候发出的信息
tbNpc.tbRemainTimeInfo = {
	[60] = "<color=yellow>距离开心大爆竹爆炸还有<color><color=gold>60秒<color><color=yellow>。爆竹周围聚集的人越多，烟花越绚烂！<color>",
	[30] = "<color=yellow>距离开心大爆竹爆炸还有<color><color=gold>30秒<color><color=yellow>。爆竹周围聚集的人越多，烟花越绚烂！<color>",
	[15] = "<color=yellow>距离开心大爆竹爆炸还有<color><color=gold>15秒<color><color=yellow>。爆竹周围聚集的人越多，烟花越绚烂！<color>",
	[10] = "<color=yellow>距离开心大爆竹爆炸还有<color><color=gold>10秒<color><color=yellow>。爆竹周围聚集的人越多，烟花越绚烂！<color>",
	[5] = "<color=yellow>距离开心大爆竹爆炸还有<color><color=gold>5秒<color><color=yellow>。爆竹周围聚集的人越多，烟花越绚烂！<color>",
	};
	
-- 不同人数时释放的技能信息
tbNpc.tbBaozhuSkill = {
	[1] = {nCount_MinPlayer = 1, nCount_MaxPlayer = 20, nSkillId = 1588, nExpRate = 20},
	[2] = {nCount_MinPlayer = 21, nCount_MaxPlayer = 50, nSkillId = 1589, nExpRate = 30},
	[3] = {nCount_MinPlayer = 51, nCount_MaxPlayer = 1000, nSkillId = 1570, nExpRate = 50},
	};

--==============================================================

-- 初始化，点燃爆竹
function tbNpc:OpenBaozhu(nMapId)
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(me.nMapId);
	local tbPos = self.tbPos[nWeddingMapLevel];
	local nNpcTemplateId = self.tbNpcId[nWeddingMapLevel];
	if (not tbPos or not nNpcTemplateId) then
		return 0;
	end
	
	local pNpc = KNpc.Add2(nNpcTemplateId, 120, -1, nMapId, unpack(tbPos));
	local tbNpcData = pNpc.GetTempTable("Marry") or {};
	tbNpcData.nRemainTime = self.nMaxRemainTime;
	
	Timer:Register(Env.GAME_FPS, self.OptNextSec, self, nMapId, pNpc.dwId);
end

-- 每秒判断要执行的操作
function tbNpc:OptNextSec(nMapId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	
	local tbNpcData = pNpc.GetTempTable("Marry") or {};
	local nRemainTime = tbNpcData.nRemainTime or 0;
	if (self.tbRemainTimeInfo[nRemainTime]) then
		Marry:SendMapMsg(nMapId, self.tbRemainTimeInfo[nRemainTime]);
	end
	
	if (0 == nRemainTime) then
		self:GameOver(nMapId, nNpcId);
		return 0;
	end
	
	tbNpcData.nRemainTime = tbNpcData.nRemainTime - 1;
end	

-- 倒计时结束，释放爆竹爆炸技能
function tbNpc:GameOver(nMapId, nNpcId)
	local tbSkillInfo = self:GetSkillInfo(nNpcId);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc or not tbSkillInfo) then
		return 0;
	end
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(nMapId);
	local tbPos = self.tbPos[nWeddingMapLevel];
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, self.MAX_RANGE);
	for _, pPlayer in pairs(tbPlayer) do
		pPlayer.AddExp(pPlayer.GetBaseAwardExp() * tbSkillInfo.nExpRate);
	end
	pNpc.Delete();
	
	local tbNpcList = KNpc.GetMapNpcWithName(nMapId, "福临门");
	if (#tbNpcList >= 1) then
		local nNpcIdx = tbNpcList[1];
		local pFuLinMen = KNpc.GetByIndex(nNpcIdx);
		pFuLinMen.CastSkill(tbSkillInfo.nSkillId, 1, unpack(tbPos));
	end
	
	Marry.MiniGame:NextStep(nMapId);
end

function tbNpc:GetSkillInfo(nNpcId)
	local tbPlayer, nPlayerNum = KNpc.GetAroundPlayerList(nNpcId, self.MAX_RANGE);
	for nLevel, tbInfo in ipairs(self.tbBaozhuSkill) do
		if (nPlayerNum >= tbInfo.nCount_MinPlayer and
			nPlayerNum <= tbInfo.nCount_MaxPlayer) then
			return tbInfo;
		end
	end
end

function tbNpc:OnDialog()
	Dialog:Say("开心大爆竹正在点燃，请快去聚集。");
end
