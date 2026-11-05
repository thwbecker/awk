#
# given input time in 
#
# year1 month1 day1 year2 month2 day2 .... 
# 
# print the line if an input yeay, month, day is within range
BEGIN{
    if(utc=="")
	utc = 1;
    datespec=sprintf("%04i %02i %02i %02i %02i 00",year,month,day,0,0);
    time_stamp = mktime(datespec,utc); # time in seconds since epoch
}
{
    datespec=sprintf("%04i %02i %02i %02i %02i 00",$1,$2,$3,0,0);
    time_stamp_left = mktime(datespec,utc); # time in seconds since epoch

    datespec=sprintf("%04i %02i %02i %02i %02i 00",$4,$5,$6,0,0);
    time_stamp_right = mktime(datespec,utc); # time in seconds since epoch

    if((time_stamp >= time_stamp_left) && (time_stamp <= time_stamp_right))
	print($0)

}
