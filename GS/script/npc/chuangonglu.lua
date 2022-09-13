------------------------------------------------------
--文件名		：	chuangonglu.lua
--创建者		：	furuilei
--创建时间		：	2009-1-19 14:02:45
--功能描述		：	师徒传功炉npc
------------------------------------------------------

local tbChuanGongLuNpc = Npc:GetClass("chuangonglunpc");


tbChuanGongLuNpc.ADD_EXP_TIME		= 6 * 18-- 每6秒加一次经验
tbChuanGongLuNpc.ADD_NPC_TIME		= 3 * 60 * 18	--每3分钟刷出一批npc
tbChuanGongLuNpc.ADD_NPC_NUM		= {2, 1, 1}	-- 每次刷出的npc当中2个先锋，1个巫医，1个弓手
tbChuanGongLuNpc.ADD_FRIENDFAVOR	= 10; 	-- 每加经验10次加亲密一次
tbChuanGongLuNpc.ADD_EXP_DEGREE	= 150	-- 加的总次数,持续15分钟,也就是150次
tbChuanGongLuNpc.nSkillId			= 377;	-- 技能ID
tbChuanGongLuNpc.NPC_MODE_ID		= 4445	-- NPC模板ID。
tbChuanGongLuNpc.NPC_XIAOGUAI_ID	= {4442, 4443, 4444}	-- 山寨先锋、山寨巫医、山寨弓手的ID
tbChuanGongLuNpc.NPC_POS			= {{2, 2}, {2, -2}, {-2, -2}, {-2, 2}} -- 刷出的小怪的坐标偏移
tbChuanGongLuNpc.ADD_EXP_RANGE		= 60	-- 加经验的范围
tbChuanGongLuNpc.CHANGE_RATIO		= 2.4	-- 基准经验到每次经验的转化率
tbChuanGongLuNpc.RATE				= 0.0625 	-- 师傅的经验倍率是徒弟的
tbChuanGongLuNpc.NPC_EXIST_TIME		= 18 * 60 * 15;	-- 小怪存活时间，15分钟

-- 师徒传功炉开始工作
function tbChuanGongLuNpc:StartToWork(nMapId, nMapX, nMapY, nId)
	-- 设置传功炉实体
	local pNpc = KNpc.Add2(self.NPC_MODE_ID, 1, -1, nMapId, nMapX, nMapY);
	if not pNpc then
		return 0;
	end
	
	local tbTemp = pNpc.GetTempTable("Npc");
	if (tbTemp) then
		tbTemp.nAddTimes = 0;
	else
		return 0;
	end

	self:Init(nId, pNpc.dwId);
	Timer:Register(self.ADD_EXP_TIME, self.AddShituExp, self, nId, pNpc.dwId);
	Timer:Register(self.ADD_NPC_TIME, self.AddXiaoGuai, self, nMapId, nMapX, nMapY, nId);
	return 1;
end

function tbChuanGongLuNpc:Init(nId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (not pPlayer) then
		return 0;
	end
	if (not self.nNpcLevle) then
		self.nNpcLevle = 0;
	end
	self.nNpcLevle = pPlayer.nLevel;
	if not self.tbCounter then
		self.tbCounter = {};
	end
	if not self.tbCounter[nId] then
		self.tbCounter[nId] = {}
	end
	self.tbCounter[nId].nCount = 0;
end

-- 添加小怪
function tbChuanGongLuNpc:AddXiaoGuai(nMapId, nMapX, nMapY, nId)
	if (self:GetCounter(nId) ~= 1) then
		return 0;
	end
	local nNpcCount = 0;
	for i, v in ipairs(self.ADD_NPC_NUM) do
		for j = 1, v do
			nNpcCount = nNpcCount + 1;
			local pNpc = KNpc.Add2(self.NPC_XIAOGUAI_ID[i], self.nNpcLevle, -1, nMapId, nMapX + self.NPC_POS[nNpcCount][1], nMapY + self.NPC_POS[nNpcCount][2]);
			if (pNpc) then
				pNpc.SetLiveTime(self.NPC_EXIST_TIME);
				pNpc.GetTempTable("Npc").nPlayerId = nId;
			end
		end
	end
	return self.ADD_NPC_TIME;
end

-- 先获得NPC周围的所有玩家列表，再判断是否有师徒关系存在，存在的话增加经验和亲密度
function tbChuanGongLuNpc:AddShituExp(nId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (pPlayer) then
		local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, self.ADD_EXP_RANGE);
		local nRatio = self.RATE;
		local nBaseExp;
		local nExBase = 1;
		local tbDelTemp = {};
		local tbTemp = pNpc.GetTempTable("Npc");
		
		if tbPlayer then
			local bIsTeacherAround = 0;
			tbTemp.nAddTimes = tbTemp.nAddTimes + 1;
			-- 添加好友亲密度
			
			for i in pairs(tbPlayer) do
				if tbPlayer[i].szName == pPlayer.szName then
					bIsTeacherAround = 1;
				end
			end
			
			if (tbTemp.nAddTimes % self.ADD_FRIENDFAVOR == 0 and bIsTeacherAround == 1) then	-- 师傅不在附近，不能增加亲密度
				self:AddFriendFavor(nId, tbPlayer);
			end
			
			for i in pairs(tbPlayer) do
				if (bIsTeacherAround == 1) then		-- 是不不再附近，弟子不能增加经验
					if tbPlayer[i].szName == pPlayer.szName then	-- 为师傅增加经验
						nBaseExp = tbPlayer[i].GetBaseAwardExp() * self.CHANGE_RATIO;
						tbPlayer[i].AddExp(math.floor(nRatio * nBaseExp));
						tbPlayer[i].CastSkill(self.nSkillId, 10, -1, tbPlayer[i].GetNpc().nIndex);
					elseif (pPlayer.IsTeacherRelation(tbPlayer[i].szName, 1) == 1) then	-- 为徒弟增加经验
						if (tbPlayer[i].nLevel < 100 and tbPlayer[i].nLevel < pPlayer.nLevel) then	-- 徒弟享受经验可以到100级或不低于师傅的等级
							nBaseExp = tbPlayer[i].GetBaseAwardExp() * self.CHANGE_RATIO;
							tbPlayer[i].AddExp(nBaseExp);
							tbPlayer[i].CastSkill(self.nSkillId, 10, -1, tbPlayer[i].GetNpc().nIndex);		
						end		
					end
				end
			end
		end
	end
	if self:AddCounter(nId) ~= 1 then
		self:DelNpc(nNpcId);
		return 0;
	end
	return self.ADD_EXP_TIME;
end

function tbChuanGongLuNpc:AddCounter(nId)
	if not self.tbCounter[nId] then
		return 0;
	end
	self.tbCounter[nId].nCount = self.tbCounter[nId].nCount + 1;
	if self.tbCounter[nId].nCount >= self.ADD_EXP_DEGREE then
		self.tbCounter[nId] = nil;
		return 0;
	end
	return 1;
end

function tbChuanGongLuNpc:GetCounter(nId)
	if (not self.tbCounter[nId]) then
		return 0;
	end
	if (self.tbCounter[nId].nCount >= self.ADD_EXP_DEGREE - 1) then
		return 0;
	end
	return 1;
end

function tbChuanGongLuNpc:DelNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
	return 1;
end

function tbChuanGongLuNpc:AddFriendFavor(nId, tbPlayer)
	if (not tbPlayer) then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (not pPlayer) then
		return 0;
	end
	for i = 1, #tbPlayer do
		if (pPlayer.IsTeacherRelation(tbPlayer[i].szName, 1) == 1) then
			Relation:AddFriendFavor(pPlayer.szName, tbPlayer[i].szName, 2);
			tbPlayer[i].Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", pPlayer.szName, 2));
			pPlayer.Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", tbPlayer[i].szName, 2));
		end
	end
end
