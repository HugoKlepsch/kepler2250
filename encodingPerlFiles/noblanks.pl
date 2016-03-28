#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher)
                       # to parse each line

#
#   noblanks.pl
#      Author(s): Deborah Stacey
#      Project: Lab Assignment 1 Task 1 Script 
#      Date of Last Update: Monday, November 16, 2015.
#
#      Functional Summary
#         noblanks.pl takes in a CSV (comma separated version) file 
#         and "removes" blank fields
#
#      Commandline Parameters: 1
#         $ARGV[0] = name of the input file
#
#      References
#

#
#   Variables to be used
#
my $EMPTY = q{};
my $COMMA = q{,};
my $LIMIT = 5;

my $filename     = $EMPTY;
my @records;
my @first_name;
my @gender;
my @number;
my $edu1;
my $edu2;
my $csv          = Text::CSV->new({ sep_char => $COMMA });

my $record_count = 0;

#
#   Check that you have the right number of parameters
#
if ($#ARGV != 0 ) {
   print "Usage: noblanks.pl <input csv file>\n" or
      die "Print failure\n";
   exit;
} else {
   $filename = $ARGV[0];
}

#
#   Open the input file and load the contents into records array
#
open my $names_fh, '<', $filename
   or die "Unable to open names file: $filename\n";

@records = <$names_fh>;

close $names_fh or
   die "Unable to close: $ARGV[0]\n";   # Close the input file

#
#   Parse each line and store the information in arrays 
#   representing each field
#
#   Extract each field from each name record as delimited by a comma
#
my $size = 0;
foreach my $name_record ( @records ) {
   if ( $csv->parse($name_record) ) {
      my @master_fields = $csv->fields();
      $size = @master_fields;
      for my $i ( 0..$size-2 ) {
         if ( $master_fields[$i] eq " " || $master_fields[$i] eq "  " ) {
            print ",";
         } else {
            print "$master_fields[$i],";
         }
      }
      print "$master_fields[$size-1]\n";
      $record_count++;
   } else {
      warn "Line/record could not be parsed: $records[$record_count]\n";
   }
}

#print "Total number of records: $record_count\n" or
#   die "Print failure\n";

#
#   End of Script
#
