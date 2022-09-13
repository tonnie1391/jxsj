-- 文件名　：wlls_ladder.lua 联赛排行榜文件
-- 创建者　：zhouchenfei
-- 创建时间：2008-10-16 15:07:15

Require("\\script\\ladder\\define.lua")


if (MODULE_GC_SERVER) then
-- 更新联赛荣誉榜

function EPlatForm:GetType(nType, nNum1, nNum2, nNum3)
	nType = KLib.SetByte(nType, 3, nNum1);
	nType = KLib.SetByte(nType, 2, nNum2);
	nType = KLib.SetByte(nType, 1, nNum3);
	return nType;
end

end -- end MODULE_GC_SERVER


if (MODULE_GAMESERVER) then
	
end
