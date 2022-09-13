-- 文件名　：kinwardrums.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-08-11 10:36:51
-- 功能    ：家族战鼓

local tbItem = Item:GetClass("kinwardrums");
tbItem.nDuration	= Env.GAME_FPS * 3600 * 3;
tbItem.nSkillId	= 2240;

function tbItem:OnUse()
	Dialog:Say("家族战鼓，能让你在家族关卡中有几率获得额外古币，你确定使用吗？", {
			{"Xác nhận", self.SureUse, self, it.dwId},
			{"Để ta suy nghĩ lại"},
		});
	return 0;
end

function tbItem:SureUse(dwId)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end

	if pItem.nCount <= 1 then
		if (me.DelItem(pItem,  Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1) then
			Dbg:WriteLog("kinwardrums", string.format("%s扣除%s物品失败", me.szName, pItem.szName));
			return 0;
		end
	else
		pItem.SetCount(pItem.nCount - 1); 
	end

	me.AddSkillState(self.nSkillId, 1, 1, self.nDuration, 1, 0, 1);
	return 1;
end
