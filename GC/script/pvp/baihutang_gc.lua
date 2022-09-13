-------------------------------------------------------------------
--File		: baihutang_gc.lua
--Author	: ZouYing
--Date		: 2008-1-8 14:13
--Describe	: 白虎堂开始报名，开始PK和结束PK的触发
-------------------------------------------------------------------

if not MODULE_GC_SERVER then
	return;
end

function BaiHuTang:ApplyStart()
	GlobalExcute{"BaiHuTang:ApplyStart_GS"};
end

function BaiHuTang:PKStop()
	GlobalExcute{"BaiHuTang:PKStop_GS"};
end

function BaiHuTang:PKStart(nTaskId)
	GlobalExcute{"BaiHuTang:PKStart_GS", nTaskId};
end

function BaiHuTang:NextPvpStart()
	GlobalExcute{"BaiHuTang:NextPvpStart_GS"};
end

function BaiHuTang:ApplyGB_GCState(nLevel)	--向大区gc申请跨服白虎状态,黄金白虎堂boss死亡后调用
	GlobalGCExcute(-1,{"KuaFuBaiHu:SendGB_GCState",nLevel});
end

function BaiHuTang:ReceiveGB_GCState(nState,nLevel)	--接受大区gc的状态数据
	GlobalExcute{"BaiHuTang:OpenGBTransferDoor",nState,nLevel}; --广播给每个gs
end


----测试指令------------
function BaiHuTang:ApplyStart_GB()
	GlobalGCExcute(-1,{"KuaFuBaiHu:ApplyStart"});
end

function BaiHuTang:ClearState_GB()
	GlobalGCExcute(-1,{"KuaFuBaiHu:ClearAllState"});
end

