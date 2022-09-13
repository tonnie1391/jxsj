-- 文件名　：waitmap.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-11 16:31:35
-- 描  述  ：
local tbNpc = Npc:GetClass("dragonboat_waitmap");

function tbNpc:OnDialog()
	local szMsg = "Thi đấu sắp diễn ra, ngươi chuẩn bị tinh thần chưa?\n";
	local tbOpt = {
		{"Ta có việc phải đi rồi", self.OnLeave, self},
		{"Ta chỉ xem qua"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnLeave()
	local nMapId, nPosX, nPosY = EPlatForm:GetLeaveMapPos();
	local tbMCfg = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType());
	if (not tbMCfg) then
		Dialog:Say("Có lỗi xảy ra...");
		me.NewWorld(nMapId, nPosX, nPosY);
		return 0;
	end

	local nNpcMapId = him.nMapId;
	local nReadyId = 0;
	for nId, nReadyMapId in pairs(tbMCfg.tbReadyMap) do
		if (nNpcMapId == nReadyMapId) then
			nReadyId = nId;
			break;
		end
	end
	
	if (nReadyId <= 0) then
		Dialog:Say("Có lỗi xảy ra...");
		me.NewWorld(nMapId, nPosX, nPosY);
		return 0;
	end
	
	if EPlatForm.ReadyTimerId > 0 then
		if Timer:GetRestTime(EPlatForm.ReadyTimerId) < EPlatForm.DEF_READY_TIME_ENTER then
			Dialog:Say("Thi đấu sắp diễn ra, ngươi không nên rời đi.");
			return 0;
		end
	end
	if EPlatForm.ReadyTimerId <= 0 then
		Dialog:Say("Có lỗi xảy ra, hãy đăng nhập lại.")
		return 0;
	end
	me.TeamApplyLeave();			--离开队伍
	me.NewWorld(nMapId, nPosX, nPosY);
end
