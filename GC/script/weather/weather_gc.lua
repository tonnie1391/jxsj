-------------------------------------------------------------------
--File: 	weather_gc
--Author: 	sunduoliang
--Date: 	2011-07-06
--Describe:	

-------------------------------------------------------------------

function Weather:Scheduletask()
	if self.DEF_OPEN == 0 then
		return 0;
	end
	GlobalExcute({"Weather:StartSystemWeather"});
	return 1;
end
