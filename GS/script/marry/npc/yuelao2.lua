-- 文件名　：yuelao2.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-13 11:37:53
-- 功能描述：结婚相关npc（提供对话选项的教育npc）

local tbNpc = Npc:GetClass("marry_yuelao2");

function tbNpc:OnDialog()
	local szMsg = "醉酒当歌，人生几何，来来来，让我们痛饮三杯！";
	local tbOpt = {
		{"我要参观侠士名居", self.GetJiaoyuMsg1, self},
		{"我要参观贵族庄园", self.GetJiaoyuMsg2, self},
		{"我要参观王侯海滩", self.GetJiaoyuMsg3, self},
		{"我要参观皇家仙境", self.GetJiaoyuMsg4, self},
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
