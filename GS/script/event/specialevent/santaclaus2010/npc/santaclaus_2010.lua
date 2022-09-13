-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-1-25 10:10:10
-- 描  述  ：圣诞老人

local tbNpc = Npc:GetClass("santaclaus_2010");
SpecialEvent.Santa2010 = SpecialEvent.Santa2010 or {};
local tbSanta = SpecialEvent.Santa2010 or {};

function tbNpc:StartSendGift(nMapIndex)
	local pNpc = KNpc.Add2(tbSanta.SANTA_CLAUS_ID, 100, -1, tbSanta.SANTA_CLAUS_BORN_POS[nMapIndex][1], tbSanta.SANTA_CLAUS_BORN_POS[nMapIndex][2], tbSanta.SANTA_CLAUS_BORN_POS[nMapIndex][3]);
	if not pNpc then
		return 0;
	end
	pNpc.SetActiveForever(1);
	pNpc.SetLiveTime(tbSanta.DURATION_TIME);
	pNpc.SetNpcAI(0, 0, 0, 0, 0, 0, 0, 0); 
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, pNpc.dwId};
	pNpc.GetTempTable("Npc").nMapIndex = nMapIndex;
	pNpc.GetTempTable("Npc").nRefreshBoxTimerId = Timer:Register(tbSanta.INTERVAL_BOX, self.AddSantaBox, self, pNpc.dwId);
	pNpc.GetTempTable("Npc").nRefreshBoxCount = 0;
	pNpc.GetTempTable("Npc").nExpTimerId = Timer:Register(tbSanta.INTERVAL_EXP, self.AddAroundExp, self, pNpc.dwId);
	pNpc.GetTempTable("Npc").nExpCount = 0;
	pNpc.GetTempTable("Npc").nChatTimerId = Timer:Register(tbSanta.INTERVAL_CHAT, self.Chat, self, pNpc.dwId);
	pNpc.GetTempTable("Npc").nChatCount = 0;
	self:move(pNpc);
	return pNpc;
end

function tbNpc:move(pNpc)
	if not pNpc then
		return 0;
	end
	local nMapIndex = pNpc.GetTempTable("Npc").nMapIndex;
	pNpc.AI_ClearPath();
	local tbRoute = Lib:LoadTabFile(tbSanta.TB_ROUTE[nMapIndex]);
	if not tbRoute or #tbRoute == 0 then
		Dbg:WriteLog("圣诞老人添加路径失败");
		return 0;
	end
	for _, tbTemp in ipairs(tbRoute) do
		pNpc.AI_AddMovePos(tbTemp["POSX"]*32, tbTemp["POSY"]*32);
	end
	pNpc.SetNpcAI(9, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0); 
end

function tbNpc:OnArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);	
	if not Npc then
		return 0;
	end
	pNpc.SetNpcAI(9, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0); 
end

function tbNpc:AddSantaBox(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRefreshBoxCount = pNpc.GetTempTable("Npc").nRefreshBoxCount;
	if nRefreshBoxCount >= tbSanta.TIMES_REFRESH_BOX then
		return 0;
	end
	pNpc.GetTempTable("Npc").nRefreshBoxCount = nRefreshBoxCount + 1;
	local tbPlayerList = KNpc.GetAroundPlayerList(nNpcId, tbSanta.RANGE_BOX);
	if tbPlayerList then
		if #tbPlayerList < tbSanta.MAX_BOX_PRODUCT_NUM then	
			for _, pPlayer in pairs(tbPlayerList) do
				local nTakeBoxCount = pPlayer.GetTask(tbSanta.TASK_GROUP_ID, tbSanta.TASK_BOX_COUNT);
				if pPlayer.nLevel >= tbSanta.LEVEL_LIMIT and pPlayer.CountFreeBagCell() >= 1 and nTakeBoxCount < tbSanta.MAX_TAKE_BOX_COUNT and pPlayer.nFaction > 0 then
					pPlayer.AddItem(unpack(tbSanta.SANTA_BOX_ID));
					pPlayer.SetTask(tbSanta.TASK_GROUP_ID, tbSanta.TASK_BOX_COUNT, nTakeBoxCount + 1);
					StatLog:WriteStatLog("stat_info", "shengdanjie", "songzhufu", pPlayer.nId, "get_box", 1);
					pPlayer.Msg("您得到圣诞老人的祝福，获得<color=yellow>圣诞宝箱<color>一个！");
					pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]得到圣诞老人的祝福，获得了<color=yellow>圣诞宝箱<color>一个！");		
					if nTakeBoxCount + 1 == 100 then
						pPlayer.Msg("您获得的圣诞宝箱已达100个上限，将无法再获得箱子！");
						Dialog:SendBlackBoardMsg(pPlayer, "您获得的圣诞宝箱已达100个上限，将无法再获得箱子！");
					else
						Dialog:SendBlackBoardMsg(pPlayer, "恭喜您得到圣诞老人精心为您准备的圣诞宝箱一个！");
					end
				end
			end
		else
			Lib:SmashTable(tbPlayerList);
			local nCount = 0;
			for _, pPlayer in ipairs(tbPlayerList) do
				local nTakeBoxCount = pPlayer.GetTask(tbSanta.TASK_GROUP_ID, tbSanta.TASK_BOX_COUNT);
				if pPlayer.nLevel >= tbSanta.LEVEL_LIMIT and pPlayer.CountFreeBagCell() >= 1 and nTakeBoxCount < tbSanta.MAX_TAKE_BOX_COUNT and pPlayer.nFaction > 0 then
					pPlayer.AddItem(unpack(tbSanta.SANTA_BOX_ID));
					nCount = nCount + 1;
					pPlayer.SetTask(tbSanta.TASK_GROUP_ID, tbSanta.TASK_BOX_COUNT, nTakeBoxCount + 1);
					StatLog:WriteStatLog("stat_info", "shengdanjie", "songzhufu", pPlayer.nId, "get_box", 1);
					pPlayer.Msg("您得到圣诞老人的祝福，获得圣诞宝箱一个！");
					pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]得到圣诞老人的祝福，获得了<color=yellow>圣诞宝箱<color>一个！");
					if nTakeBoxCount + 1 == 100 then
						pPlayer.Msg("您获得的圣诞宝箱已达100个上限，将无法再获得箱子！");
						Dialog:SendBlackBoardMsg(pPlayer, "您获得的圣诞宝箱已达100个上限，将无法再获得箱子！");
					else
						Dialog:SendBlackBoardMsg(pPlayer, "恭喜您得到圣诞老人精心为您准备的圣诞宝箱一个！");
					end
				end
				if nCount >= tbSanta.MAX_BOX_PRODUCT_NUM then
					break;
				end
			end
		end
	end
	
end

function tbNpc:AddAroundExp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nExpCount = pNpc.GetTempTable("Npc").nExpCount;
	if nExpCount >= tbSanta.TIMES_EXP then
		return 0;
	end
	
	pNpc.GetTempTable("Npc").nExpCount = nExpCount + 1;
	
	local tbPlayerList = KNpc.GetAroundPlayerList(nNpcId, tbSanta.RANGE_EXP);
	if tbPlayerList then
		for _, pPlayer in pairs(tbPlayerList) do
			if pPlayer.nLevel >= tbSanta.LEVEL_LIMIT then
				local nPlayerId = pPlayer.nId;
				local nExp = math.floor(pPlayer.GetBaseAwardExp() * tbSanta.BASE_EXP_MULTIPLE);
				pPlayer.CastSkill(377, 10, -1, pPlayer.GetNpc().nIndex);
				pPlayer.AddExp(nExp);
			end
		end
	end
	
end

function tbNpc:Chat(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nChatCount = pNpc.GetTempTable("Npc").nChatCount;
	if nChatCount >= tbSanta.TIMES_CHAT then
		return 0;
	end
	pNpc.GetTempTable("Npc").nChatCount = nChatCount + 1;
	local nRand = MathRandom(1, #tbSanta.SANTACLAUS_CHAT);
	pNpc.SendChat(tbSanta.SANTACLAUS_CHAT[nRand]);
	local nSkillId = tbSanta.SKILL_LIST[nRand%2 + 1];
	pNpc.CastSkill(nSkillId, 14, -1, pNpc.nIndex);
end
