 ------------------------------------------------------
-- 文件名　：degree3.lua
-- 创建者　：dengyong
-- 创建时间：2009-10-28 17:46:00
-- 描  述  ：
------------------------------------------------------

local tbNpc = Npc:GetClass("mentor_degree3");

function tbNpc:OnDialog()
	local tbMiss = Esport.Mentor:GetMission(me);
	local szMsg, tbOpt = "", {};
	if Esport.Mentor:CheckApprentice(me.nId) == 1 and tbMiss.nStep == 1 then
		szMsg = "哈哈哈，冰封堡终于是我的了！！哈哈哈~~现在这里一切都由我说了算了，也包括你们。顺我者昌，逆我者亡！你们要是臣服于我，或许还有一条生路；不然，嘿嘿。。";
		tbOpt = 
		{
			{"放你妈的屁，爷爷生在天地间，顶天立地，岂能向你这种小儿低头！", self.OnAccept, self},
			{"是是是，堡主英明堡主万岁，我等二人从此归顺堡主，忠心不二！"},
		}
	else
		return;
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnAccept()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("背包已满，请保证背包中有空格子存放道具！");
		return;
	end
	
	local nRet = me.AddItem(unpack(Esport.Mentor.tbFreeze));
	
	local tbMiss = Esport.Mentor:GetMission(me);
	tbMiss:SendMessage("副本已启动，战斗即将开始，请做好准备！");

	
	tbMiss:GoNextStep();
end
