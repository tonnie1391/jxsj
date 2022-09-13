
local tbNpc = Npc:GetClass("merchant_quest")
local DELAY_TIME = 10; --鉴定30秒
local tbEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
}

local tbQuestItem =
{	--npcId，物品Id，重生时间
	[1624] = {469, 30 * Env.GAME_FPS},
	[1625] = {470, 30 * Env.GAME_FPS},
	[1626] = {471, 30 * Env.GAME_FPS},
	[1627] = {472, 30 * Env.GAME_FPS},
	[1628] = {473, 30 * Env.GAME_FPS},
	[1629] = {474, 30 * Env.GAME_FPS},
	[1630] = {475, 30 * Env.GAME_FPS},
	[1631] = {476, 60 * Env.GAME_FPS},
	[1632] = {477, 60 * Env.GAME_FPS},
	[1633] = {478, 120 * Env.GAME_FPS},
	[1634] = {479, 120 * Env.GAME_FPS},
	[1635] = {480, 180 * Env.GAME_FPS},
};

function tbNpc:OnDialog()
	self:SetNpcIgnoreBarrier(me);
	if Merchant:GetTask(Merchant.TASK_STEP_COUNT) <= 0 then
		return 0;
	end
	
	local nTypeId =  Merchant:GetTask(Merchant.TASK_TYPE);
	local nStepType =  Merchant:GetTask(Merchant.TASK_STEP);
	local nLevelType  =  Merchant:GetTask(Merchant.TASK_LEVEL);
	local nNowTaskId =  Merchant:GetTask(Merchant.TASK_NOWTASK);
		
	if Merchant:GetTask(Merchant.TASK_TYPE) ~= Merchant.TYPE_COLLECTITEM and Merchant:GetTask(Merchant.TASK_TYPE) ~= Merchant.TYPE_COLLECTITEM_NEW then
		return 0;
	end
	local tbTarget = Merchant.TaskFile[nStepType].TypeClass[nTypeId][nLevelType].TaskEvent[nNowTaskId];
	local nNum = tbTarget.Num or 1;
	local nGenre = tbTarget.Genre;
	local nDetail = tbTarget.Detail;
	local nParticular = tbTarget.Particular;
	local nLevel = tbTarget.Level;
	if nParticular ~= tbQuestItem[him.nTemplateId][1] then
		return 0;
	end
	if nGenre > 0 and nDetail > 0 and nParticular > 0 and nLevel > 0 then
		local tbFind1 = me.FindItemInBags(nGenre,nDetail,nParticular,nLevel);
		if #tbFind1 >= nNum then
			return 0;
		end
	else
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống");
		return 0;
	end
	GeneralProcess:StartProcess("Đang thu thập...", DELAY_TIME * Env.GAME_FPS, {self.GetQuest, self, me.nId, him.dwId}, nil, tbEvent);
end

function tbNpc:SetNpcIgnoreBarrier(pPlayer)
	local tbIgnoreMapList = {
		[90] = {[2968]=1},	--剑贼
	};
	local tbIgnoreNpcList = tbIgnoreMapList[pPlayer.nMapId];
	if not tbIgnoreNpcList then
		return 0;
	end
	if self.nSetNpcIgnoreBarrier and self.nSetNpcIgnoreBarrier + 180 > GetTime() then
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 50);
	for _, pNpc in pairs(tbNpcList) do
		if pNpc.nKind == 0 and tbIgnoreNpcList[pNpc.nTemplateId] then
			pNpc.SetIgnoreBarrier(1);
		end
	end
	self.nSetNpcIgnoreBarrier = GetTime();
end

function tbNpc:GetQuest(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return;
	end	
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	if not tbQuestItem[pNpc.nTemplateId] then
		return 0;
	end
	local nTypeId =  Merchant:GetTask(Merchant.TASK_TYPE);
	local nStepType =  Merchant:GetTask(Merchant.TASK_STEP);
	local nLevelType  =  Merchant:GetTask(Merchant.TASK_LEVEL);
	local nNowTaskId =  Merchant:GetTask(Merchant.TASK_NOWTASK);
		
	if Merchant:GetTask(Merchant.TASK_TYPE) ~= Merchant.TYPE_COLLECTITEM and Merchant:GetTask(Merchant.TASK_TYPE) ~= Merchant.TYPE_COLLECTITEM_NEW then
		return 0;
	end
	local tbTarget = Merchant.TaskFile[nStepType].TypeClass[nTypeId][nLevelType].TaskEvent[nNowTaskId];
	local nNum = tbTarget.Num or 1;
	local nGenre = tbTarget.Genre;
	local nDetail = tbTarget.Detail;
	local nParticular = tbTarget.Particular;
	local nLevel = tbTarget.Level;
	
	if nParticular ~= tbQuestItem[pNpc.nTemplateId][1] then
		return 0;
	end
	local pItem = me.AddItem(20, 1, tbQuestItem[pNpc.nTemplateId][1], 1);
	if pItem then
		pItem.Bind(1);
		pPlayer.SetItemTimeout(pItem, 120);
		pItem.Sync();
	end
	if nGenre > 0 and nDetail > 0 and nParticular > 0 and nLevel > 0 then
		local szName = KItem.GetNameById(nGenre, nDetail, nParticular, nLevel)
		local tbFind1 = me.FindItemInBags(nGenre,nDetail,nParticular,nLevel);
		if #tbFind1 >= nNum then
			Dialog:SendBlackBoardMsg(pPlayer, string.format("Nhận được %s %s",nNum, szName));
		end	
	end
	local nMapId, nPosX, nPosY = pNpc.GetWorldPos();
	Timer:Register(tbQuestItem[pNpc.nTemplateId][2], self.NpcReliveAgain, self, pNpc.nTemplateId, nMapId, nPosX, nPosY);
	pNpc.Delete();
	return 0;
end

function tbNpc:NpcReliveAgain(nNpcId, nMapId, nPosX, nPosY)
	local pNpc = KNpc.Add2(nNpcId, 60, -1, nMapId, nPosX, nPosY);
	if not pNpc then
		return 
	end
	return 0;
end
