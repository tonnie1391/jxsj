-- 文件名　：crosstimeroom_room.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-08-01 15:23:03
-- 描述：时光屋的room

CrossTimeRoom.tbRoom = {};
--5个房间
CrossTimeRoom.tbRoom[1]  = {};
CrossTimeRoom.tbRoom[2]  = {};
CrossTimeRoom.tbRoom[3]  = {};
CrossTimeRoom.tbRoom[4]  = {};
CrossTimeRoom.tbRoom[5]  = {};


local tb1stRoom = CrossTimeRoom.tbRoom[1];
local tb2ndRoom = CrossTimeRoom.tbRoom[2];
local tb3rdRoom = CrossTimeRoom.tbRoom[3];
local tb4thRoom = CrossTimeRoom.tbRoom[4];
local tb5thRoom = CrossTimeRoom.tbRoom[5];


--------------------room 1------------------------------------------------
function tb1stRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossWangS1TemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossWangS2TemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nStopNpc_BigTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nStopNpc_NormalTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossWangBeginerTemplateId);
end

function tb1stRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	local tbBossPos = CrossTimeRoom.tbBossWangPos;
	self.pBeginer = KNpc.Add2(CrossTimeRoom.nBossWangBeginerTemplateId,120,-1,self.tbBase.nMapId,tbBossPos[1],tbBossPos[2]);
	self.tbBase:AllBlackBoard("Phía trước có một vị đạo sĩ, hỏi thăm xem đây là chỗ nào?");
end

function tb1stRoom:FailedRoom()
	self.nIsFailed = 1;
	self:ClearRoom();
	self.tbBase:AllBlackBoard("Kiếm thi nan tiếu hồng trần, xem ra người không ngăn được hắn");
end

function tb1stRoom:CheckFailed()
	if self.nIsFailed == 1 then
		return 0;
	end
	if self.tbPlayerList then
		local nCount = 0;
		for nId,nFlag in pairs(self.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and pPlayer.IsDead() ~= 1 and nFlag == 1 then
				nCount = nCount + 1;
			end
		end
		if nCount > 0 then
			return 0;
		else
			return 1;
		end
	end
	return 1;
end

function tb1stRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb1stRoom:StartAddNpc()
	local tbBossPos = CrossTimeRoom.tbBossWangPos;
	self.pBossS1 = KNpc.Add2(CrossTimeRoom.nBossWangS1TemplateId,120,-1,self.tbBase.nMapId,tbBossPos[1],tbBossPos[2]);
	self.pBossS1.SetCurCamp(6);
	Npc:RegPNpcOnDeath(self.pBossS1,self.OnBossS1Death,self); 
	self.nTalkState = 1;
	self.nTalkTimer = Timer:Register(4 * Env.GAME_FPS, self.TalkS1End, self);
end

function tb1stRoom:TalkS1End()
	if self.pBossS1  then
		if self.nTalkState == 1 then
			self.tbBase:NpcTalk(self.pBossS1.dwId,"一醉江湖三十春，焉得书剑解红尘。");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 2 then
			self.tbBase:NpcTalk(self.pBossS1.dwId,"你要挡着我见文小月，我就不客气了。");
			self.nTalkState = self.nTalkState + 1;
			self.pBossS1.SetCurCamp(5);	--变为战斗状态
			self.pBossS1.SetActiveForever(1);
			self.nTalkTimer = 0;
			self.tbBase:UpdateUiState("<color=yellow>Ngăn cản Vương Di Phong biết về cái chết của Tiểu Nguyệt<color>");
			return 0
		else
			self.nTalkTimer = 0;
			return 0;
		end
	else
		self.nTalkTimer = 0;
		return 0;
	end
end

function tb1stRoom:OnBossS1Death()
	local tbBossPos = CrossTimeRoom.tbBossWangPos;
	self.pBossS2 = KNpc.Add2(CrossTimeRoom.nBossWangS2TemplateId,120,-1,self.tbBase.nMapId,tbBossPos[1],tbBossPos[2]);
	self.pBossS2.SetCurCamp(6);
	Npc:RegPNpcOnDeath(self.pBossS2,self.OnBossS2Death,self);
	Npc:RegDeathLoseItem(self.pBossS2,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
	for _,nPercent in pairs(CrossTimeRoom.tbBossS2CastXinMoPercent) do
		Npc:RegPNpcLifePercentReduce(self.pBossS2,nPercent,self.CastXinMo,self);
	end
	for _,nPercent in pairs(CrossTimeRoom.tbBossS2CastRenxinPercent) do
		Npc:RegPNpcLifePercentReduce(self.pBossS2,nPercent,self.CastRenxin,self);
	end  
	self.tbBase:AllBlackBoard("Vương Di Phong linh cảm Tiểu Nguyệt đã gặp bất trắc");
	self.nTalkState = 1;
	self.nTalkTimer = Timer:Register(4 * Env.GAME_FPS, self.TalkS2End, self);
end


function tb1stRoom:TalkS2End()
	if self.pBossS2  then
		if self.nTalkState == 1 then
			self.tbBase:NpcTalk(self.pBossS2.dwId,"你们不让我见小月，难道是小月出了事情？");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 2 then
			self.tbBase:NpcTalk(self.pBossS2.dwId,"我要把你们都杀光给小月报仇！");
			self.nTalkState = self.nTalkState + 1;
			self.pBossS2.SetCurCamp(5);	--变为战斗状态
			self.pBossS2.SetActiveForever(1);
			self.nTalkTimer = 0;
			return 0;
		else
			self.nTalkTimer = 0;
			return 0;
		end
	else
		self.nTalkTimer = 0;
		return 0;
	end
end

--释放心魔
function tb1stRoom:CastXinMo()
	if not self.pBossS2 or not self.tbPlayerList then
		return 0;
	end
	local _,nX,nY = self.pBossS2.GetWorldPos();
	--召回到boss身边，不要放在一个点
	local tbInPos = {};
	for x = - 1 , 1 do
		for y = -1, 1 do
			if x ~= 0 or y ~= 0 then
				local tbPos = {};
				tbPos[1] = nX + x * 2;
				tbPos[2] = nY + y * 2;
				table.insert(tbInPos,tbPos);
			end
		end
	end
	for nId,nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nFlag == 1 then
			local nIdx = MathRandom(#tbInPos);
			local tbPos = tbInPos[nIdx];
			pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
			table.remove(tbInPos,nIdx);
		end
	end
	--招一个定身npc
	KNpc.Add2(CrossTimeRoom.nStopNpc_BigTemplateId,120,-1,self.tbBase.nMapId,nX,nY);
	--20秒后释放横扫技能
	if self.nCastHengsaoTimer and self.nCastHengsaoTimer > 0 then
		Timer:Close(self.nCastHengsaoTimer);
		self.nCastHengsaoTimer = 0;
	end
	self.nCastHengsaoTimer = Timer:Register(20 * Env.GAME_FPS,self.CastHengsao,self);
	self.tbBase:NpcTalk(self.pBossS2.dwId,"死无葬身之地");
end

--释放必杀技
function tb1stRoom:CastHengsao()
	--todo,释放一个必杀技
	if not self.pBossS2 then
		self.nCastHengsaoTimer = 0;
		return 0;
	end
	local _,nX,nY = self.pBossS2.GetWorldPos();
	self.pBossS2.CastSkill(CrossTimeRoom.nHengsaoSkillId,1,nX*32,nY*32,1);
	self.nCastHengsaoTimer = 0;
	return 0;
end

--释放人心
function tb1stRoom:CastRenxin()
	--随机四个玩家，在脚下释放定身npc
	if not self.pBossS2 or not self.tbPlayerList then
		return 0;
	end
	local tbSufferPlayer = {};
	for nId,nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nFlag == 1 then
			table.insert(tbSufferPlayer,pPlayer);
		end
	end
	--小于3个人不放
	if #tbSufferPlayer > 2 then
		for i = 1 , 2 do
			local nIdx = MathRandom(#tbSufferPlayer);
			local _,nX,nY = tbSufferPlayer[nIdx].GetWorldPos();
			KNpc.Add2(CrossTimeRoom.nStopNpc_NormalTemplateId,120,-1,self.tbBase.nMapId,nX,nY);	--加定身npc
			table.remove(tbSufferPlayer,nIdx);			
		end
	end
	return 0;
end

function tb1stRoom:IsPlayerNear(nPlayerId)
	local nIsNear = 0;
	for nId , nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nId == nPlayerId and nFlag == 1 then
			nIsNear = 1;
		end
	end
	return nIsNear;
end

function tb1stRoom:OnBossS2Death()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			local nIsNear = self:IsPlayerNear(pPlayer.nId);
			if nIsNear == 0 then
				if pPlayer.IsDead() == 1 then
					pPlayer.ReviveImmediately(1);
				else
					local tbPos = CrossTimeRoom.tbRoomPos[1];
					pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
			if pPlayer.nFightState == 1 then --恢复战斗状态
				pPlayer.SetFightState(0);
			end
			Achievement:FinishAchievement(pPlayer,403);	--成就
		end
	end
	self:EndRoom();
end


function tb1stRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb1stRoom:ClearRoom()
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	if self.nCastHengsaoTimer and self.nCastHengsaoTimer > 0 then
		Timer:Close(self.nCastHengsaoTimer);
		self.nCastHengsaoTimer = 0;
	end
	self:ClearNpc();
	self.pBossS1 = nil;
	self.pBossS2 = nil;
	self.tbBase:UpdateUiState("");
end

function tb1stRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb1stRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb1stRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self:AddTransferNpc();	--刷传送npc
end

function tb1stRoom:AddTransferNpc()
	local tbPos = CrossTimeRoom.tbTransferNpcPos[1];
	self.pTransferNpc = KNpc.Add2(CrossTimeRoom.nTransferTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end
---room 1 end-----------


--room 2-------------------
--在结束或者失败重新开启时候，要清除npc
function tb2ndRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nHumeiniangTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nHuliTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossLiTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossYuanTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nFangshiTemplateId);
end

function tb2ndRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	self:StartAddNpc();
	--ui更新
end

function tb2ndRoom:FailedRoom()
	self.nIsFailed = 1;
	self:ClearRoom();
	self.tbBase:AllBlackBoard("Võ Mỵ Nương vừa chết là yêu hồ, ngươi vẫn không thể nào sửa đổi lịch sử");	
end

function tb2ndRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb2ndRoom:CheckFailed()
	if self.nIsFailed == 1 then
		return 0;
	end
	if self.tbPlayerList then
		local nCount = 0;
		for nId,nFlag in pairs(self.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and pPlayer.IsDead() ~= 1 and nFlag == 1 then
				nCount = nCount + 1;
			end
		end
		if nCount > 0 then
			return 0;
		else
			return 1;
		end
	end
	return 1;
end


function tb2ndRoom:StartAddNpc()
	local tbMeiniangPos = CrossTimeRoom.tbHumeiniangPos;
	local tbHuliPos = CrossTimeRoom.tbHuliPos;
	self.pMeiniang = KNpc.Add2(CrossTimeRoom.nHumeiniangTemplateId,120,-1,self.tbBase.nMapId,tbMeiniangPos[1],tbMeiniangPos[2]);
	self.pHuli = KNpc.Add2(CrossTimeRoom.nHuliTemplateId,120,-1,self.tbBase.nMapId,tbHuliPos[1],tbHuliPos[2]);
	self.pMeiniang.SetActiveForever(1);
	self.pHuli.SetActiveForever(1);
	self.nTalkState = 1;
	self.nTalkTimer = Timer:Register(4 * Env.GAME_FPS, self.TalkEnd, self);
end

function tb2ndRoom:TalkEnd()
	if self.pMeiniang  then
		if self.nTalkState == 1 then
			self.tbBase:NpcTalk(self.pMeiniang.dwId,"我是利州武媚娘，你为什么出现在我家大院子里？");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 2 then
			local tbBossYuanPos = CrossTimeRoom.tbBossYuanPos;
			local tbBossLiPos = CrossTimeRoom.tbBossLiPos;
			self.pBossYuan = KNpc.Add2(CrossTimeRoom.nBossYuanTemplateId,120,-1,self.tbBase.nMapId,tbBossYuanPos[1],tbBossYuanPos[2]);
			self.pBossLi = KNpc.Add2(CrossTimeRoom.nBossLiTemplateId,120,-1,self.tbBase.nMapId,tbBossLiPos[1],tbBossLiPos[2]);
			self.pBossYuan.SetCurCamp(6);
			self.pBossYuan.SetActiveForever(1);
			self.pBossLi.SetCurCamp(6);
			Npc:RegDeathLoseItem(self.pBossYuan,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
			Npc:RegPNpcOnDeath(self.pBossYuan, self.OnBossYuanDeath,self); 
			Npc:RegPNpcOnDeath(self.pBossLi, self.OnBossLiDeath,self); 
			self.tbBase:NpcTalk(self.pMeiniang.dwId,"你们又是谁，啊！！！！！");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 3 then
			self.tbBase:NpcTalk(self.pBossLi.dwId,"妖女，纳命来。");
			self.pBossYuan.SetCurCamp(5);
			self.pBossLi.SetCurCamp(5);
			self:AddFangshi();
			self:SetBossLiAi();
			self.nTalkTimer = 0;
			self.tbBase:UpdateUiState("<color=yellow>Cứu Võ Mỵ Nương từ tay Viên Thiên Canh đạo sĩ<color>");
			return 0;
		else
			self.nTalkTimer = 0;
			return 0;
		end
	else
		self.nTalkTimer = 0;
		return 0;
	end
end

function tb2ndRoom:OnBossLiDeath()
	self.nBossLiReviveTimer = Timer:Register(20 * Env.GAME_FPS, self.BossLiRevive, self);
end

function tb2ndRoom:BossLiRevive()
	--todo，黑条提示
	local tbBossLiPos = CrossTimeRoom.tbBossLiPos;
	self.pBossLi = KNpc.Add2(CrossTimeRoom.nBossLiTemplateId,120,-1,self.tbBase.nMapId,tbBossLiPos[1],tbBossLiPos[2]);
	Npc:RegPNpcOnDeath(self.pBossLi, self.OnBossLiDeath,self);
	self:SetBossLiAi();
	self.nBossLiReviveTimer = 0;
	return 0;
end


function tb2ndRoom:AddFangshi()
	self.tbFangshi = {};
	for i = 1 , #CrossTimeRoom.tbFangshiPos do
		local tbPos = CrossTimeRoom.tbFangshiPos[i];
		local pNpc = KNpc.Add2(CrossTimeRoom.nFangshiTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		pNpc.SetActiveForever(1);
		self.tbFangshi[i] = pNpc.dwId;
	end
end

function tb2ndRoom:OnFangshiDeath()
	self:SetBossLiAi();
end


function tb2ndRoom:SetBossLiAi()
	for i = 1,#self.tbFangshi do
		local nId = self.tbFangshi[i];
		if KNpc.GetById(nId) and KNpc.GetById(nId).IsDead() ~= 1 then
			if self.pBossLi then
				local tbAiPos = CrossTimeRoom.tbBossLiAiPos[i];
				self.pBossLi.AI_ClearPath();
				self.pBossLi.AI_AddMovePos(tbAiPos[1],tbAiPos[2]);
				self.pBossLi.SetNpcAI(9,0,0,0,0,0,0,0);
				self.pBossLi.SetActiveForever(1);
				self.pBossLi.GetTempTable("Npc").tbOnArrive = {self.OnArrive,self,i};
				break;
			end
		end
	end
end

function tb2ndRoom:OnArrive(nIndex)
	if self.pBossLi then
		local pNpc = KNpc.GetById(self.tbFangshi[nIndex]);
		if pNpc then
			pNpc.Delete();
		end
		self:OnFangshiDeath();
	end
end


function tb2ndRoom:IsPlayerNear(pPlayer,tbPlayer)
	if not pPlayer or not tbPlayer then
		return 0;
	end
	for _,pNearPlayer in pairs(tbPlayer) do
		if pNearPlayer and pPlayer then
			if pNearPlayer.nId == pPlayer.nId then
				return 1;
			end
		end
	end
	return 0;
end

function tb2ndRoom:OnBossYuanDeath()
	local tbNearPlayer = KNpc.GetAroundPlayerList(him.dwId,50);
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			local nIsNear = self:IsPlayerNear(pPlayer,tbNearPlayer);
			if nIsNear == 1 and pPlayer.IsDead() == 1 then
				pPlayer.ReviveImmediately(1);
			elseif nIsNear == 0 and pPlayer.IsDead() == 1 then
				pPlayer.ReviveImmediately(1);
				local tbPos = CrossTimeRoom.tbRoomPos[2];
				pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
			elseif nIsNear == 0 and pPlayer.IsDead() == 0 then
				local tbPos = CrossTimeRoom.tbRoomPos[2];
				pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
			end
			if pPlayer.nFightState == 1 then --恢复战斗状态
				pPlayer.SetFightState(0);
			end
			Achievement:FinishAchievement(pPlayer,404);	--成就
		end
	end
	self:EndRoom();
end

function tb2ndRoom:EndRoom()
	self.nIsFinished  = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb2ndRoom:ClearRoom()
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	if self.nBossLiReviveTimer and self.nBossLiReviveTimer > 0 then
		Timer:Close(self.nBossLiReviveTimer);
		self.nBossLiReviveTimer = 0;
	end
	self:ClearNpc();
	self.pMeiniang = nil;
	self.pHuli = nil;
	self.pBossLi = nil;
	self.pBossYuan = nil;
	self.tbFangshi = nil;
	self.tbBase:UpdateUiState("");
end

function tb2ndRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb2ndRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb2ndRoom:RoomFinish()
	self.tbBase:RoomFinish();
	--刷传送npc
	self:AddTransferNpc();
end

function tb2ndRoom:CheckCanRevive()
	if not self.tbFangshi then
		return 0;
	end
	local nCanRevive = 0;
	for _,nId in pairs(self.tbFangshi) do
		if KNpc.GetById(nId) and KNpc.GetById(nId).IsDead() ~= 1 then
			nCanRevive = 1;
			break;
		end
	end
	return nCanRevive;
end

--每次复活减少一个
function tb2ndRoom:DelFangshi()
	for _,nId in pairs(self.tbFangshi) do
		local pNpc = KNpc.GetById(nId);
		if pNpc and pNpc.IsDead() ~= 1 then
			pNpc.Delete();
			break;
		end
	end
end

function tb2ndRoom:AddTransferNpc()
	local tbPos = CrossTimeRoom.tbTransferNpcPos[2];
	self.pTransferNpc = KNpc.Add2(CrossTimeRoom.nTransferTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end
---room 2 end------------------


------room 3-----------------------------
function tb3rdRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nWalkerBoyTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nWalkerManTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossTaijianTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nFightHelpNpcTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nFreezeHelperNpcTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossChildTemplateId);
end


function tb3rdRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	self:StartAddNpc();
end

function tb3rdRoom:FailedRoom()
	self.nIsFailed = 1;
	self:ClearRoom();
	self.tbBase:AllBlackBoard("Tiểu tử thúi như ngươi lấy gì ngăn cản ta?");
end

function tb3rdRoom:CheckFailed()
	if self.nIsFailed == 1 then
		return 0;
	end
	if self.tbPlayerList then
		local nCount = 0;
		for nId,nFlag in pairs(self.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and pPlayer.IsDead() ~= 1 and nFlag == 1 then
				nCount = nCount + 1;
			end
		end
		if nCount > 0 then
			return 0;
		else
			return 1;
		end
	end
	return 1;
end

function tb3rdRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb3rdRoom:StartAddNpc()
	local tbBoyPos = CrossTimeRoom.tbWalkerBoyPos;
	local tbManPos = CrossTimeRoom.tbWalkerManPos;
	self.pBoy = KNpc.Add2(CrossTimeRoom.nWalkerBoyTemplateId,120,-1,self.tbBase.nMapId,tbBoyPos[1],tbBoyPos[2]);
	self.pMan = KNpc.Add2(CrossTimeRoom.nWalkerManTemplateId,120,-1,self.tbBase.nMapId,tbManPos[1],tbManPos[2]);
	self.nTalkState = 1;
	self.nTalkTimer = Timer:Register(4 * Env.GAME_FPS, self.TalkEnd, self);
end

function tb3rdRoom:TalkEnd()
	if self.pMan then
		if self.nTalkState == 1 then
			self.tbBase:NpcTalk(self.pMan.dwId,"孩子，虽然你听不懂……");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 2 then
			self.tbBase:NpcTalk(self.pMan.dwId,"我父皇刚刚告诉我，因为另一块游龙珏的关系...");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 3 then
			self.tbBase:NpcTalk(self.pMan.dwId,"...为了苍生天下，我们要快点出宫"); 
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 4 then
			local tbBossPos = CrossTimeRoom.tbBossTaijianPos;
			self.pBoss = KNpc.Add2(CrossTimeRoom.nBossTaijianTemplateId,120,-1,self.tbBase.nMapId,tbBossPos[1],tbBossPos[2]);
			if self.pBoss then
				Npc:RegPNpcOnDeath(self.pBoss,self.OnBossDeath,self);
				Npc:RegPNpcLifePercentReduce(self.pBoss,CrossTimeRoom.nBossBornChildPercent,self.BeginBorn,self);
				self.pBoss.SetCurCamp(6);
				Npc:RegDeathLoseItem(self.pBoss,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
			end
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 5 then
			if self.pBoss then
				self.tbBase:NpcTalk(self.pBoss.dwId,"晚了！要么留下游龙珏，要么留下你的命！");
			end
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 6 then
			if self.pBoy then
				self.tbBase:NpcTalk(self.pBoy.dwId,"爹爹...");
			end
			if self.pBoss then
				self.pBoss.SetCurCamp(5);
			end
			for _,tbPos in pairs(CrossTimeRoom.tbFightHelpNpcPos) do
				KNpc.Add2(CrossTimeRoom.nFightHelpNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			end
			for _,tbPos in pairs(CrossTimeRoom.tbFreezeHelperNpcPos) do
				KNpc.Add2(CrossTimeRoom.nFreezeHelperNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			end
			self.tbBase:UpdateUiState("<color=yellow>Đánh bại Tiểu Thái Giám, bảo vệ Vương Gia<color>");
			self.nTalkTimer = 0;
			return 0;
		else
			self.nTalkTimer = 0;
			return 0;
		end
	else
		self.nTalkTimer = 0;
		return 0;
	end
end

function tb3rdRoom:BeginBorn()
	self:OnBorn();	--第一次就先放一次分身
	self.nBossBornTimer = Timer:Register(40 * Env.GAME_FPS, self.OnBorn,self);
end

function tb3rdRoom:OnBorn()
	if not self.pBoss then
		self.nBossBornTimer = 0;
		return 0;
	end
	self.tbBase:NpcTalk(self.pBoss.dwId,"想跑？来人啊！");
	--local nMaxLife = self.pBoss.nCurLife/4;
	if not self.nChildCount then
		self.nChildCount = 0;
	end
	for _,tbPos in pairs(CrossTimeRoom.tbBossChildPos) do
		if self.nChildCount >= 9 then
			break;
		end
		local pNpc = KNpc.Add2(CrossTimeRoom.nBossChildTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			self.nChildCount = self.nChildCount + 1;
			Npc:RegPNpcOnDeath(pNpc,self.OnChildDeath,self);
		end
		--pNpc.SetMaxLife(nMaxLife);
	end
	return 20 * Env.GAME_FPS;
end

function tb3rdRoom:OnChildDeath()
	if not self.nChildCount then
		return 0;
	end
	self.nChildCount = self.nChildCount - 1;
	if self.nChildCount <= 0 then
		self.nChildCount = 0;
	end
end

function tb3rdRoom:OnBossDeath()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			local nIsNear = self:IsPlayerNear(pPlayer.nId);
			if nIsNear == 0 then
				if pPlayer.IsDead() == 1 then
					pPlayer.ReviveImmediately(1);
				else
					local tbPos = CrossTimeRoom.tbRoomPos[3];
					pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
			if pPlayer.nFightState == 1 then --恢复战斗状态
				pPlayer.SetFightState(0);
			end
			Achievement:FinishAchievement(pPlayer,405);	--成就
		end
	end
	self:EndRoom();
end

function tb3rdRoom:IsPlayerNear(nPlayerId)
	local nIsNear = 0;
	for nId , nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nId == nPlayerId and nFlag == 1 then
			nIsNear = 1;
		end
	end
	return nIsNear;
end

function tb3rdRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb3rdRoom:ClearRoom()
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	if self.nBossBornTimer and self.nBossBornTimer > 0 then
		Timer:Close(self.nBossBornTimer);
		self.nBossBornTimer = 0;
	end
	self:ClearNpc();
	self.pBoy = nil;
	self.pMan = nil;
	self.pBoss = nil;
	self.nChildCount = 0;
	self.tbBase:UpdateUiState("");
end

function tb3rdRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb3rdRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb3rdRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self:AddTransferNpc();	--刷传送npc
end

function tb3rdRoom:AddTransferNpc()
	local tbPos = CrossTimeRoom.tbTransferNpcPos[3];
	self.pTransferNpc = KNpc.Add2(CrossTimeRoom.nTransferTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end

-----room 4--------------------------------------------------
function tb4thRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nWaitNpcTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nYangyingfengTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossZhuoTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossZiTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossNalanTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nMoonFlowerTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nDamageTemplateId);
end


function tb4thRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	self:StartAddNpc();
end

function tb4thRoom:FailedRoom()
	self.nIsFailed = 1;
	self:ClearRoom();
	self.tbBase:AllBlackBoard("Mê trận thật bí hiểm, ngay cả bản thân cũng bị lạc trong đó");
end

function tb4thRoom:CheckFailed()
	if self.nIsFailed == 1 then
		return 0;
	end
	if self.tbPlayerList then
		local nCount = 0;
		for nId,nFlag in pairs(self.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and pPlayer.IsDead() ~= 1 and nFlag == 1 then
				nCount = nCount + 1;
			end
		end
		if nCount > 0 then
			return 0;
		else
			return 1;
		end
	end
	return 1;
end

function tb4thRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb4thRoom:StartAddNpc()
	local tbPos = CrossTimeRoom.tbYangyingfengPos;
	self.pYangyingfeng = KNpc.Add2(CrossTimeRoom.nYangyingfengTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	self.nTalkState = 1;
	self.nTalkTimer = Timer:Register(4 * Env.GAME_FPS, self.TalkEnd, self);
end

function tb4thRoom:TalkEnd()
	if self.pYangyingfeng then
		if self.nTalkState == 1 then
			self.tbBase:NpcTalk(self.pYangyingfeng.dwId,"我心中喜爱纳兰真....");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 2 then
			self.tbBase:NpcTalk(self.pYangyingfeng.dwId,"所以一直不能闯过她父亲所布置的心魔阵...");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 3 then 
			self.tbBase:NpcTalk(self.pYangyingfeng.dwId,"不如你替我闯一闯吧...");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 4 then
			local tbPos = CrossTimeRoom.tbBossZhuoPos;
			self.pWaitNpc = KNpc.Add2(CrossTimeRoom.nWaitNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			self.nWaitTimer = Timer:Register(10 * Env.GAME_FPS, self.WaitEndS1, self);
			self.tbBase:UpdateUiState("<color=yellow>Giúp Dương Ảnh Phong thoát khỏi mê trận ái tình<color>");
			self.nTalkTimer = 0;
			return 0;
		else
			self.nTalkTimer = 0;
			return 0;
		end
	else
		self.nTalkTimer = 0;
		return 0;
	end
end

function tb4thRoom:WaitEndS1()
	if self.pWaitNpc then
		self.pWaitNpc.Delete();
	end
	local tbPos = CrossTimeRoom.tbBossZhuoPos;
	self.pBossZhuo = KNpc.Add2(CrossTimeRoom.nBossZhuoTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	Npc:RegPNpcOnDeath(self.pBossZhuo,self.OnBossZhuoDeath,self);
	local tbPos = CrossTimeRoom.tbBossZiPos;
	self.pBossZi = KNpc.Add2(CrossTimeRoom.nBossZiTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	Npc:RegPNpcOnDeath(self.pBossZi,self.OnBossZiDeath,self);
	self:AddGrass();
	self.nAddGrassTimer = Timer:Register(20 * Env.GAME_FPS, self.AddGrass, self);
	self.nWaitTimer = 0;
	return 0;
end

function tb4thRoom:AddGrass()
	if self.nGrassId and KNpc.GetById(self.nGrassId) then
		return 20 * Env.GAME_FPS;
	end
	local tbGrassPos = CrossTimeRoom.tbDamagePos;
	local pNpc = KNpc.Add2(CrossTimeRoom.nDamageTemplateId,120,-1,self.tbBase.nMapId,tbGrassPos[1],tbGrassPos[2]);
	self.nGrassId = pNpc.dwId; 
	return 20 * Env.GAME_FPS;
end

function tb4thRoom:OnBossZhuoDeath()
	self.nIsBossZhuoDeath = 1;
	if self.nIsBossZiDeath and self.nIsBossZiDeath == 1 then
		local tbPos = CrossTimeRoom.tbBossNalanPos;
		self.pWaitNpc = KNpc.Add2(CrossTimeRoom.nWaitNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nWaitTimer = Timer:Register(10 * Env.GAME_FPS, self.WaitEndS2, self);
	end
end

function tb4thRoom:OnBossZiDeath()
	self.nIsBossZiDeath = 1;
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nDamageTemplateId);
	if self.nAddGrassTimer and self.nAddGrassTimer > 0 then
		Timer:Close(self.nAddGrassTimer);
		self.nAddGrassTimer = 0;
	end
	if self.nIsBossZhuoDeath and self.nIsBossZhuoDeath == 1 then
		local tbPos = CrossTimeRoom.tbBossNalanPos;
		self.pWaitNpc = KNpc.Add2(CrossTimeRoom.nWaitNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		self.nWaitTimer = Timer:Register(10 * Env.GAME_FPS, self.WaitEndS2, self);
	end
end

function tb4thRoom:WaitEndS2()
	if self.pWaitNpc then
		self.pWaitNpc.Delete();
	end
	local tbPos = CrossTimeRoom.tbBossNalanPos;
	self.pBossNalan = KNpc.Add2(CrossTimeRoom.nBossNalanTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	Npc:RegDeathLoseItem(self.pBossNalan,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
	Npc:RegPNpcOnDeath(self.pBossNalan,self.OnBossNalanDeath,self);
	for _,nPercent in pairs(CrossTimeRoom.tbCastTianxianziPercent) do
		Npc:RegPNpcLifePercentReduce(self.pBossNalan,nPercent,self.CastTianxianzi,self);
	end
	self.nScanPlayerBuffTimer = Timer:Register(Env.GAME_FPS / 3, self.ScanPlayerBuff, self);
	for _ , tbPos in pairs(CrossTimeRoom.tbMoonFlowerPos) do
		KNpc.Add2(CrossTimeRoom.nMoonFlowerTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	end
	self.nWaitTimer = 0;
	return 0;
end

function tb4thRoom:CastTianxianzi()
	if not self.pBossNalan then
		return 0;
	end
	self.tbBase:AllBlackBoard("Thiên tiên hạ phàm, nhiễu hoặc chúng sinh...");
	self.nCastTianxianziTimer = Timer:Register(3 * Env.GAME_FPS, self.OnCastTianxianzi, self);
end

function tb4thRoom:OnCastTianxianzi()
	if not self.pBossNalan then
		self.nCastTianxianziTimer = 0;
		return 0;
	end
	local _,x,y = self.pBossNalan.GetWorldPos();
	local nSkillId = CrossTimeRoom.tbTianxianziSkillId[MathRandom(#CrossTimeRoom.tbTianxianziSkillId)];
	self.pBossNalan.CastSkill(nSkillId,1,x*32,y*32,1);
	self.nCastTianxianziTimer = 0;
	return 0;
end

function tb4thRoom:ScanPlayerBuff()
	if not self.tbPlayerList then
		self.nScanPlayerBuffTimer = 0;
		return 0;
	end
	for nId,nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nFlag == 1 then
			local nIsHaveRed = pPlayer.GetSkillState(CrossTimeRoom.nRedStateId);
			local nIsHaveYellow = pPlayer.GetSkillState(CrossTimeRoom.nRedStateId);
			local nIsHaveGreen = pPlayer.GetSkillState(CrossTimeRoom.nYellowStateId);
			if nIsHaveYellow > 0 and nIsHaveRed > 0 and nIsHaveGreen > 0 then
				local _,nX,nY = pPlayer.GetWorldPos();
				pPlayer.CastSkill(CrossTimeRoom.nDeathSkillId,20,nX*32, nY*32);
			end
		end
	end
	return Env.GAME_FPS / 3;
end


function tb4thRoom:OnBossNalanDeath()
	self:ClearPlayerBuff();	--死了立即清楚玩家身上的情蛊
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			local nIsNear = self:IsPlayerNear(pPlayer.nId);
			if nIsNear == 0 then
				if pPlayer.IsDead() == 1 then
					pPlayer.ReviveImmediately(1);
				else
					local tbPos = CrossTimeRoom.tbRoomPos[4];
					pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
			if pPlayer.nFightState == 1 then --恢复战斗状态
				pPlayer.SetFightState(0);
			end
			Achievement:FinishAchievement(pPlayer,406);	--成就
		end
	end
	--黑条显示
	self:EndRoom();
end

function tb4thRoom:IsPlayerNear(nPlayerId)
	local nIsNear = 0;
	for nId , nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nId == nPlayerId and nFlag == 1 then
			nIsNear = 1;
		end
	end
	return nIsNear;
end

function tb4thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb4thRoom:ClearPlayerBuff()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.RemoveSkillState(CrossTimeRoom.nRedStateId);
			pPlayer.RemoveSkillState(CrossTimeRoom.nYellowStateId);
			pPlayer.RemoveSkillState(CrossTimeRoom.nGreenStateId);
		end
	end
end

function tb4thRoom:ClearRoom()
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	if self.nWaitTimer and self.nWaitTimer > 0 then
		Timer:Close(self.nWaitTimer);
		self.nWaitTimer = 0;
	end
	if self.nScanPlayerBuffTimer and self.nScanPlayerBuffTimer > 0 then
		Timer:Close(self.nScanPlayerBuffTimer);
		self.nScanPlayerBuffTimer = 0;
	end
	if self.nAddGrassTimer and self.nAddGrassTimer > 0 then
		Timer:Close(self.nAddGrassTimer);
		self.nAddGrassTimer = 0;
	end
	if self.nCastTianxianziTimer and self.nCastTianxianziTimer > 0 then
		Timer:Close(self.nCastTianxianziTimer);
		self.nCastTianxianziTimer = 0;
	end
	self.nIsBossZhuoDeath = 0;
	self.nIsBossZiDeath = 0;
	self:ClearPlayerBuff();
	self:ClearNpc();
	self.pBossNalan = nil;
	self.pBossZhuo = nil;
	self.pBossZi = nil;
	self.tbBase:UpdateUiState("");
end

function tb4thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb4thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb4thRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self:AddTransferNpc();	--刷传送npc
end

function tb4thRoom:AddTransferNpc()
	local tbPos = CrossTimeRoom.tbTransferNpcPos[4];
	self.pTransferNpc = KNpc.Add2(CrossTimeRoom.nTransferTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end

--room 5----------------------------------------------------
function tb5thRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBossSimingTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nChildSafeTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nChildFightTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nWalkNpcTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nTransferNpcTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nShouhuzheNpcTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nCrazyNpcTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nKuileiTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nBlackRegionNpcTemplateId);
end

function tb5thRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	self:StartAddNpc();
	--ui更新
end

function tb5thRoom:FailedRoom()
	self.nIsFailed = 1;
	self:ClearRoom();
	self.tbBase:AllBlackBoard("Thời Quang Điện đâu phải nơi ngươi muốn ra vào tùy ý!");	
end

function tb5thRoom:CheckFailed()
	if self.nIsFailed == 1 then
		return 0;
	end
	if self.tbPlayerList then
		local nCount = 0;
		for nId,nFlag in pairs(self.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and pPlayer.IsDead() ~= 1 and nFlag == 1 then
				nCount = nCount + 1;
			end
		end
		if nCount > 0 then
			return 0;
		else
			return 1;
		end
	end
	return 1;
end

function tb5thRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb5thRoom:StartAddNpc()
	local tbBossPos = CrossTimeRoom.tbBossSimingPos;
	self.pBoss = KNpc.Add2(CrossTimeRoom.nBossSimingTemplateId,120,-1,self.tbBase.nMapId,tbBossPos[1],tbBossPos[2]);
	self.pBoss.SetCurCamp(6);
	self.pBoss.SetActiveForever(1);
	Npc:RegPNpcOnDeath(self.pBoss,self.OnBossDeath,self); 
	Npc:RegDeathLoseItem(self.pBoss,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
	--第一阶段释放傀儡的血量点
	for _,nPercent in pairs(CrossTimeRoom.tbBornKuileiPercent) do
		Npc:RegPNpcLifePercentReduce(self.pBoss,nPercent,self.BornChild,self);
	end
	--不同阶段的血量点
	for _,nPercent in pairs(CrossTimeRoom.tbBossStepPercent) do
		Npc:RegPNpcLifePercentReduce(self.pBoss,nPercent,self.ProcessStep,self);
	end
	--先加四个非战斗状态的傀儡
	for _,tbPos in pairs(CrossTimeRoom.tbChildPos) do
		KNpc.Add2(CrossTimeRoom.nChildSafeTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	end
	self.nTalkState = 1;
	self.nTalkTimer = Timer:Register(4 * Env.GAME_FPS, self.TalkEnd, self);
end

function tb5thRoom:TalkEnd()
	if self.pBoss  then
		if self.nTalkState == 1 then
			self.tbBase:NpcTalk(self.pBoss.dwId,"，你们发现了阴阳时光殿，此乃阴阳家的绝密地点");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 2 then
			self.tbBase:NpcTalk(self.pBoss.dwId,"世人都以为阴阳家已经被儒家吞并，早已绝迹");
			self.nTalkState = self.nTalkState + 1;
			return 4 * Env.GAME_FPS;
		elseif self.nTalkState == 3 then
			self.tbBase:NpcTalk(self.pBoss.dwId,"没想到被你们发现，知道了太多的人是不能活下来的");
			self.pBoss.SetCurCamp(5);	--变为战斗状态
			self:ChangeChildFight();	--改变傀儡战斗状态
			self.tbBase:UpdateUiState("<color=yellow>Đánh bại Đại Tư Mệnh, kết thúc tất cả<color>");
			self.nTalkTimer = 0;
			return 0;
		else
			self.nTalkTimer = 0;
			return 0;
		end
	else
		self.nTalkTimer = 0;
		return 0;
	end
end

--改变四周傀儡的战斗状态
function tb5thRoom:ChangeChildFight()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nChildSafeTemplateId);	--先清除非战斗傀儡
	ChangeWorldWeather(self.tbBase.nMapId,1);	--下雨
	if not self.tbChild then
		self.tbChild = {};
	end
	for _,tbPos in pairs(CrossTimeRoom.tbChildPos) do
		local pNpc = KNpc.Add2(CrossTimeRoom.nChildFightTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		table.insert(self.tbChild,pNpc.dwId);
	end	
end

--把傀儡召唤到boss身边
function tb5thRoom:CallChildAround()
	local nCount = 0;
	for _,nId in pairs(self.tbChild) do
		local pNpc = KNpc.GetById(nId);
		if pNpc and pNpc.IsDead() ~= 1 then
			nCount = nCount + 1;
		end
	end
	if nCount <= 0 then
		return 0;
	end
	for i = 1, #self.tbChild do
		local tbPos = CrossTimeRoom.tbAroundChildPos[i];
		local pNpc = KNpc.GetById(self.tbChild[i]);
		if pNpc and pNpc.IsDead() ~= 1 then
			local nLife = pNpc.nCurLife;
			local nMaxLife = pNpc.nMaxLife;
			pNpc.Delete();
			local pNew = KNpc.Add2(CrossTimeRoom.nChildFightTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			pNew.ReduceLife(nMaxLife - nLife);
		end
	end
end

function tb5thRoom:BornChild(nPercent)
	if nPercent == 95 then
		self:CallChildAround();
	elseif nPercent == 80 then
		if not self.nKuileiCount then
			self.nKuileiCount = 0;
		end
		for i = 1 , 5 do
			local tbPos = CrossTimeRoom.tbKuileiPos[i];
			local pNpc = KNpc.Add2(CrossTimeRoom.nKuileiTemplateId,120,i,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			if pNpc then
				Npc:RegPNpcOnDeath(pNpc,self.OnKuileiDeath,self);
				self.nKuileiCount = self.nKuileiCount + 1;
			end
		end
		if self.nKuileiCount > 0 and self.pBoss then
			self.tbBase:AllBlackBoard("Xác sống đang trỗi dậy");
			self.pBoss.SetCurCamp(6);
		end	
	end
end

function tb5thRoom:OnKuileiDeath()
	self.nKuileiCount = self.nKuileiCount - 1;
	if self.nKuileiCount <= 0 then
		self.nKuileiCount = 0;
	end
	if self.nKuileiCount <= 0 then
		self.pBoss.SetCurCamp(5);
	end
end



function tb5thRoom:ProcessStep(nPercent)
	if nPercent == 70 then	--第二阶段
		self:ProcessStep2();
		self.tbBase:AllBlackBoard("U Minh Khuyển bị ánh sáng xanh quấy nhiễu");  --test
	elseif nPercent == 50 then	--第三阶段
		self:ProcessStep3();
		self.tbBase:AllBlackBoard("Tâm ma trận mở ra, hãy xem sự chọn lựa của nội tâm");  --test
	elseif nPercent == 20 then	--第四阶段
		self:ProcessStep4();
		self.tbBase:AllBlackBoard("Người bảo vệ Thời Quang Điện xuất hiện");	--test
	end 
end

function tb5thRoom:ProcessStep2()
	self:AddBoomNpc();
	self.nAddBoomNpcTimer = Timer:Register(10 * Env.GAME_FPS, self.AddBoomNpc, self);
	self:AddCrazyNpc();
	if self.pBoss then	--第二阶段开始先是非战斗
		self.pBoss.SetCurCamp(6);
	end
end

function tb5thRoom:AddBoomNpc()
	local tbPos = CrossTimeRoom.tbChildPos[MathRandom(#CrossTimeRoom.tbChildPos)];
	local tbAiPos = CrossTimeRoom.tbWalkNpcAiPos;
	local pBoomNpc = KNpc.Add2(CrossTimeRoom.nWalkNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	local _,x,y = pBoomNpc.GetWorldPos();
	pBoomNpc.CastSkill(CrossTimeRoom.nWalkNpcBuffSkillId,4,x*32,y*32,1);
	pBoomNpc.AI_ClearPath();
	pBoomNpc.AI_AddMovePos(tbAiPos[1],tbAiPos[2]);
	pBoomNpc.SetNpcAI(9,0,0,0,0,0,0,0);
	pBoomNpc.SetActiveForever(1);
	pBoomNpc.GetTempTable("Npc").tbOnArrive = {self.OnBoomArrive,self,pBoomNpc.dwId};
	return 10 * Env.GAME_FPS;
end

function tb5thRoom:OnBoomArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local _,nX,nY = pNpc.GetWorldPos();
	--到了先释放技能，然后爆炸(删除)
	pNpc.CastSkill(CrossTimeRoom.nWalkNpcBoomSkillId,6,nX*32,nY*32,1);
	self.nKillBoomNpcTimer = Timer:Register(2 * Env.GAME_FPS, self.KillBoomNpc,self,pNpc.dwId);
end

function tb5thRoom:KillBoomNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		self.nKillBoomNpcTimer = 0;
		return 0;
	end
	pNpc.Delete();
	self.nKillBoomNpcTimer = 0;
	return 0;
end

function tb5thRoom:AddCrazyNpc()
	for nIndex,tbPos in pairs(CrossTimeRoom.tbCrazyNpcPos) do
		local pNpc = KNpc.Add2(CrossTimeRoom.nCrazyNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		if not self.tbCrazyNpc then
			self.tbCrazyNpc = {};
		end
		self.tbCrazyNpc[pNpc.dwId] = 1;
		Npc:RegPNpcOnDeath(pNpc,self.OnCrazyNpcDeath,self,pNpc.dwId); 
	end
end

function tb5thRoom:OnCrazyNpcDeath(nNpcId)
	if self.tbCrazyNpc and self.tbCrazyNpc[nNpcId] then
		self.tbCrazyNpc[nNpcId] = 0;
	end
	local nIsAllDead = 1;
	for _,nFlag in pairs(self.tbCrazyNpc) do
		if nFlag == 1 then
			nIsAllDead = 0;
		end
	end
	if nIsAllDead ~= 1 then
		self.nScanDeathTimer = Timer:Register(10 * Env.GAME_FPS, self.ScanDeath, self);
	else
		if self.pBoss then
			self.pBoss.SetCurCamp(5);
		end
	end 
end

function tb5thRoom:ScanDeath()
	local nIsAllDead = 1;
	for nId,nFlag in pairs(self.tbCrazyNpc) do
		if nFlag == 1 then
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				--增加一个30分钟的狂乱状态
				pNpc.AddSkillState(CrossTimeRoom.nCrazySkillIdIR,11,1,30 * 60 * Env.GAME_FPS,1,0,1);
				pNpc.AddSkillState(CrossTimeRoom.nCrazySkillIdAD,11,1,30 * 60 * Env.GAME_FPS,1,0,1);
			end
		end
	end
	self.nScanDeathTimer = 0;
	return 0;
end


function tb5thRoom:ProcessStep3()
	if self.nAddBoomNpcTimer and self.nAddBoomNpcTimer > 0 then
		Timer:Close(self.nAddBoomNpcTimer);
		self.nAddBoomNpcTimer = 0;
	end
	self:TransPlayerToNewPlace();
	--40秒进行一次玩家传送
	self.nTransTimer = Timer:Register(40 * Env.GAME_FPS, self.TransPlayerToNewPlace, self);
end

function tb5thRoom:TransPlayerToNewPlace()
	if self.nCurrentNpcCount and self.nCurrentNpcCount ~= 0 and 
		self.nInNewPlacePlayerId and self:IsPlayerNear(self.nInNewPlacePlayerId) == 1 then
		return 40 * Env.GAME_FPS;
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,CrossTimeRoom.nTransferNpcTemplateId);
	local tbNpcPos = CrossTimeRoom.tbNewPlaceNpcPos;
	local tbPlayerPos = CrossTimeRoom.tbTansferNewPlacePos;
	self.nCurrentNpcCount = 0;
	for _,tbPos in pairs(tbNpcPos) do
		local pNpc = KNpc.Add2(CrossTimeRoom.nTransferNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			Npc:RegPNpcOnDeath(pNpc,self.OnTransferNpcDeath,self); 
			self.nCurrentNpcCount = self.nCurrentNpcCount + 1;
		end
	end
	local tbPlayer = {};
	for nId,nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nFlag == 1 then
			table.insert(tbPlayer,pPlayer);
		end
	end
	local pPlayer = tbPlayer[MathRandom(#tbPlayer)];
	if pPlayer then
		pPlayer.NewWorld(self.tbBase.nMapId,unpack(tbPlayerPos));
		self.nInNewPlacePlayerId = pPlayer.nId;
	end
	return 40 * Env.GAME_FPS;
end


function tb5thRoom:OnTransferNpcDeath()
	self.nCurrentNpcCount = self.nCurrentNpcCount - 1;
	if self.nCurrentNpcCount <= 0 then
		self.nCurrentNpcCount = 0;
		local tbPos = CrossTimeRoom.tbRoomPos[5];
		if self.nInNewPlacePlayerId and self:IsPlayerNear(self.nInNewPlacePlayerId) == 1 then
			local pPlayer = KPlayer.GetPlayerObjById(self.nInNewPlacePlayerId);
			if pPlayer then
				pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
				self.nInNewPlacePlayerId = nil;	
			end
		end
	end
end


function tb5thRoom:ProcessStep4()
	if self.nTransTimer and self.nTransTimer > 0 then
		Timer:Close(self.nTransTimer);
		self.nTransTimer = 0;
	end
	self:AddBlackRegion();
	self:AddShouhuzhe();
end

function tb5thRoom:AddBlackRegion()
	local tbBlackPos = CrossTimeRoom.tbBlackRegionPos;
	for _,tbPos in pairs(CrossTimeRoom.tbBlackRegionPos) do
		if self.pBoss then
			self.pBoss.CastSkill(CrossTimeRoom.nBlackRegionSkillId,10,tbPos[1],tbPos[2],1);
		end
		--加四个黑水的npc形象
		KNpc.Add2(CrossTimeRoom.nBlackRegionNpcTemplateId,10,-1,self.tbBase.nMapId,tbPos[1]/32,tbPos[2]/32);
	end
end

function tb5thRoom:AddShouhuzhe()
	local tbPos = CrossTimeRoom.tbShouhuzhePos;
	local pNpc = KNpc.Add2(CrossTimeRoom.nShouhuzheNpcTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	local tbAiPos = CrossTimeRoom.tbBlackRegionPos[MathRandom(#CrossTimeRoom.tbBlackRegionPos)];	--随机选一个点走过去
	pNpc.AI_ClearPath();
	pNpc.AI_AddMovePos(tbAiPos[1],tbAiPos[2]);
	pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
	pNpc.SetActiveForever(1);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnShouhuzheArrive,self,pNpc.dwId};
	Npc:RegPNpcOnDeath(pNpc,self.OnShouhuzheDeath,self); 
	self.tbBase:NpcTalk(self.pBoss.dwId,"无边的深渊里有人正等着你……");
end

function tb5thRoom:OnShouhuzheArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		local tbPlayer = {};
		local _,nX,nY = pNpc.GetWorldPos();
		for nId,nFlag in pairs(self.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nFlag == 1 then
				if not self.nInNewPlacePlayerId or self.nInNewPlacePlayerId ~= nId then
					table.insert(tbPlayer,pPlayer);
				end
			end
		end
		local pPlayer = tbPlayer[MathRandom(#tbPlayer)];
		if pPlayer then
			pPlayer.NewWorld(self.tbBase.nMapId,nX,nY);
		end
		pNpc.Delete();
	end
	self:AddShouhuzhe();	
end


function tb5thRoom:OnShouhuzheDeath()
	self:AddShouhuzhe();
end

function tb5thRoom:IsPlayerNear(nPlayerId)
	local nIsNear = 0;
	for nId , nFlag in pairs(self.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.tbBase.nMapId and nId == nPlayerId and nFlag == 1 then
			nIsNear = 1;
		end
	end
	return nIsNear;
end

function tb5thRoom:OnBossDeath()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			local nIsNear = self:IsPlayerNear(pPlayer.nId);
			if nIsNear == 0 then
				if pPlayer.IsDead() == 1 then
					pPlayer.ReviveImmediately(1);
				else
					local tbPos = CrossTimeRoom.tbRoomPos[5];
					pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
			if pPlayer.nFightState == 1 then --恢复战斗状态
				pPlayer.SetFightState(0);
			end
			Achievement:FinishAchievement(pPlayer,407);	--成就
			Achievement:FinishAchievement(pPlayer,408);	--成就
			
			SpecialEvent.ActiveGift:AddCounts(pPlayer, 30);		--完成阴阳时光殿活跃度
			Faction:AchieveTask(pPlayer, Faction.TYPE_YINYANGSHIGUANGDIAN);
		end
	end
	--在异境里的人要传回来
	if self.nInNewPlacePlayerId and self:IsPlayerNear(self.nInNewPlacePlayerId) == 1 then
		local pPlayer = KPlayer.GetPlayerObjById(self.nInNewPlacePlayerId);
		local tbPos = CrossTimeRoom.tbRoomPos[5];
		if pPlayer then
			pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
			self.nInNewPlacePlayerId = nil;	
			if pPlayer.nFightState == 1 then --恢复战斗状态
				pPlayer.SetFightState(0);
			end
		end
	end
	local pPlayer = tbPlayer[MathRandom(#tbPlayer)];
	local nId = pPlayer and pPlayer.nId or 0;
	local szFile = CrossTimeRoom.tbOtherDropInfo[1];
	local nCount = CrossTimeRoom.tbOtherDropInfo[2];
	him.DropRateItem(szFile,nCount,0,-1,nId); 
	self:EndRoom();
end


function tb5thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
end

function tb5thRoom:ClearRoom()
	if self.nTalkTimer and self.nTalkTimer > 0 then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = 0;
	end
	if self.nAddBoomNpcTimer and self.nAddBoomNpcTimer > 0 then
		Timer:Close(self.nAddBoomNpcTimer);
		self.nAddBoomNpcTimer = 0;
	end
	if self.nKillBoomNpcTimer and self.nKillBoomNpcTimer > 0 then
		Timer:Close(self.nKillBoomNpcTimer);
		self.nKillBoomNpcTimer = 0;
	end
	if self.nScanDeathTimer and self.nScanDeathTimer > 0 then
		Timer:Close(self.nScanDeathTimer);
		self.nScanDeathTimer = 0;
	end
	if self.nTransTimer and self.nTransTimer > 0 then
		Timer:Close(self.nTransTimer);
		self.nTransTimer = 0;
	end
	if self.nKillBoomNpcTimer and self.nKillBoomNpcTimer > 0 then
		Timer:Close(self.nKillBoomNpcTimer);
		self.nKillBoomNpcTimer = 0;
	end
	ChangeWorldWeather(self.tbBase.nMapId,0);
	self.tbCrazyNpc = nil;
	self.nInNewPlacePlayerId = nil;
	self.nCurrentNpcCount = nil;
	self.tbChild = nil;
	self.nKuileiCount = 0;
	self.nCurrentNpcCount = 0;
	self.pBoss = nil;
	self:ClearNpc();
	self.tbBase:UpdateUiState("");
end

function tb5thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb5thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb5thRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self.tbBase:AllBlackBoard("Sau cơn mưa, bụi bay tan tành, bạn đã có thể rời khỏi đây");
	self:AddTransferNpc();	--刷传送npc
end

function tb5thRoom:AddTransferNpc()
	local tbPos = CrossTimeRoom.tbTransferNpcPos[5];
	local tbPos1 = CrossTimeRoom.tbTransferNpcPos[6];	--异境里的传送npc
	self.pTransferNpc = KNpc.Add2(CrossTimeRoom.nTransferTemplateId,120,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	self.pTransferNpcOther = KNpc.Add2(CrossTimeRoom.nTransferTemplateId,120,-1,self.tbBase.nMapId,tbPos1[1],tbPos1[2]);
end
