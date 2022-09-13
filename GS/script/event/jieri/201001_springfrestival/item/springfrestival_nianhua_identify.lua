-- 文件名　：nianhua_identify.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-29 09:12:13
-- 描  述  ：鉴定后的年画

local tbItem 	= Item:GetClass("picture_newyear_d");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

function tbItem:OnUse()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpringFrestival.VowTreeOpenTime or nData > SpringFrestival.VowTreeCloseTime then	--活动期间
		Dialog:Say("没有在活动期间，您还不能使用该物品！", {"知道了"});
		return;
	end
	Dialog:Say("这张年画您可以将其加入收藏盒保存起来，也可以加入收集册来换取奖励，有何想法？",
			{"存放到年画收藏盒", self.Add2Box, self,  it.dwId},
			{"加入年画收集册", self.Add2Book, self,  it.dwId},
			{"Để ta suy nghĩ thêm"}
			);
end

--存放到年画收藏盒
function tbItem:Add2Box(nItemId)
	--背包判断
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，整理下再来！",{"知道了"});
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if pItem then
		local tbItem = me.FindItemInAllPosition(unpack(SpringFrestival.tbNianHua_box));
		if #tbItem == 0 then		
			me.AddItem(unpack(SpringFrestival.tbNianHua_box));
		end
		local tbItemEx = me.FindItemInAllPosition(unpack(SpringFrestival.tbNianHua_book));
		if #tbItemEx == 0 then			
			me.AddItem(unpack(SpringFrestival.tbNianHua_book));
		end		
		local nNum = pItem.nLevel;
		local nCount = me.GetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_NIANHUA_BOX + nNum - 1) or 0;
		if nCount >= 20 then
			Dialog:Say("您的收藏盒这种年画已经放满了，不能再保存进去。",{"知道了"});
			return;
		end
		nCount = nCount + 1;
		me.SetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_NIANHUA_BOX + nNum - 1, nCount);
		pItem.Delete(me);
	end
end

--加入年画收集册
function tbItem:Add2Book(nItemId)
	--背包判断
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，整理下再来！",{"知道了"});
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if pItem then
		local tbItem = me.FindItemInAllPosition(unpack(SpringFrestival.tbNianHua_box));
		if #tbItem == 0 then
			me.AddItem(unpack(SpringFrestival.tbNianHua_box));			
		end
		local tbItemEx = me.FindItemInAllPosition(unpack(SpringFrestival.tbNianHua_book));
		if #tbItemEx == 0 then
			me.AddItem(unpack(SpringFrestival.tbNianHua_book));			
		end
		local nNum = pItem.nLevel;
		local nFlag = me.GetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_NIANHUA_BOOK+ nNum - 1) or 0;
		if nFlag == 1 then
			Dialog:Say("您的收集册中已经有了这种年画，不能再加入了。您可以将其保存到收藏盒中或卖给其他玩家。",{"知道了"});
			return;
		end
		me.SetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_NIANHUA_BOOK + nNum - 1, 1);
		pItem.Delete(me);
	end	
end
