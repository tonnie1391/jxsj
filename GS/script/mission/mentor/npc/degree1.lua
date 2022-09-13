-- 文件名　：degree1.lua
-- 创建者　：zhaoyu
-- 创建时间：2009/10/26 14:40:08
-- 描  述  ：进度1，接头npc

local tbNpc = Npc:GetClass("mentor_degree1");

function tbNpc:OnDialog()
	local tbMiss = Esport.Mentor:GetMission(me);
	local szMsg;
	local tbOpt;

	if (Esport.Mentor:CheckApprentice(me.nId) == 1 and tbMiss.nStep == 1) then
		szMsg = "准备好接受挑战了吗？";
		tbOpt = 
		{
			{"开始吧", self.OnStartGame, self},
			{"我再考虑"},
		};
	elseif Esport.Mentor:CheckApprentice(me.nId) == 1 and tbMiss.nStep == 3 then
		szMsg = "呜呜呜，前面的路有埋伏，好危险，请师傅送我过去吧，后面有蛮族首领追我，徒弟用<color=red>爆破陷阱<color>拦截吧";
		tbOpt = 
		{
			{"额，好吧！", self.OnStartProtect, self},
			{"哥不着。。。"},
		}
	elseif Esport.Mentor:CheckMaster(me.nId) == 1 then
		szMsg = "我觉得你徒弟比你长得帅，叫你徒弟来和我说话~";
		tbOpt = 
		{
			{"Kết thúc đối thoại"},
		};
	else
		szMsg = "不要迷恋哥，哥只是传说；不要迷恋姐，姐让你吐血。";
		tbOpt = 
		{
			{"吐血"},
		};
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnStartGame()
	local tbMiss = Esport.Mentor:GetMission(me);
	tbMiss:SendMessage("副本已启动，战斗即将开始，请做好准备！");
	tbMiss:GoNextStep();
end

function tbNpc:OnStartProtect()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("背包已满，请保证背包中有空格子存放道具！");
		return;
	end
	
	local nRet = me.AddItem(unpack(Esport.Mentor.tbBoom));
		
	local tbMiss = Esport.Mentor:GetMission(me);
	tbMiss:GoNextStep();
end