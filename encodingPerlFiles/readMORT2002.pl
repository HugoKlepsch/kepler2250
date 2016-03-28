#!/usr/bin/perl
use strict;
use warnings;

#
#  readMORT2002.pl
#     Author: Deborah Stacey
#     Date of Last Update: Sunday, February 21, 2016.
#
#     Summary
#
#     Parameters on the commandline:
#        $ARGV[0] = name of the input file, i.e. the MORT file
#
#     References
#        Works for some files before 2003.
#

#
#  Check that you have the right number of parameters
#
if ($#ARGV != 0 ) {
   print "Usage: readMORT2002.pl <file name>\n";
   exit;
}

#
#  Open the input file - assign a file handle
#
open my $mortFH, '<', $ARGV[0]
   or die "Unable to open the file: $ARGV[0]";

#
#  Read in each record (one per line) until the end of the file
#
my $mortRecord        = "";
my $residentStatus    = "";
my $education         = "";
my $monthDeath        = "";
my $sex               = "";
my $reportedAge       = "";
my $placeDeath        = "";
my $maritalStatus     = "";
my $DoWDeath          = "";
my $currentDataYear   = "";
my $injuryWork        = "";
my $mannerDeath       = "";
my $ICD               = "";
my $race              = "";

while ( $mortRecord = <$mortFH> ) {
#
#  Chop off the end of line character(s)
#
   chomp ( $mortRecord );

#
#  Extract each field from the record as delimited by column position
#

   $residentStatus    = substr( $mortRecord, 19, 1 );
   $education         = substr( $mortRecord, 51, 2 );
   $monthDeath        = substr( $mortRecord, 54, 2 );
   $sex               = substr( $mortRecord, 58, 1 );
   $reportedAge       = substr( $mortRecord, 63, 3 );
   $placeDeath        = substr( $mortRecord, 74, 1 );
   $maritalStatus     = substr( $mortRecord, 76, 1 );
   $DoWDeath          = substr( $mortRecord, 82, 1 );
   $currentDataYear   = substr( $mortRecord, 114, 4 );
   $injuryWork        = substr( $mortRecord, 135, 1 );
   $mannerDeath       = substr( $mortRecord, 138, 1 );
   $ICD               = substr( $mortRecord, 141, 4 );
   $race              = substr( $mortRecord, 59, 2 );

   print "$currentDataYear,$monthDeath,$DoWDeath,$reportedAge,$sex,$race,$maritalStatus,$education,$residentStatus,$placeDeath,$injuryWork,$mannerDeath,$ICD\n";

}

#
#  Close the file
#
close ($mortFH);

#
#  End of Script
#
