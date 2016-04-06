#!/usr/bin/perl

#birth.pl writen by Matthew Falkner, ecodes all years of CDC Birthdata into CSV
use strict;
use warnings;
use IO::Handle;

if ($#ARGV != 1 ) {
   print "Usage: readBirth2014.pl YEAR\n";
   exit;
}

my $filename = $ARGV[0];
my $fileYear = $ARGV[1];

my $yearOfBirth   = "";
my $monthOfBirth  = "";
my $childGender   = "";
my $birthRecord;


open my $birthFH, '<', $ARGV[0]
   or die "Unable to open the file: $ARGV[0]";

while ( $birthRecord = <$birthFH> ) {

   chomp ( $birthRecord );
   
   $yearOfBirth = $fileYear;

   if ($fileYear == 1968)
   {   #up for debate, not sure how he did this
       $monthOfBirth = substr( $birthRecord,31,2);
       $childGender = substr( $birthRecord,30,1);
   }
   elsif ($fileYear >= 1969 && $fileYear <= 1988)
   {
        $monthOfBirth = substr( $birthRecord, 83,2 );
        $childGender = substr( $birthRecord, 34,1 );
   }
   elsif ($fileYear >= 1989 && $fileYear <= 1991)
   {
        $monthOfBirth = substr( $birthRecord,113,2 );
        if ($monthOfBirth == 99)
        {
          print "line ", $. ,"\n"; 
        }

        $childGender = substr( $birthRecord,188,1 );
   }
   elsif ($fileYear >= 1992 && $fileYear <= 2002)
   {
       $monthOfBirth = substr( $birthRecord,171 ,2 );
       $childGender = substr( $birthRecord,188,1 );
   }
   elsif ($fileYear >= 2003 && $fileYear <= 2013)
   {
       $monthOfBirth = substr( $birthRecord,18,2 );
      
       $childGender = substr( $birthRecord,435,1 );

   }
   elsif ($fileYear == 2014)
   {
       $monthOfBirth = substr( $birthRecord,12,2 );
       $childGender = substr( $birthRecord,474,1 );
   }
    
   if ($childGender eq 'M')
   {
      $childGender = 1; 
   }
   elsif ($childGender eq 'F')
   {
      $childGender = 2; 
   }
   else 
   {
      $childGender = 0; 
   }
   
    print "$fileYear,$monthOfBirth,$childGender\n";
   
}

close ($birthFH);
