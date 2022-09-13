-- 文件名  : xidianquan.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-12 13:44:28
-- 描述    : 大逃杀 洗点券

local tbItem = Item:GetClass("xidianquan");

function tbItem:OnUse()
	local tbOpt = {
			{"Sử dụng",	self.OnUseEx, self, it},	
			{"Để ta suy nghĩ thêm"},
	};
			
	Dialog:Say("Bạn muốn tẩy điểm tiềm năng và kỹ năng đúng chứ?",tbOpt);	
end

function tbItem:OnUseEx(pItem)
	me.ResetFightSkillPoint();
	me.UnAssignPotential();
	pItem.Delete(me);
	return 1;	
end