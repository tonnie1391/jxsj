-------------------------------------------------------
-- 文件名　：jieyinren.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-03-05 10:44:22
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("marry_jieyin");

function tbNpc:OnDialog()
	local szMsg = "关关雎鸠，在河之洲。窈窕淑女，君子好逑。这位大侠，看得出：你即使身在江湖，也有同心爱之人共度一生的美好愿望啊！";
	local tbOpt = 
	{
		{"<color=yellow>参加典礼<color>", Marry.AttendWedding, Marry},
		{"返回江津", self.TransBack, self},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:TransBack()
	me.NewWorld(5, 1633, 2957);
end
