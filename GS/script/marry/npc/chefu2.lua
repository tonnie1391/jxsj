-- 文件名　：chefu2.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-13 11:37:53
-- 功能描述：结婚相关npc（提供对话选项的教育npc）

local tbNpc = Npc:GetClass("marry_chefu2");

function tbNpc:OnDialog()
	local szMsg = "万里之遥，瞬间到达，来，我们走！";
	local tbOpt = {
		{"我要参观侠士名居", self.GetJiaoyuMsg1, self},
		{"我要参观贵族庄园", self.GetJiaoyuMsg2, self},
		{"我要参观王侯海滩", self.GetJiaoyuMsg3, self},
		{"我要参观皇家仙境", self.GetJiaoyuMsg4, self},
		{"返回江津村找红姨老月", self.GetJiaoyuMsg5, self},		
		{"以后再来看吧"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetJiaoyuMsg1()
	me.NewWorld(498, 1633, 3309);
end

function tbNpc:GetJiaoyuMsg2()
	me.NewWorld(499, 1466, 3292);
end

function tbNpc:GetJiaoyuMsg3()
	me.NewWorld(500, 1601, 3185);
end

function tbNpc:GetJiaoyuMsg4()
	me.NewWorld(575, 1494, 3378);
end

function tbNpc:GetJiaoyuMsg5()
	me.NewWorld(5, 1633, 2957);
end