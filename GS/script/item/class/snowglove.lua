-- 雪仗手套
-- zhouchenfei

local tbItem = Item:GetClass("snowglove");

function tbItem:OnUse()
	if it.nLevel == 1 then
		local tbOpt = {
			{"确认", NewEPlatForm.ItemChangeOther, NewEPlatForm, it},
			{"Để ta suy nghĩ thêm"}}
		Dialog:Say(string.format("道具<color=yellow>%s<color>为家族竞技道具，现在开放新家族趣味竞技，道具可以兑换为新属性道具，您确定兑换吗？",it.szName), tbOpt);
		return;
	elseif it.nLevel == 2 then
		local tbOpt = {
			{"兑换为别的道具", NewEPlatForm.ItemChange, NewEPlatForm, it},
			{"Để ta suy nghĩ thêm"}}
		local nRet, szString = NewEPlatForm:CheckCanUpdate(it);
		if nRet == 1 then
			table.insert(tbOpt, 2, {"升级道具<item=".. szString..">", NewEPlatForm.ItemUpdate, NewEPlatForm, it});
		end
		Dialog:Say(string.format("道具<color=yellow>%s<color>可进行下列操作，请问您需要什么操作？",it.szName), tbOpt);
		return;
	end
end

function tbItem:GetTip(nState)
	
	local szTip = "";
	local nNowCount = it.GetGenInfo(1, 0);
	nNowCount = 10 - nNowCount;
	szTip = string.format("参加活动的次数还剩下%d次", nNowCount);
	return szTip;
end