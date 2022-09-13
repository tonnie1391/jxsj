------------------------------------------------------
--文件名		：	jiazulingpai.lua
--创建者		：	fenghewen
--创建时间		：	2008-12-2
--功能描述		：	家族领牌NPC脚本。
------------------------------------------------------
local tbJiaZuLingPaiNpc = Npc:GetClass("jiazulingpainpc");


tbJiaZuLingPaiNpc.ADD_EXP_TIME		= 6 * 18-- 每6秒加一次经验
tbJiaZuLingPaiNpc.ADD_FRIENDFAVOR	= 10; 	-- 每加经验10次加亲密一次
tbJiaZuLingPaiNpc.ADD_EXP_DEGREE	= 150	-- 加的总次数,持续15分钟,也就是150次
tbJiaZuLingPaiNpc.nSkillId			= 875;	-- 技能ID
tbJiaZuLingPaiNpc.NPC_MODE_ID		= 2653	-- NPC模板ID。
tbJiaZuLingPaiNpc.ADD_EXP_RANGE		= 90	-- 加经验的范围
tbJiaZuLingPaiNpc.CHANGE_RATIO		= 1.2	-- 基准经验到每次经验的转化率
tbJiaZuLingPaiNpc.tbRatio			= {0.6, 0.7, 0.75, 0.8, 0.9, 1, 1.1, 1.2}

-- 旗子开始工作
function tbJiaZuLingPaiNpc:StartToWork(nKinId, nMapId, nMapX, nMapY)
	-- 设置旗子实体
	local pNpc = KNpc.Add2(self.NPC_MODE_ID, 1, -1, nMapId, nMapX, nMapY);
	if not pNpc then
		return 0;
	end
	
	-- 设置旗子所属帮会
	local tbTemp = pNpc.GetTempTable("Kin");
	if tbTemp then
		tbTemp.nKinId = nKinId;
		tbTemp.nAddTimes = 0;
	else
		return 0;
	end
	
	local cKin = KKin.GetKin(nKinId)
	pNpc.szName = cKin.GetName();
	self:InitCounter(nKinId, pNpc.dwId);
	Timer:Register(
		self.ADD_EXP_TIME, 
		self.AddKinExp, 
		self, 
		nKinId,
		pNpc.dwId
	);

	return 1;
end

-- 先获得NPC周围的所有玩家列表，再判断是否为家族正式成员（如果效率上有问题再回头考虑这种设计）
function tbJiaZuLingPaiNpc:AddKinExp(nKinId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		self:DelNpc(nNpcId);
		return 0;
	end
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, 90);
	local nRatio = self:GetRatio(nKinId);
	local nCount = 0;
	local nBaseExp;
	local nExBase = 1;
	local tbDelTemp = {};
	local tbTemp = pNpc.GetTempTable("Kin");
	
	if tbPlayer then
		
		tbTemp.nAddTimes = tbTemp.nAddTimes + 1;
		-- 添加好友亲密度
		if (tbTemp.nAddTimes % self.ADD_FRIENDFAVOR == 0) then
			self:AddFriendFavor(nKinId, tbPlayer);
		end
		
		for i in pairs(tbPlayer) do
			local nTagetKin, nTagetMemberId = tbPlayer[i].GetKinMember()
			if nTagetKin ~= 0 and nTagetKin == nKinId then
				local cMember = cKin.GetMember(nTagetMemberId);
				local bIsOldPAction = EventManager.ExEvent.tbPlayerCallBack:IsOpen(tbPlayer[i], 2);
				if cMember and (cMember.GetFigure() <= Kin.FIGURE_REGULAR or (bIsOldPAction == 1 and cMember.GetFigure() <= Kin.FIGURE_RETIRE)) 
					and tbPlayer[i].nLevel >= 10 then
					nBaseExp = tbPlayer[i].GetBaseAwardExp() * self.CHANGE_RATIO;
					
					-- houxuan:活动期间烤棋子获得经验更改统一接口
					local nFreeCount, tbFunExecute, nExpMul = SpecialEvent.ExtendAward:DoCheck("KinQizi", tbPlayer[i]);
					nBaseExp = nBaseExp * nExpMul;
					
					tbPlayer[i].AddExp2(nRatio * nBaseExp, "jiazuchaqi");  -- mod zounan 修改经验接口
					tbPlayer[i].CastSkill(self.nSkillId, 10, -1, tbPlayer[i].GetNpc().nIndex);
					SpecialEvent.BuyOver:AddCounts(tbPlayer[i], SpecialEvent.BuyOver.TASK_COGIATOC);
					nCount = nCount + 1;
				end
			end
		end
	end
	if self:AddCounter(nKinId, nCount) ~= 1 then
		self:DelNpc(nNpcId);
		return 0;
	end
	return self.ADD_EXP_TIME;
end

function tbJiaZuLingPaiNpc:DelNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
	return 1;
end

function tbJiaZuLingPaiNpc:GetRatio(nKinId)
	if not self.tbCounter then
		self.tbCounter = {};
	end
	if not self.tbCounter[nKinId] then
		return 0;
	end
	local nCount = self.tbCounter[nKinId].nPersonCount;
	if not nCount then
		return 0;
	end
	nCount = nCount - 7;
	if nCount <= 0 then
		return self.tbRatio[1];
	end
	nCount = 1 + math.ceil(nCount / 4);
	if nCount <= 8 then
		return self.tbRatio[nCount];
	else
		return self.tbRatio[8];
	end
end

function tbJiaZuLingPaiNpc:InitCounter(nKinId, nNpcId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if not self.tbCounter then
		self.tbCounter = {};
	end
	if not self.tbCounter[nKinId] then
		self.tbCounter[nKinId] = {}
	end
	
	self.tbCounter[nKinId].nCount = 0;
	local nPersonCount = 0;
	local tbPlayer, nCount = KNpc.GetAroundPlayerList(nNpcId, 90);
	if tbPlayer and nCount then
		for i in pairs(tbPlayer) do
			local nTagetKin, nTagetMemberId = tbPlayer[i].GetKinMember()
			if nTagetKin ~= 0 and nTagetKin == nKinId then
				local cMember = cKin.GetMember(nTagetMemberId);
				local nLevel = tbPlayer[i].nLevel;
				if cMember and cMember.GetFigure() <= Kin.FIGURE_REGULAR and nLevel >= 50 then
					nPersonCount = nPersonCount + 1
				end
			end
		end
	end
	self.tbCounter[nKinId].nPersonCount = nPersonCount;
	self.tbCounter[nKinId].nMaxCount = nPersonCount;
end

function tbJiaZuLingPaiNpc:AddCounter(nKinId, nPersonCount)
	if not self.tbCounter[nKinId] then
		return 0;
	end
	self.tbCounter[nKinId].nCount = self.tbCounter[nKinId].nCount + 1;
	self.tbCounter[nKinId].nPersonCount = nPersonCount;
	if self.tbCounter[nKinId].nMaxCount < nPersonCount then		-- 统计家族聚集最大人数
		self.tbCounter[nKinId].nMaxCount = nPersonCount;
	end
	
	if self.tbCounter[nKinId].nCount >= self.ADD_EXP_DEGREE then  -- 加经验次数到头了
		-- 增加族长和副族长的领袖荣誉
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			local nCaptainId = Kin:GetPlayerIdByMemberId(nKinId, cKin.GetCaptain());	-- 族长ID
			local nAssistantId = Kin:GetPlayerIdByMemberId(nKinId, cKin.GetAssistant()); -- 副族长ID

			local tbHonor = {40, 30, 20, 15, 10};  -- 80%到0%以上成员参加插旗，族长分别获得的领袖荣誉表
			local tbRate = {0.8, 0.6, 0.4, 0.2, 0};
			
			for i = 1, #tbHonor do
				if self.tbCounter[nKinId].nMaxCount > cKin.nMemberCount * tbRate[i] then
					PlayerHonor:AddPlayerHonorById_GS(nCaptainId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[i]);
					PlayerHonor:AddPlayerHonorById_GS(nAssistantId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[i]/2);
					break;
				end
			end
			--KStatLog.ModifyMax("Kin", cKin.GetName(), "家族聚集最大人数", self.tbCounter[nKinId].nMaxCount);
			--KStatLog.ModifyMax("Kin", cKin.GetName(), "家族聚集人数比例", self.tbCounter[nKinId].nMaxCount / cKin.nMemberCount);
		end
		self.tbCounter[nKinId] = nil;
		return 0;
	end
	return 1;
end

function tbJiaZuLingPaiNpc:AddFriendFavor(nKinId, tbPlayer)
	if (not tbPlayer) then
		return;
	end
	for i = 1, #tbPlayer do
		local nTagetKin, nTagetMemberId = tbPlayer[i].GetKinMember()
		if nTagetKin and nTagetKin == nKinId then
			for j =  i + 1, #tbPlayer do
				local nTagetKin1 = tbPlayer[j].GetKinMember();
				if (nTagetKin1 == nKinId and tbPlayer[i].IsFriendRelation(tbPlayer[j].szName) == 1) then
					Relation:AddFriendFavor(tbPlayer[i].szName, tbPlayer[j].szName, 2);
					tbPlayer[i].Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", tbPlayer[j].szName, 2));
					tbPlayer[j].Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", tbPlayer[i].szName, 2));
				end
			end
			local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_CHAQI];
			Kinsalary:AddSalary_GS(tbPlayer[i], Kinsalary.EVENT_CHAQI, tbInfo.nRate);
		end
	end
end