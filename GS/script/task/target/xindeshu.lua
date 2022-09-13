							
						  
									
						

					   
local tbXinDeShu = Item:GetClass("xindeshu");

function tbXinDeShu:OnUse()
	if me.nLevel < Task.TaskExp.nLevel_UseXindeshu  then
		Dialog:Say(string.format("Bạn không đủ cấp %s, không thể sử dụng Tâm Đắc Thư!", Task.TaskExp.nLevel_UseXindeshu ), {"Biết rồi"});
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Cần 1 ô trống trong túi!",{"Biết rồi"});
		return 0;
	end
	 local nRegisterId = me.GetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_TASKID);
	 if nRegisterId <= 0 then	 	
		nRegisterId	= PlayerEvent:Register("OnAddInsightNew", Task.TaskExp.OnAddInsight, Task.TaskExp);
		me.SetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_TASKID, nRegisterId);
	end
	me.AddItem(unpack(Task.TaskExp.tbXinDeShu_ing));
	return 1;
end
																												   
						  
local tbXinDeShuing = Item:GetClass("xindeshuing");
function tbXinDeShuing:GetTip()
	local nCurInsight = it.GetGenInfo(1);	--当前经验值
	local nMaxLimit = Task.TaskExp.tbExp[me.nLevel][1];
	return string.format("<color=green>Kinh nghiệm tu luyện: %s/%s<color>", nCurInsight, nMaxLimit);
end

																												   
					   
local tbXinDeShued = Item:GetClass("xindeshued");
tbXinDeShued.DISUSELEVEL = Item.IVER_nInsightbookLevel; --低于书多少级才能使用

function tbXinDeShued:OnUse()	
	if Player:CheckTask(Task.TaskExp.TASK_GID,Task.TaskExp.TASK_DATE, "%Y%m%d", Task.TaskExp.TASK_USENUM, Task.TaskExp.nUseXindeMaxNum) == 0 then
		me.Msg("Bạn đã dùng Tâm Đắc Thư tối đa trong ngày, ngày mai hãy tiếp tục.");
		return 0;
	end
	local nTodayUsedCount = me.GetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_USENUM);
	if (me.nLevel < Task.TaskExp.nLevel_UseXindeshued) then
		me.Msg(string.format("Chỉ người chơi trên cấp %s mới có thể sử dụng Tâm Đắc Thư.", Task.TaskExp.nLevel_UseXindeshued));
		return 0;
	end
	
	local nCreatLevel = it.GetGenInfo(1);
	local nCanUseLevel = nCreatLevel - self.DISUSELEVEL + 1 ;
	if me.nLevel >= nCanUseLevel then
		me.Msg("Ngươi đã vượt cấp sử dụng Tâm Đắc Thư này, có mang theo cũng không ích gì.");
		return 0;
	end

	me.SetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_USENUM, nTodayUsedCount + 1);
	
	local nAddExp = Task.TaskExp.tbExp[me.nLevel][2];

													
	local nDelta = nCreatLevel - me.nLevel;
	if (nDelta >= 50) then		-- 心得书等级-角色等级 >=30且<50，则获得2倍经验
		nAddExp = nAddExp * 3;
	elseif (nDelta >= 30) then	-- 心得书等级-角色等级 >=50，则获得3倍经验
		nAddExp = nAddExp * 2;
	end

																										  
	local szCreaterName = it.szCustomString;
	local szTeacherName = me.GetTrainingTeacher();
	if (szCreaterName and szTeacherName and szCreaterName == szTeacherName) then
		Relation:AddFriendFavor(me.szName, szTeacherName, Task.TaskExp.nFAVOR);
		me.Msg("Sách này là do sư phụ của bạn viết, cho nên sau khi dùng thì độ thân mật tăng <color=yellow>" .. Task.TaskExp.nFAVOR .. " điểm<color>.");
		nAddExp = nAddExp * 2;
	end
	
	me.AddExp(nAddExp);
	me.Msg(string.format("Bạn đã lĩnh hội được quyển sách này, công lực tăng cao! Được (%d) điểm kinh nghiệm!", nAddExp));

	return 1;
end


																													 
function tbXinDeShued:GetTip()
	local nCreatLevel = it.GetGenInfo(1);
	local nAddExp = Task.TaskExp.tbExp[me.nLevel][2];
	local nTodayUsedCount = me.GetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_USENUM);
	
	local szTip = "";
	if (me.nLevel < Task.TaskExp.nLevel_UseXindeshued) then
		return "<color=0x8080ff>Phải đạt cấp "..Task.TaskExp.nLevel_UseXindeshued.." trở lên mới có thể dùng Tâm Đắc Thư<color>\n\n";
	end
	local nCanUseLevel = nCreatLevel - self.DISUSELEVEL + 1 ;
	if (nCanUseLevel > 0) then
		szTip = szTip.."<color=0x8080ff>Cấp sử dụng: Cấp  "..nCreatLevel.." trở xuống<color>\n\n";
	end
	
	szTip = szTip.."<color=0x8080ff>Kinh nghiệm nhận được: "..nAddExp.."<color>\n\n";
	szTip = szTip.."<color=0x8080ff>Hôm nay đã dùng: "..nTodayUsedCount.."/"..Task.TaskExp.nUseXindeMaxNum.." lần<color>\n\n";
	
	local nLimitLevel	= 0;
	local nTimes		= 1;
	local szMsg			= "";
	nLimitLevel = nCreatLevel - 30;
	if (nLimitLevel >= Task.TaskExp.nLevel_UseXindeshued) then		-- 心得书等级-角色等级 >=30且<50，则获得2倍经验	
		nTimes	= 2;
		szTip	= szTip .. "Người sử dụng không vượt quá cấp <color=yellow>" .. nLimitLevel .. "<color>, có thể nhận được hiệu quả gấp <color=yellow>" .. nTimes .. "<color>\n\n";
	end
	
	nLimitLevel = nCreatLevel - 50;
	if (nLimitLevel > Task.TaskExp.nLevel_UseXindeshued) then	-- 心得书等级-角色等级 >=50，则获得3倍经验
		nTimes	= 3;
		szTip	= szTip .. "Người sử dụng không vượt quá cấp <color=yellow>" .. nLimitLevel .. "<color>, có thể nhận được hiệu quả gấp <color=yellow>" .. nTimes .. "<color>\n\n";		
	end

	szTip = szTip.."<color=orange>"..it.szCustomString.."<color> <color=green>chế tạo<color>";
	return szTip;
end

					   
local tbXinDeShuZD = Item:GetClass("xindeshuzhuangding");

function tbXinDeShuZD:OnUse()
	if Player:CheckTask(Task.TaskExp.TASK_GID,Task.TaskExp.TASK_DATE, "%Y%m%d", Task.TaskExp.TASK_USENUM, Task.TaskExp.nUseXindeMaxNum) == 0 then
		me.Msg("Bạn đã dùng Tâm Đắc Thư tối đa trong ngày, ngày mai hãy tiếp tục.");
		return 0;
	end
	local nTodayUsedCount = me.GetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_USENUM);
	if (me.nLevel < Task.TaskExp.nLevel_UseXindeshued) then
		me.Msg(string.format("Chỉ người chơi trên cấp %s mới có thể sử dụng Tâm Đắc Thư.", Task.TaskExp.nLevel_UseXindeshued));
		return 0;
	end	
	me.SetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_USENUM, nTodayUsedCount + 1);
	
	local nAddExp = Task.TaskExp.tbExp[me.nLevel][2];
	
	me.AddExp(nAddExp);
	me.Msg(string.format("Bạn đã lĩnh hội được quyển sách này, công lực tăng cao! Được (%d) điểm kinh nghiệm!", nAddExp));

	return 1;
end

function tbXinDeShuZD:GetTip()
	local nAddExp = Task.TaskExp.tbExp[me.nLevel][2];
	local nTodayUsedCount = me.GetTask(Task.TaskExp.TASK_GID, Task.TaskExp.TASK_USENUM);
	local szTip = "";
	if (me.nLevel < Task.TaskExp.nLevel_UseXindeshued) then
		return "<color=0x8080ff>Phải đạt cấp "..Task.TaskExp.nLevel_UseXindeshued.." trở lên mới có thể dùng Tâm Đắc Thư<color>\n\n";
	end		
	szTip = szTip.."<color=0x8080ff>Kinh nghiệm nhận được: "..nAddExp.."<color>\n\n";
	szTip = szTip.."<color=0x8080ff>Hôm nay đã dùng: "..nTodayUsedCount.."/"..Task.TaskExp.nUseXindeMaxNum.." lần<color>\n\n";

	return szTip;
end
