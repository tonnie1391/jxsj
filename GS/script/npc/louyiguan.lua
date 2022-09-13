------------------------------------------------------
-- 文件名　：louyiguan.lua
-- 创建者　：dengyong
-- 创建时间：2012-08-20 20:45:42
-- 描  述  ：青螺岛战舰上娄一关传送脚本
------------------------------------------------------
local tbNpc = Npc:GetClass("louyiguan_boat")

function tbNpc:OnDialog()
	local szMsg = "你好，需要我为你做点什么？"
	local tbOpt = 
	{
		{"送我回去吧", me.NewWorld, me.nMapId, 1677, 3723},
		{"不需要"},
	}
	Dialog:Say(szMsg, tbOpt);
end