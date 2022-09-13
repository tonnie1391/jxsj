--额外时间通用函数GS,Client
--孙多良 2008.07.24
--*_Check可单独出现..
--DoExecute必须和*_Check成对出现.
--接口：SpecialEvent.ExtendEvent:DoExecute("szType");
--接口:以后增加注册事件接口
--使用接口1注册：SpecialEvent.ExtendEvent:RegExecute(szType, tbExe)
--使用接口2注销：SpecialEvent.ExtendEvent:UnRegExecute(szType, tbExe)

local ExtendEvent = {};
SpecialEvent.ExtendEvent = ExtendEvent;

ExtendEvent.nMaxGenStonePerHour = 4;	--一个小时内每个服务器精英怪产出的宝石上限
ExtendEvent.tbGiveStoneProb     = {[1] = 20,[2] = 30};	--产出矿石概率
--已有接口
ExtendEvent.tbInterFaceFun = 
{
	["CallNpc_BaiHuTang"]	= "CallNpc_BaiHuTang",	--白虎堂开启刷npc后触发
	["Open_Battle"]			= "Open_Battle",		--宋金战场开启触发
	["Open_Treasure"]		= "Open_Treasure",		--藏宝图副本开启触发
	["Open_ArmyCamp"]		= "Open_ArmyCamp",		--军营副本开启触发
	["Open_KinGame"]		= "Open_KinGame",		--家族关卡开启触发
	["Open_FourfoldMap"]	= "Open_FourfoldMap",	--4倍秘境地图开启触发
	["Open_FactionBattle"]	= "Open_FactionBattle",	--门派竞技开启触发	
	["Npc_Death"]			= "Npc_Death",			--所有任意npc死亡触发	
}

ExtendEvent.tbFunExecute = {};
function ExtendEvent:Init()
	self.tbInit = self.tbInit or {};
	for szType, szFun in pairs(self.tbInterFaceFun) do
		self.tbInit[szFun] = {};
	end
end
ExtendEvent:Init();

function ExtendEvent:GetInitTable(szFun)
	return self.tbInit[szFun] or {};
end

--tbExe: {回调函数, arg1, arg2 ...}
--执行时，还会把对应check收到的参数放到tbExe后再执行
--例如 tbExe = {fun, a, b}, 对应check为 function fun_check(c,d)
--最终fun会按顺序收到 a,b,c,d四个参数
function ExtendEvent:RegExecute(szType, tbExe)
	self.tbFunExecute[szType] = self.tbFunExecute[szType] or {};

	local nAdd = 1;
	for _, tbFunExe in pairs(self.tbFunExecute[szType]) do
		if tbFunExe[1] == tbExe[1] then
			nAdd = 0;
			break;
		end
	end
	if nAdd == 1 then
		table.insert(self.tbFunExecute[szType], tbExe);
	end
end

function ExtendEvent:UnRegExecute(szType, tbExe)
	if self.tbFunExecute[szType] then
		local tbTempExe = {};
		for i, tbExe in pairs(self.tbFunExecute[szType]) do
			if tbExe[1] ~= tbExe[1] then
				table.insert(tbTempExe, tbExe);
			end
		end
		self.tbFunExecute[szType] = tbTempExe;
	end
end

function ExtendEvent:DoExecute(szType, ...)
	Lib:CallBack({self.DoExecuteBase, self, szType, unpack(arg)});
end

function ExtendEvent:DoExecuteBase(szType, ...)
	local tbExecute = {};
	if not self.tbInterFaceFun[szType] then
		return 0;
	end
	if self[self.tbInterFaceFun[szType]] then
		tbExecute = self[self.tbInterFaceFun[szType]](self, unpack(arg))
	end
	for _, tbfun in ipairs(tbExecute) do
		tbfun.fun(unpack(tbfun.tbParam));
	end
	if ExtendEvent.tbFunExecute[szType] then
		
		for _, tbExe in ipairs(ExtendEvent.tbFunExecute[szType]) do
			local tbTemp = {};
			for _, v in ipairs(tbExe) do
				table.insert(tbTemp, v);
			end
			for _, v in ipairs(arg) do
				table.insert(tbTemp, v);
			end
			tbTemp[1](unpack(tbTemp,2));
		end
	end	
end

function ExtendEvent:RegistrationExecute(tbExecute)
	local tbFunExecute = {};
	for _, tbFunParam in ipairs(tbExecute) do
		if tbFunParam[1] then
			local tbTemp = {fun=tbFunParam[1], tbParam={}}
			for nId, param in ipairs(tbFunParam) do
				if nId ~= 1 then
					table.insert(tbTemp.tbParam, param);
				end
			end
			table.insert(tbFunExecute, tbTemp);
		end
	end
	return tbFunExecute;
end

--白虎堂召唤npc，
--nMapId	-白虎堂地图Id
--nLevel	-白虎堂等级(1.初级，2高级，3黄金); 
--nStep		-层数（1.一层，2.二层，3.三层）;
--nBoss		-是否是刷boss时触发（1.boss，0.普通怪）
function ExtendEvent:CallNpc_BaiHuTang(nMapId, nLevel, nStep, nBoss)
	local tbExecute = {};
	
	--2008圣诞活动. 2009.01.10后可删除
	if SpecialEvent.Xmas2008:Check() == 1 then
		if nStep == 1 and nBoss == 1 then
			SpecialEvent.Xmas2008:CallNpc(1, nMapId);	
		elseif nStep == 2 and nBoss == 1 then
			SpecialEvent.Xmas2008:CallNpc(2, nMapId);
		elseif nStep == 3 and nBoss == 1 then
			SpecialEvent.Xmas2008:CallNpc(3, nMapId);
		end
	end
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end


--宋金开启状态
--nMapId		-宋金地图Id
--nLevel		-宋金等级(1.初级扬州，2.中级凤翔，3.高级襄阳); 
--nRuleType		-宋金类型(1.杀戮模式, 2.元帅保卫模式 3.夺旗模式)
--nSeqNum		-今天第几轮
--nBattleMapType-战场类型(1.九曲之战, 2.五丈原之战 3.蟠龙谷之战)
function ExtendEvent:Open_Battle(nMapId, nLevel, nType, nSeq, nBattleMapType)
	local tbExecute = {};
	
	local tbMapType = {
		[187]=1,[188]=1,[189]=1,[263]=1,[264]=1,[265]=1,[284]=1,[290]=1,[295]=1, --九曲之战
		[190]=2,[191]=2,[192]=2,[266]=2,[267]=2,[268]=2,[285]=2,[291]=2,[296]=2, --五丈原之战
		[193]=3,[194]=3,[195]=3,[269]=3,[270]=3,[271]=3,[286]=3,[292]=3,[297]=3, --蟠龙谷之战
		[1635]=4,[1636]=4,[1637]=4,[1638]=4,[1639]=4,[1640]=4,[1641]=4,[1642]=4,[1643]=4, --嘉峪关之战
	};
	
	--2008圣诞活动. 2009.01.10后可删除
	if SpecialEvent.Xmas2008:Check() == 1 then
		local nMapType = tbMapType[nMapId];
		if nMapType then
			local nEventType = 5;
			if nMapType == 1 then
				nEventType = 5;
			elseif nMapType == 2 then
				nEventType = 6;
			elseif nMapType == 3 then
				nEventType = 7;
			elseif nMapType ==4 then
				nEventType = 8;
			end
			SpecialEvent.Xmas2008:CallNpc(nEventType, nMapId);
		end
	end
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end

--藏宝图副本开启状态
--nLevel			-副本等级(1.初级，2.中级，3.高级); 
--nMapId			-副本动态地图Id
--nMapTemplateId	-副本模版地图Id
function ExtendEvent:Open_Treasure(nLevel, nMapId, nMapTemplateId)
	local tbExecute = {};
			
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end

--军营副本开启状态
--nMapId			-副本动态地图Id
--nMapTemplateId	-副本模版地图Id
function ExtendEvent:Open_ArmyCamp(nMapId, nMapTemplateId)
	local tbExecute = {};
			
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end

--家族关卡开启状态
--nLevel			-关卡怪物等级
--nCount			-关卡家族成员数量
function ExtendEvent:Open_KinGame(nLevel, nCount)
	local tbExecute = {};
			
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end

--秘境开启状态
--nLevel			-秘境怪物等级
--nMapId			-秘境动态地图Id
function ExtendEvent:Open_FourfoldMap(nLevel, nMapId)
	local tbExecute = {};
			
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end

--门派竞技开启状态
--nFaction			-门派Id
--nMapId			-门派竞技地图Id
function ExtendEvent:Open_FactionBattle(nFaction, nMapId)
	local tbExecute = {};
	
	--2008圣诞活动. 2009.01.10后可删除
	if SpecialEvent.Xmas2008:Check() == 1 then
		SpecialEvent.Xmas2008:CallNpc(4, nMapId);
	end

	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end

function ExtendEvent:Npc_Death(pNpc, pKillPlayer)
	local tbExecute = {};
	
	local pPlayer = pKillPlayer.GetPlayer();
	if pPlayer then
		--成就
		Achievement:FinishAchievement(pPlayer,409);
	end
	--local nNpcType 	= pNpc.GetNpcType();		--npc类型
	--local pPlayer  	= pKillPlayer.GetPlayer();	--杀死npc的玩家
	self:GiveStone(pNpc,pKillPlayer);
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return tbFunExecute;
end

function ExtendEvent:GiveStone(pNpc,pKillPlayer)
	if TimeFrame:GetState("OpenLevel150") ~= 1 then
		return 0;
	end
	local nNpcType 	= pNpc.GetNpcType();		--npc类型
	local pPlayer  	= pKillPlayer.GetPlayer();	--杀死npc的玩家
	local tbMapInfo = Map.tbMapIdList[pNpc.nMapId] or {};
	local nMapLevel = tonumber(tbMapInfo.nMapLevel or 0);
	local tbProb	= self.tbGiveStoneProb;
	if nNpcType ~= 1 and nNpcType ~= 2 then
		return 0;
	end
	if not pPlayer then
		return 0;
	end
	if nMapLevel ~= 115 then
		return 0;
	end
	if not self.nHasGenStoneNum then
		self.nHasGenStoneNum = 0;
	end
	if not self.nLastGenHour then
		self.nLastGenHour = tonumber(os.date("%H",GetTime()));
	end
	local nTime = tonumber(os.date("%H",GetTime()));
	if nTime == self.nLastGenHour then
		if self.nHasGenStoneNum >= self.nMaxGenStonePerHour then
			return 0;
		end
	else
		self.nHasGenStoneNum = 0;
		self.nLastGenHour = tonumber(os.date("%H",GetTime()));
	end
	if pPlayer then
		local pMember = self:GetRandomNearTeamMember(pPlayer);
		if pMember and not IpStatistics:IsStudioRole(pMember) then
			if nMapLevel == 105 or nMapLevel == 115 then
				if nNpcType == 1 or nNpcType == 2 then
					local nProb = tbProb[nNpcType];
					if not nProb then
						return 0;
					end
					local nRand = MathRandom(100);
					if nRand <= nProb then
						local pItem = pMember.AddItem(18,1,1313,1);
						if pItem then
							self.nHasGenStoneNum = self.nHasGenStoneNum + 1;	--当前server产出数量
							local szGDPL = string.format("%d_%d_%d_%d",18,1,1313,1);
							local szMapInfo = "map" .. tostring(nMapLevel);
							StatLog:WriteStatLog("stat_info", "baoshixiangqian",szMapInfo,pMember.nId,szGDPL,1);
						else
							Dbg:WriteLog("baoshixiangqian", "Gold Npc Generate Stone Failed", pMember.szName);
						end
					end
				end
			end
		end	
	end
end

function ExtendEvent:GetRandomNearTeamMember(pPlayer)
	if pPlayer and pPlayer.nTeamId > 0 then
		local tbTeamList,nCount = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		if nCount <= 1 then
			return pPlayer;
		end
		local tbNearPlayer = KPlayer.GetAroundPlayerList(pPlayer.nId,40);
		local tbNearTeamMember = {};
		for _,pNear in pairs(tbNearPlayer) do
			if pNear then
				for _,nId in pairs(tbTeamList) do
					local pMember = KPlayer.GetPlayerObjById(nId);
					if pMember then
						if pMember.nId == pNear.nId then
							table.insert(tbNearTeamMember,pMember);
						end
					end
				end
			end
		end
		local pNearMember = tbNearTeamMember[MathRandom(#tbNearTeamMember)];
		return pNearMember;
	else
		return pPlayer;
	end
end

