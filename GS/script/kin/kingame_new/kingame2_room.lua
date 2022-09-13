-- 文件名　：kingame2_room.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-09 14:04:23
-- 描述：高级家族副本房间信息,room会记录启动它的tbBase


KinGame2.tbRoom = {};
--7个关卡
KinGame2.tbRoom[1]  = {};
KinGame2.tbRoom[2]  = {};
KinGame2.tbRoom[3]  = {};
KinGame2.tbRoom[4]  = {};
KinGame2.tbRoom[5]  = {};
KinGame2.tbRoom[6]  = {};
KinGame2.tbRoom[7]  = {};


local tb1stRoom = KinGame2.tbRoom[1];
local tb2ndRoom = KinGame2.tbRoom[2];
local tb3rdRoom = KinGame2.tbRoom[3];
local tb4thRoom = KinGame2.tbRoom[4];
local tb5thRoom = KinGame2.tbRoom[5];
local tb6thRoom = KinGame2.tbRoom[6];
local tb7thRoom = KinGame2.tbRoom[7];


-----------------------------1号房间逻辑start----------------------------
--开启房间
function tb1stRoom:StartRoom()
	if not self.tbBase then
		return 0;
	end
	self.nIsStart = 1;
	self.nStep = 1;
	self.nStartTimer = Timer:Register(20 * Env.GAME_FPS,self.StartAddNpc,self);	--开启房间的延迟
	self.tbWine = {};
	local szMsg = "<color=green>距离第一关开启还有<color><color=white>%s<color>";
	local szState = "";
	self.tbBase:UpdateUiState(szMsg,self.nStartTimer,szState);
end

function tb1stRoom:StartAddNpc()
	self:AddAttackWineNpc();
	self:AddFoodsNpc();
	self:AddNormalNpc();
	self.nRoomTimer = Timer:Register(KinGame2.ROOM_TIME_LIMIT[1] * Env.GAME_FPS, self.EndRoomTime, self);
	self.nAddAttackNpcTimer = Timer:Register(KinGame2.ADD_ATTACK_TIME * Env.GAME_FPS, self.AddAttackWineNpc, self);
	self.nAddFoodsNpcTimer = Timer:Register(KinGame2.ADD_FOODS_TIME * Env.GAME_FPS, self.AddFoodsNpc, self);
	self.nStartTimer = 0;
	self:AddWineNpc();
	local szMsg = "<color=green>距离酿酒结束还有<color><color=white>%s<color>";
	local szState = "保护角落的酒坛不受酒鬼破坏\n\n点击酒坛后收集需要的材料\n\n保证三个酒坛酿酒成功";
	self.tbBase:AllBlackBoard("快去看看四周的酒坛需要些什么东西");
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
	self:UpdateWineUi(self.nStep);
	return 0;
end


--结束房间
function tb1stRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

--房间结束，开启第二关
function tb1stRoom:RoomFinish()
	local nCount = 0;
	local nRet = 0;
	for _,tbInfo in pairs(self.tbWine) do
		if tbInfo.bDead == 1 then
			nCount = nCount + 1;
		end
	end
	if nCount >= KinGame2.MAX_DEAD_WINE or self.nStep < 3 then
		nRet = 0;
	else
		nRet = 1;
	end
	self.tbBase:AddAllPlayerExp(1,nRet);		--加经验
	self.tbBase:GiveAllPlayerRepute(1,nRet);	--加家族声望
	self.tbBase:GiveAllPlayerAwardItem(1,nRet);	--过关加的古币
	if nRet == 0 then
		self:HandleFailWine();
		self.tbBase:RoomFinish(1,0);
		self.tbBase:AllBlackBoard("酿酒失败，请等待下一关开启");
	elseif nRet == 1 then 
		self.nRoomFinishTimer = Timer:Register(10 * Env.GAME_FPS, self.RoomSucess, self);
		local szState = "酒已酿好，可以点击酒坛领取美酒了";
		self.tbBase:UpdateUiState(nil,nil,szState);
		self.tbBase:AllBlackBoard("酒已酿好，品尝后可使自身功力大增");
	end
end

function tb1stRoom:RoomSucess()
	self.tbBase:RoomFinish(1,1);
	self.nRoomFinishTimer = 0;
	return 0;
end


function tb1stRoom:HandleFailWine()
	for nId,tbInfo in pairs(self.tbWine) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.GetTempTable("KinGame2").bFailed = 1;			
		end
	end
end

--房间时间到了
function tb1stRoom:EndRoomTime()
	self.nRoomTimer = 0;
	self:EndRoom();
	return 0;
end

--房间是否开启
function tb1stRoom:IsRoomStart()
	return self.nIsStart or 0;
end

--房间是否完成
function tb1stRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

--刷出4个酒坛
function tb1stRoom:AddWineNpc()
	self.tbWine = {};
	for nIndex,tbPos in pairs(KinGame2.WINE_NPC_POS) do 
		local pNpc = KNpc.Add2(KinGame2.WINE_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		pNpc.SetTitle(KinGame2.WINE_NPC_TITLE[nIndex]);
		pNpc.GetTempTable("KinGame2").nStep = self.nStep;
		self.tbWine[pNpc.dwId] = {};
		self.tbWine[pNpc.dwId].nAiIndex = nIndex;	--对应的攻击的怪的ai索引
		self.tbWine[pNpc.dwId].nAttackedCount = 0;	--被攻击的次数
		self.tbWine[pNpc.dwId].bFinishFire = 0;	--是否完成烤火
		self.tbWine[pNpc.dwId].szTitle = KinGame2.WINE_NPC_TITLE[nIndex];
		self.tbWine[pNpc.dwId].bDead = 0;
		self:StartWineCollect(pNpc.dwId);
	end
end

function tb1stRoom:StartWineCollect(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		if not pNpc.GetTempTable("KinGame2").tbInfo then
			pNpc.GetTempTable("KinGame2").tbInfo = {};
		end
		if not pNpc.GetTempTable("KinGame2").tbInfo.tbIdx then
			pNpc.GetTempTable("KinGame2").tbInfo.tbIdx = {};
			for i = 1 ,#KinGame2.WINE_NEED_TABLE do
				pNpc.GetTempTable("KinGame2").tbInfo.tbIdx[i] = i;
			end
		end
		if not pNpc.GetTempTable("KinGame2").tbInfo.nCurrentNeedIdx and #pNpc.GetTempTable("KinGame2").tbInfo.tbIdx ~= 0 then
			local nPos = MathRandom(#pNpc.GetTempTable("KinGame2").tbInfo.tbIdx);
			local nNeedIdx = pNpc.GetTempTable("KinGame2").tbInfo.tbIdx[nPos];
			pNpc.GetTempTable("KinGame2").tbInfo.nCurrentNeedIdx = nNeedIdx;
			table.remove(pNpc.GetTempTable("KinGame2").tbInfo.tbIdx,nPos);
		end
		if not pNpc.GetTempTable("KinGame2").tbInfo.nNeedNum and pNpc.GetTempTable("KinGame2").tbInfo.nCurrentNeedIdx then
			local nNeedIdx = pNpc.GetTempTable("KinGame2").tbInfo.nCurrentNeedIdx;
			local nNeedNum = MathRandom(KinGame2.WINE_NEED_TABLE[nNeedIdx][2][1],KinGame2.WINE_NEED_TABLE[nNeedIdx][2][2]);	
			pNpc.GetTempTable("KinGame2").tbInfo.nNeedNum = nNeedNum;
		end
	end
end


function tb1stRoom:UpdateWineUi(nStep)
	local szMsg = "<color=green>距离酿酒结束还有<color><color=white>%s<color>";
	local szState = "";
	if nStep == 1 then
		szState = "保护四个角落的酒坛不受酒鬼破坏\n\n点击酒坛后收集需要的材料\n\n保证三个酒坛酿酒成功\n\n";
		for nId,tbInfo in pairs(self.tbWine) do
			local pNpc = KNpc.GetById(nId);
			if tbInfo.bDead ~= 1 then
				if tbInfo.bFinishCollect ~= 1 then
					local nIdx = pNpc.GetTempTable("KinGame2").tbInfo.nCurrentNeedIdx;
					local nNeedNum = pNpc.GetTempTable("KinGame2").tbInfo.nNeedNum or 0;
					szState = szState .. string.format("%s酒坛:%s需要<color=green>%d<color>个\n\n",tbInfo.szTitle,KinGame2.WINE_NEED_TABLE[nIdx][1],nNeedNum);
				else
					szState = szState .. string.format("%s酒坛:<color=green>材料收集完成<color>\n\n",tbInfo.szTitle);
				end
			else
				szState = szState .. string.format("%s酒坛:<color=red>已经破损<color>\n\n",tbInfo.szTitle);
			end
		end
	elseif nStep == 2 then
		szState = "保护四个角落的酒坛不受酒鬼破坏\n\n点击酒坛后收集火种\n\n保证三个酒坛酿酒成功\n\n";
		for nId,tbInfo in pairs(self.tbWine) do
			local pNpc = KNpc.GetById(nId);
			if tbInfo.bDead ~= 1 then 
				if tbInfo.bFinishFire ~= 1 then
					local nCount = pNpc.GetTempTable("KinGame2").nCurrentFireNum or 0;
					szState = szState .. string.format("%s酒坛:需要<color=green>%d<color>个火种\n\n",tbInfo.szTitle,KinGame2.WINE_NEED_FIRE_MIN_NUM - nCount);
				else
					szState = szState .. string.format("%s酒坛:<color=green>已经酿制完成<color>\n\n",tbInfo.szTitle);
				end
			else
				szState = szState .. string.format("%s酒坛:<color=red>已经破损<color>\n\n",tbInfo.szTitle);
			end
		end
	end
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
end


--处理酒坛收集完成
function tb1stRoom:HandleCollectFinish(nNpcId)
	if not self.tbWine[nNpcId] then
		return 0;
	end
	self.tbWine[nNpcId].bFinishCollect = 1;
	self:CheckAllFinishCollect();
end

--是否都收集完成
function tb1stRoom:CheckAllFinishCollect()
	local nCount = 0;
	for _,tbInfo in pairs(self.tbWine) do
		if tbInfo.bFinishCollect == 1 or tbInfo.bDead == 1 then
			nCount = nCount + 1;
		end
	end
	if nCount == #KinGame2.WINE_NPC_POS then
		self.nStep = self.nStep + 1;
		for nId,_ in pairs(self.tbWine) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.GetTempTable("KinGame2").nStep = self.nStep;
			end
		end
		local szMsg = "<color=green>距离酿酒结束还有<color><color=white>%s<color>";
		local szState = "保护角落的酒坛不受酒鬼破坏\n\n点击酒坛后收集火种\n\n保证三个酒坛酿酒成功";
		self.tbBase:AllBlackBoard("干的不错，快去收集火种吧!");
		self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
		if self.nAddFoodsNpcTimer > 0 then
			Timer:Close(self.nAddFoodsNpcTimer);
			self.nAddFoodsNpcTimer = 0;
		end
		--清除谷物
		self.tbFoodsNpc = nil;
		ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.FOODS_NPC_TEMPLATEID);
		ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.CAIHUAZEI_NPC_TEMPLATEID);
		ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.BAICAOSHUSHENG_NPC_TEMPLATEID);
		--刷火种npc
		self:AddFireNpc();
		self.nAddFireNpcTimer = Timer:Register(KinGame2.ADD_FIRE_NPC_TIME * Env.GAME_FPS, self.AddFireNpc, self);
		for nId,tbInfo in pairs(self.tbWine) do
			local pNpc = KNpc.GetById(nId);
			if pNpc and tbInfo.bDead ~= 1 then
				pNpc.GetTempTable("KinGame2").nSearchFireTimer = Timer:Register(Env.GAME_FPS, self.SearchFire, self, nId);
			end
		end
		self:UpdateWineUi(self.nStep);
	end
end

function tb1stRoom:SearchFire(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		pNpc.GetTempTable("KinGame2").nSearchFireTimer = 0;
		return 0;
	end
	local bDead = pNpc.GetTempTable("KinGame2").bDead or 0;
	local bFailed = pNpc.GetTempTable("KinGame2").bFailed or 0;
	if bDead == 1 or bFailed == 1 then
		pNpc.GetTempTable("KinGame2").nSearchFireTimer = 0;
		return 0;
	end
	local nCount = pNpc.GetTempTable("KinGame2").nCurrentFireNum or 0;
	local tbFire,nNpcCount = KNpc.GetAroundNpcListByNpc(nNpcId,KinGame2.WINE_NEED_FIRE_MIN_DISTANCE,KinGame2.WINE_NEED_FIRE_ID);
	if nNpcCount > 0 then
		nCount = nNpcCount;
	end
	if KinGame2.WINE_NEED_FIRE_MIN_NUM - nCount > 0  then
		local szMsg = string.format("火还不够，加把劲!还需要%d个火种",KinGame2.WINE_NEED_FIRE_MIN_NUM - nCount);
 		pNpc.SendChat(szMsg); 
		pNpc.GetTempTable("KinGame2").nCurrentFireNum = nCount;
		self:UpdateWineUi(self.nStep);
	else
		local szMsg = "酒已酿好，稍后可进行品尝！";
		pNpc.SendChat(szMsg);
		self:HandleFireFinish(pNpc.dwId); 
		pNpc.GetTempTable("KinGame2").nCurrentFireNum = nCount;
		pNpc.GetTempTable("KinGame2").nSearchFireTimer = 0;
		self:UpdateWineUi(self.nStep);
		return 0;
	end		
end

--增加地上的食物
function tb1stRoom:AddFoodsNpc()
	if self.nStep > 1 then
		self.nAddFoodsNpcTimer = 0;
		self.tbFoodsNpc = nil;
		return 0;
	end
	if not self.tbFoodsNpc then
		self.tbFoodsNpc = {};
	end
	for nIndex,tbPos in ipairs(KinGame2.FOODS_WINE_NPC_POS) do
		if not self.tbFoodsNpc[nIndex] or not KNpc.GetById(self.tbFoodsNpc[nIndex]) then
			local pNpc = KNpc.Add2(KinGame2.FOODS_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			self.tbFoodsNpc[nIndex] = pNpc.dwId;
		end
	end
end

--增加火种npc
function tb1stRoom:AddFireNpc()
	if self.nStep > 2 then
		return 0;
	end
	for _,tbPos in pairs(KinGame2.FIRE_WINE_NPC_POS) do
		KNpc.Add2(KinGame2.FIRE_WINE_NPC_ID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	end
end


--增加普通npc
function tb1stRoom:AddNormalNpc()
	for _,tbPos in pairs(KinGame2.CAIHUAZEI_WINE_NPC_POS) do 
		KNpc.Add2(KinGame2.CAIHUAZEI_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2],1);
	end	
	for _,tbPos in pairs(KinGame2.BAICAOSHUSHENG_WINE_NPC_POS) do 
		KNpc.Add2(KinGame2.BAICAOSHUSHENG_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2],1);
	end	
end


--增加攻击酒坛的npc,定时刷
function tb1stRoom:AddAttackWineNpc()
	--如果已经关卡结束，则停止计时器
	if self.nIsFinished == 1 then
		self.nAddAttackNpcTimer = 0;
		return 0;
	end
	for nIndex,tbPos in pairs(KinGame2.ATTACK_WINE_NPC_POS) do 
		local pNpc = KNpc.Add2(KinGame2.ATTACK_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		local nAiIndex = MathRandom(#KinGame2.tbAttackWineNpcAiPos);
		pNpc.AI_ClearPath();
		for _,tbPos in ipairs(KinGame2.tbAttackWineNpcAiPos[nAiIndex]) do
			if (tbPos[1] and tbPos[2]) then
				pNpc.AI_AddMovePos(tbPos[1], tbPos[2]);
			end
		end
		pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
		pNpc.SetActiveForever(1);
		pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self,nAiIndex,pNpc.dwId};
	end
end

--攻击酒坛的npc的ai回调
function tb1stRoom:OnArrive(nAiIndex,nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
	for nId,tbInfo in pairs(self.tbWine) do
		if tbInfo.nAiIndex == nAiIndex then
			self.tbWine[nId].nAttackedCount = self.tbWine[nId].nAttackedCount + 1;
			if self.tbWine[nId].nAttackedCount >= KinGame2.WARN_ATTACK_WINE_COUNT and self.tbWine[nId].bDead ~= 1 then
				local pNpc = KNpc.GetById(nId);
				if pNpc then
					pNpc.SendChat("酒鬼偷走了好多酒，注意保护!");
				end
			end
			if self.tbWine[nId].nAttackedCount >= KinGame2.MAX_ATTACK_WINE_COUNT then
				self.tbWine[nId].bDead = 1;
				local pNpc = KNpc.GetById(nId);
				if pNpc then
					if not pNpc.GetTempTable("KinGame2").bDead or pNpc.GetTempTable("KinGame2").bDead ~= 1 then
						pNpc.GetTempTable("KinGame2").bDead = 1;
						self.tbBase:AllBlackBoard("有一个酒坛已经酒鬼破坏了");
					end
				end
			end
			break;
		end
	end
	self:UpdateWineUi(self.nStep);
	local nCount = 0;
	for _,tbInfo in pairs(self.tbWine) do
		if tbInfo.bDead == 1 then
			nCount = nCount + 1;
		end
	end
	--2酒坛都挂了，游戏失败
	if nCount >= KinGame2.MAX_DEAD_WINE then
		self:EndRoom();
	else
		if self.nStep == 1 then
			self:CheckAllFinishCollect();	--如果失败了一个检测是否过关
		elseif self.nStep == 2 then
			self:CheckAllFinishFire();
		end
	end
end

--处理烤火完成
function tb1stRoom:HandleFireFinish(nNpcId)
	if not nNpcId or not self.tbWine[nNpcId] then
		return 0;
	end
	self.tbWine[nNpcId].bFinishFire = 1;
	self:CheckAllFinishFire();
end

--检测是否全部烤火完成
function tb1stRoom:CheckAllFinishFire()
	local nCount = 0;
	for _,tbInfo in pairs(self.tbWine) do
		if tbInfo.bFinishFire == 1 or tbInfo.bDead == 1 then
			nCount = nCount + 1;
		end
	end
	if nCount == #KinGame2.WINE_NPC_POS then
		self.nStep = self.nStep + 1;
		for nId,_ in pairs(self.tbWine) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.GetTempTable("KinGame2").nStep = self.nStep;
			end
		end
		self:EndRoom();	
	end
end

--结束了清除npc
function tb1stRoom:ClearRoom()
	if not self.tbBase then
		return 0;
	end
	if self.nRoomTimer and self.nRoomTimer > 0 then
		Timer:Close(self.nRoomTimer);
		self.nRoomTimer = 0;
	end
	if self.nAddAttackNpcTimer and self.nAddAttackNpcTimer > 0 then
		Timer:Close(self.nAddAttackNpcTimer);
		self.nAddAttackNpcTimer = 0;
	end
	if self.nAddFoodsNpcTimer and self.nAddFoodsNpcTimer > 0 then
		Timer:Close(self.nAddFoodsNpcTimer);
		self.nAddFoodsNpcTimer = 0;
	end
	if self.nAddFireNpcTimer and self.nAddFireNpcTimer > 0 then
		Timer:Close(self.nAddFireNpcTimer);
		self.nAddFireNpcTimer = 0;
	end
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	if self.tbWine then
		for nId,_ in pairs(self.tbWine) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				local nTimer = pNpc.GetTempTable("KinGame2").nSearchFireTimer;
				if nTimer and nTimer > 0 then
					Timer:Close(nTimer);
					pNpc.GetTempTable("KinGame2").nSearchFireTimer = 0;
				end
			end
		end
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.ATTACK_NPC_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.FOODS_NPC_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.WINE_NEED_FIRE_ID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.FIRE_WINE_NPC_ID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.CAIHUAZEI_NPC_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.BAICAOSHUSHENG_NPC_TEMPLATEID);
end
-------------1号房间逻辑end-----------------------------------------------------


-------------2号房间start-------------------------------------------------------
function tb2ndRoom:StartRoom(nRet)
	if not self.tbBase then
		return 0;
	end
	self.nIsStart = 1;
	self.nIsFinished = 0;
	self.nIsSucess = 0;
	self:AddStartWaitNpc();
	self.nStartTimer = Timer:Register(30 * Env.GAME_FPS,self.StartAddNpc,self,nLastRet);
	local szMsg = "<color=green>距离第二关开启还有<color><color=white>%s<color>";
	local szState = "";
	if nRet and nRet == 1 then
		szState = "可以去酒坛处品尝美酒";
	end
	self.tbBase:UpdateUiState(szMsg,self.nStartTimer,szState);
end

function tb2ndRoom:AddStartWaitNpc()
	local tbPos = KinGame2.WAIT_NPC_POS;
	self.pWaitNpc = KNpc.Add2(KinGame2.WAIT_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end

function tb2ndRoom:StartAddNpc()
	if self.pWaitNpc then
		self.pWaitNpc.Delete();
		self.pWaitNpc = nil;
	end
	self.nStartTimer = 0;
	self:AddBoss();
	self.nRoomTimer = Timer:Register(KinGame2.ROOM_TIME_LIMIT[2] * Env.GAME_FPS, self.EndRoomTime, self);
	self.tbBase:AllBlackBoard("竭尽全力击败逍遥书生");
	local szMsg = "<color=green>第二关结束还有<color><color=white>%s<color>";
	local szState = "在规定时间内击败逍遥书生";
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
	return 0;
end

function tb2ndRoom:AddBoss()
	local tbPos = KinGame2.XOYO_SHUSHENG_POS;
	self.pBoss = KNpc.Add2(KinGame2.XOYO_SHUSHENG_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	Npc:RegPNpcOnDeath(self.pBoss, self.OnDeath_Boss, self);
end

function tb2ndRoom:OnDeath_Boss(pKiller)
	him.DropRateItem(KinGame2.DROPRATE_FILE,16,-1,-1,0);	--boss掉落
	self.nIsSucess = 1;
	self:EndRoom();
end

function tb2ndRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb2ndRoom:EndRoomTime()
	if self.pBoss then
		self.pBoss.Delete();
	end
	self.nRoomTimer = 0;
	self:EndRoom();
	return 0;
end

function tb2ndRoom:ClearRoom()
	if self.nRoomTimer and self.nRoomTimer > 0 then
		Timer:Close(self.nRoomTimer);
		self.nRoomTimer = 0;
	end
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.XOYO_SHUSHENG_TEMPLATEID);
end

function tb2ndRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb2ndRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb2ndRoom:RoomFinish()
	if self.nIsSucess == 1 then
		self.tbBase:RoomFinish(2,1);
		self.tbBase:AllBlackBoard("汝等非等闲，前路更艰险");
	else
		self.tbBase:RoomFinish(2,0);
		self.tbBase:AllBlackBoard("汝等武艺尚浅，莫要气馁");
	end
	self.tbBase:AddAllPlayerExp(2,self.nIsSucess);		--加经验
	self.tbBase:GiveAllPlayerRepute(2,self.nIsSucess);	--加家族声望
	self.tbBase:GiveAllPlayerAwardItem(2,self.nIsSucess);	--过关加的古币
end
-------------2号房间end----------------------------------------------------------

-------------3号房间start-------------------------------------------------------
function tb3rdRoom:StartRoom()
	if not self.tbBase then
		return 0;
	end
	self.nIsStart = 1;
	self.nIsFinished = 0;
	self.nIsSucess = 0;
	self.nAddEnemyCount = 0;	--刷怪的次数,3波刷一次大的
	self:AddStartWaitNpc();
	self.nStartTimer = Timer:Register(30 * Env.GAME_FPS,self.StartAddNpc,self);	--开启房间的延迟
	local szMsg = "<color=green>距离第三关开启还有<color><color=white>%s<color>";
	local szState = "";
	self.tbBase:UpdateUiState(szMsg,self.nStartTimer,szState);
end

function tb3rdRoom:AddStartWaitNpc()
	local tbPos = KinGame2.WAIT_NPC_POS;
	self.pWaitNpc = KNpc.Add2(KinGame2.WAIT_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end

function tb3rdRoom:StartAddNpc()
	if self.pWaitNpc then
		self.pWaitNpc.Delete();
		self.pWaitNpc = nil;
	end
	self:AddNpc();
	self:AddEnemy();
	self.nStartTimer = 0;
	self.nAddEnemyTimer = Timer:Register(15 * Env.GAME_FPS,self.AddEnemy,self);
	self.nRoomTimer = Timer:Register(KinGame2.ROOM_TIME_LIMIT[3] * Env.GAME_FPS, self.EndRoomTime, self);
	self.tbBase:AllBlackBoard("保护无忧书生不受到攻击");
	local szMsg = "<color=green>第三关结束还有<color><color=white>%s<color>";
	local szState = "保护无忧书生";
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
	return 0;
end

function tb3rdRoom:AddNpc()
	local tbPos = KinGame2.WUYOU_SHUSHENG_POS;
	self.pNpc = KNpc.Add2(KinGame2.WUYOU_SHUSHENG_TEMPLATEID,130,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	for i = 1 , #KinGame2.SHUSHENG_WARING_PERCENT do
		self.pNpc.AddLifePObserver(KinGame2.SHUSHENG_WARING_PERCENT[i]);
	end
end

function tb3rdRoom:OnNpc_Death()
	if self.pNpc then
		self.pNpc.Delete();
	end
	self.nIsSucess = 0;
	self:EndRoom();	
end

function tb3rdRoom:AddEnemy()
	if self.nIsFinished == 1 then
		self.nAddEnemyTimer = 0;
		return 0;
	end
	local nAddCount = 1;
	self.nAddEnemyCount = self.nAddEnemyCount + 1;
	local tbEnemyPos = KinGame2.SHUSHENG_ENEMY_POS;
	if self.nAddEnemyCount >= 4 then
		tbEnemyPos = KinGame2.SHUSHENG_ENEMY_BIG_POS;
		self.nAddEnemyCount = 0;
		self.tbBase:AllBlackBoard("一大批疯狂的学生向无忧书生发起进攻");
	end 
	for nDirection,tbPosA in pairs(tbEnemyPos) do
		for nIndex,tbPos in pairs(tbPosA) do
			local pNpc = KNpc.Add2(KinGame2.SHUSHENG_ENEMY_TEMPLATEID[nIndex%3 + 1],self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			local tbAi = KinGame2.ROOM3_AI_POS[nDirection];
			pNpc.AI_ClearPath();
			if tbAi then
				for _,tbAiPos in ipairs(tbAi) do
					if tbAiPos[1] and tbAiPos[2] then
						pNpc.AI_AddMovePos(tbAiPos[1],tbAiPos[2]);
					end	
				end
				pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
				pNpc.SetActiveForever(1);
				pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self,pNpc.dwId};
			end
		end
	end
end

function tb3rdRoom:AddNormalNpc()
	self.nLeftEnemyCount = 0;
	self.nRightEnemyCount = 0;
	for _,tbPos in pairs(KinGame2.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_LEFT) do
		local pLeft = KNpc.Add2(KinGame2.NORMAL_ENEMY_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nLeftEnemyCount = self.nLeftEnemyCount + 1;
		Npc:RegPNpcOnDeath(pLeft, self.OnAddOpenSwitchNpc, self,1); 
	end
	for _,tbPos in pairs(KinGame2.JIGUANLANG_POS[1]) do
		local pLeft = KNpc.Add2(KinGame2.JIGUANLANG_TEMPLATE_ID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nLeftEnemyCount = self.nLeftEnemyCount + 1;
		Npc:RegPNpcOnDeath(pLeft, self.OnAddOpenSwitchNpc, self,1); 
	end
	for _,tbPos in pairs(KinGame2.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_RIGHT) do
		local pRight = KNpc.Add2(KinGame2.NORMAL_ENEMY_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nRightEnemyCount = self.nRightEnemyCount + 1;
		Npc:RegPNpcOnDeath(pRight, self.OnAddOpenSwitchNpc, self,2); 
	end
	for _,tbPos in pairs(KinGame2.JIGUANLANG_POS[2]) do
		local pRight = KNpc.Add2(KinGame2.JIGUANLANG_TEMPLATE_ID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nRightEnemyCount = self.nRightEnemyCount + 1;
		Npc:RegPNpcOnDeath(pRight, self.OnAddOpenSwitchNpc, self,2); 
	end
end


function tb3rdRoom:OnAddOpenSwitchNpc(nDirection)
	if nDirection == 1 then
		self.nLeftEnemyCount = self.nLeftEnemyCount - 1;
		if self.nLeftEnemyCount <= KinGame2.MAX_NUM_ENEMY_ADD_SHOUHUZHE and not self.pLeft then
			local tbLeftPos = KinGame2.LEFT_SWITCH_ENEMY_POS;
			self.pLeft = KNpc.Add2(KinGame2.LEFT_SWITCH_ENEMY_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbLeftPos[1],tbLeftPos[2]);
			Npc:RegPNpcOnDeath(self.pLeft, self.OnOpenSwitch, self,1);
		end
	elseif nDirection == 2 then
		self.nRightEnemyCount = self.nRightEnemyCount - 1;
		if self.nRightEnemyCount <= KinGame2.MAX_NUM_ENEMY_ADD_SHOUHUZHE and not self.pRight then
			local tbRightPos = KinGame2.RIGHT_SWITCH_ENEMY_POS;
			self.pRight = KNpc.Add2(KinGame2.RIGHT_SWITCH_ENEMY_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbRightPos[1],tbRightPos[2]);		
			Npc:RegPNpcOnDeath(self.pRight, self.OnOpenSwitch, self,2);
		end
	end
end


function tb3rdRoom:OnOpenSwitch(nDirection)
	local tbPos = KinGame2.TRAP_SWITCH_NPC_POS[4][nDirection];
	local pNpc = KNpc.Add2(KinGame2.nTrapSwitchNpcTemplateId,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	pNpc.GetTempTable("KinGame2").nRoomId = 4;
	pNpc.GetTempTable("KinGame2").nDirection = nDirection;
end


function tb3rdRoom:OnArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if self.pNpc then
		self.pNpc.ReduceLife(KinGame2.SHUSHENG_REDUCE_BLOOD[pNpc.nTemplateId]);
		if self.pNpc.nCurLife <= 0 then
			self:OnNpc_Death();
		end
	end
	pNpc.Delete();
end

function tb3rdRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb3rdRoom:EndRoomTime()
	if not self.pNpc or self.pNpc.nCurLife <= 0 then
		self.nIsSucess = 0;
	else
		self.nIsSucess = 1;
	end
	self.nRoomTimer = 0;
	self:EndRoom();
	return 0;
end

function tb3rdRoom:ClearRoom()
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	if self.nRoomTimer and self.nRoomTimer > 0 then
		Timer:Close(self.nRoomTimer);
		self.nRoomTimer = 0;
	end
	if self.nAddEnemyTimer and self.nAddEnemyTimer > 0 then
		Timer:Close(self.nAddEnemyTimer);
		self.nAddEnemyTimer = 0;
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.WUYOU_SHUSHENG_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.FENGKUANG_RUSHENG_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.SHUTONG_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.BANDUSHINV_TEMPLATEID);
end

function tb3rdRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb3rdRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb3rdRoom:RoomFinish()
	if self.nIsSucess == 1 then
		self.tbBase:RoomFinish(3,1);
		self.tbBase:AllBlackBoard("谢谢你们，兵分两路清理小岛的怪物，打开前方的路口");
	else
		self.tbBase:RoomFinish(3,0);
		self.tbBase:AllBlackBoard("我轻轻地走了，两边小岛的怪物是通往前方的关键");
	end
	self.tbBase:AddAllPlayerExp(3,self.nIsSucess);		--加经验
	self.tbBase:GiveAllPlayerRepute(3,self.nIsSucess);	--加家族声望
	self.tbBase:GiveAllPlayerAwardItem(3,self.nIsSucess);	--过关加的古币
	local szMsg = "";
	local szState = "兵分两路，清理小岛\n\n开启龙柱";
	self.tbBase:UpdateUiState(szMsg,nil,szState);
	self:AddNormalNpc();	--增加同往第四关的一些npc
end
-------------3号房间end----------------------------------------------------------

-------------4号房间start-------------------------------------------------------
function tb4thRoom:StartRoom()
	if not self.tbBase then
		return 0;
	end
	self.nIsStart = 1;
	self.nIsFinished = 0;
	self.nIsSucess = 0;
	self.nIsChangedBoss = 0; --是否交换过boss
	self.nIsWaring = 0;	--是否通知过要同时击杀
	self.nIsStartScan = 0;	--是否已经开启检测同时击杀
	self.nIsDuguDeath = 0;
	self.nIsDongguoDeath = 0;
	self:AddBoss();
	self.nRoomTimer = Timer:Register(KinGame2.ROOM_TIME_LIMIT[4] * Env.GAME_FPS, self.EndRoomTime, self);
	self.tbBase:AllBlackBoard("危险降临，大家小心为妙");
	local szMsg = "<color=green>第四关结束还有<color><color=white>%s<color>";
	local szState = "同时击杀东郭逸尘和独孤若兰";
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
end


function tb4thRoom:AddBoss()
	local tbDuguPos = KinGame2.DUGURUOLAN_NPC_POS;
	local tbDongguoPos = KinGame2.DUOGUOYICHEN_NPC_POS;
	self.pDugu = KNpc.Add2(KinGame2.DUGURUOLAN_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbDuguPos[1],tbDuguPos[2]);
	self.pDongguo =  KNpc.Add2(KinGame2.DUOGUOYICHEN_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbDongguoPos[1],tbDongguoPos[2]);
	self.pDugu.AddLifePObserver(KinGame2.CHANGE_LIFE_PERCENT);
	self.pDongguo.AddLifePObserver(KinGame2.CHANGE_LIFE_PERCENT);
	self.pDugu.AddLifePObserver(KinGame2.WARNING_LIFE_PERCENT);
	self.pDongguo.AddLifePObserver(KinGame2.WARNING_LIFE_PERCENT);
end

function tb4thRoom:ChangeBoss()
	self.nIsChangedBoss = 1;
	self.nDuguLifeReduce = self.pDugu.nMaxLife - self.pDugu.nCurLife;
	self.nDongguoLifeReduce = self.pDongguo.nMaxLife - self.pDongguo.nCurLife;	
	self.pDugu.Delete();
	self.pDongguo.Delete();
	local tbDuguPos = KinGame2.DUGURUOLAN_NPC_POS;
	local tbDongguoPos = KinGame2.DUOGUOYICHEN_NPC_POS;
	self.pDugu = KNpc.Add2(KinGame2.DUGURUOLAN_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbDongguoPos[1],tbDongguoPos[2]);
	self.pDongguo =  KNpc.Add2(KinGame2.DUOGUOYICHEN_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbDuguPos[1],tbDuguPos[2]);
	self.pDugu.ReduceLife(self.nDuguLifeReduce);
	self.pDongguo.ReduceLife(self.nDongguoLifeReduce);
	self.pDugu.AddLifePObserver(KinGame2.WARNING_LIFE_PERCENT);
	self.pDongguo.AddLifePObserver(KinGame2.WARNING_LIFE_PERCENT);
	Npc:RegPNpcOnDeath(self.pDugu, self.OnDeath_Boss_Dugu, self);
	Npc:RegPNpcOnDeath(self.pDongguo, self.OnDeath_Boss_Dongguo, self);
end

function tb4thRoom:OnDeath_Boss_Dongguo(pKiller)
	him.DropRateItem(KinGame2.DROPRATE_FILE,12,-1,-1,0); --boss掉落
	self.nIsDongguoDeath = 1;
	if self.nIsDongguoDeath == 1 and self.nIsDuguDeath == 1 then
		self.nIsSucess = 1;
		self:EndRoom();
		return 0;
	end
	if self.nIsStartScan == 1 then
		return 0;
	end 
	self.nIsStartScan = 1;
	self.nScanKillTimer = Timer:Register(KinGame2.KILL_BOSS_DELAY * Env.GAME_FPS, self.ScanKill, self);
end

function tb4thRoom:OnDeath_Boss_Dugu(pKiller)
	him.DropRateItem(KinGame2.DROPRATE_FILE,12,-1,-1,0); --boss掉落
	self.nIsDuguDeath = 1;
	if self.nIsDongguoDeath == 1 and self.nIsDuguDeath == 1 then
		self.nIsSucess = 1;
		self:EndRoom();
		return 0;
	end
	if self.nIsStartScan == 1 then
		return 0;
	end 
	self.nIsStartScan = 1;
	self.nScanKillTimer = Timer:Register(KinGame2.KILL_BOSS_DELAY * Env.GAME_FPS, self.ScanKill, self);
end

function tb4thRoom:ScanKill()
	if self:CheckBossDeath() == 1 then
		self.nIsSucess = 1;
	end
	self.nScanKillTimer = 0;
	self:EndRoom();
	return 0;
end

function tb4thRoom:CheckBossDeath()
	if self.nIsDuguDeath == 1 and self.nIsDongguoDeath == 1 then
		return 1;
	end
	return 0;
end

function tb4thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb4thRoom:EndRoomTime()
	self.nRoomTimer = 0;
	self:EndRoom();
	return 0;
end

function tb4thRoom:ClearRoom()
	if self.nRoomTimer and self.nRoomTimer > 0 then
		Timer:Close(self.nRoomTimer);
		self.nRoomTimer = 0;
	end
	if self.nScanKillTimer and self.nScanKillTimer > 0 then
		Timer:Close(self.nScanKillTimer);
		self.nScanKillTimer = 0;
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.DUGURUOLAN_NPC_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.DUOGUOYICHEN_NPC_TEMPLATEID);
end

function tb4thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb4thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb4thRoom:RoomFinish()
	if self.nIsSucess == 1 then
		self.tbBase:RoomFinish(4,1);
	else
		self.tbBase:RoomFinish(4,0);
		self.tbBase:AllBlackBoard("吃得苦中苦,方为人上人,你们要学的还很多");
		local szMsg = "";
		local szState = "小心前方的机关";
		self.tbBase:UpdateUiState(szMsg,nil,szState);
	end
	self.tbBase:AddAllPlayerExp(4,self.nIsSucess);		--加经验
	self.tbBase:GiveAllPlayerRepute(4,self.nIsSucess);	--加家族声望
	self.tbBase:GiveAllPlayerAwardItem(4,self.nIsSucess);	--过关加的古币
end
-------------4号房间end----------------------------------------------------------


-------------5号房间start-------------------------------------------------------
function tb5thRoom:StartRoom()
	if not self.tbBase then
		return 0;
	end
	self.nIsStart = 1;
	self.nIsFinished = 0;
	self.nIsSucess = 0;
	self.nIsBmyDead = 0;
	self.nIsBmjjDead = 0;
	self:AddStartWaitNpc();
	self.nStartTimer = Timer:Register(15 * Env.GAME_FPS,self.StartAddNpc,self);	--开启房间的延迟
	self.tbBase:AllBlackBoard("远处传来了诡异的读书声");
	local szMsg = "<color=green>距离第五关开启还有<color><color=white>%s<color>";
	local szState = "";
	self.tbBase:UpdateUiState(szMsg,self.nStartTimer,szState);
end

function tb5thRoom:AddStartWaitNpc()
	local tbPosLeft = KinGame2.BAIMAYI_NPC_POS;
	local tbPosRight = KinGame2.BAIMAJUNJIE_NPC_POS;
	self.pWaitNpcLeft = KNpc.Add2(KinGame2.WAIT_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPosLeft[1],tbPosLeft[2]);
	self.pWaitNpcRight = KNpc.Add2(KinGame2.WAIT_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPosRight[1],tbPosRight[2]);
end

function tb5thRoom:StartAddNpc()
	if self.pWaitNpcLeft then
		self.pWaitNpcLeft.Delete();
		self.pWaitNpcLeft = nil;
	end
	if self.pWaitNpcRight then
		self.pWaitNpcRight.Delete();
		self.pWaitNpcRight = nil;
	end
	self.nStartTimer = 0;
	self:AddBoss();
	self.nRoomTimer = Timer:Register(KinGame2.ROOM_TIME_LIMIT[5] * Env.GAME_FPS, self.EndRoomTime, self);
	self.nAddShadowTimer = Timer:Register(KinGame2.ADD_JUNJIE_SHADOW_DELAY * Env.GAME_FPS, self.OnAddShadow, self);
	local szMsg = "<color=green>第五关结束还有<color><color=white>%s<color>";
	local szState = "分别击杀白马懿和白马俊杰";
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
	return 0;
end

function tb5thRoom:AddBoss()
	local tbBmyPos = KinGame2.BAIMAYI_NPC_POS;
	self.tbBaimayi = KNpc.Add2(KinGame2.BAIMAYI_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbBmyPos[1],tbBmyPos[2]);
	local tbJunjiePos = KinGame2.BAIMAJUNJIE_NPC_POS;
	self.tbBaimajunjie = KNpc.Add2(KinGame2.BAIMAJUNJIE_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbJunjiePos[1],tbJunjiePos[2]);
	for i = 1,#KinGame2.ADD_ARMY_PERCENT do
		Npc:RegPNpcLifePercentReduce(self.tbBaimajunjie, KinGame2.ADD_ARMY_PERCENT[i], self.AddArmy,self);
	end
	Npc:RegPNpcOnDeath(self.tbBaimajunjie, self.OnDeath_Boss_Bmjj, self);
	Npc:RegPNpcOnDeath(self.tbBaimayi, self.OnDeath_Boss_Bmy, self);
end

function tb5thRoom:OnDeath_Boss_Bmjj(pKiller)
	him.DropRateItem(KinGame2.DROPRATE_FILE,14,-1,-1,0); --boss掉落
	if self.nAddShadowTimer and self.nAddShadowTimer > 0 then
		Timer:Close(self.nAddShadowTimer);
		self.nAddShadowTimer = 0;
	end
	self.nIsBmjjDead = 1;
	if self.nIsBmjjDead == 1 and self.nIsBmyDead == 1 then
		self.nIsSucess = 1;
		self:EndRoom();
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.JUNJIE_SHADOW_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.SHUSHENG_ARMY_TEMPLATEID);
end

function tb5thRoom:OnDeath_Boss_Bmy(pKiller)
	him.DropRateItem(KinGame2.DROPRATE_FILE,14,-1,-1,0); --boss掉落
	self.nIsBmyDead = 1;
	if self.nIsBmjjDead == 1 and self.nIsBmyDead == 1 then
		self.nIsSucess = 1;
		self:EndRoom();
	end
end

--增加影子
function tb5thRoom:OnAddShadow()
	if self.nIsBmjjDead == 1 then	--如果boss死了，停止刷影子
		self.nAddShadowTimer = 0;
		return 0;
	end
	self.nScanCastTimer = Timer:Register(KinGame2.AOE_SKILL_DELAY * Env.GAME_FPS, self.OnCastSkill, self);
	local tbShadowPos = KinGame2.JUNJIE_SHADOW_POS;
	self.nShadowCount = 0;
	for _,tbPos in pairs(tbShadowPos) do
		local pNpc = KNpc.Add2(KinGame2.JUNJIE_SHADOW_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nShadowCount = self.nShadowCount + 1;
		Npc:RegPNpcOnDeath(pNpc, self.OnDeath_Shadow, self);
	end
end

function tb5thRoom:OnCastSkill()
	if self.nShadowCount and self.nShadowCount > 0 then
		if self.tbBaimajunjie then
			local _ , x, y = self.tbBaimajunjie.GetWorldPos();
			self.tbBaimajunjie.CastSkill(KinGame2.AOE_SKILL_ID_5TH,10,x * 32,y * 32,1);
		end
	end
	return 0;
end

function tb5thRoom:OnDeath_Shadow()
	self.nShadowCount = self.nShadowCount - 1;
	if self.nShadowCount <= 0 then
		self.nShadowCount = 0;
	end
end

--加书生大军
function tb5thRoom:AddArmy()
	if self.tbBaimajunjie then
		local szMsg = "出来吧，我的学生们！";
		self.tbBaimajunjie.SendChat(szMsg);
	end
	for _,tbPos in pairs(KinGame2.SHUSHENG_ARMY_POS) do
		if tbPos[1] and tbPos[2] then
			KNpc.Add2(KinGame2.SHUSHENG_ARMY_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		end
	end
end

function tb5thRoom:EndRoomTime()
	if self.nIsBmjjDead == 1 and self.nIsBmyDead == 1 then
		self.nIsSucess = 1;
	end
	self.nRoomTimer = 0;	
	self:EndRoom();	
	return 0;
end

function tb5thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb5thRoom:ClearRoom()
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	if self.nRoomTimer and self.nRoomTimer > 0 then
		Timer:Close(self.nRoomTimer);
		self.nRoomTimer = 0;
	end
	if self.nAddShadowTimer and self.nAddShadowTimer > 0 then
		Timer:Close(self.nAddShadowTimer);
		self.nAddShadowTimer = 0;
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.BAIMAYI_NPC_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.BAIMAJUNJIE_NPC_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.JUNJIE_SHADOW_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.SHUSHENG_ARMY_TEMPLATEID);
end

function tb5thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb5thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb5thRoom:RoomFinish()
	if self.nIsSucess == 1 then
		self.tbBase:RoomFinish(5,1);
		self.tbBase:AllBlackBoard("书到用时方恨少，你们走吧，哼");
	else
		self.tbBase:RoomFinish(5,0);
		self.tbBase:AllBlackBoard("我白马兄弟岂会败给无名小辈");
	end
	self.tbBase:AddAllPlayerExp(5,self.nIsSucess);		--加经验
	self.tbBase:GiveAllPlayerRepute(5,self.nIsSucess);	--加家族声望
	self.tbBase:GiveAllPlayerAwardItem(5,self.nIsSucess);	--过关加的古币
	local szMsg = "";
	local szState = "小心前方的机关";
	self.tbBase:UpdateUiState(szMsg,nil,szState);
end
-------------5号房间end----------------------------------------------------------


-------------6号房间start-------------------------------------------------------
function tb6thRoom:StartRoom()
	if not self.tbBase then
		return 0;
	end
	self.nIsStart = 1;
	self.nIsFinished = 0;
	self.nIsSucess = 0;
	self.nIsSwitchOpen = 0;
	self:AddBook();
	self.nStartTimer = Timer:Register(30 * Env.GAME_FPS,self.StartAddNpc,self);	--开启房间的延迟
	self.tbBase:AllBlackBoard("地上出现了一些神秘残卷，阅读后将功力倍增");
	local szMsg = "<color=green>距离第六关开启还有<color><color=white>%s<color>";
	local szState = "点击地上的残卷";
	self.tbBase:UpdateUiState(szMsg,self.nStartTimer,szState);
end

function tb6thRoom:AddBook()
	local nCount = self.tbBase:GetPlayerCount();
	if nCount <= 0 then
		return 0;
	end
	local nAddBookCount = math.ceil(nCount / 3);
	local tbIndex = {};
	for i = 1 ,#KinGame2.BOOK_POS do
		tbIndex[i] = i;	
	end
	local tbAddPos = {};
	for i = 1,nAddBookCount do
		local nPos = MathRandom(#tbIndex);
		table.insert(tbAddPos,tbIndex[nPos]);
		table.remove(tbIndex,nPos);
	end
	for _,nIndex in pairs(tbAddPos) do
		local tbPos = KinGame2.BOOK_POS[nIndex];
		local nTemplateId = KinGame2.BOOK_TEMPLATE_ID[MathRandom(#KinGame2.BOOK_TEMPLATE_ID)];
		local pNpc = KNpc.Add2(nTemplateId,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		pNpc.GetTempTable("KinGame2").nPickedCount = 0;
	end
end


function tb6thRoom:StartAddNpc()
	self.nStartTimer = 0;
	self.tbNormalEnemy = {};
	self.nNormalCount = 0;
	self:AddBoss();
	self.nStartTimer = 0;
	self.nRoomTimer = Timer:Register(KinGame2.ROOM_TIME_LIMIT[6] * Env.GAME_FPS, self.EndRoomTime, self);
	self.tbBase:AllBlackBoard("敢偷我的书，汝等纳命来");
	local szMsg = "<color=green>第六关结束还有<color><color=white>%s<color>";
	local szState = "击杀司马雁南";
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
	return 0;
end


function tb6thRoom:AddBoss()
	local tbPos = KinGame2.SIMAYANNAN_NPC_POS;
	self.pBoss = KNpc.Add2(KinGame2.SIMAYANNAN_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	Npc:RegPNpcLifePercentReduce(self.pBoss , KinGame2.START_NEW_STEP_PERCENT, self.BossNewStep,self);
	Npc:RegPNpcOnDeath(self.pBoss, self.OnDeath_Boss, self);
end

function tb6thRoom:BossNewStep()
	self:AddNormal();
	self.nCastAoeTimer = Timer:Register(KinGame2.AOE_CAST_SCAN_TIMER * Env.GAME_FPS,self.CastAoe,self);
	self.nAddNormalTimer = Timer:Register(KinGame2.ADD_LIXUEWEISHI_SCAN_DELAY * Env.GAME_FPS,self.AddNormal,self);
end

function tb6thRoom:CastAoe()
	if self.nIsFinished == 1 then
		self.nCastAoeTimer = 0;
		return 0;
	end
	local tbNpc,nCount =  KNpc.GetAroundNpcListByNpc(self.pBoss.dwId,50,KinGame2.FREEZE_NPC_TEMPLATEID);
	if self.pBoss then
		if nCount > 0 then
			local _ , x , y = self.pBoss.GetWorldPos();
			self.pBoss.CastSkill(KinGame2.AOE_SKILL_ID_6TH,1,x*32,y*32,1);
		end
	end
end

function tb6thRoom:AddNormal()
	for _,tbPos in pairs(KinGame2.LIXUEWEISHI_NPC_POS) do
		local pNpc = KNpc.Add2(KinGame2.LIXUEWEISHI_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		table.insert(self.tbNormalEnemy,pNpc);
		self.nNormalCount = self.nNormalCount + 1;
		Npc:RegPNpcOnDeath(pNpc, self.OnDeath_Normal, self);
	end
	self.nAddAttackTimer = Timer:Register(KinGame2.ADD_LIXUEWEISHI_SCAN_DELAY * Env.GAME_FPS,self.AddAttack,self);
end

function tb6thRoom:AddAttack()
	if self.nNormalCount <= 0 then
		return 0;
	end
	if self.pBoss then
		self.pBoss.AddSkillState(KinGame2.ADD_ATTACK_SKILL_ID,1,1,KinGame2.ADD_ATTCK_TIME * Env.GAME_FPS,1,0,1);
	end
	for _,pNpc in pairs(self.tbNormalEnemy) do
		if pNpc then
			pNpc.AddSkillState(KinGame2.ADD_ATTACK_SKILL_ID,1,1,KinGame2.ADD_ATTCK_TIME * Env.GAME_FPS,1,0,1);
		end
	end
	return 0;
end

function tb6thRoom:OnDeath_Normal()
	self.nNormalCount = self.nNormalCount - 1;
	if self.nNormalCount <= 0 then
		self.nNormalCount = 0;
	end
end

function tb6thRoom:ClearTimer()
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	if self.nAddNormalTimer and self.nAddNormalTimer > 0 then
		Timer:Close(self.nAddNormalTimer);
		self.nAddNormalTimer = 0;
	end
	if self.nCastAoeTimer and self.nCastAoeTimer > 0 then
		Timer:Close(self.nCastAoeTimer);
		self.nCastAoeTimer = 0;
	end
	if self.nAddAttackTimer and self.nAddAttackTimer > 0 then
		Timer:Close(self.nAddAttackTimer);
		self.nAddAttackTimer = 0;
	end
	if self.nRoomTimer and self.nRoomTimer > 0 then
		Timer:Close(self.nRoomTimer);
		self.nRoomTimer = 0;
	end
end

function tb6thRoom:OnDeath_Boss(pKiller)
	him.DropRateItem(KinGame2.DROPRATE_FILE,17,-1,-1,0); --boss掉落
	self.nIsSucess = 1;
	self:EndRoom();	
end


function tb6thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb6thRoom:EndRoomTime()
	self.nRoomTimer = 0;
	self:EndRoom();
	return 0;
end

function tb6thRoom:ClearRoom()
	self:ClearTimer();	
	self.tbNormalEnemy = nil;
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.SIMAYANNAN_NPC_TEMPLATEID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.LIXUEWEISHI_NPC_TEMPLATEID);
end

function tb6thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb6thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb6thRoom:RoomFinish()
	if self.nIsSucess == 1 then
		self.tbBase:RoomFinish(6,1);
		self.tbBase:AllBlackBoard("算了，这些书就送给你们了，你们终究逃不过命运");
	else
		self.tbBase:RoomFinish(6,0);
		self.tbBase:AllBlackBoard("见识到了偷书者的下场了吧");
	end
	self.tbBase:AddAllPlayerExp(6,self.nIsSucess);		--加经验
	self.tbBase:GiveAllPlayerRepute(6,self.nIsSucess);	--加家族声望
	self.tbBase:GiveAllPlayerAwardItem(6,self.nIsSucess);	--过关加的古币
	self:AddSnake();
	local szMsg = "";
	local szState = "小心前方的蛇";
	self.tbBase:UpdateUiState(szMsg,nil,szState);
end

function tb6thRoom:AddSnake()
	if not self.nSnakeCount then
		self.nSnakeCount = 0;
	end
	for _,tbPos in pairs(KinGame2.TRAP_SNAKE_POS) do
		local pNpc = KNpc.Add2(KinGame2.TRAP_SNAKE_TEMPLATE_ID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nSnakeCount = self.nSnakeCount + 1;
		Npc:RegPNpcOnDeath(pNpc, self.OnDeath_Snake, self);
	end
end

function tb6thRoom:OnDeath_Snake()
	self.nSnakeCount = self.nSnakeCount - 1;
	if self.nSnakeCount <= 0 then
		self.nSnakeCount = 0;
	end
	if self.nSnakeCount <= 1 and self.nIsSwitchOpen == 0 then
		self.nIsSwitchOpen = 1;
		local tbPos = KinGame2.TRAP_SWITCH_NPC_POS[7][1];
		local pNpc = KNpc.Add2(KinGame2.nTrapSwitchNpcTemplateId,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		pNpc.GetTempTable("KinGame2").nRoomId = 7;
		pNpc.GetTempTable("KinGame2").nDirection = 1;
	end
end
-------------6号房间end----------------------------------------------------------


-------------7号房间start-------------------------------------------------------
function tb7thRoom:StartRoom()
	if not self.tbBase then
		return 0;
	end
	self.nIsStart = 1;
	self.nIsFinished = 0;
	self.nIsSucess = 0;
	self:AddStartWaitNpc();
	self.nStartTimer = Timer:Register(15 * Env.GAME_FPS,self.StartAddNpc,self);	--开启房间的延迟
	self.tbBase:AllBlackBoard("诡异的寂静让人感到不安");
	local szMsg = "<color=green>距离第七关开启还有<color><color=white>%s<color>";
	local szState = "";
	self.tbBase:UpdateUiState(szMsg,self.nStartTimer,szState);
end

function tb7thRoom:AddStartWaitNpc()
	local tbPos = KinGame2.XIMENFEIXUE_POS;
	self.pWaitNpc = KNpc.Add2(KinGame2.WAIT_NPC_TEMPLATEID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end

function tb7thRoom:StartAddNpc()
	if self.pWaitNpc then
		self.pWaitNpc.Delete();
		self.pWaitNpc = nil;
	end
	self.nStartTimer = 0;
	self:AddBoss();
	self.nRoomTimer = Timer:Register(KinGame2.ROOM_TIME_LIMIT[7] * Env.GAME_FPS, self.EndRoomTime, self);
	local szMsg = "<color=green>第七关结束还有<color><color=white>%s<color>";
	local szState = "击杀西门飞雪";
	self.tbBase:UpdateUiState(szMsg,self.nRoomTimer,szState);
	return 0;
end

function tb7thRoom:AddBoss()
	local tbPos = KinGame2.XIMENFEIXUE_POS;
	self.pBoss = KNpc.Add2(KinGame2.XIMENFEIXUE_TEMPLATE_ID,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	Npc:RegPNpcLifePercentReduce(self.pBoss, KinGame2.ADD_SHADOW_PERCENT, self.AddShadow,self);
end

function tb7thRoom:AddShadow()
	if not self.pBoss then
		return 0;
	end
	local nReduceLife = self.pBoss.nMaxLife - self.pBoss.nCurLife;	--新加的boss要减去血量
	self.pBoss.Delete();
	self.pBoss = nil;
	local tbNpcPos = {};
	local tbNpcTemplatId = {
		KinGame2.XIMENFEIXUE_TEMPLATE_ID,
		KinGame2.XIMENFEIXUE_UNREAL_TEMPLATE_ID,
		KinGame2.XIMENFEIXUE_UNREAL_TEMPLATE_ID
		};
	for _,tbPos in pairs(KinGame2.XIMENFEIXUE_UNREAL_POS) do
		table.insert(tbNpcPos,{tbPos[1],tbPos[2]});
	end
	for i = 1,#KinGame2.XIMENFEIXUE_UNREAL_POS do
		local nIdIndex = MathRandom(#tbNpcTemplatId);
		local nTemplateId = tbNpcTemplatId[nIdIndex];
		table.remove(tbNpcTemplatId,nIdIndex);
		local nPosIndex = MathRandom(#tbNpcPos);
		local tbPos = tbNpcPos[nPosIndex];
		table.remove(tbNpcPos,nPosIndex);
		if nTemplateId == KinGame2.XIMENFEIXUE_TEMPLATE_ID then
			self.pBoss =  KNpc.Add2(nTemplateId,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			self.pBoss.ReduceLife(nReduceLife);
			Npc:RegPNpcOnDeath(self.pBoss, self.OnDeath_Boss, self);
		else
			local pShadow = KNpc.Add2(nTemplateId,self.tbBase.nMonsterAvgLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			pShadow.ReduceLife(nReduceLife);
			Npc:RegPNpcOnDeath(pShadow, self.OnDeath_Shadow, self);
		end
	end 
end

function tb7thRoom:OnDeath_Boss(pKiller)
	him.DropRateItem(KinGame2.DROPRATE_FILE,22,-1,-1,0); --boss掉落
	self.nIsSucess = 1;
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			Achievement:FinishAchievement(pPlayer,395);
		end
	end
	self:EndRoom();
end


function tb7thRoom:OnDeath_Shadow()
	--有一个死了，另一个也死了
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.XIMENFEIXUE_UNREAL_TEMPLATE_ID);
end

function tb7thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb7thRoom:EndRoomTime()
	self.nRoomTimer = 0;
	self:EndRoom();
	return 0;
end

function tb7thRoom:ClearRoom()
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	if self.nRoomTimer and self.nRoomTimer > 0 then
		Timer:Close(self.nRoomTimer);
		self.nRoomTimer = 0;
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.XIMENFEIXUE_UNREAL_TEMPLATE_ID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.XIMENFEIXUE_TEMPLATE_ID);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,KinGame2.JIANHUN_TEMPLATE_ID);
end

function tb7thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb7thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb7thRoom:RoomFinish()
	if self.nIsSucess == 1 then
		self.tbBase:RoomFinish(7,1);
	else
		self.tbBase:RoomFinish(7,0);
		self.tbBase:AllBlackBoard("离开吧，别再回来了");
	end
	self.tbBase:AddAllPlayerExp(7,self.nIsSucess);		--加经验
	self.tbBase:GiveAllPlayerRepute(7,self.nIsSucess);	--加家族声望
	self.tbBase:GiveAllPlayerAwardItem(7,self.nIsSucess);	--过关加的古币
	self:AddLeaveTrap();
end

function tb7thRoom:AddLeaveTrap()
	local tbPos = KinGame2.TRAP_LEAVE_POS;
	KNpc.Add2(KinGame2.TRAP_LEAVE_NPC_TEMPLATE_ID,10,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end

-------------7号房间end----------------------------------------------------------










