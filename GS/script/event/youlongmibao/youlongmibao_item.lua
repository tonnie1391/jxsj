-------------------------------------------------------
-- 文件名　：youlongmibao_item.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-11-09 14:45:39
-- 文件描述：
-------------------------------------------------------

Require("\\script\\event\\youlongmibao\\youlongmibao_mapmgr.lua");

local tbItem = Item:GetClass("youlongzhanshu");

function tbItem:OnUse()

	-- 城市和新手村
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then
		me.Msg("Chỉ có thể sử dụng Chiến Thư trong thành thị và tân thủ thôn.");
		return 0;
	end
	
	-- 角色50级
	if me.nLevel < 50 then
		me.Msg("Cấp độ yêu cầu lớn hơn 50.");
		return 0;
	end
	
	-- 加入门派
	if me.nFaction <= 0 then
		me.Msg("Chưa gia nhập môn phái không thể sử dụng.");
		return 0;
	end
	
	local tbOpt = 
	{
		{"Đúng vậy", Youlongmibao.Manager.JoinPlayer, Youlongmibao.Manager, me},
		{"Để ta suy nghĩ thêm"},
	};
	
	Dialog:Say("Ngươi muốn tiến vào Mật thất Du Long sao?", tbOpt);
	
	return 0;
end
