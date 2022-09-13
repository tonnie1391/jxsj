
local tbNpc = Npc:GetClass("jiazuzhaomushi");

function tbNpc:OnDialog()
	Dialog:Say("有缘才会相聚，有心才会珍惜！和志同道合的江湖好汉一起战斗，一起畅谈，将是多么愉快的一件事呀！\n\n"..
	           "加入门派后，就可以在我这里查看家族招募信息，挑选心仪的家族申请加入。\n\n"..
	           "如果需要建立家族，就需要到各城市的找<color=green>武林盟主特使<color>黄裳大哥办理了。而我爷爷马穿山则在各大城市负责为参加<color=green>家族关卡<color>活动的侠客引路，加入家族后请务必前往了解哦！",
		{
			{"家族招募榜", self.OpenKinRecruitment, self},
			{"Kết thúc đối thoại"},
		})
end


function tbNpc:OpenKinRecruitment()
	if me.nFaction==0 then
	    Dialog:Say("您还未加入门派呢，请先找心仪门派的接引弟子到门派掌门处拜师吧。",
	    	{
			    {"Kết thúc đối thoại"},
		    }
		  )
	else
	    me.CallClientScript({"UiManager:OpenWindow", "UI_KINRCM_LIST" });
	end
end
