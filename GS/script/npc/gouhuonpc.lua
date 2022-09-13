-------------------------------------------------------------------
--File: gouhuonpc.lua
--Author: sunduoliang
--Date: 2008-5-19 09:59
--Describe: 篝火NPC脚本
-------------------------------------------------------------------

local tbGouhuoNpc = Npc:GetClass("gouhuonpc");

tbGouhuoNpc.nNpcId				= 2626;		-- 篝火npc的Id
tbGouhuoNpc.nTaskNpcId			= 1489;		-- 任务战神酒篝火npc的Id
tbGouhuoNpc.nGouhuoSkillId		= 377;		-- 篝火的技能Id
tbGouhuoNpc.BASE_EXP_FILE 		= "\\setting\\player\\attrib_level.txt";		-- 基准奖励文件
tbGouhuoNpc.KIND_EVERYONE		= 0;
tbGouhuoNpc.KIND_TEAM			= 1;
tbGouhuoNpc.KIND_KIN			= 2;
tbGouhuoNpc.KIND_TONG			= 3;
tbGouhuoNpc.KIND_TASK			= 4;
tbGouhuoNpc.KIND_EVENT			= 5;	--活动

--初始化数据：类型，持续时间，每次加经验时间，范围， 经验倍数
function tbGouhuoNpc:InitGouHuo(nNpcId, nType,	nRestTime, nPeriodTime, nAddExpDis, nBaseMultip, nCanUseJIu, nCanUseXiuLianZhu, nStateSkillId)
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return 0
		end
		local tbTmp = pNpc.GetTempTable("Npc");
		tbTmp.nType 				= nType;				--类型:0,所有人,1队伍,2家族,3帮会,4任务专用
		tbTmp.nCanUseJIu 		= nCanUseJIu or 0;		--酒是否有效,无效用0;
		tbTmp.nPeriodTime 	= nPeriodTime or 5;
		tbTmp.nRestTime 		= nRestTime or 60;
		tbTmp.nAddExpDis		= nAddExpDis or 40;
		tbTmp.nCanUseXiuLianZhu = nCanUseXiuLianZhu or 1; --修理珠是否有效
		tbTmp.nBaseMultip		= nBaseMultip; 	--经验倍率
		tbTmp.nQuotiety			= 100;					--酒的加成百分比
		tbTmp.tbQuotiety		= {};						--记录每个玩家的酒加成;任务篝火使用
		tbTmp.nAnnouce			= 0;						--公告与否
		tbTmp.nJiuMax			= 0;						--最大酒数量
		tbTmp.szJiuName			= "";						--最大酒名称
		tbTmp.nGouhuoSkillId	= nStateSkillId or self.nGouhuoSkillId;
end

function tbGouhuoNpc:SetTeamId(nNpcId, nTeamId)
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return 0
		end
		local tbTmp 	= pNpc.GetTempTable("Npc");
		tbTmp.nTeamId = nTeamId;
end

function tbGouhuoNpc:SetKinId(nNpcId, nKinId)
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return 0
		end
		local tbTmp  = pNpc.GetTempTable("Npc");
		tbTmp.nKinId = nKinId;
end

function tbGouhuoNpc:SetTongId(nNpcId, nTongId)
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return 0
		end
		local tbTmp 	= pNpc.GetTempTable("Npc");
		tbTmp.nTongId = nTongId;
end

function tbGouhuoNpc:StartNpcTimer(nNpcId)
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return 0
		end
		local tbTmp = pNpc.GetTempTable("Npc");
		Timer:Register(tbTmp.nPeriodTime * Env.GAME_FPS, self.OnNpcTimer, self, nNpcId);
end

function tbGouhuoNpc:OnNpcTimer(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end
	local tbTmp = pNpc.GetTempTable("Npc");
	if tbTmp.nRestTime ~= -1 then 	--限时篝火,nRestTime==-1为任务篝火,无限时.
		if (tbTmp.nRestTime <= tbTmp.nPeriodTime) then		-- 时间到，表示要关闭此Timer
			pNpc.Delete();
			return 0;
		end 
		tbTmp.nRestTime = tbTmp.nRestTime - tbTmp.nPeriodTime;
		if tbTmp.nRestTime < 0 then
			tbTmp.nRestTime = 0;
		end
	end
	self:AddAroundPlayersExp(nNpcId);							-- 给Npc周围队伍玩家加经验
	return tbTmp.nPeriodTime * Env.GAME_FPS;
end 


-- 功能:	给Npc周围队伍玩家加经验
-- 参数:	pNpc	篝火Npc
function tbGouhuoNpc:AddAroundPlayersExp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp		= pNpc.GetTempTable("Npc");
	local tbJiuItem	= Item:GetClass("jiu");
	if tbTmp.nType == self.KIND_EVERYONE then
		self:AddAroundExp_Everyone(nNpcId)
	elseif tbTmp.nType == self.KIND_TEAM then
		self:AddAroundExp_Team(nNpcId)
	elseif tbTmp.nType == self.KIND_KIN then
		self:AddAroundExp_Kin(nNpcId)
	elseif tbTmp.nType == self.KIND_TONG then
		self:AddAroundExp_Tong(nNpcId)
	elseif tbTmp.nType == self.KIND_TASK then
		self:AddAroundExp_Task(nNpcId)
	elseif tbTmp.nType == self.KIND_EVENT then
		self:AddAroundExp_Event(nNpcId)
	end
end

--所有
function tbGouhuoNpc:AddAroundExp_Everyone(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp			 = pNpc.GetTempTable("Npc");
	local tbJiuItem	 = Item:GetClass("jiu");
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbPlayerId = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			table.insert(tbPlayerId, pPlayer.nId);
		end
	end
	tbTmp.nAnnouce = 0;
	if tbTmp.nCanUseJIu ~= 0 then
		local nJiuMax, nQuotiety, szJiuName =  tbJiuItem:CalcQuotiety(tbPlayerId);
		 --是否公告酒的提示
		if tbTmp.nQuotiety ~= nQuotiety then
			tbTmp.nAnnouce 	= 1;
			tbTmp.nQuotiety = nQuotiety;
			tbTmp.nJiuMax 	= nJiuMax;
			tbTmp.szJiuName = szJiuName;
		end
	end
	for _, nPlayerId in pairs(tbPlayerId) do
		self:AddExp2Player(nPlayerId, nNpcId, tbTmp.nAnnouce);
	end
end

--队伍
function tbGouhuoNpc:AddAroundExp_Team(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp			 = pNpc.GetTempTable("Npc");
	local tbJiuItem	 = Item:GetClass("jiu");
	local tbPlayerId = KTeam.GetTeamMemberList(tbTmp.nTeamId);
	if tbPlayerId == nil then
		return 0;
	end
	tbTmp.nAnnouce = 0; --是否公告酒的提示
	if tbTmp.nCanUseJIu ~= 0 then
		local nJiuMax, nQuotiety, szJiuName, tbPlayerName =  tbJiuItem:CalcQuotiety(tbPlayerId);
		local _, nEventQuotiety, szEventJiuName =  tbJiuItem:CalcEventQuotiety(tbPlayerId);
		if nEventQuotiety > 0 then
			nQuotiety = nQuotiety + nEventQuotiety;
		end
		if self:CheckJiuState(tbTmp.tbQuotiety, tbPlayerName) == 0 or tbTmp.nQuotiety ~= nQuotiety then
			tbTmp.nAnnouce 	 = 1;
			tbTmp.nQuotiety  = nQuotiety;
			tbTmp.nJiuMax 	 = nJiuMax;
			tbTmp.szJiuName  = szJiuName;
			tbTmp.tbQuotiety = tbPlayerName;
		end
		local szMsg, szMsg2 = self:CreateAnnouce(nNpcId, tbPlayerName, szEventJiuName);
		if tbTmp.nAnnouce == 1 and szMsg then
			self:Msg2Team(tbTmp.nTeamId, szMsg);
			if szMsg2 then				
				self:Msg2Team(tbTmp.nTeamId, szMsg2);
			end
		end
	end
	local nNpcMapId, nNpcX, nNpcY	= pNpc.GetWorldPos();	
	for _, nPlayerId in pairs(tbPlayerId) do
		local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local nPlayerMapId, nPlayerX, nPlayerY	= pPlayer.GetWorldPos();
			if (nPlayerMapId == nNpcMapId) then
				local nDisSquare = (nNpcX - nPlayerX)^2 + (nNpcY - nPlayerY)^2;
				if (nDisSquare < ((tbTmp.nAddExpDis/2) * (tbTmp.nAddExpDis/2))) then
					local nFlag = SpecialEvent.tbNewGateEvent:CheckCanAddExp(pPlayer);	--新服活动，新秀10%经验，大师兄大师姐5%经验
					self:AddExp2Player(nPlayerId, nNpcId, 0, nFlag);
				end
			end
		end
	end
end

--家族
function tbGouhuoNpc:AddAroundExp_Kin(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp		= pNpc.GetTempTable("Npc");
	local tbJiuItem	= Item:GetClass("jiu");
	local cKin = KKin.GetKin(tbTmp.nKinId)
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbKinPlayerId = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			local nTagetKin, nTagetMemberId = pPlayer.GetKinMember()
			if nTagetKin ~= 0 and nTagetKin == tbTmp.nKinId then
				local cMember = cKin.GetMember(nTagetMemberId);
				if cMember and cMember.GetFigure() <= Kin.FIGURE_REGULAR and pPlayer.nLevel >= 10 then
					table.insert(tbKinPlayerId, pPlayer.nId);
				end
			end
		end
	end
	if #tbKinPlayerId ~= 0 then
			tbTmp.nAnnouce = 0; --是否公告酒的提示
			if tbTmp.nCanUseJIu ~= 0 then
				local nJiuMax, nQuotiety, szJiuName =  tbJiuItem:CalcQuotiety(tbKinPlayerId);
				if tbTmp.nQuotiety ~= nQuotiety then
					tbTmp.nAnnouce 	= 1;
					tbTmp.nQuotiety = nQuotiety;
					tbTmp.nJiuMax 	= nJiuMax;
					tbTmp.szJiuName = szJiuName;
				end
				local szMsg = self:CreateAnnouce(nNpcId);
				if tbTmp.nAnnouce == 1  and szMsg then
					KKin.Msg2Kin(tbTmp.nKinId, szMsg);
				end
			end
			for _, nPlayerId in pairs(tbKinPlayerId) do
				self:AddExp2Player(nPlayerId, nNpcId, 0);
			end
	end
end

--帮会
function tbGouhuoNpc:AddAroundExp_Tong(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp		= pNpc.GetTempTable("Npc");
	local tbJiuItem	= Item:GetClass("jiu");	
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbTongPlayerId = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			local nTongId = pPlayer.dwTongId
			if nTongId ~= 0 and nTongId == tbTmp.nTongId then
				table.insert(tbTongPlayerId, pPlayer.nId);
			end
		end
	end
	if #tbTongPlayerId ~= 0 then
			tbTmp.nAnnouce = 0; --是否公告酒的提示
			if tbTmp.nCanUseJIu ~= 0 then
				local nJiuMax, nQuotiety, szJiuName =  tbJiuItem:CalcQuotiety(tbTongPlayerId);
				if tbTmp.nQuotiety ~= nQuotiety then
					tbTmp.nAnnouce 	= 1;
					tbTmp.nQuotiety = nQuotiety;
					tbTmp.nJiuMax 	= nJiuMax;
					tbTmp.szJiuName = szJiuName;
				end
				local szMsg = self:CreateAnnouce(nNpcId);
				if tbTmp.nAnnouce == 1  and szMsg then
					KTong.Msg2Tong(tbTmp.nTongId, szMsg);
				end
			end
			for _, nPlayerId in pairs(tbTongPlayerId) do
				self:AddExp2Player(nPlayerId, nNpcId, 0);
			end
	end
end

--专用
function tbGouhuoNpc:AddAroundExp_Task(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp		= pNpc.GetTempTable("Npc");
	local tbJiuItem	= Item:GetClass("jiu");
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbPlayerId = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			local nSkillLevel = pPlayer.GetSkillState(tbJiuItem.nTaskJiuSkillId);
			if nSkillLevel > 0 then
				table.insert(tbPlayerId, pPlayer.nId)
			end
		end
		for _, nPlayerId in pairs(tbPlayerId) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if pPlayer ~= nil then
				if pPlayer.nTeamId == 0 then
						tbPlayerId = {nPlayerId}
						local nJiuMax, nQuotiety, szJiuName =  tbJiuItem:CalcTaskQuotiety(tbPlayerId);
						tbTmp.nAnnouce = 0; --是否公告酒的提示
						tbTmp.nQuotiety = nQuotiety;
						if tbTmp.tbQuotiety[pPlayer.nId] ~= nQuotiety then
							tbTmp.nAnnouce 	= 1;
							tbTmp.tbQuotiety[pPlayer.nId] = nQuotiety;
							tbTmp.nJiuMax 	= nJiuMax;
							tbTmp.szJiuName = szJiuName;
						end
						self:AddExp2Player(nPlayerId, nNpcId, tbTmp.nAnnouce);
				else
						local tbTeamPlayerId = KTeam.GetTeamMemberList(pPlayer.nTeamId);
						local nJiuMax, nQuotiety, szJiuName =  tbJiuItem:CalcTaskQuotiety(tbTeamPlayerId);
						tbTmp.nAnnouce = 0; --是否公告酒的提示
						tbTmp.nQuotiety = nQuotiety;
						if tbTmp.tbQuotiety[pPlayer.nId] ~= nQuotiety then
							tbTmp.nAnnouce 	= 1;
							tbTmp.nQuotiety = nQuotiety;
							tbTmp.nJiuMax 	= nJiuMax;
							tbTmp.szJiuName = szJiuName;
							for n, nTeamPlayerId in pairs(tbTeamPlayerId) do
								tbTmp.tbQuotiety[nTeamPlayerId] = nQuotiety;
							end
						end
						local szMsg = self:CreateAnnouce(nNpcId);
						if tbTmp.nAnnouce == 1  and szMsg then							
							self:Msg2Team(pPlayer.nTeamId, szMsg);
						end
						self:AddExp2Player(nPlayerId, nNpcId, 0);
				end
			end
		end
	end	
end

--活动
function tbGouhuoNpc:AddAroundExp_Event(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp		= pNpc.GetTempTable("Npc");
	local tbJiuItem	= Item:GetClass("jiu");
	local tbEventItem = Item:GetClass("xinnianyanhua");
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbPlayerId = {};
	local tbPlayerIdFlag = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			local nSkillLevel = pPlayer.GetSkillState(tbEventItem.nSkillBuffId);
			if nSkillLevel > 0 then
				table.insert(tbPlayerId, pPlayer.nId)
				tbPlayerIdFlag[pPlayer.nId] = 1;
			end
		end
		for _, nPlayerId in pairs(tbPlayerId) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if pPlayer ~= nil then
				if pPlayer.nTeamId == 0 then
						tbTmp.nQuotiety = 100;
						self:AddExp2Player(nPlayerId, nNpcId, 0);
				else
						local tbTeamPlayerId = KTeam.GetTeamMemberList(pPlayer.nTeamId);
						local tbPlayerId2 = {};
						for _, nId in pairs(tbTeamPlayerId) do
							if tbPlayerIdFlag[nId] == 1 then
								table.insert(tbPlayerId2, nId)
							end
						end
						local nJiuMax = tbJiuItem:CalcOtherQuotiety(tbPlayerId2, tbEventItem.nSkillBuffId);
						tbTmp.nQuotiety = math.floor(100 * (1 + (nJiuMax - 1)/10));
						if tbTmp.nQuotiety < 100 then
							tbTmp.nQuotiety = 100;
						end
						self:AddExp2Player(nPlayerId, nNpcId, 0);
						
						--新年特效
						--加亲密度
						for _, nId in pairs(tbPlayerId2) do
							if nId ~= nPlayerId then
								local pMemPlayer = KPlayer.GetPlayerObjById(nId);
								if pMemPlayer and pPlayer.IsFriendRelation(pMemPlayer.szName) == 1 then
									Relation:AddFriendFavor(pPlayer.szName, pMemPlayer.szName, 2);
									pPlayer.Msg(string.format("Độ thân mật với <color=yellow>%s<color> tăng lên %d điểm.", pMemPlayer.szName, 2));
									pMemPlayer.Msg(string.format("Độ thân mật với <color=yellow>%s<color> tăng lên %d điểm.", pPlayer.szName, 2));
								end
							end
						end
						
				end
				pPlayer.CastSkill(tbEventItem.nSkillId, 1, -1, pPlayer.GetNpc().nIndex);	
			end
		end
	end	
end

function tbGouhuoNpc:AddExp2Player(nPlayerId, nNpcId, nAnnouce, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp		= pNpc.GetTempTable("Npc");
	local nBaseMultip = tbTmp.nBaseMultip;
	local nQuotiety		= tbTmp.nQuotiety;
	pPlayer.CastSkill(tbTmp.nGouhuoSkillId, 10, -1, pPlayer.GetNpc().nIndex);
	local nExp = math.floor(pPlayer.GetBaseAwardExp() *	(nBaseMultip / 100) * (nQuotiety / 100) / (60 / tbTmp.nPeriodTime));
	if nFlag then
		nExp = math.floor(nExp * (100 + nFlag) / 100);
	end
	if tbTmp.nCanUseXiuLianZhu == 1 then
		pPlayer.AddExperience(nExp);
	else
		pPlayer.AddExp2(nExp,"gouhuo"); -- mod zounan 修改经验接口
	end
	if nAnnouce == 1 then
		local szMsg = self:CreateAnnouce(nNpcId);
		pPlayer.Msg("<color=blue>"..szMsg);
	end
end

function tbGouhuoNpc:CreateAnnouce(nNpcId, tbPlayerName, szEventJiuName)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp			= pNpc.GetTempTable("Npc");
	local nBaseMultip 	= tbTmp.nBaseMultip;
	local nQuotiety		= tbTmp.nQuotiety;
	local nAnnouce		= tbTmp.nAnnouce;
	local nJiuMax		= tbTmp.nJiuMax;
	local szJiuName		= tbTmp.szJiuName;

	local szMsg;
	local szMsg2;
	if nAnnouce == 1 then
		if nJiuMax == 0 then
			if szEventJiuName then
				szMsg = string.format("<color=blue>Sử dụng %s, ", szEventJiuName);
			else
				szMsg = string.format("<color=blue>Không sử dụng rượu, ");
			end
			szMsg = string.format("%s kinh nghiệm lửa trại tăng <color=yellow>%s%%<color=blue>.", szMsg, nQuotiety)
		else
			if szEventJiuName then
				szMsg = string.format("Đồng đội chia sẻ %s và %s, kinh nghiệm lửa trại tăng %s%%", szJiuName, szEventJiuName, nQuotiety)
			else	
				szMsg = string.format("Đồng đội chia sẻ %s, kinh nghiệm lửa trại tăng %s%%", szJiuName, nQuotiety)
			end
			if tbPlayerName ~= nil then
				szMsg2 = "";
				for szJiu, tbName in pairs(tbPlayerName) do
					for ni, szName in ipairs(tbName) do
						--酒的名字只显示3个字，把陈年去掉，这种方法比较搓，但临时用吧
						local szJiu2 = string.sub(szJiu,9,-1)
						szMsg2 = string.format("%s %s-%s<enter>", szMsg2, szName, szJiu2);
					end
				end
			end
		end
	end
	return szMsg, szMsg2;
end

function tbGouhuoNpc:CheckJiuState(tbQuotiety, tbPlayerName)
	local nFlag1 = 0;
	local nFlag2 = 0;
	for szJiu, tbPlayer in pairs(tbQuotiety) do
		nFlag1 = 1;
		break;
	end
	
	for szJiu, tbPlayer in pairs(tbPlayerName) do
		nFlag2 = 1;
		if tbQuotiety[szJiu] == nil then
			return 0;
		end
		if #tbPlayer ~= #tbQuotiety[szJiu] then
			return 0;
		end
		for ni, szName in pairs(tbPlayer) do
			if tbQuotiety[szJiu][ni] ~= szName then
				return 0;
			end
		end
	end
	
	if nFlag1 == 1 and  nFlag2 == 0 then
		return 0;
	end
	return 1;
end

function tbGouhuoNpc:Msg2Team(nTeamId, szMsg)
	local tbPlayerIdList = KTeam.GetTeamMemberList(nTeamId);
	for _, nPlayerId in pairs(tbPlayerIdList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg(szMsg);
		end
	end
end
