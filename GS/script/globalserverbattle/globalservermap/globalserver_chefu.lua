-------------------------------------------------------
-- 文件名　：globalserver_chefu.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 19:23:30
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("globalserver_chefu");

function tbNpc:OnDialog()
	if me.GetCamp() == 6 then
		Dialog:Say("记者记得要用GM卡哦！！！！！！")
		return;
	end
	local szMsg = "Xin chào! Ta có thể đưa ngươi rời khỏi Đảo Anh Hùng"
	local tbOpt = 
	{
		{"Hãy cho ta quá giang một đoạn", self.TransToLocal, self},
--		{"前往跨服宋金报名点", self.TransToBattle, self},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:TransToLocal()
	Transfer:NewWorld2MyServer(me);
end

function tbNpc:TransToBattle()
	me.NewWorld(1651, unpack(Wldh.Battle.POS_SIGNUP[MathRandom(1, 3)]));
end
