-------------------------------------------------------
-- 文件名　：kuozhanqunpc.lua
-- 文件描述：海陵王墓 扩展区
-- 创建者　：ZhangDeheng
-- 创建时间：2009-04-14 10:43:10
-------------------------------------------------------

--传送
local tbMiDao = Npc:GetClass("hl_midao");

function tbMiDao:OnDialog()
	Dialog:Say("是否进入", 
			{
				{"是", self.Enter, self, him.dwId, me.nId},
				{"暂不进入"},
			}
		);	
end;

function tbMiDao:Enter(dwId, nId)
	local pNpc = KNpc.GetById(dwId);
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (not pNpc or not pPlayer) then
		return;
	end;
	local tbNpcData = pNpc.GetTempTable("Task");
	local nNo = tbNpcData.nHongLianDiYu;
	if (not nNo) then
		return;
	end;
	if (nNo == 1) then
		pPlayer.NewWorld(me.nMapId, 53696 / 32, 115104 / 32);
	elseif (nNo == 2) then
		pPlayer.NewWorld(me.nMapId, 52288 / 32, 109760 / 32);
	elseif (nNo == 3) then
		pPlayer.NewWorld(me.nMapId, 54144 / 32, 124160 / 32);
	end;
	
end;

-- 扩展区1
local tbQiHun = Npc:GetClass("hl_qihun");

tbQiHun.szDesc	= "棋魂";
tbQiHun.szText 	= "棋盘变化，奥妙无穷，世间万物，包罗其中，来来来，我们下盘棋。";

function tbQiHun:OnDialog()
	Dialog:Say(self.szText, 
			{
				{"开始", self.FightStart, self, him.dwId, me.nId},
				{"Kết thúc đối thoại"},
			}
		);
end;

function tbQiHun:FightStart(dwId, nId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	local pNpc = KNpc.GetById(dwId);
	if (not pPlayer or not pNpc) then
		return;
	end;
	pNpc.Delete();
	-- 帅
	KNpc.Add2(4241, 120, -1, pPlayer.nMapId, 51200 / 32, 111904 / 32);
	
	-- 士
	KNpc.Add2(4242, 120, -1, pPlayer.nMapId, 51040 / 32, 112064 / 32);
	KNpc.Add2(4242, 120, -1, pPlayer.nMapId, 51360 / 32, 111744 / 32);
	-- 相
	KNpc.Add2(4243, 120, -1, pPlayer.nMapId, 50880 / 32, 112256 / 32);
	KNpc.Add2(4243, 120, -1, pPlayer.nMapId, 51552 / 32, 111584 / 32);
	-- 马
	KNpc.Add2(4245, 120, -1, pPlayer.nMapId, 50720 / 32, 112416 / 32);
	KNpc.Add2(4245, 120, -1, pPlayer.nMapId, 51712 / 32, 111424 / 32);
	-- 车
	KNpc.Add2(4244, 120, -1, pPlayer.nMapId, 50560 / 32, 112576 / 32);
	KNpc.Add2(4244, 120, -1, pPlayer.nMapId, 51872 / 32, 111264 / 32);
	-- 炮
	KNpc.Add2(4246, 120, -1, pPlayer.nMapId, 51008 / 32, 112736 / 32);
	KNpc.Add2(4246, 120, -1, pPlayer.nMapId, 52000 / 32, 111712 / 32);
	-- 兵
	KNpc.Add2(4247, 120, -1, pPlayer.nMapId, 51008 / 32, 113024 / 32);
	KNpc.Add2(4247, 120, -1, pPlayer.nMapId, 51680 / 32, 112384 / 32);
	KNpc.Add2(4247, 120, -1, pPlayer.nMapId, 51328 / 32, 112704 / 32);
	KNpc.Add2(4247, 120, -1, pPlayer.nMapId, 52000 / 32, 112032 / 32);
	KNpc.Add2(4247, 120, -1, pPlayer.nMapId, 52320 / 32, 111712 / 32);
end;

local tbShuai = Npc:GetClass("hl_shuai");

function tbShuai:OnDeath(pNpc)
	local nMapId, nPosX, nPosY = him.GetWorldPos();
	local pBox = KNpc.Add2(4280, 120, -1, nMapId, nPosX, nPosY);
	local tbNpcData = pBox.GetTempTable("Task");
	tbNpcData.nHongLianDiYu = 2;
	tbNpcData.CUR_LOCK_COUNT = 0;
	
	-- 成就，棋魂
	local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Achievement:FinishAchievement(teammate, 269);
	end
end;

-- 扩展区2
local tbYingHun = Npc:GetClass("hl_yinghun");

tbYingHun.szDesc	= "影魂";
tbYingHun.szText 	= "也许世界上最难的事情，就是战胜自己，你做好准备了吗？";
tbYingHun.tbCapyNpc	= {
		[1] = 4251,
		[2] = 4252,
		
		[3] = 4249,
		[4] = 4250,
		
		[5] = 4257,
		[6] = 4258,
		
		[7] = 4253,
		[8] = 4254,
		
		[9]  = 4261,
		[10] = 4262,
		
		[11] = 4263,
		[12] = 4264,
		
		[13] = 4267,
		[14] = 4268,
		
		[15] = 4265,
		[16] = 4266,
		
		[17] = 4271,
		[18] = 4272,
		
		[19] = 4269,
		[20] = 4270,
		
		[21] = 4255,
		[22] = 4256,
		
		[23] = 4259,
		[24] = 4260,
	}

tbYingHun.tbCapyNpcPos = {
				{1592, 3399},
				{1583, 3391},
				{1584, 3381},
				{1591, 3371},
				{1603, 3372},
				{1612, 3380},
		}

function tbYingHun:OnDialog()
	Dialog:Say(self.szText, 
			{
				{"Khiêu chiến", self.FightStart, self, him.dwId, me.nId},
				{"Kết thúc đối thoại"},
			}
		);
end;

function tbYingHun:FightStart(dwId, nId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	local pNpc = KNpc.GetById(dwId);

	if (not pPlayer or not pNpc) then
		return;
	end;

	local nMapId, _, _ = pNpc.GetWorldPos();
	pNpc.Delete();
	
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing) then
		return;
	end;

	local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
	local nNo = 0;
	for _, teammate in ipairs(tbPlayList) do
		nNo = nNo + 1;
		self:AddCopyNpc(teammate.nId, nNo);
		if (nNo == 6) then
			break;
		end;
	end;
	tbInstancing.nCapyNpcCount = nNo;
end;


function tbYingHun:AddCopyNpc(nId, nNo)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (not pPlayer) then
		return;
	end;

	local nLevel 	= pPlayer.nLevel;
	local nSeries  	= pPlayer.nSeries;
	local nFaction 	= pPlayer.nFaction;
	local nRouteId 	= pPlayer.nRouteId;
	local szName 	= pPlayer.szName;
	local nSex		= pPlayer.nSex;
	
	if nFaction == 0 then
		nFaction = 1;
	end
	if nRouteId == 0 then
		nRouteId = 1;
	end

	local nIndex = (nFaction - 1) * 2 + nRouteId;
	if (nIndex < 1 or nIndex > 24) then
		print("[海陵王墓] ERROR: nFaction[" .. nFaction .. "], nRouteId[" .. nRouteId .. "].");
		nIndex = 1;
	end;
	
	local pNpc = KNpc.Add2(self.tbCapyNpc[nIndex], nLevel, nSeries, pPlayer.nMapId, self.tbCapyNpcPos[nNo][1], self.tbCapyNpcPos[nNo][2]);
	if pNpc then
		pNpc.szName = szName;
	end
end

local tbCapyNpc = Npc:GetClass("hl_capynpc");

function tbCapyNpc:OnDeath(pNpc)
	local nMapId, nPosX, nPosY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing) then
		return;
	end;
	
	if (not tbInstancing.nKillCapyNpcCount) then
		tbInstancing.nKillCapyNpcCount = 0;
	end;
	tbInstancing.nKillCapyNpcCount = tbInstancing.nKillCapyNpcCount + 1;
	if (tbInstancing.nKillCapyNpcCount == tbInstancing.nCapyNpcCount) then
		KNpc.Add2(4275, 120, -1, nMapId, 51200 / 32, 108512 / 32);
		
		local nMapId, nPosX, nPosY = him.GetWorldPos();
		local pBox = KNpc.Add2(4280, 120, -1, nMapId, nPosX, nPosY);
		local tbNpcData = pBox.GetTempTable("Task");
		tbNpcData.nHongLianDiYu = 3;
		tbNpcData.CUR_LOCK_COUNT = 0;
	end;
	
	-- 成就，镜中人
	local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Achievement:FinishAchievement(teammate, 270);
	end
end;

-- 扩展区3
local tbLiuYiBan_Dialog = Npc:GetClass("hl_liuyiban_dialog");
tbLiuYiBan_Dialog.szText = "<npc=4276>：怎么是你，怎么还是你？我闪先。"
tbLiuYiBan_Dialog.tbPos = {
		{1720, 3861}, {1721, 3824}, {1710, 3807}, {1711, 3777}, 
		{1722, 3747}, {1738, 3746}, {1748, 3742}, {1769, 3764}, 
		{1783, 3764}, {1808, 3767}, {1825, 3756}, {1830, 3766}, 
		{1825, 3799}, {1842, 3830}, {1855, 3847}, {1842, 3831}, 
		{1825, 3800}, {1830, 3767}, {1825, 3757}, {1808, 3768}, 
		{1783, 3765}, {1769, 3765}, {1748, 3743}, {1738, 3747}, 
		{1722, 3748}, {1711, 3778}, {1710, 3808}, {1721, 3825}, 
		{1720, 3860}, {1721, 3823}, {1710, 3806}, {1711, 3776}, 
		{1722, 3746}, {1738, 3745}, {1748, 3741}, {1769, 3763}, 
		{1783, 3763}, {1808, 3766}, {1825, 3755}, {1830, 3765}, 
		{1825, 3798}, {1842, 3829}, {1855, 3846},
	}

function tbLiuYiBan_Dialog:OnDialog()
	TaskAct:Talk(self.szText, self.TalkEnd, self, him.dwId);
end;

function tbLiuYiBan_Dialog:TalkEnd(dwId)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc) then
		return;
	end;
	
	local nMapId, nPosX, nPosY = pNpc.GetWorldPos();
	pNpc.Delete();
	
	local pNpc = KNpc.Add2(4273, 120, -1, nMapId, nPosX, nPosY);
	
	pNpc.RestoreLife();
	pNpc.AI_ClearPath();
	for _, Pos in ipairs(self.tbPos) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
		end
	end;
	pNpc.SetNpcAI(9, 0, 0, -1, 25, 25, 25, 0, 0, 0, 0);	
end;

local tbLiuYiBan_Fight = Npc:GetClass("hl_liuyiban_Fight");

function tbLiuYiBan_Fight:OnDeath(pNpc)
	local nMapId, nPosX, nPosY = him.GetWorldPos();
	local pBox = KNpc.Add2(4280, 120, -1, nMapId, nPosX, nPosY);
	local tbNpcData = pBox.GetTempTable("Task");
	tbNpcData.CUR_LOCK_COUNT = 0;
	
	-- 成就，留一半
	local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Achievement:FinishAchievement(teammate, 271);
	end
end;
