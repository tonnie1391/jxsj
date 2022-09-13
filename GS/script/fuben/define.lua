-- 文件名　：define.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-7
-- 描  述  ：


CFuben.TASKID_GROUP		= 2123;	--任务变量组
CFuben.TASKID_DATE		= 1;	--
CFuben.TASKID_NTIMES	 	= 2;	--副本次数（限制2-30）

CFuben.tbMapList = CFuben.tbMapList or {};
CFuben.NTIMES_END = Env.GAME_FPS * 60 * 1;   --副本申请15分钟没有开启的自动注销掉

CFuben.tbMapType = {
					["village"] = "新手村地图区",
					["faction"] = "门派地图区",
					["city"] = "城市地图区",
					["fight"] = "野外地图区"
				};
