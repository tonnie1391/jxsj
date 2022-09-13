-- yelanmingdeng.lua
-- zhouchenfei
-- 2010-12-27 15:37:43
-- 夜岚明灯脚本

local tbItem = Item:GetClass("yelanmingdeng");
function tbItem:OnUse()
	if it.nLevel < 3 then
		local tbOpt = {
			{"Xác nhận", NewEPlatForm.ItemChangeOther, NewEPlatForm, it},
			{"Để ta suy nghĩ thêm"}}
		Dialog:Say(string.format("Vật phẩm <color=yellow>%s<color> là vật phẩm dùng cho thi đấu Gia tộc, bạn có thể sử dụng vật phẩm này để đổi vật phẩm khác. Chắc chắn chứ?",it.szName), tbOpt);
		return;
	elseif it.nLevel >= 3 then
		local tbOpt = {
			{"Hoán đổi vật phẩm", NewEPlatForm.ItemChange, NewEPlatForm, it},
			{"Để ta suy nghĩ thêm"}}
		local nRet, szString = NewEPlatForm:CheckCanUpdate(it);
		if nRet == 1 then
			table.insert(tbOpt, 2, {"Nâng cấp <item=".. szString..">", NewEPlatForm.ItemUpdate, NewEPlatForm, it});
		end
		Dialog:Say(string.format("Vật phẩm <color=yellow>%s<color> có thể thực hiện một số thao tác sau:",it.szName), tbOpt);
		return;
	end
end

--function tbItem:OnUse()
--	local tbConsole = CastleFight:GetConsole();
--	if (not tbConsole) then
--		Dialog:Say("目前活动未开放！不能使用Vật phẩm ！");
--		return 0;
--	end
--
--	if (tbConsole:CheckState() ~= 1) then
--		Dialog:Say("目前活动尚未开放！不能使用Vật phẩm ！");
--		return 0;
--	end
--
--
--	local nTotal = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
--	local nCountSum, nCount, nCountEx = CastleFight:IsSignUpByTask(me);
--	if (nTotal + nCountSum >= CastleFight.DEF_MAX_TOTAL_NUM) then
--		me.Msg(string.format("您已经参加活动的次数和剩余挑战资格已经超过最大参加活动的次数,不能使用！"));
--		return 0;
--	end
--	
--	local nTimes		= me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_USE_ITEM_TIMES);
--	
--	if (nTimes <= 0) then
--		Dialog:Say("您已经用完了今天使用夜岚明灯的次数,不能使用夜岚明灯！");
--		return 0;
--	end	
--		
--	me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_EXCOUNT, me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_EXCOUNT) + CastleFight.DEF_CHANGENUME);
--	
--	nTimes = nTimes - 1;
--	if (nTimes < 0) then
--		nTimes = 0;
--	end
--	
--	me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_USE_ITEM_TIMES, nTimes);
--	Dbg:WriteLog("CastleFight", "yelanmingdeng", me.szName.."夜岚明灯换取三次次数");
--	me.Msg(string.format("您获得了决战夜岚关的%s次机会！", CastleFight.DEF_CHANGENUME));
--	return 1;
--end

function tbItem:GetTip(nState)
	
	local szTip = "";
	local nNowCount = it.GetGenInfo(1, 0);
	nNowCount = 10 - nNowCount;
	szTip = string.format("Số lượt tham gia hoạt động còn: <color=red>%d<color>", nNowCount);
	return szTip;
end
