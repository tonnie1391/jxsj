-- 文件名　：scheduletask.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-27 16:10:50
-- 描  述  ：

function Esport:ScheduletaskDragonBoat()
	if Esport.DragonBoat:CheckState() == 1 then
		Esport.DragonBoatConsole:StartSignUp();
	end
end
