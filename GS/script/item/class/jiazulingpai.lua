------------------------------------------------------
--文件名		：	jiazulingpai.lua
--创建者		：	zhengyuhua
--创建时间		：	2007-11-29
--功能描述		：	家族领牌脚本。
------------------------------------------------------
local tbItemJiaZuLingPai = Item:GetClass("jiazulingpai");
tbItemJiaZuLingPai.BEGIN_TIME		= 19 * 60 + 30	-- 允许使用的开始时间
tbItemJiaZuLingPai.END_TIME			= 23 * 60 + 30	-- 允许使用的结束时间


-- 设置插旗时间和记录地点
function tbItemJiaZuLingPai:OnUse()
	local nKinId = me.dwKinId;
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end

-- 判断时间是否正确	
	local nHour = tonumber(GetLocalDate("%H"));
	local nMinu = tonumber(GetLocalDate("%M"));
	local nNowTime = nHour * 60 + nMinu;
	if nNowTime < self.BEGIN_TIME or nNowTime > self.END_TIME then
		me.Msg("Chỉ có thể sử dụng trong khung giờ từ 19:30 đến 23:30 giờ!");
		return 0;
	end
	
-- 判断该地图是否合法
	local cSelfNpc = me.GetNpc();
	local nMapId, nMapX, nMapY = cSelfNpc.GetWorldPos();
	if GetMapType(nMapId) ~= "village" and GetMapType(nMapId) ~= "city" then
		me.Msg("Chỉ có thể sử dụng trong thành thị hoặc tân thủ thôn.");
		return 0;
	end
	
-- 弹出插旗时间设置窗口
	me.CallClientScript({"UiManager:OpenWindow", "UI_KINBUILDFLAG"});
	return 0;
end
