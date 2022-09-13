

local tbNpc = Npc:GetClass("machuanshan")

local DYN_MAP_ID_START = 65535;--动态地图起始

function tbNpc:OnDialog()
	if HomeLand:CheckOpen() == 1 then
		local szMsg = "　　Ngươi cần gì ở ta?";
		local nRet = HomeLand:GetMapIdByKinId(me.dwKinId);
		if me.nMapId == nRet or (nRet <= 0 and me.nMapId >= DYN_MAP_ID_START) then
			KinGame:OnEnterDialog();
			return 0;
		else
			local tbOpt = 
			{
				{"<color=green>Lãnh địa Gia tộc<color>", HomeLand.OnEnterDialog, HomeLand},
				{"Tính năng Gia tộc", KinGame.OnEnterDialog, KinGame},
				{"Kết thúc đối thoại"},	
			};
			Dialog:Say(szMsg, tbOpt);
		end
	else
		KinGame:OnEnterDialog();
	end
end