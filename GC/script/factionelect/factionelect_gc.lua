-------------------------------------------------------------------
--File: 	factionelect_gc.lua
--Author: 	zhengyuhua
--Date: 	2008-9-28 18:29
--Describe:	门派选举gc逻辑
-------------------------------------------------------------------

-- 门派投票时间任务
function FactionElect:FactionVoteSchedule()
	if IsVoting() == 1 then -- 如果已经在投票期间则关闭投票
		EndVote();
		-- 信件
		local tbSendHelpForDa = {};
		for i = 1, self.FACTION_NUM do
			self:SendMailToWinner(i, tbSendHelpForDa);
		end
		self:RecordHistory();
		self:RecNewsForMenPaiDaShiXiong(tbSendHelpForDa);
	end
	local nDate = tonumber(GetLocalDate("%d"));
	if nDate == self.START_DATE then
		PlayerHonor:UpdateWuLinHonorLadder();
		Wlls:SetFactionElectPlayer();
		StartVote();
	end
end

-- 记录历史
function FactionElect:RecordHistory()
	local tbMenpaiName = {
			[Env.FACTION_ID_SHAOLIN]		= "少林",
			[Env.FACTION_ID_TIANWANG]		= "天王",
			[Env.FACTION_ID_TANGMEN]		= "唐门",
			[Env.FACTION_ID_WUDU]			= "五毒",
			[Env.FACTION_ID_EMEI]			= "峨嵋",
			[Env.FACTION_ID_CUIYAN]			= "翠烟",
			[Env.FACTION_ID_GAIBANG]		= "丐帮",
			[Env.FACTION_ID_TIANREN]		= "天忍",
			[Env.FACTION_ID_WUDANG]			= "武当",
			[Env.FACTION_ID_KUNLUN]			= "昆仑",
			[Env.FACTION_ID_MINGJIAO]		= "明教",
			[Env.FACTION_ID_DALIDUANSHI]	= "段氏",
			[Env.FACTION_ID_GUMU]			= "古墓",
	};
	
	for i = 1, self.FACTION_NUM do
	local tbWinner = GetCurWinner(i);
		if tbWinner then					
			local szName = KGCPlayer.GetPlayerName(tbWinner.nPlayerId);
			if szName then		
				local nKinId = KGCPlayer.GetKinId(tbWinner.nPlayerId);
				if nKinId then			
					local pKin = KKin.GetKin(nKinId)
					if pKin then
						local nTongId = pKin.GetBelongTong();
						local pTong = KTong.GetTong(nTongId);	
						local nElectVer = GetCurElectVer();
						if pTong then
							pTong.AddHistoryFactionElect(szName, tostring(nElectVer), tbMenpaiName[i]);
							pTong.AddAffairFactionElect(szName, tostring(nElectVer), tbMenpaiName[i]);
							GlobalExcute{"FactionElect:AddAffair", nTongId, szName, tostring(nElectVer), tbMenpaiName[i]};
						end
					end
				end
			end
		end
	end
end

-- 发送信件给胜利者
function FactionElect:SendMailToWinner(nFaction, tbSendHelpForDa)
	local tbWinner = GetCurWinner(nFaction);
	local szName = tbWinner.szName;
	if tbWinner.nPlayerId ~= 0 then
		szName = KGCPlayer.GetPlayerName(tbWinner.nPlayerId);
	end
	if szName == "" then	-- 没有选举优胜者（没人获得候选人资格，很极端的情况）
		return 0;
	end
	local szTitle = "来自门派的贺函";
	local szSender = "<Sender>"..self.FACTION_TO_MASTER[nFaction].."<Sender>";
	local szContent = szSender..szName.."：\n\n    在众位同门的提名和支持下，你从数名候选人中脱颖而出，成为了最受同门爱戴的“门派大师兄（姐）”。\n    <color=yellow>速来本掌门处领取“门派大师兄（姐）”之称号！<color>\n    希望你能不骄不躁，弘扬本门武学精神；尊敬师长，提携新晋，以无愧于“门派大师兄（姐）”的称号。\n\n              掌门人："..self.FACTION_TO_MASTER[nFaction];
	SendMailGC(tbWinner.nPlayerId, szTitle, szContent);
	tbSendHelpForDa[nFaction] = szName;
end

-- 投票给某个候选人
function FactionElect:VoteToCandidate_GC(nFaction, nElectId, nPlayerId, nVote)
	if IsVoting() ~= 1 then
		return 0;
	end
	VoteToCandidate(nFaction, nElectId, nVote)
	GlobalExcute{"FactionElect:VoteToCandidate_GS2", nPlayerId};
end

-- 获取门派大师兄消息的信息
function FactionElect:RecNewsForMenPaiDaShiXiong(tbMenPaiDa)
	self:WriteElectLog("RecNewsForMenPaiDaShiXiong","Elect Man Pai Da Shi Xiong");
	self.MENPAINAME = {
			[Env.FACTION_ID_SHAOLIN]		= "少林";
			[Env.FACTION_ID_TIANWANG]		= "天王";
			[Env.FACTION_ID_TANGMEN]		= "唐门";
			[Env.FACTION_ID_WUDU]			= "五毒";
			[Env.FACTION_ID_EMEI]			= "峨嵋";
			[Env.FACTION_ID_CUIYAN]			= "翠烟";
			[Env.FACTION_ID_GAIBANG]		= "丐帮";
			[Env.FACTION_ID_TIANREN]		= "天忍";
			[Env.FACTION_ID_WUDANG]			= "武当";
			[Env.FACTION_ID_KUNLUN]			= "昆仑";
			[Env.FACTION_ID_MINGJIAO]		= "明教";
			[Env.FACTION_ID_DALIDUANSHI]	= "段氏";
			[Env.FACTION_ID_GUMU]			= "古墓";
	};

	self.tbMenPaiDa = {};
	local tbNewsInfo = {};
	tbNewsInfo.nKey		= Task.tbHelp.NEWSKEYID.NEWS_MENPAIJINGJI_DASHIXING;
	tbNewsInfo.szTitle	= string.format("第%d届十三大门派大师兄、大师姐", GetCurElectVer() - 1);
	tbNewsInfo.nAddTime = GetTime();
	tbNewsInfo.nEndTime = tbNewsInfo.nAddTime + 3600 * 24 * 27;
	tbNewsInfo.szMsg	= "";

	for i=1, self.FACTION_NUM do
		local tbInfo = {};
		tbInfo.szName	= "空缺";
		tbInfo.nLevel	= 0;
		tbInfo.szKin	= "无家族";
		tbInfo.szTong	= "无帮会";
		tbInfo.nSex		= 0;
		if (5 == i) then
			tbInfo.nSex = 1;
		end
		self.tbMenPaiDa[i] = tbInfo;
	end
	for key, szName in pairs(tbMenPaiDa) do
		if (szName) then
			self:ProcessPlayerInfo(key, szName, self.tbMenPaiDa);
		end
	end
	local szMsg = self:GetMenPaiDaNewsMsg();
	Task.tbHelp:AddDNews(tbNewsInfo.nKey, tbNewsInfo.szTitle, szMsg, tbNewsInfo.nEndTime, tbNewsInfo.nAddTime);
end

-- 获取门派大师兄消息
function FactionElect:GetMenPaiDaNewsMsg()
	local szMsg = "";
	for i=1, self.FACTION_NUM do
		local tbInfo = self.tbMenPaiDa[i];
		local szOneMsg = "";
		if (tbInfo.nSex == 0) then
			szOneMsg = string.format("<color=yellow>%s<color>大师兄\n", self.MENPAINAME[i]);
		elseif (tbInfo.nSex == 1) then
			szOneMsg = string.format("<color=yellow>%s<color>大师姐\n", self.MENPAINAME[i]);
		end
		szOneMsg = szOneMsg .. 
				string.format("    名字：<color=yellow>%s<color>\n", tbInfo.szName) .. 
				string.format("    等级：<color=green>%d<color>\n", tbInfo.nLevel) .. 
				string.format("    家族：<color=pink>%s<color>\n", tbInfo.szKin) .. 
				string.format("    帮会：<color=pink>%s<color>\n\n", tbInfo.szTong);
		szMsg = szMsg .. szOneMsg;
	end
	return szMsg;
end

-- 处理玩家信息
function FactionElect:ProcessPlayerInfo(nFaction, szName, tbMenPai)
	local tbPlayerInfo = GetPlayerInfoForLadderGC(szName);
	if (tbPlayerInfo) then -- 玩家不存在
		self:WriteElectLog("ProcessPlayerInfo", nFaction, szName);
		local tbMenInfo = {};
		tbMenInfo.szName = szName;
		tbMenInfo.nLevel = tbPlayerInfo.nLevel;
		if (string.len(tbPlayerInfo.szKinName) > 0) then
			tbMenInfo.szKin	 = tbPlayerInfo.szKinName;
		else
			tbMenInfo.szKin	 = "无家族";
		end
		
		if (string.len(tbPlayerInfo.szTongName) > 0) then
			tbMenInfo.szTong	 = tbPlayerInfo.szTongName;
		else
			tbMenInfo.szTong	 = "无帮会";
		end
		tbMenInfo.nSex = tbPlayerInfo.nSex;
		tbMenPai[nFaction] = tbMenInfo;
	end
end

function FactionElect:WriteElectLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "PVP", "FactionElect", unpack(arg));
	end
	if (MODULE_GC_SERVER) then
		Dbg:Output("PVP", "FactionElect", unpack(arg));
	end
end


