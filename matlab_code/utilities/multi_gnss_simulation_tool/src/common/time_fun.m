function [UTC]=time_fun(seconds,Insert_data)
% time_func Time trasformation function.

Monthh=[31,28,31,30,31,30,31,31,30,31,30,31];
if seconds<86400
    hour=floor(seconds/3600);
    minutes=floor((seconds-3600*hour)/60);
    sec=(seconds-3600*hour)-60*minutes;
    year=Insert_data(1,1);
    month=Insert_data(1,2);
    day=Insert_data(1,3);
    UTC=[year month day hour minutes sec];
end
if seconds>=86400
    hour=floor(mod(seconds,86400)/3600);
    minutes=floor((mod(seconds,86400)-3600*hour)/60);
    sec=(mod(seconds,86400)-3600*hour)-60*minutes;
    day=Insert_data(1,3)+1;
    month=Insert_data(1,2);
    year=Insert_data(1,1);
    if (Insert_data(1,3)==Monthh(1,Insert_data(1,2)))
        day=floor(seconds/86400);
        month=Insert_data(1,2)+1;
    else 
        month=Insert_data(1,2);
        day=Insert_data(1,3)+floor(seconds/86400);
        if month>12
            month=1;
            year=Insert_data(1,1)+1;
        else
            year=Insert_data(1,1);
        end
    end
    UTC=[year month day hour minutes sec];
end
