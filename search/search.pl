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
#   search.pl
#      Author(s):   Team Kepler
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

my @filenames;
my $csv          = Text::CSV->new({ sep_char => $COMMA });
my $isParseMort;
my $t1;
my $t2;
my @yearRange;

#returns the list of filenames to parse
#first parameter: the type of filenames
#    1 = mort
#    else = birth
#second parameter: the starting year in range
#third: the final year in range
sub genFilenames {
    my @filenames;
    my $baseString;
    my $startYear = $_[1];
    my $endYear = $_[2];
    my $loopInd = 0;
    
    #1 for mort filenames, anything else for birth
    if ($_[0] == 1) {
        $baseString = "mort";
    } else {
        $baseString = "birth";
    }
    
    if ($startYear >= $endYear){
        exit;
    } elsif ($startYear < 1968 || $endYear > 2014) {
        exit;
    }
    
    for my $year ($startYear .. $endYear) {
        $filenames[$loopInd++] = $baseString.$year.".txt";
    }
    
    return @filenames;
    
}

sub printHelp {
    print "Usage: search.pl {tier 1} {tier 2} {year range}\n";
    print "Options: \n{tier 1}:\n\t{tier 2}\n\t{tier 2}\n";
    print "Race\n\tworkDeath\n\teduLvl\nGender\n\tworkDeath\n\teduLvl\nFuneral\n\tdeathMonth\nSchool\n\tbirthMonth\nBabyToy\n\tgenderMonth\nMentalHealth\n\tmaritalSuicide\n";
    
}

#usage:
#$_[0] = the string of year range
#   1968-1971
#reuturn:
#   a list of the two numbers, separated
sub getYearRange {
    my $string = $_[0];
    my @range;
    @range = split("-",$string);
    #ensure the correct parameters are given
    if ($#range != 1) {
        exit;
    }
    return @range;
    
}


#   Check that you have the right number of parameters
if ($#ARGV != 2 ) {
    printHelp();
    exit;
} else {
    if ($ARGV[0] eq "Race") {
        $isParseMort = 1;
        $t1 = $ARGV[0];
        if ($ARGV[1] eq "workDeath" || $ARGV[1] eq "eduLvl") {
            $t2 = $ARGV[1];
        } else {
            printHelp();
            exit;
        }
    } elsif ($ARGV[0] eq "Gender") {
        $isParseMort = 1;
        $t1 = $ARGV[0];
        if ($ARGV[1] eq "workDeath" || $ARGV[1] eq "eduLvl") {
            $t2 = $ARGV[1];
        } else {
            printHelp();
            exit;
        }
    } elsif ($ARGV[0] eq "Funeral") {
        $isParseMort = 1;
        $t1 = $ARGV[0];
        if ($ARGV[1] eq "deathMonth") {
            $t2 = $ARGV[1];
        } else {
            printHelp();
            exit;
        }
    } elsif ($ARGV[0] eq "MentalHealth") {
        $isParseMort = 1;
        $t1 = $ARGV[0];
        if ($ARGV[1] eq "maritalSuicide") {
            $t2 = $ARGV[1];
        } else {
            printHelp();
            exit;
        }
    } elsif ($ARGV[0] eq "School") {
        $isParseMort = 0;
        $t1 = $ARGV[0];
        if ($ARGV[1] eq "birthMonth") {
            $t2 = $ARGV[1];
        } else {
            printHelp();
            exit;
        }
    } elsif ($ARGV[0] eq "BabyToy") {
        $isParseMort = 0;
        $t1 = $ARGV[0];
        if ($ARGV[1] eq "genderMonth") {
            $t2 = $ARGV[1];
        } else {
            printHelp();
            exit;
        }
    } else {
        printHelp();
        exit;
    }
    
    @yearRange = getYearRange($ARGV[2]);
    @filenames = genFilenames($isParseMort, $yearRange[0], $yearRange[1]);
    
}

if($t1 eq "Gender" && $t2 eq "workDeath") {
    my $record_count = -1;
    my $maleInjuryCount = 0;
    my $femaleInjuryCount = 0;
    my $totalMcount = 0;
    my $totalFcount = 0;
    my $totalUcount = 0;
    my $unknown = 0;
    my @gender;
    my @workInjury;
    my @records;
    my $filename;
    
    
    foreach $filename (@filenames)
    {
        
        #
        #   Open the input file and load the contents into records array
        #
        open my $names_fh, '<', $filename
        or die "Unable to open names file: $filename\n";
        
        @records = <$names_fh>;
        
        close $names_fh or
        die "Unable to close: $filename";   # Close the input file
        
        #
        #   Parse each line and store the information in arrays
        #   representing each field
        #
        #   Extract each field from each name record as delimited by a comma
        #
        foreach my $mort_record ( @records )
        {
            if ( $csv->parse($mort_record) )
            {
                my @master_fields = $csv->fields();
                $record_count++;
                $gender[$record_count]     = $master_fields[2];
                $workInjury[$record_count]     = $master_fields[6];
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }
        
        for (my $i = 0; $i <= $record_count; $i++)
        {
            if($gender[$i] eq "1" && $workInjury[$i] eq "1")
            {
                $maleInjuryCount++;
            }
            elsif($gender[$i] eq "2" && $workInjury[$i] eq "1")
            {
                $femaleInjuryCount++;
            }
            elsif($workInjury[$i] eq "9")
            {
                $unknown++;
            }
        }
        
        
        #print $begYear.": male injury ".$maleInjuryCount." female injury ".$femaleInjuryCount." Unknowns ".$unknown."\n";
        
        $totalMcount = $totalMcount + $maleInjuryCount;
        $totalFcount = $totalFcount + $femaleInjuryCount;
        $totalUcount = $totalUcount + $unknown;
        
        $record_count = -1;
        $maleInjuryCount = 0;
        $femaleInjuryCount = 0;
        $unknown = 0;
        
    }
    
    print $totalMcount." Male injuries"."\n";
    print $totalFcount." Female injuries"."\n";
    print $totalUcount." Unknown"."\n";
}




exit;
#this is how you block comment
=begin swag
 #########################################################################################
 print "\“CATEGORY\”,\”XLABEL\”,\”VALUE\”\n";
 =end swag
 =cut
