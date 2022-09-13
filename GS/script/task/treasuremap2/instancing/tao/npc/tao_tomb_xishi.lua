
-- ====================== 文件信息 ======================

-- 陶朱公疑冢无名女子（西施）脚本
-- Edited by peres
-- 2008/03/09 PM 16:14

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================


local tbNpc = Npc:GetClass("tao2_tomb_xishi");

function tbNpc:OnDialog()
	local szTalk	= [[<color=yellow><playername><color>: Cô nương, sao lại ở đây 1 mình vậy?<end>
						<color=red><npc=2705><color>: Tức ngực quá…<end>
						<color=yellow><playername><color>: Cô nương không sao chứ? Nơi này rất nguy hiểm, mau cùng ta rời khỏi!<end>
						<color=red><npc=2705><color>: Đau lòng quá…<end>
						<color=yellow><playername><color>: Ta…<end>
						<color=yellow><playername><color>: Sao lại có cảm giác đáng sợ thế này, ta hãy mau đi khỏi đây thôi.<end>
]];
						
	TaskAct:Talk(szTalk, Npc:GetClass("tao2_tomb_xishi").TalkEnd, Npc:GetClass("tao2_tomb_xishi"));	
	return;
end


function tbNpc:TalkEnd()
	return;
end;
