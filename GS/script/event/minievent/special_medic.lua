-- 文件名　：special_medic.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-08-13 17:20:08
-- 福利药箱

SpecialEvent.tbMedicine_2012 = SpecialEvent.tbMedicine_2012 or {};
local tbMedicine_2012 = SpecialEvent.tbMedicine_2012;

tbMedicine_2012.TASK_GROUP_MEDICINE = 2199;
tbMedicine_2012.TASK_GET_MEDICINE_TIME	= 1;
tbMedicine_2012.TASK_GET_MEDICINE_NUM	= 2;

tbMedicine_2012.tbFreeMedicine = {
	[1] = {
		[1] = {18,1,1783,1},
		[2] = {18,1,1784,1},
		[3] = {18,1,1785,1},
		nCount = 1,
		nLevel = 50,
		},
	[2] = {
		[1] = {18,1,1783,2},
		[2] = {18,1,1784,2},
		[3] = {18,1,1785,2},
		nCount = 2,
		nLevel = 70,
		},
	[3] = {
		[1] = {18,1,1783,3},
		[2] = {18,1,1784,3},
		[3] = {18,1,1785,3},
		nCount = 3,
		nLevel = 90,
		},
	[4] = {
		[1] = {18,1,1783,4},
		[2] = {18,1,1784,4},
		[3] = {18,1,1785,4},
		nCount = 4,
		nLevel = 200,
		},
	};

function tbMedicine_2012:GetMedicine()
	local nRes, szMsg = self:CanGetMedicine();
	if nRes == 0 then
		Dialog:Say(szMsg);
		return;
	end
	
	local tbOpt = {
		{"Hồi Huyết Đơn-Rương", self.GetMedicine2, self, 1},
		{"Hồi Nội Đơn-Rương", self.GetMedicine2, self, 2},
		{"Càn Khôn Tạo Hóa Hoàn-Rương", self.GetMedicine2, self, 3},
		{"Ta chỉ đến xem thôi"},
		};
	Dialog:Say(string.format("Giang hồ hiểm ác, đan dược lúc nào cũng phải có trong người. Hãy nhận rương thuốc của ta.<enter><enter>Ngươi có thể nhận <color=green>%s rương thuốc miễn phí<color> hôm nay.", nRes), tbOpt);
end

function tbMedicine_2012:GetMedicine2(nType)
	local nRes, vMsg = self:CanGetMedicine();
	if nRes == 0 then
		Dialog:Say(vMsg);
		return;
	end
	
	local pItem = me.AddItem(unpack(self.tbFreeMedicine[vMsg][nType]));
	if pItem then
		me.SetItemTimeout(pItem, 24*60, 0);
		me.SetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_NUM, me.GetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_NUM) + 1);
		Dbg:WriteLog("Medicine_2012", string.format("%s 获得药品 %s", me.szName, pItem.szName));
	end
end

function tbMedicine_2012:CanGetMedicine()
	if me.nLevel < 30 then
		return 0, "你需要达到30级才能领取药品。";
	end
	local nTime = tonumber(os.date("%Y%m%d", GetTime()));
	local nLevel = 0;
	for nLevelEx, tbMedic in ipairs(tbMedicine_2012.tbFreeMedicine) do
		if me.nLevel < tbMedic.nLevel then
			nLevel = nLevelEx;
			break;
		end
	end
	local tbMedic = self.tbFreeMedicine[nLevel];
	if not tbMedic then
		return 0, "Hôm nay không thể nhận, mai hãy đến gặp ta.";
	end
	local nTime = tonumber(GetLocalDate("%Y%m%d"));
	
	local nLastTime = me.GetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_TIME);
	local nNum = me.GetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_NUM);
	if nTime ~= nLastTime then
		me.SetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_TIME, nTime);
		me.SetTask(self.TASK_GROUP_MEDICINE, self.TASK_GET_MEDICINE_NUM, 0);
		nNum = 0;
	end
	if nNum >= tbMedic.nCount then
		return 0, "Hôm nay đã nhận thuốc miễn phí rồi!";
	end
	if me.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ 1 ô trống";
	end
	return tbMedic.nCount - nNum, nLevel;
end



Require("\\script\\item\\class\\medicine.lua"); 

local tbMedicine = Item:NewClass("fulimedicine", "medicine");
if not tbMedicine then
	tbMedicine = Item:GetClass("fulimedicine");
end

------------------------------------------------------------------------------------------
-- public

function tbMedicine:OnUse()
	local nDomainUsable = me.GetNpc().GetRangeDamageFlag();
	local szMapType = GetMapType(me.nMapId);
	if nDomainUsable == 0 and szMapType == "fight" then
		me.Msg("Đạo cụ không thể sử dụng tại bản đồ này.");
		return 0;
	end
	return  self._tbBase:OnUse();
end

function tbMedicine:CheckUsable()
	local nDomainUsable = me.GetNpc().GetRangeDamageFlag();
	local szMapType = GetMapType(me.nMapId);
	if nDomainUsable == 0 and szMapType == "fight" then
		me.Msg("Đạo cụ không thể sử dụng tại bản đồ này.");
		return 0;
	end
	return 1;
end
