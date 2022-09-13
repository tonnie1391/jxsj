-- 文件名　：medic.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-02 09:40:06
-- 描  述  ：

local tbItem 			= Item:GetClass("medicpaper");
tbItem.szInfo = '"Bổn Thảo Bí Phương" hội tụ tinh hoa của trời đất!';
tbItem.tbMedic ={
			[1] = {
				{18,	1,	505,	1},	--回天丹箱
				{18,	1,	506,	1},	--大补散箱
				{18,	1,	538,	1},	--大逃杀万灵丹-Rương
			},
			[2] = {				
				{18,	1,	497,	1},	--九转还魂丹箱
				{18,	1,	498,	1},	--首乌还神丹箱
				{18,	1,	539,	1},	--大逃杀万灵丹-Rương
			},
		};
tbItem.tbMedicName = {
			[1] = {
				"Hàn Vũ Hồi Huyết Đơn-Rương (Thấp)",
				"Hàn Vũ Hồi Nội Đơn-Rương (Thấp)",
				"Song Hồi Dược-Rương (Thấp)",
			},
			[2] = {
				"Hàn Vũ Hồi Huyết Đơn-Rương (Cao)",
				"Hàn Vũ Hồi Nội Đơn-Rương (Cao)",
				"Song Hồi Dược-Rương (Cao)",
			},
		};
function tbItem:OnUse()
	local tbOpt = {};
	for i =1 , 3 do
		table.insert(tbOpt, {self.tbMedicName[DaTaoSha:GetPlayerMission(me).nLevel][i], self.Select, self, i, it.dwId});
	end
	Dialog:Say(self.szInfo, tbOpt);
	return 0;
end

function tbItem:Select(nType, nId)	
	me.AddItem(unpack(self.tbMedic[DaTaoSha:GetPlayerMission(me).nLevel][nType]));
	local pItem = KItem.GetObjById(nId);
	if pItem then
		pItem.Delete(me);
	end
end
