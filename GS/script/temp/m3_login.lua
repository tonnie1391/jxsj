
M3_Test.szHead = "<head:\\image\\icon\\npc\\portrait_default_female.spr>";
M3_Test.tbSelect = {{"返回介绍目录", "M3_Test:Main"}, {"Kết thúc đối thoại", "M3_Test:Exit"}};


function M3_Test:Main()
	local nSex = me.nSex;
	local szSex = "";
	
	if nSex==0 then
		szSex = "公子";
	else
		szSex = "女侠";
	end;
	
	Dialog:Say(self.szHead.."蝶飘飘：这位"..szSex.."，欢迎您来到这个奇妙的剑侠世界，您现在想了解些什么呢？",
			   {
			    {"怎样获得装备", "M3_Test:ShowEquip"},
			    {"怎样获得技能", "M3_Test:ShowSkill"},
			    {"怎样获得任务", "M3_Test:ShowTask"},
			    {"怎样组队",     "M3_Test:ShowTeam"},			    
			    {"怎样参与擂台", "M3_Test:Pk"},
			    {"那我先去玩了", "M3_Test:Exit"},
			   });
end;


function M3_Test:ShowEquip()
	Dialog:Say(M3_Test.szHead.."蝶飘飘：上线就送装备大礼包：打开背包，右键点击大礼包，即可获得帆仔友情赞助的10件极品装备。还是全激活的哟！", M3_Test.tbSelect);	
end;

function M3_Test:ShowTask()
	Dialog:Say(M3_Test.szHead.."蝶飘飘：在龙泉村里找到季叔班，与他对话即可开展一段跌宕起伏的主线剧情故事！", M3_Test.tbSelect);
end;

function M3_Test:ShowTeam()
	Dialog:Say(M3_Test.szHead.."蝶飘飘：按 “P” 打开组队界面，可以邀请附近玩家入队或加入其他玩家队伍，还可以发布发组信息与招蓦队友信息，还可以跨服组队哦！", M3_Test.tbSelect);
end;

function M3_Test:ShowSkill()
	Dialog:Say(M3_Test.szHead.."蝶飘飘：当角色达到10级时，在龙泉村的唐军荣处、新手村的盲僧处及其他各NPC处都可选择加入门派。入派后，即可获得该门派各路线技能，选择喜欢的路线学习技能。目前已开放10个门派，26条路线。", M3_Test.tbSelect);
end;

function M3_Test:Pk()
	Dialog:Say(M3_Test.szHead.."蝶飘飘：1、在龙泉村建立新角色，通过与衙役对话，传送到临安府地图或者直接输入gm指令：<enter> ?gm ds NewWorld(29,1780,3508)<enter><enter>"..
			   "2、与其它玩家组队，队伍只能为2人，然后队长与临安府地图中的公平子对话，选择擂台比赛，需要选择双方比赛人数以及比赛场地，然后便可以进入擂台赛场进行擂台比武。",
			   M3_Test.tbSelect
			  );
end;

function M3_Test:Exit()
	
end;
