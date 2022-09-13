-- 文件名　：201112_xmas_gs.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-28 18:07:01
-- 描述：2011圣诞gs

if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201112_xmas\\201112_xmas_def.lua");

SpecialEvent.Xmas2011 =  SpecialEvent.Xmas2011 or {};
local Xmas2011 = SpecialEvent.Xmas2011;


-------------common------------
--活动npc的对话接口
function Xmas2011:OnEventNpcDialog(nIndex)
	local szFun = self.tbEventFunction[nIndex];
	if szFun and self[szFun] then
		self[szFun](self);
	end
end

function Xmas2011:CalItemRemainTime()
	local nRemainTime = Lib:GetDate2Time(self.nEventEndTime);
	return nRemainTime;
end

function Xmas2011:GetPrizeLevel()
	local nOpenDay = TimeFrame:GetServerOpenDay();
	if nOpenDay < 146 then
		return 1;
	elseif nOpenDay >= 146 and nOpenDay <= 365 then
		return 2;
	else
		return 3;
	end
end

function Xmas2011:AddSnowManAndDecoration_GS()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	if not self.nSnowManCity or not KNpc.GetById(self.nSnowManCity) then
		self:AddSnowMan_GS();
		if self.nNotifySnowManMsgTimer and self.nNotifySnowManMsgTimer > 0 then
			Timer:Close(self.nNotifySnowManMsgTimer);
			self.nNotifySnowManMsgTimer = 0;
		end
		self.nNotifySnowManMsgTimer = Timer:Register(self.nNotifyProduceTime,self.OnNotifySnowManMsg,self);
	end
	if not self.nIsDecorationAdded or self.nIsDecorationAdded ~= 1 then
		self:AddDecoration_GS();
	end
end

function Xmas2011:OnNotifySnowManMsg()
	if self:IsEventOpen() ~= 1 then
		self.nNotifySnowManMsgTimer = 0;
		return 0;
	end
	self:AnnounceMsg(self.szNotifyProduceMsg);
end


--加装饰npc
function Xmas2011:AddDecoration_GS()
	if not self.tbDecorationPos then
		self:LoadDecorationPos();
	end
	self:AddDecorationNpc();
	self.nIsDecorationAdded = 1;	--是否已经加过装饰npc
end

function Xmas2011:AddDecorationNpc()
	if not self.tbDecorationPos then
		return 0;
	end
	for nMapId,tbInfo in pairs(self.tbDecorationPos) do
		if IsMapLoaded(nMapId) == 1 then
			for nTemplateId,tbPosInfo in pairs(tbInfo) do
				for _,tbPos in pairs(tbPosInfo) do
					local nX = tbPos[1];
					local nY = tbPos[2];
					local bName = tbPos[3];
					local pNpc = KNpc.Add2(nTemplateId,50,-1,nMapId,nX,nY);
					if pNpc and bName ~= 1 then
						pNpc.szName = "";
						pNpc.Sync();
					end
				end
			end
		end
	end
end

function Xmas2011:LoadDecorationPos()
	if not self.tbDecorationPos then
		self.tbDecorationPos = {};
	end
	local tbFile = Lib:LoadTabFile(self.szDecorationPosFile);
	if not tbFile then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Load Decoration Npc Pos File Error",self.szDecorationPosFile);
		return 0;
	end
	for _,tbInfo in ipairs(tbFile) do
		local nMapId = tonumber(tbInfo.MapId);
		local nTemplateId = tonumber(tbInfo.TemplateId);
		local bName = tonumber(tbInfo.bName) or 0;
		if not self.tbDecorationPos[nMapId] then
			self.tbDecorationPos[nMapId] = {};
		end
		if not self.tbDecorationPos[nMapId][nTemplateId] then
			self.tbDecorationPos[nMapId][nTemplateId] = {};
		end
		local tbTemp = {tonumber(tbInfo.PosX)/32,tonumber(tbInfo.PosY)/32,bName};
		table.insert(self.tbDecorationPos[nMapId][nTemplateId],tbTemp);
	end	
end


-----------------给面具活动
function Xmas2011:OnGiveMaskBox()
	if self:CheckCanGetMask() ~= 1 then
		return 0;
	end
	local tbGdpl = self.tbMaskGdpl;
	if not tbGdpl then
		return 0;
	end
	local pItem = me.AddItem(unpack(tbGdpl));
	if pItem then
		local nOrgTime = 12 * 24 * 60 * 60;
		local nRemainTime = self:CalItemRemainTime() or nOrgTime;
		pItem.SetTimeOut(0,nRemainTime);
		pItem.Bind(1);
		me.SetTask(self.nTaskGroupId,self.nHasGetMaskTaskId,1);
		return 1;
	else
		Dbg:WriteLog("SpecialEvent","Xmas2011,Give Mask Box Failed!",me.nId,me.szName);
		return 0;
	end
end

function Xmas2011:CheckCanGetMask()
	if self:IsEventOpen() ~= 1 then
		Dialog:Say("Sự kiện đã kết thúc!");
		return 0;
	end
	if me.nLevel < self.nGetMaskBaseLevel then
		Dialog:Say(string.format("等级未达到%s级的玩家无法领取圣诞面具！",self.nGetMaskBaseLevel));
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!");
		return 0;
	end
	local nHasGetMask = me.GetTask(self.nTaskGroupId,self.nHasGetMaskTaskId);
	if nHasGetMask and nHasGetMask > 0 then
		Dialog:Say("您已经领取过【圣诞假面盒】，如若丢失，奇珍阁或者侠义商店可帮助您。");
		return 0;
	end
	return 1;
end

function Xmas2011:IsMaskXmasNeed(szName)
	if not szName then
		return 0;
	end
	if string.find(szName,self.szMaskNeedName) then
		return 1;
	else
		return 0;
	end
end

----------------找袜子活动
function Xmas2011:StartWalkAroundCity_GS()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	if not self.tbNpcWalkRoutePos then
		self:LoadNpcRoute();
	end
	self:ClearInfo();
	for nMapId,_ in pairs(self.tbNpcWalkRoutePos) do
		if IsMapLoaded(nMapId) == 1 then
			table.insert(self.tbNpcWalkCityMap,nMapId);
			self.tbCurrentWalkStep[nMapId] = 1;	--每次开始加的时候，都把起始阶段设置为1
			self.tbNpcInfo[nMapId] = {};
			self.tbLiveTimer[nMapId] = 0;
		end
	end
	if #self.tbNpcWalkCityMap > 0 then
		self.nDelteEventNpcTimer = Timer:Register(self.nWalkEventDelayTime,self.OnDeleteEventNpc,self);
		self:SetWalkNpc();
	end
	self:AnnounceMsg(self.szNotifyMsgPerHour);
	self.nAnnounceCount = 1;
	self.nNotifyTimer = Timer:Register(self.nNotifyTime,self.OnNotifyMsg,self);
end

function Xmas2011:OnNotifyMsg()
	self:AnnounceMsg(self.szNotifyMsgPerHour);
	self.nAnnounceCount = self.nAnnounceCount + 1;
	if self.nAnnounceCount >= self.nNotifyMaxCount then
		self.nNotifyTimer = 0;
		return 0;
	end
end

function Xmas2011:AnnounceMsg(szMsg)
	if not szMsg or #szMsg <= 0 then
		return 0;
	end
	KDialog.NewsMsg(0,Env.NEWSMSG_NORMAL,szMsg);
	KDialog.Msg2SubWorld(szMsg);
end

function Xmas2011:ClearInfo()
	if self.nDelteEventNpcTimer and self.nDelteEventNpcTimer > 0 then
		Timer:Close(self.nDelteEventNpcTimer);
		self.nDelteEventNpcTimer = 0;
	end
	if self.nNotifyTimer and self.nNotifyTimer > 0 then
		Timer:Close(self.nNotifyTimer);
		self.nNotifyTimer = 0;
	end
	if self.tbNpcInfo then
		self:OnDeleteEventNpc();
	end
	if self.tbLiveTimer then
		for nIndex,nTimer in pairs(self.tbLiveTimer) do
			if nTimer and nTimer > 0 then
				Timer:Close(nTimer);
				self.tbLiveTimer[nIndex] = 0;
			end
		end
	end
	self.tbNpcWalkCityMap = {};
	self.tbCurrentWalkStep = {};	--记录npc走到第几条路线
	self.tbNpcInfo = {};			--记录行走npc和站立npc
	self.tbLiveTimer = {};			--记录站立npc存在时间的timer
	if self.nDelteEventNpcTimer and self.nDelteEventNpcTimer > 0 then
		Timer:Close(self.nDelteEventNpcTimer);
		self.nDelteEventNpcTimer = 0;
	end
end


function Xmas2011:LoadNpcRoute()
	self.tbNpcWalkRoutePos = {};	--记录npcai路线
	local tbFile = Lib:LoadTabFile(self.szWalkNpcAiRouteFile);
	if not tbFile then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Load Npc Ai Road Error",self.szWalkNpcAiRouteFile);
		return 0;
	end
	for _,tbInfo in ipairs(tbFile) do
		local nMapId = tonumber(tbInfo.MapId);
		local nStepId = tonumber(tbInfo.StepId);
		if not self.tbNpcWalkRoutePos[nMapId] then
			self.tbNpcWalkRoutePos[nMapId] = {};
		end
		if not self.tbNpcWalkRoutePos[nMapId][nStepId] then
			self.tbNpcWalkRoutePos[nMapId][nStepId] = {};
		end
		local tbTemp = {tonumber(tbInfo.ROADX),tonumber(tbInfo.ROADY)};
		table.insert(self.tbNpcWalkRoutePos[nMapId][nStepId],tbTemp);
	end
end

function Xmas2011:SetWalkNpc()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	for _,nMapId in pairs(self.tbNpcWalkCityMap) do
		local tbAiStepInfo = self.tbNpcWalkRoutePos[nMapId];
		if tbAiStepInfo then
			local nStep = self.tbCurrentWalkStep[nMapId];
			local tbAiPosInfo = tbAiStepInfo[nStep];
			local tbStartPos = tbAiPosInfo[1];	--出生点就是ai点的第一个
			self:AddWalkNpc(nMapId,tbStartPos[1]/32,tbStartPos[2]/32);
		end
	end
end

function Xmas2011:AddWalkNpc(nMapId,nX,nY)
	local nTemplateId = self.nWalkNpcTemplateId;
	local pNpc = KNpc.Add2(nTemplateId,50,-1,nMapId,nX,nY);
	if not pNpc then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add City Walk Npc Failed!",nMapId);
		return 0;
	else
		table.insert(self.tbNpcInfo[nMapId],pNpc.dwId);
		self:SetNpcBeginWalk(pNpc.dwId);	
	end
end


function Xmas2011:AddStandNpc(nMapId,nX,nY)
	local nTemplateId = self.nStandNpcTemplateId;
	local pNpc = KNpc.Add2(nTemplateId,50,-1,nMapId,nX,nY);
	if not pNpc then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add City Stand Npc Failed!",nMapId);
		return 0;
	else
		pNpc.GetTempTable("Npc").nCastSkillTimer = Timer:Register(self.nWalkNpcCastSkillDelayTime,self.OnNpcCastSkill,self,pNpc.dwId);
		table.insert(self.tbNpcInfo[nMapId],pNpc.dwId);
	end
	if self.tbLiveTimer[nMapId] and self.tbLiveTimer[nMapId] > 0 then
		Timer:Close(self.tbLiveTimer[nMapId]);
		self.tbLiveTimer[nMapId] = 0;
	end
	--即使刷不出来，也会进行下一阶段
	self.tbLiveTimer[nMapId] = Timer:Register(self.nStandNpcLiveTime,self.OnStandNpcLive,self,pNpc and pNpc.dwId or 0,nMapId,nX,nY);
end

function Xmas2011:OnStandNpcLive(nId,nMapId,nX,nY)
	local pNpc = KNpc.GetById(nId);
	if pNpc then
		pNpc.Delete();		
		self:AddWalkNpc(nMapId,nX,nY);
	end
	self.tbLiveTimer[nMapId] = 0;
	return 0;
end

function Xmas2011:OnDeleteEventNpc()
	for _,tbInfo in pairs(self.tbNpcInfo) do
		for _,nId in pairs(tbInfo) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.nDelteEventNpcTimer = 0;
	return 0;
end

function Xmas2011:SetNpcBeginWalk(nId)
	local pNpc = KNpc.GetById(nId);
	if not pNpc then
		return  0;
	end
	local nStep = self.tbCurrentWalkStep[pNpc.nMapId];
	local tbAiPos = self.tbNpcWalkRoutePos[pNpc.nMapId][nStep];
	if not tbAiPos then
		return 0;
	end
	pNpc.AI_ClearPath();
	for i = 1,#tbAiPos do
		pNpc.AI_AddMovePos(tbAiPos[i][1],tbAiPos[i][2]);
	end
	local nMapId,nX,nY = pNpc.nMapId,tbAiPos[#tbAiPos][1]/32,tbAiPos[#tbAiPos][2]/32;
	pNpc.SetActiveForever(1);
	pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnWalkNpcArrive,self,pNpc.dwId,nMapId,nX,nY};
end

function Xmas2011:OnWalkNpcArrive(nId,nMapId,nX,nY)
	local pNpc = KNpc.GetById(nId);
	if pNpc then
		pNpc.Delete();
		self:AddStandNpc(nMapId,nX,nY);
		self.tbCurrentWalkStep[nMapId] = self.tbCurrentWalkStep[nMapId] + 1;
		if self.tbCurrentWalkStep[nMapId] > self.tbNpcAiRouteMaxStep[nMapId] then	--如果大于路线数最大值，就从1开始
			self.tbCurrentWalkStep[nMapId] = 1;
		end
	end
end

function Xmas2011:OnNpcCastSkill(nId)
	local pNpc = KNpc.GetById(nId);
	if not pNpc then
		return 0;
	end
	local nSkillId = self.tbWalkNpcSkillId[MathRandom(#self.tbWalkNpcSkillId)];
	local nMapId,nX,nY = pNpc.GetWorldPos();
	pNpc.CastSkill(nSkillId,1,nMapId,nX * 32,nY * 32,1);
end


function Xmas2011:OnGetPrizeSock()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	local szMsg = "    圣诞获得期间，每日11点~14点、19点~22点，可在襄阳、临安、大理寻找圣诞老人领取圣诞袜子，与拥有同花色袜子的玩家组队后，在规定时间内，来此领取奖励。";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"确定领取",self.SureGetPrizeSock,self};
	tbOpt[#tbOpt + 1] =	{"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);

end

function Xmas2011:SureGetPrizeSock()
	local nCanGetPrize,szError = self:CheckCanGetPrizeSock();
	if nCanGetPrize ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	self:GivePrizeSock();
end

--是否可以领取袜子
function Xmas2011:CheckCanGetPrizeSock()
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"只有组队才能领取装满礼物的袜子！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"只有两人队伍才能领取装满礼物的袜子！";
	end
	if me.IsCaptain() ~= 1 then
		return 0,"只有队长才能前来领取装满礼物的袜子！";
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,self.nGetSockRequireRange);
	for _, tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		return 0,"对不起，你的队友离你太远了。";
	end
	local tbMember = me.GetTeamMemberList();
	local tbSockGdp = self.tbSockGdp;
	local nAllHasMask = 1;	--是否都有面具
	local nMyLastGetLevel = me.GetTask(self.nTaskGroupId,self.nLastGetSockLevelTaskId);
	local tbMySock =  me.FindItemInBags(tbSockGdp[1],tbSockGdp[2],tbSockGdp[3],nMyLastGetLevel);
	local tbTeammateSock = {};	--队友的袜子
	local nAllHasFree = 1;	--是否都有空间 
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			local pMask = pPlayer.GetEquip(Item.EQUIPPOS_MASK);
			if not pMask or self:IsMaskXmasNeed(pMask.szName) ~= 1 then
				nAllHasMask = 0;
			end
			if pPlayer.nId ~= me.nId then
				local nLastGetLevel = pPlayer.GetTask(self.nTaskGroupId,self.nLastGetSockLevelTaskId);
				tbTeammateSock = pPlayer.FindItemInBags(tbSockGdp[1],tbSockGdp[2],tbSockGdp[3],nLastGetLevel);
			end
			if pPlayer.CountFreeBagCell() < 1 then
				nAllHasFree = 0;
			end
		end
	end
	if nAllHasMask ~= 1 then
		return 0,"队伍中有成员没有装备圣诞欢喜面具！";
	end
	if #tbMySock <= 0 or #tbTeammateSock <= 0 then
		return 0,"队伍中有成员背包中没有圣诞袜！";
	end
	if tbMySock[1].pItem.SzGDPL() ~= tbTeammateSock[1].pItem.SzGDPL() then
		return 0,"你和队友的圣诞袜花色不匹配，请找到有同花色圣诞袜的队友后再来！";
	end
	if nAllHasFree ~= 1 then
		return 0,"请保证队伍中所有成员预留出<color=yellow>1<color>格背包空间！";	
	end
	return 1;	
end

--领取袜子
function Xmas2011:GivePrizeSock()
	local tbMember = me.GetTeamMemberList();
	local tbSockGdp = self.tbSockGdp;
	local tbPrizeSockGdpl = self.tbPrizeSockGdpl;
	local szMsg = "打开装满礼物的袜子，放置好圣诞星星就能拿到礼物了";
	local szFMsg = "";
	if tbMember[1] and tbMember[2] then
		szFMsg = string.format("【%s】和【%s】凑成了一对圣诞袜，真是难能可贵！实乃一段美好的江湖情缘！",tbMember[1].szName,tbMember[2].szName);
	end
	local tbLogName = {};	--记log的两人名字
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			local nLastGetLevel = pPlayer.GetTask(self.nTaskGroupId,self.nLastGetSockLevelTaskId);
			local tbSock = pPlayer.FindItemInBags(tbSockGdp[1],tbSockGdp[2],tbSockGdp[3],nLastGetLevel);
			if #tbSock > 0 then
				if pPlayer.DelItem(tbSock[1].pItem,Player.emKLOSEITEM_USE) ~= 1 then
					Dbg:WriteLog("SpecialEvent","Xmas2011,Delete Normal Sock Failed!",pPlayer.nId,pPlayer.szName);
				else
					local pItem = pPlayer.AddItem(unpack(tbPrizeSockGdpl));
					Dialog:SendBlackBoardMsg(pPlayer,szMsg);
					if szFMsg ~= "" then
						pPlayer.SendMsgToFriend(szFMsg);
					end
					if pItem then
						table.insert(tbLogName,pPlayer.szName);
						pItem.SetGenInfo(1,0);	--标记还未点星星，无法打开奖品
					else
						Dbg:WriteLog("SpecialEvent","Xmas2011,Give Prize Sock Failed!",pPlayer.nId,pPlayer.szName);
					end
				end
			end
		end
	end
	StatLog:WriteStatLog("stat_info","shengdanjie_2011","socks_put_star",0,unpack(tbLogName));
end


-------------------------堆雪人活动
function Xmas2011:OnGetSnowBase()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	local nLastGetSnowBaseTime = me.GetTask(self.nTaskGroupId,self.nLastGetSnowBaseTimeTaskId);
	if os.date("%Y%m%d",GetTime()) ~= os.date("%Y%m%d",nLastGetSnowBaseTime) then
		me.SetTask(self.nTaskGroupId,self.nHasGetSnowBaseCountTaskId,0);
		me.SetTask(self.nTaskGroupId,self.nLastGetSnowBaseTimeTaskId,GetTime());
	end
	local nCanGetSnowBase,szError = self:CheckCanGetSnowBase();
	if nCanGetSnowBase ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	self:GiveSnowBase();
end

function Xmas2011:GiveSnowBase()
	local tbGdpl = self.tbSnowBaseItemGdpl;
	local pItem = me.AddItem(unpack(tbGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Give Snow Base Failed!",me.nId,me.szName);
	else
		local nGetCount = me.GetTask(self.nTaskGroupId,self.nHasGetSnowBaseCountTaskId);
		me.SetTask(self.nTaskGroupId,self.nHasGetSnowBaseCountTaskId,nGetCount + 1);
		local szMsg = "获得未完成的雪人坯，收集好雪团子再放置它吧";
		Dialog:SendBlackBoardMsg(me,szMsg);
	end
end


function Xmas2011:CheckCanGetSnowBase()
	if me.nLevel < self.nMakeSnowBoyBaseLevel then
		return 0,"你的等级未达到参加活动的等级！";
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法进行堆雪人活动！";
	end
	local nGetSnowBaseCount = me.GetTask(self.nTaskGroupId,self.nHasGetSnowBaseCountTaskId);
	if nGetSnowBaseCount >= self.nGetSnowBaseMaxCount then
		return 0,string.format("你今天已经领取过%s次未完成的雪人坯，活动期间每人每天只能领取一个未完成的雪人坯！",self.nGetSnowBaseMaxCount);
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!";
	end
	return 1;	
end


---------------------雪城建设
function Xmas2011:AddSnowMan_GS()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	local nMapId = self.tbSnowManPosInfo[1];
	if not nMapId or IsMapLoaded(nMapId) ~= 1 then
		return 0;
	end
	if not self.nSnowManCity or not KNpc.GetById(self.nSnowManCity) then
		local pNpc = KNpc.Add2(self.nSnowManTemplateId,10,-1,unpack(self.tbSnowManPosInfo));
		if not pNpc then
			Dbg:WriteLog("SpecialEvent","Xmas2011,Add City SnowMan Failed!",unpack(self.tbSnowManPosInfo));
		else
			local nCurrentProcess = KGblTask.SCGetDbTaskInt(DBTASK_XMAS_SNOWMAN_PROCESS) or 0;
			pNpc.GetTempTable("SpecialEvent").nCurrentProcess = nCurrentProcess;	--存储当前进度
			self.nSnowManCity = pNpc.dwId;
			if nCurrentProcess < self.nFinishProduceNeedMaxCount then
				self:StartSyncProduceProcessTimer();
			end
		end
	end
end

--启动同步建设进度的计时器
function Xmas2011:StartSyncProduceProcessTimer()
	if self.nSyncProcessTimer and self.nSyncProcessTimer > 0 then
		Timer:Close(self.nSyncProcessTimer);
		self.nSyncProcessTimer = 0;
	end
	self.nSyncProcessTimer = Timer:Register(self.nSyncProduceProgressTimeDelay,self.OnSyncProduceProcess,self);
	return 1;
end

function Xmas2011:OnSyncProduceProcess()
	if self:IsEventOpen() ~= 1 then
		self.nSyncProcessTimer = 0;
		return 0;
	end
	local pNpc = KNpc.GetById(self.nSnowManCity or 0);
	if not pNpc then
		self.nSyncProcessTimer = 0;
		return 0;
	end
	local nOrgProcess = KGblTask.SCGetDbTaskInt(DBTASK_XMAS_SNOWMAN_PROCESS) or 0;
	local nCurrentProcess = pNpc.GetTempTable("SpecialEvent").nCurrentProcess or 0;
	local nDeta = nCurrentProcess - nOrgProcess;
	GCExcute({"SpecialEvent.Xmas2011:OnSyncProduceProcess",nDeta});
end

function Xmas2011:StopSyncTimer()
	if self.nSyncProcessTimer and self.nSyncProcessTimer > 0 then
		Timer:Close(self.nSyncProcessTimer);
		self.nSyncProcessTimer = 0;
	end
	return 1;
end

--测试用
function Xmas2011:SetProduceProgress(nProgress)
	if not nProgress then
		return 0;
	end
	local pNpc = KNpc.GetById(self.nSnowManCity or 0);
	pNpc.GetTempTable("SpecialEvent").nCurrentProcess = nProgress;
	local nOrgProcess = KGblTask.SCGetDbTaskInt(DBTASK_XMAS_SNOWMAN_PROCESS) or 0;
	GCExcute({"SpecialEvent.Xmas2011:OnSyncProduceProcess",-(nOrgProcess - nProgress)});
	self:StopSyncTimer();
	self:StartSyncProduceProcessTimer();
end


--服务器启动事件
function Xmas2011:OnServerStart()
	if self:IsEventOpen() == 1 then
		self:AddDecoration_GS();	--加装饰npc
		self:AddSnowMan_GS();
	end
end

--注册启动回调
if Xmas2011:IsEventOpen() == 1 then
	ServerEvent:RegisterServerStartFunc(Xmas2011.OnServerStart,Xmas2011);
end




------------圣诞关卡
function Xmas2011:OnJoinXmasMission()
	local szMsg = "我带你去圣诞秘境吧！"
	local tbOpt = {};
	tbOpt[#tbOpt + 1] ={"闯入圣诞秘境",self.ProcessOpenMission,self};
	tbOpt[#tbOpt + 1] ={"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function Xmas2011:ProcessOpenMission()
	if me.nFaction <= 0 then
		Dialog:Say("想进入圣诞秘境，先加了门派再来找我！");
		return 0;
	end
	if me.nLevel < self.nJoinXmasMissionBaseLevel then
		Dialog:Say(string.format("想进入圣诞秘境，等你达到%s级再来吧！",self.nJoinXmasMissionBaseLevel));
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		Dialog:Say("想进入圣诞秘境，请组队前来！");
		return 0;
	end
	local pGame =  CFuben:GetGameByTeamId(me.nTeamId,self.nXmasGameType,self.nXmasGameId);
	local tbOpt =  {};
	local szMsg = "我带你去圣诞秘境吧！"
	if not pGame then
		tbOpt[#tbOpt + 1] = {"开启圣诞秘境",self.ApplyXmasGame,self};
	else
		tbOpt[#tbOpt + 1] = {"进入圣诞秘境",self.TransferXmasGame,self};
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function Xmas2011:ApplyXmasGame()
	if me.nFaction <= 0 then
		Dialog:Say("想进入圣诞秘境，先加了门派再来找我！");
		return 0;
	end
	if me.nLevel < self.nJoinXmasMissionBaseLevel then
		Dialog:Say(string.format("想进入圣诞秘境，等你达到%s级再来吧！",self.nJoinXmasMissionBaseLevel));
		return 0;
	end
	if me.nTeamId <= 0 then
		Dialog:Say("想进入圣诞秘境，请组队前来！");
		return 0;
	end
	if me.IsCaptain() ~= 1 then
		Dialog:Say("想进入圣诞秘境，请队长前来报名！");
		return 0;
	end
	local nNearby = 0;
	local tbMemberId,nCount = KTeam.GetTeamMemberList(me.nTeamId);
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 40);
	for _,tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		Dialog:Say("对不起，有队友不在身边！");
		return 0;
	end
	if nCount < self.nJoinXmasGameBaseMemberCount then
		Dialog:Say(string.format("对不起，进入圣诞秘境，队伍人数不能小于%s，请组齐了人再来报名！",self.nJoinXmasGameBaseMemberCount));
		return 0;
	end
	--todo,检查队友身上次数，和队友身上道具是否符合条件
	local nIsPlayerHasNoItem ,tbNoItemPlayerName = 0 , {};
	local nIsPlayerNoGetLevel,tbNoGetLevelPlayerName = 0,{};
	local nIsPlayerNoFaction,tbNoFactionPlayerName = 0, {};
	local nIsPlayerHasNoMask,tbNoMaskPlayerName = 0,{}
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if pMember then
			if self:CheckHaveJoinGameItem(pMember) ~= 1 then
				nIsPlayerHasNoItem = 1;
				table.insert(tbNoItemPlayerName,pMember.szName);
			end
			if pMember.nLevel < self.nJoinXmasMissionBaseLevel then
				nIsPlayerNoGetLevel = 1;
				table.insert(tbNoGetLevelPlayerName,pMember.szName);
			end
			if pMember.nFaction <= 0 then
				nIsPlayerNoFaction = 1;
				table.insert(tbNoFactionPlayerName,pMember.szName);
			end
			local pMask = pMember.GetEquip(Item.EQUIPPOS_MASK);
			if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
				nIsPlayerHasNoMask = 1;
				table.insert(tbNoMaskPlayerName,pMember.szName);
			end
		end
	end
	if nIsPlayerNoGetLevel == 1 then	--有等级未达到的
		local szMsg = "";
		for _,szName in pairs(tbNoGetLevelPlayerName) do
			szMsg = szMsg .. string.format("<color=yellow>%s<color>等级未达到%s级！\n",szName,self.nJoinXmasMissionBaseLevel);
		end
		Dialog:Say(szMsg);
		return 0;
	end
	if nIsPlayerNoFaction == 1 then		--有未加入门派的
		local szMsg = "";
		for _,szName in pairs(tbNoFactionPlayerName) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color>未加入任何门派！\n";
		end
		Dialog:Say(szMsg);
		return 0;
	end
	if nIsPlayerHasNoItem == 1 then
		local szMsg = "";
		for _,szName in pairs(tbNoItemPlayerName) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color>身上没有圣诞邀请卡！\n";
		end
		Dialog:Say(szMsg);
		return 0;
	end
	if nIsPlayerHasNoMask == 1 then
		local szMsg = "";
		for _,szName in pairs(tbNoMaskPlayerName) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color>身上没有装备圣诞欢喜面具！\n";
		end
		Dialog:Say(szMsg);
		return 0;	
	end
	local pGame = CFuben:GetGameByTeamId(me.nTeamId,self.nXmasGameType,self.nXmasGameId);
	if not pGame then
		if CFuben:ApplyFuBenEx(self.nXmasGameType,self.nXmasGameId,me.nId,Xmas2011.RoomXmas) == 1 then	--初始化副本
			local tbOpt = {};	
			tbOpt[#tbOpt + 1] = {"进入圣诞秘境",self.TransferXmasGame,self};
			tbOpt[#tbOpt + 1] = {"稍等片刻"};
			Dialog:Say("你已经开启了圣诞秘境，叫上队友快进去挑战吧！",tbOpt);		
			KTeam.Msg2Team(me.nTeamId,"队长开启了<color=white>圣诞秘境<color>，请大家前往挑战！该副本重伤后将无法再次进入，请侠士们小心！");
			local szAnn = "圣诞秘境已经开启，请大家前往挑战！";
			for _, nMemberId in pairs(tbMemberId) do
				local pMember = KPlayer.GetPlayerObjById(nMemberId);
				if pMember then
					Dialog:SendBlackBoardMsg(pMember,szAnn);
				end
			end
			StatLog:WriteStatLog("stat_info","shengdanjie_2011","room_open",me.nId,1);
			return 0;
		end
	end
end

function Xmas2011:CheckHaveJoinGameItem(pPlayer)
	if not pPlayer then
		return 0;
	end
	local tbFind = pPlayer.FindItemInBags(unpack(self.tbJoinXmasGameNeedItem));
	if #tbFind < 1 then
		return 0;
	end
	return 1;
end


function Xmas2011:TransferXmasGame()
	if me.nFaction <= 0 then
		Dialog:Say("想进入圣诞秘境，先加了门派再来找我！");
		return 0;
	end
	if me.nLevel < self.nJoinXmasMissionBaseLevel then
		Dialog:Say(string.format("想进入圣诞秘境，等你达到%s级再来吧！",self.nJoinXmasMissionBaseLevel));
		return 0;
	end
	if me.nTeamId <= 0 then
		Dialog:Say("想进入圣诞秘境，请组队前来！");
		return 0;
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		Dialog:Say("你身上没有装备圣诞欢喜面具，无法进入圣诞秘境！");
		return 0;
	end
	local pGame = CFuben:GetGameByTeamId(me.nTeamId,self.nXmasGameType,self.nXmasGameId);
	if not pGame then
		Dialog:Say("你们队伍没有开启圣诞秘境，无法进入！请确定开启圣诞秘境是当前队长！");
		return 0;
	end
	local tbPlayerIdList = KTeam.GetTeamMemberList(me.nTeamId);
	local nCaptainId = tbPlayerIdList[1];
	local nTempMapId = pGame[1];
	local nDyMapId = pGame[2];
	if CFuben.tbMapList[nTempMapId][nDyMapId].DeathPlayerList[me.nId] == 1 then
		local szMsg = "你已经从圣诞密境中重伤出来了，无法再次进入！"
		Dialog:SendBlackBoardMsg(me,szMsg);
		me.Msg(szMsg);
		return 0;
	end
	if CFuben:IsSatisfy(me.nId,nCaptainId) == 0 then			
		return 0;
	end
	if CFuben.tbMapList[nTempMapId][nDyMapId].PlayerList[me.nId] ~= 1 then	--没进入的不用再扣道具了
		if self:CheckHaveJoinGameItem(me) ~= 1 then
			Dialog:Say("你身上没有圣诞邀请卡，无法进入圣诞秘境！");
			return 0;
		end
		local tbItem = me.FindItemInBags(unpack(self.tbJoinXmasGameNeedItem));
		local pItem = tbItem[1].pItem;
		if me.DelItem(pItem,Player.emKLOSEITEM_USE) == 1 then
			CFuben.tbMapList[nTempMapId][nDyMapId].MissionList.nConsumeItemCount = (CFuben.tbMapList[nTempMapId][nDyMapId].MissionList.nConsumeItemCount or 0) + 1;
			CFuben:JoinGame(me.nId,nCaptainId);
			StatLog:WriteStatLog("stat_info","shengdanjie_2011","room_join",me.nId,1);
			return 0;
		else
			Dbg:WriteLog("SpecialEvent","Xmas2011,Delele Xmas Game Item Error",me.nId,me.szName);
			return 0;
		end
	else
		CFuben:JoinGame(me.nId,nCaptainId);
		return 0;		
	end
end

-------------家族关卡boss
function Xmas2011:AddKinGameXmasBoss(nType,nLevel,nMapId,nX,nY)
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	if not self.tbKinGameBossTimer then
		self.tbKinGameBossTimer = {};
	end
	self:AddKinGameWaitNpc(nLevel,nMapId,nX,nY);
	self.tbKinGameBossTimer[nMapId] = Timer:Register(self.nWaitTime * Env.GAME_FPS,self.OnAddXmasBoss,self,nType,nLevel,nMapId,nX,nY);
end

function Xmas2011:AddKinGameWaitNpc(nLevel,nMapId,nX,nY)
	local pNpc =  KNpc.Add2(self.nWaitNpcTemplateId,nLevel,-1,nMapId,nX,nY);
	if pNpc then
		pNpc.SetLiveTime((self.nWaitTime - 2) * Env.GAME_FPS);	--刷boss前几秒删掉
	end
end

function Xmas2011:OnAddXmasBoss(nType,nLevel,nMapId,nX,nY)
	local nTempId = self.tbKinGameXmasBossTemplateId[nType] or 9837;
	local pNpc =  KNpc.Add2(nTempId,nLevel or 100,-1,nMapId,nX,nY);
	if not pNpc then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Add KinGame Xmas Boss Failed",nLevel,nMapId,nX,nY);
	else
		Npc:RegPNpcOnDeath(pNpc,self.OnXmasKinBossDeath,self);
	end
	self.tbKinGameBossTimer[nMapId] = 0;
	return 0;
end

function Xmas2011:OnXmasKinBossDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	local nLevel = Xmas2011:GetPrizeLevel();
	local szFile = Xmas2011.tbNoramlDropFile[nLevel];
	if szFile then
		him.DropRateItem(szFile,20,-1,-1,0);	--boss掉落
	end
	local szMaskFile = Xmas2011.szMaskDropFile;
	if szMaskFile then
		him.DropRateItem(szMaskFile,20,-1,-1,0);	--boss掉落
	end
end

-------------下雪控制
function Xmas2011:ProcessSnowTimer_GS(nFlag)
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	if not self.tbSnowTimer then
		self.tbSnowCheckTimer = {};
	end
	if nFlag == 1 then
		for _,nMapId in pairs(self.tbSnowCityId) do
			if IsMapLoaded(nMapId) == 1 then
				if self.tbSnowCheckTimer[nMapId] and self.tbSnowCheckTimer[nMapId] > 0 then
					Timer:Close(self.tbSnowCheckTimer[nMapId]);
					self.tbSnowCheckTimer[nMapId] = 0;
				end
				Xmas2011:OnBeginSnow(nMapId);	--整点先下一次
				self.tbSnowCheckTimer[nMapId] = Timer:Register(self.nSnowCheckTime,self.OnBeginSnow,self,nMapId);
			end
		end
	else
		if not self.tbSnowCheckTimer then
			return 0;
		end
		for nMapId,nTimer in pairs(self.tbSnowCheckTimer) do
			if nTimer and nTimer > 0 then
				Timer:Close(nTimer);
				self.tbSnowCheckTimer[nMapId] = 0;
			end
		end
	end	
end

function Xmas2011:OnBeginSnow(nMapId)
	ChangeWorldWeather(nMapId,self.nSnowWeatherId);
	Timer:Register(self.nSnowDelayTime,self.OnEndSnow,self,nMapId);
end

function Xmas2011:OnEndSnow(nMapId)
	ChangeWorldWeather(nMapId,0);
	return 0;
end