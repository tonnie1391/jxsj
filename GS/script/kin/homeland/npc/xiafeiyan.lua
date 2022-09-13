Require("\\script\\kin\\homeland\\homeland_def.lua")

local tbNpc = Npc:GetClass("xiafeiyan");

function tbNpc:OnDialog()
	if (Item.tbStone:GetOpenDay() == 0) then
		local tbOpt = {
			{"Ta sẽ quay lại sau"},
		};
		Dialog:Say("Cửa hàng vẫn chưa hoạt động.", tbOpt);
		return;
	end
	Kin:RefreshSkillInfo(me.dwKinId);			-- 在这里同步到客户端
	local bFangJuEnable = 0;
	local bShouShiEnable = 0;
	local bWeaponEnable = 0;
	local nSkillPoint = 0;
	for nPos, tbCon in pairs(Item.EQUIPPOS_MAKEHOLE_KIN_SKILLLEVEL) do
		if (tbCon[1][2] == 1) then
			local nSkillLevel = Kin:GetSkillLevel(me.dwKinId, unpack(tbCon[1]));
			if (nSkillLevel > 0) then
				bFangJuEnable = 1;
				nSkillPoint = nSkillPoint + 1;
			end
		elseif (tbCon[1][2] == 2) then
			local nSkillLevel = Kin:GetSkillLevel(me.dwKinId, unpack(tbCon[1]));
			if (nSkillLevel > 0) then
				bShouShiEnable = 1;
				nSkillPoint = nSkillPoint + 1;
			end
		elseif (tbCon[1][2] == 3) then
			local nSkillLevel = Kin:GetSkillLevel(me.dwKinId, unpack(tbCon[1]));
			if (nSkillLevel > 0) then
				bWeaponEnable = 1;
				nSkillPoint = nSkillPoint + 1;
			end
		end
	end 
	local tbOpt = {};
	if (bFangJuEnable == 1) then
		table.insert(tbOpt, {"Đục lỗ Trang bị", self.ShowMakeHoleList, self, 1});
	else
		table.insert(tbOpt, {"<color=gray>Đục lỗ Trang bị<color>", self.OnRefuse, self});
	end
	
	if (bShouShiEnable == 1) then
		table.insert(tbOpt, {"Đục lỗ Trang sức", self.ShowMakeHoleList, self, 2});
	else
		table.insert(tbOpt, {"<color=gray>Đục lỗ Trang sức<color>", self.OnRefuse, self});
	end

	if (bWeaponEnable == 1) then
		table.insert(tbOpt, {"Đục lỗ Vũ khí", self.CheckPermission, self, {self.PreMakeHole, self, 3}});
	else
		table.insert(tbOpt, {"<color=gray>Đục lỗ Vũ khí<color>", self.OnRefuse, self});
	end
	table.insert(tbOpt, {"Thôi thôi"});
	local szMsg = "    Ta có thể giúp ngươi mở khóa Lỗ thứ 3 trên trang bị.\n";
	szMsg = szMsg .. "    Tình trạng tăng điểm kũ năng [Đuc lỗ trang bị] của gia tộc quyết định bạn có thể cải tạo được loại hình trang bị nào.\n";
	szMsg = szMsg .. "    Ta chỉ có trách nhiệm phục vụ thành viên chính thức và thành viên danh dự trong Tộc, chúc may mắn.\n";
	szMsg = szMsg .. "    Kỹ năng gia tộc hiện tại: <color=yellow>["..nSkillPoint.."/10]<color>\n";
	szMsg = szMsg .. "    Điểm cống hiến gia tộc: <color=yellow>["..me.GetKinSkillOffer().."]<color>";
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ShowMakeHoleList(nEquipType)
	if (me.dwKinId == 0) then		-- 没家族，不知道怎么进来的
		return;
	end
	local tbOpt = {};
	for nPos, tbCon in pairs(Item.EQUIPPOS_MAKEHOLE_KIN_SKILLLEVEL) do
		if (tbCon[1][2] == nEquipType) then			-- 相应的类型
			local tbInsert = nil;
			local nSkillLevel = Kin:GetSkillLevel(me.dwKinId, unpack(tbCon[1]));
			if (nSkillLevel > 0) then		-- 学习了技能了
				tbInsert = {Item.EQUIPPOS_NAME[nPos], self.CheckPermission, self, {self.PreMakeHole, self, nPos}};
			else
				tbInsert = {"<color=gray>"..Item.EQUIPPOS_NAME[nPos].."<color>", self.OnRefuse2, self, nEquipType};
			end
			table.insert(tbOpt, tbInsert);	
		end
	end
		
	table.insert(tbOpt, {"Quay về", self.OnDialog, self});
	Dialog:Say("Hãy lựa chọn trang bị cần đục lỗ", tbOpt);
end

function tbNpc:PreMakeHole(nEquipPos)
	me.OpenEquipHole(Item.HOLE_MODE_MAKEHOLEEX, nEquipPos);
end

function tbNpc:CheckPermission(tbOption)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản của bạn đã bị khóa.");
		Account:OpenLockWindow(me);
		return;
	end
	Lib:CallBack(tbOption);
end

function tbNpc:OnRefuse()
	local tbOpt = {
			{"Quay về", self.OnDialog, self},
		};
	Dialog:Say("Gia tộc bạn chưa mở phần này", tbOpt);
end

function tbNpc:OnRefuse2(nEquipType)
	local tbOpt = {
			{"Quay về", self.ShowMakeHoleList, self, nEquipType},
		};
	Dialog:Say("Gia tộc bạn chưa mở phần này", tbOpt);
end
