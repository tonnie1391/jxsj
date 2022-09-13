-- 文件名  : dts_chefu.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-17 10:06:08
-- 描述    : 车夫


local tbNpc = Npc:GetClass("dts_chefu");

function tbNpc:OnDialog()	
	local szMsg = "你好！我可以带你离开寒武遗迹。"
	local tbOpt = 
	{
		{"离开寒武遗迹", self.TransToLocal, self},--		
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:TransToLocal()
	me.CallClientScript({"DaTaoSha:RefreshShortcutWindow"});
	Transfer:NewWorld2MyServer(me);
end