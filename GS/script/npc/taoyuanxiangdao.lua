-- 文件名　：taoyuanxiangdao.lua
-- 创建者　：xiewen
-- 创建时间：2008-12-10 16:32:42

local tbNpc = Npc:GetClass("taoyuanxiangdao");

--离开桃源,将玩家送到上次存档点
function tbNpc:GetOutOfTaoYuan()
	me.Msg("离开桃源");
	Player:SetFree(me.szName);
	
	--判断是否是通过非法收据道具的原因进入的桃源
	local nIsIllegalItem = me.GetTask(SpecialEvent.HoleSolution.TASK_COMPENSATE_GROUPID, SpecialEvent.HoleSolution.TASK_SUBID_REASON);
	if nIsIllegalItem == 1 or nIsIllegalItem == 2  or nIsIllegalItem == 3 then
		me.SetTask(SpecialEvent.HoleSolution.TASK_COMPENSATE_GROUPID, SpecialEvent.HoleSolution.TASK_SUBID_REASON, 0);	--将存放原因的任务变量清除
	end
end

function tbNpc:OnDialog()
	--判断是否是通过非法收据道具的原因进入的桃源
	local nIsIllegalItem = me.GetTask(SpecialEvent.HoleSolution.TASK_COMPENSATE_GROUPID, SpecialEvent.HoleSolution.TASK_SUBID_REASON);
	
	if nIsIllegalItem == 1 then	--是因为非法刷道具的原因进入的桃源
		self:OnDialog_Compensate();
	elseif nIsIllegalItem == 2 then		-- 因为多开客户端进来的
		self:OnDialog_MultiRunGame();
	elseif nIsIllegalItem == 3 then
		self:OnDialog_WG();
	else
		self:OnDialog_Original();
	end
	
end

--是因为非法刷取道具的原因进入桃源时进入这个对话
function tbNpc:OnDialog_Compensate()
	local nArrearage, nTaskVar = SpecialEvent.HoleSolution:GetBalanceValue();
	if nArrearage <= 0 then
		--如果两组任务变量的值都为0了，先将所有任务变量清零
		SpecialEvent.HoleSolution:SetTaskValue(0,0,1);
		SpecialEvent.HoleSolution:SetTaskValue(0,0,2);
		--再看看数据中还有没有其它的赔偿信息，有则设置到任务变量中并取出
		SpecialEvent.HoleSolution:IsPlayerInList();
		nArrearage, nTaskVar = SpecialEvent.HoleSolution:GetBalanceValue();
	end
	
	local szMsg = "";
	local tbOpt = {};
		
	local tbOpt = {};
	if 0 == nArrearage then
		szMsg = string.format("桃源向导：你已经成功补偿所有价值量,现在你可以离开桃源啦。");
		tbOpt = 
		{
		 {"我要马上离开。", self.GetOutOfTaoYuan, self},
		 {"我还想再呆会儿。"},
		}
	else
		szMsg = string.format("桃源向导：有人举报,你通过不正当手段刷取个人财富。目前,你还有<color=red>%d<color>条记录,在处理所有记录前,你将不能离开桃源!", SpecialEvent.HoleSolution:GetPlayerDebetCount());
		szMsg = szMsg..string.format("\n    在当前记录中,你还欠价值量为<color=red>%s<color>的财富。", nArrearage);
		tbOpt = SpecialEvent.HoleSolution:__ParseTheTaskVar(nTaskVar, nArrearage);
		table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

--因为其它原因进入桃源的进入这个对话
function tbNpc:OnDialog_Original()
	local tbDlg = {
		{"联系GM", self.ContactGM, self},
		{"Đóng lại"}
		}
	Dialog:Say("桃源向导：这是个隐蔽的地方哦，难道你是用了非法软件或者利用游戏漏洞进来的，赶快使用GM面板<color=red>联系GM<color>说明你的情况吧。也许你可以打死守卫，拿到剑侠世界的终极装备再走，不过桃源的宝藏，可是不好拿的哦。",
		tbDlg);
end

-- 多开进来的
function tbNpc:OnDialog_MultiRunGame()
	local nJailTerm = me.GetJailTerm();
	local nArrestTime = me.GetArrestTime();
	local nNow = GetTime();
	local nMinute = 0;
	if (nNow - nArrestTime < nJailTerm) then
		nMinute = math.ceil((nJailTerm - (nNow - nArrestTime)) / 60);
		local tbDlg = {
			{"联系GM", self.ContactGM, self},
			{"Đóng lại"}
			};
			Dialog:Say("桃源向导：捕快发现，你通过非法客户端多开游戏，在".. nMinute .."分钟内不能离开桃源。",
				tbDlg);
	else
		local tbDlg = {
			{"离开桃源", self.GetOutOfTaoYuan, self},
			{"Đóng lại"}
			};
			Dialog:Say("桃源向导：你的惩罚时间已到，可以离开桃源了。希望以后洁身自好，不要再犯。", tbDlg);		
	end
	
end

function tbNpc:OnDialog_WG()
	local nJailTerm = me.GetJailTerm();
	local nArrestTime = me.GetArrestTime();
	local nNow = GetTime();
	local nMinute = 0;
	if (nNow - nArrestTime < nJailTerm) then
		nMinute = math.ceil((nJailTerm - (nNow - nArrestTime)) / 60);
		local tbDlg = {
			{"联系GM", self.ContactGM, self},
			{"Đóng lại"}
			};
			Dialog:Say("桃源向导：捕快发现，你使用了非法客户端或插件，在".. nMinute .."分钟内不能离开桃源。",
				tbDlg);
	else
		local tbDlg = {
			{"离开桃源", self.GetOutOfTaoYuan, self},
			{"Đóng lại"}
			};
			Dialog:Say("桃源向导：你的惩罚时间已到，可以离开桃源了。希望以后洁身自好，不要再犯。", tbDlg);		
	end
end

function tbNpc:ContactGM()
	me.CallClientScript({"UiManager:OpenWindow", "UI_MSGBOARD"});
end
