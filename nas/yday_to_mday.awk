#! /usr/bin/awk -f

##
##  Given a year and a day of year (i.e. doy), this function will
##+ transform the given date to YYYY-MM-DD format.
##  
##  Example:
##		$ echo "2015 167" | ./yday_to_mday
##      $ 2012-06-16
##      $ echo "2012 167" | ./yday_to_mday
##      $ 2012-06-15
##
##  Fixme: Check that the provided arguments are positive ints.
##
##  cheers, 
##+ xanthos
##

{
        month_day0[0]  = 0
        month_day0[1]  = 31
        month_day0[2]  = 59
        month_day0[3]  = 90
        month_day0[4]  = 120
        month_day0[5]  = 151
        month_day0[6]  = 181
        month_day0[7]  = 212
        month_day0[8]  = 243
        month_day0[9]  = 273
        month_day0[10] = 304
        month_day0[11] = 334
        month_day0[12] = 365
        month_day1[0]  = 0
        month_day1[1]  = 31
        month_day1[2]  = 60
        month_day1[3]  = 91
        month_day1[4]  = 121
        month_day1[5]  = 152
        month_day1[6]  = 182
        month_day1[7]  = 213
        month_day1[8]  = 244
        month_day1[9]  = 274
        month_day1[10] = 305
        month_day1[11] = 335
        month_day1[12] = 366
        leap  = ($1 % 4 == 0)
        guess = int( $2 * 0.032 )
        if ( leap == 0 ) {
                more  = (( $2 - month_day0[guess+1] ) > 0)
                month = guess + more + 1
                mday  = $2 - month_day0[guess+more]
        } else {
                more  = (( $2 - month_day1[guess+1] ) > 0)
                month = guess + more + 1
                mday  = $2 - month_day1[guess+more]
        }
        printf "%4i-%02i-%02i\n", $1, month, mday
}
