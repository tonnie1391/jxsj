-- 文件名　：kinplant_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-08 20:07:22
-- 功能    ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201110_nationnalday\\kinplant\\kinplant_def.lua");
local tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011;

--个人进入家族副本时加载npc
function tbKinPlant_2011:AddGroundNpc(nKinId, nMapId)
	if self.tbKinInfo[nKinId] then
		return;
	end
	--领奖期间重启只加商人
	local nDay = tonumber(GetLocalDate("%Y%m%d"));
	if nDay >= self.nAwardTime and nDay <= self.nGetAwardTime then
		KNpc.Add2(self.nTempNpc, 1, -1, nMapId, self.tbTempNpcPos[1], self.tbTempNpcPos[2]);	--Add商人
		self.tbKinInfo[nKinId] = 1;
		return;
	end
	if self:GetState() == 0 then
		return;
	end
	local tbKinPlantInfo = self.tbPlantInfo[nKinId];
	if not tbKinPlantInfo then
		tbKinPlantInfo = self:InitKinPlant(nKinId);
	end
	for i, tb in ipairs(tbKinPlantInfo) do		
		local pNpc = KNpc.Add2(self.tbTempNpc[tb[2]], 1, -1, nMapId, self.tbNpcPoint[i][1], self.tbNpcPoint[i][2]);
		if pNpc and tb[2] > 1 then	--如果是树木需要设置temptable
			local tbTemp = pNpc.GetTempTable("Npc");
			tbTemp.tbKinPlant = {
				["szPlayerName"] 	= tb[1];
				["nTreeIndex"]  	= tb[2];
				["nNum"] 		= i;
				["tbWarterInfo"] 	= {};
				["tbGatherSeed"] 	= {};
				};
			pNpc.szName = tb[1] .. "的" .. pNpc.szName;
			self.tbPlantNpcInfo[nKinId] = self.tbPlantNpcInfo[nKinId] or {};
			self.tbPlantNpcInfo[nKinId][tb[1]] = pNpc.dwId;
		end		
	end
	KNpc.Add2(self.nTempNpc, 1, -1, nMapId, self.tbTempNpcPos[1], self.tbTempNpcPos[2]);	--Add商人
	self.tbKinInfo[nKinId] = 1;	--记录家族是否已经加载了npc
end

--init家族活动信息
function tbKinPlant_2011:InitKinPlant(nKinId)
	self.tbPlantInfo[nKinId] = {};
	for i = 1, #self.tbNpcPoint do
		table.insert(self.tbPlantInfo[nKinId], {"", 1, 0, 0})
	end
	GCExcute({"SpecialEvent.tbKinPlant_2011:InitKinPlant",nKinId});
	return self.tbPlantInfo[nKinId];
end

-- 种下一棵树
-- return pNpc
function tbKinPlant_2011:PlantTree(szPlayerName, nTreeIndex, nMapId, x, y, pPlant, nNum, nNew)	
	local nNpcId = self.tbTempNpc[nTreeIndex];
	local pNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y);
	if not pNpc then
		return 0;
	end	
	--self:Msg2Player(szPlayerName, nTreeIndex);
	local tbTempEx = pPlant.GetTempTable("Npc");
	local tbKinPlantEx = tbTempEx.tbKinPlant or {};
	local tbTemp = pNpc.GetTempTable("Npc");
	tbTemp.tbKinPlant = {
		["szPlayerName"] = szPlayerName;
		["nTreeIndex"]  = nTreeIndex;
		["nNum"] = nNum or tbKinPlantEx.nNum or 0;
		["tbWarterInfo"] = tbKinPlantEx.tbWarterInfo or {};
		["tbGatherSeed"] =  tbKinPlantEx.tbGatherSeed or {};
		};
	if nNew then
		tbTemp.tbKinPlant.tbWarterInfo = {};
		tbTemp.tbKinPlant.tbGatherSeed = {};
	end
	pNpc.szName = szPlayerName .. "的" .. pNpc.szName;	
	return 0, pNpc;
end

--全局提醒玩家操作
function tbKinPlant_2011:Msg2Player(nPlayerId, nIndexMsg, szMsg)
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

--能否种树判断
function tbKinPlant_2011:CanPlantTree(pPlayer)
	--pos
	local _, nX, nY = pPlayer.GetWorldPos();
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	local nFlag = 0;
	local pGround = nil
	local nXGround = 0;
	local nYGround = 0;
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == self.tbTempNpc[1] then
			local _,nX1, nY1 = pNpc.GetWorldPos();
			if (nX- nX1) * (nX- nX1) + (nY- nY1)*(nY- nY1) <= 5 then
				nFlag = 1;
				nXGround = nX1;
				nYGround = nY1;
				pGround = pNpc;
				break;
			end
		end
	end
	if nFlag == 0 then
		return 0, "请在土壤上种植。";
	end
	
	--task
	local nTreeCountToday = pPlayer.GetTask(self.TASKGID, self.TASK_GETITEM);	
	if nTreeCountToday ~= 0 then		
		return 0, "我已经种下了一棵树，不能再种了，还是给他人留点地方吧。";
	end
	
	return 1, pGround, nXGround, nYGround;
end

--种下第一棵树
function tbKinPlant_2011:Plant1stTree(pPlayer, dwItemId)
	local nRes, pPlant, nXGround, nYGround = self:CanPlantTree(pPlayer);
	if nRes == 0 then
		return 0;
	end
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return 0;
	end
	local nNum = 0;
	for i, tb in ipairs(self.tbNpcPoint) do
		if tb[1] == nXGround and tb[2] == nYGround then
			nNum = i;
			break;
		end
	end
	local _, pNpc = self:PlantTree(pPlayer.szName, 2, me.nMapId, nXGround, nYGround, pPlant, nNum);
	if pNpc then
		self.tbPlantNpcInfo[pPlayer.dwKinId] = self.tbPlantNpcInfo[pPlayer.dwKinId] or {};
		self.tbPlantNpcInfo[pPlayer.dwKinId][pPlayer.szName] = pNpc.dwId;
		pItem.Delete(pPlayer);
		pPlant.Delete();
		pPlayer.SetTask(self.TASKGID, self.TASK_GETITEM, nNum);
		GCExcute({"SpecialEvent.tbKinPlant_2011:SetPlantState_GC",pPlayer.dwKinId, pPlayer.szName, 2, nNum, 0, 0});
		self:SetPlantState_GS(pPlayer.dwKinId, pPlayer.szName, 2, nNum, 0, 0);
		StatLog:WriteStatLog("stat_info", "mid_autumn2011", "plant", pPlayer.nId, 1);
		return 1;
	end
	return 0;
end

--系统自动种树
function tbKinPlant_2011:Plant1stTreeEx(szPlayerName, dwKinId, dwNpcId)	
	if not dwNpcId or szPlayerName == "" then
		return;
	end
	local pPlant = KNpc.GetById(dwNpcId);
	if not pPlant then
		return;
	end
	local nMapId, nXGround, nYGround = pPlant.GetWorldPos();
	local tbTemp = pPlant.GetTempTable("Npc");
	local nNum = tbTemp.tbKinPlant.nNum;	
	local _, pNpc = self:PlantTree(szPlayerName, 2, nMapId, nXGround, nYGround, pPlant, nNum, 1);
	if pNpc then
		self.tbPlantNpcInfo[dwKinId] = self.tbPlantNpcInfo[dwKinId] or {};
		self.tbPlantNpcInfo[dwKinId][szPlayerName] = pNpc.dwId;
		pPlant.Delete();
	end
	return 0;
end

--摘果子喽
function tbKinPlant_2011:DelSeed(dwKinId, nNum, nFlag)
	if nFlag then
		self.tbPlantInfo[dwKinId][nNum][4] = self.tbPlantInfo[dwKinId][nNum][4]  - self.nPerGetOther;
	else
		self.tbPlantInfo[dwKinId][nNum][3] = 0;
	end
	GCExcute({"SpecialEvent.tbKinPlant_2011:DelSeed_GC",dwKinId, nNum, nFlag});
end

--设置玩家种树情况
function tbKinPlant_2011:SetPlantState_GS(dwKinId, szName, nType, nNum, nAward, nRemand)
	if not self.tbPlantInfo[dwKinId] then
		return 0;
	end
	self.tbPlantInfo[dwKinId][nNum] = {szName, nType, self.tbPlantInfo[dwKinId][nNum][3] + nAward, nRemand};
end

--摘果子
function tbKinPlant_2011:GatherSeed(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRet, szErrorMsg = self:CanGatherSeed(pNpc, pPlayer);
	if nRet == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, szErrorMsg);
		pPlayer.Msg(szErrorMsg);
		return 0;
	end	
	self:GetAward(dwNpcId, nPlayerId, nRet);
end

--自己采了果子后改buff
function tbKinPlant_2011:GetAward(dwNpcId, nPlayerId, nType)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc").tbKinPlant;
	if not tbTemp then
		return 0;
	end
	if nType == 1 then
		local nNum = pPlayer.GetTask(self.TASKGID, self.TASK_GETITEM);
		local tbInfo = self.tbPlantInfo[pPlayer.dwKinId][nNum];
		local nNeedBag = KItem.GetNeedFreeBag(self.tbAwardItem[1], self.tbAwardItem[2], self.tbAwardItem[3], self.tbAwardItem[4], nil,  tbInfo[4]);
		if pPlayer.CountFreeBagCell() < nNeedBag then
			pPlayer.Msg(string.format("Hành trang không đủ %s chỗ trống.", nNeedBag));
			return 0;
		end
		local nMapId, x, y = pNpc.GetWorldPos();
		pPlayer.AddStackItem(self.tbAwardItem[1], self.tbAwardItem[2], self.tbAwardItem[3], self.tbAwardItem[4], nil, tbInfo[4]);
		local _, pNpcEx = self:PlantTree(pPlayer.szName,self.nMaxIndex, nMapId, x, y, pNpc, nNum);
		if pNpcEx then
			self.tbPlantNpcInfo[me.dwKinId] = self.tbPlantNpcInfo[me.dwKinId] or {};
			self.tbPlantNpcInfo[me.dwKinId][pPlayer.szName] = pNpcEx.dwId;
			pNpc.Delete();
			GCExcute({"SpecialEvent.tbKinPlant_2011:SetPlantState_GC",pPlayer.dwKinId, pPlayer.szName, self.nMaxIndex, nNum, 0, 0});
			self:SetPlantState_GS(pPlayer.dwKinId, pPlayer.szName, self.nMaxIndex, nNum, 0, 0);
			pPlayer.AddExp(math.floor(pPlayer.GetBaseAwardExp() * 20));
			StatLog:WriteStatLog("stat_info", "mid_autumn2011", "gain", pPlayer.nId, string.format("%s,%s", tbInfo[4], 1));
			return 1;
		end
	else
		if pPlayer.CountFreeBagCell() < 1 then
			pPlayer.Msg("Hành trang không đủ chỗ trống1格，请清理下再来吧。");
			return 0;
		end
		pPlayer.AddStackItem(self.tbAwardItem[1], self.tbAwardItem[2], self.tbAwardItem[3], self.tbAwardItem[4], nil, self.nPerGetOther);
		tbTemp.tbGatherSeed[pPlayer.szName] = 1;
		self:DelSeed(pPlayer.dwKinId, tbTemp.nNum, 1);
		pPlayer.AddExp(math.floor(pPlayer.GetBaseAwardExp() * 5));		
		pPlayer.SetTask(self.TASKGID, self.TASK_COUNT_GET, pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_GET) + 1);
		StatLog:WriteStatLog("stat_info", "mid_autumn2011", "gain", pPlayer.nId, "2,0");
	end
end

--升级操作
function tbKinPlant_2011:GradeTree(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end	
	local nRet, szErrorMsg = self:CanGrade(pPlayer, pNpc);
	if  nRet == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, szErrorMsg);
		return 0;
	end
	local nMapId, x, y = pNpc.GetWorldPos();
	local tbTemp = pNpc.GetTempTable("Npc");
	tbTemp.tbKinPlant.tbWarterInfo[pPlayer.szName] = 1;
	if Lib:CountTB(tbTemp.tbKinPlant.tbWarterInfo) == self.nTeamPlantNum then
		local nTreeIndex = tbTemp.tbKinPlant.nTreeIndex;
		local szPlayerName = tbTemp.tbKinPlant.szPlayerName;
		local nNum = tbTemp.tbKinPlant.nNum;	
		local _, pNpcEx = self:PlantTree(szPlayerName, nTreeIndex + 1, nMapId, x, y, pNpc, nNum);
		if pNpcEx then
			self.tbPlantNpcInfo[pPlayer.dwKinId] = self.tbPlantNpcInfo[pPlayer.dwKinId] or {};
			self.tbPlantNpcInfo[pPlayer.dwKinId][szPlayerName] = pNpcEx.dwId;
			pNpc.Delete();
			local nAwardCount = 0;
			local nRemand = 0;
			if nTreeIndex + 2 == self.nMaxIndex then
				nRemand = self.nMaxAwardCoun;
			end
			GCExcute({"SpecialEvent.tbKinPlant_2011:SetPlantState_GC", pPlayer.dwKinId, szPlayerName, nTreeIndex + 1, nNum, nAwardCount, nRemand});
			self:SetPlantState_GS(pPlayer.dwKinId, szPlayerName, nTreeIndex + 1, nNum, nAwardCount, nRemand);
		end
		Dialog:SendBlackBoardMsg(pPlayer, "幸运之种得到水的滋润，已经成长了。");
	else
		Dialog:SendBlackBoardMsg(pPlayer, "幸运之种得到水的滋润，好像快要发芽了。");
	end
	pPlayer.SetTask(self.TASKGID, self.TASK_COUNT_PLANT, pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT) + 1);
	--前十次浇水给福袋
	if pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT) <= 10 then
		pPlayer.AddItem(18,1,80,1);
	end
	pPlayer.AddExp(math.floor(pPlayer.GetBaseAwardExp() * 10));
	return 0;
end

--自己能否摘果子
function tbKinPlant_2011:CanGatherSeed(pPlant, pPlayer)
	local tbTemp = pPlant.GetTempTable("Npc");
	if not tbTemp.tbKinPlant then
		return 0, "问题树。";
	end
	local szPlayerName = tbTemp.tbKinPlant.szPlayerName;
	if szPlayerName == pPlayer.szName then
		return 1;
	else
		local tbGatherSeed = tbTemp.tbKinPlant.tbGatherSeed;
		if tbGatherSeed[pPlayer.szName] then
			return 0, "你太贪心了吧，每个人只能摘取一次。";
		else
			Setting:SetGlobalObj(pPlayer);
			if Player:CheckTask(self.TASKGID, self.TASK_DATE_GET, "%Y%m%d", self.TASK_COUNT_GET, self.nDayMaxGet) == 0 then
				Setting:RestoreGlobalObj();
				return 0, "今天摘别人的已经够多了吧。";
			end
			Setting:RestoreGlobalObj();
			local nNum = tbTemp.tbKinPlant.nNum;
			if self.tbPlantInfo[pPlayer.dwKinId][nNum][4] <= self.nMinAwardCount then
				return 0, "这棵树不是你的，已经被摘够多了。";
			end
			return 2;
		end
	end
	return 0, "系统问题。";
end

--是否能升级
function tbKinPlant_2011:CanGrade(pPlayer, pNpc)
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbKinPlant then
		return 0, "系统出错！";
	end
	if Player:CheckTask(self.TASKGID, self.TASK_DATE, "%Y%m%d", self.TASK_COUNT_PLANT, self.nDayMaxWater) == 0 then
		return 0, "没那么多水了，一天只够浇20次水。";
	end
	if tbTemp.tbKinPlant.tbWarterInfo[pPlayer.szName] then
		return 0, "一粒种子每个人只能浇一次水。";
	end
	if #me.FindItemInBags(unpack(self.tbWaterItem)) <= 0 then
		return 0, "需要有幸运之水才能浇灌种子。";
	end
	if me.GetTask(self.TASKGID, self.TASK_COUNT_PLANT) < 10 and me.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ chỗ trống1格";
	end
	return 1;
end

--使者那里领取累积的种子
function tbKinPlant_2011:DialogGetAward()
	local nNum = me.GetTask(self.TASKGID, self.TASK_GETITEM)
	if not self.tbPlantInfo[me.dwKinId] or nNum <= 0 then
		Dialog:Say("您恐怕还没有中下种子吧。")
		return ;
	end
	local nCount = self.tbPlantInfo[me.dwKinId][nNum][3];
	if nCount <= 0 then
		Dialog:Say("您没有累积的果实。");
		return ;
	end
	local nNeedBag = KItem.GetNeedFreeBag(self.tbAwardItem[1], self.tbAwardItem[2], self.tbAwardItem[3], self.tbAwardItem[4], nil, nCount);
	if me.CountFreeBagCell() < nNeedBag then
		Dialog:Say(string.format("Hành trang không đủ %s chỗ trống.", nNeedBag));
		return 0;
	end
	me.AddStackItem(self.tbAwardItem[1], self.tbAwardItem[2], self.tbAwardItem[3], self.tbAwardItem[4], nil, nCount);
	self:DelSeed(me.dwKinId, nNum);
	StatLog:WriteStatLog("stat_info", "mid_autumn2011", "gain", me.nId, string.format("%s,%s", nCount, 2));
end

--系统收割自动种树
function tbKinPlant_2011:NpcGetAward()
	for dwKinId, tbKinPlantInfo in pairs(self.tbPlantInfo) do
		for i, tb in ipairs(tbKinPlantInfo) do
			if tb[1] and tb[1] ~= "" and self.tbPlantNpcInfo[dwKinId] and self.tbPlantNpcInfo[dwKinId][tb[1]] then
				local dwNpcId = self.tbPlantNpcInfo[dwKinId][tb[1]];
				if tb[2] == self.nMaxIndex - 1 then
					self.tbPlantInfo[dwKinId][i][2] = 2;
					self.tbPlantInfo[dwKinId][i][3] = self.tbPlantInfo[dwKinId][i][3] + self.tbPlantInfo[dwKinId][i][4];
					self.tbPlantInfo[dwKinId][i][4] = 0;
				elseif tb[2] == self.nMaxIndex then
					self.tbPlantInfo[dwKinId][i][2] = 2;
				end
				self:Plant1stTreeEx(tb[1], dwKinId, dwNpcId);
			end
		end
	end
end

--宕机保护
function tbKinPlant_2011:ServerStartFunc(nKinId, tbData)
	if not tbData and not nKinId then
		GCExcute({"SpecialEvent.tbKinPlant_2011:SyncData"});
	else
		if not self.tbPlantInfo[nKinId] then
			self.tbPlantInfo[nKinId] = tbData;
		end
	end
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.tbKinPlant_2011.ServerStartFunc, SpecialEvent.tbKinPlant_2011);
