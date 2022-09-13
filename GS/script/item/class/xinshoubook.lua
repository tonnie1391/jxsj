-- 新手锦囊
local tbXinShouBook = Item:GetClass("xinshoubook");

tbXinShouBook.szInfo = "    少主人，在您涉入江湖之前，需要了解一些必要的知识。当您遇到疑惑时，可以随时查阅这里的信息，或许能找到答案。\n"..
"    如果不慎遗失了这个锦囊，您可以<color=gold>点击主界面角色头像左边的问号<color>，或者<color=gold>按F12键，开启帮助锦囊界面<color>，在<color=gold>详细帮助<color>里提供了各类指南信息。\n"..
"                                                              秋姨字"


function tbXinShouBook:OnUse()
	local tbOpt = {};
	tbOpt = Lib:MergeTable( tbOpt,{
			{"基本操作",	self.JiBenCaoZuo, self },
			{"战斗操作",	self.ZhanDouCaoZuo, self },
			{"加入门派",	self.JiaRuMenPai, self},
			{"五行系统",	self.WuXingXiTong, self},
			{"交通指南",  self.JiaoTongZhiNan, self},
			{"练级指南",  self.LianJiZhiNan, self},
			{"天赐洪福",  self.TianCiHongFu, self},
			{"Đóng lại"},
	});
			
	Dialog:Say(self.szInfo,tbOpt);
	
	return 0;
end;

function tbXinShouBook:JiBenCaoZuo()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say("    <color=yellow>角色移动<color>：鼠标左键点击地面。按<color=gold>R键<color>可以切换走路和跑步。\n"..
  	         "    <color=yellow>与npc对话<color>：鼠标左键点击npc。头上有感叹号的npc表示有任务可以接，有问号表示有任务可以交。\n"..
  	         "    <color=yellow>查看任务<color>：按<color=gold>F4键<color>打开任务面板。点击<color=gold>带下划线的黄字<color>可以使用自动寻路功能。涉及到跨场景的自动寻路时，需要手动移动角色来切换场景。另外，在<color=gold>任务向导<color>一栏里列举出了当前等级能够接的所有任务。\n"..
  	         "    <color=yellow>查看地图<color>：按<color=gold>Tab键<color>打开小地图全图。在图上点击左键可以移动角色到插旗位置，按住右键可以拖动小地图。点击<color=gold>区域地图<color>和<color=gold>世界地图<color>按钮，可以查看周边场景和国家区域的地理方位以及场景间的连接路线。"
 
  ,tbOpt);
  	     
  return 0;
end;

function tbXinShouBook:ZhanDouCaoZuo()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
  	"    <color=yellow>攻击<color>：<color=gold>鼠标左键或者右键点击敌对目标<color>。在界面中下方可以设置左右键的攻击技能（点击怒字上方的两个图标）。使用技能需要搭配相应的武器。在加入门派后，按F3打开技能面板，将会增加门派的技能，投点学习后即可选择使用。\n"..
  	"    <color=yellow>战斗恢复<color>：<color=gold>酒楼老板处有食物出售<color>，恢复持续时效长，是打怪练级的必备品。<color=gold>药铺则出售药品<color>，恢复效果大但持续时效短，是PK的主要恢复品。此外，也可以按V键进行打坐来调息恢复。\n"..
  	"    <color=yellow>快捷栏<color>：所有可使用的道具物品以及招式技能，均可以<color=gold>左键拖放图标<color>到左下方的快捷栏，按<color=gold>数字键<color>来使用。\n"..
  	"    <color=yellow>拾取物品<color>：左键点击地面的物品，或者按<color=gold>空格键<color>进行快速拾取。左键把物品拖放到物品栏外可以进行丢弃操作。\n"..
  	"    <color=yellow>装备<color>：在物品栏里<color=gold>右键点击<color>装备类物品可将其装备到身上。<color=gold>所有装备到身上的物品都将与角色绑定，绑定后不可丢弃，只能在店铺卖掉处理<color>。"
  	,tbOpt);
  	     
  return 0;
end;



function tbXinShouBook:JiaRuMenPai()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
  	"   在角色等级达到<color=gold>10级<color>时，即可由新手村的<color=gold>各门派接引弟子<color>传送到<color=gold>掌门<color>处申请加入该门派。\n"..
  	"   每个门派根据战斗特色均划分两条路线，在加入门派后需要手动投点确认路线。在投点后，修炼路线暂时不能更改，需要等到角色到达60级时，方可从掌门处传送到洗髓岛洗点更换。\n"..
  	"   各门派的介绍，请查阅F12帮助锦囊里的详细帮助内容，或者访问官方网站的相关资料页面。"
  	,tbOpt);
  	     
  return 0;
end;


function tbXinShouBook:WuXingXiTong()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"门派五行划分",  self.WuXingHuaFen, self},
			{"装备激活顺序",  self.JiHuoShunXu, self},
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
  	"    五行系统是剑侠世界战斗体系的核心。五行即金、木、水、火、土。五行遵循相生相克原理。\n\n"..
    "    <color=gold>五行相克：金克木，木克土，土克水，水克火，火克金。<color>\n"..
    "    <color=gold>所有门派分属于这五行，遵循五行相克原理。<color>例如金系门派攻击木系门派时，攻击有额外的加成，而金系受到木系的攻击时会有额外的伤害减免。游戏中的NPC也有五行划分，利用五行相克挑选对自己有利的战斗对象，可以使战斗过程更加轻松。\n\n"..
    "    <color=gold>五行相生：金生水，水生木，木生火，火生土，土生金。<color>\n"..
    "    <color=gold>所有装备种类也分属于这五行，遵循五行相生原理。<color>例如，一把火属性的刀，需要装备上一件木属性的衣服，才能激活刀上的五行暗属性。"
  	,tbOpt);
  	     
  return 0;
end;


function tbXinShouBook:WuXingHuaFen()
   
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"装备激活顺序",  self.JiHuoShunXu, self},
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
     "\n    <color=yellow>金系：天王、少林<color>\n"..
     "    <color=green>木系：唐门、五毒、明教<color>\n"..
     "    <color=turquoise>水系：峨嵋、翠烟、段氏<color>\n"..
     "    <color=red>火系：丐帮、天忍<color>\n"..
     "    土系：武当、昆仑"
  	,tbOpt);
  	     
  return 0;
end;

function tbXinShouBook:JiHuoShunXu()
   
  local tbOpt = {}; 
  tbOpt = Lib:MergeTable( tbOpt,{
			{"门派五行划分",  self.WuXingHuaFen, self},
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
    "    <color=gold>按F1打开角色属性面板，点击“五行换装模式”，<color>可以查看各类装备激活的顺序。\n\n"..
    "帽子和武器，可以激活鞋子和护身符。\n"..
    "鞋子和护身符，可以激活护腕和腰坠。\n"..
    "护腕和腰坠，可以激活腰带和戒指。\n"..
    "腰带和戒指，可以激活衣服和项链。\n"..
    "衣服和项链，可以激活帽子和武器。\n\n"..
    "    <color=gold>装备Tips上有门派推荐提示，<color>按提示装备推荐自身门派的装备就可以完成五行相生激活。"
  	,tbOpt);
  	     
  return 0;
end;


function tbXinShouBook:JiaoTongZhiNan()
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
     "    <color=gold>每个新手村都与特定的门派和城市相连。<color>按Tab打开地图界面，可以通过<color=gold>区域地图<color>和<color=gold>世界地图<color>查看各新手村周边的交通路线。\n"..
     "    <color=gold>各新手村和城市的车夫可以相互传送。<color>\n"..
     "    每个新手村都有12大门派的接引弟子，负责传送玩家到该门派，同时<color=gold>各门派里的门派传送人会负责传送玩家回各新手村。<color>"
  	,tbOpt);
  	     
  return 0;
end;

function tbXinShouBook:LianJiZhiNan()
  
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"各级别练级指南",  self.LianJiDiTu, self},
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
     "    除了体验丰富的任务，您也可以在各练级地图磨炼自身的实力。\n\n"..
     "<color=yellow>一珠在手，潜力无穷<color>\n"..
     "    当角色到达<color=gold>20级<color>时，在<color=gold>门派掌门<color>处领取<color=gold>修炼珠<color>一枚，在练级时使用可以获得额外的经验和幸运加成。\n\n"..
     "<color=yellow>挑选合适的练级对手<color>\n"..
     "    按Tab键打开地图界面，点击打开区域地图，所有练级场景的名字后会有等级标识。点击图标查看练级场景的小地图，<color=gold>红字标识的即为练级怪区<color>。所有任务怪仅提供1点经验，练级需要打练级怪，并且当角色等级低于或超过怪物5级时，所获经验将大幅度递减。\n\n"..
     "<color=yellow>挑战精英首领，饮酒烤火侠意浓<color>\n"..
     "    15级以上练级地图的练级怪会有一定几率刷新<color=gold>精英<color>或<color=gold>首领<color>，打倒后会出现<color=gold>篝火<color>，<color=gold>组队状态下拾取点燃篝火<color>，在篝火附近会获得高额经验奖励，配合修炼珠会有显著的升级速度。<color=gold>在篝火状态下，喝酒会有额外的经验加成。<color>并且队伍里喝相同酒的人数越多，经验加成越大。<color=gold>酒由练级怪随机掉落，也可以在奇珍阁商城购买。<color>"
  	,tbOpt);
  	     
  return 0;
end;

function tbXinShouBook:LianJiDiTu()
	
	local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
	Dialog:Say(
     "    <color=gold>1~20级<color>建议做主线剧情任务升级（找各新手村的白秋琳接取），也可以在新手村周边的5级和15级地图打怪练级。\n"..
     "    <color=gold>21~50级<color>可以在门派周边的25级、35级、45级地图练级。\n"..    
     "    <color=gold>50~90级<color>可以在城市周边的地图练级。\n"..
     "    <color=gold>90级后<color>可以在新手村周边的高级地图练级。"
  	,tbOpt);
  	     
  return 0;
end;

function tbXinShouBook:TianCiHongFu()
  
  local tbOpt = {};
  tbOpt = Lib:MergeTable( tbOpt,{
			{"返回首页",  self.OnUse, self},
			{"Đóng lại"},
	});
   
  Dialog:Say(
     "    在野外打练级怪有一定几率会获得<color=gold>黄金福袋<color>。\n"..
     string.format("    打开福袋可以获得一定的奖励，包括经验、绑定银两或绑定%s。<color=gold>绑定%s可以在奇珍阁商城消费。<color>\n", IVER_g_szCoinName, IVER_g_szCoinName)..
     "    每个帐号每天开启的头10个福袋才能获得这些奖励，超过10个的黄金福袋仍然可以使用，但是只能得到100绑定银两的奖励。"
  	,tbOpt);
  	     
  return 0;
end;