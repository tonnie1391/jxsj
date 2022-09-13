-- 文件名  : planting_gs.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2011-02-24 10:03:48
-- 描述    : 2011植树

if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201103_zhishujie\\planting_def.lua");

SpecialEvent.tbZhiShu2011 = SpecialEvent.tbZhiShu2011 or {};
local tbZhiShu2011 = SpecialEvent.tbZhiShu2011;

-- 种下一棵树
-- return pNpc
function tbZhiShu2011:PlantTree(pPlayer, nTreeIndex, nMapId, x, y, nAwardIndex)
	local nPlayerId = pPlayer.nId;
	local szPlayerName = pPlayer.szName;
	local nNpcId = self.tbTree[nTreeIndex][1];
	assert(nNpcId);
	
	local pNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y)
	
	if not pNpc then
		return 0;
	end
	
	if nTreeIndex == 1 then
		local nRate = MathRandom(1,100);
		for i,nRateEx in ipairs(self.tbAwardRate) do
			if nRate < nRateEx then
				nAwardIndex = i;
				break;
			end
		end
	end
	
	self:SetTreePlantingState(szPlayerName, 1);
	
	self:Msg2PlayerAndAward(nPlayerId, nTreeIndex);
	
	local tbTemp = pNpc.GetTempTable("Npc");
	
	local nTimerId_Die, nTimerId_Alert, nCanGrade, nSeedCollectNum;
	
	if nTreeIndex < self.INDEX_BIG_TREE then
		nTimerId_Alert = Timer:Register((self.tbTree[nTreeIndex][2]) * Env.GAME_FPS, self.TreeDieAlert, self, nPlayerId, pNpc.dwId);		
		nCanGrade = 0;
	else
		nCanGrade = 1;
	end	
	nTimerId_Die = Timer:Register(self.tbTree[nTreeIndex][3] * Env.GAME_FPS, self.TreeDie, self, nPlayerId, pNpc.dwId);
	
	tbTemp.tbZhiShu2011 = {
		["szName"] = pPlayer.szName;
		["dwKingId"] = pPlayer.GetKinMember();
		["dwTongId"] = pPlayer.dwTongId;
		["nPlayerId"] = nPlayerId,
		["nTreeIndex"]  = nTreeIndex; -- 对应 tbZhiShu09.tbIndex2Data 的索引
		["nCanGrade"] = nCanGrade;
		["nAwardIndex"] = nAwardIndex or 1;
		["nTimerId_Die"] = nTimerId_Die;
		["nTimerId_Alert"] = nTimerId_Alert;
		["nSeedCollectNum"] = self.tbTree[nTreeIndex][6] or 0; -- 玩家从这棵树上采集了多少种子
		};
		
	pNpc.szName = szPlayerName .. "的" .. pNpc.szName;
	if nTreeIndex ~= 1 then		
		pNpc.CastSkill(1847, 1, -1, pNpc.nIndex);
		--pPlayer.CallClientScript({"SpecialEvent.tbZhiShu2011:CastSkill", pNpc.dwId});		
	end
	
	return 0, pNpc;
end

--发送消息给自己和帮户家族，及称号领取
function tbZhiShu2011:Msg2PlayerAndAward(nPlayerId, nTreeIndex)	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if nTreeIndex <= self.INDEX_BIG_TREE then
		Dialog:SendBlackBoardMsg(pPlayer, "恭喜你！小树在你的精心呵护下茁壮成长起来。");
	end
	if nTreeIndex >= self.nMinLevelForMsg then
		pPlayer.SendMsgToFriend(string.format("您的好友%s种出了【%s】,真是鸿运当头呀！", pPlayer.szName, self.tbTreeName[nTreeIndex]));
		if pPlayer.dwTongId ~= 0 then
			Player:SendMsgToKinOrTong(pPlayer, string.format("种出了【%s】,真是鸿运当头呀！", self.tbTreeName[nTreeIndex]), 1);
		end
		Player:SendMsgToKinOrTong(pPlayer, string.format("种出了【%s】,真是鸿运当头呀！", self.tbTreeName[nTreeIndex]), 0);
	end
	if nTreeIndex == self.INDEX_BIG_TREE then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("%s种出了【%s】并获得了“忽如一夜春风来”称号,真是鸿运当头呀！", pPlayer.szName, self.tbTreeName[nTreeIndex]));
		pPlayer.AddTitle(unpack(self.tbTitle));
		pPlayer.SetCurTitle(unpack(self.tbTitle));
	end
end

--全局提醒玩家操作
function tbZhiShu2011:Msg2Player(nPlayerId, nIndexMsg, szMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if nIndexMsg then
		local tbMsg = self.tbMsgforOther[nIndexMsg];	
		szMsg = string.format("你种的树需要【%s】，不然树很快就会死掉的。", tbMsg[1]);
	end
	if szMsg then
		pPlayer.Msg(szMsg);
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

-- 提醒需要的操作
function tbZhiShu2011:TreeDieAlert(nPlayerId, dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local nIndexMsg = MathRandom(1,3);
	local tbMsg = self.tbMsgforOther[nIndexMsg];
	pNpc.SendChat(tbMsg[2]);	
	pNpc.GetTempTable("Npc").tbZhiShu2011.nCanGrade = 1;
	pNpc.GetTempTable("Npc").tbZhiShu2011.nActionIndex = nIndexMsg;
	pNpc.GetTempTable("Npc").tbZhiShu2011.nTimerId_Alert = nil;
	GlobalExcute({"SpecialEvent.tbZhiShu2011:Msg2Player",nPlayerId, nIndexMsg});
	return 0;
end

--能否种树判断
function tbZhiShu2011:CanPlantTree(pPlayer)
	--pos
	local nMapId, x, y = pPlayer.GetWorldPos();
	if nMapId < 1 or nMapId > 8 then
		return 0, "只有在新手村才可以种树，这里不是，所以现在就快去吧！";
	end
	
	--task
	local nRes, szKind, nNum = self:IsTreeCountOk(pPlayer);
	if nRes == 0 then
		if szKind == "TOTAL" then
			return 0, string.format("我已经种了%d棵树了，不需要再种了，还是给他人留点地方吧。", nNum);
		elseif szKind == "TODAY" then
			return 0, string.format("我今天已经种了%d棵树了，还是休息下，明天再说吧。", nNum);
		end
	end
	
	--挡npc
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, "在这种会把<color=green>".. pNpc.szName.."<color>给挡住了，还是挪个地方吧。";
		end
	end
	
	--是否种树判断
	for i = 1, 7 do
		if self.tbPlantInfo[i] and self.tbPlantInfo[i][pPlayer.szName] then
			return 0, " 先照顾好已种的树吧...";
		end
	end
	return 1;
end

--设置种树状态
function tbZhiShu2011:SetTreePlantingState(szName, nFlag)
	local nServerId = GetServerId();
	self:SetPlantState(szName, nServerId, nFlag);
	GCExcute({"SpecialEvent.tbZhiShu2011:SetPlantState",szName, nServerId, nFlag});
end

--设置种树标志
function tbZhiShu2011:SetPlantState(szName, nServerId, nFlag)
	self.tbPlantInfo[nServerId] = self.tbPlantInfo[nServerId] or {};
	if nFlag == 1 then		
		self.tbPlantInfo[nServerId][szName] = GetTime();
	else
		self.tbPlantInfo[nServerId][szName] = nil;
	end
end

--种下第一棵树
function tbZhiShu2011:Plant1stTree(pPlayer, dwItemId)
	local nRes = self:CanPlantTree(pPlayer);
	if nRes == 0 then 
		return 0;
	end
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return 0;
	end
	--self:SetTreePlantingState(pPlayer.szName, 0);
	local nMapId, x, y = pPlayer.GetWorldPos();
	local _, pNpc = self:PlantTree(pPlayer,1, nMapId, x, y);
	if pNpc then
		if pItem.nCount > 1 then
			pItem.SetCount(pItem.nCount - 1);
		else
			pItem.Delete(pPlayer);
		end
		pPlayer.SetTask(self.TASKGID, self.TASK_COUNT_PLANT, pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT) + 1);
		StatLog:WriteStatLog("stat_info", "zhishujie", "join", pPlayer.nId, 2);
		return 1;
	end
	return 0;
end

-- 判断玩家植树数量是否符合要求
function tbZhiShu2011:IsTreeCountOk(pPlayer)
	--task
	Setting:SetGlobalObj(pPlayer)
	local nFlag = Player:CheckTask(self.TASKGID, self.TASK_DATE, "%Y%m%d", self.TASK_COUNT_PLANT, self.nMaxPlant);
	Setting:RestoreGlobalObj()
	local nTreeCountToday = pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT);	
	if nFlag == 0 then
		return 0, "TODAY", nTreeCountToday;
	end
	return 1;
end

-- 枯死了
function tbZhiShu2011:TreeDie(nPlayerId, dwNpcId, nState)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local szMsg = "真遗憾啊，您辛苦种的树枯死了，下次要细心点呀！！";
	local tbTreeData = pNpc.GetTempTable("Npc").tbZhiShu2011;	
	local nTreeIndex = tbTreeData.nTreeIndex;
	local szName = tbTreeData.szName	
	
	tbTreeData.nTimerId_Die = nil;
	pNpc.Delete();
	if nTreeIndex ~= self.INDEX_BIG_TREE then
		if nState then
			szMsg = "很不幸，你所种植的小树生命太脆弱了，千万别气馁。";
		end
		GlobalExcute({"SpecialEvent.tbZhiShu2011:Msg2Player",nPlayerId, nil, szMsg});
	end
	self:SetTreePlantingState(szName, 0);
	return 0;
end

--家族帮会人领奖
function tbZhiShu2011:GetAwardKinTong(dwNpcId, nPlayerId, nType)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nFlag = self:CanGatherSeedforOther(dwNpcId, nPlayerId);
	if nFlag == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, "我想你不能摘果子吧。");
		return 0;
	elseif nFlag == 2 then
		Dialog:SendBlackBoardMsg(pPlayer, "果子已被摘光了，下次趁早吧~");
		return 0;
	end
	local nTreeIndex = pNpc.GetTempTable("Npc").tbZhiShu2011.nTreeIndex;	
	self:GetAward(dwNpcId, nPlayerId, 2, nType);
end

--摘果子
function tbZhiShu2011:GatherSeed(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if self:CanGatherSeed(dwNpcId) == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, "我想你不能摘果子吧。");
		return 0;
	end	
	local nTreeIndex = pNpc.GetTempTable("Npc").tbZhiShu2011.nTreeIndex;
	self:GetAward(dwNpcId, nPlayerId, 1);
end

--检查是不是已经摘过果子了
function tbZhiShu2011:CheckIsGatherSeed(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nCanGrade = pNpc.GetTempTable("Npc").tbZhiShu2011.nCanGrade;
	if nCanGrade == 2 then
		return 1;
	end
	return 0;
end

--给奖励
function tbZhiShu2011:GetAward(dwNpcId, nPlayerId, nType, nDetail)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc").tbZhiShu2011;
	if not tbTemp then
		return 0;
	end
	local nTreeIndex = tbTemp.nTreeIndex;
	local nAwardIndex = tbTemp.nAwardIndex;
	--奖励
	local tbAward = self.tbAward[nTreeIndex][nType][nAwardIndex];
	if nDetail then		
		tbAward = self.tbAward[nTreeIndex][nType][nDetail];
	end
	if tbAward[1] == 1 then
		pPlayer.AddBindCoin(tbAward[2]);
	elseif tbAward[1] == 2 then		
		if me.GetBindMoney() + tbAward[2] > me.GetMaxCarryMoney() then
			Dialog:SendBlackBoardMsg(pPlayer, "您的携带的绑定银两过多，还是整理下再使用吧。");
			return 0;
		end
		pPlayer.AddBindMoney(tbAward[2]);
	elseif tbAward[1] == 3 then
		if me.CountFreeBagCell() < tbAward[2][6]  then
			Dialog:SendBlackBoardMsg(pPlayer, string.format("Hành trang không đủ ，需要%s格背包空间。", tbAward[2][6]));
			return 0;
		end
		pPlayer.AddStackItem(unpack(tbAward[2]));
	elseif tbAward[1] == 4 then
		if me.GetBindMoney() + tbAward[2] > me.GetMaxCarryMoney() then
			Dialog:SendBlackBoardMsg(pPlayer, "您的携带的绑定银两过多，还是整理下再使用吧。");
			return 0;
		end
		pPlayer.AddBindMoney(tbAward[2]);
		pPlayer.AddBindCoin(tbAward[3]);
	end
	-- 标志
	if nType == 1 then
		StatLog:WriteStatLog("stat_info", "zhishujie", "open_level", pPlayer.nId, string.format("%s,%s", nTreeIndex, nAwardIndex));
		tbTemp.nCanGrade = 2;
		self:SetTreePlantingState(pPlayer.szName, 0);
		self:GetAwardFinsh(dwNpcId, nPlayerId);
		Dialog:SendBlackBoardMsg(pPlayer, "你已经摘取了果实，感谢你在春天里散播了爱与希望。");
		if nTreeIndex >= self.nMinLevelForMsg then
			pPlayer.SendMsgToFriend(string.format("您的好友%s领取了【%s】的奖励,快去摘果实吧，先到先得喔~", pPlayer.szName, self.tbTreeName[nTreeIndex]));
			if pPlayer.dwTongId ~= 0 then
				Player:SendMsgToKinOrTong(pPlayer, string.format("领取了【%s】的奖励,快去摘果实吧，先到先得喔~", self.tbTreeName[nTreeIndex]), 1);
			end
			Player:SendMsgToKinOrTong(pPlayer, string.format("领取了【%s】的奖励,快去摘果实吧，先到先得喔~", self.tbTreeName[nTreeIndex]), 0);
		end
		--self:Msg2PlayerAndAward();		--通知帮会家族可以领奖
	else
		tbTemp.nSeedCollectNum = tbTemp.nSeedCollectNum - 1;
		tbTemp.tbAwardPlayer = tbTemp.tbAwardPlayer or {};
		tbTemp.tbAwardPlayer[pPlayer.szName] = 1;
	end
	
	return 1;
end

--自己采了果子后删掉死亡timer，设置生存时间
function tbZhiShu2011:GetAwardFinsh(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc").tbZhiShu2011;
	if not tbTemp then
		return 0;
	end
	
	if tbTemp.nTimerId_Die then
		Timer:Close(tbTemp.nTimerId_Die);
		tbTemp.nTimerId_Die = nil;
	end
	tbTemp.nLiveTime = Timer:Register(self.tbTree[tbTemp.nTreeIndex][4] * Env.GAME_FPS, self.TreeliveTime, self, dwNpcId);
end

--生存时间到了杀死树
function tbZhiShu2011:TreeliveTime(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if pNpc then
		pNpc.Delete();
	end	
	return 0;
end

--升级操作
function tbZhiShu2011:GradeTree(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if self:IsNeedGrade(dwNpcId) == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, "我想你还不可以进行这个操作。");
		return 0;
	end	
	local nMapId, x, y = pNpc.GetWorldPos();
	local nTreeIndex = pNpc.GetTempTable("Npc").tbZhiShu2011.nTreeIndex;
	local nAwardIndex = pNpc.GetTempTable("Npc").tbZhiShu2011.nAwardIndex;
	local nRate = self.tbTree[nTreeIndex][5];
	if MathRandom(1,10000) > nRate then
		--操作致死
		self:TreeDie(nPlayerId, dwNpcId, 1);
		StatLog:WriteStatLog("stat_info", "zhishujie", "open_level", pPlayer.nId, string.format("%s,0", nTreeIndex));
		return 0;
	end
	--删除掉前一颗树
	if pNpc.GetTempTable("Npc").tbZhiShu2011.nTimerId_Die then
		Timer:Close(pNpc.GetTempTable("Npc").tbZhiShu2011.nTimerId_Die);
	end
	pNpc.Delete();
	--种下一颗
	self:PlantTree(pPlayer, nTreeIndex + 1, nMapId, x, y, nAwardIndex);
	return 0;
end

--别人是否能摘果子
function tbZhiShu2011:CanGatherSeedforOther(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbZhiShu2011 then
		return 0;
	end
	if not tbTemp.tbZhiShu2011.nCanGrade or tbTemp.tbZhiShu2011.nCanGrade ~= 2 then
		return 0;
	end
	--不是帮会，家族，好友	
	if (not tbTemp.tbZhiShu2011.dwKingId or tbTemp.tbZhiShu2011.dwKingId ~= pPlayer.GetKinMember() or pPlayer.GetKinMember() == 0) and
	 	(not tbTemp.tbZhiShu2011.dwTongId or tbTemp.tbZhiShu2011.dwTongId ~= pPlayer.dwTongId or pPlayer.dwTongId == 0) and
	 	 (not tbTemp.tbZhiShu2011.szName or pPlayer.IsFriendRelation(tbTemp.tbZhiShu2011.szName) ~= 1) then
		return 0;
	end	
	if not tbTemp.tbZhiShu2011.nSeedCollectNum or tbTemp.tbZhiShu2011.nSeedCollectNum <= 0 then
		return 2;
	end
	if tbTemp.tbZhiShu2011.tbAwardPlayer and tbTemp.tbZhiShu2011.tbAwardPlayer[pPlayer.szName] then
		return 0;
	end	
	return 1;
end

--自己能否摘果子
function tbZhiShu2011:CanGatherSeed(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbZhiShu2011 then
		return 0;
	end
	if not tbTemp.tbZhiShu2011.nCanGrade or tbTemp.tbZhiShu2011.nCanGrade ~= 1 then
		return 0;
	end
	if not tbTemp.tbZhiShu2011.nTreeIndex or tbTemp.tbZhiShu2011.nTreeIndex <= 1 then
		return 0;
	end
	return 1;
end

--是否需要升级
function tbZhiShu2011:IsNeedGrade(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbZhiShu2011 then
		return 0;
	end
	if not tbTemp.tbZhiShu2011.nCanGrade or tbTemp.tbZhiShu2011.nCanGrade ~= 1 then
		return 0;
	end
	if not tbTemp.tbZhiShu2011.nTreeIndex or tbTemp.tbZhiShu2011.nTreeIndex >= self.INDEX_BIG_TREE then
		return 0;
	end
	return 1;
end

--同步全局数据
function tbZhiShu2011:SyncData(nServerId, tbPlantInfo)
	local nLServerId = GetServerId();
	if nLServerId == nServerId then
		self.tbPlantInfo = tbPlantInfo;
	end
end

--宕机保护
function tbZhiShu2011:ServerStartFunc()
	GCExcute({"SpecialEvent.tbZhiShu2011:SyncData", GetServerId()});
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.tbZhiShu2011.ServerStartFunc, SpecialEvent.tbZhiShu2011);


--------------------------------------------------------------------------------------------
--team
--获取希望之种
function tbZhiShu2011:GetXiWangZhong(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("包裹空间不足1 ô.");
	  	return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc").tbZhiShu2011;
	if not tbTemp then
		return 0;
	end
	if not tbTemp.tbPlayerList or not tbTemp.tbPlayerList[me.szName] then
		Dialog:Say("这粒希望之种不是你种的。");
		return 0;
	end	
	if tbTemp.tbPlayerList[me.szName] == 2 then
		Dialog:Say("你已经拿过种子了。");
		return 0;
	end
	me.AddItem(unpack(self.tbXiWangZhiZhong));
	tbTemp.tbPlayerList[me.szName] = 2;
	Dialog:SendBlackBoardMsg(me, "恭喜你，你获得了木良赠送的希望之种，可以进行种植了。");
	return 1;
end

--获取希望道具
function tbZhiShu2011:GetXiWangItem(nPlayerId)
	local nFlag, szMsg = self:CheckXiWangItem(nPlayerId);
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nFlag == 0 then		
		Dialog:Say(szMsg);
		return 0;
	end
	local tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);
	for i = 1, #tbTeamMemberList do
		local pPlayer = KPlayer.GetPlayerObjById(tbTeamMemberList[i]);
		if pPlayer then
			local tbItem = self.tbXiWangNeedItem[i];
			local pItem = pPlayer.AddItem(unpack(tbItem));
			if pItem then
				pPlayer.SetTask(self.TASKGID, self.TASK_GETITEM, nDate);
				StatLog:WriteStatLog("stat_info", "zhishujie", "join", pPlayer.nId, 1);
			end
		end
	end
	return 1;
end

--检测获取种子
function tbZhiShu2011:CheckXiWangItem(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end	
	
	--队长且是三人队伍
	if pPlayer.nTeamId == 0 then
		return 0, "必须组队。";
	end
	local tbTeamMemberList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if not tbTeamMemberList or #tbTeamMemberList ~= self.nTeamPlantNum then
		return 0, string.format("必须是%s个人组队。", self.nTeamPlantNum);
	end
	if pPlayer.nId ~= tbTeamMemberList[1] then
		return 0, "你不是队长。";
	end
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	for i = 1, #tbTeamMemberList do
		local pPlayerEx = KPlayer.GetPlayerObjById(tbTeamMemberList[i]);
		if pPlayerEx then
			local nMapId2, nPosX2, nPosY2	= pPlayerEx.GetWorldPos();
			local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
			if nMapId2 ~= nMapId or nDisSquare > 400 then
				return 0, "队友必须在这附近。";
			end
			if pPlayerEx.CountFreeBagCell() < 1 then
			  	return 0, string.format("你们队伍的<color=yellow>%s<color>包裹空间不足1 ô.", pPlayerEx.szName);
			end
			if pPlayerEx.nLevel < self.nAttendMinLevel then
			  	return 0, string.format("你们队伍的<color=yellow>%s<color>等级不足%s级。",pPlayerEx.szName, self.nAttendMinLevel);
			end
			if pPlayerEx.nFaction == 0 then
				return 0, string.format("你们队伍的<color=yellow>%s<color>还是新手，入了门派再来吧。", pPlayerEx.szName);
			end
			if pPlayerEx.GetTask(self.TASKGID, self.TASK_GETITEM) == nDate then
				return 0, string.format("你们队伍的<color=yellow>%s<color>今天已经领取道具了。", pPlayerEx.szName);
			end
		else
			return 0, "队友必须在这附近。";
		end
	end
	return 1;
end

--team种下第一棵树
function tbZhiShu2011:Plant1stTreeTeam(nPlayerId, dwItemId)	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRes, szMsg = self:CanPlantTreeTeam(nPlayerId);
	if nRes == 0 then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say(szMsg);
		Setting:RestoreGlobalObj();
		return 0;
	end
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return 0;
	end
	local nMapId, x, y = pPlayer.GetWorldPos();
	local nPlayerId = pPlayer.nId;
	local szPlayerName = pPlayer.szName;
	local nNpcId = self.tbXiWangNpc[1][1];
	
	local pNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y);
	
	if not pNpc then		
		return 0;
	end
	
	pItem.Delete(pPlayer);
	
	local tbTemp = pNpc.GetTempTable("Npc");
	
	local nTimerId_Die = Timer:Register(self.tbXiWangNpc[1][2] * Env.GAME_FPS, self.TreeDieTeam, self, pNpc.dwId);
	
	tbTemp.tbZhiShu2011 = {
		["nTimerId_Die"] = nTimerId_Die,
		["tbPlayerList"] = {},
		["nStep"] = 1;
		};
	local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	for i = 1 , #tbPlayerList do
		local pPlayerEx = KPlayer.GetPlayerObjById(tbPlayerList[i]);
		if pPlayerEx then
			if pPlayer.nId == tbPlayerList[i] then
				tbTemp.tbZhiShu2011.tbPlayerList[pPlayerEx.szName] = 1;
			else
				tbTemp.tbZhiShu2011.tbPlayerList[pPlayerEx.szName] = 0;
			end
		end
	end
	pNpc.szName = szPlayerName .. "队伍的" .. pNpc.szName;
	self:Msg2TeamMember(nPlayerId, pNpc.dwId);
	return 0;
end

--检测team能中第一棵树不
function tbZhiShu2011:CanPlantTreeTeam(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0, "";
	end
	--pos
	local nMapId, x, y = pPlayer.GetWorldPos();
	if nMapId < 1 or nMapId > 8 then
		return 0, "只有在新手村才可以种树，这里不是，所以现在就快去吧！";
	end	
	--挡npc
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, "在这种会把<color=green>".. pNpc.szName.."<color>给挡住了，还是挪个地方吧。";
		end
	end
	--队长且是三人队伍
	if pPlayer.nTeamId == 0 then
		return 0, "必须组队才能种出希望之种。";
	end
	local tbTeamMemberList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if not tbTeamMemberList or #tbTeamMemberList ~= self.nTeamPlantNum then
		return 0, string.format("必须是%s个人组队才能种出希望之种。", self.nTeamPlantNum);
	end
	if pPlayer.nId ~= tbTeamMemberList[1] then
		return 0, "你不是队长是不能种出希望之种的。";
	end
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();	
	local tbFlag = {};
	for i = 1, #tbTeamMemberList do
		local pPlayerEx = KPlayer.GetPlayerObjById(tbTeamMemberList[i]);
		if pPlayerEx then
			local nMapId2, nPosX2, nPosY2	= pPlayerEx.GetWorldPos();
			local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
			if nMapId2 ~= nMapId or nDisSquare > 400 then
				return 0, "队友必须在这附近。";
			end
			for nStepE = 1, 3 do
				local tbItem = pPlayerEx.FindItemInBags(unpack(self.tbXiWangNeedItem[nStepE]));
				if #tbItem > 0 then
					tbFlag[nStepE] = tbFlag[nStepE] or 1;
				end
			end
		else
			return 0, "队友必须在这附近。";
		end
	end
	if Lib:CountTB(tbFlag) ~= 3 then
		return 0, "你们队伍的人不够3种道具恐怕种不出来希望之种的。"
	end
	return 1;
end

--步骤
function tbZhiShu2011:MakeStepAction(nPlayerId, dwNpcId, nFlag)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then		
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then		
		return 0;
	end
	Setting:SetGlobalObj(pPlayer);
	local tbTemp = pNpc.GetTempTable("Npc").tbZhiShu2011;
	local nStep = tbTemp.nStep;
	local tbPlayerList = tbTemp.tbPlayerList;
	
	--队长且是三人队伍
	if me.nTeamId == 0 then
		Dialog:Say("必须组队才能种出希望之种。");
		Setting:RestoreGlobalObj();
		return 0;
	end
	if not tbPlayerList or not tbPlayerList[me.szName] then
		Dialog:Say("你组错队伍了，这棵树好像不是你跟他们一起种的。");
		Setting:RestoreGlobalObj();
		return 0;
	end
	if tbPlayerList[me.szName] == 1 then
		Dialog:Say("你不能进行这步骤操作。");
		Setting:RestoreGlobalObj();
		return 0;
	end	
	local tbItem = me.FindItemInBags(unpack(self.tbXiWangNeedItem[nStep + 1]));
	if #tbItem <= 0 then
		Dialog:Say("你没有需求的道具。");
		Setting:RestoreGlobalObj();
		return 0;
	end
	if not nFlag then
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
			};
		GeneralProcess:StartProcess("培育希望种子...", 1 * Env.GAME_FPS, {SpecialEvent.tbZhiShu2011.MakeStepAction, SpecialEvent.tbZhiShu2011, nPlayerId, dwNpcId, 1}, nil, tbEvent);
	else
		me.ConsumeItemInBags2(1, unpack(self.tbXiWangNeedItem[nStep + 1]));
		tbTemp.nStep = nStep + 1;
		self:Msg2TeamMember(nPlayerId, dwNpcId);
		if nStep + 1 == 3 then
			self:PlantTreeTeam(nPlayerId, dwNpcId);
		end
	end
	Setting:RestoreGlobalObj();
	return 1;
end

--team种树
function tbZhiShu2011:PlantTreeTeam(nPlayerId, dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nMapId, x, y = pNpc.GetWorldPos();	
	local nNpcId = self.tbXiWangNpc[2][1];
	local tbTemp = pNpc.GetTempTable("Npc").tbZhiShu2011;
	local tbPlayerList = tbTemp.tbPlayerList;	
	pNpc.Delete();
	local pNpcEx = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y);	
	if not pNpcEx then
		return 0;
	end
	tbTemp = pNpcEx.GetTempTable("Npc");
	local nTimerId_Die = Timer:Register(self.tbXiWangNpc[2][2] * Env.GAME_FPS, self.TreeDieTeam, self, pNpcEx.dwId, 1);
	
	tbTemp.tbZhiShu2011 = {
		["nTimerId_Die"] = nTimerId_Die,
		["tbPlayerList"] = tbPlayerList,			
		};
	pNpc.szName = pPlayer.szName .. "队伍的" .. pNpc.szName;
	return 0;
	
end

--team树死亡
function tbZhiShu2011:TreeDieTeam(dwNpcId, nFlag)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc").tbZhiShu2011;
	local tbPlayerList = tbTemp.tbPlayerList;
	if nFlag then
		for _, szName in ipairs(tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerByName(szName)
			if pPlayer then
				pPlayer.Msg("真可惜，你们队伍的种植的树死了！");
				Dialog:SendBlackBoardMsg(pPlayer, "真可惜，你们队伍种植的树死了！");
			end
		end
	end
	pNpc.Delete();
	return 0;
end

--team种树泡泡
function tbZhiShu2011:Msg2TeamMember(nPlayerId, dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc").tbZhiShu2011;
	local nStep = tbTemp.nStep;	
	local szMsg = self.tbXiWangMsg[nStep];
	local tbTeamMemberList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	for i = 1, #tbTeamMemberList do
		local pPlayerEx = KPlayer.GetPlayerObjById(tbTeamMemberList[i]);
		if pPlayerEx then
			pPlayerEx.Msg(szMsg);
			Dialog:SendBlackBoardMsg(pPlayerEx, szMsg);
		end
	end	
	Timer:Register(1* Env.GAME_FPS, self.DelaySendChat, self, dwNpcId, szMsg);	
	return 1;
end

--延迟1秒发消息，给同步npc
function tbZhiShu2011:DelaySendChat(dwNpcId, szMsg)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.SendChat(szMsg);
	return 0;
end

