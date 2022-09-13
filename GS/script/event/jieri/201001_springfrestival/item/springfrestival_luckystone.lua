-- 文件名　：springfrestival_luckystone.lua
-- 创建者　：zounan
-- 创建时间：2010-01-22 14:32:49
-- 描  述  ：

local tbItem 	= Item:GetClass("luckystone");
tbItem.nDate  	= 2010030222;

tbItem.nLotteryBegin = 20100224;
tbItem.nLotteryEnd	 = 20100302;
tbItem.tbBox  		 = {18,1,909,1};

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(self.nDate);
	it.SetTimeOut(0, nSec);
	return	{ };
end

function tbItem:OnUse()
	Dialog:Say("这颗宝石看上去流光溢彩，据说能参加2月24日到3月2日的大抽奖活动，获得游龙阁声望令，也可以选择保存到收藏盒子中。",
			{"收藏到宝石盒子", self.Store, self, it.dwId},
			{"参加今天的抽奖活动", self.Lottery, self, it.dwId},
			{"Để ta suy nghĩ thêm"}
			);
end

function tbItem:Store(nId)
	local pItem = KItem.GetObjById(nId);
	if not pItem then
		return;
	end
	
	local tbResult = me.FindItemInAllPosition(unpack(self.tbBox));
	local nRes,szMsg = Item:GetClass("box_luckystone"):AddIntoBox(me,pItem);
	if nRes == 0 then
		Dialog:Say(szMsg);
		return;
	end

	if #tbResult == 0 then
		local pBox = me.AddItem(unpack(self.tbBox));
		if pBox then
			pBox.Bind(1);	
			--Item:GetClass("luckystone_box"):AddIntoBox(me,pItem,pBox);
		end
	end		
	
end

function tbItem:Lottery(nId)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nCurDate < self.nLotteryBegin then
		Dialog:Say("抽奖活动还未开始呢，据说2月24日0点才会开始，3月2日24点活动就结束了，每天22点开奖，请注意时间参加活动！");
		return;
	end
	local pItem = KItem.GetObjById(nId);
	if pItem then
		pItem.Delete(me);
		Lottery:UseTicket(me.szName, me.nId);
		me.Msg("恭喜您参加了幸运宝石大抽奖活动");
		Dialog:SendBlackBoardMsg(me, "恭喜您参加了幸运宝石大抽奖活动");
	end
end


