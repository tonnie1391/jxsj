-- 文件名　：dts_award.lua
-- 创建者　：zounan1@kingsoft.com
-- 创建时间：2009-11-10 17:18:26
-- 描  述  ：大逃杀奖励

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\dataosha\\dts_def.lua");
function DaTaoSha:GetAward(pPlayer, nRound)
	local pItem = pPlayer.AddItem(unpack(DaTaoSha.AWARD_ROUND[nRound].tbItem));
	if pItem then
		pItem.Bind(1);
	end
	local nValue = GetPlayerSportTask(pPlayer.nId, DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTSK_AWARD) or 0;	
	pPlayer.SetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_AWARD, nValue);
end	

function DaTaoSha:GetCampAward(pPlayer, nType)
	if not DaTaoSha.AWARD_REPUTE[nType] then	
		return;
	end
	local nCampId = DaTaoSha.AWARD_REPUTE[nType].nCampId;
	local nClassId = DaTaoSha.AWARD_REPUTE[nType].nClassId;
	local nLevel = pPlayer.GetReputeLevel(nCampId, nClassId);
	if not nLevel then		
		return;
	end
	
	pPlayer.Earn(DaTaoSha.AWARD_MONEY, 0);

	if not DaTaoSha.AWARD_REPUTE[nType].tbRepute[nLevel] then
		pPlayer.Msg(string.format("您的%s活动声望已达最高级", DaTaoSha.AWARD_REPUTE[nType].szName));
		return;
	end
	local nAwardLevel = DaTaoSha.AWARD_REPUTE[nType].nLevel;  -- 默认升到的等级如果已达到该等级则升到下一级
	local nAwardValue = DaTaoSha.AWARD_REPUTE[nType].tbRepute[nLevel] - pPlayer.GetReputeValue(nCampId, nClassId);
	for i = nLevel + 1, nAwardLevel - 1 do 
		nAwardValue = nAwardValue + DaTaoSha.AWARD_REPUTE[nType].tbRepute[i];
	end
	pPlayer.AddRepute(nCampId, nClassId, nAwardValue);
end	

function DaTaoSha:GetAwardForMe(nSure)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate > DaTaoSha.DEF_GLOBALAWARD_DATE_END then
		Dialog:Say("领奖已经截止了。");
		return;
	end
	
	nSure = nSure or 0;
	local nPlayerCount = me.CountFreeBagCell();
	local nIsNoAward  = 1;
	local tbAwardItem = {};
	local nExaItem	  = nil;	
	local tbAwardList = {};
	for nAwardType , tbInfo in ipairs(self.DEF_AWARD_ITEMLIST) do
		local nAwardTimes = self:GetAwardTimes(me, nAwardType);
		if nAwardTimes > 0 then
			for i = 1, nAwardTimes do
				nIsNoAward = 0;		
				tbAwardItem[tbInfo.tbId] = (tbAwardItem[tbInfo.tbId] or 0 ) + tbInfo.nCount;
			end
		else
			tbAwardItem[tbInfo.tbId] = tbAwardItem[tbInfo.tbId] or 0;
		end
		table.insert(tbAwardList, nAwardTimes);
	end
	
	if nIsNoAward == 1 then
		Dialog:Say("您没有任何奖励可以领取，请参与探寻寒武遗迹获得奖励！");
		return;
	end
	
	local szMsg = string.format("您在探索寒武遗迹活动中累计获得奖励如下：（请于%s23:59:59前领取您的所有奖励）\n", os.date("%Y年%m月%d日",Lib:GetDate2Time(DaTaoSha.DEF_GLOBALAWARD_DATE_END)));
	local nNeedCount = 0;
	for nId, nCount in pairs(tbAwardItem) do
		if nCount > 0 then
			szMsg = szMsg.. (string.format("<color=yellow>%s %d个<color> \n",DaTaoSha.DEF_AWARD_ITEM[nId].szName,nCount));
			local tbItemId = DaTaoSha.DEF_AWARD_ITEM[nId].tbItemId;
			nNeedCount = nNeedCount + KItem.GetNeedFreeBag(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], nil, nCount);	
		end
	end
	szMsg = szMsg .. "确定领取吗?";
	
	if nSure == 0 then
		Dialog:Say(szMsg , {{"我要领取",self.GetAwardForMe,self,1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	
	if nPlayerCount < nNeedCount then
		Dialog:Say(string.format("Hành trang không đủ ,至少需要%d格背包空间。",nNeedCount));
		return;
	end	
	
	local szMsgAward = "";
	-- 先清 后领
	self:ClearLocalAwardTimes(me);
	local nAwardCount = 1;
	for nId, nCount in pairs(tbAwardItem) do
		if nCount > 0 then
			local tbItem = DaTaoSha.DEF_AWARD_ITEM[nId];
			me.AddStackItem(tbItem.tbItemId[1], tbItem.tbItemId[2], tbItem.tbItemId[3], tbItem.tbItemId[4], {bForceBind = tbItem.bBind or 0,}, nCount);
		end
		if nAwardCount < 3 then
			szMsgAward = szMsgAward..nCount..",";
		else
			szMsgAward = szMsgAward..nCount;
		end
		nAwardCount = nAwardCount + 1;
	end	
	
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[寒武遗迹]1阶段%s次，2阶段%s次，3阶段%s次，冠军%s次，冠军额外奖励%s次, 领取%s瓷瓶，%s宝瓶，%s雪魂令", 
		tbAwardList[1],tbAwardList[2], tbAwardList[3],tbAwardList[4],tbAwardList[5], tbAwardItem[1], tbAwardItem[2], tbAwardItem[3]));
	StatLog:WriteStatLog("stat_info", "dataosha", "output", me.nId, szMsgAward);
	--Dbg:WriteLogEx(1, "dataosha", "output", me.szAccount, me.szName, szMsgAward);
end

function DaTaoSha:GetGlobalAwardForMe(nSure)
	nSure = nSure or 0;
	local nCurRank = 0;
	
	if self:CheckFinalAwardDate() == 0 then
		Dialog:Say("领奖已经截止了。");
		return;
	end
	
	if me.GetTask(self.TASKID_GROUP,self.TASKID_GLOBAL_AWARD) == 1 then
		Dialog:Say("你已经领取过这份奖励了，不能重复领取。");
		return;
	end	
	
	
	local nType, nRank   = self:GetTotalRankTye();
	if nType == 0 then
		Dialog:Say("您没有任何奖励可以领取。");
		return;
	end
	if nSure == 0 then
		Dialog:Say(string.format("恭喜您在本次大逃杀活动中获得%d的排名，确定领取奖励吗？",nRank) , {{"我要领取",self.GetGlobalAwardForMe,self,1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	
	local tbItemInfo = DaTaoSha.DEF_GLOBAL_AWARD_TYPE[nType].tbItem;
	local tbItem = DaTaoSha.DEF_AWARD_ITEM[tbItemInfo.tbId];	
	
	--[1] = {nRank = 1, tbItem = {tbId = 3, nCount = 60,}};			
	local nNeedCount = KItem.GetNeedFreeBag(tbItem.tbItemId[1], tbItem.tbItemId[2], tbItem.tbItemId[3], tbItem.tbItemId[4], nil, tbItemInfo.nCount);
	local nPlayerCount = me.CountFreeBagCell();
	if nRank <= 10 then
		nNeedCount = nNeedCount + 1;
	end
	if nPlayerCount < nNeedCount then
		Dialog:Say(string.format("Hành trang không đủ ,至少需要%d格背包空间。",nNeedCount));
		return;
	end	
	me.SetTask(self.TASKID_GROUP,self.TASKID_GLOBAL_AWARD, 1);
	me.AddStackItem(tbItem.tbItemId[1], tbItem.tbItemId[2], tbItem.tbItemId[3], tbItem.tbItemId[4], {bForceBind = tbItem.bBind or 0,}, tbItemInfo.nCount);		
	--前十名有坐骑
	if (IVER_g_nTwVersion == 0 and IVER_g_nSdoVersion == 0) then
		if nRank <= 10 then
			local pItem = me.AddItem(unpack(self.AWARD_HORSE));
			if pItem then
				pItem.SetTimeOut(0, GetTime() + 90 * 24 * 3600);
				pItem.Sync();
			end
		end
	end
	StatLog:WriteStatLog("stat_info", "dataosha", "award", me.nId, nRank);
	--Dbg:WriteLogEx(1, "dataosha", "award", me.szAccount, me.szName, nRank);
end

function DaTaoSha:GetTotalRankTye()
	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_LADDER1, 0);
	if nHonorRank <= 0 then
		return 0;
	end
	
	for nRank, tbInfo in ipairs(self.DEF_GLOBAL_AWARD_TYPE) do
		if nHonorRank <= tbInfo.nRank then
			return nRank, nHonorRank;
		end
	end
	return 0;
end

function DaTaoSha:CheckFinalAwardDate()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < DaTaoSha.DEF_GLOBALAWARD_DATE_BEGIN then
		return 0;
	end
	
	if nCurDate > DaTaoSha.DEF_GLOBALAWARD_DATE_END	then
		return 0;
	end
	return 1;
end

function DaTaoSha:GetAwardTimes(pPlayer, nAwardType)
	local nGlobalId  = DaTaoSha.DEF_AWARD_TSK[nAwardType].nGlobal;
	local nLocalId   = DaTaoSha.DEF_AWARD_TSK[nAwardType].nLocal;
	local nGlobalRes = GetPlayerSportTask(pPlayer.nId, DaTaoSha.GBTSKG_DATAOSHA, nGlobalId) or 0;
	local nGlobalBatch = GetPlayerSportTask(me.nId,self.GBTSKG_DATAOSHA, self.GBTASKID_BATCH) or 0;	
	if nGlobalBatch ~= self.nBatch then
		return 0;
	end
	return nGlobalRes - pPlayer.GetTask(DaTaoSha.TASKID_GROUP, nLocalId);	
end

function DaTaoSha:ClearLocalAwardTimes(pPlayer)
	local nGlobalId  = nil;
	local nLocalId   = nil;
	local nGlobalRes = nil;	
	for nAwardType, tbInfo	in ipairs(DaTaoSha.DEF_AWARD_TSK) do
		nGlobalId  = DaTaoSha.DEF_AWARD_TSK[nAwardType].nGlobal;
		nLocalId   = DaTaoSha.DEF_AWARD_TSK[nAwardType].nLocal;
		nGlobalRes = GetPlayerSportTask(pPlayer.nId, DaTaoSha.GBTSKG_DATAOSHA, nGlobalId) or 0;
		pPlayer.SetTask(DaTaoSha.TASKID_GROUP, nLocalId,nGlobalRes);	
	end	
end

function DaTaoSha:AddLocalAwardTimes(pPlayer, nAwardType)
	local nGlobalId  = DaTaoSha.DEF_AWARD_TSK[nAwardType].nGlobal;
	local nLocalId   = DaTaoSha.DEF_AWARD_TSK[nAwardType].nLocal;
	local nGlobalRes = GetPlayerSportTask(pPlayer.nId, DaTaoSha.GBTSKG_DATAOSHA, nGlobalId) or 0;
	local nCurTimes  = pPlayer.GetTask(DaTaoSha.TASKID_GROUP, nLocalId);	
	pPlayer.SetTask(DaTaoSha.TASKID_GROUP, nLocalId,nCurTimes + 1);	
end

