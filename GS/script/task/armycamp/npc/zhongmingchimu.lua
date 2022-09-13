local tbZhongMingChiMu = Npc:GetClass("zhongmingchimu");

tbZhongMingChiMu.szText = "    驾长车，踏破贺兰山缺。壮志饥餐胡虏肉，笑谈渴饮匈奴血。待从头，收拾旧山河，朝天阙！少侠，你的成长让我欣慰，<color=yellow>以后我便不发布任务给你了，那些军营你要闯便闯，进去后你会自动获取任务的。<color>";
function tbZhongMingChiMu:OnDialog()
	local tbOpt = {{"Kết thúc đối thoại"}, };
	Dialog:Say(self.szText, tbOpt);
end;