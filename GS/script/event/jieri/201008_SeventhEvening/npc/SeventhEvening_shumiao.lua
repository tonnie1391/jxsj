-------------------------------------------------------
-- 文件名　：SeventhEvening_shumiao.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-07-23 10:50:50
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("QX_shumiao");
SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local tbSeventhEvening = SpecialEvent.SeventhEvening;

function tbNpc:OnDialog()
	
	local szMaleName = him.GetTempTable("SpecialEvent").szMaleName;
	local szFemaleName = him.GetTempTable("SpecialEvent").szFemaleName;
	if not szMaleName or not szFemaleName then
		return 0;
	end
	
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		Dialog:Say("请男女组队前来培育树苗。");
		return 0;
	end
	
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	if not pTeamMate or me.nSex == pTeamMate.nSex then
		Dialog:Say("请男女组队前来培育树苗。");
		return 0;
	end
	
	if me.szName ~= szMaleName and me.szName ~= szFemaleName
	or pTeamMate.szName ~= szMaleName and pTeamMate.szName ~= szFemaleName then
		Dialog:Say("对不起，这不是你们俩种下的树苗。");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请留出1格背包空间。");
		return 0;
	end
	
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
	
	GeneralProcess:StartProcess("培育中...", 1 * Env.GAME_FPS, {self.OnClick, self, him.dwId, me.szName}, nil, tbEvent);
end

function tbNpc:OnClick(nNpcId, szPlayerName)

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	
	local tbNpcData = pNpc.GetTempTable("SpecialEvent");
	if not tbNpcData.tbClickTime then
		tbNpcData.tbClickTime = {};
	end
	tbNpcData.tbClickTime[szPlayerName] = GetTime();
	
	if Lib:CountTB(tbNpcData.tbClickTime) < 2 then
		return 0;
	end
	
	local tbCalc = {};
	for szName, nTime in pairs(tbNpcData.tbClickTime) do
		table.insert(tbCalc, {szName = szName, nTime = nTime});
	end
	if math.abs(tbCalc[1].nTime - tbCalc[2].nTime) > 1 then
		local szMsg = "树苗需要二位在同一秒之内点击才能长成";
		for _, tbInfo in pairs(tbCalc) do
			local pPlayer = KPlayer.GetPlayerByName(tbInfo.szName);
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer, szMsg);
			end
		end
	else
		local pPlayer1 = KPlayer.GetPlayerByName(tbCalc[1].szName);
		local pPlayer2 = KPlayer.GetPlayerByName(tbCalc[2].szName);
		if pPlayer1 and pPlayer2 then
			local nMarryFlag = 0;
			if pPlayer1.IsMarried() == 1 and pPlayer2.IsMarried() == 1 and pPlayer1.GetCoupleName() == pPlayer2.szName then				
				nMarryFlag = 1;
			end
			local nMapId, nMapX, nMapY = pNpc.GetWorldPos();
			local nNpcId = (nMarryFlag == 1) and tbSeventhEvening.XIALVSHU_ID or tbSeventhEvening.TONGXINSHU_ID;
			local pAddNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, nMapX, nMapY);
			if pAddNpc then
				pAddNpc.GetTempTable("SpecialEvent").szMaleName = pNpc.GetTempTable("SpecialEvent").szMaleName;
				pAddNpc.GetTempTable("SpecialEvent").szFemaleName = pNpc.GetTempTable("SpecialEvent").szFemaleName;
				pNpc.Delete();
				Timer:Register(60 * 60 * Env.GAME_FPS, tbSeventhEvening.OnTimerDelNpc, tbSeventhEvening, pAddNpc.dwId);
				
				local nCount = KGblTask.SCGetDbTaskInt(DBTASD_QIXI_TONGXINSHU_COUNT) + 1;
				KGblTask.SCSetDbTaskInt(DBTASD_QIXI_TONGXINSHU_COUNT, nCount);
				if math.mod(nCount, 100) == 77 then
					self:SendSpecialAward(pPlayer1, nCount);
					self:SendSpecialAward(pPlayer2, nCount);
					Dialog:GlobalNewsMsg_GS(string.format("恭喜%s和%s种下第%s棵树，获得幸运奖励！",pPlayer1.szName, pPlayer2.szName, nCount));
				end
				
				if nMarryFlag == 1 then
					tbSeventhEvening:AddXialvPoint(pPlayer1, pPlayer2, 5);
				end
			end
		end
	end
end

function tbNpc:SendSpecialAward(pPlayer, nCount)
	if not pPlayer then
		return 0;
	end
	local szMsg = string.format("【恭喜你种下了今天同心园内第%s棵同心树，额外获得丰厚奖励】", nCount);
	pPlayer.Msg(szMsg);
	Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	if pPlayer.nSex == 0 then
		pPlayer.AddItem(unpack(tbSeventhEvening.tbSpecailMaleId));
	elseif pPlayer.nSex == 1 then
		pPlayer.AddItem(unpack(tbSeventhEvening.tbSpecailFemaleId));
	end
end
