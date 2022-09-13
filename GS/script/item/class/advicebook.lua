-- 成长锦囊
local tbAdviceBook = Item:GetClass("advicebook");

tbAdviceBook.szInfo = "    在险恶的江湖中生存，单靠个人的力量总有不支的时候。此时便需要广泛结识其他江湖侠客，依靠集体的力量度过难关。\n"


function tbAdviceBook:OnUse()
	local tbOpt = {};
	tbOpt = Lib:MergeTable( tbOpt,{
			{"如何聊天",	self.LiaoTian, self },
			{"如何加好友",	self.JiaHaoYou, self },
			{"如何组队",	self.ZuDui, self},
			{"Đóng lại"},
	});
			
	Dialog:Say(self.szInfo,tbOpt);
	
	return 0;
end;

function tbAdviceBook:LiaoTian()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say("    <color=gold>按下回车键（Enter）开启聊天模式。<color>在左下方的聊天输入栏内会出现闪烁的光标。\n"..
  	         "    点击光标左边“近”字图标，可以展开所有的聊天频道。<color=gold>10级加入门派后可以使用“派聊”，30级后可以使用“公聊”，55级后可以使用“城聊”。<color>选择完聊天频道后，在输入栏内输入语句，回车即可发送到该频道中。\n"..
  	         "    <color=gold>开启密聊（私聊）方法：\n"..
  	         "    1、在输入栏中输入“/对方角色名”，按回车键。\n"..
  	         "    2、在聊天频道内“Ctrl+左键”点击对方名字。\n"..
  	         "    3、在屏幕内“Ctrl+右键”点击对方名字，选择“聊天”指令。<color>\n"..
             "    点击聊天输入栏右边的笑脸图标，可以展开表情库。选择丰富多彩的表情可以使您的聊天对话更加生动。"
  ,tbOpt);
  	     
  return 0;
end;

function tbAdviceBook:JiaHaoYou()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say("    话说江湖儿女，走南闯北，怎能没个好友？\n"..
  	         "    <color=gold>加好友方法：\n"..
  	         "    1、	在聊天频道内左键点击发话角色的名字，在展开菜单项中选择“好友”。\n"..
  	         "    2、	在游戏画面中“Ctrl+右键”点击对方角色，在展开菜单项中选择“好友”。\n"..
  	         "    3、	按F5打开人际界面，点击“输名字添加好友”。<color>\n"..
  	         "    上述操作后，系统会向对方发送一份邀请结成好友关系的系统信息，此时被加方就成了主加方的<color=gold>临时好友（人际界面中白字显示）<color>。如果双方都进行了以上操作，则关系自动变为<color=gold>正式好友（人际界面中黄字显示）<color>。\n"..
             "    <color=gold>正式好友一起组队练级，满足一定时间后可以提升亲密度。<color>亲密度是成为家族成员和密友的条件。"
  ,tbOpt);
  	     
  return 0;
end;


function tbAdviceBook:ZuDui()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say("    组队的好处在于大家可以分享到更多的杀怪经验，以更快的速度提升等级，迈向武学上更高的层次。<color=gold>组队一起做同一任务，杀怪数量和任务物品获得都会得到共享。<color>\n"..
  	         "    组队方法：\n"..
  	         "    <color=gold>1、用“Ctrl+右键”点击画面中要组队的玩家，在弹出菜单中选择组队或入队。<color>邀请别人组队将会自动建立队伍，同时自己成为队长，<color=gold>队长角色头上有红旗标识。<color>\n"..
  	         "    <color=gold>2、点击界面上的组队按钮、或使用快捷键P打开组队面板。<color>可以在面板中发布组队信息，或求组信息。建立队伍后，队长可以在“招募队员”栏中点击“输入名字”，添加指定名字的队友。"

  ,tbOpt);
  	     
  return 0;
end;