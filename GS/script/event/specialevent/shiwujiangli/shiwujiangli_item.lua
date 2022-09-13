-- 文件名　：shiwujiangli.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-05-10 10:01:48
-- 实物奖励
local tbItem = Item:GetClass("shiwujiangli");

function tbItem:OnUse()
	
	local nType = tonumber(it.GetExtParam(1));
	if nType <= 0 then
		me.Msg("道具有问题，请联系GM");
		return 0;
	end
	Dialog:AskString("请输入真实姓名", 15, self.InPutName, self, it.dwId, nType);
	return 0;
end

function tbItem:InPutName(dwItemId, nType, szName)	
	Dialog:AskString("请输入联系电话", 15, self.InPutTel, self, dwItemId, nType, szName);
end

function tbItem:InPutTel(dwItemId, nType, szName, szTel)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return;
	end	
	local szMsg = string.format("恭喜您获得实物奖励<color=green>%s<color>，我们会根据您填写的信息联系您，所以请您务必确认您填写的信息是否正确？\n\n您的联系信息如下：\n真实姓名：<color=yellow>%s<color>\n联系电话：<color=yellow>%s<color>", pItem.szName, szName, szTel);
	local tbOpt = {
		{"Xác nhận", self.OnOK, self, dwItemId, nType, szName, szTel},
		{"Để ta suy nghĩ thêm"},
		}
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:OnOK(dwItemId, nType, szName, szTel)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return;
	end	
	pItem.Delete(me);
	Dbg:WriteLog("shiwujiangli", string.format("%s领取实物奖励%s玩家真实姓名：%s联系方式：%s", me.szName, pItem.szName, szName, szTel));
	GCExcute({"SpecialEvent.tbShiwuJIang:SaveBuff", me.szAccount, me.szName, nType, szName, szTel});
	return 1;
end


