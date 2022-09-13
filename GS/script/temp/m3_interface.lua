
local m3_interface_test = Npc:GetClass("m3_test");

local m3_test = m3_interface_test;

function m3_test:OnDialog()
	Dialog:Say("<pic:\\image\\ui\\temp\\say.spr><head:\\image\\icon\\npc\\portrait_default_female.spr>[对话界面演示]<enter><enter>你知道，在村子西面山脚的池塘边长有一种叫红应子的花朵，它只会在每月初三那天早上的卯时开花，须刻即谢。现在你要做的就是去给我采集三朵红应子，至于怎么估算时辰你可以找村里的算命先生。<enter><enter>你只需要知道这个对我很重要，别的我不想多说了，去吧。",
				{{"放心好了，我这就去", m3_test.exit},
				 {"我想看看其它的任务", m3_test.task},
				 {"我想知道附近的一些信息", m3_test.exit},
				 {"今晚可以一起吃个饭吗", m3_test.exit},
				 {"Kết thúc đối thoại", m3_test.exit},});
end;



function m3_test:exit()
	
end;
