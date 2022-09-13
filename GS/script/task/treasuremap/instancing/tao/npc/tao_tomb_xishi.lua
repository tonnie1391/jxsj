
-- ====================== 文件信息 ======================

-- 陶朱公疑冢无名女子（西施）脚本
-- Edited by peres
-- 2008/03/09 PM 16:14

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================


local tbNpc = Npc:GetClass("tao_tomb_xishi");

function tbNpc:OnDialog()
	local szTalk	= [[<color=yellow><playername><color>：这位姑娘，你怎么会一个人在这里？<end>
						<color=red><npc=2705><color>：心口好痛……<end>
						<color=yellow><playername><color>：姑娘！？你没事吧？这里很危险，还是快跟我一起出去吧！<end>
						<color=red><npc=2705><color>：心里好痛……<end>
						<color=yellow><playername><color>：这……<end>
						<color=yellow><playername><color>：怎么有种阴森的感觉，我还是赶紧走吧。<end>]];
						
	TaskAct:Talk(szTalk, Npc:GetClass("tao_tomb_xishi").TalkEnd, Npc:GetClass("tao_tomb_xishi"));	
	return;
end


function tbNpc:TalkEnd()
	return;
end;
