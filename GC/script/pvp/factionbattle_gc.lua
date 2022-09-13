-------------------------------------------------------------------
--File: 	factionbattle.lua
--Author: 	zhengyuhua
--Date: 	2008-1-8 17:38
--Describe:	门派战--gamecenter端脚本
-------------------------------------------------------------------

-- 开启活动
function FactionBattle:StartFactionBattle()
	local nWeek = tonumber(GetLocalDate("%w"));
	if (EventManager.IVER_bOpenTiFu ~= 1) then
		if nWeek ~= self.OPEN_WEEK_DATE[1] and nWeek ~= self.OPEN_WEEK_DATE[2] then
			return;
		end
	end
	
	-- 是否开启新模式
	local nModel = FactionBattle._MODEL_OLD;
	if EventManager.IVER_bOpenFactionBattleNew == 1 then
		local b150 = TimeFrame:GetState("OpenLevel150");
		if (1 == IVER_g_nSdoVersion) then
			nModel = FactionBattle._MODEL_NEW;
		else
			if nWeek == self.OPEN_WEEK_DATE[2] and b150 == 1 then
				nModel = FactionBattle._MODEL_NEW;
			elseif nWeek == self.OPEN_WEEK_DATE[1] and b150 == 1 then
				nModel = FactionBattle._MODEL_96_DAY_WEEK_2;
			end
		end
	end
	self:StartFactionBattle_Detail(nModel);
end

function FactionBattle:StartFactionBattle_Detail(nModel)
	assert(nModel == FactionBattle._MODEL_NEW or nModel == FactionBattle._MODEL_OLD or nModel == FactionBattle._MODEL_96_DAY_WEEK_2);
	
	local nCurId = GetFactionBattleCurId();	-- 设置本届比赛的届数
	nCurId = nCurId + 1;
	SetFactionBattleCurId(nCurId)
	
	self:SetDefByMode(nModel);			-- 设置模式一些相关细节定义
	GlobalExcute{"FactionBattle:StartFactionBattle_GS", nModel};
	self:InitFactionNewsTable();
end

function FactionBattle:EndBattle_GC(nFaction)
	GlobalExcute{"FactionBattle:EndBattle_GS2", nFaction};
end

-- 记录活动结果
function FactionBattle:FinalWinner_GC(nFaction, nPlayerId)
	--联赛开启后，关闭门派竞技新人王显示，关闭门派大师兄候选人资格。
	if Wlls:GetMacthSession() <= 0 then
		-- by zhangjinpin@kingsoft
		local bFind = 0;
		local tbList = GetCurCandidate(nFaction);
		for _, tbRow in pairs(tbList or {}) do
			if tbRow.nPlayerId == nPlayerId then
				bFind = 1;
				break;
			end	
		end
		if bFind == 0 then
			KGCPlayer.SetPlayerPrestige(nPlayerId, KGCPlayer.GetPlayerPrestige(nPlayerId) + 100);
			Dbg:WriteLog("FactionBattle", "门派大师兄候选人", KGCPlayer.GetPlayerName(nPlayerId), "增加江湖威望100点");
		end
		-- end
		SetCurCandidate(nFaction, nPlayerId);
	end
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	self:RecNewsForNewsMan(nFaction, szName);
end

function FactionBattle:InitFactionNewsTable()
	
	-- 门派名TODO：这样的方式不好，需要人工维护
	self.MENPAINAME = {
			[Env.FACTION_ID_SHAOLIN]		= "Thiếu Lâm";
			[Env.FACTION_ID_TIANWANG]		= "Thiên Vương";
			[Env.FACTION_ID_TANGMEN]		= "Đường Môn";
			[Env.FACTION_ID_WUDU]			= "Ngũ Độc";
			[Env.FACTION_ID_EMEI]			= "Nga Mi";
			[Env.FACTION_ID_CUIYAN]			= "Thúy Yên";
			[Env.FACTION_ID_GAIBANG]		= "Cái Bang";
			[Env.FACTION_ID_TIANREN]		= "Thiên Nhẫn";
			[Env.FACTION_ID_WUDANG]			= "Võ Đang";
			[Env.FACTION_ID_KUNLUN]			= "Côn Lôn";
			[Env.FACTION_ID_MINGJIAO]		= "Minh Giáo";
			[Env.FACTION_ID_DALIDUANSHI]	= "Đoàn Thị";
			[Env.FACTION_ID_GUMU]			= "Cổ Mộ";
	};
	self.tbMenPaiNew = {};
	local tbNewsInfo = {};
	tbNewsInfo.nKey		= Task.tbHelp.NEWSKEYID.NEWS_MENPAI_NEW;
	tbNewsInfo.szTitle	= "Tân Thập Tam Đại Phái Tân Nhân Vương";
	tbNewsInfo.nAddTime = GetTime();
	tbNewsInfo.nEndTime = tbNewsInfo.nAddTime + 3600 * 48;
	tbNewsInfo.szMsg	= "";
	self.tbNewsInfo = tbNewsInfo;

	for i=1, Env.FACTION_NUM do
		local tbInfo = {};
		tbInfo.szName	= "Chưa có";
		tbInfo.nLevel	= 0;
		tbInfo.szKin	= "Vô Tộc";
		tbInfo.szTong	= "Vô Bang";
		tbInfo.nSex		= 0;
		self.tbMenPaiNew[i] = tbInfo;
	end
	self:WriteNewsLog("InitFactionNewsTable", "Init Vote News Msg Successed");
end

-- 获取门派新人王消息信息
function FactionBattle:RecNewsForNewsMan(nFaction, szName)
	self:WriteNewsLog("RecNewsForNewsMan", nFaction, szName);
	if (nFaction <= 0) then
		return;
	end
	local szMsg = self:GetMenPaiNewsMsg(nFaction, szName);
	self:WriteNewsLog("新人王消息", szMsg);
	local tbSendInfo = self.tbNewsInfo;
	Task.tbHelp:AddDNews(tbSendInfo.nKey, tbSendInfo.szTitle, szMsg, tbSendInfo.nEndTime, tbSendInfo.nAddTime);
end

-- 获取门派新人王消息
function FactionBattle:GetMenPaiNewsMsg(nFaction, szName)
	self:ProcessPlayerInfo(nFaction, szName, self.tbMenPaiNew);
	local szMsg = "";
	for i=1, Env.FACTION_NUM do
		local tbInfo = self.tbMenPaiNew[i];
		local szOneMsg = string.format("<color=yellow>%s<color> Tân Nhân Vương\n    Tên: <color=yellow>%s<color>\n    Cấp độ: <color=green>%d<color>\n    Gia tộc: <color=pink>%s<color>\n    Bang hội: <color=pink>%s<color>\n\n", self.MENPAINAME[i], tbInfo.szName, tbInfo.nLevel, tbInfo.szKin, tbInfo.szTong);
		szMsg = szMsg .. szOneMsg;
	end
	return szMsg;
end

function FactionBattle:ProcessPlayerInfo(nFaction, szName, tbMenPai)
	local tbPlayerInfo = GetPlayerInfoForLadderGC(szName);
	if (tbPlayerInfo) then -- 玩家不存在
		self:WriteNewsLog(ProcessPlayerInfo, nFaction, szName);
		local tbMenInfo = {};
		tbMenInfo.szName = szName;
		tbMenInfo.nLevel = tbPlayerInfo.nLevel;
		if (string.len(tbPlayerInfo.szKinName) > 0) then
			tbMenInfo.szKin	 = tbPlayerInfo.szKinName;
		else
			tbMenInfo.szKin	 = "Không có";
		end
		
		if (string.len(tbPlayerInfo.szTongName) > 0) then
			tbMenInfo.szTong	 = tbPlayerInfo.szTongName;
		else
			tbMenInfo.szTong	 = "Không có";
		end
		tbMenInfo.nSex = tbPlayerInfo.nSex;
		tbMenPai[nFaction] = tbMenInfo;
	end
end

function FactionBattle:WriteNewsLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "PVP", "FactionBattle", unpack(arg));
	end
	if (MODULE_GC_SERVER) then
		Dbg:Output("PVP", "FactionBattle", unpack(arg));
	end
end

--
function FactionBattle:TestCandidate_GC(nFaction, nPlayerId)
	SetCurCandidate(nFaction, nPlayerId);
end

-- 
function FactionBattle:TestVote_GC(nFaction, nElectId, nVote)
	VoteToCandidate(nFaction, nElectId, nVote);
end

function FactionBattle:WriteLogFor16Player(nFaction, tb16Player)
	local szWeek = os.date("%Y%m%d", GetTime());
	local szOutFile = "\\playerladder\\factionbattle\\"..szWeek.."_"..nFaction..".txt";
	local szFaction = Player:GetFactionRouteName(nFaction);
	local szOut = "门派\t十六强索引\t玩家名\t名次\r\n";
	KFile.WriteFile(szOutFile, szOut);
	for i = 1, 16 do
		local tbPlayer = tb16Player[i];
		if tbPlayer then
			local szStep = "十六强";
			if tbPlayer.nWinCount >= 1 then
				szStep = "八强";
			end
			if tbPlayer.nWinCount >= 2 then
				szStep = "四强";
			end			
			if tbPlayer.nWinCount >= 3 then
				szStep = "亚军";
			end
			if tbPlayer.nWinCount >= 4 then
				szStep = "冠军";
			end
			local szAddText = string.format("%s\t%s\t%s\t%s\r\n", szFaction, i, tbPlayer.szName, szStep);
			KFile.AppendFile(szOutFile, szAddText);
		end
	end
	return 1;
end

