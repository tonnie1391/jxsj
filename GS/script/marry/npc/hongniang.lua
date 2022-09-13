-- 文件名　：hongniang.lua
-- 创建者　：furuilei
-- 创建时间：2009-11-26 10:19:50
-- 描述	   : 结婚相关npc（红娘）

local tbNpc = Npc:GetClass("marry_hongniang");

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local szMsg = "   Trăm năm tri kỷ khó tìm, tri âm khó gặp, bạn hiền khó quen. Ngươi cần gì ở ta?";
	local tbOpt = 
	{
		{"[Tìm hiểu hệ thống hiệp lữ]", self.Introduce, self},		
		{"[Kết thúc đối thoại]"},
	};
	if EventManager.IVER_bOpenDivorce == 1 then
		table.insert(tbOpt, 2, {"[Đơn phương hủy bỏ hiệp lữ]", Marry.DialogNpc.OnSingleDivorce, Marry.DialogNpc});
		table.insert(tbOpt, 2, {"[Song phương hủy bỏ hiệp lữ]", Marry.DialogNpc.OnDivorce, Marry.DialogNpc});
		table.insert(tbOpt, 2, {"[Đơn phương hủy bỏ quan hệ nạp cát]", Marry.DialogNpc.OnSingleRemoveQiuhun, Marry.DialogNpc});
		table.insert(tbOpt, 2, {"[Song phương hủy bỏ quan hệ nạp cát]", Marry.DialogNpc.OnRemoveQiuhun, Marry.DialogNpc});		
	end
	-- 周年庆活动
	local tbGift = SpecialEvent.ZhouNianQing2011:BuildHongNiangZhouNianQingOption();
	if (tbGift) then
		table.insert(tbOpt, #tbOpt, tbGift);
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:Introduce()
	local tbNpc = Npc:GetClass("marry_dlgjiaoyunpc");
	tbNpc:OnDialog();
end


