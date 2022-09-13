-- 李金财脚本

local LiJinCai	= Npc:GetClass("jbexchange_npc");

if (not MODULE_GAMESERVER) then
	return;
end

LiJinCai.tbInfomation = 
{
	[1] = "除了在各大城市找<color=gold>金币交易管理员<color>对话外，也可以点击主界面<color=gold>奇珍阁商城<color>按钮，点击奇珍阁界面左边的<color=gold>金币交易所按钮<color>，即可打开金币交易所界面。";
	[2] = "在金币交易所里点击<color=gold>卖出金币<color>按钮，输入要卖出的金币单价和数量，点击确定会挂单上去，如果有符合价格的买方挂单，则交易自动成功。<color=green>卖出成功获得的银两将扣除交易总额1%的手续费，并存放在金币交易所里，需要手动取出。<color>\n"..
		  "金币交易所挂单时间最长是1周，从挂单那天算起，如果一周内这个单还没交易成功，会自动取消挂单。<color=green>交易取消后金币会退回角色帐户，并有邮件通知。<color>";
	[3] = " 在金币交易所里点击<color=gold>买入金币<color>按钮，输入要买入的金币单价和数量，点击确定会挂单上去，如果有符合价格的卖方挂单，则交易自动成功。<color=green>买入成功获得的金币将直接划入角色帐户。<color>\n"..
		  "金币交易所挂单时间最长是1周，从挂单那天算起，如果一周内这个单还没交易成功，会自动取消挂单。<color=green>交易取消后银两会存放在金币交易所里，并有邮件通知。<color>";
	[4] = "金币交易所的汇率是指每周金币和银两的兑换比例值。游戏中“装备强化和玄晶剥离所需的手续费”都与金币交易所的汇率相关，每天这些系统的手续费会随着每组服务器金币交易所的汇率而上下波动。";
	
}
-- 定义对话事件
function LiJinCai:OnDialog()
	-- if IVER_g_nSdoVersion == 1 then
		-- return
	-- end
	
	-- local szMsg	= "您好，这里是金币交易所。\n看好一把极品刀，可身上的银两不够怎么办？想在奇珍阁买东西可只有银两没有金币怎么搞？没关系，在金币交易所里，你可以用银两购买金币，也可以将自己的金币卖给有需要的人获得银两，各取所需。";
	local szMsg = "Tính năng này đã đóng.";
	Dialog:Say(szMsg, 
		{
			-- {"金币交易所",  LiJinCai.OpenJbExchange, 	self},
			-- {"帮助信息",    LiJinCai.HelpInformation, 	self},
			{"Ta chỉ tiện đường ghé qua"}
		});
end

function LiJinCai:OpenJbExchange()
	JbExchange:ApplyOpenJbExchange();
end

function LiJinCai:HelpInformation()
	Dialog:Say("帮助信息",
		{
			{"一、如何进入金币交易所？", 	 LiJinCai.ShowInfomation, self, 1},
			{"二、如何用金币兑换银两？",	 LiJinCai.ShowInfomation, self, 2},
			{"三、如何用银两兑换金币？",	 LiJinCai.ShowInfomation, self, 3},
			{"四、金币交易所的汇率是什么？", LiJinCai.ShowInfomation, self, 4},
			{"Ta chỉ tiện đường ghé qua"},
		});
end

function LiJinCai:ShowInfomation(nNum)
	local szMsg = self.tbInfomation[nNum];
	assert(szMsg);
	Dialog:Say( szMsg,
		{
			{ "返回上一层" , LiJinCai.HelpInformation, self};
			{ "Tôi hiểu" };
		})
end