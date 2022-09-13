-------------------------------------------------------------------
--File: 	weather_def
--Author: 	sunduoliang
--Date: 	2011-07-06
--Describe:	

-------------------------------------------------------------------

Weather.DEF_BASE_PATH 	= "\\setting\\weather\\"
Weather.DEF_BASE_FILE 	= "weather.txt";
Weather.DEF_OPEN	  	= 1;
Weather.tbWeathBase		= Weather.tbWeathBase or {};
Weather.tbMapWeathList 	= Weather.tbMapWeathList or {};
Weather.tbMapInServerList = nil;	--第一次启动天气时初始化加载
Weather.tbMapNowWeathList = Weather.tbMapNowWeathList or {};
