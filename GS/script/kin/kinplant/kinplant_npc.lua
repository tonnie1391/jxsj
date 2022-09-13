-- 文件名　: kinplant_npc.lua
-- 创建者　: jiazhenwei
-- 创建时间: 2011-10-12 19:50:27
-- 功能    : 


local tbNpc1 = Npc:GetClass("KinPlantTree1");

function tbNpc1:OnDialog()
	local szMsg = him.szName..": đang phát triển.\n";
	local tbTemp = him.GetTempTable("Npc").tbKinPlant;
	if not tbTemp then
		Dialog:Say("Cây bệnh, vui lòng liên hệ GM!");
		return 0;
	end
	local nIndex = tbTemp.nIndex;
	local nUpTimeId = tbTemp.nTimerId_up;
	szMsg = szMsg.."Thời gian thu hoạch: "..string.format("%s giờ %s phút %s giây\n", Lib:TransferSecond2NormalTime(math.floor(Timer:GetRestTime(nUpTimeId) / 18)));
	local tbOpt = {{"Để ta suy nghĩ thêm"}};
	local nDredging = KinPlant.tbPlantNpcInfo[nIndex].nDredging;
	--被其他人挖掘等级:1族长，2族长副族长，3正式成员，4荣誉成员，5记名成员(向上兼容)
	local tbKinFigure = {[4] = 5, [5] = 4};	--把记名和荣誉的颠倒位置
	local nKinFigure = tbKinFigure[me.nKinFigure] or me.nKinFigure;
	if (nKinFigure > 0 and nKinFigure <= nDredging) or me.szName == tbTemp.szPlayerName then
		table.insert(tbOpt, 1, {"<color=red>Nhổ lên<color>", KinPlant.TreeDredging, KinPlant, him.dwId, me.nId});
	end
	Dialog:Say(szMsg, tbOpt);
end

local tbNpc2 = Npc:GetClass("KinPlantTree2");

function tbNpc2:OnDialog()
	local szMsg =  him.szName..": Quả đã chín, héo sau: %s\nSố lượng: <color=yellow>%s/%s<color>\nKỹ năng trồng trọt tăng: <color=yellow>%s<color>\nThời tiết tăng: <color=yellow>%s<color>\nPhẩm chất: <color=%s>%s<color>(Tăng:  <color=yellow>%s<color>)\nThứ tự phẩm chất từ thấp đến cao: <color=white>Khỏe mạnh<color>, <color=green>Căng tròn<color>, <color=blue>Tươi ngon<color>, <color=yellow>Năng suất cao<color>, <color=pink>Chất lượng cao<color>";
	local tbTemp = him.GetTempTable("Npc").tbKinPlant;
	if not tbTemp then
		Dialog:Say("Cây có vấn đề!");
		return 0;
	end
	local nUpTimeId = tbTemp.nTimerId_up;
	local szTime = string.format("%s giờ %s phút %s giây\n", Lib:TransferSecond2NormalTime(math.floor(Timer:GetRestTime(nUpTimeId) / 18)));
	local nNum = tbTemp.nNum;
	if not KinPlant.tbPlantInfo[me.dwKinId] or not nNum or not KinPlant.tbPlantInfo[me.dwKinId][nNum] then
		return 0;
	end
	local nIndex = tbTemp.nIndex;
	local tbInfo = KinPlant.tbPlantNpcInfo[nIndex];
	local nMaxAward = tbInfo.nMaxAwardCount;
	local nCount = KinPlant.tbPlantInfo[me.dwKinId][nNum][4];
	local nWeatherType = KinPlant.tbPlantInfo[me.dwKinId][nNum][5];
	local nWeatherCount = KinPlant:GetWeatherRate(nIndex, nWeatherType)
	local nKinCount = KinPlant:GetKinRate(me.dwKinId);
	local nHealth = KinPlant.tbPlantInfo[me.dwKinId][nNum][6];
	local szHealthTitle = "";
	local szHealthColor = "";
	for i, tb in ipairs(KinPlant.tbChangRate) do
		if tb[2] == nHealth then
			szHealthTitle, szHealthColor = unpack(KinPlant.tbHealthTitile[i]);
			break;
		end
	end
	szMsg =string.format(szMsg, szTime, nCount, nMaxAward, nKinCount, nWeatherCount, szHealthColor, szHealthTitle, nHealth);
	if KinPlant.nTimes > 1 then
		szMsg = szMsg..string.format("\n\n<color=pink>Bội số thu hoạch là: <color><color=yellow>%s lần<color>", KinPlant.nTimes);
	end
	local tbOpt = {
		{"<color=yellow>Thu hoạch nông sản<color>", KinPlant.GatherSeed, KinPlant, him.dwId, me.nId},
		{"Hiệp khách đến viếng", self.Infor, self, tbTemp},
		--{"<color=red>铲除植物<color>", KinPlant.TreeDredging, KinPlant, him.dwId, me.nId},
		{"Để ta suy nghĩ thêm"}};
	local nDredging = KinPlant.tbPlantNpcInfo[nIndex].nDredging;
	--被其他人挖掘等级:1族长，2族长副族长，3正式成员，4荣誉成员，5记名成员(向上兼容)
	local tbKinFigure = {[4] = 5, [5] = 4};	--把记名和荣誉的颠倒位置
	local nKinFigure = tbKinFigure[me.nKinFigure] or me.nKinFigure;
	if (nKinFigure > 0 and nKinFigure <= nDredging) or me.szName == tbTemp.szPlayerName then
		table.insert(tbOpt, 3, {"<color=red>Nhổ lên<color>", KinPlant.TreeDredging, KinPlant, him.dwId, me.nId});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc2:Infor(tbTemp)
	local szMsg = "Hiệp khách đến viếng bao gồm: \n";
	for szName, _ in pairs(tbTemp.tbGatherSeed) do
		szMsg = szMsg.."<color=yellow>"..szName.."<color>\n";
	end
	Dialog:Say(szMsg);
end

--公告板，查看订单和天气
local tbNpc3 = Npc:GetClass("KinPlantTaskBoard");

function tbNpc3:OnDialog()	
	me.CallClientScript({"UiManager:OpenWindow", "UI_KINPLANTTASK"});
end

--吕丰年，种子商店和订单种子发放
local tbNpc4 = Npc:GetClass("lvfengnian");

function tbNpc4:OnDialog()
	local szMsg = "Phải nói Đào Nguyên tốt thật, ta một mình cày cấy, lòng lại thảnh thơi. Người trẻ tuổi có muốn trồng thử gì không?\n  Chỗ ta hạt giống gì cũng có, ngươi có thể mang hoa màu đến đổi phần thưởng. Mỗi ngày <color=yellow>09:00~23: 00<color> trong Vườn Hoa Quả sẽ có đất trống, những giờ khác không thể trồng được. Nhưng...<color=green> nên tập trung nghiên cứu 1 loại<color> thực vật thôi và cũng đừng tham lam, chỉ trồng <color=yellow>3 cây/ngày<color>, nếu không đừng trách lão không nhắc ngươi.\n<color=red>(Các vị hiệp khách có thể xem danh vọng trồng trọt tại giao diện danh vọng)<color>";
	local tbOpt = {
		{"Cửa hàng hạt giống bội thu", self.OpenShop, self},
		{"Đổi phần thưởng", self.ChangeFruit, self},
		{"<color=yellow>Nhận giống Cây Phúc Lộc<color>", KinPlant.GetSeedWeekly, KinPlant},
		{"Để ta suy nghĩ thêm"}
		};
	local cKin = KKin.GetKin(me.dwKinId)
	local tbOptEx = {{"Để ta suy nghĩ thêm"}};
	if KinPlant:MergeDialog(tbOptEx, him.nTemplateId) == 1 then
		table.insert(tbOpt, 1, {"<color=green>Đơn hàng đặt biệt<color>", self.Task, self, tbOptEx})
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc4:Task(tbOpt)
	local szMsg = "Ta vẫn còn một số đơn hàng đặc biệt, và sẽ có thưởng hậu hĩnh sau khi hoàn thành, hạt giống ta sẽ đưa cho ngươi. Có muốn thử sức không? Mỗi thứ 2 hàng tuần sẽ bắt đầu lại những đơn hàng đặc biệt. Nhưng đừng tham lam, <color=green>chỉ có thể nhận 1 tuần 1 lần thôi<color>."
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc4:OpenShop()
	me.OpenShop(226, 1);
end

function tbNpc4:ChangeFruit()
	Dialog:OpenGift("Hãy đặt thực vật muốn đổi phần thưởng vào.\n<color=green>Lương thực<color> nhận được <color=yellow>kinh nghiệm<color>\n<color=green>Hoa quả<color> nhận được <color=yellow>huyền tinh<color>\n<color=green>Hoa tươi<color> nhận được <color=yellow>bạc khóa<color>", nil ,{self.OnOpenGiftOk, self});
end

function tbNpc4:OnOpenGiftOk(tbItemObj, nFlag)
	local vCount, vMsg = self:ChechItem(tbItemObj);
	if (vCount == 0) then
		me.Msg(vMsg or "Mặt hàng không đúng hoặc số lượng chưa đủ!");
		return 0;
	end
	if not nFlag then
		local szMsg = "Đây là phần thưởng cho việc giao hàng: \n";
		local szExpMsg = "";
		local szMoneyMsg = "";
		local szXuanJInMsg = "";		
		for i, v in ipairs(vMsg) do
			if i == 1 then
				szExpMsg = szExpMsg .."Kinh nghiệm: <color=yellow>"..math.floor(me.GetBaseAwardExp() * v).."<color>\n";
			elseif i == 3 then
				szMoneyMsg = szMoneyMsg .."Bạc khóa: <color=yellow>"..v.."<color>\n";
			elseif i == 2 then
				szXuanJInMsg = szXuanJInMsg.."Huyền tinh: ";
				for nLevel, vCount in pairs(v) do
					if type(vCount) ~= "table" then
						szXuanJInMsg = szXuanJInMsg .. " <color=yellow>Huyền tinh cấp 8<color>: <color=yellow>"..vCount.." viên<color>\n";
					else
						local b = 1;
						for nLevelEx, tb in pairs(vCount) do
							if b == 1 then
								szXuanJInMsg = szXuanJInMsg.."<color=yellow>"..tb[2].."%<color> nhận được <color=yellow>Huyền tinh cấp ".. nLevelEx..": 1 viên<color>\n";
								b = 0;
							else
								szXuanJInMsg = szXuanJInMsg.."<color=yellow>".. (100 - tb[1]).."%<color> nhận được <color=yellow>Huyền tinh cấp ".. nLevelEx.."<color>: 1 viên\n";
							end
						end
					end
				end
			end
		end
		szMsg = szMsg..szExpMsg..szMoneyMsg..szXuanJInMsg;
		Dialog:Say(szMsg, {{"Xác nhận", self.OnOpenGiftOk, self, tbItemObj, 1},{"Để ta suy nghĩ thêm"}});
		return 0;
	end
	for _, pItem in pairs(tbItemObj) do
		local szItem = string.format("%s,%s,%s,%s", pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);	
		pItem[1].Delete(me);
	end
	--三个类型的奖励分别算
	KinPlant:ChangeFruit(vCount);
	for szItem, nCount in pairs(vCount) do
		if KinPlant.tbAcheveMent[szItem] and nCount >= 20 then
			Achievement:FinishAchievement(me, KinPlant.tbAcheveMent[szItem]);	--454-462成就
		end
	end
end

function tbNpc4:ChechItem(tbItemObj)
	local tbItem = {};
	local tbCount = {};
	for _, pItem in pairs(tbItemObj) do
		local szItem = string.format("%s,%s,%s,%s", pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if not KinPlant.tbPlantFruit[szItem] then
			return 0, "Ngươi đưa ta thứ gì đây?";
		end
		tbCount[szItem] = tbCount[szItem] or 0;
		tbCount[szItem] = tbCount[szItem] + pItem[1].nCount;
	end
	local nNeedBag, tbAward = KinPlant:GetChangeFNeedBag(tbCount);
	if me.CountFreeBagCell() < nNeedBag then
		return 0, string.format("Hành trang không đủ %s ô trống.", nNeedBag);
	end
	if tbAward[3] > 0 and me.GetBindMoney() + tbAward[3] > me.GetMaxCarryMoney() then
		return 0, "Lượng bạc mang theo đã đạt giới hạn.";
	end
	return tbCount, tbAward;
end
