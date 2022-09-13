-- 文件名  : beautyhero_gs.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-19 17:12:19
-- 描述    : 

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\beautyhero\\beautyhero_def.lua");

function BeautyHero:StartMatch_GS(nIndex)
	local tbInfo = self.MATCH_STATE[nIndex];

	self.tbMissionList = {};
	self.tbMissionFlag = {};
	self.nTypeFlag = tbInfo.nType;
	self.nServerFlag = tbInfo.nServer;	
	

 	-- 混战和单人赛的地图策略不一样
	local tbMapInfo = {};
	if tbInfo.nType == BeautyHero.emMATCHTYPE_MELEE then
		tbMapInfo = self.MAP_MELEE;
	elseif tbInfo.nType == BeautyHero.emMATCHTYPE_SERIES then
		tbMapInfo = self.MAP_SERIES;
	end
	
	for nSeries, nMapId in pairs(tbMapInfo) do
		self.tbMissionFlag[nSeries] = nMapId;
	end	
	
	--判断全局服用
	if tbInfo.nServer == self.emMATCHSERVER_LOCAL then
		if GLOBAL_AGENT then
			return;
		end
	elseif tbInfo.nServer == self.emMATCHSERVER_GLOBAL then
		if not GLOBAL_AGENT then
			return;
		end				
	end


	local nRet = 0;
	for nSeries, nMapId in pairs(tbMapInfo) do
		-- self.tbMissionFlag[nSeries] = nMapId;
		if IsMapLoaded(nMapId) == 1 then	-- 地图加载则开启活动		
			--self.tbMissionList[nSeries] = Lib:NewClass(self.Mission);	
			--self.tbMissionList[nSeries]:Init(tbInfo.nServer,tbInfo.nType,nSeries,nMapId);
			self.tbMissionList[nMapId] = Lib:NewClass(self.Mission);  -- 用地图ID会比较好吧？
			self.tbMissionList[nMapId]:Init(nMapId,tbInfo.nType,nSeries,tbInfo.nServer);
			nRet = 1;
		end
	end
	
	-- 全服消息
	if nRet == 1 then
		if GLOBAL_AGENT then
			GCExcute{"BeautyHero:GlobalMsg_Center" , "跨服巾帼英雄赛已经开启，请玩家从丁丁处进入英雄岛，准备跨服竞技！"};
		else
			KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, "巾帼英雄赛已经开启，请玩家进入巾帼英雄竞技场!");
		end
	end
	
end

function BeautyHero:EndMatch_GS()
--	if not self.tbBattleFlag then
--		self.tbBattleFlag = {}
--	end
--	self.tbBattleFlag[nFaction] = 0;
	for _ ,tbMissionInfo  in pairs(self.tbMissionList) do
		tbMissionInfo:EndGame();		
	end
--	self.tbMissionList = {};
--	self.tbMissionFlag = {};
end

function BeautyHero:EndMatchFlag_GS(nSeries, nMapId)
	self.tbMissionFlag = self.tbMissionFlag or {};
	self.tbMissionFlag[nSeries] = nil;
end

function BeautyHero:GetMissionFlag(nSeries)	
	self.tbMissionFlag = self.tbMissionFlag or {};
	return self.tbMissionFlag[nSeries];
end

function BeautyHero:GetMissionBrief()
	self.tbMissionFlag = self.tbMissionFlag or {};
	local nCount = 0;
	for _, _ in pairs(self.tbMissionFlag) do
		nCount = nCount + 1;
	end
	
	if nCount == 0 then
		return;
	end
	local tbMissionBrief = 
	{
		nType 		  = self.nTypeFlag,
		nServer  	  = self.nServerFlag,
		tbMissionFlag = self.tbMissionFlag,
	};
	return tbMissionBrief;
end

function BeautyHero:GetMissionInfo(nMapId)
	self.tbMissionList = self.tbMissionList or {};
	return self.tbMissionList[nMapId];
end



-- 获取某个混战区的一个随机点
function BeautyHero:GetRandomPoint(nArenaId)
	if not self.tbArenaRange or not self.tbArenaRange[nArenaId] then
		return;
	end
	local nArenaRangeNum = #self.tbArenaRange[nArenaId];
	local tbRandomRange = self.tbArenaRange[nArenaId][MathRandom(nArenaRangeNum)];
	if not tbRandomRange then
		return;
	end
	local nAngle = 6.28 * MathRandom()				-- 随机弧度度 3.14 * 2 = 6.28
	local nRadii = MathRandom(tbRandomRange.nR)	-- 随机距离
	local nX = math.floor(math.cos(nAngle) * nRadii + tbRandomRange.nX);
	local nY = math.floor(math.sin(nAngle) * nRadii + tbRandomRange.nY);
	return nX, nY;
end

-- 获取某个淘汰赛区域的两个定点
function BeautyHero:GetElimFixPoint(nArenaId)
	if self.tbArenaPoint and self.tbArenaPoint[nArenaId] then
		return self.tbArenaPoint[nArenaId][1], self.tbArenaPoint[nArenaId][2];
	end
end

-- 关闭活动
function BeautyHero:ShutDown(nMapId, nSeries)
	if self.tbMissionList and self.tbMissionList[nMapId]then
		self.tbMissionList[nMapId] = nil;
	end
	if self.tbMissionFlag then
		self.tbMissionFlag[nSeries] = nil;
	end
	GCExcute{"BeautyHero:EndMatchFlag_GC" , nSeries};
end

function BeautyHero:ShowMsgToMapPlayer(nSeries, szMsg)
	local tbMission = self:GetMissionInfo(nSeries);
	if tbMission then
		tbMission:MsgToMapPlayer(szMsg);
	end
end

-- 传送玩家至某个传入点
function BeautyHero:TrapIn(pPlayer,nMapId)
	nMapId = nMapId or pPlayer.nMapId
	local nRandom = MathRandom(4);
	if pPlayer and self.REV_POINT[nRandom] then
		pPlayer.NewWorld(nMapId, unpack(self.REV_POINT[nRandom]));
	end
end

function BeautyHero:FinalWinner(nSeries,nType,nMapId, tb16thPlayer)
	GCExcute{"BeautyHero:FinalWinner_GC", tb16thPlayer};
	-- 冠军旗子
	self:AwardChampionStart(nSeries,nMapId, nPlayerId);

end

function BeautyHero:UpdateBeautyHeroLadder()
	GCExcute{"BeautyHero:UpdateBeautyHeroLadder"};
end

--[[
function BeautyHero:ShowCandidate(nSeries)
	local tbCandidate = GetCurCandidate(nSeries);
	print("本月：")
	Lib:ShowTB(tbCandidate);
	tbCandidate = GetLastMonthCandidate(nSeries);
	print("上月:");
	Lib:ShowTB(tbCandidate);
	print("历届:");
	tbCandidate = GetAllElectWinner(nFaction);
	Lib:ShowTB(tbCandidate);
	print("最近:")
	local tbPlayer = GetCurWinner(nFaction);
	if tbPlayer then
		Lib:ShowTB(tbPlayer);
	end
end
--]]


-- 冠军授予功能启动
function BeautyHero:AwardChampionStart(nSeries,nMapId, nWinnerId)
	local pFlagNpc = KNpc.Add2(
		self.FLAG_NPC_TAMPLATE_ID, 
		10, 
		-1, 
		nMapId, 
		self.FLAG_X, 
		self.FLAG_Y
	);
	local tbTemp = pFlagNpc.GetTempTable("BeautyHero");
	tbTemp.tbFactionData = {};
	tbTemp.tbFactionData.nWinnerId = nWinnerId;
	tbTemp.tbFactionData.nFlagTimerId = Timer:Register(
		self.FLAG_EXIST_TIME * Env.GAME_FPS,
		self.ExcuteAwardChampion,
		self,
		pFlagNpc.dwId,
		0
	);
end

function BeautyHero:ChampionFlagNpc(pPlayer, pNpc)
	self:ExcuteAwardChampion(pNpc.dwId,pPlayer.nId);
end

-- 触发冠军授予
function BeautyHero:ExcuteAwardChampion(nNpcId, nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end

	local tbTemp = pNpc.GetTempTable("BeautyHero");
	if  nPlayerId ~= 0 and
		(tbTemp.tbFactionData) and 
		(tbTemp.tbFactionData.nWinnerId) and
		(tbTemp.tbFactionData.nWinnerId == nPlayerId) then
		
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			-- 授予称号
			--	pPlayer.AddTitle(self.TITLE_GROUP, self.TITLE_ID, pPlayer.nFaction, 0);
			-- 特效
			pPlayer.CastSkill(self.YANHUA_SKILL_ID, 1, -1, pPlayer.GetNpc().nIndex);
		end
	end

	-- 奖励
	local tbPlayer = KPlayer.GetMapPlayer(pNpc.nMapId);
	local nPlayerCount = #tbPlayer;
	local tbMissionInfo = self:GetMissionInfo(pNpc.nMapId);
	pNpc.Delete();
	Timer:Close(tbTemp.tbFactionData.nFlagTimerId);

	if tbMissionInfo then
		tbMissionInfo:AddGuanjunBaoXiang();
	--	tbMissionInfo:CalcDuBoAward();
	end
	return 0;
end


function BeautyHero:GetAttendTimes(pPlayer)
	local nCurWeek = tonumber(GetLocalDate("%Y%W"));
	local nTskWeek =  pPlayer.GetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_WEEK);
	if nTskWeek ~= nCurWeek then
		return 0;
	end
	
	local nPlayerTimes = pPlayer.GetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_TIMES);
	return nPlayerTimes;
end

function BeautyHero:AddAttendTimes(pPlayer)
	local nCurWeek = tonumber(GetLocalDate("%Y%W"));
	if pPlayer.GetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_WEEK) ~= nCurWeek then
		pPlayer.SetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_WEEK,nCurWeek);
		pPlayer.SetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_TIMES,1);
	else
		local nCurTime = pPlayer.GetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_TIMES);
		pPlayer.SetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_TIMES,nCurTime + 1);	
	end
end

function BeautyHero:SetAttendTimes(pPlayer,nTimes)
	local nCurWeek = tonumber(GetLocalDate("%Y%W"));
	if pPlayer.GetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_WEEK) ~= nCurWeek then
		pPlayer.SetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_WEEK,nCurWeek);
		pPlayer.SetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_TIMES,nTimes);
	else
		pPlayer.SetTask(BeautyHero.TSK_GLOBAL_GROUP, BeautyHero.TSK_MATCH_TIMES,nTimes);	
	end	
end

--增加跨服活动奖励 -- 本服领取 GS
function BeautyHero:AddGlobalRestAward(nPlayerId,nAddBindCoin, pPlayer)
	GCExecute({"BeautyHero:AddGlobalRestAward", nPlayerId, nAddBindCoin});
	if pPlayer then
		pPlayer.Msg(string.format("您增加了%d绑金，请比赛结束后到本服丁丁处领取",nAddBindCoin));
	end
end

-- 玩家活动奖励 GS
function BeautyHero:SetGlobalMatchAward(nPlayerId,nRank)
	GCExecute({"BeautyHero:SetGlobalMatchAward", nPlayerId, nRank});
end

function BeautyHero:BuyRose()
	Dialog:OpenShop(182,7);
end