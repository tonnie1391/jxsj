
-- 五行书

------------------------------------------------------------------------------------------
-- initialize

local tbSeriesInfoBook = Item:GetClass("seriesinfobook");

------------------------------------------------------------------------------------------
-- public

tbSeriesInfoBook.MSG_INFO 	= "五行书：五行轮转，万象更新。阴阳之法，造化乾坤。"..
							  "阁下若对某件装备可以被什么属性的装备激活，或者可以激活什么属性的装备不理解，"..
							  "请按书中所指明确你要查询五行关系的装备，由五行书告知你一切。";
tbSeriesInfoBook.MSG_EQUIP 	= "您当前要查询的装备是？";
tbSeriesInfoBook.MSG_SERIES	= "您这件装备的五行属性是？";

function tbSeriesInfoBook:init()
	self.nSelEquip  		= 0;
	self.nSelSeries 		= 0;
	self.tbEquitSelItem		= {};
	self.tbSeriesSelItem	= {};
end

tbSeriesInfoBook:init();

function tbSeriesInfoBook:OnUse()
	Dialog:Say(self.MSG_INFO, {{ "查看", self.OnViewEquip, self }});
end

function tbSeriesInfoBook:OnViewEquip()
	self.nSelSeries	= 0;
	self.nSelEquip	= 0;
	self.tbEquitSelItem = {};
	for i = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		table.insert(self.tbEquitSelItem, { Item.EQUIPPOS_NAME[i], self.OnSelectEquip, self, i })
	end
	Dialog:Say(self.MSG_EQUIP, self.tbEquitSelItem);
end

function tbSeriesInfoBook:OnSelectEquip(nEquipPos)
	self.nSelEquip = nEquipPos;
	self:OnViewSeries();
end

function tbSeriesInfoBook:OnViewSeries()
	self.tbSeriesSelItem = {};
	for i = Env.SERIES_METAL, Env.SERIES_EARTH do
		table.insert(self.tbSeriesSelItem, { Env.SERIES_NAME[i], self.OnSelectSeries, self, i })
	end
	Dialog:Say(self.MSG_SERIES, self.tbSeriesSelItem);
end

function tbSeriesInfoBook:OnSelectSeries(nSeries)
	self.nSelSeries = nSeries;
	self:Conclusion();
end

function tbSeriesInfoBook:Conclusion()
	local nAccruedSeries = KMath.AccruedSeries(self.nSelSeries);
	local nAccrueSeries  = KMath.AccrueSeries(self.nSelSeries);
	local nEquipActive1, nEquipActive2   = KItem.GetEquipActive(self.nSelEquip);
	local nEquipActived1, nEquipActived2 = KItem.GetEquipActived(self.nSelEquip);
	
	local szMsg = "您当前指定要查询的装备是<color=red>"..tostring(Env.SERIES_NAME[self.nSelSeries]).."<color>属性的<color=red>"..
	tostring(Item.EQUIPPOS_NAME[self.nSelEquip]).."<color>。它能够被<color=red>"..tostring(Env.SERIES_NAME[nAccruedSeries]).."<color>属性的<color=red>"..
		tostring(Item.EQUIPPOS_NAME[nEquipActive1]).."<color>，<color=red>"..tostring(Item.EQUIPPOS_NAME[nEquipActive2]).."<color>激活。能够激活<color=red>"..
		tostring(Env.SERIES_NAME[nAccrueSeries]).."<color>属性功能的<color=red>"..tostring(Item.EQUIPPOS_NAME[nEquipActived1]).."<color>和<color=red>"..
		tostring(Item.EQUIPPOS_NAME[nEquipActived2]).."<color>。";

	local tbDialog =
	{
		{ "继续查询", self.OnViewEquip, self },
		{ "结束" },
	};
	Dialog:Say(szMsg, tbDialog);

end
