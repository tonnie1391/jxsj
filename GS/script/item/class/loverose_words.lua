----------玫瑰
local tbLoveRoseWords = Item:GetClass("loverose_words");

tbLoveRoseWords.nRange			= 17;
tbLoveRoseWords.nGouHuoRange	= 15;
tbLoveRoseWords.nNpcLiveTime	= 8 * 60;
tbLoveRoseWords.nNpcTemplateId	= 9931;
tbLoveRoseWords.nSkillStateId	= 1979;
tbLoveRoseWords.nBaseMultip		= 150;
tbLoveRoseWords.tbTitle			= {6,100,1,0};
tbLoveRoseWords.nExpBufId		= 1623;
tbLoveRoseWords.nExpBufTime_Day	= 7 * 3600 * 24;
tbLoveRoseWords.tbNpcTemplateId = {9927,9928,9929,9930,9931};

function tbLoveRoseWords:IsNpcExist(nTemplateId)
	local nIsExist = 0;
	for _,nId in pairs(self.tbNpcTemplateId) do
		if nId == nTemplateId then
			nIsExist = 1;
			break;
		end
	end
	return nIsExist;
end

tbLoveRoseWords.szMainWords = "<color=green>%s<color>向<color=green>%s<color>送出了<color=pink>真爱永恒的花海<color>，并真情的说：";

tbLoveRoseWords.tbGBMsg =
{
	{"无尽的任务", "如果爱你是上天交给我的任务,我愿意这个任务是永久的，让我们一起组队去完成吧。"},
	{"相识的缘分", "与你相识是一种缘分，与你相恋是一种美好，与你相伴是一种幸福，我愿和你相伴到永远。"},
	{"每时和每刻", "每一天都为你心跳，每一刻都被你感动，每一秒都为你担心。剑侠世界里有你的感觉真好。"},
	{"来世和今生", "因为不知来生来世会不会遇到你，所以今生今世我会加倍爱你，让我们一起携手走完剑侠的一生吧。"},
	{"美丽的意外", "遇见你，是我最美丽的意外，是你的出现带给了我无限的快乐,愿你每一天都开心。"},
}

function tbLoveRoseWords:OnUse()
	local nRet ,szError = self:CheckCanUse(it.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	self:UseRose(it.dwId);
end

function tbLoveRoseWords:UseRose(nItemId)
	local tbMember = me.GetTeamMemberList();
	local szMyName = me.szName;
	local szMateName = (tbMember[1].szName ~= me.szName and tbMember[1].szName or tbMember[2].szName);
	local pItem = KItem.GetObjById(nItemId);
	local szMsg = string.format([[<color=red>LOVE花海，表达无穷无尽的爱意<color>。使用后向对方发出爱的宣言，漫天炫舞的玫瑰花瓣将一同见证你们的幸福和甜蜜！

使用后<color=red>男女双方<color>均获得浪漫称号<color=green>玫瑰花语<color>和<color=yellow>紫色玫瑰光环<color>，更有<color=yellow>打怪经验提高5%%<color>的增益状态，持续7天！

快快选择你对心爱的TA的表白语吧，更可邀约亲朋好友一起见证甜蜜时刻。
]]);
	local tbOpt = {};
	for nIndex, tbMsg in pairs(self.tbGBMsg) do
		tbOpt[#tbOpt + 1] = { string.format("<color=yellow>%s<color>", tbMsg[1]), self.OnChooseMsg, self, nIndex, nItemId, szMyName, szMateName};
	end
	tbOpt[#tbOpt + 1] = {"暂时不使用"};
	Dialog:Say(szMsg,tbOpt);
end

function tbLoveRoseWords:OnChooseMsg(nIndex,nItemId,szMyName,szMateName)
	local nRet ,szError = self:CheckCanUse(nItemId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	if not nIndex or not nItemId or not szMyName or not szMateName then
		return 0;
	end

	local szMsg = string.format([[你即将向心爱的<color=yellow>%s<color>表达你的玫瑰花语：
	
<color=green>%s<color>
]], szMateName, self.tbGBMsg[nIndex][2]);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"我要发出爱的宣言", self.SendMsg, self, nIndex, nItemId, szMyName, szMateName};
	tbOpt[#tbOpt + 1] = {"选择其他玫瑰花语", self.UseRose, self, nItemId};
	tbOpt[#tbOpt + 1] = {"暂不使用"};
	Dialog:Say(szMsg, tbOpt);
end

function tbLoveRoseWords:SendMsg(nIndex,nItemId,szMyName,szMateName)
	local nRet ,szError = self:CheckCanUse(nItemId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	if not nIndex or not nItemId or not szMyName or not szMateName then
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) == 1 then
		local szMsg = string.format(self.szMainWords .. self.tbGBMsg[nIndex][2], szMyName, szMateName);
		KDialog.NewsMsg(1,Env.NEWSMSG_MARRAY,szMsg);
	
		local nMapId,nX,nY = me.GetWorldPos();
		local pNpc = KNpc.Add2(self.nNpcTemplateId,1,-1,nMapId,nX,nY);
		if pNpc then
			pNpc.SetLiveTime(self.nNpcLiveTime * Env.GAME_FPS);
			local tbNpc	= Npc:GetClass("gouhuonpc");
			local nMapIdx		= SubWorldID2Idx(me.nMapId);
			tbNpc:InitGouHuo(pNpc.dwId, 1, self.nNpcLiveTime, 5, self.nGouHuoRange, self.nBaseMultip, 1, 1, self.nSkillStateId)
			tbNpc:SetTeamId(pNpc.dwId, me.nTeamId)
			tbNpc:StartNpcTimer(pNpc.dwId);				
		end
		
		local tbMember = me.GetTeamMemberList();
		for _, pPlayer in pairs(tbMember) do
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer, string.format("空气中弥散着玫瑰的旖旎芬芳，快邀请好朋友一起来分享幸福吧"));
				pPlayer.AddTitle(unpack(self.tbTitle));
				pPlayer.SetCurTitle(unpack(self.tbTitle));
				pPlayer.AddSkillState(self.nExpBufId, 1, 1, self.nExpBufTime_Day * Env.GAME_FPS, 1);
			end
		end
	else
		return 0;
	end 
end

function tbLoveRoseWords:CheckCanUse(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用错误！";
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then
		return 0,"该道具只能在城市、新手村使用。";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说玫瑰要送给心上人，需要甜蜜拍档<color=yellow>组队<color>才可以赠送！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"<color=yellow>必须两人队伍<color>，你的玫瑰才能赠送噢！";
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	for _, tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		return 0,"<color=yellow>你的队友离你太远了<color>，靠近一点，再靠近一点！";
	end
	local tbMember = me.GetTeamMemberList();
	local tbSex,nDiffSex = {},0;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
		end
	end
	if tbSex[1] and tbSex[2] then
		if tbSex[1] ~= tbSex[2] then
			nDiffSex = 1;
		end
	end
	if nDiffSex ~= 1 then
		return 0,"玫瑰只能送给<color=yellow>异性<color>哦！";
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,self.nRange);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or self:IsNpcExist(pNpc.nTemplateId) == 1 then
			return 0,"这里貌似太过拥挤了，还是换一个地方试试吧！";
		end
	end
	return 1;
end
