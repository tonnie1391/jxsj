------------------------------------------------------
-- 文件名　：limituse.lua
-- 创建者　：dengyong
-- 创建时间：2010-08-26 11:06:02
-- 功能    ：加载道具使用限制检查配置
------------------------------------------------------

if MODULE_GC_SERVER then
	return;
end

local szSetting = "\\setting\\item\\001\\other\\limituse.txt"

-- 因为这个表是可以横向扩展的（即添加新的列），为了修改配置表时不需要修改加载接口
-- 所以这里没有用Lib:LoadTabFile()，而用了KLib.LoadTabFile()。
function Item:LoadLimitUseSetting()
	local tbData	= KLib.LoadTabFile(szSetting);
	if (not tbData) then	-- 未能读取到
		print("load "..szSetting.." failed!");
		return;
	end
	
	local tb = {};
	for i = 2, #tbData do
		local szItemClass = tbData[i][1];
		if tb[szItemClass] then
			assert(false);
		end
		
		tb[szItemClass] = {};
		for j = 2, #tbData[i] do
			if (tbData[i][j] and tbData[i][j] ~= "") then
				local nType = self.LIMITUSE_STR_TYPE[tbData[1][j]];
				assert(nType);
				
				local tbStr = Lib:SplitStr(tbData[i][j], "|");
				--[[
				if nType == self.emKLIMITUSE_MAPFORBID then
					tb[szItemClass][nType] = tbStr;
				elseif nType == self.emKLIMITUSE_MAPPROPER then
					assert(#tbStr == 1);
					tb[szItemClass][nType] = tbStr[1];
				end
				]]--
				for _, szMapClass in pairs(tbStr) do
					RegisgerLimitUseRule(szItemClass, nType, szMapClass, 1);
				end
			end
		end		
	end

end


Item.emKLIMITUSE_NONE = 0;
Item.emKLIMITUSE_MAPFORBID = 1;
Item.emKLIMITUSE_MAPPROPER = 2;
Item.emKLIMITUSE_COUNT = 3;

Item.LIMIT_FORBIDMAP = "ForbiddenMap";
Item.LIMIT_PROPERMAP = "ProperMap";

Item.LIMITUSE_STR_TYPE =
{
	[Item.LIMIT_FORBIDMAP] = Item.emKLIMITUSE_MAPFORBID,
	[Item.LIMIT_PROPERMAP] = Item.emKLIMITUSE_MAPPROPER,	
}

Item:LoadLimitUseSetting();