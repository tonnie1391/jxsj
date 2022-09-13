--4倍地圖npc
--sunduoliang
--2008.11.05

Require("\\script\\task\\fourfoldmap\\fourfoldmap_def.lua");

local Fourfold = Task.FourfoldMap;

function Fourfold:OnAbout()
	local szMsg = string.format([[
<color=red>Giới thiệu Bí Cảnh:<color>

1. Người chơi phải đạt <color=yellow>cấp 50<color> mới có tư cách vào Bí Cảnh.

2. Thời gian mỗi lần Bí Cảnh mở là <color=yellow>2-6 giờ<color>, trong Bí Cảnh có phần thưởng kinh nghiệm hậu hĩnh.

3. Đạt cấp 50 mỗi ngày sẽ <color=yellow>tự động tích lũy %d giờ<color>, tối đa tích lũy <color=yellow>%d giờ<color>.

4. Trước khi Bí Cảnh đóng có thể ra vào tùy ý.

5. Thời gian tu luyện Bí Cảnh của đội trưởng ít nhất là <color=yellow>2 giờ<color>, nhiều nhất có <color=yellow>6 người<color> cùng lúc vào Bí Cảnh.

6. Nếu <color=yellow>sử dụng bản đồ để vào Bí Cảnh (dù là đội trưởng hay không)<color>, lúc tu luyện có thể nhận <color=red>kinh nghiệm ủy thác rời mạng tương ứng (ủy thác trên mạng)<color>, muốn nhận kinh nghiệm thì <color=yellow>thời gian Bạch Câu Hoàn của nhân vật phải lớn hơn 0<color>.

]], EventManager.IVER_nFourfoldMapPreTime, EventManager.IVER_nFourfoldMapMaxTime);
	Dialog:Say(szMsg);
end

function Fourfold:OnDialog()
	if me.nLevel < self.LIMIT_LEVEL then
		Dialog:Say(string.format("Ngươi phải tu luyện đến cấp %s mới có thể vào Bí Cảnh.", self.LIMIT_LEVEL));
		return 0;
	end
	local nRemainTime = me.GetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME);
	local szMsgTilte = string.format("Tu luyện võ học nếu nóng vội dễ gây tẩu hỏa nhập ma.\n\nHiện thời gian tu luyện của ngươi còn: <color=yellow>%s<color>\n\n", Lib:TimeFullDesc(nRemainTime));
	if nRemainTime <= 0 then
		Dialog:Say(string.format("%s Thời gian tu luyện bí cảnh của ngươi đã hết, hãy quay lại vào ngày mai.", szMsgTilte))
		return 0;
	end
	if me.nTeamId <= 0 then
		Dialog:Say(string.format("%s Ngươi phải <color=yellow>ở trong nhóm<color> và làm <color=yellow>đội trưởng<color>, mang theo bằng hữu của ngươi vào tu luyện.", szMsgTilte))
		return 0;
	end
	local nTeamList = KTeam.GetTeamMemberList(me.nTeamId);
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	
	local tbOpenMap = {};
	for nId, nPlayerId in ipairs(nTeamList) do
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
		Dialog:Say(string.format("%sNhóm của ngươi có người không thể vào trong, gồm %s, một nhóm chỉ cho phép đội trưởng mở Bí Cảnh, hãy tạo lại nhóm rồi mở lại.", szMsgTilte, szPlayerMsg))
		return 0;
	end
	if #tbOpenMap > 0 and tbOpenMap[1][1] ~= 1 then
		Dialog:Say(string.format("%sNhóm của ngươi tại <color=yellow>%s<color> mở Bí Cảnh, nhưng ngươi không phải đội trưởng，cần phải có đội trưởng ở <color=yellow>%s<color>, ngươi mới có thể vào trong tu luyện.", szMsgTilte, tbOpenMap[1][2], tbOpenMap[1][2]))		
		return 0;
	end
	
	if self.MapTempletList.tbBelongList[nTeamList[1]] then
		if self:IsMissionOpen() == 1 then
			local szMsg = string.format("%sMuốn vào Bí Cảnh", szMsgTilte);
			local tbOpt = {
				{"Có mang theo bản đồ bí cảnh (nhân đôi kinh nghiệm)",self.EnterMapForItem, self},
				{"Ta theo đội trưởng vào bí cảnh",self.EnterMap, self},
				{"Kết thúc đối thoại"},
			}
			Dialog:Say(szMsg, tbOpt);
			return 0;
		else
			local nTeamList = KTeam.GetTeamMemberList(me.nTeamId);
			local nCityMapId = self.MapTempletList.tbBelongList[nTeamList[1]][1];
			local szWorldName = GetMapNameFormId(nCityMapId);
			local szMsg = string.format("%sNhóm của ngươi mở Bí Cảnh tại <color=yellow>%s<color>, hãy đến <color=yellow>%s<color> gặp Quan Quân Nhu (nghĩa quân) để vào Bí Cảnh.", szMsgTilte, szWorldName, szWorldName);
			Dialog:Say(szMsg);
			return;
		end
	end
	local szMsg = string.format("%sNếu ngươi sở hữu <color=yellow>Bản đồ Bí Cảnh<color>, có thể mở được Bí Cảnh, ngươi có muốn mở không?",szMsgTilte);
	local tbOpt = {
		{"Mở Bí Cảnh", self.ApplyTeamMap, self},
		{"Kết thúc đối thoại"}
	}
	Dialog:Say(szMsg, tbOpt);
end

--返回可能的修煉時間，如果時間不夠則返回空table
--nRemainTime單位為秒
function Fourfold:GetValidPractiseTime(pPlayer, nRemainTime)
	local tbHour = {};
	if nRemainTime >= 45 * 60 then
		table.insert(tbHour, 45);
	end
	if nRemainTime >= 30 * 60 then
		table.insert(tbHour, 30);
	end
	if nRemainTime >= 15 * 60 then
		table.insert(tbHour, 15);
	end
	return tbHour, string.format("Thời gian tu luyện phải <color=yellow>lớn hơn %s<color> mới có thể vào Bí Cảnh.", Lib:TimeFullDesc(self.DEF_MIN_OPEN_TIME));	
end

function Fourfold:ApplyTeamMap(nFlag, nHour, nMapNumber)
	local nRemainTime = me.GetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME);
	if nRemainTime < self.DEF_MIN_OPEN_TIME then
		Dialog:Say(string.format("Thời gian tu luyện phải <color=yellow>lớn hơn %s<color> mới có thể vào Bí Cảnh.", Lib:TimeFullDesc(self.DEF_MIN_OPEN_TIME)));
		return 0;
	end
	if me.nTeamId <= 0 or me.IsCaptain() == 0 then
		Dialog:Say(string.format("Ngươi phải ở trong tổ đội và làm đội trưởng, cùng bằng hữu mới có thể tham gia."))
		return 0;
	end
	
	local nTeamList = KTeam.GetTeamMemberList(me.nTeamId);
	if self.MapTempletList.tbBelongList[nTeamList[1]] then
		return 0;
	end
	if self.MapTempletList.nCount >= self.MAP_APPLY_MAX then
		Dialog:Say("Có quá nhiều anh hùng đang tu luyện trong Bí Cảnh, ngươi hãy đến vào lúc khác nhé.");
		return 0;
	end
	
	-- 選擇用多少地圖
	if not nFlag then
		local tbHour, szMsg = self:GetValidPractiseTime(me, nRemainTime);
		if #tbHour == 0 then
			Dialog:Say(szMsg);
			return 0;
		end
		
		local szMsg = string.format("Nếu ngươi sở hữu <color=yellow>Bản đồ Bí Cảnh<color>, có thể mở được Bí Cảnh, ngươi có muốn mở không?\n<color=red>Mở Bí Cảnh sẽ khấu trừ Bản đồ Bí Cảnh trên người<color>");
		local tbOpt = {};
		
		for nIndex, nHour in ipairs(tbHour) do
			table.insert(tbOpt, {string.format("Sử dụng %d bản đồ tu luyện %d phút", nHour/15, nHour), self.ApplyTeamMap, self, 1, nHour, nHour/15});
		end
		
		table.insert(tbOpt,	{"Kết thúc đối thoại"});
		Dialog:Say(szMsg, tbOpt)
		return 0;
	end
	
	local tbFind = me.FindItemInBags(unpack(self.DEF_ITEM_KEY));
	if #tbFind < nMapNumber then
		Dialog:Say(string.format(
			"Không có <color=yellow>%d<color> bản đồ chỉ dẫn, ta không có cách gì đưa các ngươi vào nơi thần bí đó，nhớ là phải có đủ <color=yellow>Bản đồ Bí Cảnh<color> ta mới giúp được!",
			nMapNumber));
		return 0;
	end
	
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	if self:ApplyMap(nMapId, me.nId, me.nLevel, nHour) == 1 then
		for i = 1, nMapNumber do
			me.DelItem(tbFind[i].pItem);
		end
		me.Msg("<color=yellow>Mở Bí Cảnh thành công<color>, hãy gọi bằng hữu tới, trong thời gian <color=yellow>1 phút<color> vào Bí Cảnh tu luyện.");
																	 
		return 0;
	end
end

-- 玩家隊伍的副本是否已經開啟
function Fourfold:IsMissionOpen()
	local nTeamList = KTeam.GetTeamMemberList(me.nTeamId);
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	if self.MapTempletList.tbBelongList[nTeamList[1]] then
		local nCityMapId = self.MapTempletList.tbBelongList[nTeamList[1]][1];
		local nDyMapId = self.MapTempletList.tbBelongList[nTeamList[1]][3];
		if nCityMapId == nMapId and nDyMapId ~= 0 then
			if not self.MissionList[nTeamList[1]] then
				return 0, "Bí Cảnh chưa được mở.";
			else
				return 1, self.MissionList[nTeamList[1]], nDyMapId;
			end
		else
			return 0, "Bí Cảnh chưa được mở.";
		end
	else
		return 0, "Bí Cảnh chưa được mở.";
	end
end

function Fourfold:CanEnterMap()
	if me.nTeamId <= 0 then
		return 0, "Trong Bí Cảnh ẩn chứa nhiều hiểm nguy, hãy tham gia tổ đội để có thể vào trong.";
	end
	
	local nRemainTime = me.GetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME);
	if nRemainTime <= self.DEF_MIN_ENTER_TIME then
		return 0, string.format("Thời gian tu luyện phải <color=yellow>lớn hơn %s<color> mới có thể vào Bí Cảnh.", Lib:TimeFullDesc(self.DEF_MIN_ENTER_TIME));
	end
	
	local nRes, var, nDyMapId= self:IsMissionOpen();
	if nRes ~=1 then
		return 0, var;
	end
		
	local nTeamList = KTeam.GetTeamMemberList(me.nTeamId);
	if var:GetPlayerCount() >= self.DEF_MAX_ENTER then
		return 0, string.format("Đã có <color=yellow>%s người<color> ở trong Bí Cảnh, quá nhiều người cùng vào, có thể gây hỗn loạn, không thể vào trong được nữa.", self.DEF_MAX_ENTER);
	end
	
	return 1, var, nDyMapId;
end

function Fourfold:EnterMapForItem(nFlag, nHour, nMapNumber)
	local nRes, var = self:CanEnterMap();
	if nRes ~= 1 then
		Dialog:Say(var);
		return 0;
	end
	local tbMission = var;
	if tbMission:GetFourfold(me.nId) == 1 or tbMission:IsOnceInFourfold(me.nId) == 1 then
		self:EnterMap();
		return 0;
	end
		
	if not nFlag then -- 選擇用幾幅地圖
		local nMissionTime = tbMission:GetHour()*3600;
		local nRemainTime = me.GetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME);
		local tbHour, szMsg = Fourfold:GetValidPractiseTime(pPlayer, math.min(nRemainTime, nMissionTime));
		if #tbHour == 0 then
			Dialog:Say(szMsg);
			return 0;
		end
		local szMsg = string.format("Nếu ngươi sở hữu <color=yellow>Bản đồ Bí Cảnh<color>, có thể sử dụng <color=yellow>Bản đồ Bí Cảnh<color> cùng đội trưởng vào tu luyện, ngươi sẽ nhận được hiệu quả cực lớn (tăng 4 lần kinh nghiệm), ngươi có muốn sử dụng <color=yellow>Bản đồ Bí Cảnh<color> để vào tu luyện không?\n<color=red>Sử dụng Bản đồ Bí Cảnh để vào tu luyện sẽ khấu trừ Bản đồ Bí Cảnh trên người<color>");
		local tbOpt = {}
		for _, nHour in ipairs(tbHour) do
			table.insert(tbOpt, {string.format("Sử dụng %d Bản đồ Bí Cảnh", nHour/15), self.EnterMapForItem, self, 1, nHour, nHour/15});
		end
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		Dialog:Say(szMsg, tbOpt)
		return 0;
	else -- 進入
		local tbFind = me.FindItemInBags(unpack(self.DEF_ITEM_KEY));
		if #tbFind < nMapNumber then
			Dialog:Say(string.format(
				"Ngươi không có đủ <color=yellow>Bản đồ Bí Cảnh<color>, muốn tu luyên %d giờ, mang theo <color=yellow>%d Bản đồ Bí Cảnh<color> đến gặp ta!",
				nHour, nMapNumber));
			return 0;
		end
		
		for i = 1, nMapNumber do
			me.DelItem(tbFind[i].pItem);
		end
		SpecialEvent.ActiveGift:AddCounts(me, 18);		--开启秘境活跃度
		tbMission:JoinFourfold(me.nId, nHour);
		self:EnterMap();
		return 0;
	end
end

function Fourfold:EnterMap()
	local nRes, var, nDyMapId = self:CanEnterMap();
	if nRes ~= 1 then
		Dialog:Say(var);
		return 0;
	end
	
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	self.PlayerTempList[me.nId] = {};
	self.PlayerTempList[me.nId].nMapId = nMapId;
	self.PlayerTempList[me.nId].nPosX = nPosX;
	self.PlayerTempList[me.nId].nPosY = nPosY;
	self.PlayerTempList[me.nId].nCaptain = KTeam.GetTeamMemberList(me.nTeamId)[1];
	self.PlayerTempList[me.nId].nState = 0;
	me.NewWorld(nDyMapId, unpack(self.DEF_MAP_POS[1]));
	return 0;
end
