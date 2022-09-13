-- 文件名　：xuanzhan.lua
-- 创建者　：xiewen
-- 创建时间：2008-10-31 00:07:10

local tbNpc = Npc:GetClass("xuanzhan");

function tbNpc:OnDialog()
	-- if KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO) == 0 then
		-- Dialog:Say("领土争夺战将会在开放89等级上限后的第7天开放，请耐心等候。");
		-- return 0
	-- end
	local tbOpt =
	 {
		{"Quân nhu Lãnh thổ chiến", Domain.DlgJunXu, Domain},
		{"Phần thưởng chinh chiến", Domain.AwardDialog, Domain},
		{"Bang hội quán", self.OpenTongShop, self},
		{"Thiết lập thành chính", Domain.SelectCapital_Intro, Domain},
		{"Mua trang bị danh vọng Lãnh thổ chiến", self.OpenReputeShop, self},
		{"Kết thúc đối thoại"},
	}
	if Domain:GetBattleState() == Domain.PRE_BATTLE_STATE then
		tbOpt = Lib:MergeTable({{"Tuyên chiến", Domain.DeclareWar_Intro, Domain}}, tbOpt);
	end
	
	-- if  me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,7) == 0 or me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,8) == 0
      -- or me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,9) == 0 or me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,10) == 0
      -- or me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,11) == 0 or me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,12) == 0 
    -- then
      -- tbOpt = Lib:MergeTable({{"<color=yellow>Lãnh thổ chiến trong từ điển Kiếm Thế<color>", self.AwardQuestion, self}}, tbOpt);
	-- end
	
	local szSay = [[
    Kèn lệnh tranh đoạt lãnh thổ đã vang lên, giờ là thời đại tranh giành của các anh hùng!
    Mỗi tuần vào <color=green>20:00~21:30 Thứ 6, Chủ nhật<color>, các Bang hội có thể tấn công các lãnh thổ trong trò chơi, sau khi chiếm được lãnh thổ có thể nhận uy danh, bạc khóa, huyền tinh và các loại trang bị thần bí khác.
]]
	Dialog:Say(szSay,tbOpt);
end

function tbNpc:OpenTongShop()
	me.OpenShop(145, 9);
end

function tbNpc:OpenReputeShop()
	me.OpenShop(147, 1);
end

function tbNpc:AwardQuestion()
  if me.nLevel <80 then
		local tbOpt =
	  {
		  {"Quay về", self.OnDialog, self},
		  {"Kết thúc đối thoại"},		
	  }
		
		Dialog:Say("Bạn chưa đạt cấp 80, chưa thể tham gia từ điển Kiếm Thế.",tbOpt);
      
  else
   
	  local tbOpt =
	  {
	 	  {"Quay về", self.OnDialog, self},
		  {"Kết thúc đối thoại"},		
	  }
	    if me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,12) == 0 then
	       tbOpt = Lib:MergeTable({{"问答<color=green>规则篇（二）<color>", HelpQuestion.StartGame, HelpQuestion, me, 12}}, tbOpt);
	    end    
	    if me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,11) == 0 then
	       tbOpt = Lib:MergeTable({{"问答<color=green>帮会设置篇<color>", HelpQuestion.StartGame, HelpQuestion, me,11}}, tbOpt);	       
		  end
	    if me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,10) == 0 then
	       tbOpt = Lib:MergeTable({{"问答<color=green>NPC篇<color>", HelpQuestion.StartGame, HelpQuestion, me,10}}, tbOpt);	       
	  	end
	    if me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,9) == 0 then
	       tbOpt = Lib:MergeTable({{"问答<color=green>界面篇<color>", HelpQuestion.StartGame, HelpQuestion, me,9}}, tbOpt);
	    end    
	    if me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,8) == 0 then
	       tbOpt = Lib:MergeTable({{"问答<color=green>规则篇<color>", HelpQuestion.StartGame, HelpQuestion, me,8}}, tbOpt);
	    end
	    if me.GetTaskBit(HelpQuestion.TASK_GROUP_ID,7) == 0 then
	       tbOpt = Lib:MergeTable({{"问答<color=green>流程篇<color>", HelpQuestion.StartGame, HelpQuestion, me, 7}}, tbOpt);
	    end    
	local szSay = string.format([[    这位侠士，您是否已经熟悉了领土战的相关规则和流程了呢？
    我这里有若干道问题，如果您能全部答对，我会奖励您丰厚的绑定%s。问题有点难度，建议您仔细阅读F12帮助锦囊里的详细帮助，熟读完领土战相关内容后再来答题。
    您是否准备好开始答题了么？
]], IVER_g_szCoinName);
	Dialog:Say(szSay,tbOpt);

   end
end
