Require("\\script\\misc\\globaltaskdef.lua");

Xisuidao.TSKGROUP = 2011;
Xisuidao.TSKID_LINGPAICOUNT 	= 15; -- 进入洗髓岛的令牌个数
Xisuidao.TSKID_REVIVEMAPID		= 16; -- 进入洗髓岛前的重生点地图id
Xisuidao.TSKID_REVIVEPOINTID	= 17; -- 进入洗髓岛前的重生点储物箱ID
Xisuidao.TSKID_AWARDFREE		= 18; -- 免费进入洗髓岛的标记

Xisuidao.XISUIDAOMAPID			= 255; -- 暂定，洗点区
Xisuidao.BATTLEMAPID			= 256; -- 暂定，战斗测试区

Xisuidao.LIMIT_PLAYER_NUM		= 200; -- 洗髓岛在线人数的限制包括战斗区和洗点区

Xisuidao.GBLTASKID_NUM			= DBTASK_XISUIDAO_PLAYER;

Xisuidao.tbDeathRevPos				= { 
		[1] = { Xisuidao.XISUIDAOMAPID, 1652, 3389}, 
	};
	
Xisuidao.tbItem2Map	= {18, 1, 1274, 1};		--三修令牌	

-- 如果需要继续开新等级的时候给予奖励就要添
Xisuidao.tbLevelInfo = {
	DBTASD_SERVER_SETMAXLEVEL89,
	DBTASD_SERVER_SETMAXLEVEL99,
	DBTASD_SERVER_SETMAXLEVEL150,
};

function Xisuidao:Init()
	
end

function Xisuidao:OnEnterXisuidao_Xidian(pPlayer)
	if (60 > pPlayer.nLevel) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Đẳng cấp của bạn chưa đến 60, kỹ năng còn yếu kém không thể vào Tẩy Tủy Đảo.");
		Setting:RestoreGlobalObj();
		return;
	end

	local nPlayerNum	= KGblTask.SCGetTmpTaskInt(Xisuidao.GBLTASKID_NUM);
	if (nPlayerNum >= self.LIMIT_PLAYER_NUM) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Tẩy Tủy Đảo đã có quá nhiều người, hãy chọn thời điểm khác hãy vào.");
		Setting:RestoreGlobalObj();
		return;		
	end

	if ( 1 == self:AwardFreeEnter(pPlayer) ) then
		return;
	end

	local nCount = pPlayer.GetTask(Xisuidao.TSKGROUP, Xisuidao.TSKID_LINGPAICOUNT);
	local szMsg = "";
	if (0 == nCount) then
		szMsg = "Khi vào tẩy tủy đảo bạn có thể tẩy điểm tiềm năng và kỹ năng thoải mái. Lần đầu vào không cần mất phí, bạn chắc chắn muốn vào ?";
	elseif (0 < nCount and 5 > nCount) then
		szMsg = string.format("Bạn đã từng vào tẩy tủy đảo %d lần, Lần này vào cần %d Lệnh Bài Tẩy Tủy Đảo, Bạn đã chuẩn bị đầy đủ chưa ?", nCount, nCount);
	elseif (5 <= nCount) then
		szMsg = "Bạn đã vào Tẩy tủy đảo quá nhiều lần. Cần 5 Lệnh Bài mới có thể vào, bạn đã chuẩn bị đủ chưa ?";
	else
		-- DEBUG
		return;
	end
	local tbOpt = {
			{"Ta đã chuẩn bị đủ, hãy đưa ta vào.", self.OnEnter, self, pPlayer, nCount},
			{"Kết thúc đối thoại"},
		};
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg, tbOpt);
	Setting:RestoreGlobalObj();
	return;
end

function Xisuidao:CanDuoxiu(pPlayer)
	-- if me.szName ~= "Launcher" then
		-- return
	-- end
	local nCurGerneCount	= #Faction:GetGerneFactionInfo(pPlayer);
	local tbLvlReq = {60, 80, 100, 120}
	
	if (pPlayer.nLevel < tbLvlReq[nCurGerneCount]) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Đẳng cấp phải đạt <color=red>cấp "..tbLvlReq[nCurGerneCount].."<color> mới có thể phụ tu thêm môn phái khác.");
		Setting:RestoreGlobalObj();
		return 0;
	end
	
	local nCount = pPlayer.GetItemCountInBags(Item.SCRIPTITEM,1,16,1);
	if (nCount < 1) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Muốn vào phụ tu phái cần có <color=red>Tu Luyện Châu<color> trong người. <color=red>Tu Luyện Châu<color> sẽ giúp bạn chuyển đổi các môn phái với nhau, hãy đi chuẩn bị rồi đến gặp ta.");
		Setting:RestoreGlobalObj();
		return 0;
	end
	
	if(pPlayer.IsAccountLock() == 1)then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Tài khoản của bạn đang khóa, không thể vào tẩy tủy đảo.");
		Setting:RestoreGlobalObj();
		return 0;
	end
	
	if(nCurGerneCount >= Faction.MAX_USED_FACTION)then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Bạn đã hết lần vào tẩy tủy đảo miễn phí.");
		Setting:RestoreGlobalObj();
		return 0;
	end
	
	return 1;
end

function Xisuidao:OnEnterXisuidao_Duoxiu(pPlayer, nFlag)
	local nPlayerNum	= KGblTask.SCGetTmpTaskInt(Xisuidao.GBLTASKID_NUM);
	if (nPlayerNum >= self.LIMIT_PLAYER_NUM) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Tẩy tủy đảo đã có quá nhiều người, hãy quay lại sau.");
		Setting:RestoreGlobalObj();
		return;		
	end
	
	if (self:CanDuoxiu(pPlayer) ~= 1) then
		return;
	end
	
	-- 多修时提醒玩家如果要辅修古墓派需要古墓好友度达到2级才能辅修
	if (Faction:IsOpenGumuFuXiu() == 1) then
		local nShowWarningMsg = 0;
		if (me.nFaction ~= Env.FACTION_ID_GUMU) then
			local nOrgFaction = Faction:GetOriginalFaction(pPlayer);
			if (nOrgFaction ~= Env.FACTION_ID_GUMU) then
				nShowWarningMsg = 1;
			end
		end
		if (nShowWarningMsg == 1) then
			local nFuXiuLevel = pPlayer.GetReputeLevel(Faction.GUMU_FRIEND_REPUTE_CAMP, Faction.GUMU_FRIEND_REPUTE_CLASS);
			if (nFuXiuLevel < Faction.GUMU_FRIEND_REPUTE_CAN_FUXIU_LEVEL) then
				if (not nFlag or nFlag ~= 1) then
					Setting:SetGlobalObj(pPlayer);
					Dialog:Say("<color=red>古墓派为特殊辅修门派，欲辅修古墓须古墓友好度达到2级方可。<color>    \n确定进入洗髓岛？", {
							{"是，进入洗髓岛", self.OnEnterXisuidao_Duoxiu, self, pPlayer, 1},
							{"否，Để ta suy nghĩ thêm"},
						});
					Setting:RestoreGlobalObj();
					return 0;
				end
			end			
		end
	end
	
	local tbGerneFactionInfo = Faction:GetGerneFactionInfo(pPlayer);
	
	local szMsg = "Bạn có thể sử dụng <color=yellow>%d<color><enter>"
	szMsg = string.format(szMsg, Faction.MAX_USED_FACTION - #tbGerneFactionInfo);
	szMsg = szMsg .. "Phụ tu môn phái được dựa trên sự duy trì của các môn phái hiện có, bổ sung học võ công các giáo phái khác. Hãy vào trong và đến gặp <color=yellow>Tẩy Tủy Đại Sư<color> để được hướng dẫn cụ thể. Ngươi đã rõ rồi chứ ?";
	
	local tbOpt = {
		{"Ta đã hiểu rõ, hãy đưa ta vào.", self.EnterXisuidao_Duoxiu, self, pPlayer, #tbGerneFactionInfo},
		{"Kết thúc đối thoại"},
	};
	
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg, tbOpt);
	Setting:RestoreGlobalObj();
	return;
	
end

-- return 1, nLastGerne or 0
function Xisuidao:CanModifyDuoxiu(pPlayer)
	local tbGerneFactionInfo = Faction:GetGerneFactionInfo(pPlayer);
	local nChangeGerneIndex = Faction:GetChangeGenreIndex(pPlayer);
	local nModifyFactionNum = Faction:GetModifyFactionNum(pPlayer);
	
	if(#tbGerneFactionInfo <= 1) then
		Dialog:Say("Bạn chưa gia nhập môn phái.");
		return 0;
	end
	
	if(pPlayer.IsAccountLock() == 1)then
		Dialog:Say("Tài khoản của bạn đang khóa, không thể thực hiện thao tác.");
		return 0;
	end
	
	if nModifyFactionNum >= Faction:GetMaxModifyTimes(pPlayer) then
		Dialog:Say("Bạn đã hết lần vào tẩy tủy đảo miễn phí.");
		return 0;
	end
	
	return 1;
end


function Xisuidao:OnEnterXisuidao_ModifyDuoxiu(pPlayer)
	Faction:InitChangeFaction(pPlayer);
	local nRes = self:CanModifyDuoxiu(pPlayer);
	if nRes == 0 then
		return;
	end
	
	local tbGerneFactionInfo = Faction:GetGerneFactionInfo(pPlayer);
	local nDelta = Faction:GetMaxModifyTimes(pPlayer) - Faction:GetModifyFactionNum(pPlayer);
	local szMsg = string.format("Hiện tại bạn có <color=yellow>%d <color> cơ hội phụ tu môn phái. <enter>Bạn phải gia nhập môn phái trước khi phụ tu.", nDelta);
	
	-- if (Faction:IsOpenGumuFuXiu() == 1) then
		-- szMsg = szMsg .. "\n<color=red>古墓派为特殊辅修门派，欲辅修古墓须古墓友好度达到2级方可。<color>";
	-- end
	szMsg = szMsg .. "<enter>Ngươi muốn thay đổi môn phái nào?";
	
	local tbOpt = {{"Kết thúc đối thoại"}};
	
	for i = 2, #tbGerneFactionInfo do
		local szFactionName = Player.tbFactions[tbGerneFactionInfo[i]].szName;
		table.insert(tbOpt, 1, {szFactionName, self.SureModifyFaction, self, pPlayer, szFactionName, i});
	end
	
	Dialog:Say(szMsg, tbOpt);
	return;
end

function Xisuidao:SureModifyFaction(pPlayer, nFactionName, nFactionGerne)
	local szMsg = "Bạn có chắc chắn muốn thay thế môn phải <color=yellow>%s<color> không ?<enter> Sao khi xác nhận bạn có thể vào tẩy tủy đảo để chọn hướng phụ tu cho mình, hãy cẩn thận với quyết định của mình.";
	szMsg = string.format(szMsg, nFactionName);
	
	local tbOpt = {
		{"Hãy đưa ta vào trong", self.EnterXisuidao_ModifyDuoXiu, self, pPlayer, nFactionGerne},
		{"Để ta suy nghĩ chút"},
		};
		
	Dialog:Say(szMsg, tbOpt);
end

-- 多修一个门派
function Xisuidao:EnterXisuidao_Duoxiu(pPlayer, nGerneFaction)
	local nResult = self:CanDuoxiu(pPlayer);
	if (nResult ~= 1) then
		return;
	end
		
	local nRet, szMsg = Map:CheckTagServerPlayerCount(self.XISUIDAOMAPID)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	
	if EventManager.IVER_bUseChangeFactionItem == 1 and  nGerneFaction == 2 then
		local nResult = self:CheckHaveItem2Map(pPlayer);
		if nResult ~= 1 then
			return 0;
		end
		pPlayer.ConsumeItemInBags2(1, self.tbItem2Map[1], self.tbItem2Map[2], self.tbItem2Map[3], self.tbItem2Map[4]);	
	end
	
	Faction:InitChangeFaction(pPlayer);
	
	local nCurGerneCount = #Faction:GetGerneFactionInfo(pPlayer);
	
	local nGerne = nCurGerneCount + 1; -- 要修一个新的
	
	Faction:SetChangeGenreIndex(pPlayer, nGerne);
	Faction:WriteLog(Dbg.LOG_INFO, "EnterXisuidao_Duoxiu", pPlayer.szName, nGerne);
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("进入洗髓岛多修，修的是第%d修。", nGerne));
	pPlayer.NewWorld(self.XISUIDAOMAPID, 1652, 3389);
	pPlayer.Msg("Vào tẩy tủy đảo có thể lựa chọn lại hướng tu luyện của mình.");
end

--vn 检查是否是有三修令牌才能进入洗髓岛
function Xisuidao:CheckHaveItem2Map(pPlayer)
	local nCount = pPlayer.GetItemCountInBags(unpack(self.tbItem2Map));
	if (nCount < 1) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Phụ tu lần 3 cần <color=red>Lệnh bài tam tu<color>, có thể mua từ Kỳ Trân Các.");
		Setting:RestoreGlobalObj();
		return 0;
	end
	return 1;
end

-- 更换多修
-- nGerne：要换第几个
function Xisuidao:EnterXisuidao_ModifyDuoXiu(pPlayer, nGerne)
	local nRet, szMsg = Map:CheckTagServerPlayerCount(self.XISUIDAOMAPID)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	
	Faction:InitChangeFaction(pPlayer);
	local nCurGerneCount = #Faction:GetGerneFactionInfo(pPlayer);
	assert(nGerne >= 2 and nGerne <= nCurGerneCount);
	
	local nRes = self:CanModifyDuoxiu(pPlayer);
	if nRes == 0 then
		return;
	end
	
	local nCurrModifyNum = Faction:GetModifyFactionNum(pPlayer);
	Faction:SetModifyFactionNum(pPlayer, nCurrModifyNum + 1);
	Faction:SetChangeGenreIndex(pPlayer, nGerne);
	
	Faction:WriteLog(Dbg.LOG_INFO, "EnterXisuidao_ModifyDuoxiu", pPlayer.szName, nGerne);
	pPlayer.NewWorld(self.XISUIDAOMAPID, 1652, 3389);
	pPlayer.Msg("Vào tẩy tủy đảo có thể lựa chọn lại hướng tu luyện của mình.");
	local szLogMsg = string.format("进入洗髓岛更换辅修门派， 换的是第%d修。", nGerne);
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLogMsg);
end

-- 增加判断给予免费洗点的机会
function Xisuidao:AwardFreeEnter(pPlayer)
	for _, nTaskId in ipairs(self.tbLevelInfo) do
		local nTime = KGblTask.SCGetDbTaskInt(nTaskId);
		if (nTime > 0) then
			local nAwardFlag = 0;
			local nFreeFlag = pPlayer.GetTask(self.TSKGROUP, self.TSKID_AWARDFREE);
			if (nFreeFlag <= 0) then
				if (nTime < GetTime()) then
					nAwardFlag = 1;
				end
			else
				if (nTime > nFreeFlag) then
					nAwardFlag = 1;
				end
			end
			if (nAwardFlag == 1) then
				local szMsg = "Hiện tại bạn có cơ hội miễn phí để vào tẩy tủy đảo.";
				local tbOpt = {
						{"Được đưa ta đi", self.OnFreeEnter, self, pPlayer, nTime},
						{"Kết thúc đối thoại"},
					};
				Setting:SetGlobalObj(pPlayer);
				Dialog:Say(szMsg, tbOpt);
				Setting:RestoreGlobalObj();
				return 1;
			end
		else
			break;
		end
	end
	return 0;
end

function Xisuidao:OnEnter(pPlayer, nCount)
	local nRet, szMsg = Map:CheckTagServerPlayerCount(self.XISUIDAOMAPID)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	-- 判断包裹里的令牌是否足够
	if (0 < nCount) then
		local nPaiCount = nCount;
		if (5 < nCount) then
			nPaiCount = 5;
		end
		local nLingpaiCount = pPlayer.GetItemCountInBags(18, 1, 79, 1);
		-- 包裹里的令牌不足
		if (nPaiCount > nLingpaiCount) then
			Setting:SetGlobalObj(pPlayer);
			Dialog:Say("你带的洗髓岛令牌不足，待备齐了再来吧。");
			Setting:RestoreGlobalObj();
			return;
		end
		pPlayer.ConsumeItemInBags(nPaiCount, 18, 1, 79, 1);
	end
	if (5 > nCount) then
		nCount = nCount + 1;
		pPlayer.SetTask(self.TSKGROUP, self.TSKID_LINGPAICOUNT, nCount);
	end
	self:EnterXisuidao(pPlayer);
end

function Xisuidao:OnFreeEnter(pPlayer, nTime)
	local nRet, szMsg = Map:CheckTagServerPlayerCount(self.XISUIDAOMAPID)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	pPlayer.SetTask(self.TSKGROUP, self.TSKID_AWARDFREE, nTime);
	self:EnterXisuidao(pPlayer);
end

function Xisuidao:EnterXisuidao(pPlayer)
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "进入洗髓岛洗点");
	pPlayer.NewWorld(self.XISUIDAOMAPID, 1652, 3389);
	pPlayer.Msg("Vào tẩy tủy đảo, bạn có thể phân phối lại điểm tiềm năng vào điểm kỹ năng không giới hạn.");
end

function Xisuidao:OnRecoverXisuidao(pPlayer)
	local nChangeGerneIndex = Faction:GetChangeGenreIndex(pPlayer);
	if nChangeGerneIndex > 0 then
		
		Faction:WriteLog(Dbg.LOG_INFO, "OnRecoverXisuidao", pPlayer.szName, nChangeGerneIndex);
		local szLogMsg = string.format("进入洗髓岛更换辅修门派， 换的是第%d修。", nChangeGerneIndex);
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLogMsg);
		pPlayer.NewWorld(self.XISUIDAOMAPID, 1652, 3389);
		pPlayer.Msg("Vào tẩy tủy đảo bạn có thể thay đổi hướng tu luyện võ công của mình.");
	end
end

Xisuidao:Init();

--?pl DoScript("\\script\\player\\xisuidao\\xisuidao.lua")