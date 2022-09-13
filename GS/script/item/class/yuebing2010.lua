-- 文件名　：yuebing2010.lua
-- 创建者　：zhoupengfeng
-- 创建时间：2010-08-23 14:13:54
-- 描  述  ：2010中秋月饼

local tbYuebing = Item:GetClass("yuebing2010");

tbYuebing.tbTask	= 
{
	[1001] = 177,
	[1002] = 178,
	[1003] = 179,
}

function tbYuebing:OnUse()
	local nTask = self.tbTask[it.nParticular]
	if nTask and EventManager:GetTask(nTask) <= (tonumber(os.date("%Y%m%d", GetTime()))) then
		local tbOpt ={
			{"确定使用",	self.CheckUse, self, it.dwId},
			{"Để ta suy nghĩ lại"},
		};
		Dialog:Say(string.format("您今天尚未换取%s月饼奖励，确定使用吗？", it.szName),tbOpt);
	else
		self:DoUse(it);
	end
	return 0;
end

function tbYuebing:CheckUse(nItemId)
	local pItem =  KItem.GetObjById(nItemId);
	if pItem then
		self:DoUse(pItem);
	end
end

function tbYuebing:DoUse(pItem)
	if pItem.nCount <= 1 then
		if pItem.Delete(me) ~= 1 then
			return;
		end
	else
		pItem.SetCount(pItem.nCount - 1);
	end
	me.AddBindMoney(100);
end