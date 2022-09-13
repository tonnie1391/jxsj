-------------------------------------------------------------------
--File: 	jingjiqizhi.lua
--Author: 	sunduoliang
--Date: 	2008-2-23 9:00
--Describe:	门派战休息间旗帜
-------------------------------------------------------------------

local tbBaseFactionRest = Npc:GetClass("jingjiqizhi");

function tbBaseFactionRest:OnDialog()
	local tbNpcInfo = him.GetTempTable("FactionBattle");
	if tbNpcInfo.tbBaseClass == nil then
		return 0;
	end
	tbBaseFactionRest._tbBase = tbNpcInfo.tbBaseClass;
	tbBaseFactionRest:HitQiZhi(him);
end

function tbBaseFactionRest:HitQiZhi(pNpc)
	local pPlayer = me;
	if self.tbPlayerIdList[pPlayer.nId] == nil then
		Dialog:Say("Bạn không tham gia hoạt động này.");
		return 0;
	end
	if self.tbPlayerIdList[pPlayer.nId].tbHitQiZhiSign[pNpc.dwId] == 1 then
		Dialog:Say("Ngươi đã tìm qua cờ này.");
		return 0;
	end
	Dialog:Say("Ngươi đã tìm được cờ.");
	self.tbPlayerIdList[pPlayer.nId].tbHitQiZhiSign[pNpc.dwId] = 1;
	self.tbPlayerIdList[pPlayer.nId].nHitQiZhi = self.tbPlayerIdList[pPlayer.nId].nHitQiZhi +  1;
	local tbTeamMemberList = pPlayer.GetTeamMemberList();
	if tbTeamMemberList == nil then
		self:AddGradePoint(pPlayer.nId, pPlayer.nId);
	else
		local nMyPlayerId = pPlayer.nId;
		for _, pMemPlayer in pairs(tbTeamMemberList) do
			self:AddGradePoint(pMemPlayer.nId, nMyPlayerId);
		end	
	end
end

function tbBaseFactionRest:AddGradePoint(nPlayerId, nMyPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer == nil then
		return 0;
	end
	if not self.tbPlayerIdList[nPlayerId] then
		return 0;
	end
	local nExSign = 0;
	local nExMemSign = 0;
	if self.tbPlayerIdList[nPlayerId].nHitQiZhi >= self.MY_GET_POINT.nExNum then
		nExSign = 1;
	end
	if self.tbPlayerIdList[nPlayerId].nHitQiZhi >= self.MEMBER_GET_POINT.nExNum then
		nExMemSign = 1;
	end
	local nGrade = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ID2);
	local nAddGrade = nGrade;
	if nPlayerId == nMyPlayerId then
		nAddGrade = nAddGrade +  self.MY_GET_POINT.nPoint;
		local szAnnouce = string.format("Bạn tìm được 1 cờ, nhận được <color=yellow>%s điểm<color> tích lũy <color>", self.MY_GET_POINT.nPoint);
		pPlayer.Msg(szAnnouce);
		if nExSign == 1 then
			nAddGrade = nAddGrade + self.MY_GET_POINT.nExPoint;
			szAnnouce = string.format("Bạn đã tìm đủ số cờ, được nhận thêm %s điểm tích lũy.", self.MY_GET_POINT.nExPoint);
			Dialog:SendBlackBoardMsg(pPlayer, szAnnouce);
		end
	else
		if self.tbPlayerIdList[nPlayerId] ~= nil then
			if self.tbPlayerIdList[nPlayerId].nState == 1 then
				nAddGrade = nAddGrade +  self.MEMBER_GET_POINT.nPoint;
				local pMyPlayer = KPlayer.GetPlayerObjById(nMyPlayerId);
				local szName = pMyPlayer.szName;
				local szAnnouce = string.format("<color=blue>Đồng đội<color> <color=yellow>[%s]<color> <color=blue>tìm được 1 cờ, nhận được <color=yellow>%s điểm<color> <color=blue>tích lũy<color>", szName, self.MEMBER_GET_POINT.nPoint);
				pPlayer.Msg(szAnnouce);
				if nExMemSign == 1 then
					nAddGrade = nAddGrade + self.MEMBER_GET_POINT.nExPoint;
					szAnnouce = string.format("<color=blue>Đồng đội<color> <color=yellow>[%s]<color> <color=blue>đã tìm đủ số cờ, được nhận thêm<color=yellow>%s điểm<color> <color=blue>tích lũy<color>", szName, self.MEMBER_GET_POINT.nExPoint)
					pPlayer.Msg(szAnnouce);
				end
			end
		end
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ID2, nAddGrade);
	self:UpdateShowMsg(pPlayer);
end
