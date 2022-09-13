-- 文件名　：nianhua_box.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-29 10:37:45
-- 描  述  ：年画收藏盒

local tbBox = Item:GetClass("collectionbox");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

if  MODULE_GAMESERVER then

function tbBox:OnUse()
	local tbOpt = {
		{"存入物品", self.TakeInItem, self},
		{"取出物品", self.TakeOutItem, self},
		{"Đóng lại"}
	};
	local szMsg = "可对已鉴定的年画进行存储和取出。\n\n" .. self:GetTip() .. "\n";
	Dialog:Say(szMsg, tbOpt);
end;

--存入物品
function tbBox:TakeInItem()
	Dialog:OpenGift("请放入要保存的物品",nil ,{self.OnOpenGiftOk, self});
end;

function tbBox:OnOpenGiftOk(tbItemObj)
	local tbItemList = {};	
	if (self:ChechItem(tbItemObj, tbItemList) == 0) then
		me.Msg("存在不符合的物品或者数量超过限制!")
		return 0;	
	end;
	
	for _, pItem in pairs(tbItemObj) do
		if me.DelItem(pItem[1]) ~= 1 then
			return 0;
		end
	end
	
	for nNum, nCount in pairs(tbItemList) do
		local nCurCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNum - 1);
		nCurCount = nCurCount + nCount;
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNum - 1, nCurCount);
		me.Msg(string.format("您收集了%s个<color=yellow>%s<color>生肖的年画。", nCount, SpringFrestival.tbShengXiao[nNum]));		
	end;	
	return 1;
end;

-- 检测物品及数量是否符合
function tbBox:ChechItem(tbItemObj, tbItemList)
	for _, pItem in pairs(tbItemObj) do		
		local szFollowItem 	= string.format("%s,%s,%s", unpack(SpringFrestival.tbNianHua_identify));
		local szItem		= string.format("%s,%s,%s", pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular);
		if szFollowItem ~= szItem then
			return 0;
		end;
		local nNum = pItem[1].nLevel;
		tbItemList[nNum] = 	(tbItemList[nNum] or 0) + 1;
		local nCurCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNum - 1);		
		
		if (nCurCount + tbItemList[nNum] > 20) then
			return 0;
		end;		
	end
	return 1;
end;

-- 取出物品
function tbBox:TakeOutItem(nNowPage)
	local tbOpt = {};
	if not nNowPage then
		nNowPage = 0;
	end
	local nPage = 6;
	local nCount = nNowPage * nPage;
	local nSum = 0;
	for nNumber, szName in ipairs(SpringFrestival.tbShengXiao) do
		local nCurCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNumber -1);
		if (nCurCount > 0) then
			nSum = nSum + 1;
			if nSum > nCount then
				nCount = nCount + 1;
				if nCount > (nPage * (nNowPage + 1)) then
					table.insert(tbOpt, {"Trang sau", self.TakeOutItem, self, nNowPage + 1});
					break;
				end
				table.insert(tbOpt, {szName .. "(生肖的年画剩余" .. nCurCount .. "个)", self.SelectItem, self, nNumber});
			end
		end
	end
	
	if nCount > (nPage + 1) then
		table.insert(tbOpt, {"Trang trước", self.TakeOutItem, self, nNowPage - 1});
	end
	
	tbOpt[#tbOpt + 1] = {"Đóng lại"};
	local szMsg = "请选择您要取出的物品。";
	Dialog:Say(szMsg, tbOpt);
end;

--输入取出物品的数量
function tbBox:SelectItem(nNumber)
	local nCurCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNumber -1);
	Dialog:AskNumber("请输入取出的数量：", nCurCount, self.OnUseTakeOut, self, nNumber);
end;

--取出物品
function tbBox:OnUseTakeOut(nNumber, nCount)	
	local nCurCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNumber -1);
	if (nCount <= 0 or nCount > nCurCount) then
		me.Msg("输入的数量不对!");
		return 0;
	end;
	if me.CountFreeBagCell() < nCount then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	local nCurCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNumber -1);
	nCurCount = nCurCount - nCount;
	me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + nNumber -1, nCurCount);
	local tbNianHua = SpringFrestival.tbNianHua_identify;
	for i = 1, nCount do
		local pItem = me.AddItem(tbNianHua[1],tbNianHua[2],tbNianHua[3], nNumber);
		me.SetItemTimeout(pItem, 60*24*3, 0);
	end
end

end

function tbBox:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(SpringFrestival.nOutTime)
	it.SetTimeOut(0, nSec);
	return	{ };
end

function tbBox:GetTip()
	local szTip = "";
	for i, szName in ipairs(SpringFrestival.tbShengXiao) do
		local nItemNum = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOX + i - 1) or 0;
		local szColor = "white";		
		if nItemNum <= 0 then 
			szColor = "gray";
		end
		if nItemNum >= 20 then 
			szColor = "green";
		end;
		local szMsg = string.format("<color=%s>", szColor);		
		szTip = szTip..Lib:StrFillL("", 5)..szMsg..Lib:StrFillL(szName, 10)..Lib:StrFillL(string.format("%s", nItemNum), 2).." /20<color>\n";
	end
	return szTip;
end
