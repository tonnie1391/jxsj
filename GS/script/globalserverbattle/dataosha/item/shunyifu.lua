-- 文件名　：shunyifu.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-30 10:14:12
-- 描  述  ：

local tbItem 			= Item:GetClass("shunyifu");

function tbItem:OnUse()
	local nRound = DaTaoSha:GetPlayerMission(me).nRound;
	local tbPos = DaTaoSha.TRANS_POINT[nRound];
	me.NewWorld(me.nMapId, tbPos[1][1], tbPos[1][2]);
	return 1;
end
