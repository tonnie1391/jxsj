-- 文件名　：luckystone_box.lua
-- 创建者　：zounan
-- 创建时间：2010-01-22 14:33:39
-- 描  述  ：一个装东东的盒子
local tbItem 	= Item:GetClass("box_luckystone");

--东东的数据都是记在玩家的任务变量身上的，一个物品要占两个任务变量(数目和过期时间)
tbItem.TSKG_GROUP 		 = 2116;
tbItem.TSK_ITEM_BEGIN	 = 1;
tbItem.TSK_ITEM_END		 = 100; -- 最多可以存50个
tbItem.TIME_LIMIT		 = 5;  -- 有效期相差不大的可以放进来 暂时设5s

--规定可以存的物品的信息 以后可以改成写配置表
tbItem.tbBox =
{
	[1] = {szName = "幸运宝石",tbGDPL = {18,1,908,1}, nMaxCount = 21},
--	[2] = {szName = "宝石2",tbGDPL = {18,1,910,1}, nMaxCount = 5},
}


function tbItem:OnUse()
	local tbOpt = {
		{"存入物品", self.TakeOutItem, self,it.dwId},
		{"取出物品", self.TakeInItem, self,it.dwId},
		{"Đóng lại"}
	};
	local szMsg = "这是一个神奇的盒子,你想用它做什么?";
	Dialog:Say(szMsg, tbOpt);
end;


--取出物品 貌似单词写反了
function tbItem:TakeInItem(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end		
	local tbOpt = {};
	for i = 1 , #self.tbBox do
		local nTskId = self.TSK_ITEM_BEGIN + (i - 1) * 2;		
		local nCurCount = me.GetTask(self.TSKG_GROUP, nTskId);
		local nTimeSec  = me.GetTask(self.TSKG_GROUP, nTskId + 1);
		local nCurDate	= tonumber(GetLocalDate("%Y%m%d"));
		local nCurSec	= Lib:GetDate2Time(nCurDate);		
		
		if nCurCount == 0 then
			if nTimeSec ~= 0 then
				me.SetTask(self.TSKG_GROUP, nTskId + 1,0);
			end
		elseif nCurSec > nTimeSec then
			me.SetTask(self.TSKG_GROUP, nTskId,0);
			me.SetTask(self.TSKG_GROUP, nTskId + 1,0);
		else
			local szName = string.format("取出%s 目前剩余%s个", Lib:StrFillC(self.tbBox[i].szName,10),nCurCount);
			table.insert(tbOpt,{szName, self.OnOpenItem, self,nTskId,nItemId,nCurCount});
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	local szMsg = "\n请选择您所需要取出的物品。";
	Dialog:Say(szMsg, tbOpt)
end

function tbItem:OnOpenItem(nTskId, nItemId,nCurCount)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end

	Dialog:AskNumber("请输入取出的数量：", nCurCount, self.OnUseTakeOut, self, nTskId, nItemId);
end

function tbItem:OnUseTakeOut(nTskId, nItemId, nTakeOutCount)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local nCurCount = me.GetTask(self.TSKG_GROUP,nTskId)
	if  nCurCount <= 0 or nTakeOutCount > nCurCount then
		return 0;
	end

	local nTimeSec  = me.GetTask(self.TSKG_GROUP, nTskId + 1);
	local nCurDate	= tonumber(GetLocalDate("%Y%m%d"));
	local nCurSec	= Lib:GetDate2Time(nCurDate);
	if  nCurSec > nTimeSec then
		me.SetTask(self.TSKG_GROUP, nTskId,0);
		me.SetTask(self.TSKG_GROUP, nTskId + 1,0);
		return 0;
	end
	
	if me.CountFreeBagCell() < nTakeOutCount then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	
	for i=1, nTakeOutCount do
		local nItemNum = (nTskId - tbItem.TSK_ITEM_BEGIN) / 2 + 1;
		local pAddItem = me.AddItem(unpack(self.tbBox[nItemNum].tbGDPL));
		if pAddItem then
			pAddItem.Bind(1);
			pAddItem.SetTimeOut(0,nTimeSec);		
			pAddItem.Sync();	
		end
	end
	local nLeftCount = nCurCount - nTakeOutCount;
	me.SetTask(self.TSKG_GROUP,nTskId,nLeftCount);
	--pItem.Sync();
end

function tbItem:FindPos(pItem)
	local nPos = 0;
	for i = 1, #self.tbBox do
		if pItem.Equal(unpack(self.tbBox[i].tbGDPL)) == 1 then
			nPos = i;
			break;
	 	end
	end
	return nPos;	
end

function tbItem:CanAddIntoBox(pPlayer,pItem,nAddCount)
	if not pItem  then
		return 0 , "物品不见了,呜";
	end
	nAddCount = nAddCount or 0;
	local nPos = self:FindPos(pItem);
	
	if nPos == 0 then
		return 0,"该物品不能加入盒子";
	end
	
	local nTskId = self.TSK_ITEM_BEGIN + (nPos - 1) * 2;

	local nCurCount = pPlayer.GetTask(self.TSKG_GROUP,nTskId);
	local nTimeSec = pPlayer.GetTask(self.TSKG_GROUP,nTskId +1);
	local nType,nSec = pItem.GetTimeOut();
	if nType == 1 then
		return 0,"该物品不能加入盒子";
	end

	if nCurCount ~= 0 and nTimeSec > nSec + self.TIME_LIMIT and nSec > nTimeSec + self.TIME_LIMIT then
		return 0,"有效期不一致,不能放入盒子";
	end	
	
	if (nCurCount + nAddCount ) >= self.tbBox[nPos].nMaxCount then
		return 0 ,"不能存更多的此类物品了。";
	end	
	return 1, nTskId,nCurCount, nSec;
end

function tbItem:AddIntoBox(pPlayer,pItem)

	local nResult, varRes1,varRes2,varRes3 = self:CanAddIntoBox(pPlayer,pItem);
	if nResult == 0 then
		return 0 ,varRes1;
	end
	pItem.Delete(me);
	pPlayer.SetTask(self.TSKG_GROUP, varRes1, varRes2 + 1);
	pPlayer.SetTask(self.TSKG_GROUP, varRes1+1, varRes3);
	--pBox.Sync();
	return 1;
end

function tbItem:TakeOutItem(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end	
	Dialog:OpenGift("请放入要保存的物品", {"Merchant:LuckyBoxCheckGiftSwith"}, {self.OnOpenGiftOk, self});
end

function tbItem:OnOpenGiftOk(tbItemObj)
	local nResult, szMsg = nil, nil;
	for _, pItem in pairs(tbItemObj) do
		nResult, szMsg = self:AddIntoBox(me,pItem[1]);
		if nResult == 0 then
			me.Msg(pItem[1].szName.."不能放入:",szMsg);
		end
	end
	
	return 1;
end;

--客户端检查 必须要挂在第一层下 故借用Merchant Table
function Merchant:LuckyBoxCheckGiftSwith(tbGiftSelf, pPickItem, pDropItem, nX, nY)
	local tbItem = Item:GetClass("box_luckystone");
	if (not tbGiftSelf.tbOnSwithItemCount) then
		tbGiftSelf.tbOnSwithItemCount = {};
	end	
	local szMsg = "";
	if pDropItem then
		local nPos = tbItem:FindPos(pDropItem);
		if nPos == 0 then
			me.Msg("该物品不能加入盒子");
			return 0;
		end
		tbGiftSelf.tbOnSwithItemCount[nPos] = tbGiftSelf.tbOnSwithItemCount[nPos] or 0;
		local nResult, varResult = tbItem:CanAddIntoBox(me,pDropItem, tbGiftSelf.tbOnSwithItemCount[nPos]);
		if nResult == 0 then
			me.Msg(varResult);
			return 0;
		end		
				tbGiftSelf.tbOnSwithItemCount[nPos] = tbGiftSelf.tbOnSwithItemCount[nPos] + 1;
		szMsg = tbItem:LuckyBoxUpdateGiftSwith(tbGiftSelf.tbOnSwithItemCount);
	end
	if pPickItem then
		local nPos = tbItem:FindPos(pPickItem);
		if nPos == 0 then
			return 0;
		end		
		tbGiftSelf.tbOnSwithItemCount[nPos] = tbGiftSelf.tbOnSwithItemCount[nPos] - 1;
		szMsg = tbItem:LuckyBoxUpdateGiftSwith(tbGiftSelf.tbOnSwithItemCount);
	end
	
	tbGiftSelf:UpdateContent(szMsg);
	return 1;
end;

function tbItem:LuckyBoxUpdateGiftSwith(tbOnSwithItemCount)
--	local szTip = string.format("%s%s\n\n",Lib:StrFillC("宝石", 16), Lib:StrFillC("放入个数", 12));
	local szTip = "";
	for i = 1 , #self.tbBox do
		local nTskId = self.TSK_ITEM_BEGIN + (i - 1) * 2;	
		local nCurCount = me.GetTask(self.TSKG_GROUP, nTskId);		
		local nTimeSec  = me.GetTask(self.TSKG_GROUP, nTskId + 1);
		local nCurDate	= tonumber(GetLocalDate("%Y%m%d"));
		local nCurSec	= Lib:GetDate2Time(nCurDate)
	
		local nSec = nTimeSec - nCurSec;
		
		nCurCount = nCurCount + (tbOnSwithItemCount[i] or 0);
		if nCurCount ~= 0 and (nTimeSec == 0 or nSec > 0) then
			--local szName = string.format("<color=green>%s<color> %s个 有效期:%s\n",self.tbBox[i].szName,nCurCount,Lib:TimeDesc(nSec));
			local szName = string.format("<color=green>%s<color> %s/%s\n",Lib:StrFillC(self.tbBox[i].szName,20),nCurCount,self.tbBox[i].nMaxCount);
			szTip = szTip..szName;
		end
	end		

	return szTip;
end

function tbItem:GetTip(nState)
	local szTip = "";
	for i = 1 , #self.tbBox do
		local nTskId = self.TSK_ITEM_BEGIN + (i - 1) * 2;	
		local nCurCount = me.GetTask(self.TSKG_GROUP, nTskId);		
		local nTimeSec  = me.GetTask(self.TSKG_GROUP, nTskId + 1);
		local nCurDate	= tonumber(GetLocalDate("%Y%m%d"));
		local nCurSec	= Lib:GetDate2Time(nCurDate)
	
		local nSec = nTimeSec - nCurSec;
		if nCurCount ~= 0 and nSec > 0 then
			--local szName = string.format("<color=green>%s<color> %s个 有效期:%s\n",self.tbBox[i].szName,nCurCount,Lib:TimeDesc(nSec));
			local szName = string.format("<color=green>%s<color> %s/%s 剩余时间:%s\n",Lib:StrFillC(self.tbBox[i].szName,10),nCurCount,self.tbBox[i].nMaxCount,Lib:TimeFullDescEx(nSec));
			szTip = szTip..szName;
		end
	end	
	szTip = szTip..string.format("\n<color=gold>右键点击打开<color>");
	return	szTip;
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nDate = it.GetExtParam(1);
	local nSec = Lib:GetDate2Time(nDate);
	it.SetTimeOut(0, nSec);
	return	{ };
end
