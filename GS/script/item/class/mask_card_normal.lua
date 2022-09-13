-- 文件名　：mask_card_normal.lua
-- 创建者　：zounan
-- 创建时间：2010-04-28 16:31:14
-- 描  述  ：通用的面具箱

local tbItem = Item:GetClass("mask_card_normal");
local SZITEMFILE = "\\setting\\item\\001\\other\\mask_xiang.txt";

function tbItem:OnUse()
	if not self.tbItemList  then
		self.tbItemList = self:GetItemList();
	end
	local nkind = tonumber(it.GetExtParam(1));
	if not self.tbItemList[nkind] then
		return;
	end		
	local tbOpt ={};
	for nIdx, tbItem in ipairs(self.tbItemList[nkind]) do		
		table.insert(tbOpt, {tbItem.szName,self.AddMask,self,it.dwId,nkind,nIdx});
	end			
	table.insert(tbOpt,{"Đóng lại"});
	local szInfo = "请选择你想要的物品(只能选择一个喔~)：";
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:AddMask(nItemId,nkind, nIdx)
	local pItem =  KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	
	if not self.tbItemList  then
		self.tbItemList = self:GetItemList();
	end	
	
	if not self.tbItemList[nkind] then
		return;
	end		
	
	local tbItem = 	self.tbItemList[nkind][nIdx];
	if not tbItem then
		return;
	end

	pItem.Delete(me);
	me.AddItem(unpack(tbItem.tbItem));
end


function tbItem:GetItemList()	
	local tbsortpos = Lib:LoadTabFile(SZITEMFILE);
	local nLineCount = #tbsortpos;
	local tbClassItemList = {};	
	for nLine=2, nLineCount do
		local nClassParamID = tonumber(tbsortpos[nLine].ClassParamID);
		local szName = tbsortpos[nLine].Name;
		local szDesc = tbsortpos[nLine].Desc;
		local nGenre = tonumber(tbsortpos[nLine].Genre) or 0;
		local nDetailType = tonumber(tbsortpos[nLine].DetailType)or 0;
		local nParticularType = tonumber(tbsortpos[nLine].ParticularType) or 0;
		local nLevel = tonumber(tbsortpos[nLine].Level)or 0;		
		if tbClassItemList[nClassParamID] == nil then
			tbClassItemList[nClassParamID] = {};
		end
		local nPosNo = (#tbClassItemList[nClassParamID]+ 1);
		tbClassItemList[nClassParamID][nPosNo] = {};
		tbClassItemList[nClassParamID][nPosNo].szName = szName;
		tbClassItemList[nClassParamID][nPosNo].tbItem = {nGenre,nDetailType,nParticularType,nLevel};
		tbClassItemList[nClassParamID][nPosNo].szDesc = szDesc;
	end
	return tbClassItemList;
end


tbItem.tbItemList = tbItem:GetItemList();	