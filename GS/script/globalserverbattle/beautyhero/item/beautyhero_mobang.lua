-- 文件名  : beautyhero_mobang.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-19 21:56:23
-- 描述    : 

local tbItem = Item:GetClass("beautyhero_mobang");
tbItem.NUM_PERPAGE = 5;

tbItem.TABLE_MASK = 
{
	{szName = "[面具]柔小翠",tbItemId = {1,13,98,1}},
	{szName = "[面具]张善德",tbItemId = {1,13,99,1}},
	{szName = "[面具]贾逸山",tbItemId = {1,13,100,1}},
	{szName = "[面具]乌山青",tbItemId = {1,13,101,1}},
	{szName = "[面具]陈无命",tbItemId = {1,13,102,1}},
	{szName = "[面具]叶静",  tbItemId = {1,13,103,1}},
	{szName = "[面具]宝玉"	,tbItemId = {1,13,104,1}},
	{szName = "[面具]夏小倩",tbItemId = {1,13,105,1}},
	{szName = "[面具]秦仲",  tbItemId = {1,13,106,1}},
	{szName = "[面具]木超"	,tbItemId = {1,13,107,1}},
	{szName = "[面具]紫苑"	,tbItemId = {1,13,108,1}},
	{szName = "[面具]莺莺"	,tbItemId = {1,13,109,1}},
	{szName = "[面具]秦始皇",tbItemId = {1,13,110,1}},
};

function tbItem:OnUse()
	self:OnUseEx();
end

function tbItem:OnUseEx(nCurPage)
	nCurPage = nCurPage or 1;

	local nCurBeginCount = self.NUM_PERPAGE *(nCurPage - 1) + 1;
	if not self.TABLE_MASK[nCurBeginCount] then
		return 0;
	end

	
	local nCurEndCount = #self.TABLE_MASK;
	local tbOpt = {};
	if  #self.TABLE_MASK - nCurBeginCount + 1 > self.NUM_PERPAGE then
		nCurEndCount = nCurBeginCount + self.NUM_PERPAGE - 1;
	end
	
	for i = nCurBeginCount , nCurEndCount do
		table.insert(tbOpt,{self.TABLE_MASK[i].szName,self.GetItem,self,i});
	end
	
	if nCurEndCount < #self.TABLE_MASK then
		table.insert(tbOpt,{"Trang sau",self.OnUseEx,self, nCurPage + 1});
	end
	
	table.insert(tbOpt,{"Kết thúc đối thoại"});
	Dialog:Say("你好，请选择喜欢的面具", tbOpt);
end

function tbItem:GetItem(nIndex)
	if not self.TABLE_MASK[nIndex] then
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不够。");
		return 0;
	end	
	
	local pItem = me.AddItem(unpack(self.TABLE_MASK[nIndex].tbItemId));
	if pItem then
		pItem.Bind(1);
	end
end