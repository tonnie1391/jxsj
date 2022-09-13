--机关大师
--孙多良
--2008.08.15

local tbNpc = Npc:GetClass("jiguandashi");
tbNpc.tbArmyBag = {20,1,482,1};
tbNpc.tbArmyHandBook = {20,1,483,1};
tbNpc.nTaskGroupId = 2044;	--随机获得零件的任务变量Group
tbNpc.tbTaskId =
{
	--随机获得零件的任务变量
	1,2,3,4,5,6,7,8,9,10,
}

function tbNpc:OnDialog()
	local szMsg = "Thiên địa phân âm dương, vạn vật hóa Ngũ Hành, bổ trợ cho nhau, tương sinh tương khắc. Tinh túy của Cơ quan học không phải là kỹ nghệ tuyệt vời, mà là sáng tạo thuận theo tự nhiên.";
	local tbOpt = 
	{
		{"Dùng độ bền cơ quan đổi vật phẩm", Dialog.OpenShop, Dialog, 129, 10},
		{"Nhận rương cơ quan", self.GetArmyBag, self},
		--{"领取机关材料手册", self.GetArmyHandBook, self},
		{"Nhận sổ tay tài liệu cơ quan", self.recycleHandBook, self},
		{"Kết thúc đối thoại"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetArmyBag()
	if me.nLevel < 80 then
		Dialog:Say("Thiên Cơ Tử: Ngươi chưa đạt cấp 80 không thể nhận vật phẩm.");
		return 0;
	end
	if me.GetTask(1022,117) ~= 1 then
		Dialog:Say("Thiên Cơ Tử: Nhiệm vụ chưa được hoàn thành. hãy đi làm đi");		
		return 0;
	end
	local tbFind1 = me.FindItemInBags(unpack(self.tbArmyBag));
	local tbFind2 = me.FindItemInRepository(unpack(self.tbArmyBag));
	if #tbFind1 <= 0 and #tbFind2 <= 0 then
		if me.CountFreeBagCell() >= 1 then
			local pItem = me.AddItem(unpack(self.tbArmyBag));
			if pItem then
				
			end
			Dialog:Say("Thiên Cơ Tử: Bạn nhận được rương cơ quan.")
		else
			Dialog:Say("Thiên Cơ Tử: Túi của bạn không đủ chỗ.");
		end
	else
		Dialog:Say("Thiên Cơ Tử: Bạn đã nhận được rương cơ quan.")
	end
	return 0;
end

function tbNpc:GetArmyHandBook()
	local tbFind1 = me.FindItemInBags(unpack(self.tbArmyHandBook));
	local tbFind2 = me.FindItemInRepository(unpack(self.tbArmyHandBook));
	if #tbFind1 <= 0 and #tbFind2 <= 0 then
		if me.CountFreeBagCell() >= 1 then
			local pItem = me.AddItem(unpack(self.tbArmyHandBook));
			if pItem then
				pItem.Bind(1);
			end
			Dialog:Say("Thiên Cơ Tử: Bạn nhận được sổ tay tài liệu cơ quan.")
		else
			Dialog:Say("Thiên Cơ Tử: hành trang của bạn không đủ chỗ.");
		end
	else
		Dialog:Say("Thiên Cơ Tử: Bạn nhận được sổ tay tài liệu cơ quan.")
	end
	return 0;
end

function tbNpc:recycleHandBook()
	local tbFind1 = me.FindItemInBags(unpack(self.tbArmyHandBook));
	if #tbFind1 <= 0 then
		Dialog:Say("Thiên Cơ Tử: Bạn không mang theo sổ tay tài liệu cơ quan.")
		return 0;
	end
	for i, nTaskId in pairs(self.tbTaskId) do
		if me.GetTask(self.nTaskGroupId, nTaskId) == 0 then
			Dialog:Say("Thiên Cơ Tử: Bạn chưa thu thập đủ 10 mảnh ghép, hãy đi thu thập tiếp.")
			return 0;
		end
	end
	me.ConsumeItemInBags(1,unpack(self.tbArmyHandBook));
	for i, nTaskId in pairs(self.tbTaskId) do
		me.SetTask(self.nTaskGroupId, nTaskId, 0)
	end
	me.AddExp(1000000);
	me.Earn(10000, Player.emKEARN_TASK_ARMYCAMP);
	KStatLog.ModifyAdd("jxb", "[产出]军营任务", "总量", 10000)
	me.AddMachineCoin(150);
	me.AddRepute(1, 3, 150);
	me.Msg("Bạn nhận được 1000000 kinh nghiệm");
	me.Msg("Bạn nhận được 10000 bạc thường.");
	me.Msg("Bạn nhận được 150 điểm kinh nghệm cơ quan");
	me.Msg("Bạn nhận được 150 điểm độ bền cơ quan");
end
