-------------------------------------------------------------------
--File: banghuiLianmengshi.lua
--Author: fenghewen
--Date: 2009-6-17 15:56
--Describe: 帮会联盟使
-------------------------------------------------------------------
--	帮会联盟使;	
local tbBangHuiLianMengShi = Npc:GetClass("banghuilianmengshi");

function tbBangHuiLianMengShi:OnDialog()
	local szSay = "Nếu muốn Liên minh các Bang hội, hãy đến tìm ta."
	if me.dwUnionId and me.dwUnionId ~= 0 then
		local pUnion = KUnion.GetUnion(me.dwUnionId);
		if pUnion then
			szSay = "Bang hội của bạn đã tham gia Liên Minh <color=green>"..pUnion.GetName().."<color>\nCác thành viên bao gồm: <color=green>";
			local pTongItor = pUnion.GetTongItor();
			local nTongId = pTongItor.GetCurTongId();
			while nTongId ~= 0 do
				local pTong = KTong.GetTong(nTongId);
				if pTong then
					szSay = szSay ..pTong.GetName().."\n";
				end
				nTongId = pTongItor.NextTongId();
			end
		
			local nMasterTongId = pUnion.GetUnionMaster();
			local pMasterTong = KTong.GetTong(nMasterTongId);
			if not pMasterTong then
				local szMsg = string.format("[%s] không có Bang hội Chỉ huy", pUnion.GetName());
				Dbg:WriteLog("Union", "Không có Bang hội Chỉ huy", szMsg);
				return 0;
			end
			local nMasterId = Tong:GetMasterId(nMasterTongId)
			local szMasterName = KGCPlayer.GetPlayerName(nMasterId);
	
			szSay = szSay .."<color>\nBang hội Chỉ huy: <color=green>"..pMasterTong.GetName().."<color>Lãnh đạo: <color=green>"..szMasterName.."<color>";
		end
	end
	Dialog:Say(szSay, 
		{
			{"Lập Liên minh", Union.DlgCreateUnion, Union},
			{"Tham gia Liên minh", Union.DlgTongJoin, Union},
			{"Rời Liên minh", Union.DlgTongLeave, Union},
			{"Thay đổi Lãnh đạo", Union.DlgChangeUnionMaster, Union},
			{"Giải tán Liên minh", Union.DlgDispenseDomain, Union},
			{"Rời khỏi"}		
		})
end
