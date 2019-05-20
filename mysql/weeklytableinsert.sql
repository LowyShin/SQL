// show week table
select * from week_info order by week desc limit 5;

// show input data
select 
    , case 
        when date_format(date_add(max(END_DATE), interval 1 day), '%Y%m') = substring(max(WEEK), 1, 6) 
            then max(WEEK) + 1
        else concat(date_format(date_add(max(END_DATE), interval 1 day), '%Y%m'), '1')
        end  as week
    , date_format(date_add(max(END_DATE), interval 1 day), '%Y%m%d') as ST_DATE
    , date_format(date_add(max(END_DATE), interval 8 day), '%Y%m%d') as END_DATE
from week_info;

// input data
insert into week_info
select 
    case 
        when date_format(date_add(max(END_DATE), interval 1 day), '%Y%m') = substring(max(WEEK), 1, 6) 
            then max(WEEK) + 1
        else concat(date_format(date_add(max(END_DATE), interval 1 day), '%Y%m'), '1')
        end  as chk_week
    , date_format(date_add(max(END_DATE), interval 1 day), '%Y%m%d') as stdt
    , date_format(date_add(max(END_DATE), interval 7 day), '%Y%m%d') as endt
from week_info order by week desc limit 1;

// check input data
select * from week_info order by week desc limit 5;
