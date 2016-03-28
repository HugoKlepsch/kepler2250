#!/usr/bin/perl
use strict;
use warnings;


if ($#ARGV != 0 ) {
   print "Usage: readBirth2014.pl YEAR\n";
   exit;
}

my $filename = $ARGV[0];
my $fileYear = $ARGV[1];

my $yearOfBirth   = "";
my $monthOfBirth  = "";
my $childGender   = "";


open my $birthFH, '<', $ARGV[0]
   or die "Unable to open the file: $ARGV[0]";


while ( $birthRecord = <$birthFH> ) 
{

   chomp ( $birthRecord );
   
   $yearOfBirth = $fileYear;
   if ($fileYear == 1968)
   {   
       #up for debate, not sure how he did this
       $monthOfBirth = substr( $birthRecord,31,2);
       $childGender = substr( $birthRecord,30,1);
   }
   else if ($fileYear >= 1969 && $fileYear <= 1988) 
   {
        $monthOfBirth = substr( $birthRecord, 83,2 );
        $childGender = substr( $birthRecord, 34,1 );
   }
   else if ($fileYear >= 1989 && $fileYear <= 1991) 
   {
        $monthOfBirth = substr( $birthRecord,113,2 );
        $childGender = substr( $birthRecord,188,1 );
   }
   else if ($fileYear >= 1992 && $fileYear <= 2002) 
   {
       $monthOfBirth = substr( $birthRecord,171 ,2 );
       $childGender = substr( $birthRecord,188,1 );
   }
   else if ($fileYear >= 2003 && $fileYear <= 2013) {
       #This is where birth gender becomes "m" "f" instead of 1 or 0
       if (substr( $birthRecord,435,1 ) eq 'M')
       {
            $childGender = 0;
       }
       else if ( substr( $birthRecord,435,1 ) eq 'F')
       {
            $childGender = 1; 
       }
       $monthOfBirth = ( substr( $birthRecord,18,2 );
   }
   else if ($fileYear == 2014) 
   {
       if (substr( $birthRecord,474,1 ) eq 'M')
       {
            $childGender = 0;
       }
       else if (substr( $birthRecord,474,1 ) eq 'F')
       {
            $childGender = 1; 
       }
       $monthOfBirth = substr( $birthRecord,12,2 );
   }

   print "$yearOfBirth,$monthOfBirth,$childGender\n";

}

close ($birthFH);
