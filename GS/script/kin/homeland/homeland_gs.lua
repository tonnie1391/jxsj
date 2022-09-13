-- 文件名　：homeland_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-036-10 17:32:10
-- 描  述  ：

if MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\kin\\homeland\\homeland_def.lua")

function HomeLand:LoadLadder_GS(tbLastWeekRank)
	self.tbLastWeekRank = tbLastWeekRank;
	self.tbLastWeekKinId2Index = {};
	for i = 1, #self.tbLastWeekRank do
		if self.tbLastWeekRank[i] then
			self.tbLastWeekKinId2Index[self.tbLastWeekRank[i]] = i;
		else
			print("HomeLand","LoadLadder_GS: not table index ", i);
		end
	end
end

function HomeLand:LoadMap_GS(tbKinId2MapId, nConectEvent)
	self.tbKinId2MapId = tbKinId2MapId;
	self:LoadHomeLandMap(nConectEvent);
end

-- 家族副本地图
function HomeLand:LoadHomeLandMap(nConectEvent)
	for nKinId, tbInfo in pairs(self.tbKinId2MapId) do
		if (GetServerId() == tbInfo[1]) and (nConectEvent == 1 or tbInfo[2] == 0) then
			if (Map:LoadDynMap(1, self.MAP_TEMPLATE, {self.OnLoadMapFinish, self, nKinId}) ~= 1) then
				print(string.format("副本地图%s加载错误！",nTempMapId, nKinId));
				self.tbLoadFailKin[nKinId] = 1;
			end	
		end
	end
end

-- 加载地图回调
function HomeLand:OnLoadMapFinish(nKinId, nDyMapId)
	self.tbKinId2MapId[nKinId][2] = nDyMapId;
	GCExcute{"HomeLand:RecordKinMapId_GC", nKinId, nDyMapId};
	--self:AdornHouse(nKinId, nDyMapId);	-- 装饰家族领地
end

function HomeLand:AdornHouse(nKinId, nDyMapId)
	
end

function HomeLand:RecordKinMapId_GS2(nKinId, nDyMapId)
	self.tbKinId2MapId[nKinId][2] = nDyMapId;
end

-- 返回排行榜
function HomeLand:GetLadderPart(nLadderType, nStart, nLength)
	local nMaxList = #self.tbLastWeekRank;
	local nMaxNum = math.min(math.min(self.MAX_VISIBLE_LADDER, nStart + nLength - 1), nMaxList);
	if nStart > nMaxNum then
		return;
	end
	local tbLadder = {};
	for i = nStart, nMaxNum do		
		local szName = "未知";
		local nRepute = 0;
		if self.tbLastWeekRank[i] then		--保护
			local cKin = KKin.GetKin(self.tbLastWeekRank[i]);
			if cKin then
				szName = cKin.GetName();
				nRepute = cKin.GetTotalRepute();
			else
				Dbg:WriteLog("HomeLand", "找不到家族", nKinId);
			end
		end
		local tbInfo = {};
		tbInfo.szPlayerName = szName;
		tbInfo.dwValue = nRepute;
		tbLadder[#tbLadder + 1] = tbInfo;
	end
	return tbLadder, nMaxList
end

function HomeLand:GetLadderRankByPlayerName(nLadderType, szName, nSearchType)
	if nSearchType == Ladder.SEARCHTYPE_PLAYERNAME then
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		if not nPlayerId then
			return -1, szName .. " Gia tộc";
		end
		local nKinId = KGCPlayer.GetKinId(nPlayerId);
		if not nKinId or nKinId <= 0 then
			return -1, szName .. " Gia tộc";
		end
		local nRank = self.tbLastWeekKinId2Index[nKinId];
		if not nRank then
			return -1, szName .. " Gia tộc";
		end
		return nRank;
	elseif nSearchType == Ladder.SEARCHTYPE_KINNAME then
		local nKinId = KKin.GetKinNameId(szName);
		if not nKinId or nKinId <= 0 then
			return -1, szName;
		end
		local nRank = self.tbLastWeekKinId2Index[nKinId];
		if not nRank then
			return -1, szName;
		end
		return nRank;
	end
	return -1, szName;
end

function HomeLand:OpenHomeLand_GS2(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetIsOpenHomeLand(1);
	KKin.Msg2Kin(nKinId, "Lãnh địa Gia tộc đã được mở, các thành viên có thể thông qua Mã Xuyên Sơn hoặc Truyền tống phù để vào lãnh địa.")
end

-- 返回家园所在地图Id
function HomeLand:GetMapIdByKinId(nKinId)
	if not self.tbLastWeekKinId2Index[nKinId] then
		return 0, "Thứ hạng của Gia tộc chưa đạt.";
	end
	if self.tbLastWeekKinId2Index[nKinId] > self.MAX_LADDER_RNAK then
		return 0, string.format("Chỉ có %s Gia tộc xếp hạng đầu tiên được mở lãnh địa", self.MAX_LADDER_RNAK);
	end
	if not self.tbKinId2MapId[nKinId] then
		return 0, "Không tìm thấy Lãnh địa của Gia tộc của bạn.";
	end
	local nMapId = self.tbKinId2MapId[nKinId][2];
	if nMapId <= 0 then
		return 0, "Không thể tìm thấy lãnh địa, hãy sang thành thị khác rồi thử lại.";
	end
	return nMapId;
end

--通过player返回家园地图id
function HomeLand:GetMapIdByPlayerId(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
		if HomeLand:CheckOpen() ~= 1 then
		return 0, "Tính năng này chưa mở";
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId <= 0 then
		return 0, "Chưa có Gia tộc";
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0, "Chưa có Gia tộc";
	end
	if cKin.GetIsOpenHomeLand() == 0 then -- 族长还未开启
		return 0, "Hãy gọi Tộc trưởng mở Lãnh địa Gia tộc trước";
	end
	local nMapId, szMsg = self:GetMapIdByKinId(nKinId);
	if nMapId == 0 then
		return 0, szMsg;
	end
	return nMapId;
end


-- 进入自己家园
function HomeLand:Enter(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId <= 0 then
		pPlayer.Msg("Hãy quay lại tìm ta sau khi tham gia 1 Gia tộc");
		return 0;
	end
	local nMapId, szMsg = self:GetMapIdByKinId(nKinId);
	if nMapId <= 0 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	pPlayer.NewWorld(nMapId, self.ENTER_POS[1], self.ENTER_POS[2]);
end


function HomeLand:GetKinRank(nKinId)
	return self.tbLastWeekKinId2Index[nKinId] or 0;
end