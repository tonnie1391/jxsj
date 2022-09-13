local tbItem = Item:GetClass("fuxiulingpai");   --增加洗辅修机会道具

--任务变量 
tbItem.TSK_GROUP    = 2027;  
tbItem.TSK_USETIME  = 90;
tbItem.CD_TIME 		= 24 * 60 * 60; -- 辅修令使用间隔时间7天

function tbItem:OnUse()	
	--判断CD
	local nCheck, nSec = self:CheckItemCD();
	if nCheck == 0 then
		local szTime = Lib:TimeFullDesc(nSec);
		me.Msg("Thời gian sử dụng Bổ Tu Lệnh cách nhau 3 ngày, thời gian còn lại "..szTime);
		return;
	end 	
	local nCount = Faction:GetMaxModifyTimes(me) - Faction:GetModifyFactionNum(me);
	local tbOpt = {}
	table.insert(tbOpt, {"Ta chắc chắn sử dụng", self.UseItem, self, it.dwId});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	local szMsg = string.format("Bạn có chắc muốn sử dụng vật phẩm? Bạn còn %s lần đổi phụ tu môn phái", nCount);
	Dialog:Say(szMsg, tbOpt); 
end

function tbItem:UseItem(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if me.DelItem(pItem , Player.emKLOSEITEM_USE) ~= 1 then
		return 0;
	end
	Faction:AddExtraModifyTimes(me , 1);
	local nCount = Faction:GetMaxModifyTimes(me) - Faction:GetModifyFactionNum(me);
	local szMsg = string.format("Bạn đã tăng 1 lần đổi phụ tu môn phái, hiện tại còn %s lần đổi phụ tu môn phái", nCount);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[活动]增加辅修机会%s次",nCount));		
	Dbg:WriteLog(string.format("[使用物品]增加辅修机会%s次",nCount), me.szName);
	me.Msg(szMsg);
	local nCurTime = GetTime(); 
	me.SetTask(self.TSK_GROUP, self.TSK_USETIME, nCurTime);
	return 1;
end

function tbItem:GetTip(nState)
	local nCount = Faction:GetMaxModifyTimes(me) - Faction:GetModifyFactionNum(me);
	local szTip = "";
	szTip = szTip..string.format("<color=yellow>Hiện tại còn lại %s lần đổi phụ tu môn phái<color>", nCount);	
	return	szTip;
end

function tbItem:CheckItemCD()
	local nEndTime = me.GetTask(self.TSK_GROUP, self.TSK_USETIME) + self.CD_TIME;
	local nRemainSec = nEndTime -  GetTime();	
	if nRemainSec < 0   then
	 	return 1 , 0;
	end
	return 0 , nRemainSec;			
end
