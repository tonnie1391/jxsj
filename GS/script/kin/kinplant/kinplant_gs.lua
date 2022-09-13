-- 文件名　：kinplant_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-08 20:07:22
-- 功能    ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\kin\\kinlogic_gs.lua");

Require("\\script\\kin\\kinplant\\kinplant_def.lua");

--个人进入家族副本时加载npc
function KinPlant:AddGroundNpc(nKinId, nMapId)
	if self.tbKinInfo[nKinId] then
		return;
	end	
	if self:GetState() == 0 then
		return;
	end
	local tbKinPlantInfo_temp = self.tbPlantInfo[nKinId];
	if not tbKinPlantInfo_temp then
		tbKinPlantInfo_temp = self:InitKinPlant(nKinId);
	end
	for i, tb in ipairs(tbKinPlantInfo_temp) do
		if tb[2] > 0  then	--树的index为0表示是土壤
			local nTime = self:CheckPlantState(i, tb, nKinId);		--停机保护，超时的默认为下个棵树，可以收获的果树在持续一个小时				
			if nTime < 0 then
				self:TreeUpEx(tb[1], nKinId, tb[2],  tb[3], i, nMapId, self.tbNpcPoint[i][1], self.tbNpcPoint[i][2]);
			else
				local _, pNpc, szNpcName = self:PlantTree(tb[1], nKinId, tb[2], nMapId, self.tbNpcPoint[i][1], self.tbNpcPoint[i][2], i, tb[3], nTime, tb[7]);
				local nTitleIndex = self.tbTitileIndex[tb[6]] or 0;
				if self.tbHealthTitile[nTitleIndex] and szNpcName then
					pNpc.SetTitle(string.format("<color=%s>%s %s<color>", self.tbHealthTitile[nTitleIndex][2], self.tbHealthTitile[nTitleIndex][1], szNpcName));
				end
			end
		else
			KNpc.Add2(self.nTempNpc, 1, -1, nMapId, self.tbNpcPoint[i][1], self.tbNpcPoint[i][2]);
		end
	end
	self.tbKinInfo[nKinId] = 1;	--记录家族是否已经加载了npc
end

--检查计算树成长的进程
function KinPlant:CheckPlantState(nNum, tbInfo, nKinId)
	local nNpcId, nTime, bHasMax = self:GetTempNpcInFo(tbInfo[3], tbInfo[2]);
	if GetTime() - tbInfo[7] >= nTime then	--树超时了
		if bHasMax then	--超时没摘的多一个小时
			return  3600;
		else
			return  -1;
		end
	end
	return nTime + tbInfo[7] - GetTime();		--本阶段，剩余时间
end

--init家族活动信息
function KinPlant:InitKinPlant(nKinId)
	self.tbPlantInfo[nKinId] = {};
	for i = 1, #self.tbNpcPoint do
		table.insert(self.tbPlantInfo[nKinId], {"", 0, 0, 0, 0, 0, 0});	--玩家，树阶段，对应的类型，剩余果子，健康度，天气，种植时间
	end
	GCExcute({"KinPlant:InitKinPlant",nKinId});
	return self.tbPlantInfo[nKinId];
end

-- 种下一棵树
-- return pNpc
--玩家名，家族id，树index（树的第几个阶段）， 地图，x，y，第几个坑，种树id
function KinPlant:PlantTree(szPlayerName, dwKinId, nTreeIndex, nMapId, x, y, nNum, nIndex, nTime, nPlantTime)
	local nNpcId, nTimeEx, bHasMax = self:GetTempNpcInFo(nIndex, nTreeIndex);
	if nNpcId == self.nTempNpcId or not nTimeEx then
		return 0;
	end
	local pNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y);
	if not pNpc then
		return 0;
	end
	if not nTime then
		nTime = nTimeEx;
	end
	local nTimerId_up;
	if not bHasMax then
		nTimerId_up = Timer:Register(nTime * Env.GAME_FPS, self.TreeUp, self, pNpc.dwId);
	else
		nTimerId_up = Timer:Register(nTime * Env.GAME_FPS, self.TreeDie, self, pNpc.dwId);
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	tbTemp.tbKinPlant = {
		["szPlayerName"] 	= szPlayerName;
		["nTreeIndex"]  	= nTreeIndex;
		["nIndex"]  		= nIndex;
		["nNum"] 		= nNum or tbKinPlantEx.nNum or 0;
		["tbGatherSeed"] 	=  {};
		["nTimerId_up"] 	= nTimerId_up;
		["dwKinId"] 		= dwKinId;
		["nTime"]			= nPlantTime or GetTime();
		};
	local szNpcName = pNpc.szName;
	pNpc.szName = szPlayerName;
	return bHasMax, pNpc, szNpcName;
end

--能否种树判断
function KinPlant:CanPlantTree(pPlayer, pItem)
	--Figure
	if pPlayer.nKinFigure == Kin.FIGURE_SIGNED then
		return 0, "Các thành viên trong gia tộc không thể tham gia hoạt động trồng trọt.";
	end
	--Time
	local nNowTime = tonumber(GetLocalDate("%H%M"));
	local nTimeFlag = 0;
	for _, tbTime in ipairs (self.tbPlantTime) do
		if nNowTime >= tbTime[1] and nNowTime <= tbTime[2] then
			nTimeFlag = 1;
			break;
		end
	end
	if nTimeFlag == 0 then
		return 0, "Hoạt động từ 09：00 - 23：00 mỗi ngày.";
	end
	--pos
	local _, nX, nY = pPlayer.GetWorldPos();
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	local nFlag = 0;
	local pGround = nil
	local nXGround = 0;
	local nYGround = 0;
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == self.nTempNpc then
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
		return 0, "Hãy trồng trên gò đất.";
	end
	
	--task
	local nTreeCountToday = self:GetTask(pPlayer);
	if nTreeCountToday >= self.nMaxPlantCount then
		return 0, string.format("Ngươi đã trồng %s cây, không thể trồng thêm.", self.nMaxPlantCount);
	end
	
	local nFlagEx = Player:CheckTask(self.TASKGID, self.TASK_DATE, "%Y%m%d", self.TASK_COUNT, self.nMaxPlantCount);
	if nFlagEx == 0 then
		return 0, string.format("Ngươi đã trồng %s cây, hãy tiết kiệm chỗ cho người khác.", self.nMaxPlantCount);
	end
	
	local nIndex = pItem.GetExtParam(1);
	if not nIndex or not self.tbPlantNpcInfo[nIndex] then
		return 0, "Hạt giống đã hết hạn.";
	end
	if pItem.GetGenInfo(1) ~= 1 then
		local tbGrade = self.tbPlantNpcInfo[nIndex].tbGrade;
		for i =1, 3 do
			if tbGrade[i] and pPlayer.GetReputeLevel(14, i) < tbGrade[i] then
				return 0, "Chuyên môn không đủ để trồng cây.";
			end
		end
	end
	return 1, pGround, nXGround, nYGround;
end

--种下第一棵树
function KinPlant:Plant1stTree(pPlayer, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return 0;
	end
	local nRes, pPlant, nXGround, nYGround = self:CanPlantTree(pPlayer, pItem);
	if nRes == 0 then
		return 0;
	end	
	local nIndex = pItem.GetExtParam(1);
	local nNum = 0;
	for i, tb in ipairs(self.tbNpcPoint) do
		if tb[1] == nXGround and tb[2] == nYGround then
			nNum = i;
			break;
		end
	end
	local _, pNpc = self:PlantTree(pPlayer.szName, pPlayer.dwKinId, 1, pPlayer.nMapId, nXGround, nYGround, nNum, nIndex);
	if pNpc then
		if pItem.nCount <= 1 then
			pItem.Delete(pPlayer);
		else
			pItem.SetCount(pItem.nCount - 1);
		end
		pPlant.Delete();	--删除土壤
		self:AddTask(nNum, pPlayer);	--记录坑位变量
		pPlayer.SetTask(self.TASKGID, self.TASK_COUNT, pPlayer.GetTask(self.TASKGID, self.TASK_COUNT) + 1);	--记录每天的数量
		
		local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_ZHONGZHI];
		Kinsalary:AddSalary_GS(pPlayer, Kinsalary.EVENT_ZHONGZHI, tbInfo.nRate);
		
		local nWeatherType = self:GetWeatherType(pPlayer.nMapId);
		GCExcute({"KinPlant:SetPlantState_GC",pPlayer.dwKinId, pPlayer.szName, 1, nNum, 0, nIndex, nWeatherType, 0, GetTime()});
		self:SetPlantState_GS(pPlayer.dwKinId, pPlayer.szName, 1, nNum, 0, nIndex, nWeatherType, 0, GetTime());
		StatLog:WriteStatLog("stat_info", "homeland", "plant", pPlayer.nId, nIndex);
		return 1;
	end
	return 0;
end

--摘果子喽
function KinPlant:DelSeed(dwKinId, nNum, nPerGetOther)
	self.tbPlantInfo[dwKinId][nNum][4] = self.tbPlantInfo[dwKinId][nNum][4]  - nPerGetOther;
	GCExcute({"KinPlant:DelSeed_GC",dwKinId, nNum, nPerGetOther});
end

--设置玩家种树情况
function KinPlant:SetPlantState_GS(dwKinId, szName, nTreeIndex, nNum, nRemand, nIndex, nWeatherType, nHealth, nTime)
	if not self.tbPlantInfo[dwKinId] then
		return 0;
	end
	self.tbPlantInfo[dwKinId][nNum] = {szName, nTreeIndex, nIndex, nRemand, nWeatherType, nHealth, nTime};
end

--摘果子
function KinPlant:GatherSeed(dwNpcId, nPlayerId, nFlag)
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
		GeneralProcess:StartProcess("Đang thu hoạch...", 3 * Env.GAME_FPS, {KinPlant.GatherSeed, KinPlant, dwNpcId, nPlayerId, 1}, nil, tbEvent);
		return;
	end
	self:GetAward(dwNpcId, nPlayerId, nRet);
end

--自己采了果子后改buff
function KinPlant:GetAward(dwNpcId, nPlayerId, nType)
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
	local tbFruit = self:GetFruitItem(tbTemp.nIndex);
	if not tbFruit then
		return 0;
	end
	if nType == 1 then
		local tb = self.tbPlantInfo[pPlayer.dwKinId][tbTemp.nNum];
		local nNum =math.floor(tb[4] + self:GetWeatherRate(tb[3], tb[5]) + tb[6]  + self:GetKinRate(pPlayer.dwKinId));		--果实数量为：原本数量+天气加成数量+健康度加成数量+家族技能加成数量
		nNum = nNum * self.nTimes;
		local nNeedBag = KItem.GetNeedFreeBag(tbFruit[1], tbFruit[2], tbFruit[3], tbFruit[4], nil,  nNum);
		local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("KinPlantGetFruit", pPlayer, tbTemp.nIndex, nNum);
		if pPlayer.CountFreeBagCell() < nNeedBag + nFreeCount then
			pPlayer.Msg(string.format("Hành trang không đủ %s ô trống.", nNeedBag + nFreeCount));
			return 0;
		end
		local nMapId, x, y = pNpc.GetWorldPos();
		pPlayer.AddStackItem(tbFruit[1], tbFruit[2], tbFruit[3], tbFruit[4], nil, nNum);
		pNpc.Delete();
		self:AddRepute(pPlayer, tbTemp.nIndex, nNum);		--收获加对应的专精
		self:ChangePlantState(pPlayer.dwKinId, "", 0, tbTemp.nNum, 0, 0, 0, 0, 0);		--请空坑位
		KNpc.Add2(self.nTempNpc, 1, -1, nMapId, x, y);	--土壤加上
		Achievement:FinishAchievement(pPlayer, 452);	--丰收的喜悦
		Achievement:FinishAchievement(pPlayer, 453);	--仓廪实 
		SpecialEvent.ActiveGift:AddCounts(pPlayer, 47);	--活跃度
		SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_TRONGCAY);
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		StatLog:WriteStatLog("stat_info", "homeland", "get_ fruit", pPlayer.nId, string.format("%s,%s,%s", tbTemp.nIndex, nNum, 1));
		return 1;
	else
		if pPlayer.CountFreeBagCell() < 1 then
			pPlayer.Msg("Hành trang không đủ 1 ô trống");
			return 0;
		end
		local nPerGetOther = self:GetPerGetFruit(tbTemp.nIndex);
		pPlayer.AddStackItem(tbFruit[1], tbFruit[2], tbFruit[3], tbFruit[4], nil, nPerGetOther);
		tbTemp.tbGatherSeed[pPlayer.szName] = tonumber(GetLocalDate("%Y%m%d"));
		self:DelSeed(pPlayer.dwKinId, tbTemp.nNum, nPerGetOther);
		pPlayer.SetTask(self.TASKGID, self.TASK_COUNT_GET, pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_GET) + 1);
		Achievement:FinishAchievement(pPlayer, 465);	--勤俭持家
		Achievement:FinishAchievement(pPlayer, 466);	--颗粒归仓 
		Achievement:FinishAchievement(pPlayer, 467);	--广积粮 
		StatLog:WriteStatLog("stat_info", "homeland", "get_ fruit", pPlayer.nId, string.format("%s,%s,%s", tbTemp.nIndex, nPerGetOther, 0));
	end
end

--升级操作
function KinPlant:TreeUp(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	
	local nMapId, x, y = pNpc.GetWorldPos();
	local tbTemp = pNpc.GetTempTable("Npc");
	local nTreeIndex = tbTemp.tbKinPlant.nTreeIndex;
	local szPlayerName = tbTemp.tbKinPlant.szPlayerName;
	local nIndex = tbTemp.tbKinPlant.nIndex;
	local nNum = tbTemp.tbKinPlant.nNum;	
	local dwKinId = tbTemp.tbKinPlant.dwKinId;
	local bHasMax, pNpcEx, szTreeName = self:PlantTree(szPlayerName, dwKinId, nTreeIndex + 1, nMapId, x, y, nNum, nIndex);
	if pNpcEx then
		pNpc.Delete();
		local nRemand, nHealth, nHealthGroup;
		if bHasMax then
			nHealthGroup, nHealth = self:GetRandHeath();
			nRemand = self:GetMaxAwardCount(nIndex);
			local tbTitle = self.tbHealthTitile[nHealthGroup];
			if tbTitle and szTreeName then
				pNpcEx.SetTitle(string.format("<color=%s>%s%s<color>", tbTitle[2], tbTitle[1], szTreeName));
			end
			--种出高产作物
			local cKin = KKin.GetKin(dwKinId)
			if nHealthGroup >= 5 and cKin and tbTitle and szTreeName then
				local szKinMsg = string.format("[%s]-[%s] thu được %s%s", cKin.GetName(),  szPlayerName, tbTitle[1], szTreeName);
				KKin.Msg2Kin(dwKinId, szKinMsg, 0);
				if nHealthGroup == #self.tbHealthTitile then
					local szWorldMsg = string.format("[%s]-[%s] thu được nông sản Chất lượng cao!", cKin.GetName(), szPlayerName);
					KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szWorldMsg);
					Dialog:GlobalMsg2SubWorld_GS(szWorldMsg);
				end
			end
		end
		self:ChangePlantState(dwKinId, nil, nTreeIndex + 1, nNum, nRemand, nil, nil, nHealth, GetTime());		--改树的index和剩余果子的数量，以及健康度
	end
	return 0;
end

--启动服务器时候加的树成长了
function KinPlant:TreeUpEx(szPlayerName, dwKinId, nTreeIndex, nIndex, nNum, nMapId, x, y)
	local bHasMax, pNpc, szNpcName = self:PlantTree(szPlayerName, dwKinId, nTreeIndex + 1, nMapId, x, y, nNum, nIndex);
	if pNpc then
		local nRemand, nHealth, nHealthGroup;
		if bHasMax then
			nHealthGroup, nHealth = self:GetRandHeath();
			local tbTitle = self.tbHealthTitile[nHealthGroup];
			if tbTitle and szNpcName then
				pNpc.SetTitle(string.format("<color=%s>%s%s<color>", tbTitle[2], tbTitle[1], szNpcName));
			end
			nRemand = self:GetMaxAwardCount(nIndex);
		end
		self:ChangePlantState(dwKinId, nil, nTreeIndex + 1, nNum, nRemand, nil, nil, nHealth, GetTime());		--改树的index和剩余果子的数量，以及健康度
	end
	return 0;
end

--72小时树死亡，被别人挖掉
function KinPlant:TreeDie(nNpcId, nFlag)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nMapId, x, y = pNpc.GetWorldPos();
	local tbTemp = pNpc.GetTempTable("Npc");
	local nTimerId_up = tbTemp.tbKinPlant.nTimerId_up;
	local nNum = tbTemp.tbKinPlant.nNum;	
	local dwKinId = tbTemp.tbKinPlant.dwKinId;
	pNpc.Delete();
	if nFlag and Timer:GetRestTime(nTimerId_up) > 0 then
		Timer:Close(nTimerId_up);
	end
	self:ChangePlantState(dwKinId, "", 0, nNum, 0, 0, 0, 0, 0);		--清空坑位
	local nPlayerId = KGCPlayer.GetPlayerIdByName(tbTemp.tbKinPlant.szPlayerName);
	if not nFlag and nPlayerId then
		StatLog:WriteStatLog("stat_info", "homeland", "dead", nPlayerId, tbTemp.tbKinPlant.nIndex);
	elseif not nFlag and not nPlayerId then	--重启服务器，玩家没上过线，没有id
		WriteStatLog("stat_info", "homeland", "dead", string.format("NONE\t%s\t%s", tbTemp.tbKinPlant.szPlayerName, nNum));
	end
	KNpc.Add2(self.nTempNpc, 1, -1, nMapId, x, y);	--土壤加上
	return 0;
end

--挖树
function KinPlant:TreeDredging(nNpcId, nPlayerId, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRet, vErrorMsg = self:CheckDredging(nNpcId, nPlayerId);
	if nRet == 0 then
		pPlayer.Msg(vErrorMsg);
		return;
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
		GeneralProcess:StartProcess("Đang nhổ...", 3 * Env.GAME_FPS, {self.TreeDredging, self, nNpcId, nPlayerId, 1}, nil, tbEvent);
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		local tbTemp = pNpc.GetTempTable("Npc").tbKinPlant;
		if tbTemp then
			if tbTemp.szPlayerName == pPlayer.szName then
				Achievement:FinishAchievement(pPlayer, 463);	--三思而后行
				Achievement:FinishAchievement(pPlayer, 464);	--冲动是魔鬼
				pPlayer.Msg("Đã loại bỏ 1 cây trồng.");
			else
				KKin.Msg2Kin(pPlayer.dwKinId, string.format("%s đã bị [%s] nhổ lên.", pNpc.szName, pPlayer.szName), 0);
			end
		end
	end
	self:TreeDie(nNpcId, 1)
	StatLog:WriteStatLog("stat_info", "homeland", "remove", nPlayerId, string.format("%s,%s", vErrorMsg, nRet-1));
end

function KinPlant:CheckDredging(nNpcId, nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0, "Cây đã héo.";
	end	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0, "你没在植物跟前。";
	end
	local cKin = KKin.GetKin(pPlayer.dwKinId)
	if not cKin then
		return 0, "Xâm nhập bất hợp pháp.";
	end	
	if pPlayer.IsAccountLock() ~= 0 then
		return 0, "Tài khoản đang khóa.";	
	end
	local tbTemp = pNpc.GetTempTable("Npc").tbKinPlant;
	if not tbTemp then
		return 0, "Cây này đã bị bệnh.";
	end
	local nIndex = tbTemp.nIndex;
	if not self.tbPlantNpcInfo[nIndex] then
		return 0, "Cây này đã bị bệnh.";
	end	
	if tbTemp.szPlayerName == pPlayer.szName then
		return 2, nIndex;
	end
	local nDredging = self.tbPlantNpcInfo[nIndex].nDredging;
	--被其他人挖掘等级:1族长，2族长副族长，3正式成员，4荣誉成员，5记名成员(向上兼容)
	local tbKinFigure = {[4] = 5, [5] = 4};	--把记名和荣誉的颠倒位置
	local nKinFigure = tbKinFigure[pPlayer.nKinFigure] or pPlayer.nKinFigure;
	if nKinFigure <= 0 or nKinFigure > nDredging then
		return 0, "Bạn không được phép đào cây này.";
	end	
	if cKin.GetCaptainLockState() == 1 then
		return 0, "Quyền tộc trưởng đang tạm gián đoạn.";
	end
	return 1, nIndex;
end

function KinPlant:ChangePlantState(dwKinId, szName, nTreeIndex, nNum, nRemand, nIndex, nWeatherType, nHealth, nTime)
	if not dwKinId or not nNum or not self.tbPlantInfo[dwKinId] then
		return 0;
	end
	szName 	= szName or self.tbPlantInfo[dwKinId][nNum][1];
	nTreeIndex 	= nTreeIndex or self.tbPlantInfo[dwKinId][nNum][2];
	nIndex 	= nIndex or self.tbPlantInfo[dwKinId][nNum][3];
	nRemand 	= nRemand or self.tbPlantInfo[dwKinId][nNum][4];
	nWeatherType 	= nWeatherType or self.tbPlantInfo[dwKinId][nNum][5];
	nHealth 		= nHealth or self.tbPlantInfo[dwKinId][nNum][6];
	nTime 		= nTime or self.tbPlantInfo[dwKinId][nNum][7];
	self:SetPlantState_GS(dwKinId, szName, nTreeIndex, nNum, nRemand, nIndex, nWeatherType, nHealth, nTime);
	GCExcute({"KinPlant:SetPlantState_GC", dwKinId, szName, nTreeIndex, nNum, nRemand, nIndex, nWeatherType, nHealth, nTime});
end

--自己能否摘果子
function KinPlant:CanGatherSeed(pPlant, pPlayer)
	local tbTemp = pPlant.GetTempTable("Npc");
	if not tbTemp.tbKinPlant or not tbTemp.tbKinPlant.nNum then
		return 0, "Cây này đã bị bệnh.";
	end
	if not pPlayer.dwKinId or not self.tbPlantInfo[pPlayer.dwKinId] then
		return 0, "Cây này đã bị bệnh.";
	end
	local tbFruit = self:GetFruitItem(tbTemp.tbKinPlant.nIndex);
	if not tbFruit then
		return 0;
	end
	local szPlayerName = tbTemp.tbKinPlant.szPlayerName;
	if szPlayerName == pPlayer.szName then
		local tb = self.tbPlantInfo[pPlayer.dwKinId][tbTemp.tbKinPlant.nNum];
		local nNum =math.floor(tb[4] + self:GetWeatherRate(tb[3], tb[5]) + tb[6]  + self:GetKinRate(pPlayer.dwKinId));		--果实数量为：原本数量+天气加成数量+健康度加成数量+家族技能加成数量
		local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("KinPlantGetFruit", pPlayer, tbTemp.tbKinPlant.nIndex, nNum);
		local nNeedBag = KItem.GetNeedFreeBag(tbFruit[1], tbFruit[2], tbFruit[3], tbFruit[4], nil,  nNum);
		if pPlayer.CountFreeBagCell() < nNeedBag + nFreeCount then
			return 0, string.format("Hành trang không đủ %s ô trống!", nNeedBag + nFreeCount);
		end
		return 1;
	else
		local tbGatherSeed = tbTemp.tbKinPlant.tbGatherSeed;
		local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
		if tbGatherSeed[pPlayer.szName] and tbGatherSeed[pPlayer.szName] == nNowDate then
			return 0, "Đừng tham lam, ngươi đã trồng đủ hôm nay rồi";
		else
			Setting:SetGlobalObj(pPlayer);
			local nFlagEx = Player:CheckTask(self.TASKGID, self.TASK_DATE_GET, "%Y%m%d", self.TASK_COUNT_GET, self.nDayMaxGet);
			Setting:RestoreGlobalObj();
			if nFlagEx == 0 then
				return 0, "Hôm nay ngươi trộm đã đủ rồi.";
			end
			local nNum = tbTemp.tbKinPlant.nNum;
			local nIndex = tbTemp.tbKinPlant.nIndex;
			local nTime = tbTemp.tbKinPlant.nTime;
			if self:GetPerGetFruit(nIndex) == 0 then
				return 0, "Ngươi không thể trộm cây này.";
			end
			if self.tbPlantInfo[pPlayer.dwKinId][nNum][4] <= self:GetMinAwardCount(nTime, nIndex) then
				return 0, "Cây này còn quá ít.";
			end
			if pPlayer.CountFreeBagCell() < 1 then
				return 0, "Hành trang không đủ 1 ô trống.";
			end
			return 2;
		end
	end
	return 0, "Lỗi";
end

--获得npc对话table
function KinPlant:MergeDialog(tbOpt, nNpcId)
	local nTaskInfo = KGblTask.SCGetDbTaskInt(DBTASK_KINPLANT_TASK);
	local nTask1 = math.fmod(nTaskInfo , 100);
	local nTask2 = math.fmod((nTaskInfo - nTask1)/100, 100);
	local nTask3 = math.fmod((nTaskInfo - nTask2*100 - nTask1)/10000, 100);
	local tbTask = {nTask1, nTask2, nTask3};
	local nWeakly = math.floor(nTaskInfo/1000000);
	local nTaskWeakly = me.GetTask(self.TASKGID, self.TASK_FINISHTASK);	
	if nWeakly == 0 or (nWeakly > 0 and nWeakly == nTaskWeakly) then
		return;
	end
	local nFlag = 1;	
	for i = 1, 3 do
		if self.tbPlantWeekTask[i] and self.tbPlantWeekTask[i][tbTask[i]] then
			nFlag = 0;
			table.insert(tbOpt, 1, {self.tbTypeName[i] or "[<color=yellow>Đơn đặt hàng Gia tộc<color>]", self.OnDialog, self, tbTask[i], i});
		end
	end
	if nFlag == 0 then
		return 1;
	end
	return;
end

--对话交任务道具
function KinPlant:OnDialog(nNum, nType)
	local tbTaskInfo = self.tbPlantWeekTask[nType][nNum];
	local szMsg = tbTaskInfo[2] or "";
	local tbOpt = {{"Nhận hạt giống", self.GetSeed, self, nNum, nType},
		{"Giao hàng", self.OnDialogEx, self, nNum, nType},
		{"Để ta suy nghĩ thêm"}};
	Dialog:Say(szMsg, tbOpt);
end

--获取种子
function KinPlant:GetSeed(nNum, nType)
	local nSeedCount = 0;
	local tbSeed = {};
	local nNeedBag = 0;
	local tbTaskInfo = self.tbPlantWeekTask[nType][nNum];
	for i, tbFurit in ipairs(tbTaskInfo[1]) do
		local tb = Lib:SplitStr(self.tbPlantFruit[tbFurit[1]].szItem);
		if #tb == 4 and tbFurit[3] > 0 then
			nNeedBag = nNeedBag + tbFurit[3];
			table.insert(tbSeed, {{tonumber(tb[1]), tonumber(tb[2]), tonumber(tb[3]), tonumber(tb[4])}, tbFurit[3]});
		end
	end
	if nNeedBag <= 0 then
		return;
	end
	if me.nKinFigure == 0 or me.nKinFigure == Kin.FIGURE_SIGNED then
		me.Msg("您还是记名成员恐怕不能种植作物。");
		return 0;
	end
	if me.CountFreeBagCell() < nNeedBag then
		me.Msg(string.format("Hành trang không đủ %s ô trống.", nNeedBag));
		return 0;
	end
	local nTaskInfo = KGblTask.SCGetDbTaskInt(DBTASK_KINPLANT_TASK);
	local nWeakly = math.floor(nTaskInfo/1000000);
	local nTaskWeakly = me.GetTask(self.TASKGID, self.TASK_GETTASK);
	if nTaskWeakly == nWeakly then
		me.Msg("Ngươi đã nhận đơn đặt hàng của tuần này.");
		return 0;
	end
	for _, tb in ipairs(tbSeed) do
		for i =1, tb[2] do
			local pItem = me.AddItemEx(tb[1][1], tb[1][2], tb[1][3], tb[1][4], nil, nil, GetTime() + 3600*24*3);
			if pItem then
				pItem.SetGenInfo(1, 1);	--设置为不需要等级就可以种的果子
				pItem.Sync();
			end
		end
	end
	me.SetTask(self.TASKGID, self.TASK_GETTASK, nWeakly);
	StatLog:WriteStatLog("stat_info", "homeland", "spe_order", me.nId, string.format("1,%s", nType));
end

--对话交任务道具
function KinPlant:OnDialogEx(nNum, nType)
	if not self.tbPlantWeekTask[nType] or not self.tbPlantWeekTask[nType][nNum] then
		return;
	end
	local tbTaskInfo = self.tbPlantWeekTask[nType][nNum];
	Dialog:OpenGift("Hãy đặt vào các mặt hàng. Nếu dư ta sẽ trả lại.", nil ,{self.OnOpenGiftOk, self, tbTaskInfo, nType});
end

function KinPlant:OnOpenGiftOk(tbTaskInfo, nType, tbItemObj)
	local nCount, szMsg = self:ChechItem(tbItemObj, tbTaskInfo);
	if (nCount == 0) then
		me.Msg(szMsg or "Không đủ số lượng các mặt hàng hoặc không phù hợp.");
		return 0;
	end
	local tbCount = {};
	for _, tbFruit in ipairs(tbTaskInfo[1]) do
		local tbItem = Lib:SplitStr(tbFruit[1]);
		if #tbItem ~= 4 then
			me.Msg("Đơn hàng bất thường.");
			return 0;
		end
		if not self.tbPlantFruit[tbFruit[1]] then
			me.Msg("Đơn hàng bất thường.");
			return;
		end
		me.ConsumeItemInBags2(tbFruit[2], tonumber(tbItem[1]), tonumber(tbItem[2]), tonumber(tbItem[3]), tonumber(tbItem[4]));
		tbCount[tbFruit[1]] = tbCount[tbFruit[1]] or 0;
		tbCount[tbFruit[1]] = tbCount[tbFruit[1]] + tbFruit[2];
	end
	self:ChangeFruit(tbCount, 1.5);
	local nTaskInfo = KGblTask.SCGetDbTaskInt(DBTASK_KINPLANT_TASK);
	local nWeakly = math.floor(nTaskInfo/1000000);
	for i = 468, 471 do		--举手之劳|体贴入微|日积月累|有求必应
		Achievement:FinishAchievement(me, i);
	end
	 me.SetTask(self.TASKGID, self.TASK_FINISHTASK, nWeakly);
	 StatLog:WriteStatLog("stat_info", "homeland", "spe_order", me.nId, string.format("2,%s", nType));
end

function KinPlant:ChechItem(tbItemObj, tbTaskInfo)
	local tbItem = {};
	for _, pItem in pairs(tbItemObj) do
		local szItem		= string.format("%s,%s,%s,%s", pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		tbItem[szItem] = tbItem[szItem] or 0;
		tbItem[szItem] = tbItem[szItem] + pItem[1].nCount;
	end
	local nTaskInfo = KGblTask.SCGetDbTaskInt(DBTASK_KINPLANT_TASK);
	local nWeakly = math.floor(nTaskInfo/1000000);
	local nTaskWeakly = me.GetTask(self.TASKGID, self.TASK_FINISHTASK);
	if nWeakly == 0 then
		return 0, "Không còn nhiệm vụ cho tuần này.";
	end
	if nWeakly > 0 and nWeakly == nTaskWeakly then
		return 0, "Mỗi người chỉ có thể hoàn thành đơn hàng đặt biệt mỗi tuần 1 lần.";
	end
	local tbCount = {};
	for _, tbFruit in ipairs(tbTaskInfo[1]) do
		if not tbItem[tbFruit[1]] or  tbItem[tbFruit[1]] < tbFruit[2] then
			return 0, "Số lượng các mặt hàng không chính xác.";
		end
		tbCount[tbFruit[1]] = tbCount[tbFruit[1]] or 0;
		tbCount[tbFruit[1]] = tbCount[tbFruit[1]] + tbFruit[2];
	end
	local nNeedBag, tbAward = self:GetChangeFNeedBag(tbCount);
	if me.CountFreeBagCell() < nNeedBag then
		return 0, string.format("Hành trang không đủ %s chỗ trống.", nNeedBag);
	end
	if tbAward[3] > 0 and me.GetBindMoney() + tbAward[3] > me.GetMaxCarryMoney() then
		return 0, "Bạc trên người đã đạt giới hạn.";
	end
	return nCount;
end
---------------------------------------------------------
----------------c2s--------------------------------------
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	Kin.c2sFun[szName] = fun
end
--同步家族数值
function Kin:RefreshKinPlant_HandIn(nKinId)
	if not nKinId then
		
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end	
	return KKinGs.KinClientExcute(nKinId, {"Kin:AddPlantSkillExp_C2", 0, cKin.GetHandInCount()});
end

RegC2SFun("RefreshKinPlant_HandIn", Kin.RefreshKinPlant_HandIn);

---------------------------------------------------------
---------------------------------------------------------
--同步家族数值
function KinPlant:RefreshKinPlant()
	local cKin = KKin.GetKin(me.dwKinId)
	if not cKin then
		return 0
	end	
	return KKinGs.KinClientExcute(me.dwKinId, {"Kin:AddPlantSkillExp_C2", 0, cKin.GetHandInCount()});
end

PlayerEvent:RegisterGlobal("OnLogin",  KinPlant.RefreshKinPlant,  KinPlant);

--宕机保护
function KinPlant:ServerStartFunc(nKinId, tbData)
	if not tbData and not nKinId then
		GCExcute({"KinPlant:SyncData"});
	else
		if not self.tbPlantInfo[nKinId] then
			self.tbPlantInfo[nKinId] = tbData;
		end
	end
end

function KinPlant:Login_ProcessSubPlayerPlantTask(bExchangeServerComing)
	if (bExchangeServerComing == 1) then
		return 0;
	end
	
	local nCoZoneTime	= KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
	
	-- 没有合服标志
	if (nCoZoneTime <= 0) then
		return 0;
	end
	
	local nNowTime		= GetTime();
	local nCoZoneWeek	= Lib:GetLocalWeek(nCoZoneTime);
	local nNowWeek		= Lib:GetLocalWeek(nNowTime);
	-- 如果跨周了那么就不更新标记了
	if (nNowWeek ~= nCoZoneWeek) then
		return 0;
	end

	-- 主服玩家不刷新
	if (me.IsSubPlayer() == 0) then
		return 0;
	end

	local nCoZoneRepairFlag = me.GetTask(self.TASKGID, self.TASK_COZONE_FLAG);
	-- 如果修复标记一样说明已经修复过了
	if (nCoZoneTime == nCoZoneRepairFlag) then
		return 0;
	end

	local nTaskInfo = KGblTask.SCGetDbTaskInt(DBTASK_KINPLANT_TASK);
	local nWeakly = math.floor(nTaskInfo/1000000);
	local nTaskWeakly = me.GetTask(self.TASKGID, self.TASK_FINISHTASK);
	local nTaskGetWeakly = me.GetTask(self.TASKGID, self.TASK_GETTASK);
	if nWeakly == 0 then
		return 0;
	end
	-- 如果发现已经完成本周任务了那就不用修复了
	if nWeakly > 0 and nWeakly == nTaskWeakly then
		return 0;
	end
	
	-- 这里清除获取标记
	me.SetTask(self.TASKGID, self.TASK_COZONE_FLAG, nCoZoneTime);
	me.SetTask(self.TASKGID, self.TASK_GETTASK, 0);
	Dbg:WriteLog("KinPlant", me.szName, "Login_ProcessSubPlayerPlantTask", "ClearKinPlantTaskFlag");
	return 1;
end

PlayerEvent:RegisterGlobal("OnLogin", KinPlant.Login_ProcessSubPlayerPlantTask, KinPlant);
ServerEvent:RegisterServerStartFunc(KinPlant.ServerStartFunc, KinPlant);
