-- 文件名　：dragonboat.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-04 17:19:39
-- 描  述  ：
Esport.DragonBoat = Esport.DragonBoat or {};
local DragonBoat = Esport.DragonBoat;

--增加荣誉点
function DragonBoat:AddHonor(pPlayer, nHonor)
	if nHonor <= 0 then
		return
	end
	pPlayer.Msg(string.format("你获得了<color=yellow>%s点龙舟赛荣誉点<color>", nHonor));
	local nCurHonor = PlayerHonor:GetPlayerHonorByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_DRAGONBOAT, 0);
	PlayerHonor:SetPlayerHonorByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_DRAGONBOAT, 0, nCurHonor + nHonor)
end

function DragonBoat:CheckState()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate >= self.DEF_STATE[1] and nCurDate < self.DEF_STATE[2] then
		return 1;
	end
	return 0;
end

function DragonBoat:GetBoatRestGenId(nSel, pItem)
	local tbItem = Item:GetClass("dragonboat");
	return tbItem:GetGenId(nSel, pItem);
end

function DragonBoat:OnPlayerType1(nGroup, nPoint)
	self:OnPlayerBaseType1(1, nGroup, nPoint);
end

function DragonBoat:OnPlayerType2(nGroup, nPoint)
	local nMaxRandom = 0;
	for _, nR in pairs(self.SKILL_ITEM_RATE) do
		nMaxRandom = nMaxRandom + nR;
	end
	local nCurRate = MathRandom(1,nMaxRandom);
	local nSum = 0;
	local nCurType = 0;
	for nType, nR  in pairs(self.SKILL_ITEM_RATE) do
		nSum = nSum + nR;
		if nSum >= nCurRate then
			nCurType = nType;
			break;
		end
	end

	if nCurType == 1 then
		self:OnPlayerBaseType1(nCurType, nGroup, nPoint);
	elseif nCurType == 2 then
		self:OnPlayerBaseType2(nCurType, nGroup, nPoint);
	elseif nCurType == 4 then
		self:OnPlayerBaseType3(nCurType, nGroup, nPoint);
	end
end

function DragonBoat:OnPlayerType3(nGroup, nPoint)

	local tbMis = self:GetPlayerMission(me);
	local tbRankList = tbMis:GetRankList();
	local tbRate = {60,25,15}
	
	local nMaxRandom = 0;
	local nTempi = 1;
	for n in pairs(tbRankList) do
		if not tbRate[nTempi] then
			break;
		end
		nMaxRandom = nMaxRandom + tbRate[nTempi];
		nTempi = nTempi + 1;
	end
	
	local nCurRate = MathRandom(1, nMaxRandom);
	
	local nSum = 0;
	local nCurRank = 0;
	for nRank, nRate in pairs(tbRate) do
		nSum = nSum + nRate;
		if nSum >= nCurRate then
			nCurRank = nRank;
			break;
		end
	end
	local nGiveRank = 0;
	for ni = 1, 3 do
		if tbRankList[nCurRank] then
			nGiveRank = nCurRank;
			break;
		end
		nCurRank = nCurRank -1;
		if nCurRank <= 0 then
			break;
		end
	end
	if nGiveRank == 0 then
		me.Msg("赛道中已没有可遭受攻击的对手了！");
		Dialog:SendBlackBoardMsg(me, "赛道中已没有可遭受攻击的对手了！");
	else
		self:OnPlayerBaseType4(me, tbRankList[nGiveRank]);
	end
	tbMis:SkillItemClose(nGroup, nPoint);	
end

function DragonBoat:OnPlayerBaseType1(nType, nGroup, nPoint)
	local tbSkillItem = self.SKILL_ITEM_LIST[nType];
	for _, tbSkill in pairs(tbSkillItem) do
		if me.IsHaveSkill(tbSkill[1]) > 0 then
			me.DelFightSkill(tbSkill[1]);
		end
	end
	local tbSkill = tbSkillItem[MathRandom(1, #tbSkillItem)];
	local nLeftSKillId = FightSkill:GetLeftSkill(me);
	me.AddFightSkill(tbSkill[1], 1);
	if me.IsHaveSkill(nLeftSKillId) > 0 then
		FightSkill:SaveLeftSkillEx(me, nLeftSKillId);
	end
	FightSkill:SaveRightSkillEx(me, tbSkill[1]);
	local tbMis = self:GetPlayerMission(me);
	if not tbMis then
		return 0;
	end	
	tbMis:SkillItemClose(nGroup, nPoint);
	Dialog:SendBlackBoardMsg(me, string.format("你在河道中惊喜的发现了龙舟秘术%s！", KFightSkill.GetSkillName(tbSkill[1])));
	me.Msg(string.format("<color=blue>你在河道中惊喜的发现了龙舟秘术%s！<color>", KFightSkill.GetSkillName(tbSkill[1])));	
end

function DragonBoat:OnPlayerBaseType2(nType, nGroup, nPoint)
	local tbSkillItem = self.SKILL_ITEM_LIST[nType];
	local tbSkill = tbSkillItem[MathRandom(1, #tbSkillItem)];
	local nM, nX, nY=me.GetWorldPos();
	me.CastSkill(tbSkill[1], tbSkill[2], nX*32, nY*32);
	local tbMis = self:GetPlayerMission(me);
	if not tbMis then
		return 0;
	end		
	tbMis:SkillItemClose(nGroup, nPoint);
	Dialog:SendBlackBoardMsg(me, string.format("风云突变，你在河道中的龙舟遭受到秘术%s的干扰！", KFightSkill.GetSkillName(tbSkill[1])));
	me.Msg(string.format("<color=blue>风云突变，你在河道中的龙舟遭受到秘术%s的干扰！<color>", KFightSkill.GetSkillName(tbSkill[1])));	
end

--获得物品
function DragonBoat:OnPlayerBaseType3(nType, nGroup, nPoint)
	local tbSkillItem = self.SKILL_ITEM_LIST[nType];
	local tbItem = {};
	if self.SKILL_ITEM_GET_RATE[nType] then
		local nMaxRandom = 0;
		for _, nR in pairs(self.SKILL_ITEM_GET_RATE[nType]) do
			nMaxRandom = nMaxRandom + nR;
		end
		local nCurRate = MathRandom(1,nMaxRandom);
		local nSum = 0;
		local nCurType = 0;
		for nRateType, nR  in pairs(self.SKILL_ITEM_GET_RATE[nType]) do
			nSum = nSum + nR;
			if nSum >= nCurRate then
				nCurType = nRateType;
				break;
			end
		end
		tbItem = tbSkillItem[nCurType];
	else
		tbItem = tbSkillItem[MathRandom(1, #tbSkillItem)];
	end
	--趣味活动吃粽子只掉1-3玄
	if NewEPlatForm:GetMatchState() == NewEPlatForm.DEF_STATE_STAR then
		tbItem[4] = math.max(0, tbItem[4] - 3);
	end
	local nM, nX, nY=me.GetWorldPos();
	if me.CountFreeBagCell() < 1 then
		KItem.AddItemInPos(nM, nX, nY, tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
	else
		local pItem = me.AddItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
	end
	local tbMis = self:GetPlayerMission(me);
	if not tbMis then
		return 0;
	end		
	tbMis:SkillItemClose(nGroup, nPoint);
	local szItemName = KItem.GetNameById(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
	if szItemName then
		Dialog:SendBlackBoardMsg(me, string.format("你从河道中意外的打捞到%s！", szItemName));
		me.Msg(string.format("<color=blue>你从河道中意外的打捞到%s！<color>", szItemName));
	end
end

--天罚
function DragonBoat:OnPlayerBaseType4(pCastPlayer, tbPlayerInfo)
	local pPlayer = KPlayer.GetPlayerObjById(tbPlayerInfo.nId);
	if not pPlayer or not pCastPlayer then
		return 0;
	end
	local tbSkillItem = self.SKILL_ITEM_LIST[5];
	local tbSkill = tbSkillItem[MathRandom(1, #tbSkillItem)];
	local nM, nX, nY = pPlayer.GetWorldPos();
	pPlayer.CastSkill(tbSkill[1], tbSkill[2], nX*32, nY*32);
	
	if pCastPlayer.nId == pPlayer.nId then
		local szMsg = string.format("真倒霉，你遭受到了自己释放的天罚%s的攻击。", KFightSkill.GetSkillName(tbSkill[1]));
		pPlayer.Msg(string.format("<color=blue>%s<color>", szMsg));
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		return 0;
	end
	
	local szMsg1 = string.format("真可恶，你遭受到了%s释放的天罚攻击%s！", pCastPlayer.szName, KFightSkill.GetSkillName(tbSkill[1]));	
	local szMsg2 = string.format("嘿，你对%s释放的天罚攻击%s！", pPlayer.szName, KFightSkill.GetSkillName(tbSkill[1]));	
	Dialog:SendBlackBoardMsg(pPlayer, szMsg1);
	Dialog:SendBlackBoardMsg(pCastPlayer, szMsg2);
	pPlayer.Msg(string.format("<color=blue>%s<color>", szMsg1));
	pCastPlayer.Msg(string.format("<color=blue>%s<color>", szMsg2));
end

function DragonBoat:CheckSkill(pItem, nSkillId)
	for _, nGenId in pairs(self.GEN_SKILL_ATTACK) do
		if pItem.GetGenInfo(nGenId, 0) == nSkillId then
			return 1;
		end
	end
	for _, nGenId in pairs(self.GEN_SKILL_DEFEND) do
		if pItem.GetGenInfo(nGenId, 0) == nSkillId then
			return 1;
		end
	end
	return 0;
end

function DragonBoat:ClearAllSkill(pPlayer)
	for _, tbSkill in pairs(self.PRODUCT_BOAT) do
		local nSkillId = tbSkill[4][1];
		if pPlayer.GetSkillState(nSkillId) > 0 then
			pPlayer.RemoveSkillState(nSkillId);
		end
	end
	for _, tbSkills in pairs(self.PRODUCT_SKILL) do
		for _, tbSkill in pairs(tbSkills) do
			local nSkillId = tbSkill[1];
			if pPlayer.IsHaveSkill(nSkillId) > 0 then
				pPlayer.DelFightSkill(nSkillId);
			end
		end
	end
	
	for i=1, 2 do
		for _, tbSkill in pairs(self.SKILL_ITEM_LIST[i]) do
			local nSkillId = tbSkill[1];
			if pPlayer.IsHaveSkill(nSkillId) > 0 then
				pPlayer.DelFightSkill(nSkillId);
			end
		end
	end
end

function DragonBoat:IsAward(nRank)
	if self.AWARD_ITEM[nRank] then
		return 1;
	end
	return 0;
end

function DragonBoat:GetSingleGameAward(pPlayer, nRank)
	if not pPlayer then
		return 0;
	end
	if NewEPlatForm:GetMatchState() == NewEPlatForm.DEF_STATE_CLOSE then
		EPlatForm:GiveWeleeAwardToPlayer(pPlayer, nRank);
	else
		NewEPlatForm:GiveWeleeAwardToPlayer(pPlayer, nRank);
	end
end	

function DragonBoat:GetExChangeCount()
	local nDay = tonumber(GetLocalDate("%y%m%d"));
	local nTskDay = me.GetTask(self.TSK_GROUP, self.TSK_EXCHANGE_DAY);
	if nDay > nTskDay then
		me.SetTask(self.TSK_GROUP, self.TSK_EXCHANGE_COUNT, 0);
		me.SetTask(self.TSK_GROUP, self.TSK_EXCHANGE_DAY, nDay);
	end
	return me.GetTask(self.TSK_GROUP, self.TSK_EXCHANGE_COUNT);
end

function DragonBoat:AddExCount(nCount)
	local nExCount = me.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT_EX);
	return me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT_EX, nExCount + nCount);
end

function DragonBoat:CostCount(pPlayer)
	local nCount 	= pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT);
	local nCountEx  = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT_EX);
	if nCount > 0 then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT, (nCount-1));
		return 1;
	end
	if nCountEx > 0 then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT_EX, (nCountEx-1));
		return 1;
	end
	return 0;
end

function DragonBoat:LogOutRV()
	me.SetFightState(0);
	me.SetCurCamp(me.GetCamp());
	me.DisableChangeCurCamp(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	me.nForbidChangePK	= 0;
	me.SetDeathType(0);
	me.RestoreMana();
	me.RestoreLife();
	me.RestoreStamina();
	me.DisabledStall(0);	--摆摊
	if me.IsDisabledTeam() == 1 then
		me.TeamDisable(0);--禁止组队
	end	
	me.ForbitTrade(0);		--交易
	me.ForbidEnmity(0);
	me.ForbidExercise(0);
	self:ClearAllSkill(me);
end

function DragonBoat:LoadPosJiGuan()
	local tbFile = Lib:LoadTabFile("\\setting\\mission\\dragonboat\\pos_jiguan.txt");
	if not tbFile then
		return 0;
	end
	self.tbPosJiGuan = tbFile;
end

DragonBoat:LoadPosJiGuan();

function DragonBoat:LoadPosRandom()
	local szFile = string.format("\\setting\\mission\\dragonboat\\random.txt");
	local tbFile = Lib:LoadTabFile(szFile);
	if not tbFile then
		return 0;
	end
	self.tbPosRandom = {};
	for _, tbTrap in pairs(tbFile) do
		local szTrap = tbTrap.TRAP;
		local nPosX  = tbTrap.TRAPX;
		local nPosY  = tbTrap.TRAPY;
		local szGroup_Point = string.sub(szTrap, 7, -1);
		local tbG_P = Lib:SplitStr(szGroup_Point, "_");
		local nGroup = tonumber(tbG_P[1]);
		local nPoint = tonumber(tbG_P[2]);
		self.tbPosRandom[nGroup] = self.tbPosRandom[nGroup] or {};
		self.tbPosRandom[nGroup][nPoint] = {TRAPX=nPosX, TRAPY=nPosY};
	end
end

function DragonBoat:GetPlayerMission(pPlayer)
	if (not pPlayer) then
		return;
	end
	local tbTemp = pPlayer.GetTempTable("Esport");
	if (not tbTemp) then
		return;
	end
	
	if (not tbTemp.tbDragonBoatInfo) then
		return;
	end
	
	return tbTemp.tbDragonBoatInfo.tbMission;
end

DragonBoat:LoadPosRandom();

function DragonBoat:TaskDayEvent()
	if self:CheckState() == 0 then
		return 0;
	end
	local nNowDay 	=  Lib:GetLocalDay(GetTime())
	local nKeepDay  =  me.GetTask(self.TSK_GROUP, self.TSK_ATTEND_DAY);

	if me.nLevel < self.DEF_PLAYER_LEVEL or me.nFaction == 0 or me.GetCamp() == 0 then
		me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_DAY, (nNowDay - 1));
		me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT, 0);
		return 0;
	end

	if nKeepDay <= 0 then
		nKeepDay = Lib:GetLocalDay(Lib:GetDate2Time(self.DEF_STATE[1])) - 1;
	end
	
	if (nNowDay - nKeepDay) > 0 then
	local nCount = me.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT) + self.DEF_PLAYER_PRECOUNT * (nNowDay - nKeepDay);
		if nCount > self.DEF_PLAYER_MAXCOUNT then
			nCount = self.DEF_PLAYER_MAXCOUNT;
		end
		me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT, nCount);
		me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_DAY, nNowDay);
	end
end

if (MODULE_GAMESERVER) then
--玩家登陆执行后次数增加
-- PlayerEvent:RegisterOnLoginEvent(Esport.DragonBoat.TaskDayEvent, Esport.DragonBoat);
end
