-- 文件名　：homeland_npc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-06-14 14:44:10
-- 描  述  ：

Require("\\script\\kin\\homeland\\homeland_def.lua")


function HomeLand:OnEnterDialog()
	local szMsg = "   Lãnh địa gia tộc là nơi trồng trọt, họp mặt các thành viên và tham gia những hoạt động khác.";
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId <= 0 then
		Dialog:Say("Chưa có gia tộc không thể vào.");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		Dialog:Say("Chưa có gia tộc không thể vào.");
		return 0;
	end
	if cKin.GetIsOpenHomeLand() == 0 then
		local nRet, cKin = Kin:CheckSelfRight(nKinId, nMemberId, 1);
		if nRet ~= 1 then
			Dialog:Say("Hãy nhờ Tộc trưởng mở Lãnh địa.");
			return 0;
		end
		local tbOpt = 
		{
			{"Mở Lãnh địa gia tộc", self.OpenHomeLand, self},
			{"Để ta suy nghĩ"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	local tbOpt = 
	{
		{"Vào Lãnh địa gia tộc", self.EnterHomeLand, self},
		{"Để ta suy nghĩ"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 以me进入家族
function HomeLand:EnterHomeLand()
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId <= 0 then
		Dialog:Say("Chưa có gia tộc không thể vào.");
		return 0;
	end
	local nMapId, szMsg = self:GetMapIdByKinId(nKinId);
	if nMapId <= 0 then
		Dialog:Say(szMsg);
		return 0;
	end
	me.NewWorld(nMapId, self.ENTER_POS[1], self.ENTER_POS[2]);
end


function HomeLand:OpenHomeLand()
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId <= 0 then
		Dialog:Say("Chưa có gia tộc không thể vào.");
		return 0;
	end
	local nRet, cKin = Kin:CheckSelfRight(nKinId, nMemberId, 1)
	if nRet ~= 1 then
		Dialog:Say("Hãy nhờ Tộc trưởng mở Lãnh địa.");
		return 0;
	end
	if not self.tbLastWeekKinId2Index[nKinId] then
		Dialog:Say(string.format("Hãy đợi sắp xếp thứ hạng Uy danh Gia tộc, nếu đạt top %s hãy tới tìm ta.", self.MAX_LADDER_RNAK));
		return 0;
	end
	if self.tbLastWeekKinId2Index[nKinId] > self.MAX_LADDER_RNAK then
		Dialog:Say(string.format("Hãy đợi sắp xếp thứ hạng Uy danh Gia tộc, nếu đạt top %s hãy tới tìm ta.", self.MAX_LADDER_RNAK));
		return 0;
	end
	GCExcute{"HomeLand:OpenHomeLand_GC", nKinId, nMemberId, me.nId};
end