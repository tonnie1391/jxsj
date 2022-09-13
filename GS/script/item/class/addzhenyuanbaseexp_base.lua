-- 文件名　：addzhenyuanbaseexp_base.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-07-12 15:54:29
-- 功能    ：真元历练累计值
local tbBase = Item:GetClass("addzhenyuanbaseexp_base");
tbBase.Task_Group = 2171;
tbBase.Task_UseData = 1;
tbBase.Task_UseCount = 2;
tbBase.nMaxCountDay = 100;		--每天限制使用多少

function tbBase:OnUse()
	local nValue =tonumber(it.GetExtParam(1));
	if nValue <= 0 then
		Dialog:Say("道具有问题，请联系GM！");
		return 0;
	end
	local nRet = Player:CheckTask(self.Task_Group, self.Task_UseData, "%Y%m%d", self.Task_UseCount, self.nMaxCountDay);
	if nRet == 0 then
		me.Msg(string.format("Chỉ có thể sử dụng %s cái trong ngày", self.nMaxCountDay));
		return 0;
	end
	
	local nOrg = me.GetTask(Item.tbZhenYuan.EXPSTORE_TASK_MAIN, Item.tbZhenYuan.EXPSTORE_TASK_SUB);
	local nNew = nOrg + nValue;
	if nNew > Item.tbZhenYuan.EXPSTORE_MAX then
		me.Msg("Kinh nghiệm tích lũy đã đầy, không thể sử dụng thêm");
		return 0;
	end
	local nCount = me.GetTask(self.Task_Group, self.Task_UseCount);
	me.SetTask(Item.tbZhenYuan.EXPSTORE_TASK_MAIN, Item.tbZhenYuan.EXPSTORE_TASK_SUB, nNew);
	if nNew == Item.tbZhenYuan.EXPSTORE_MAX then
		me.CallClientScript({"PopoTip:ShowPopo", 28});
	end
	me.SetTask(self.Task_Group, self.Task_UseCount, nCount + 1);
	me.Msg(string.format("Nhận được %s kinh nghiệm tu luyện.", nValue));
	return 1;
	
end

function tbBase:GetTip()
	local nValue =tonumber(it.GetExtParam(1));	
	if nValue <= 0 then
		return "";
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = me.GetTask(self.Task_Group, self.Task_UseData);
	local nCount = me.GetTask(self.Task_Group, self.Task_UseCount);
	if nDate ~= nNowDate then
		nCount = 0;
	end
	local szMsg = string.format("Giới hạn sử dụng trong ngày: %s/%s\n\n<color>", nCount, self.nMaxCountDay);
	if nCount >= self.nMaxCountDay then
		szMsg = "<color=red>"..szMsg;
	else
		szMsg = "<color=green>"..szMsg;
	end
	return szMsg..string.format("<color=green>Dùng tăng kinh nghiệm tu luyện Chân Nguyên thêm <color><color=yellow>%s<color><color=green> phút<color>", nValue);	
end
