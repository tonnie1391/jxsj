-- 文件名　：wuqi_qianghuajuanzhou.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-29 11:29:01
-- 描  述  ：

local tbqianghuajuanzhou = Item:GetClass("wuqiqianghua");
tbqianghuajuanzhou.szInfo = "Bùa cường hóa vũ khí có thể sử dụng hoặc tặng cho đồng đội. <color=yellow>Tối đa có thể tăng lên +%s<color>"

function tbqianghuajuanzhou:OnUse()	
	local nMaxQianghua = 14;
	local tbOpt = {
			{"Tặng cho đồng đội",	DaTaoSha.tbqianghuajuanzhou.Trade, DaTaoSha.tbqianghuajuanzhou, it.dwId, 1},	
			{"Đóng lại"},
	};	
	local pEquip = me.GetItem(Item.ROOM_EQUIP, 3, 0);	
	if not DaTaoSha:GetPlayerMission(me) then
		return;
	end
	if DaTaoSha:GetPlayerMission(me).nLevel ~= 1 then	
		nMaxQianghua = 14;
	end
	if pEquip and pEquip.nEnhTimes < nMaxQianghua then
		table.insert(tbOpt, 1, {"Sử dụng",  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou ,3, it.dwId});
	end
	Dialog:Say(string.format(self.szInfo,nMaxQianghua),tbOpt);
	
	return 0;
end;
