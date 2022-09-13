-- 文件名　：snowman_file.lua
-- 创建者　：zounan
-- 创建时间：2009-11-24 10:58:37
-- 描  述  ：

Require("\\script\\event\\jieri\\200812_xmas\\snowman\\snowman_def.lua");
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;
function XmasSnowman:LoadGameType()
	local tbFile = Lib:LoadTabFile("\\setting\\event\\jieri\\200812_xmas\\snowman\\xueren.txt");
	if not tbFile then
		print("【圣诞】读取文件错误，文件不存在xueren.txt");
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		local nIndex = tonumber(tbParam.Index) or 0;
		XmasSnowman.SNOWMAN_POS[nIndex] = XmasSnowman.SNOWMAN_POS[nIndex] or {};
		XmasSnowman.SNOWMAN_POS[nIndex].nMapId = tonumber(tbParam.MapId);	
		XmasSnowman.SNOWMAN_POS[nIndex].nX = math.floor((tonumber(tbParam.TRAPX) )/32);
		XmasSnowman.SNOWMAN_POS[nIndex].nY = math.floor((tonumber(tbParam.TRAPY) )/32);
		XmasSnowman.SNOWMAN_POS[nIndex].bOpen = tonumber(tbParam.bOpen) or 0;
		local tbFile2 = Lib:LoadTabFile("\\setting\\event\\jieri\\200812_xmas\\snowman\\xuerenguoguo\\"..tbParam.File);
		if not tbFile2 then
			print("【圣诞】读取文件错误，文件不存在 xuerenguoguo\\"..tbParam.File);
			return;	
		end
		for nId2, tbParam2 in ipairs(tbFile2) do
			XmasSnowman.CHEST_POS[nIndex] = XmasSnowman.CHEST_POS[nIndex] or {};
			local nX = math.floor((tonumber(tbParam2.TRAPX) )/32);
			local nY = math.floor((tonumber(tbParam2.TRAPY) )/32);
			table.insert(XmasSnowman.CHEST_POS[nIndex], {nX = nX, nY = nY});
		end				
	end
	
	
	tbFile = Lib:LoadTabFile("\\setting\\event\\jieri\\200812_xmas\\snowman\\xiaoxuedui.txt");
	if not tbFile then
		print("【圣诞】读取文件错误，文件不存在xiaoxuedui.txt");
		return;
	end		
	for nId, tbParam in ipairs(tbFile) do
		local nIndex = tonumber(tbParam.Index) or 0;
		XmasSnowman.SNOWBALL_POS[nIndex] = XmasSnowman.SNOWBALL_POS[nIndex] or {};
		local nX = math.floor((tonumber(tbParam.TRAPX) )/32);
		local nY = math.floor((tonumber(tbParam.TRAPY) )/32);
		table.insert(XmasSnowman.SNOWBALL_POS[nIndex], {nX = nX, nY = nY});
	end

	tbFile = Lib:LoadTabFile("\\setting\\event\\jieri\\200812_xmas\\snowman\\xuerenzhizhong.txt");
	if not tbFile then
		print("【圣诞】读取文件错误，文件不存在xuerenzhizhong.txt");
		return;
	end		
	for nId, tbParam in ipairs(tbFile) do
		local nIndex = tonumber(tbParam.Index) or 0;
		XmasSnowman.SNOWSEED_POS[nIndex] = XmasSnowman.SNOWSEED_POS[nIndex] or {};
		XmasSnowman.SNOWSEED_POS[nIndex].nX = math.floor((tonumber(tbParam.TRAPX) )/32);
		XmasSnowman.SNOWSEED_POS[nIndex].nY = math.floor((tonumber(tbParam.TRAPY) )/32);
	end
end

if MODULE_GAMESERVER then
XmasSnowman:LoadGameType();
end
