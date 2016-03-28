#!/usr/bin/perl
use strict;
use warnings;

#
#  readBirth2014.pl
#     Author: Deborah Stacey
#     Date of Last Update: Sunday, February 21, 2016.
#
#     Summary
#
#     Parameters on the commandline:
#        $ARGV[0] = name of the input file, i.e. the Birth file
#
#     References
#        Tested on 2014 data.
#

#
#  Check that you have the right number of parameters
#
if ($#ARGV != 0 ) {
   print "Usage: readBirth2014.pl <file name>\n";
   exit;
}

#
#  Open the input file - assign a file handle
#
open my $birthFH, '<', $ARGV[0]
   or die "Unable to open the file: $ARGV[0]";

#
#  Read in each record (one per line) until the end of the file
#
my $birthRecord       = "";
my $currentDataYear   = "";
my $residentStatus    = "";
my $month             = "";
my $time              = "";
my $DoW               = "";
my $placeDelivery     = "";
my $methodDelivery    = "";
my $attendant         = "";
my $ChildSex          = "";
my $ChildWeight       = "";
my $ChildNumber       = "";
my $MotherAge         = "";
my $MotherRace        = "";
my $MotherMStatus     = "";
my $MotherEdu         = "";
my $MotherBOrder      = "";
my $MotherBInterval   = "";
my $FatherAge         = "";
my $FatherRace        = "";
my $FatherEdu         = "";

while ( $birthRecord = <$birthFH> ) {
#
#  Chop off the end of line character(s)
#
   chomp ( $birthRecord );

#
#  Extract each field from the record as delimited by column position
#

   $currentDataYear   = substr( $birthRecord, 8, 4 );
   $residentStatus    = substr( $birthRecord, 103, 1 );
   $month             = substr( $birthRecord, 12, 2 );
   $time              = substr( $birthRecord, 18, 4 );
   $DoW               = substr( $birthRecord, 22, 1 );
   $placeDelivery     = substr( $birthRecord, 31, 1 );
   $methodDelivery    = substr( $birthRecord, 401, 1 );
   $attendant         = substr( $birthRecord, 432, 1 );
   $ChildSex          = substr( $birthRecord, 474, 1 );
   $ChildWeight       = substr( $birthRecord, 503, 4 );
   $ChildNumber       = substr( $birthRecord, 453, 1 );
   $MotherAge         = substr( $birthRecord, 74, 2 );
   $MotherRace        = substr( $birthRecord, 104, 2 );
   $MotherMStatus     = substr( $birthRecord, 119, 1 );
   $MotherEdu         = substr( $birthRecord, 123, 1 );
   $MotherBOrder      = substr( $birthRecord, 181, 1 );
   $MotherBInterval   = substr( $birthRecord, 200, 2 );
   $FatherAge         = substr( $birthRecord, 148, 2 );
   $FatherRace        = substr( $birthRecord, 150, 2 );
   $FatherEdu         = substr( $birthRecord, 162, 1 );

   print "$currentDataYear,$residentStatus,$month,$time,$DoW,$placeDelivery,$methodDelivery,$attendant,$ChildSex,$ChildWeight,$ChildNumber,$MotherAge,$MotherRace,$MotherMStatus,$MotherEdu,$MotherBOrder,$MotherBInterval,$FatherAge,$FatherRace,$FatherEdu\n";

}

#
#  Close the file
#
close ($birthFH);

#
#  End of Script
#
