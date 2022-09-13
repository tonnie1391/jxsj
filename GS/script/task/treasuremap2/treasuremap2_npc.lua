-- 文件名  : treasuremap2_npc.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-04 17:20:06
-- 描述    : 藏宝图对话NPC
Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua");

function TreasureMap2:OnDialog(nNpcId)
	local pNpc = nil;
	if nNpcId then
		pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return;
		end
	else
		pNpc = him;
	end	
	
	local szMsgTilte = "Xin chào vị thiếu hiệp.\n\n";
	
	if me.nTeamId <= 0 then
		Dialog:Say(string.format("%sTrước tiên, ngươi <color=yellow>phải Tổ đội<color> và chỉ có <color=yellow>Đội trưởng<color> mới có thể mở được Tàng Bảo Đồ", szMsgTilte))
		return 0;
	end	
	self:GetMapTempletList();
	
	local tbTeamList = KTeam.GetTeamMemberList(me.nTeamId);
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	
	local tbOpenMap = {};
	for nId, nPlayerId in ipairs(tbTeamList) do
		if self.MapTempletList.tbBelongList[nPlayerId] then
			table.insert(tbOpenMap, {nId, KGCPlayer.GetPlayerName(nPlayerId)})
		end 
	end
	
	if #tbOpenMap >= 2 then
		local szPlayerMsg = "";
		for ni, tbTemp in pairs(tbOpenMap) do
			szPlayerMsg = szPlayerMsg .. string.format("<color=yellow>%s<color>", tbTemp[2]);
			if ni ~= #tbOpenMap then
				szPlayerMsg = szPlayerMsg .. ", ";
			end
		end
		Dialog:Say(string.format("%sCó nhiều thành viên mở Tàng Bảo Đồ. Họ là: %s. Hãy tổ chức lại thành viên cho phù hợp.", szMsgTilte, szPlayerMsg))
		return 0;
	end
	
	if #tbOpenMap > 0 and tbOpenMap[1][1] ~= 1 then
		Dialog:Say(string.format("%s<color=yellow>%s<color> đã mở Tàng Bảo Đồ, hãy chuyển Trưởng nhóm cho <color=yellow>%s<color>để có thể vào phó bản.", szMsgTilte, tbOpenMap[1][2], tbOpenMap[1][2]));	
		return 0;
	end
	
	local nCityMapId = pNpc.GetWorldPos();			
	if self.MapTempletList.tbBelongList[tbTeamList[1]] then
		local nRes, tbMission, nDyMapId= self:IsMissionOpen();
		if nRes == 1 then
			local szMsg = string.format("%sĐội trưởng đã mở <color=yellow>%s<color> độ khó <color=green>%d sao<color>, ngươi quyết định vào phó bản này?", szMsgTilte, tbMission.szName, tbMission.nTreasureLevel);			
			local tbOpt = {};
			if tbTeamList[1] == me.nId then
				table.insert(tbOpt,{"Tiến vào phó bản",self.EnterMap, self, nCityMapId});
			else
				table.insert(tbOpt,{"Theo đội trưởng",self.EnterMap, self, nCityMapId});
			end
			table.insert(tbOpt,{"Để ta suy nghĩ lại"});

			Dialog:Say(szMsg, tbOpt);
			return 0;
		else
			local tbTeamList = KTeam.GetTeamMemberList(me.nTeamId);
			local nCityMapId = self.MapTempletList.tbBelongList[tbTeamList[1]][1];
			local szWorldName = GetMapNameFormId(nCityMapId);
			local szMsg = string.format("%sNhóm của ngươi đã mở Tàng Bảo Đồ ở <color=yellow>%s<color>. Hãy đến <color=yellow>%s<color> gặp Quan Nghĩa Quân để vào phó bản.", szMsgTilte, szWorldName, szWorldName);
			if nCityMapId == me.nMapId then
				szMsg = string.format("%sTàng Bảo Đồ đã đóng.", szMsgTilte);
			end			
			Dialog:Say(szMsg);
			return;
		end
	end
	
	local tbOpt = {};
	
	for nTreasureId, tbTemplate in ipairs(self.TEMPLATE_LIST) do
		if tbTemplate.nOpenState and tbTemplate.nOpenState == 1 then
			local szName = "";
			if tbTemplate.szColor and #tbTemplate.szColor ~= 0 then
				szName = string.format("<color=%s>%s<color>",tbTemplate.szColor,tbTemplate.szName);
			else
				szName = tbTemplate.szName;
			end
			table.insert(tbOpt, {szName, self.ApplyTreasureMap, self, nTreasureId, him.dwId});
		end
	end
	local szMsgNew = string.format("Tham gia phó bản sẽ tiêu hao <color=red>1 lượt<color> khiêu chiến Tàng Bảo Đồ.\n(Số lượt khiêu chiến hôm nay: <color=yellow>%d<color>/%d)",self:GetPlayerTimes(me), self.TIMES_LIMIT);
	szMsgTilte = szMsgTilte..szMsgNew;
	table.insert(tbOpt,{"Để ta suy nghĩ lại"});
	Dialog:Say(szMsgTilte, tbOpt);	
end


function TreasureMap2:ApplyTreasureMap(nTreasureId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	

	local nCityMapId = pNpc.GetWorldPos();		
	
	if me.nTeamId <= 0 or me.IsCaptain() == 0 then
		Dialog:Say(string.format("Ngươi phải là thành viên của nhóm."))
		return 0;
	end
	
	local tbTeamList = KTeam.GetTeamMemberList(me.nTeamId);
	if self.MapTempletList.tbBelongList[tbTeamList[1]] then
		return 0;
	end
	if self.MapTempletList.nCount >= self.INSTANCE_LIMIT then
		Dialog:Say("Đã có quá nhiều người tham gia.");
		return 0;
	end
	
--	local szMsg = string.format("请选择%s副本的难度星级。\n<color=red>注意：<color>若高等级参加低星级副本，则您的奖励会有很大程度上的衰减！",self.TEMPLATE_LIST[nTreasureId].szName);
	local szMsg = string.format("Hãy chọn độ khó của %s\n",self.TEMPLATE_LIST[nTreasureId].szName);

	local tbOpt = {};
	for nTreasureLevel, tbTemplate in ipairs(self.TEMPLATE_LIST[nTreasureId].tbInstanceInfo) do
		local szLevel = nil;
		if self:CheckPlayer(me.nId, nCityMapId, nTreasureId, nTreasureLevel) ~= 1 then
			szLevel = string.format("<color=gray>%d sao (%s)<color>",nTreasureLevel, tbTemplate.szDesc);
		else
			szLevel = string.format("%d sao (%s)",nTreasureLevel, tbTemplate.szDesc);
		end
		table.insert(tbOpt, {szLevel, self.ApplyTreasureLevel, self, nTreasureId, nTreasureLevel, nNpcId});
	end
	table.insert(tbOpt, {"Quay lại", self.OnDialog, self, nNpcId});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function TreasureMap2:ApplyTreasureLevel(nTreasureId, nTreasureLevel, nNpcId)
	--CheckInstanceLevel
	if me.nTeamId <= 0 then
		Dialog:Say("Ngươi cần có tổ đội.");
	end	
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local nCityMapId = pNpc.GetWorldPos();		
	
	local tbTeamList = KTeam.GetTeamMemberList(me.nTeamId);	
	if not tbTeamList then
		return;
	end
	
	local bAllRight  = 1;
	local tbOpt 	 = {};
	local szMsg      = "Đồng đội không đủ điều kiện:\n";
	for nId, nPlayerId in ipairs(tbTeamList) do
		local nRes, szRes = self:CheckPlayer(nPlayerId, nCityMapId, nTreasureId, nTreasureLevel);
		if nRes ~= 1 then
			bAllRight = 0;
			szMsg = szMsg.. "<color=yellow>"..KGCPlayer.GetPlayerName(nPlayerId).. "<color> <color=red>".. szRes.. "<color> \n";
		end
		if nRes == -1 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer, "Ấn phím <color=yellow>K<color> để xem số lượt Tàng Bảo Đồ");
			end
		end
	end	
	
	if bAllRight == 0 then
		szMsg = szMsg .. "Ấn phím <color=yellow>K<color> để xem số lượt Tàng Bảo Đồ. Ngươi có thể nhận 2 lệnh bài thông dụng/tuần và 2 lượt khiêu chiến mỗi ngày (Người chơi cấp 50 trở lên có thể tham gia)";
		table.insert(tbOpt, {"Trở lại", self.ApplyTreasureMap, self, nTreasureId, nNpcId});
		table.insert(tbOpt, {"Để ta suy nghĩ lại"});
		Dialog:Say(szMsg, tbOpt);
		return;
	end
		
	if self:CreateInstancing(me, nTreasureId, nTreasureLevel, nCityMapId) == 1 then
		self:ConsumePlayerItem(me,nTreasureId, nTreasureLevel);
		self:AddPlayerTimes(me);		
		me.Msg(string.format("<color=yellow>Đã mở %s độ khó %d sao<color>, hãy gọi đồng đội tiến vào phó bản.",self.TEMPLATE_LIST[nTreasureId].szName, nTreasureLevel));
		KTeam.Msg2Team(me.nTeamId, string.format("Đội trưởng đã mở %s độ khó %d sao.",self.TEMPLATE_LIST[nTreasureId].szName, nTreasureLevel));	
		return 0;
	else
		Dialog:Say("Có quá nhiều người tham gia. Hãy đến nơi khác thử lại.");
	end
end

-- 玩家队伍的副本是否已经开启
function TreasureMap2:IsMissionOpen()
	local nTeamList = KTeam.GetTeamMemberList(me.nTeamId);
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	if self.MapTempletList.tbBelongList[nTeamList[1]] then
		local nCityMapId = self.MapTempletList.tbBelongList[nTeamList[1]][1];
		local nDyMapId = self.MapTempletList.tbBelongList[nTeamList[1]][2];
		if nCityMapId == nMapId and nDyMapId ~= 0 then
			if not self.MissionList[nTeamList[1]] then
				return 0, "Tàng Bảo Đồ không mở hoặc đã kết thúc";
			else
				return 1, self.MissionList[nTeamList[1]], nDyMapId;
			end
		else
			return 0, "Tàng Bảo Đồ không mở.";
		end
	else
		return 0, "Tàng Bảo Đồ không mở.";
	end
end

function TreasureMap2:CanEnterMap(pPlayer)
	if pPlayer.nTeamId <= 0 then
		return 0, "Ngươi cần lập tổ đội trước.";
	end
	
	local nRes, var, nDyMapId= self:IsMissionOpen();
	if nRes ~=1 then
		return 0, var;
	end
	
	if var:GetPlayerCount() >= self.DEF_MAX_ENTER then
		return 0, string.format("Đã có <color=yellow>%s người<color> tham gia phó bản. Ngươi không nên tham gia nữa.", self.DEF_MAX_ENTER);
	end
	
	return 1, var, nDyMapId;
end

function TreasureMap2:EnterMap(nCityMapId)	
	local nRes, var = self:CanEnterMap(me);
	if nRes ~= 1 then
		Dialog:Say(var);
		return 0;
	end
	
	local tbMission = var;
	if tbMission:IsOnceInMission(me.nId) == 0 then
		nRes, var =  self:CheckPlayer(me.nId,nCityMapId, tbMission.nTreasureId, tbMission.nTreasureLevel);
		if nRes ~= 1 then
			local szMsg = string.format("Ngươi không thể tham gia:\n<color=red>%s<color>",var);
			if nRes == -1 then
				szMsg = szMsg .. "\nẤn phím <color=yellow>K<color> để xem số lượt Tàng Bảo Đồ. Ngươi có thể nhận 2 lệnh bài thông dụng/tuần và 2 lượt khiêu chiến mỗi ngày (Người chơi cấp 50 trở lên có thể tham gia)";
			end
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	tbMission:JoinPlayer(me, 0);
	return 0;
end
