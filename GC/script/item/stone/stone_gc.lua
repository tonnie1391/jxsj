------------------------------------------------------
-- 文件名　：stone_gc.lua
-- 创建者　：dengyong
-- 创建时间：2011-06-10 18:11:52
-- 描  述  ： 宝石GC脚本
------------------------------------------------------
if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\item\\stone\\define.lua");

Item.tbStone = Item.tbStone or {};
local tbStone = Item.tbStone;

-- 因为还需要通知GS做些事情，仅仅靠KGblTask的同步策略不好做，于是有了这个文件这个函数
function tbStone:SetOpenDay(nTime)	
	local nDay = Lib:GetLocalDay(nTime);
	local nOld = KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY);
	
	if nDay ~= nOld then
		-- gs需要做些独立的逻辑
		GlobalExcute({"Item.tbStone:SetOpenDay", nDay});
		KGblTask.SCSetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY, nDay);		
	end
end

-- 初始化的时候设置一下宝石系统的整体开关
function Item:StoneSysInit()
	if (self.tbStone.IsOpen ~= KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENFLAG)) then
		KGblTask.SCSetDbTaskInt(DBTASK_STONE_FUNCTION_OPENFLAG, self.tbStone.IsOpen);
	end
end

function tbStone:StoneSendMail()
local szTitle = "Bảo thạch kì lạ";
local szContent = [[
<Sender>Bạch Thu Lâm<Sender>    Đã hơn một tháng kể từ lần gặp cuối cùng. Đầu tiên, những người thợ thủ công dân gian đã tìm ra cách tìm đá quý thô trong quặng, sau đó một số người đã sử dụng các phương pháp cổ xưa để cải tiến nhiều loại đá quý thô và đánh bóng chúng thành những thành phẩm rực rỡ.
    Những loại đá quý này thường có công dụng thần kỳ, có thể thanh nhiệt, bồi bổ ngũ tạng, trấn tĩnh tâm hồn, dưỡng huyết, bổ tai. Về sau có người đề xuất phương pháp khảm đá quý lên áo thường cải thiện sinh khí, khí huyết sẽ không gặp bất lợi. Quả thật tôi đã được lợi rất nhiều nên không dám làm một mình, mong các bạn cũng có thể đến thăm thợ chế tác đá quý để tìm hiểu sự việc và bày tỏ sự cảm ơn ít ỏi của tôi.
    Người chơi đạt cấp 80 có thể đến Tân Thủ Thôn gặp Tô Mộng Trần để nhận các nhiệm vụ liên quan đến bảo thạch.
]];
	local nNowTime = tonumber(GetLocalDate("%Y%m%d%H"));
	local nYear, nMonth, nDate, nHour = math.floor(nNowTime/1000000), math.floor((nNowTime%1000000)/10000),
									math.floor((nNowTime%10000)/100), math.floor((nNowTime%100));
	nYear, nMonth, nDate = Lib:AddDay(nYear, nMonth, nDate, self.nSendMailEndTime);
	Mail.BatchMail:AddIntoGblBuf(szTitle, szContent, tonumber(string.format("%02d%02d%02d%02d", nYear, nMonth, nDate, nHour)));
end

GCEvent:RegisterGCServerStartFunc(Item.StoneSysInit, Item);
