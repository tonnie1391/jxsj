------------------------------------------------------
-- 文件名　：degree2.lua
-- 创建者　：dengyong
-- 创建时间：2009-10-28 17:27:24
-- 描  述  ：
------------------------------------------------------ 

local tbNpc = Npc:GetClass("mentor_degree2");

function tbNpc:OnDialog()
	local tbMiss = Esport.Mentor:GetMission(me);
	local szMsg, tbOpt = "", {};

	if Esport.Mentor:CheckApprentice(me.nId) == 1 and tbMiss.nStep == 1 then
		szMsg = "接下来你们将遇到剑侠世界里最最邪恶的任务了————杀死狗男女！！本来这对狗男女本事也平平，但却不知在哪儿习了“谁越讨厌我我就越在他面前晃”的歪魔邪功，除非两个人先后被打败的时间差在5秒之内，否则这两人就会借对方之躯瞬间回满气血，你们可要注意了！";
		tbOpt = 
		{
			{"放心，我们松松搞定", self.OnAccept, self},
			{"我有点儿慌，让Để ta suy nghĩ thêm！"},
		};
	else
		return;
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnAccept()
	local tbMiss = Esport.Mentor:GetMission(me);
	tbMiss:SendMessage("副本已启动，战斗即将开始，请做好准备！");
	tbMiss:GoNextStep();
end