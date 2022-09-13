-- 神秘家书
local tbCJDBook = Item:GetClass("cjdbook");
tbCJDBook.USEMAXTIME = 500;
tbCJDBook.tbInfo = 
{
	"<color=gold>头顶有惊叹号的人表示有任务可接，头顶有问号的人表示有任务可交。",
	"<color=gold>按下Tab键打开小地图，可以看到当前地图的重要信息。",
	"<color=gold>单击任务按钮或快捷键F12进入任务面板，在步骤描述中点黄色字体，可以自动行走到该任务地点。",
	"<color=gold>单击背包按钮或快捷键F2进入背包面板，将药品拖动到快捷栏，就能使用数字快捷键迅速使用了。道具、技能都可以使用这种方式。",
	"<color=gold>比如回城符，许多物品都可以在背包中的道具图标上单击鼠标右键使用。",
	"<color=gold>按回车键Enter打开聊天栏，输入你要对的下联，再按回车就可以发送出去了。注意聊天频道的区别。",
	"<color=gold>点界面上的好友按钮，再点中对方，发出好友邀请；CTRL+鼠标右键点中对方，再点击弹出菜单中的好友按钮，发出好友申请；用快捷键操作Ctrl+F。",
	"<color=gold>与游戏世界的人物对话时，点击对话框中的’交易’选项，可以打开商店界面，选购道具装备。",
	"<color=gold>装备之间的激活，是依五行生克而定。金生水，水生土，土生木，木生火，火生金。",
	"<color=gold>本门武艺有数条路线，一旦选择某条路线的技能，投上一点，便只能修炼此条路线了，要慎重选择。",
	"<color=gold>可以通过门派接引弟子回到本门，找到掌门人领取门派任务。",
	"<color=gold>点击界面上的组队按钮、或使用快捷键P打开组队面板。在面板中发布组队信息，或求组信息；Ctrl+鼠标右键点击要组队的玩家，在弹出菜单中选择组队或入队。",
	"<color=gold>奇珍阁的打开方式：按下界面上的按钮；用快捷键Ctrl+z。",
	"<color=gold>使用Ctrl+Tab键可以实现数种界面风格的切换。",
	"<color=gold>加工系技能需消耗活力。活力值可通过做师门任务、主线任务与离线托管获得。",
	"<color=gold>制造系技能需消耗精力。精力值可通过做师门任务、主线任务与离线托管获得,"
}

function tbCJDBook:OnUse()
	local nMeUseCount = me.GetTask(1021, 1) or 0;
	if (nMeUseCount >= self.USEMAXTIME) then
		me.Msg("使用的次数超过500次，不能继续使用。");
		return 0;
	end
	
	local nRandomInfoIdx = MathRandom(1, #self.tbInfo);
	Dialog:Say("游戏小提示：\n"..self.tbInfo[nRandomInfoIdx])
	me.AddExp(100);
	me.SetTask(1021, 1, nMeUseCount + 1);
	return 1;
end;
