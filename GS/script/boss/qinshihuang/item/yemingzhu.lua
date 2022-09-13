-------------------------------------------------------
-- 文件名　：yemingzhu.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-10 10:34:06
-- 文件描述：
-------------------------------------------------------

-- 定义标示名字："\\setting\\item\\001\\other\scriptitem.txt"
local tbYemingzhuItem = Item:GetClass("qinling_yemingzhu");

function tbYemingzhuItem:OnUse()
	
	local tbOpt = {
		{"是", Boss.Qinshihuang.OnUseYemingzhu, Boss.Qinshihuang, me.nId},
		{"否"},
	}
	
	local nNum = Boss.Qinshihuang:GetCostNum(me);
	local szMsg = string.format("使用夜明珠后，可以暂时在<color=yellow>一小时之内<color>缓解毒气对身体的侵害，<color=yellow>由于每个人的功力不同，所消耗的夜明珠数量也不同<color>，你需要使用<color=yellow>%d<color>颗夜明珠方能生效，确定要使用吗？（每层最多可叠加10小时）", nNum);
	Dialog:Say(szMsg, tbOpt);
	
	-- 不消失
	return 0;
end
