#!/usr/bin/perl
use strict;
use warnings;

#
#  mort.pl
#     Author: Hugo Klepsch & Raymond Hong
#     Date of Last Update: Sunday, March 17, 2016.
#
#     Summary
#
#     Parameters on the commandline:
#        $ARGV[0] = name of the input file, i.e. the unprocessed MORT file
#        $ARGV[1] = the year of the input file
#

#
#  Check that you have the right number of parameters
#
if ($#ARGV != 1 ) {
    print "Usage: readMORT.pl <file name>, <year of the input file>\n";
    exit;
}

my $filename = $ARGV[0];
my $fileYear = $ARGV[1];

#
#  Open the input file - assign a file handle
#
open my $mortFH, '<', $filename
or die "Unable to open the file: $filename";

#
#  Read in each record (one per line) until the end of the file
#
my $yearOD = "";
my $monthOD = "";
my $sexy = "";
my $race = "";
my $mStatus = ""; #marital status
my $edu03 = ""; #education 03
my $workInjury = "";
my $mannerOD = "";
my $mannerOD2 = "";
my $mortRecord;

while ( $mortRecord = <$mortFH> ) {
    
    #  Chop off the end of line character(s)
    chomp ( $mortRecord );
    
    
    if ($fileYear >= 1968 && $fileYear <= 1978) {
        #  Extract each field from the record as delimited by column position
        # $residentStatus    = substr( $mortRecord, 19, 1 );
        $yearOD = substr($mortRecord, 0, 1);
        #1,1 (8=1968, 7=1977) NOTE 8=1968=1978, NEED TO MAKE SCRIPT ACCOUNT FOR THIS.
        if ($yearOD == 8){
            if ($fileYear == 1968) {
                $yearOD = 1968;
            } else {
                $yearOD = 1978;
            }
        } elsif ($yearOD == 9) {
            $yearOD = "196".$yearOD;
        } else {
            $yearOD = "197".$yearOD;
        }
        
        $monthOD = substr($mortRecord, 30, 2); #already in our format
        #31, 2 (01=January... etc)
        
        $sexy = substr($mortRecord, 34, 1); #already in our format
        #35,1 (1=male,2=female)
        
        $race = substr($mortRecord, 35, 1); #already in our format
        $race = "0".$race;
        #36,1 (0=guamian,1=white,2=black,3=indian (native americans),4=chinese,5=japanese,6=hawaiian,7=other,8=filipino)
        
        $mStatus = 9; #none given
        
        $edu03 = 99; #none given
        
        $workInjury = substr($mortRecord, 90, 1);
        #91, 1 (0=home, 1, 2, 3, 6=at work, other=unknown)
        if ($workInjury == 0) {
            $workInjury = 2;
        } elsif($workInjury == 1 || $workInjury == 2 || $workInjury == 3 || $workInjury == 6) {
            $workInjury = 1;
        } else {
            $workInjury = 9;
        }
        
        $mannerOD = substr($mortRecord, 58, 4);
        #ICD 59.4 (950-959=suicide, 960-978=homicide, all others=other)
        if ($mannerOD >= 950 && $mannerOD <= 959) {
            $mannerOD = 1;
        } elsif ($mannerOD >= 960 && $mannerOD <= 978) {
            $mannerOD = 2;
        } else {
            $mannerOD = 9;
        }
        
        print "$yearOD,$monthOD,$sexy,$race,$mStatus,$edu03,$workInjury,$mannerOD,\n";
        
    } elsif ($fileYear >= 1979 && $fileYear <= 1988) {
        #  Extract each field from the record as delimited by column position
        
        $yearOD = substr($mortRecord, 0, 2);
        #1,2 (last two digits of year)
        $yearOD = "19".$yearOD;
        
        $monthOD = substr($mortRecord, 54, 2); #already in our format
        #55,2 (01=January... etc)
        
        $sexy = substr($mortRecord, 58, 1); #already in our format
        #59,1 (1=male,2=female)
        
        $race = substr($mortRecord, 59, 2);
        #60,2 (00=Asian,01=white,02=black,03=nativeamerican,04=chinese,05=japanese,06=hawaiian,07=others,08=filipino)
        
        $mStatus = substr($mortRecord, 76, 1);
        #77,1 (1=never maried single, 2=maried, 3=widowed, 4=divorced, 8-9=unknown)
        if ($mStatus != 1 || $mStatus != 2 || $mStatus != 3 || $mStatus != 4 || $mStatus != 9) {
            $mStatus = 9;
        }
        
        $edu03 = 99; #none given
        
        $workInjury = substr($mortRecord, 140, 1);
        #141,1 (0=home, 1, 2, 3, 6=at work, other=unknown)
        if ($workInjury == 0) {
            $workInjury = 2;
        } elsif($workInjury == 1 || $workInjury == 2 || $workInjury == 3 || $workInjury == 6) {
            $workInjury = 1;
        } else {
            $workInjury = 9;
        }
        
        $mannerOD = substr($mortRecord, 141, 4);
        #ICD 142,4 (950-959=suicide, 960-978=homicide, all others=other)
        if ($mannerOD >= 950 && $mannerOD <= 959) {
            $mannerOD = 1;
        } elsif ($mannerOD >= 960 && $mannerOD <= 978) {
            $mannerOD = 2;
        } else {
            $mannerOD = 9;
        }
        
        print "$yearOD,$monthOD,$sexy,$race,$mStatus,$edu03,$workInjury,$mannerOD,\n";
        
    } elsif ($fileYear >= 1989 && $fileYear <= 1991) {
        #  Extract each field from the record as delimited by column position
        
        $yearOD = substr($mortRecord, 0, 2);
        #1,2 (last two digits of year)
        $yearOD = "19".$yearOD;
        
        $monthOD = substr($mortRecord, 54, 2); #already in our format
        #55,2 (01=January... etc)
        
        $sexy = substr($mortRecord, 58, 1); #already in our format
        #59,1 (1=male,2=female)
        
        $race = substr($mortRecord, 59, 2);
        #60,2 (01=white,02=black,03=nativeamerican,04=chinese,05=japanese,06=hawaiian,07=filipino,08=Other asian,09=all other)
        if ($race eq "09") {
            $race = "07";
        } elsif ($race eq "07") {
            $race = "08";
        } elsif ($race eq "08") {
            $race = "07";
        }
        
        $mStatus = substr($mortRecord, 76, 1);
        #77,1 (1=never maried single, 2=maried, 3=widowed, 4=divorced, 8-9=unknown)
        if ($mStatus != 1 || $mStatus != 2 || $mStatus != 3 || $mStatus != 4 || $mStatus != 9) {
            $mStatus = 9;
        }
        
        $edu03 = substr($mortRecord, 51, 2); #already in format
        #52, 2 (00=no formal education,01-08=years of elementary school, 09-12=years of highschool,13-17=years of college,99=not stated)
        
        $workInjury = substr($mortRecord, 140, 1);
        #141,1 (0=home, 1, 2, 3, 6=at work, other=unknown)
        if ($workInjury == 0) {
            $workInjury = 2;
        } elsif($workInjury == 1 || $workInjury == 2 || $workInjury == 3 || $workInjury == 6) {
            $workInjury = 1;
        } else {
            $workInjury = 9;
        }
        
        $mannerOD = substr($mortRecord, 141, 4);
        #ICD 142,4 (950-959=suicide, 960-978=homicide, all others=other)
        if ($mannerOD >= 950 && $mannerOD <= 959) {
            $mannerOD = 1;
        } elsif ($mannerOD >= 960 && $mannerOD <= 978) {
            $mannerOD = 2;
        } else {
            $mannerOD = 9;
        }
        
        print "$yearOD,$monthOD,$sexy,$race,$mStatus,$edu03,$workInjury,$mannerOD,\n";
    } elsif ($fileYear >= 1992 && $fileYear <= 1995) {
        $yearOD = substr($mortRecord, 0, 2);
        $yearOD = "19".$yearOD;
        
        $monthOD = substr($mortRecord, 54, 2);#already in our format
        $sexy = substr($mortRecord, 58, 1); #already in our format
        $race = substr($mortRecord, 59, 2); #already in our format
        $mStatus = substr($mortRecord, 76, 1);
        if ($mStatus == 8)
        {
            $mStatus = 9;
        }
        $edu03 = substr($mortRecord, 51, 2); #already in our format
        $workInjury = substr ($mortRecord, 135, 1); #already in our format
        
        $mannerOD = substr($mortRecord, 141, 4);
        #ICD 142,4 (950-959=suicide, 960-978=homicide, all others=other)
        if ($mannerOD >= 950 && $mannerOD <= 959) {
            $mannerOD = 1;
        } elsif ($mannerOD >= 960 && $mannerOD <= 978) {
            $mannerOD = 2;
        } else {
            $mannerOD = 9;
        }
        
        print "$yearOD,$monthOD,$sexy,$race,$mStatus,$edu03,$workInjury,$mannerOD,\n";
        
        
        
    } elsif ($fileYear >= 1996 && $fileYear <= 2002) {
        $yearOD = substr($mortRecord, 114, 4);#already in our format
        $monthOD = substr($mortRecord, 54, 2); #already in our format
        $sexy = substr($mortRecord, 58, 1); #already in our format
        $race = substr($mortRecord, 59, 2); #already in our format
        $mStatus = substr($mortRecord, 76, 1);
        if ($mStatus == 8)
        {
            $mStatus = 9;
        }
        $edu03 = substr($mortRecord, 51, 2); #already in our format
        $workInjury = substr ($mortRecord, 135, 1); #already in our format
        
        $mannerOD = substr($mortRecord, 141, 1);
        $mannerOD2 = substr($mortRecord, 142, 2);
        
         if ($mannerOD eq "X")
         {
             $mannerOD = 1;
             if ($mannerOD2 >= 60 && $mannerOD2 <= 84)
             {
                 $mannerOD = 1;
             }
             elsif($mannerOD2 >= 85 && $mannerOD2 <= 99)
             {
                 $mannerOD = 2;
             }
         }
        elsif ($mannerOD eq "Y" && $mannerOD2 >= 0 && $mannerOD2 <= 9)
        {
            $mannerOD = 2;
        }
        else
        {
            $mannerOD = 9;
        }
        
        print "$yearOD,$monthOD,$sexy,$race,$mStatus,$edu03,$workInjury,$mannerOD,\n";
        
    } elsif ($fileYear >= 2003 && $fileYear <= 2014) {
        $yearOD = substr($mortRecord, 101, 4);#Already in our format
        $monthOD = substr($mortRecord, 64, 2);  #Already in our format
        $sexy = substr($mortRecord, 68, 1);
        if ($sexy eq "M")
        {
            $sexy = 1;
        }
        else
        {
            $sexy = 2;
        }
        
        $race = substr($mortRecord, 444, 2);#Already in our format
        $mStatus = substr($mortRecord, 83, 1); #Already in our format
        if ($mStatus eq "S")
        {
            $mStatus = 1;
        }
        elsif ($mStatus eq "M")
        {
            $mStatus = 2;
        }
        elsif ($mStatus eq "W")
        {
            $mStatus = 3;
        }
        elsif ($mStatus eq "D")
        {
            $mStatus = 4;
        }
        elsif ($mStatus eq "N" || $mStatus eq "U")
        {
            $mStatus = 9;
        }
        
        $edu03 = substr($mortRecord, 60, 2); #Already in our format
        $workInjury = substr($mortRecord, 105, 1); #Already in our format
        
        if ($workInjury eq "Y")
        {
            $workInjury = 1;
        }
        elsif ($workInjury eq "N")
        {
            $workInjury = 2;
        }
        elsif ($workInjury eq "U")
        {
            $workInjury = 9;
        }
        
        $mannerOD = substr($mortRecord, 106, 1);
        if ($mannerOD == 2)
        {
            $mannerOD = 1;
        }
        elsif ($mannerOD == 3)
        {
            $mannerOD = 2;
        }
        else
        {
            $mannerOD = 9;
        }
        
        print "$yearOD,$monthOD,$sexy,$race,$mStatus,$edu03,$workInjury,$mannerOD,\n";
        
    } else {
        print "error";
    }
} 



#
#  Close the file
#
close ($mortFH);

#
#  End of Script
#