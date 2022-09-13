--初级大会官员
--孙多良
--2008.09.12

local tbNpc = Npc:GetClass("Wldh_guanyuan1");

function tbNpc:OnDialog()
	local nType, nIsFinal = Wldh:GetCurGameType();
	if nType <= 0 then
		Dialog:Say("你好，有什么需要帮忙吗？");
		return 0;
	end
	local szMsg = "";
	if nIsFinal > 0 then
		szMsg = string.format([[
   现在的赛制是<color=yellow>%s决赛<color>阶段。
   比赛时间表如下：<color=yellow>
      20：00  32进16
      20：15  16进8
      20：30  8进4
      20：45  4进2
      21：00  2进1 第一场
      21：15  2进1 第二场
      21：30  2进1 第三场<color>]], Wldh:GetName(nType));
    else
		szMsg = string.format("现在是%s阶段。\n\n%s", Wldh:GetName(nType),Wldh:GetDesc(nType));
	end
	local tbOpt = {
		{"参加本类型比赛", Wldh.DialogNpc.Attend, Wldh.DialogNpc, nType},
		{"选择赛制建立战队", Wldh.DialogNpc.ChoseType, Wldh.DialogNpc},
		{"查询战队信息", Wldh.DialogNpc.Query, Wldh.DialogNpc},
		{"Ta chỉ đến xem thôi"},
	};
	Dialog:Say(szMsg, tbOpt);
end
