-- 文件名　：mingyang_identify.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-31 14:16:07
-- 描  述  ：

local tbItem 	= Item:GetClass("mingyang_identify");
SpecialEvent.LaborDay = SpecialEvent.LaborDay or {};
local LaborDay = SpecialEvent.LaborDay or {};

function tbItem:OnUse()
	if LaborDay.IVER_nHero_Famous == 0 then
		return;
	end
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < LaborDay.OpenTime or nData > LaborDay.CloseTime then
		Dialog:Say("没有在活动期间，您还不能使用该物品！", {"知道了"});
		return;
	end
	Dialog:Say("这块牌子您可以加入收集册来换取奖励，有何想法？",			
			{"加入收集册", self.Add2Book, self,  it.dwId},
			{"Để ta suy nghĩ thêm"}
			);
end

--加入收集册
function tbItem:Add2Book(nItemId)
	--背包判断
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("需要1格背包空间，整理下再来！",{"知道了"});
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if pItem then		
		local tbItemEx = me.FindItemInAllPosition(unpack(LaborDay.tbmingyang_book));
		if #tbItemEx == 0 then
			local pItemEx = me.AddItem(unpack(LaborDay.tbmingyang_book));
			if pItemEx then
				pItemEx.SetTimeOut(0, GetTime() + 30 * 24 * 3600);
				pItemEx.Sync();
			end
		end
		local nNum = pItem.nLevel;
		local nFlag = me.GetTask(LaborDay.TASKID_GROUP,LaborDay.TASKID_BOOK+ nNum - 1);
		if nFlag == 1 then
			Dialog:Say("您的收集册中已经有了这种牌子，不能再加入了。",{"知道了"});
			return;
		end
		me.SetTask(LaborDay.TASKID_GROUP, LaborDay.TASKID_BOOK + nNum - 1, 1);
		pItem.Delete(me);
	end	
end
