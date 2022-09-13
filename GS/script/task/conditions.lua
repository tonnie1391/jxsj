function TaskCond:IsFinished(nTaskId, nTaskIdx)
	if (Task:GetFinishedIdx(nTaskId) >= nTaskIdx) then
		return 1
	end
	local szFailDesc = "";
	szFailDesc = "还未完成 "..self.tbReferDatas[nTaskIdx].szName;
	return nil, szFailDesc;
end

function TaskCond:IsLevelAE(nLevel)
	if (me.nLevel >= nLevel) then
		return 1
	end
	local szFailDesc = "";
	szFailDesc = "等级尚未达到 "..nLevel.." 级";
	return nil, szFailDesc;
end

function TaskCond:IsLevelMax(nLevel)
	if (me.nLevel <= nLevel) then
		return 1;
	end
	local szFailDesc = "";
	szFailDesc = "等级已经超过" .. nLevel .. " 级";
	return nil, szFailDesc;
end

-- 注意可以有门派无关，无门无派是0
function TaskCond:IsFaction(nFaction)
	if (me.nFaction == nFaction) then
		return 1
	end
	return nil, "门派不符合要求"
end

function TaskCond:NotThisFaction(nFaction)
	if (me.nFaction ~= nFaction) then
		return 1;
	end
	
	return nil, "门派不符合要求";
end

function TaskCond:IsFactionMember(szFailDesc)
	if (me.nFaction > 0) then
		return 1;
	end
	return nil, szFailDesc;
end

function TaskCond:HaveMoney(nValue)
	if (me.nCashMoney >= nValue) then
		return 1
	end
	local szFailDesc = "";
	szFailDesc = "现金不足"..nValue;
	return nil, szFailDesc;
end

function TaskCond:HaveSkill(nSkillId)
	if (me.GetSkillLevel(nSkillId) >= 0) then
		return 1
	end
	return nil, "技能尚未达到要求"
end

function TaskCond:IsPkAE(nValue)
	if (me.nPKValue >= nValue) then
		return 1;
	end
	local szFailDesc = "";
	szFailDesc = "恶名值未到 "..nValue;
	return nil, szFailDesc;
end

function TaskCond:IsAtPos(nMapId, nPosX, nPosY, nR)
	local nMyMapId, nMyPosX, nMyPosY	= me.GetWorldPos();
	if (nMapId == nMyMapId or nMapId == 0) then
		if (nPosX == 0) then
			return 1;
		else
			local nMyR	= ((nPosX-nMyPosX)^2 + (nPosY-nMyPosY)^2)^0.5;
			if (nMyR < nR) then
				return 1;
			end;
		end;
	end;
	return nil, "未到达指定位置";
end;

function TaskCond:IsNpcAtPos(nNpcId, nMapId, nPosX, nPosY, nR)
	if (nNpcId and nNpcId > 0) then
		local pNpc = KNpc.GetById(nNpcId);
		local nHimMapId, nHimPosX, nHimPosY  = pNpc.GetWorldPos();
		if (nHimMapId == nMapId) then
			if (nPosX == 0) then
				return 1;
			else
				local nMyR	= ((nPosX-nHimPosX)^2 + (nPosY-nHimPosY)^2)^0.5;
				if (nMyR < nR) then
					return 1;
				end;
			end;
		end
	else
		return nil, "没有指定Npc";
	end
	
	return nil, "Npc未到达指定位置";
end;

function TaskCond:IsReputeAE(nCamp, nClass, nLevel, nValue)
	local nMyLevel	= me.GetReputeLevel(nCamp, nClass);
	local nMyValue	= me.GetReputeValue(nCamp, nClass);
	if (nMyLevel and nMyValue) then
		if (nMyLevel > nLevel) then
			return 1;
		elseif (nMyLevel == nLevel and nMyValue >= nValue) then
			return 1;
		end;
	end;
	return nil, "声望尚未达到要求";
end;

function TaskCond:HaveTitleAE(byTitleGenre, byTitleDetailType, byTitleLevel)
	local tbTitles	= me.GetAllTitle(nCamp, nClass);
	for _, tbTitle in ipairs(tbTitles) do
		if (tbTitle.byTitleGenre == byTitleGenre and
			tbTitle.byTitleDetailType == byTitleDetailType and
			tbTitle.byTitleLevel >= byTitleLevel) then
			return 1;
		end;
	end;
	return nil, "称号尚未达到要求";
end;


function TaskCond:HaveTitle(byTitleGenre, byTitleDetailType, byTitleLevel, dwTitleParam)
	local tbTitles	= me.GetAllTitle(nCamp, nClass);
	for _, tbTitle in ipairs(tbTitles) do
		if (tbTitle.byTitleGenre == byTitleGenre and
			tbTitle.byTitleDetailType == byTitleDetailType and
			tbTitle.byTitleLevel == byTitleLevel and
			tbTitle.dwTitleParam == dwTitleParam) then
			return 1;
		end;
	end;
	return nil, "称号尚未达到要求";
end;


function TaskCond:HaveBagSpace(nNeedSpace)
	local nFreeCell = me.CountFreeBagCell();
	if (not nNeedSpace) then
		nNeedSpace = 1;
	end
	if (nFreeCell >= nNeedSpace) then
		return 1;
	end
	
	return nil, "包裹空间不够";
end;


function TaskCond:IsRefFinished(nRefSubId)
	local tbNeedReferData = Task.tbReferDatas[nRefSubId];	-- 需要判断的引用子任务数据
	local nNeedRefIdx = tbNeedReferData.nReferIdx; 			-- 需要完成的引用子任务索引号
	local nTaskId	  	= tbNeedReferData.nTaskId;				-- 此子任务所属的任务
	
	
	local nCurReferId = Task:GetFinishedRefer(nTaskId)
	if (nCurReferId > 0) then
		local nCurRefIdx = Task.tbReferDatas[nCurReferId].nReferIdx;	
		if (nCurRefIdx >= nNeedRefIdx) then
			return 1;
		end
	end
	
	return nil, "没完成指定的任务";
end;

function TaskCond:NeedSex(nNeedMale)
	if (me.nSex == nNeedMale) then
		return 1;
	end

	return nil, "性别不符要求";
end;

function TaskCond:HasBlueEquip()
	for i = 0, Item.EQUIPPOS_NUM do
		pItem = me.GetEquip(i);
		if (pItem) then
			if (pItem.nGenre == Item.EQUIP_GENERAL) and (pItem.IsWhite() ~= 1) then
				return 1;
			end
		end
	end
	
	return nil, "您身上没有蓝色装备";
end

function TaskCond:HaveItem(tbItem)
	if (Task:GetItemCount(me, tbItem) >= 1) then
		return 1;
	end
	
	return nil, "您身上没有此物品";
end

function TaskCond:HaveBitItem(tbItem, nCount)	
	assert(nCount >= 1);
	if (Task:GetItemCount(me, tbItem) >= nCount) then
		return 1;
	end
	local szItemName = KItem.GetNameById(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
	
	return nil, "您身上没有"..nCount.."个"..szItemName;
end

-- 判断玩家身上有指定道具
function TaskCond:UsingMask(nMaskId, nLevel)
	local pItem = me.GetEquip(Item.EQUIPPOS_MASK)
	
	if (pItem and pItem.nLevel >= nLevel and pItem.nParticular == nMaskId) then
		return 1;
	end
		
	return nil, "您没有装备指定面具！";
end


function TaskCond:RequireTaskValue(nGroupId, nTaskId, nValue, szDesc)
	assert(nGroupId > 0 and nTaskId > 0);
	
	--防沉迷, 不健康时间不能领取任务
	if (me.GetTiredDegree() == 2) then
		return 0;
	end
	
	if (me.GetTask(nGroupId, nTaskId) == nValue) then
		return 1;
	end
	
	return nil, szDesc;
end

function TaskCond:HaveRoute(szDesc)
	if (me.nRouteId > 0) then
		return 1;
	end
	
	return nil, szDesc;
end

function TaskCond:CanAddCountItemIntoBag(tbItem, nCount)
	if (nCount <= 0) then
		return 1;
	end
	
	local tbItems = {};	
	for i = 1, nCount do
		tbItems[#tbItems + 1] = tbItem;
	end
	
	return self:CanAddItemsIntoBag(tbItems);
end


function TaskCond:CanAddItemsIntoBag(tbItems)

	local tbDesItems = {};

	for _, tbItem in ipairs(tbItems) do
		local tbBaseProp = KItem.GetItemBaseProp(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
		if tbBaseProp then
			local tbDes =
			{
				nGenre		= tbItem[1],
				nDetail		= tbItem[2],
				nParticular	= tbItem[3],
				nLevel		= tbItem[4],
				nSeries		= (tbBaseProp.nSeries > 0) and tbBaseProp.nSeries or tbItem[5],
				bBind		= KItem.IsItemBindByBindType(tbBaseProp.nBindType),
				nCount 		= 1;
			};
			table.insert(tbDesItems, tbDes);
		end
	end

	if (me.CanAddItemIntoBag(unpack(tbDesItems)) == 1) then
			return 1;
	end
		
	return nil, "包裹空间不够，无法获得物品！";

end

function TaskCond:IsKinReputeAE(nRepute)
	if MODULE_GAMECLIENT then
		return 1;
	end
	local szFailDesc = "";
	if (me.nPrestige >= nRepute) then
		return 1
	end
	
	szFailDesc = "江湖威望尚未达到 "..nRepute.." 点";
	return nil, szFailDesc;
end

function TaskCond:TaskValueLessThen(nGroupId, nTaskId, nTaskValue, szErrorDesc)
	if (me.GetTask(nGroupId, nTaskId, nTaskValue) < nTaskValue) then
		return 1;
	end
	
	return nil, szErrorDesc;
end


function TaskCond:RequireTaskValueBit(nGroupId, nTaskId, nBitNum, bBit, szErrorDesc)
	local nValue = me.GetTask(nGroupId, nTaskId);
	assert(nBitNum <= 16 and nBitNum >= 1);
	
	local nBit = KLib.GetBit(nValue, nBitNum);
	if ((nBit == 1 and bBit) or (nBit == 0) and not bBit) then
		return 1;
	end
	
	return nil, szErrorDesc;
end

function TaskCond:RequireTime(nStartTime, nEndTime, szErrorDesc)
	local nDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nStartTime <= nDate and nDate <= nEndTime) then
		return 1;
	end;
	return nil, szErrorDesc;
end;

function TaskCond:HaveTeacher(szErrorDesc)
	if not MODULE_GAMESERVER then
		local tbTrain = me.Relation_GetTrainingRelation();
		if tbTrain then
			for _, tbInfo in pairs(tbTrain) do
				if (tbInfo.nRole == 1 and tbInfo.nLevel > me.nLevel) then
					return 1;
				end;
			end;
		end
		return nil, szErrorDesc; 
	else 
		-- nType 用来表示已经出师和未出师都要得到
		local nType = Player.emKPLAYERRELATION_TYPE_TRAINING + Player.emKPLAYERRELATION_TYPE_TRAINED;
		local pszTeacher = me.GetTrainingTeacher(nType);
		if (pszTeacher == nil) then
			return nil, szErrorDesc; 
		end
		local tbInfo = GetPlayerInfoForLadderGC(pszTeacher);
		if (not tbInfo or not tbInfo.nLevel or tbInfo.nLevel <= me.nLevel) then
			return nil, szErrorDesc;
		end
		local tbTrainStudentList = me.GetTrainingStudentList();
		if (tbTrainStudentList) then
			return nil, szErrorDesc;
		end;
		return 1;
	end;
end;

function TaskCond:RequirRepute(nValue, szErrorDesc)
	if (me.nPrestige < nValue) then
		return nil, szErrorDesc;
	end;
	return 1;
end;

function TaskCond:RequirScript(varFunc, nTure, szErrorDesc)
	local nArgS, nArgE = string.find(varFunc, "%(.*%)");
	local tbArg = {};
	if nArgS and nArgS > 0 then
		local szArg = string.sub(varFunc, nArgS + 1, nArgE - 1);
		varFunc = string.sub(varFunc, 1, nArgS-1);
		tbArg = Lib:SplitStr(szArg, ",");
		for i, varArg in ipairs(tbArg) do
			if tonumber(varArg) then
				tbArg[i] = tonumber(varArg);
			end
		end
	end
	
	local fnFunc, tbSelf	= KLib.GetValByStr(varFunc);
	if not fnFunc then
		return 1;
	end
	local nRet, szMsg = fnFunc(tbSelf, unpack(tbArg));
	if tonumber(nRet) == tonumber(nTure) then
		return 1
	end
	return nil, szMsg;
end;

function TaskCond:IsKinRegularMember()
	local nKinId = me.dwKinId;
	if (nKinId and nKinId > 0) then
		local cKin = KKin.GetKin(nKinId);
		if (cKin) then
			local _, nMemberId = self.GetKinMember();
			local cMember = cKin.GetMember(nMemberId);
			if (cMember) then
				local nFigure = cMember.GetFigure();
				if (nFigure == Kin.FIGURE_CAPTAIN or
					nFigure == Kin.FIGURE_ASSISTANT or
					nFigure == Kin.FIGURE_REGULAR ) then
					return 1;
				end
			end
		end
	end
	return nil, "家族不符合"
end

-- 是否和另一个异性组队
function TaskCond:IsInTeamWithOtherSex()
	if (MODULE_GAMESERVER) then
		local tblMemberList, nMemberCount = me.GetTeamMemberList()
		if (2 ~= nMemberCount) then
			return nil, "队伍只能有两个人";
		end
		if (tblMemberList[1].nSex == tblMemberList[2].nSex) then
			return nil, "性别相同";
		end
		return 1;
	elseif (MODULE_GAMECLIENT) then
		local tbInfo = me.GetTeamMemberInfo();
		if (1 ~= #tbInfo) then
			return nil, "队伍只能有两个人";
		end
		if (tbInfo[1].nSex == me.nSex) then
			return nil, "性别相同";
		end
		return 1;
	end
	return nil, "";
end

-- 真元变量是否打开
function TaskCond:IsZhenYuanOpen()
	if (Item.tbZhenYuan.bOpen == 0) then
		return nil, "";
	end
	return 1;
end

-- 是否达到126时间轴
function TaskCond:RequireTimeFrame_126()
	-- if TimeFrame:GetServerOpenDay() >= 126 then
		return 1;
	-- end
	-- return nil, "服务器开服未满126天";
end

-- 是否达到119天时间轴
function TaskCond:RequireTimeFrame_119()
	-- if TimeFrame:GetServerOpenDay() >= 119 then
		return 1;
	-- end
	-- return nil, "服务器开服未满119天";
end
