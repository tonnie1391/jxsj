-- 文件名　：shiwujiangli_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-05-10 10:27:34
--实物奖励
if not MODULE_GC_SERVER then
	return;
end
SpecialEvent.tbShiwuJIang = SpecialEvent.tbShiwuJIang or {};
local tbShiwuJIang = SpecialEvent.tbShiwuJIang;
tbShiwuJIang.tbData = {};
tbShiwuJIang.tbItem = {"限量美女鼠标垫", "限量美女抱枕"};		--这里必须和scriptitem的物品相对应

--save
function tbShiwuJIang:SaveBuff(szAccount, szPlayerName, nType, szName, szTel)	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	self.tbData[nDate] = self.tbData[nDate] or {};
	table.insert(self.tbData[nDate], {szAccount, nType, szName, szTel});
	SetGblIntBuf(GBLINTBUF_SHIWUJIANGLI, 0, 1, self.tbData);
	self:SendMail(szPlayerName, nType, szName, szTel);
end

--sendmail
function tbShiwuJIang:SendMail(szPlayerName, nType, szName, szTel)
	local szMsg = string.format("恭喜您获得实物奖励：<color=green>%s<color>\n您的真实姓名：<color=yellow>%s<color>\n联系电话：<color=yellow>%s<color>\n\n\n<color=red>真诚的感谢您对剑侠世界的支持，我们会在近期跟您确认联系方式，尽快给您发送奖励物品。<color>", self.tbItem[nType] or "", szName, szTel);
	SendMailGC(szPlayerName, "恭喜您获得实物奖励", szMsg);
	return;
end

function tbShiwuJIang:WriteFile()
	local szDate = os.date("%Y_%m_%d", GetTime());
	local tbData = self.tbData;
	local szContext = "GatewayId\tAccount\tType\tRoleName\tTelephone\n";
	local szOutFile = "\\playerladder\\"..szDate.."\\shiwu_" .. GetGatewayName() .. ".txt";
	local szMsg = "";
	for nData, tbInfo in pairs(tbData) do
		for _, tbInfoEx in ipairs(tbInfo) do
			szMsg = szMsg .. string.format("%s\t%s\t%s\t%s\t%s\n", GetGatewayName(), tbInfoEx[1], self.tbItem[tbInfoEx[2]] or tbInfoEx[2], tbInfoEx[3], tbInfoEx[4]);
		end
	end
	if szMsg == "" then
		return;
	end
	KFile.WriteFile(szOutFile, szContext);
	KFile.AppendFile(szOutFile, szMsg);
	self.tbData = {};
	SetGblIntBuf(GBLINTBUF_SHIWUJIANGLI, 0, 1, self.tbData);
end

function tbShiwuJIang:LoadBuffer_GC()	
	local tbBuffer = GetGblIntBuf(GBLINTBUF_SHIWUJIANGLI, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbData = tbBuffer;
	end
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbShiwuJIang.LoadBuffer_GC, SpecialEvent.tbShiwuJIang);
