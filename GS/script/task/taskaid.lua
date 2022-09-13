
-------------------------------------------------------------------------
-- 关于进度条目标
function Task:GetProgressData()
	local tbPlayerData				= me.GetTempTable("Task");
	local tbPlayerProgressTagData	= tbPlayerData.tbProgressTagData;
	if (not tbPlayerProgressTagData) then
		tbPlayerProgressTagData	= {};
		tbPlayerData.tbProgressTagData	= tbPlayerProgressTagData;
	end;
	
	return tbPlayerProgressTagData;
end


function Task:SetProgressTag(tbTag, pPlayer)
	Setting:SetGlobalObj(pPlayer)
	local tbPlayerProgressTagData = self:GetProgressData();
	tbPlayerProgressTagData.tbTag = tbTag;
	Setting:RestoreGlobalObj()
end;

function Task:OnProgressTagFinish()
	local tbPlayerProgressTagData = self:GetProgressData();
	tbPlayerProgressTagData.tbTag.OnProgressFull(tbPlayerProgressTagData.tbTag);
	tbPlayerProgressTagData.tbTag = nil;
end


-------------------------------------------------------------------------
-- 关于给予物品目标
Task.GiveItemTag = Task.GiveItemTag or {};
Task.GiveItemTag.tbGiveForm = Gift:New();

local tbGiveForm = Task.GiveItemTag.tbGiveForm;

tbGiveForm._szTitle = "给予物品目标";



function tbGiveForm:GetGiveFormData()
	local tbPlayerData				= me.GetTempTable("Task");
	local tbPlayerGiveFormData	= tbPlayerData.tbGiveFormData;
	if (not tbPlayerGiveFormData) then
		tbPlayerGiveFormData	= {};
		tbPlayerData.tbGiveFormData	= tbPlayerGiveFormData;
	end;
	
	return tbPlayerGiveFormData;
end


function tbGiveForm:SetRegular(tbTag, pPlayer)
	self._szContent = tbTag.szDesc or "";
	if #self._szContent == 0 and tbTag.GetDesc then
		self._szContent = tbTag:GetDesc();
	end
	pPlayer.CallClientScript({"Gift:SetContent", self._szContent})
	Setting:SetGlobalObj(pPlayer)
	local tbPlayerGiveFormData = self:GetGiveFormData();
	tbPlayerGiveFormData.tbTag = tbTag;
	Setting:RestoreGlobalObj()
end


function tbGiveForm:OnOK()
	local nTotalNeed = 0;
	local tbTag = self:GetGiveFormData().tbTag;
	
	--商会任务判断 特殊处理
	if tbTag.tbTask.nTaskId == Merchant.TASKDATA_ID then
		local _, _, nItemFree = Merchant:GetStepAward(Merchant:GetTask(Merchant.TASK_STEP_COUNT), 0)
		if me.CountFreeBagCell() < nItemFree then
			Dialog:Say("对不起，您的背包空间不足，请整理背包后再交任务领取奖励。");
			return 0;
		end
	end
		
	--按名字和魔法属性
	if tbTag.szTargetName == "GiveItemWithName" then
		tbTag.ItemList.nRemainCount = tbTag.ItemList[3];
		nTotalNeed = tbTag.ItemList[3];
		
		-- 遍历判断给与界面中每个格子的物品
		local nFormItemCount = 0;
		local pFind = self:First();
		while pFind do
			nFormItemCount = nFormItemCount + pFind.nCount;
			tbTag.ItemList.nRemainCount = self:DecreaseItemInListWithName(pFind, tbTag.ItemList) - pFind.nCount;
			pFind = self:Next();
		end
		if (nFormItemCount ~= nTotalNeed) then
			tbTag.me.Msg("物品数目不对!")
			return;
		end
		if (tbTag.ItemList.nRemainCount ~= 0) then
			tbTag.me.Msg("给的物品不合要求!")
			return;
		end	
	else
	
		-- 把 table 里每个物品的数量等同于原始的数量，并计算总数量
		for i=1, #tbTag.ItemList do
			tbTag.ItemList[i].nRemainCount = tbTag.ItemList[i][6];
			nTotalNeed = nTotalNeed + tbTag.ItemList[i][6];
		end
	
		-- 遍历判断给与界面中每个格子的物品
		local nFormItemCount = 0;
		local pFind = self:First();
		while pFind do
			nFormItemCount = nFormItemCount + pFind.nCount;
			self:DecreaseItemInList(pFind, tbTag.ItemList);
			pFind = self:Next();
		end
		if (nFormItemCount ~= nTotalNeed) then
			tbTag.me.Msg("物品数目不对!")
			return;
		end
		for _,tbItem in ipairs(tbTag.ItemList) do
			if (tbItem.nRemainCount ~= 0) then
				tbTag.me.Msg("给的物品不合要求!")
				return;
			end
		end
	end
	-- 删除物品
	local pFind = self:First();
	while pFind do
		tbTag.me.DelItem(pFind, Player.emKLOSEITEM_TYPE_TASKUSED);
		pFind = self:Next();
	end
	
	--设置目标成功
	tbTag.OnFinish(tbTag);
	me.CallClientScript({"UiManager:CloseWindow","UI_ITEMBOX"});
end;

-- 判断指定物品是否在靠标物品列表中，若在则把数量 -1(通过物品GDPL)
function tbGiveForm:DecreaseItemInList(pFind, tbItemList)
	for _,tbItem in ipairs(tbItemList) do
		if (tbItem[1] == pFind.nGenre and 
			tbItem[2] == pFind.nDetail and 
			tbItem[3] == pFind.nParticular and 
			(tbItem[4] == pFind.nLevel or tbItem[4] == -1) and 
			(tbItem[5] == pFind.nSeries or tbItem[5] == -1)) then
				tbItem.nRemainCount = tbItem.nRemainCount - pFind.nCount;
				return 1;
		end
	end
	
	return 0;
end

-- 判断指定物品是否在靠标物品列表中，若在则把数量 -1(通过物品名)
function tbGiveForm:DecreaseItemInListWithName(pFind, tbItemList)
	if (tbItemList[1] == pFind.szOrgName and 
		tbItemList[2] == pFind.szSuffix) then
			return pFind.nCount;
	end
	return 0;
end

-------------------------------------------------------------------------
-- 根据地图ID获得地图名字
function Task:GetMapName(nMapId)
	if (not nMapId or nMapId <= 0) then
		return "";
	end
		return GetMapNameFormId(nMapId);
end

-- 青螺岛战车任务。。
function Task:_Specil_DoTaskByCarrier()
	local nMapId, nX, nY = me.GetWorldPos();
	local pCarrier = KNpc.Add2(11049, 20, -1, nMapId, nX + 5, nY + 5, 0, 0, 0, 0, -1, 40);
	if not pCarrier then
		return;
	end	

	me.RideHorse(0);
	--提高跑速
	pCarrier.AddSkillState(2929,10,0,90*18,1,1,1,0,1);
	pCarrier.SetActiveForever(1);
	pCarrier.SetLiveTime(15 * 60 * 18);		-- 可以存活15分钟
	local tb = {};	
	table.insert(tb, {nil, nil, 8});
	local sz = string.format([[local pPlayer = ...;
	        local _, x, y = %d, %d, %d;
	        pPlayer.DoCommand(4, x * 32, y * 32, 600);]],
	        pCarrier.GetWorldPos());
	table.insert(tb, {nil, sz, 20})		-- 做跳的动作
	sz = string.format("local pPlayer = ...;pPlayer.SetFightState(0);pPlayer.LandInCarrier(%d, %d);", pCarrier.nIndex, 0)
	table.insert(tb, {nil, sz, 30});	-- 上战车
	
	local szCarrier = "local pPlayer = ...;local pCarrier = pPlayer.GetCarrierNpc(); if (not pCarrier) then return end;";		
	local tbMovePos = {{1956, 3546}, {1966, 3559}, {1981, 3554}, {1992, 3536}, {2007, 3540}};
	for _, tbPos in pairs(tbMovePos) do
		sz = string.format("%spCarrier.DoCommand(3,%d,%d)", szCarrier, tbPos[1]*32, tbPos[2]*32)
		table.insert(tb, {nil, sz, 50});	-- 移动到指定点
		sz = string.format("%spCarrier.DoSkill(%d,%d,%d);", szCarrier, 604,tbPos[1]+10, tbPos[2]+10);
		table.insert(tb, {nil, sz, 30});	-- 释放技能	
	end
	
	sz = "local pPlayer = ...;Task:_Specil_OnCarrierTaskFinished(pPlayer, 1);";		-- 任务目标完成
	table.insert(tb, {nil, sz, 15});
	sz = "local pPlayer = ...;Task:_Specil_OnCarrierTaskFinished(pPlayer, 2);";		-- 删除载具
	table.insert(tb, {nil, sz, 15});
	Player:DoServerCmd(me, tb);
end

function Task:_Specil_OnCarrierTaskFinished(pPlayer, nStep)
	
	if nStep == 1 then			
		-- 1025, 84是该步任务目标完成标记对应任务变量，1表示完成
		pPlayer.SetTask(1025, 84, 1);	-- 设置任务目标完成
	elseif nStep == 2 then
		pPlayer.LandOffCarrier();		
		pPlayer.SetFightState(1);
	end	
end

--青螺岛燃烧芦苇荡
function Task:_Specil_BurnLuWei()
	if MODULE_GAMESERVER then
		me.CallClientScript({"Task:_Specil_BurnLuWei"});
	else
		--自身附近多个小火墙
		local nMapId, nMapX, nMapY = me.GetWorldPos();
		for i=1,30 do
			local x = nMapX + MathRandom(-15, 15);
			local y = nMapY + MathRandom(-10, 10);
			me.CastSkill(153,1,x*32,y*32);
		end	
	end
end

--青螺岛任务选择新手村
function Task:_Specil_SelectCountry()
	-- 先检查任务步骤
	local nMainTaskId = tonumber("001", 16);
	local nSubTaskId = tonumber("008", 16);
	local tbTaskRange = {4, 5};
	local bContinue = 0;
	
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	local tbTask = tbPlayerTasks[nMainTaskId];	-- 主任务ID
	
	if tbTask and tbTask.nReferId == nSubTaskId then
		if (tbTask.nCurStep >= tbTaskRange[1] and tbTask.nCurStep <= tbTaskRange[2]) then
			bContinue = 1;
		end
	end
	
	if bContinue == 0 then
		return 0;
	end
	
	local szMsg = "Mời chọn Tân Thủ Thôn dưới đây:";
	local tbOpt = 
	{
		{"Vân Trung Trấn", me.NewWorld, 1, 1388, 3098},	
		{"Giang Tân Thôn", me.NewWorld, 5, 1598, 3121},
		{"Vĩnh Lạc Trấn", me.NewWorld, 3, 1589, 3196},
	}
	Lib:SmashTable(tbOpt);
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
	return 1;
end

-- 青螺岛信鸽
function Task:_Specil_FlyABird()    
	local tbFlyToPos = 
	{
		[1] =
		{
			{ 1678 * 32, 3541 * 32},
			{ 1664 * 32, 3529 * 32},
			{ 1662 * 32, 3548 * 32},
			{ 1681 * 32, 3526 * 32},
			{ 1689 * 32, 3519 * 32},
--			{ 1678 * 32, 3534 * 32},
--			{ 1673 * 32, 3548 * 32},
--			{ 1667 * 32, 3544 * 32},
--			{ 1668 * 32, 3532 * 32},
--			{ 1675 * 32, 3537 * 32},
--			{ 1683 * 32, 3543 * 32},
--			{ 1692 * 32, 3530 * 32},
		},
		[2] =
		{     
			{ 1681 * 32, 3526 * 32},
			{ 1666 * 32, 3549 * 32},
			{ 1664 * 32, 3529 * 32},
			{ 1679 * 32, 3541 * 32},
			{ 1690 * 32, 3537 * 32},
--			{ 1670 * 32, 3547 * 32},
--			{ 1672 * 32, 3536 * 32},
--			{ 1677 * 32, 3531 * 32},
--			{ 1681 * 32, 3544 * 32},
--			{ 1667 * 32, 3537 * 32},
--			{ 1664 * 32, 3527 * 32},
--			{ 1662 * 32, 3515 * 32},
		}
	}
	
	local nM, nX, nY = me.GetWorldPos();
	local tbPos = tbFlyToPos[MathRandom(1, #tbFlyToPos)];
	local pBird = KNpc.Add2(11053, 1, -1, nM, nX, nY);
	if not pBird then
		return;
	end
	
	pBird.AddSkillState(116, 1, 1, 18 * 3600);	--2223
	pBird.AI_ClearPath();
	for _, pos in pairs(tbPos) do
		pBird.AI_AddMovePos(unpack(pos));		
	end

	pBird.SetNpcAI(9, 0, 1, -1, 25, 25, 25, 0, 0, 0, 0);
	pBird.GetTempTable("Npc").tbOnArrive = {self._Specil_FlyBirdArrived, self, pBird.dwId};	
end

function Task:_Specil_FlyBirdArrived(dwNpcId)
	local pBird = KNpc.GetById(dwNpcId);
	if not pBird then
		return;
	end
	
	pBird.GetTempTable("Npc").tbOnArrive = nil;
	pBird.Delete();
end

-- 花灯乱坐船timer回调
function Task:OnHuaDengLuanBoatTimer(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local tbParam= {};
	tbParam.nFadeinTime = 2000;
	tbParam.nLastTime = 3000;
	tbParam.nFadeOutTime = 1000;
	tbParam.szImage ="chahua_song_bie.spr";
	tbParam.szTalk = "一湖斜雨，半纸书。两处相忆，共江湖。";
	Dialog:PlayIlluastration(pPlayer, tbParam)
	return 0;
end

------------ 以下函数可能不应该属于任务系统，暂时放在这里

-- 取得物品拥有数量
function Task:GetItemCount(pPlayer, tbItemId, nRoom)
	if (not nRoom) then
		local tbItemList;
		if (not tbItemId[5] or tbItemId[5] < 0) then
			tbItemList = self:GetPlayerItemList(pPlayer, {tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4]});
		else
			tbItemList = self:GetPlayerItemList(pPlayer, {tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], tbItemId[5]});
		end
		local nCount = 0;
		for i = 1, #tbItemList do
			nCount = nCount + tbItemList[i].nCount;
		end
		return nCount;
	else
		return pPlayer.GetItemCount(nRoom, {tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4]});
	end
end;


-- 删除物品
function Task:DelItem(pPlayer, tbItemId, nDelCount)
--	assert(tbItemId[1] == 20);
	if (not nDelCount) then
		nDelCount	= 1;
	end;
	
	assert(type(nDelCount) == "number");
		
	local tbItemList = self:GetPlayerItemList(pPlayer, tbItemId);
	local i = 1;
	while (nDelCount >= 1 ) do
		if (not tbItemList[i]) then
			return;
		end
		local nItemCount = tbItemList[i].nCount;
		if (nItemCount <= 0) then
			return 0;
		end
		if (nItemCount > nDelCount) then
			tbItemList[i].SetCount(nItemCount - nDelCount, Item.emITEM_DATARECORD_REMOVE);
			break;
		else
			nDelCount = nDelCount - nItemCount;
			tbItemList[i].Delete(pPlayer);
		end
		i = i + 1;
	end
	
	return 1;
end;

-- 获得玩家指定物品列表
function Task:GetPlayerItemList(pPlayer, tbItemId)
	local tbItemList = {};
	local tbNeedSearchRoom = {
			Item.ROOM_EQUIP,
			Item.ROOM_EQUIPEX,
			Item.ROOM_MAINBAG,		-- 主背包
			Item.ROOM_REPOSITORY,	-- 贮物箱
			Item.ROOM_EXTBAG1,		-- 扩展背包1
			Item.ROOM_EXTBAG2,		-- 扩展背包2
			Item.ROOM_EXTBAG3,		-- 扩展背包3
			Item.ROOM_EXTREP1,		-- 扩展贮物箱1
			Item.ROOM_EXTREP2,		-- 扩展贮物箱2
			Item.ROOM_EXTREP3,		-- 扩展贮物箱3
			Item.ROOM_EXTREP4,		-- 扩展贮物箱4
			Item.ROOM_EXTREP5,		-- 扩展贮物箱5
		};
	for _,room in pairs(tbNeedSearchRoom) do
		local tbRoomItemList = pPlayer.FindItem(room, tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], tbItemId[5] or 0);
		for _, item in ipairs(tbRoomItemList) do
			tbItemList[#tbItemList + 1] = item.pItem;
		end
	end	
	
	return tbItemList;
end

function Task:IsSameItem(tbItem1, tbItem2)
	if (tbItem1[1] ~= tbItem2[1] or 
		tbItem1[2] ~= tbItem2[2] or 
		tbItem1[3] ~= tbItem2[3] or 
		tbItem1[4] ~= tbItem2[4] or 
		tbItem1[5] ~= tbItem2[5]) then
		
		return 0;
	end
	
	return 1;
end

-- 解析字符串<npc=xxx><playername>
function Task:ParseTag(szMsg)
	local nCurIdx = 1;
	while true do
		local nNpcTagStart, nNpcIdStart	= string.find(szMsg, "<npc=");
		local nNpcTagEnd, nNpcIdEnd			= string.find(szMsg, ">", nNpcIdStart);
		local nNpcTempId = -1;
		if (not nNpcIdStart or not nNpcIdEnd) then
			break;
		end
		local nNpcTempId 		= tonumber(string.sub(szMsg, nNpcIdStart+1, nNpcIdEnd-1));
		
		if (nNpcTempId) then
			local szNpcName = KNpc.GetNameByTemplateId(nNpcTempId);
			szMsg = Lib:ReplaceStrFormIndex(szMsg, nNpcTagStart, nNpcTagEnd, szNpcName);
		end
		nCurIdx = nNpcTagStart + 1; --不能是nNpcIdEnd + 1,因为字符串被替换了 
	end
	
	szMsg = Lib:ReplaceStr(szMsg, "<playername>", "<color=Gold>"..me.szName.."<color>");
	
	return szMsg;
end



-------------------------------------------------------------------------
--新人直接得到新手任务任务
function Task:OnAskBeginnerTask()
	local bFresh = me.GetTask(Task.nFirstTaskValueGroup, Task.nFirstTaskValueId);
	if (bFresh ~= 1) then
		me.SetTask(Task.nFirstTaskValueGroup, Task.nFirstTaskValueId, 1, 1);
		local tbTaskData	= Task.tbTaskDatas[Task.nFirstTaskId];
		
		if (tbTaskData) then
			local nReferId 		= tbTaskData.tbReferIds[1];
			local nSubTaskId	= Task.tbReferDatas[nReferId].nSubTaskId;
			local tbSubData		= Task.tbSubDatas[nSubTaskId];
			
			local szMsg = "";
			if (tbSubData.tbAttribute.tbDialog.Start.szMsg) then -- 未分步骤
					szMsg = tbSubData.tbAttribute.tbDialog.Start.szMsg;
			else
					szMsg = tbSubData.tbAttribute.tbDialog.Start.tbSetpMsg[1];
			end

			TaskAct:TalkInDark(szMsg,Task.AskAccept, Task, Task.nFirstTaskId, nReferId);
		else
			print("新手任务不存在!")
		end
	end
end


-------------------------------------------------------------------------
-- 判断两个玩家是否是近距离
function Task:AtNearDistance(pPlayer1, pPlayer2)
	local nMapId1, nPosX1, nPosY1 = pPlayer1.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pPlayer2.GetWorldPos();
	
	if (nMapId1 == nMapId2) then
		local nMyR	= ((nPosX1-nPosX2)^2 + (nPosY1-nPosY2)^2)^0.5;
		if (nMyR < self.nNearDistance) then
			return 1;
		end;
	end;
end

function Task:AtNearDistance2(p1, p2, nDistance)
	local nMapId1, nPosX1, nPosY1 = p1.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = p2.GetWorldPos();
	
	if (nMapId1 == nMapId2) then
		local nMyR	= ((nPosX1-nPosX2)^2 + (nPosY1-nPosY2)^2)^0.5;
		if (nMyR <= nDistance) then
			return 1;
		end;
	end;
	
	return 0;
end

-------------------------------------------------------------------------
-- 增加玩家心得
function Task:AddInsight(nInsightNumber)
	PlayerEvent:OnEvent("OnAddInsight", nInsightNumber);
	PlayerEvent:OnEvent("OnAddInsightNew", nInsightNumber);
end


function Task:AddItems(pPlayer, tbItemId, nCount)
	if (nCount <= 0) then
		return;
	end
	
	for i = 1, nCount do
		Task:AddItem(pPlayer, tbItemId);
	end
end

-- 加物品
function Task:AddItem(pPlayer, tbItemId, nTaskId)
	local tbItemInfo = {};
	tbItemInfo.nSeries		= Env.SERIES_NONE;
	if pPlayer.nSeries <= 0 and tbItemId[1] == 1  then
		tbItemInfo.nSeries = 1;
	end
	tbItemInfo.nEnhTimes	= 0;
	tbItemInfo.nLucky		= tbItemId[6];
	tbItemInfo.tbGenInfo	= nil;
	tbItemInfo.tbRandomInfo	= nil;
	tbItemInfo.nVersion		= 0;
	tbItemInfo.uRandSeed	= 0;
	tbItemInfo.bForceBind	= self:IsNeedBind(tbItemId);
	
	local nWay = Player.emKITEMLOG_TYPE_FINISHTASK;
	local pItem = pPlayer.AddItemEx(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], tbItemInfo, nWay);
	
	if (not pItem) then
		print("添加物品失败", "Name："..pPlayer.szName.."..\n", unpack(tbItemId))		
		return;
	end
	
	if (pItem.szClass == "insightbook") then
		pItem.SetGenInfo(1, pPlayer.nLevel);
		pItem.SetCustom(Item.CUSTOM_TYPE_MAKER, pPlayer.szName);		-- 记录制造者名字
		pItem.Sync();
	end

	nTaskId = nTaskId or Item.TASKID_INVALID;
	Item:CheckXJRecord(Item.emITEM_XJRECORD_TASK, nTaskId, pItem);
	
--	if Item.tbStone.tbStoneLogItem[pItem.SzGDPL()] then
--		-- 数据埋点，todo 这里应该是为了商会埋点，因为奖励固定，或许可以放到其他地方
--		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "task", pPlayer.nId, 
--			string.format("%d_%d_%d_%d,%d", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, nTaskId));
--	end
	
	return pItem;
end;


function Task:AddObjAtPos(pPlayer, tbItemId, nMapIdx, nPosX, nPosY)
	local tbParam = {};
	tbParam[1] = tbItemId[1];
	tbParam[2] = tbItemId[2];
	tbParam[3] = tbItemId[3];
	tbParam[4]	= tbItemId[4];
	if (tbParam[4] == 0) then
		tbParam[4] = 1;
	end
	tbParam[5] = tbItemId[5];
	if (tbParam[5] < 0) then
		tbParam[5] = 0;
	end
	tbParam[7] = tbItemId[6];
	tbParam[6] = 0;
	tbParam[8] = pPlayer.nPlayerIndex;
	tbParam[9] = nMapIdx;
	tbParam[10] = nPosX;
	tbParam[11] = nPosY;
	AddObjAtPos(unpack(tbParam));
end

function Task:IsNpcExist(dwNpcId, tb)
	if (not dwNpcId) then
		return 0;
	end
	
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pNpc) then
		return 0;
	end
	
	return 1;
end

-------------------------------------------------------------------------
-- 以下函数为临时添加用于测试
-------------------------------------------------------------------------
function Task:SetStep(nTaskId, nStep)
	if (type(nTaskId) == "string") then
		nTaskId = tonumber(nTaskId, 16);
	end
	
	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbTask	= tbPlayerTask.tbTasks[nTaskId];
	if (not tbTask) then
		return nil;
	end;
	tbTask:CloseCurStep("finish");
	tbTask:SetCurStep(nStep);
end


-------------------------------------------------------------------------
-- 获取目前正在进行的任务数目
function Task:GetMyRunTaskCount()
	local tbPlayerTask = self:GetPlayerTask(me);
	return tbPlayerTask.nCount;
end


-------------------------------------------------------------------------
-- 获取当前可接任务，不包括物品触发任务
function Task:GetCanAcceptTaskCount()
	local nCanAcceptCount = 0;
	local tbPlayerTasks	= self:GetPlayerTask(me).tbTasks;
	for _, tbTaskData in pairs(self.tbTaskDatas) do
		if (not tbPlayerTasks[tbTaskData.nId]) then
			local nReferIdx		= self:GetFinishedIdx(tbTaskData.nId) + 1;			-- +1表示将要继续的任务
			local nReferId		= tbTaskData.tbReferIds[nReferIdx];
			if (nReferId) then				
				local tbReferData	= self.tbReferDatas[nReferId];
				local tbAccept	= tbReferData.tbAccept;
				local tbVisable = tbReferData.tbVisable
				local nTaskType = tbTaskData.tbAttribute.TaskType;
				if (Lib:DoTestFuncs(tbVisable) and Lib:DoTestFuncs(tbAccept) and  (nTaskType == 1 or nTaskType == 2)) then	-- 满足可见和可接条件
					nCanAcceptCount = nCanAcceptCount + 1;	
				end
			end
		end
	end
	
	return nCanAcceptCount;
end


-- 获得当前可接的最小等级的引用子任务数据
function Task:GetMinCanAcceptRefDataList(pPlayer, nTaskType)
	if (not nTaskType) then
		nTaskType = Task.emType_Main;
	end
	
	return self:GetCanAcceptRefDataList(pPlayer, 1, 2);
end

-- 0 All
-- 1 Max
-- 2 Min
--根据nTaskType获取相关类型任务的可接列表，nLevelType为0时获取全部，为1时获取所有同时最大的任务，为2获取所有同时最小的任务
function Task:GetCanAcceptRefDataList(pPlayer, nTaskType, nLevelType)
	if (not nTaskType) then
		nTaskType = Task.emType_Main;
	end
	
	local tbRefSubDataList = {};
	local nLevel = nil;
	local tbPlayerTasks	= self:GetPlayerTask(pPlayer).tbTasks;
	for _, tbTaskData in pairs(self.tbTaskDatas) do
		if (not tbPlayerTasks[tbTaskData.nId]) then
			local nReferIdx		= self:GetFinishedIdx(tbTaskData.nId) + 1;			-- +1表示将要继续的任务
			local nReferId		= tbTaskData.tbReferIds[nReferIdx];
			if (nReferId) then				
				local tbReferData	= self.tbReferDatas[nReferId];
				if (tbReferData.nAcceptNpcId > 0) then
					local tbAccept	= tbReferData.tbAccept;
					local tbVisable = tbReferData.tbVisable;
					
					if (Lib:DoTestFuncs(tbVisable) and Lib:DoTestFuncs(tbAccept) and tbTaskData.tbAttribute.TaskType == nTaskType) then	-- 满足可见和可接条件						
						if (nLevelType == 1 and (not nLevel or tbReferData.nLevel > nLevel)) then
							tbRefSubDataList = {};
							tbRefSubDataList[#tbRefSubDataList + 1] = tbReferData;
							nLevel = tbReferData.nLevel;						
						elseif (nLevelType == 2 and (not nLevel or tbReferData.nLevel < nLevel)) then
							tbRefSubDataList = {};
							tbRefSubDataList[#tbRefSubDataList + 1] = tbReferData;
							nLevel = tbReferData.nLevel;
						elseif (not nLevel or tbReferData.nLevel == nLevel) then
							tbRefSubDataList[#tbRefSubDataList + 1] = tbReferData;							
						end
					end
				end
			end
		end
	end
	
	return tbRefSubDataList;
end


function Task:GetMinAcceptRefData(pPlayer)
	local nMinLevel = 1000;
	local tbRefSubData = nil;
	local tbPlayerTasks = self:GetPlayerTask(pPlayer).tbTasks;
	for _, tbTask in pairs(tbPlayerTasks) do
		local tbReferData = self.tbReferDatas[tbTask.nReferId]
		local tbTaskData = tbTask.tbTaskData;
		if (tbTaskData.tbAttribute.TaskType == 1) then
			if (tbReferData.nLevel < nMinLevel) then
				nMinLevel = tbReferData.nLevel;
				tbRefSubData = tbReferData;
			end
		end
	end
	
	return tbRefSubData;
end

-- 获得等级段描述
-- 先找已接任务最低等级段的任务描述，再找可接任务最低等级段描述
function Task:GetLevelRangeDesc(pPlayer)
	local nLevel = pPlayer.nLevel;
	local tbAcceptRefSubData = self:GetMinAcceptRefData(pPlayer);
	local tbRefSubData = self:GetMinCanAcceptRefDataList(pPlayer);
	
	if (tbAcceptRefSubData) then
		nLevel = tbAcceptRefSubData.nLevel;
	elseif (tbRefSubData and tbRefSubData[1]) then
		nLevel = tbRefSubData[1].nLevel;
	end
	
	for _, item in ipairs(self.tbLevelRangeInfo) do
		if (item.level_range_max >= nLevel) then
			return item.level_range_desc;
		end
	end
	
	return "";
end

-- 获得当前可接的所有主线任务指引描述
function Task:GetAllMainTaskInfo(pPlayer)
	local tbRet = {};
	local tbRefSubDataList = self:GetCanAcceptRefDataList(pPlayer,1,0);--1指获取主线任务，0指全部
	if (tbRefSubDataList) then
		for _, tbRefSubData in ipairs(tbRefSubDataList) do
			tbRet[#tbRet + 1] = {tbRefSubData.nLevel, tbRefSubData.szName, tbRefSubData.szIntrDesc, tbRefSubData.nTaskId};
		end
	end
	table.sort(tbRet, self.CompLevel);
	return tbRet;
end

-- 获得当前可接的最小等级主线任务指引描述
function Task:GetMinLevelMainTaskInfo(pPlayer)
	local tbRet = {};
	local tbRefSubDataList = self:GetMinCanAcceptRefDataList(pPlayer);
	if (tbRefSubDataList) then
		for _, tbRefSubData in ipairs(tbRefSubDataList) do
			tbRet[#tbRet + 1] = {tbRefSubData.nLevel, tbRefSubData.szName, tbRefSubData.szIntrDesc, tbRefSubData.nTaskId};
		end
	end
	
	return tbRet;
end

function Task:GetMaxLevelCampTaskInfo(pPlayer)
	local tbRet = {};
	local tbRefSubDataList = self:GetCanAcceptRefDataList(me, Task.emType_Camp, 1);
	if (tbRefSubDataList) then
		for _, tbRefSubData in ipairs(tbRefSubDataList) do
			tbRet[#tbRet + 1] = {tbRefSubData.nLevel, tbRefSubData.szName, tbRefSubData.szIntrDesc, tbRefSubData.nTaskId};
		end
	end
	
	return tbRet;	
end

-- 获得当前所有可接的支线任务列表
--
--{
--		{szName, szDesc = ""},
--		{szName, szDesc = ""},
--}
function Task:GetBranchTaskTable(pPlayer)
	local tbRet = {};
	local tbPlayerTasks	= self:GetPlayerTask(pPlayer).tbTasks;
	for _, tbTaskData in pairs(self.tbTaskDatas) do
		if (not tbPlayerTasks[tbTaskData.nId]) then
			local nReferIdx		= self:GetFinishedIdx(tbTaskData.nId) + 1;			-- +1表示将要继续的任务
			local nReferId		= tbTaskData.tbReferIds[nReferIdx];
			if (nReferId) then				
				local tbReferData	= self.tbReferDatas[nReferId];
				if (tbReferData.nAcceptNpcId > 0) then
				local tbAccept	= tbReferData.tbAccept;
				local tbVisable = tbReferData.tbVisable
				if (Lib:DoTestFuncs(tbVisable) and Lib:DoTestFuncs(tbAccept) and tbTaskData.tbAttribute.TaskType == 2 and (not tbTaskData.tbAttribute["Repeat"])) then	-- 满足可见和可接条件
					tbRet[#tbRet + 1] = {tbReferData.nLevel, tbReferData.szName, tbReferData.szIntrDesc, tbTaskData.nId}
					end
				end
			end
		end
	end
	
	table.sort(tbRet, self.CompLevel);
	
	return tbRet;
end


function Task.CompLevel(tbTaskA, tbTaskB)
	if (tbTaskA and tbTaskB) then
		return tbTaskA[1] < tbTaskB[1];
	end
end


-- 获得难度描述
function Task:GetRefSubTaskDegreeDesc(nRefSubId)
	if (not self.tbReferDatas[nRefSubId]) then
		return "";
	end
	
	local nDegree = self.tbReferDatas[nRefSubId].nDegree or 1;
	if (nDegree <= 1) then
		return "";
	elseif (nDegree == 2) then
		return "<color=Yellow>建议组队<color=White>";
	elseif (nDegree == 3) then
		return "<color=Yellow>极限难度，欢迎挑战<color=White>";
	elseif (nDegree == 4) then
		return"<color=Yellow>可重复任务<color=White>";
	end
	
	return "";
end


-- 玩家是否做过指定引用子任务，对于重复任务无效
function Task:HaveDoneSubTask(pPlayer, nTaskId, nRefId)
	local tbTaskData = self.tbTaskDatas[nTaskId];
	if (not tbTaskData) then
		return 0;
	end
	local nLastRefId = pPlayer.GetTask(1000, nTaskId);
	
	if (nLastRefId == 0) then
		return 0;
	end
	if not self.tbReferDatas[nLastRefId] or not self.tbReferDatas[nRefId] then
		return 0;
	end
	if (self.tbReferDatas[nLastRefId].nReferIdx >= self.tbReferDatas[nRefId].nReferIdx) then
		return 1;
	end
	
	return 0;
end

-- 玩家现在身上是否有某个任务
function Task:HaveTask(pPlayer, nTaskId)
	local tbPlayerTasks	= self:GetPlayerTask(pPlayer).tbTasks;
	if (tbPlayerTasks[nTaskId]) then
		return 1;
	end
	
	return 0;
end

-- 获取任务的当前步骤和总步骤
function Task:GetCurSetp(pPlayer, nTaskId)
	local tbPlayerTasks	= self:GetPlayerTask(pPlayer).tbTasks;
	if (not tbPlayerTasks[nTaskId]) then
		return 0;
	end
	return tbPlayerTasks[nTaskId].nCurStep, #tbPlayerTasks[nTaskId].tbSubData.tbSteps;
end

-- 检查能否接任务
function Task:CheckAcceptTask(pPlayer, nTaskId, nReferId)
	if (type(nTaskId) == "string") then
		nTaskId = tonumber(nTaskId, 16);
	end
	if (type(nReferId) == "string") then
		nReferId = tonumber(nReferId, 16);
	end
	
	if (not nTaskId or not nReferId) then
		assert(false);
		return;
	end
	
	local tbTaskData	= self.tbTaskDatas[nTaskId];
	local tbReferData	= self.tbReferDatas[nReferId];
	if (not tbReferData) then
		return;
	end
	
	if pPlayer.GetTiredDegree1() == 2 then
		return 0, "太累了，还是休息下吧！";
	end
	
	local tbUsedGroup	= {};
	-- 标记已经使用过的Group
	for _, tbTask in pairs(self:GetPlayerTask(pPlayer).tbTasks) do
		tbUsedGroup[tbTask.nSaveGroup]	= 1;
	end;
	-- 找出空闲的可以使用的Group
	local nSaveGroup	= nil;
	for n = self.TASK_GROUP_MIN, self.TASK_GROUP_MAX do
		if (not tbUsedGroup[n]) then
			nSaveGroup	= n;
			break;
		end;
	end;
	if (not nSaveGroup) then
		return 0, "任务已经满了！";
	end
	Setting:SetGlobalObj(pPlayer);
	-- 判断可接条件
	if (tbReferData.tbAccept) then
		local bOK, szMsg	= Lib:DoTestFuncs(tbReferData.tbAccept);
		if (not bOK) then
			Setting:RestoreGlobalObj();
			if not szMsg or szMsg == "" then
				szMsg = "不满足接任务条件！";
			end
			return 0, szMsg;
		end;
	end
	Setting:RestoreGlobalObj();
	
	-- 若是物品触发，检查玩家身上是否有此物品，有则删除，没有就返回nil
	if (tbReferData.nParticular) then
		local tbItemId = {20,1,tbReferData.nParticular,1};
		local tbItemList = self:GetPlayerItemList(pPlayer, tbItemId);
		local nItemCount = 0;
		for _, tbTaskItem in pairs(tbItemList) do
			nItemCount = nItemCount + tbTaskItem.nCount;
		end
		if (nItemCount < 1) then
			return 0, "指定触发物品不存在，无法接受此任务！";
		end
	end
	return 1;
end

-- 显示所有任务，调试用
function Task:ShowAllTasks()
	local function fnCompEarlier(tbTask1, tbTask2)
		return tbTask1.nAcceptDate < tbTask2.nAcceptDate;
	end;

	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbTasks	= {};
	for _, tbTask in pairs(tbPlayerTask.tbTasks) do
		tbTasks[#tbTasks+1]	= tbTask;
	end;
	me.Msg("My Tasks: ("..tbPlayerTask.nCount..")");
	table.sort(tbTasks, fnCompEarlier);
	for _, tbTask in ipairs(tbTasks) do
		me.Msg("  "..tbTask:GetName().." ["..os.date("%y/%m/%d %H:%M:%S", tbTask.nAcceptDate).."] ");
	end;
end


-- 以后补将可能用到，不删先
function Task:ModifTaskItem(pPlayer)	
	if (pPlayer.GetTask(1022, 107) == 1) then
		pPlayer.Msg("你的奖励不存在错误，或者已经补领过此奖励！");
		return;
	end
	
	if (pPlayer.CountFreeBagCell() < 1) then
		pPlayer.Msg("背包空间不够");
		return;
	end
	
	pPlayer.SetTask(1022, 107, 1);
	
	if (pPlayer.nFaction == Player.FACTION_DUANSHI and pPlayer.nRouteId == Player.ROUTE_QIDUANSHI) then -- 气段
		local nTaskId = tonumber("0C", 16);
		local nRefId  = tonumber("5E", 16);
		
		if (self:HaveDoneSubTask(pPlayer, nTaskId, nRefId) == 0) then
			if (self.tbReferDatas[nRefId]) then
				pPlayer.Msg("你没完成过任务"..self.tbReferDatas[nRefId].szName.."不能补奖！");
			end
			return;
		end
		
		if (self:GetItemCount(pPlayer, {2, 1, 96, 5, 3}) <= 0) then
			pPlayer.AddItem(2, 1, 97, 6, 3);
			return;
		end
		pPlayer.Msg("你已经拥有应有的奖励！");
	elseif (pPlayer.nFaction == Player.FACTION_EMEI and pPlayer.nRouteId == Player.ROUTE_FUZHUEMEI) then -- 辅助峨嵋
		local nTaskId = tonumber("0C", 16);
		local nRefId  = tonumber("5E", 16);
		
		if (self:HaveDoneSubTask(pPlayer, nTaskId, nRefId) == 0) then
			if (self.tbReferDatas[nRefId]) then
				pPlayer.Msg("你没完成过任务"..self.tbReferDatas[nRefId].szName.."不能补奖！");
			end
			return;
		end
		if (self:GetItemCount(pPlayer, {2, 1, 96, 5, 3}) <= 0) then
			pPlayer.AddItem(2, 1, 97, 6, 3);
			return;
		end
		pPlayer.Msg("你已经拥有应有的奖励！");
	elseif (pPlayer.nFaction == Player.FACTION_KUNLUN and pPlayer.nRouteId == Player.ROUTE_JIANWUDANG) then -- 剑武当
			local nTaskId = tonumber("09", 16);
			local nRefId  = tonumber("4A", 16);
		
			if (self:HaveDoneSubTask(pPlayer, nTaskId, nRefId) == 0) then
				if (self.tbReferDatas[nRefId]) then
					pPlayer.Msg("你没完成过任务"..self.tbReferDatas[nRefId].szName.."不能补奖！");
				end
				return;
			end
		
		
			if (self:GetItemCount(pPlayer, {2, 1, 176, 5, 5}) <= 0) then
				pPlayer.AddItem(2, 1, 177, 6, 5);
				return;
			end
			
			pPlayer.Msg("你已经拥有应有的奖励！");
	else
		pPlayer.Msg("你所选择的路线不存在奖励问题！");
		return;
	end
end

function Task:IsNeedBind(tbItem)
	-- 装备绑定
	if (tbItem[1] >= 1 and tbItem[1] <= 4) then
		return 1;
	end
	
	-- 玄晶会绑定
	if (tbItem[1] == 18 and tbItem[2] == 1 and tbItem[3] == 1) then
		return 1;
	end
	
	-- 白驹会绑定
	if (tbItem[1] == 18 and tbItem[2] == 1 and tbItem[3] == 71) then
		return 1;
	end
	
	-- 情花会绑定
	if (tbItem[1] == 18 and tbItem[2] == 1 and tbItem[3] == 597) then
		return 1;
	end
	
	-- 魂石会绑定
	if (tbItem[1] == 18 and tbItem[2] == 1 and tbItem[3] == 205) then
		return 1;
	end
	
	-- 包裹绑定
	if (tbItem[1] == 21) then
		return 1;
	end
	
	return 0;
end

function Task:OnLoadMapFinish(nMapId, nMapCopy, nParam)
	self.tbArmyCampInstancingManager:OnLoadMapFinish(nMapId, nMapCopy, nParam);
end


function Task:RepairTaskValue(bExchangeServerComing)
	Task:DoRepairTaskValue(bExchangeServerComing);
end

function Task:DoRepairTaskValue(bExchangeServerComing)
	--跨服不做处理
	if bExchangeServerComing == 1 then
		return;
	end
	--全局服不做处理
	if GLOBAL_AGENT then
		return;
	end
		
	--修复军营，无尽的征程（任务没完成，身上没有对应的任务，但任务变量不对）
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	if not tbPlayerTasks[488] and me.GetTask(1025, 69) == 1 and me.GetTask(1022, 187) == 1 then	--80级无尽的征程任务
		me.SetTask(1025, 69, 0, 1);
	end
	if not tbPlayerTasks[429] and me.GetTask(1025, 70) == 1 and me.GetTask(1022, 187) == 1 then	--90级无尽的征程任务
		me.SetTask(1025, 70, 0, 1);
	end
	if not tbPlayerTasks[490] and me.GetTask(1025, 71) == 1 and me.GetTask(1022, 187) == 1 then	--100级无尽的征程任务
		me.SetTask(1025, 71, 0, 1);
	end
	
	--修复军营日常剧情任务异常
	if not tbPlayerTasks[483] and not tbPlayerTasks[491] and me.GetTask(1025,64) == 1 then	--备战
		me.SetTask(1025,64,0)
	end
	if not tbPlayerTasks[492] and not tbPlayerTasks[493] and me.GetTask(1025,65) == 1 then	--蛊惑
		me.SetTask(1025,65,0)
	end
	if not tbPlayerTasks[484] and not tbPlayerTasks[485] and me.GetTask(1025,66) == 1 then	--海陵王
		me.SetTask(1025,66,0)
	end
	if not tbPlayerTasks[494] and not tbPlayerTasks[495] and me.GetTask(1025,61) == 1 then	--鄂伦河原
		me.SetTask(1025,61,0)
	end
	
	--修复跨服宋金任务：232为可接条件
	if not Task:GetPlayerTask(me).tbTasks[477] and me.GetTask(1022, 232) > 0 then
		me.SetTask(1022, 232, 0);
		me.SetTask(1022, 233, 0);
	end
	
	--修复主线师徒成就
	if me.GetTask(1022, 107) == 1 then
		Achievement_ST:FinishAchievement(me.nId, Achievement_ST.MAINTASK_50);
	end
	
	--如果争夺任务，但进入房间的变量不正确，修复变量
	if me.GetTask(1024, 9) ~= 1 and me.GetTask(1000,18) == 123 then
		me.SetTask(1024, 9, 1); 
	end
	
	--真假难辨，死局，第一步需要变量1022,62,2才能进入房间继续任务
	if me.GetTask(1000,7) == 57 and tbPlayerTasks[7] and tbPlayerTasks[7].nCurStep == 1 and me.GetTask(1022,62) ~= 2 then
		me.SetTask(1022, 62, 2);
	end
	
	--如果任务真假难辨第6个任务匪夷所思时，1022,65的变量应该是2，说明已经完成，进行修正任务。
	if me.GetTask(1000, 7) == 62 and me.GetTask(1022,65) == 1 then
		me.SetTask(1000, 7, 63, 1);
	end
	
	--如果任务真假难辨第7个任务匪夷所思完成后，1022,67的变量应该是1，现在没有真假难辨任务，但是变量不对，且只做到匪夷所思这个任务。
	if me.GetTask(1000, 7) == 63 and not tbPlayerTasks[7] and me.GetTask(1022,67) == 0 then
		me.SetTask(1022,67, 1, 1);
	end
	
	--血光之灾-劫难过后上一步擒贼擒王，完成后设变量1022,51,3,接任务 江湖 时进房间需求变量（做到劫难过后，无变量1022,51,3接不到任务江湖）。
	if me.GetTask(1000, 12) == 91 and not tbPlayerTasks[12] and me.GetTask(1022,51) ~= 3 then
		me.SetTask(1022,51, 3, 1);
	end
	--以下修复危险，不知为何不断修复任务。
	
	local pPlayer = me;
	if (self:HaveDoneSubTask(pPlayer, tonumber("DB", 16), tonumber("18A", 16)) == 1) then
		if (0 ~= pPlayer.GetTask(1000, tonumber("DB", 16))) then
			Dbg:WriteLog("Task", "Player TaskValue Error!", 1000, tonumber("DB", 16), 0);
			pPlayer.SetTask(1000, tonumber("DB", 16), 0, 1);
		end
	end
	
	if (self:HaveDoneSubTask(pPlayer, tonumber("DC", 16), tonumber("18B", 16)) == 1) then
		if (0 ~= pPlayer.GetTask(1000, tonumber("DC", 16))) then
			Dbg:WriteLog("Task", "Player TaskValue Error!", 1000, tonumber("DC", 16),0);
			pPlayer.SetTask(1000, tonumber("DC", 16), 0, 1);
		end
	end
		
	if (self:HaveDoneSubTask(pPlayer, tonumber("04", 16), tonumber("26", 16)) == 1 or 
		self:HaveDoneSubTask(pPlayer, tonumber("05", 16), tonumber("33", 16)) == 1 or 
		self:HaveDoneSubTask(pPlayer, tonumber("09", 16), tonumber("4A", 16)) == 1 or 
		self:HaveDoneSubTask(pPlayer, tonumber("0C", 16), tonumber("5F", 16)) == 1 or 
		self:HaveDoneSubTask(pPlayer, tonumber("0D", 16), tonumber("60", 16)) == 1)then
			if (1 ~= pPlayer.GetTask(1022,107)) then
				Dbg:WriteLog("Task", "Player TaskValue Error!", 1022,107,1);
				pPlayer.SetTask(1022,107,1,1);
			end
	end
	
	if (self:HaveDoneSubTask(pPlayer, tonumber("F0", 16), tonumber("19F", 16)) == 1) then
		if (1 ~= pPlayer.GetTask(1022, 168)) then
			Dbg:WriteLog("Task", "Player TaskValue Error!", 1022, 168, 1);
			pPlayer.SetTask(1022, 168, 1, 1);
		end
	end

	if (self:HaveDoneSubTask(pPlayer, tonumber("12C", 16), tonumber("1DB", 16)) == 1) then
		if (1 ~= pPlayer.GetTask(1022, 169)) then
			Dbg:WriteLog("Task", "Player TaskValue Error!", 1022, 169, 1);
			pPlayer.SetTask(1022, 169, 1, 1);
		end
	end
	
	local tbPlayerTasks	= Task:GetPlayerTask(pPlayer).tbTasks;
	local tbTask = tbPlayerTasks[228];
	if (tbTask and tbTask.nReferId == 403 and tbTask.nCurStep == 4) then
		local tbFind1 = pPlayer.FindItemInBags(20,1,298,1);
		local tbFind2 = pPlayer.FindItemInRepository(20,1,298,1);
		if #tbFind1 <= 0 and #tbFind2 <= 0 then
			Dbg:WriteLog("Task", "Player TaskValue Error!", 1022, 119, 1);
			pPlayer.SetTask(1022, 119, 1);
		end;
	end;
	
	self:SetTaskValueWithStepCondition(pPlayer, 240, 415, 1, 8, 1022, 141, 1); 
	
	self:SetTaskValueWithStepCondition(pPlayer, 157, 310, 1, 12, 1022, 225, 1);	-- 十二门派
	
	self:SetTaskValueWithStepCondition(pPlayer, 292, 467, 2, 2, 1022, 151, 1); -- 千钧一发
	self:SetTaskValueWithStepCondition(pPlayer, 295, 470, 7, 7, 1022, 152, 2); -- 在水一方
	self:SetTaskValueWithStepCondition(pPlayer, 295, 470, 8, 8, 1022, 141, 2); -- 在水一方
	self:SetTaskValueWithStepCondition(pPlayer, 237, 412, 3, 4, 1022, 137, 1); -- 背水一战
	self:SetTaskValueWithStepCondition(pPlayer, 237, 412, 4, 4, 1022, 138, 1); -- 背水一战
	self:SetTaskValueWithStepCondition(pPlayer, 239, 414, 7, 11, 1022, 141, 1); -- 功败垂成
	self:SetTaskValueWithStepCondition(pPlayer, 240, 415, 3, 8, 1022, 141, 1); -- 庆元党禁
	self:SetTaskValueWithStepCondition(pPlayer, 240, 415, 5, 8, 1022, 139, 3); -- 庆元党禁
	
	self:SetTaskValueWithStepCondition(pPlayer, 240, 415, 9, 9, 1022, 141, 0); -- 庆元党禁
	self:SetTaskValueWithStepCondition(pPlayer,  24, 170, 1, 3, 1024,   2, 4); -- 仇人相见

	self:SetTaskValueWithStepCondition(pPlayer,  24, 165, 1, 1, 1024,   2, 0); -- 洞中异象
	self:SetTaskValueWithStepCondition(pPlayer,  24, 165, 2, 3, 1024,   2, 1); -- 洞中异象
	self:SetTaskValueWithStepCondition(pPlayer,  24, 166, 1, 2, 1024,   2, 1); -- 别有洞天
	self:SetTaskValueWithStepCondition(pPlayer,  24, 167, 1, 3, 1024,   2, 2); -- 秘密泄露
	self:SetTaskValueWithStepCondition(pPlayer,  24, 167, 4, 6, 1024,   2, 3); -- 秘密泄露
	self:SetTaskValueWithStepCondition(pPlayer,  24, 167, 4, 6, 1024,   3, 1); -- 秘密泄露
	self:SetTaskValueWithStepCondition(pPlayer,  24, 168, 1, 2, 1024,   2, 3); -- 寻门而入
	self:SetTaskValueWithStepCondition(pPlayer,  24, 168, 1, 1, 1024,   3, 1); -- 寻门而入
	self:SetTaskValueWithStepCondition(pPlayer,  24, 168, 2, 2, 1024,   3, 2); -- 寻门而入
	self:SetTaskValueWithStepCondition(pPlayer,  24, 169, 1, 1, 1024,   2, 3); -- 有备无患
	self:SetTaskValueWithStepCondition(pPlayer,  24, 169, 1, 2, 1024,   3, 2); -- 有备无患
	self:SetTaskValueWithStepCondition(pPlayer,  24, 169, 2, 2, 1024,   2, 4); -- 有备无患
	
	self:SetTaskValueWithStepCondition(pPlayer,  18, 123, 1, 1, 1024,   9, 0); -- 谋划
	self:SetTaskValueWithStepCondition(pPlayer,  18, 123, 2, 7, 1024,   9, 1); -- 谋划
	self:SetTaskValueWithStepCondition(pPlayer,  18, 124, 1, 2, 1024,   9, 1); -- 争夺
	self:SetTaskValueWithStepCondition(pPlayer,  18, 124, 3, 6, 1024,   9, 3); -- 争夺
	self:SetTaskValueWithStepCondition(pPlayer,  18, 124, 4, 6, 1024,  10, 1); -- 争夺
	self:SetTaskValueWithStepCondition(pPlayer,  18, 125, 1, 4, 1024,   9, 3); -- 悬疑
	self:SetTaskValueWithStepCondition(pPlayer,  18, 125, 1, 4, 1024,  10, 1); -- 悬疑
	self:SetTaskValueWithStepCondition(pPlayer,  18, 126, 1, 4, 1024,   9, 2); -- 撤离
	self:SetTaskValueWithStepCondition(pPlayer,  18, 126, 1, 4, 1024,  10, 1); -- 撤离
	self:SetTaskValueWithStepCondition(pPlayer,  18, 126,-1,-1, 1024,  10, 1); -- 撤离
	self:SetTaskValueWithStepCondition(pPlayer,  18, 126,-1,-1, 1024,   9, 2); -- 撤离
	self:SetTaskValueWithStepCondition(pPlayer,  18, 127, 1, 9, 1024,   9, 2); -- 风范
	self:SetTaskValueWithStepCondition(pPlayer,  18, 127, 1, 1, 1024,  10, 1); -- 风范
	self:SetTaskValueWithStepCondition(pPlayer,  18, 127, 2, 9, 1024,  10, 2); -- 风范
	
	local tbTasks = {225, 226, 227}
	local nHaveTask = 0;
	for _, nTaskId in ipairs(tbTasks) do
		if (Task:HaveTask(pPlayer, nTaskId) == 1) then
			nHaveTask = 1;
			break;
		end
	end
	if (nHaveTask == 0 and me.GetTask(1024, 50) ~= 0) then
		Dbg:WriteLog("Task", "Player TaskValue Error!", 1024, 50, 0);
		me.SetTask(1024, 50, 0);
	end;
	
	local tbTasks = {333, 334, 337, 338}
	local nHaveTask = 0;
	for _, nTaskId in ipairs(tbTasks) do
		if (Task:HaveTask(pPlayer, nTaskId) == 1) then
			nHaveTask = 1;
			break;
		end
	end
	if (nHaveTask == 0 and (me.GetTask(1024, 60) ~= 0 or me.GetTask(1024, 59) ~= 0)) then
		Dbg:WriteLog("Task", "Player TaskValue Error!", 1024, 60, 0);
		Dbg:WriteLog("Task", "Player TaskValue Error!", 1024, 59, 0);
		me.SetTask(1024, 60, 0);
		me.SetTask(1024, 59, 0); 
	end;

	local tbTasks = {363, 364, 365, 366, 367, 368}
	local nHaveTask = 0;
	for _, nTaskId in ipairs(tbTasks) do
		if (Task:HaveTask(pPlayer, nTaskId) == 1) then
			nHaveTask = 1;
			break;
		end
	end
	if (nHaveTask == 0 and me.GetTask(1022, 176) ~= 0) then
		Dbg:WriteLog("Task", "Player TaskValue Error!", 1022, 176, 0);
		me.SetTask(1022, 176, 0);
	end;
	
	local tbPlayerTasks	= self:GetPlayerTask(pPlayer).tbTasks;
	local tbTask = tbPlayerTasks[381];
	if (tbTask and tbTask.nReferId == 565 and pPlayer.GetTask(1022, 187) ~= 0) then
		Dbg:WriteLog("Task", "Player TaskValue Error!", 1022, 187, 0);
		pPlayer.SetTask(1022, 187, 0, 1);
	end;
	
	tbTask = tbPlayerTasks[470];
	if (tbTask and tbTask.nReferId == 664 and tbTask.nCurStep == 2 and pPlayer.dwKinId > 0) then
		if (0 == pPlayer.GetTask(1022, 224)) then
			 pPlayer.SetTask(1022, 224, 1);
		end
	end;
	

end

function Task:SetTaskValueWithStepCondition(pPlayer, nTaskId, nReferId, nMinStep, nMaxStep, nGroupId, nRowId, nValue)
	if (not pPlayer or not nTaskId or not nReferId or not nMinStep or not nMaxStep) then
		return;
	end;
	if (not nGroupId or not nRowId or not nValue) then
		return;
	end;
	
	local tbPlayerTasks	= self:GetPlayerTask(pPlayer).tbTasks;
	local tbTask = tbPlayerTasks[nTaskId];
	if (tbTask and tbTask.nReferId == nReferId and tbTask.nCurStep >= nMinStep and tbTask.nCurStep <= nMaxStep) then
		if (nValue ~= pPlayer.GetTask(nGroupId, nRowId)) then
			Dbg:WriteLog("Task", "Player TaskValue Error!", nGroupId, nRowId, nValue);
			pPlayer.SetTask(nGroupId, nRowId, nValue, 1);
		end
	end;
end;

function Task:RepairBook()
	-- 如果背包里没有书，切处于指定任务的指定步骤，则加书给他
	local tbPlayerTasks	= self:GetPlayerTask(me).tbTasks;
	local tbTask0 = tbPlayerTasks[228];
	local tbTask1 = tbPlayerTasks[229];
	local tbTask2 = tbPlayerTasks[230];
	
	if (tbTask0 and tbTask0.nCurStep == 6 and not TaskCond:HaveItem({20, 1, 299, 1}) and me.GetTask(1022, 120) == 0) then
		-- 如果有背包空间
		if (TaskCond:HaveBagSpace(1) and not TaskCond:HaveItem({20, 1, 490, 1})) then
			Task:AddItem(me, {20, 1, 490, 1});
		end
	end
	-- 补偿孙子兵法书
	if (tbTask1 and tbTask1.nCurStep == 2 and not TaskCond:HaveItem({20, 1, 298, 1}) and me.GetTask(1022, 119) == 0) then
		-- 如果有背包空间
		if (TaskCond:HaveBagSpace(1) and not TaskCond:HaveItem({20, 1, 489, 1})) then
			Task:AddItem(me, {20, 1, 489, 1});
		end
	end
	
	-- 墨家机关术
	if (tbTask2 and tbTask2.nCurStep == 2 and not TaskCond:HaveItem({20, 1, 299, 1}) and me.GetTask(1022, 120) == 0) then
		-- 如果有背包空间
		if (TaskCond:HaveBagSpace(1) and not TaskCond:HaveItem({20, 1, 490, 1})) then
			Task:AddItem(me, {20, 1, 490, 1});
		end
	end
	
	local tbTask3 = tbPlayerTasks[340];
	-- 兵书
	if (tbTask3 and tbTask3.nCurStep == 2 and not TaskCond:HaveItem({20,1,544,1}) and me.GetTask(1022, 165) == 0) then
		-- 如果有背包空间
		if (TaskCond:HaveBagSpace(1)) then
			Task:AddItem(me, {20,1,544,1});
		end
	end
	
	local tbTask4 = tbPlayerTasks[341];
	-- 墨家机关术
	if (tbTask4 and tbTask4.nCurStep == 2 and not TaskCond:HaveItem({20,1,545,1}) and me.GetTask(1022, 167) == 0) then
		-- 如果有背包空间
		if (TaskCond:HaveBagSpace(1)) then
			Task:AddItem(me, {20,1,545,1});
		end
	end
end


function Task:RepairCampTask()
	if (Task:HaveTask(me, 226) == 0 and Task:HaveTask(me, 227) == 0) then
		if (me.GetTask(1024, 50) == 1) then
			me.SetTask(1024, 50, 0, 1);
			if (me.GetTask(2060, 1) == 0) then
				me.SetTask(2060, 1, 1); -- 值为1表示可以领，领过之后累加
				me.Msg("你可以去副本接引人处领取任务补偿。")
			end
		end
	end
	
	-- 青螺岛四面楚歌使用箭车任务修复..
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	local tbTask = tbPlayerTasks[1];	-- 主任务ID是1	
	if tbTask and tbTask.nReferId == 7 then		-- 子任务ID是7
		if (tbTask.nCurStep == 4) then		-- 任务步骤是4
			Task:SetStep(1, 4);		-- 重置任务步骤
		end
	end
	me.UnLockClientInput();
end

function Task:AmendeForCampTask(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	if (pPlayer.GetTask(2060, 1) == 0) then
		Dialog:Say("您的军营任务没有错过。");
	elseif (pPlayer.GetTask(2060, 1) ~= 1) then
		Dialog:Say("军营任务的补偿是不能重复获得的。");
	else
		pPlayer.AddExp(8000000);							-- 800w经验
		pPlayer.Earn(40000, Player.emKEARN_TASK_GIVE);	-- 4w非绑银
		pPlayer.ChangeCurGatherPoint(1800);				-- 1800活力
		pPlayer.ChangeCurMakePoint(1800);				-- 1800精力
		local nOldValue = pPlayer.GetTask(2060, 1);
		pPlayer.SetTask(2060, 1, nOldValue+1, 1);
	end
end

function Task:DailyEvent()
	me.SetTask(1025, 1, 0, 1);--大拜年
	me.SetTask(2031, 1, 0, 1);
	me.SetTask(1025, 14, 0, 1);--2010拜年
	me.SetTask(1025, 16, 0, 1);--赈灾任务
	me.SetTask(1025, 24, 0, 1);--七夕任务
	me.SetTask(2063,21,0,1);	--每天累积上线时间
end;

local tbRepairArmyBook = Item:GetClass("repairarmybook");

function tbRepairArmyBook:OnUse()
	me.SetTask(1022,119,1,1);
	
	return 1;
end

local tbRepairHisBook = Item:GetClass("repairhisbook");
function tbRepairHisBook:OnUse()
	me.SetTask(1022,120,1,1);
	
	return 1;
end

PlayerSchemeEvent:RegisterGlobalDailyEvent({Task.DailyEvent, Task});

PlayerEvent:RegisterGlobal("OnLogin", Task.RepairTaskValue, Task);
PlayerEvent:RegisterGlobal("OnLogin", Task.RepairBook, Task);
PlayerEvent:RegisterGlobal("OnLogin", Task.RepairCampTask, Task);
