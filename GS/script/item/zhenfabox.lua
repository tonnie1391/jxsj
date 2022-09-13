-------------------------------------------------------
-- 文件名　：zhenfabox.lua
-- 文件描述：阵法箱 用于取阵法书及销毁阵法书
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-26 11:53:08
-- 修改者: zhangjunjie
-- 修改时间: 2010-12-6
-- 修改内容: 阵法册使用模式，新增高级阵法使用 
-------------------------------------------------------

local tbItem = Item:GetClass("zhenfa_box")

tbItem.tbHighZhenFaGDPL =  --高级阵法册的gdpl,用于比较是否为高级阵法册
{
	"18,1,320,3",
	"18,1,743,1",
	"18,1,1803,1",
};

tbItem.PRIMER_ZHONGJIZHENFA_LIST = {
			{"Trung: Ngũ Hành Trận", 1, 15, 12, 1},
	}
tbItem.NORMAL_ZHONGJIZHENFA_LIST = {
			{"Trung: Bát Quái Trận-Li", 1, 15, 2, 1},
			{"Trung: Bát Quái Trận-Đoài", 1, 15, 3, 1},
			{"Trung: Bát Quái Trận-Cấn", 1, 15, 4, 1},
			{"Trung: Bát Quái Trận-Khảm", 1, 15, 5, 1},
			{"Trung: Bát Quái Trận-Tốn", 1, 15, 6, 1},
			{"Trung: Bát Quái Trận-Càn", 1, 15, 7, 1},
			{"Trung: Thanh Long Trận", 1, 15, 8, 1},
			{"Trung: Huyền Vũ Trận", 1, 15, 9, 1},
			{"Trung: Bạch Hổ Trận", 1, 15, 10, 1},
			{"Trung: Chu Tước Trận", 1, 15, 11, 1},
	}
tbItem.ALL_ZHONGJIZHENFA_LIST ={
			{"Trung: Ngũ Hành Trận", 1, 15, 12, 1},
			{"Trung: Bát Quái Trận-Li", 1, 15, 2, 1},
			{"Trung: Bát Quái Trận-Đoài", 1, 15, 3, 1},
			{"Trung: Bát Quái Trận-Cấn", 1, 15, 4, 1},
			{"Trung: Bát Quái Trận-Khảm", 1, 15, 5, 1},
			{"Trung: Bát Quái Trận-Tốn", 1, 15, 6, 1},
			{"Trung: Bát Quái Trận-Càn", 1, 15, 7, 1},
			{"Trung: Thanh Long Trận", 1, 15, 8, 1},
			{"Trung: Huyền Vũ Trận", 1, 15, 9, 1},
			{"Trung: Bạch Hổ Trận", 1, 15, 10, 1},
			{"Trung: Chu Tước Trận", 1, 15, 11, 1},
	}
tbItem.PRIMER_GAOJIZHENFA_LIST = {
			{"Cao: Ngũ Hành Trận",1,15,1,3},
	}
tbItem.NORMAL_GAOJIZHENFA_LIST = {
			{"Cao: Bát Quái Trận-Li",1,15,2,3},
			{"Cao: Bát Quái Trận-Đoài",1,15,3,3},
			{"Cao: Bát Quái Trận-Cấn",1,15,4,3},
			{"Cao: Bát Quái Trận-Khảm",1,15,5,3},
			{"Cao: Bát Quái Trận-Tốn",1,15,6,3},
			{"Cao: Bát Quái Trận-Càn",1,15,7,3},
			{"Cao: Thanh Long Trận",1,15,8,3},
			{"Cao: Huyễn Vũ Trận",1,15,9,3},
			{"Cao: Bạch Hổ Trận",1,15,10,3},
			{"Cao: Chu Tước Trận",1,15,11,3},
	}
tbItem.HIGH_GAOJIZHENFA_LIST = {
			{"Cao: Nguyệt Mê Tân Độ Trận",1,15,12,3},
			{"Cao: Vụ Thất Lâu Đài Trận",1,15,13,3},
			{"Cao: Tham Lang Trận-Dương",1,15,14,3},
			{"Cao: Tham Lang Trận-Âm",1,15,15,3},
			{"Cao: Bát Quái Trận-Chấn",1,15,16,3},
			{"Cao: Bát Quái Trận-Khôn",1,15,17,3},
			{"Cao: Phá Quân Trận",1,15,18,3},
			{"Cao: Thất Sát Trận",1,15,19,3},
	}
tbItem.ALL_GAOJIZHENFA_LIST = {
			{"Cao: Ngũ Hành Trận",1,15,1,3},
			{"Cao: Bát Quái Trận-Li",1,15,2,3},
			{"Cao: Bát Quái Trận-Đoài",1,15,3,3},
			{"Cao: Bát Quái Trận-Cấn",1,15,4,3},
			{"Cao: Bát Quái Trận-Khảm",1,15,5,3},
			{"Cao: Bát Quái Trận-Tốn",1,15,6,3},
			{"Cao: Bát Quái Trận-Càn",1,15,7,3},
			{"Cao: Thanh Long Trận",1,15,8,3},
			{"Cao: Huyễn Vũ Trận",1,15,9,3},
			{"Cao: Bạch Hổ Trận",1,15,10,3},
			{"Cao: Chu Tước Trận",1,15,11,3},
			{"Cao: Nguyệt Mê Tân Độ Trận",1,15,12,3},
			{"Cao: Vụ Thất Lâu Đài Trận",1,15,13,3},
			{"Cao: Tham Lang Trận-Dương",1,15,14,3},
			{"Cao: Tham Lang Trận-Âm",1,15,15,3},
			{"Cao: Bát Quái Trận-Chấn",1,15,16,3},
			{"Cao: Bát Quái Trận-Khôn",1,15,17,3},
			{"Cao: Phá Quân Trận",1,15,18,3},
			{"Cao: Thất Sát Trận",1,15,19,3},
	}


tbItem.LIVE_TIME	= 30 * 24 * 60 * 60; -- 秒 一个月
	
function tbItem:InitGenInfo()
	--设置道具的生存期
	if MODULE_GAMECLIENT then
		local nTime = tonumber(it.GetExtParam(1));
        	if nTime and nTime > 0 then
			it.SetTimeOut(1, nTime);
        	else
			it.SetTimeOut(1, self.LIVE_TIME);
        	end		
	else
		local nTime = tonumber(it.GetExtParam(1));
        if nTime and nTime > 0 then
		   it.SetTimeOut(0, GetTime() + nTime);
        else
           it.SetTimeOut(0, GetTime() + self.LIVE_TIME);
        end
	end;
	return	{};
end

function tbItem:OnUse()
	local szMsg 		= "Hãy chọn thao tác:"
	local tbOpt 		= {};
	tbOpt[#tbOpt + 1] 	= {"Thay đổi trận pháp", self.ReplaceBook, self, me.nId, it.dwId};
	tbOpt[#tbOpt + 1] 	= {"Lấy trận pháp", self.SelectBook, self, me.nId, it.dwId};
	tbOpt[#tbOpt + 1]	= {"Cất lại trận pháp", self.DeleteBook, self, me.nId, it.dwId};
	tbOpt[#tbOpt + 1]	= {"Hủy bỏ"};
	Dialog:Say(szMsg, tbOpt);
end;

function tbItem:SelectBook(nPlayerId, nBoxId)
	local szMsg 	= "Hãy chọn loại trận pháp:"
	local tbOpt		= {};
	local pItem = KItem.GetObjById(nBoxId);
	if not pItem then
		return 0;
	end
	if self:IsHighLevelBook(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel) == 1 then
		tbOpt[#tbOpt + 1] 	= {"Trận pháp Cao", self.HandleGiveZhenFaKind, self, self.HIGH_GAOJIZHENFA_LIST,nPlayerId, nBoxId};
		tbOpt[#tbOpt + 1] 	= {"Trận pháp Trung", self.HandleGiveZhenFaKind, self, self.NORMAL_GAOJIZHENFA_LIST,nPlayerId, nBoxId};
		tbOpt[#tbOpt + 1]	= {"Trận pháp Sơ", self.HandleGiveZhenFaKind, self, self.PRIMER_GAOJIZHENFA_LIST,nPlayerId, nBoxId};
	else
		tbOpt[#tbOpt + 1] 	= {"Trận pháp Trung", self.HandleGiveZhenFaKind, self, self.NORMAL_ZHONGJIZHENFA_LIST,nPlayerId, nBoxId};
		tbOpt[#tbOpt + 1]	= {"Trận pháp Sơ", self.HandleGiveZhenFaKind, self, self.PRIMER_ZHONGJIZHENFA_LIST,nPlayerId, nBoxId};
	end
	tbOpt[#tbOpt + 1]	= {"Hủy"};
	Dialog:Say(szMsg, tbOpt); 
end;

function tbItem:HandleGiveZhenFaKind(tbZhenFaList,nPlayerId,nBoxId)
	local szMsg		= "Hãy chọn Trận pháp đồ:";
	local tbOpt		= {};
	if not tbZhenFaList then
		return;
	end
	for i = 1, #tbZhenFaList do
		local szTip = "<item=".. tbZhenFaList[i][2] .. "," .. tbZhenFaList[i][3] .. "," .. 
						tbZhenFaList[i][4] .. "," .. tbZhenFaList[i][5]..">"
		tbOpt[#tbOpt + 1]	= {tbZhenFaList[i][1] .. szTip,self.GiveBook, self, nPlayerId, i, nBoxId,tbZhenFaList};
	end;
	tbOpt[#tbOpt + 1]	=  {"Hủy"};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:ReplaceBook(nPlayerId, nBoxId)
	local szMsg 	= "Hãy chọn loại Trận pháp đồ muốn đổi:"
	local tbOpt		= {};
	local pItem = KItem.GetObjById(nBoxId);
	if not pItem then
		return 0;
	end
	if self:IsHighLevelBook(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel) == 1 then
		tbOpt[#tbOpt + 1] 	= {"Trận pháp Cao", self.HandleReplaceZhenFaKind, self, self.HIGH_GAOJIZHENFA_LIST,nPlayerId, nBoxId};
		tbOpt[#tbOpt + 1] 	= {"Trận pháp Trung", self.HandleReplaceZhenFaKind, self, self.NORMAL_GAOJIZHENFA_LIST,nPlayerId, nBoxId};
		tbOpt[#tbOpt + 1]	= {"Trận pháp Sơ", self.HandleReplaceZhenFaKind, self, self.PRIMER_GAOJIZHENFA_LIST,nPlayerId, nBoxId};
	else
		tbOpt[#tbOpt + 1] 	= {"Trận pháp Trung", self.HandleReplaceZhenFaKind, self, self.NORMAL_ZHONGJIZHENFA_LIST,nPlayerId,nBoxId};
		tbOpt[#tbOpt + 1]	= {"Trận pháp Sơ", self.HandleReplaceZhenFaKind, self, self.PRIMER_ZHONGJIZHENFA_LIST,nPlayerId,nBoxId};
	end
	tbOpt[#tbOpt + 1]	= {"Hủy"};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:HandleReplaceZhenFaKind(tbZhenFaList,nPlayerId,nBoxId)
	local szMsg		= "Hãy chọn trận pháp đồ bạn muốn đổi, sau khi chọn sẽ thay thế trận pháp đồ hiện tại bằng trận mới:";
	local tbOpt		= {};
	if not tbZhenFaList then
		return;
	end
	for i = 1, #tbZhenFaList do
		local szTip = "<item=".. tbZhenFaList[i][2] .. "," .. tbZhenFaList[i][3] .. "," .. 
						tbZhenFaList[i][4] .. "," .. tbZhenFaList[i][5]..">"
		tbOpt[#tbOpt + 1]	= {tbZhenFaList[i][1] .. szTip,self.ChangeBook, self, nPlayerId, i, nBoxId,tbZhenFaList};
	end;
	tbOpt[#tbOpt + 1]	=  {"Hủy"};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:ChangeBook(nPlayerId, nBookId, nBoxId,tbZhenFaList)
	local pItem = KItem.GetObjById(nBoxId);
	if not pItem then
		return 0;
	end
	local pOldItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHEN,0);
	local nIsHighBook = 0;
	if self:IsHighLevelBook(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel) == 1 then
		nIsHighBook = 1;
	end
	if not pOldItem or self:CheckItem(pOldItem.nGenre, pOldItem.nDetail, pOldItem.nParticular, pOldItem.nLevel,nIsHighBook) ~= 0 then
		local pNewItem = self:GiveBook(nPlayerId, nBookId, nBoxId,tbZhenFaList);
		if not pNewItem then
			return;
		end
		Setting:SetGlobalObj(me,him,pNewItem);
		Item:OnUse(pNewItem.szClass);
		Setting:RestoreGlobalObj();
	else
		local tbTimeOut = me.GetItemAbsTimeout(pOldItem);
		local nResult = pOldItem.Regenerate(tbZhenFaList[nBookId][2], tbZhenFaList[nBookId][3], tbZhenFaList[nBookId][4], tbZhenFaList[nBookId][5], 
											pOldItem.nSeries, pOldItem.nEnhTimes, pOldItem.nLucky, pOldItem.GetGenInfo(),
											pOldItem.nVersion,pOldItem.dwRandSeed, pOldItem.nStrengthen);
		if nResult ~= 1 then
			me.Msg("Đổi pháp trận thất bại!");
			return; 
		end
		if (tbTimeOut) then
			local szTime = string.format("%02d/%02d/%02d/%02d/%02d/10", 			
					tbTimeOut[1],
					tbTimeOut[2],
					tbTimeOut[3],
					tbTimeOut[4],
					tbTimeOut[5]);
			me.SetItemTimeout(pOldItem, szTime);
			pOldItem.Sync()
		end
	end
end

function tbItem:GiveBook(nPlayerId, nBookId, nBoxId,tbZhenFaList)
	local pBox = KItem.GetObjById(nBoxId);
	if (not pBox) then
		print("ZhenFaBox ERROR", nPlayerId, nBookId, nBoxId);
		return;
	end;
	pBox.Bind(1);
	local nFreeBagCell = me.CountFreeBagCell();
	if nFreeBagCell < 1 then
			me.Msg("Túi đầy, ít nhất phải chừa 1 ô túi trống!");
			return;
	end
	-- 从阵法例子中拿出一个阵法图，并不是真正的添加道具
	local pItem = me.AddItemEx(tbZhenFaList[nBookId][2], tbZhenFaList[nBookId][3], tbZhenFaList[nBookId][4], tbZhenFaList[nBookId][5], nil, 0);
	if (not pItem) then
		return;
	end;
	local tbTimeOut = me.GetItemAbsTimeout(pBox);		--设置绝对过期时间
	if (tbTimeOut) then
		local szTime = string.format("%02d/%02d/%02d/%02d/%02d/10", 			
				tbTimeOut[1],
				tbTimeOut[2],
				tbTimeOut[3],
				tbTimeOut[4],
				tbTimeOut[5]);
		me.SetItemTimeout(pItem, szTime);
		pItem.Sync()
	end;
	return pItem;	
end;



function tbItem:DeleteBook(nPlayerId,nBoxId)
	local pItem = KItem.GetObjById(nBoxId);
	if not pItem then
		return 0;
	end
	local nIsHighBook = 0;
	if self:IsHighLevelBook(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel) == 1 then
		nIsHighBook = 1;
	end
	Dialog:OpenGift("Hãy đặt Trận pháp đồ muốn trả", nil, {self.OnOpenGiftOk,self,nIsHighBook});
end;

function tbItem:OnOpenGiftOk(nIsHighBook,tbItemObj)
	local bForbidItem 	= false;
	
	for _, pItem in pairs(tbItemObj) do
		if (self:CheckItem(pItem[1].nGenre,pItem[1].nDetail,pItem[1].nParticular,pItem[1].nLevel,nIsHighBook) == 0) then
			-- 把阵法放回到例子里，并不是真正的删除
			me.DelItem(pItem[1], 0);
		else
			bForbidItem = true;
		end;
	end
	
	if (bForbidItem == true) then
		me.Msg("Một số vật phẩm không thuộc Trận pháp đồ của quyển này, không thể trả lại!");
	end;
end;

function tbItem:CheckItem(nGenre, nDetail,nParticular,nLevel,nIsHighBook)
	local szBook = string.format("%s,%s,%s,%s", nGenre, nDetail,nParticular,nLevel)
	local nIsHigh = (nIsHighBook == 1 and true or false);
	for i,v in ipairs(nIsHigh and self.ALL_GAOJIZHENFA_LIST or self.ALL_ZHONGJIZHENFA_LIST) do
		local szItem = string.format("%s,%s,%s,%s", v[2], v[3], v[4], v[5]);
		if (szItem == szBook) then
			return 0;
		end;
	end;
	return 1;
end;

function tbItem:IsHighLevelBook(nGenre,nDetail,nParticular,nLevel)
	local szGDPL = string.format("%s,%s,%s,%s",nGenre,nDetail,nParticular,nLevel)
	local nIsHigh = 0;
	for _,szCmp in pairs(self.tbHighZhenFaGDPL) do
		if szCmp == szGDPL then
			nIsHigh = 1;
			break;
		end
	end
	return nIsHigh;
end
