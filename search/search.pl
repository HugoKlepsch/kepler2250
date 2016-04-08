#!/usr/bin/perl

#   Packages and modules

use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher)

#
#   search.pl
#      Author(s):   Team Kepler
#
#      Commandline Parameters: 5
#         $ARGV[0] = The tier one question parameter
#         $ARGV[1] = The tier two question parameter
#         $ARGV[2] = The year range to search over (ex: 1997-2002)
#         $ARGV[3] = Whether to output with plotMode or not. plotMode off == human readable (on/off)
#                       (ex: on)
#         $ARGV[4] = Whether or not to ignore records that contain unknown in their field (on/off)
#                       (ex: on)
#

my $EMPTY = q{};
my $COMMA = q{,};
my $LIMIT = 5;

my @filenames;
my $csv          = Text::CSV->new({ sep_char => $COMMA });
my $isParseMort;
my $t1;
my $t2;
my $isPlotMode;
my $isIgnoreUnknown;
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
    my $baseDir;
    my $startYear = $_[1];
    my $endYear = $_[2];
    my $loopInd = 0;

    #1 for mort filenames, anything else for birth
    if ($_[0] == 1) {
        $baseString = "mort";
        $baseDir = "processedMort/";
    } else {
        $baseString = "birth";
        $baseDir = "processedBirth/";
    }

    #error checking for validity
    if ($startYear > $endYear){
        printHelp();
        exit;
    } elsif ($startYear < 1968 || $endYear > 2014) {
        printHelp();
        exit;
    }
    #generate the list of filenames
    if ($_[0] == 1){
        for my $year ($startYear .. $endYear) {
            $filenames[$loopInd++] = $baseDir.$baseString.$year.".txt";
        }

    }
    else {
        for my $year ($startYear .. $endYear) {
            $filenames[$loopInd++] = $baseDir.$year.$baseString.".txt";
        }
    }
    #return them
    return @filenames;

}

#prints the default help text to screen
sub printHelp {
    print "Usage: search.pl {tier 1} {tier 2} {year range} {plotMode on/off} {ignoreUnknown on/off}\n";
    print "Options: \n{tier 1}:\n\t{tier 2}\n\t{tier 2}\n";
    print "Race\n\tworkDeath\n\teduLvl\nGender\n\tworkDeath\n\teduLvl\nFuneral\n\tdeathMonth\nSchool\n\tbirthMonth\nBabyToy\n\tgenderMonth\nMentalHealth\n\tmaritalSuicide\n";
    print "• Usage: search.pl Gender workDeath 1968-1971 on\n";
    print "• To search a single year, put that year as both sides of the year range.\n";
    print "• PlotMode off means the output is in a 'human readable' format. \n• PlotMode on means the output is ready for our plotting tool\n";
    print "• ignoreUnknown on means that the output of the search tool does not include statistics on \n\"unknown\" categories. For example it will not output information on unknown race, or education level. \nExceptions for workplace deaths, as unknown injury is more important there. \n";

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
        printHelp();
        exit;
    }
    return @range;

}


#   Check that you have the right number of parameters
if ($#ARGV != 4 ) {
    printHelp();
    exit;
} else {
    #parse in the argv for t1 and t2, while checking for valid configurations
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

    #once we've error checked the t1, t2, generate the filenames to run on
    @yearRange = getYearRange($ARGV[2]);
    @filenames = genFilenames($isParseMort, $yearRange[0], $yearRange[1]);
    #parse the remaining argvs
    $isPlotMode = $ARGV[3];
    if ($isPlotMode eq "on") {
        $isPlotMode = 1;
    } elsif ($isPlotMode eq "off") {
        $isPlotMode = 0;
    } else {
        printHelp();
        exit;
    }
    $isIgnoreUnknown = $ARGV[4];
    if ($isIgnoreUnknown eq "on") {
        $isIgnoreUnknown = 1;
    } elsif ($isIgnoreUnknown eq "off") {
        $isIgnoreUnknown = 0;
    } else {
        printHelp();
        exit;
    }

    #print which files we will search to stderr
    print STDERR "Will try to load these files:\n";
    foreach my $year (@filenames) {
        print STDERR $year."\n";
    }
    print STDERR "~~~~~~~~~~~~~~~~~\n";

}

###############################################################################
#Start of the search code######################################################
###############################################################################


#each if/elsif block represents a question
if ($t1 eq "Race" && $t2 eq "workDeath") {
    #Race workDeath
    my $record_count = -1;
    my $whiteCount = 0;
    my $blackCount = 0;
    my $asianCount = 0;
    my $indianCount = 0;
    my $otherCount = 0;
    my $totalMcount = 0;
    my $totalFcount = 0;
    my $totalUcount = 0;
    my @race;
    my @workInjury;
    my @records;
    my $filename;

    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];

    #for each filename in our list
    foreach $filename (@filenames)
    {
        #real-time progress
        print STDERR "\tStarting $filename\n";

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
                $race[$record_count]     = $master_fields[3];
                $workInjury[$record_count]     = $master_fields[6];

                #find what race they were
                if($race[$record_count] eq "01" && $workInjury[$record_count] eq "1")
                {
                    $whiteCount++
                }
                elsif($race[$record_count] eq "02" && $workInjury[$record_count] eq "1")
                {
                    $blackCount++;
                }
                elsif($race[$record_count] eq "03" && $workInjury[$record_count] eq "1")
                {
                    $indianCount++;
                }
                elsif(($race[$record_count] eq "04" || $race[$record_count] eq "05" || $race[$record_count] eq "06" || $race[$record_count] eq "07" ||  $race[$record_count] eq "18" ||  $race[$record_count] eq "28" || $race[$record_count] eq "48") && $workInjury[$record_count] eq "1")
                {
                    $asianCount++;
                }
                elsif($workInjury[$record_count] eq "9")
                {
                    $unknown++;
                }
                else
                {
                    $otherCount++
                }
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }

    }

    #different output based on command line args
    if($isPlotMode == 0)
    {
        print "From ".$initialYear." to ".$endYear." there were: \n";
        print $whiteCount." White workplace injuries"."\n";
        print $blackCount." Black workplace injuries"."\n";
        print $indianCount." Native Indian workplace injuries"."\n";
        print $asianCount." Asian workplace injuries"."\n";
        print $otherCount." Other workplace injuries"."\n";
        print $unknown." Unknown injuries"."\n";
    }
    else
    {
        if ($isIgnoreUnknown == 1)
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "White,".$initialYear."-".$endYear.",".$whiteCount."\n";
            print "Black,".$initialYear."-".$endYear.",".$blackCount."\n";
            print "Native Indian,".$initialYear."-".$endYear.",".$indianCount."\n";
            print "Asian,".$initialYear."-".$endYear.",".$asianCount."\n";
            print "Other,".$initialYear."-".$endYear.",".$otherCount."\n";
        }
        else
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "White,".$initialYear."-".$endYear.",".$whiteCount."\n";
            print "Black,".$initialYear."-".$endYear.",".$blackCount."\n";
            print "Native Indian,".$initialYear."-".$endYear.",".$indianCount."\n";
            print "Asian,".$initialYear."-".$endYear.",".$asianCount."\n";
            print "Other,".$initialYear."-".$endYear.",".$otherCount."\n";
            print "Unknown,".$initialYear."-".$endYear.",".$unknown."\n";
        }

    }

} elsif ($t1 eq "Race" && $t2 eq "eduLvl") {
    #Race eduLvl
    my $record_count = -1;
    my $whiteElem = 0;
    my $whiteNe = 0;
    my $whiteHs = 0;
    my $whiteUni = 0;
    my $whiteNs = 0;

    my $blackElem = 0;
    my $blackNe = 0;
    my $blackHs = 0;
    my $blackUni = 0;
    my $blackNs = 0;

    my $asianElem = 0;
    my $asianNe = 0;
    my $asianHs = 0;
    my $asianUni = 0;
    my $asianNs = 0;

    my $indianElem = 0;
    my $indianNe = 0;
    my $indianHs = 0;
    my $indianUni = 0;
    my $indianNs = 0;

    my $otherElem = 0;
    my $otherNe = 0;
    my $otherHs = 0;
    my $otherUni = 0;
    my $otherNs = 0;

    my $notStated = 0;
    my $totalMcount = 0;
    my $totalFcount = 0;
    my $totalUcount = 0;
    my @race;
    my @eduLevel;
    my @records;
    my $filename;

    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];


    foreach $filename (@filenames)
    {
        print STDERR "\tStarting $filename\n";

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
                $race[$record_count]     = $master_fields[3];
                $eduLevel[$record_count]     = $master_fields[5];

                if($race[$record_count] eq "01" && ($eduLevel[$record_count] eq "01" || $eduLevel[$record_count] eq "02" || $eduLevel[$record_count] eq "03"|| $eduLevel[$record_count] eq "04" || $eduLevel[$record_count] eq "05" || $eduLevel[$record_count] eq "06" || $eduLevel[$record_count] eq "07" || $eduLevel[$record_count] eq "08"))
                {
                    $whiteElem++;
                }
                elsif($race[$record_count] eq "02" && ($eduLevel[$record_count] eq "01" || $eduLevel[$record_count] eq "02" || $eduLevel[$record_count] eq "03"|| $eduLevel[$record_count] eq "04" || $eduLevel[$record_count] eq "05" || $eduLevel[$record_count] eq "06" || $eduLevel[$record_count] eq "07" || $eduLevel[$record_count] eq "08"))
                {
                    $blackElem++;
                }
                elsif($race[$record_count] eq "03" && ($eduLevel[$record_count] eq "01" || $eduLevel[$record_count] eq "02" || $eduLevel[$record_count] eq "03"|| $eduLevel[$record_count] eq "04" || $eduLevel[$record_count] eq "05" || $eduLevel[$record_count] eq "06" || $eduLevel[$record_count] eq "07" || $eduLevel[$record_count] eq "08"))
                {
                    $indianElem++;
                }
                elsif(($race[$record_count] eq "04" || $race[$record_count] eq "05" || $race[$record_count] eq "06" || $race[$record_count] eq "07" ||  $race[$record_count] eq "18" ||  $race[$record_count] eq "28" || $race[$record_count] eq "48") && ($eduLevel[$record_count] eq "01" || $eduLevel[$record_count] eq "02" || $eduLevel[$record_count] eq "03"|| $eduLevel[$record_count] eq "04" || $eduLevel[$record_count] eq "05" || $eduLevel[$record_count] eq "06" || $eduLevel[$record_count] eq "07" || $eduLevel[$record_count] eq "08"))
                {
                    $asianElem++;
                }
                elsif($race[$record_count] eq "01" && ($eduLevel[$record_count] eq "09" || $eduLevel[$record_count] eq "10" || $eduLevel[$record_count] eq "11"|| $eduLevel[$record_count] eq "12"))
                {
                    $whiteHs++;
                }
                elsif($race[$record_count] eq "02" && ($eduLevel[$record_count] eq "09" || $eduLevel[$record_count] eq "10" || $eduLevel[$record_count] eq "11"|| $eduLevel[$record_count] eq "12"))
                {
                    $blackHs++;
                }
                elsif($race[$record_count] eq "03" && ($eduLevel[$record_count] eq "09" || $eduLevel[$record_count] eq "10" || $eduLevel[$record_count] eq "11"|| $eduLevel[$record_count] eq "12"))
                {
                    $indianHs++;
                }
                elsif(($race[$record_count] eq "04" || $race[$record_count] eq "05" || $race[$record_count] eq "06" || $race[$record_count] eq "07" ||  $race[$record_count] eq "18" ||  $race[$record_count] eq "28" || $race[$record_count] eq "48") && ($eduLevel[$record_count] eq "09" || $eduLevel[$record_count] eq "10" || $eduLevel[$record_count] eq "11"|| $eduLevel[$record_count] eq "12"))
                {
                    $asianHs++;
                }
                elsif($race[$record_count] eq "01" && ($eduLevel[$record_count] eq "13" || $eduLevel[$record_count] eq "14" || $eduLevel[$record_count] eq "15"|| $eduLevel[$record_count] eq "16" || $eduLevel[$record_count] eq "17"))
                {
                    $whiteUni++;
                }
                elsif($race[$record_count] eq "02" && ($eduLevel[$record_count] eq "13" || $eduLevel[$record_count] eq "14" || $eduLevel[$record_count] eq "15"|| $eduLevel[$record_count] eq "16" || $eduLevel[$record_count] eq "17"))
                {
                    $blackUni++;
                }
                elsif($race[$record_count] eq "03" && ($eduLevel[$record_count] eq "13" || $eduLevel[$record_count] eq "14" || $eduLevel[$record_count] eq "15"|| $eduLevel[$record_count] eq "16" || $eduLevel[$record_count] eq "17"))
                {
                    $indianUni++;
                }
                elsif(($race[$record_count] eq "04" || $race[$record_count] eq "05" || $race[$record_count] eq "06" || $race[$record_count] eq "07" ||  $race[$record_count] eq "18" ||  $race[$record_count] eq "28" || $race[$record_count] eq "48") && ($eduLevel[$record_count] eq "13" || $eduLevel[$record_count] eq "14" || $eduLevel[$record_count] eq "15"|| $eduLevel[$record_count] eq "16" || $eduLevel[$record_count] eq "17"))
                {
                    $asianUni++;
                }
                elsif($race[$record_count] eq "01" && $eduLevel[$record_count] eq "00")
                {
                    $whiteNe++;
                }
                elsif($race[$record_count] eq "02" && $eduLevel[$record_count] eq "00")
                {
                    $blackNe++;
                }
                elsif($race[$record_count] eq "03" && $eduLevel[$record_count] eq "00")
                {
                    $indianNe++;
                }
                elsif(($race[$record_count] eq "04" || $race[$record_count] eq "05" || $race[$record_count] eq "06" || $race[$record_count] eq "07" ||  $race[$record_count] eq "18" ||  $race[$record_count] eq "28" || $race[$record_count] eq "48") && $eduLevel[$record_count] eq "00")
                {
                    $asianNe++;
                }
                elsif($eduLevel[$record_count] eq "99")
                {
                    $notStated++
                }
                else
                {
                    if($eduLevel[$record_count] eq "01" || $eduLevel[$record_count] eq "02" || $eduLevel[$record_count] eq "03"|| $eduLevel[$record_count] eq "04" || $eduLevel[$record_count] eq "05" || $eduLevel[$record_count] eq "06" || $eduLevel[$record_count] eq "07" || $eduLevel[$record_count] eq "08")
                    {
                        $otherElem++;
                    }
                    elsif($eduLevel[$record_count] eq "09" || $eduLevel[$record_count] eq "10" || $eduLevel[$record_count] eq "11"|| $eduLevel[$record_count] eq "12")
                    {
                        $otherHs++;
                    }
                    elsif($eduLevel[$record_count] eq "13" || $eduLevel[$record_count] eq "14" || $eduLevel[$record_count] eq "15"|| $eduLevel[$record_count] eq "16" || $eduLevel[$record_count] eq "17")
                    {
                        $otherUni++;
                    }
                    elsif($eduLevel[$record_count] eq "00")
                    {
                        $otherNe++;
                    }

                }
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }

    }

    if($isPlotMode == 0)
    {
        print "From ".$initialYear." to ".$endYear." there were: \n";
        print $whiteNe." White people with no education"."\n";
        print $blackNe." Black people with no education"."\n";
        print $indianNe." Native Indian people with no education"."\n";
        print $asianNe." Asian people with no education"."\n";
        print $otherNe." Other people with no education"."\n";
        print "\n";
        print $whiteElem." White people with elementary school education"."\n";
        print $blackElem." Black people with elementary school education"."\n";
        print $indianElem." Native Indian people with elementary school education"."\n";
        print $asianElem." Asian people with elementary school education"."\n";
        print $otherElem." Other people with elementary school education"."\n";
        print "\n";
        print $whiteHs." White people with high school education"."\n";
        print $blackHs." Black people with high school education"."\n";
        print $indianHs." Native Indian people with high school education"."\n";
        print $asianHs." Asian people with high school education"."\n";
        print $otherHs." Other people with high school education"."\n";
        print "\n";
        print $whiteUni." White people with college education"."\n";
        print $blackUni." Black people with college education"."\n";
        print $indianUni." Native indian people with college education"."\n";
        print $asianUni." Asian people with college education"."\n";
        print $otherUni." Other people with college education"."\n";
        print "\n";
        print $notStated." People with unstated education"."\n";
    }
    else
    {
        if ($isIgnoreUnknown == 1)
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "White,"."No education".",".$whiteNe."\n";
            print "Black,"."No education".",".$blackNe."\n";
            print "Indian,"."No education".",".$indianNe."\n";
            print "Asian,"."No education".",".$asianNe."\n";
            print "Other,"."No education".",".$otherNe."\n";

            print "White,"."Elementary".",".$whiteElem."\n";
            print "Black,"."Elementary".",".$blackElem."\n";
            print "Indian,"."Elementary".",".$indianElem."\n";
            print "Asian,"."Elementary".",".$asianElem."\n";
            print "Other,"."Elementary".",".$otherElem."\n";

            print "White,"."High School".",".$whiteHs."\n";
            print "Black,"."High School".",".$blackHs."\n";
            print "Indian,"."High School".",".$indianHs."\n";
            print "Asian,"."High School".",".$asianHs."\n";
            print "Other,"."High School".",".$otherHs."\n";

            print "White,"."University".",".$whiteUni."\n";
            print "Black,"."University".",".$blackUni."\n";
            print "Indian,"."University".",".$indianUni."\n";
            print "Asian,"."University".",".$asianUni."\n";
            print "Other,"."University".",".$otherUni."\n";

        }

        else
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "White,"."No education".",".$whiteNe."\n";
            print "Black,"."No education".",".$blackNe."\n";
            print "Indian,"."No education".",".$indianNe."\n";
            print "Asian,"."No education".",".$asianNe."\n";
            print "Other,"."No education".",".$otherNe."\n";

            print "White,"."Elementary".",".$whiteElem."\n";
            print "Black,"."Elementary".",".$blackElem."\n";
            print "Indian,"."Elementary".",".$indianElem."\n";
            print "Asian,"."Elementary".",".$asianElem."\n";
            print "Other,"."Elementary".",".$otherElem."\n";

            print "White,"."High School".",".$whiteHs."\n";
            print "Black,"."High School".",".$blackHs."\n";
            print "Indian,"."High School".",".$indianHs."\n";
            print "Asian,"."High School".",".$asianHs."\n";
            print "Other,"."High School".",".$otherHs."\n";

            print "White,"."University".",".$whiteUni."\n";
            print "Black,"."University".",".$blackUni."\n";
            print "Indian,"."University".",".$indianUni."\n";
            print "Asian,"."University".",".$asianUni."\n";
            print "Other,"."University".",".$otherUni."\n";

            print "All races,"."Not stated".",".$notStated."\n";
        }

    }
} elsif ($t1 eq "Gender" && $t2 eq "workDeath") {
    #Gender workDeath
    my $record_count = -1;
    my $maleInjuryCount = 0;
    my $femaleInjuryCount = 0;
    my $totalMcount = 0;
    my $totalFcount = 0;
    my $totalUcount = 0;
    my @gender;
    my @workInjury;
    my @records;
    my $filename;

    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];

    foreach $filename (@filenames)
    {
        print STDERR "\tStarting $filename\n";

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

                if($gender[$record_count] eq "1" && $workInjury[$record_count] eq "1")
                {
                    $maleInjuryCount++;
                }
                elsif($gender[$record_count] eq "2" && $workInjury[$record_count] eq "1")
                {
                    $femaleInjuryCount++;
                }
                elsif($workInjury[$record_count] eq "9")
                {
                    $unknown++;
                }
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }

        $totalMcount = $totalMcount + $maleInjuryCount;
        $totalFcount = $totalFcount + $femaleInjuryCount;
        $totalUcount = $totalUcount + $unknown;

        $record_count = -1;
        $maleInjuryCount = 0;
        $femaleInjuryCount = 0;
        $unknown = 0;

    }

    if($isPlotMode == 0)
    {
        print "From ".$initialYear." to ".$endYear." there were: \n";
        print $totalMcount." Male injuries"."\n";
        print $totalFcount." Female injuries"."\n";
        print $totalUcount." Unknown"."\n";
    }
    else
    {
        print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
        print "CATEGORY,XLABEL,VALUE\n";
        print "Male,".$initialYear."-".$endYear.",".$totalMcount."\n";
        print "Female,".$initialYear."-".$endYear.",".$totalFcount."\n";
        print "Unknown,".$initialYear."-".$endYear.",".$totalUcount."\n";
    }
} elsif ($t1 eq "Gender" && $t2 eq "eduLvl") {
    #Gender eduLvl
    my $record_count = -1;
    my $maleCount = 0;
    my $maleNe = 0;
    my $maleElem = 0;
    my $maleHs = 0;
    my $maleUni = 0;
    my $maleNs = 0;
    my $femaleCount = 0;
    my $femaleNe = 0;
    my $femaleElem = 0;
    my $femaleHs = 0;
    my $femaleUni = 0;
    my $femaleNs = 0;
    my @gender;
    my @eduLevel;
    my @records;
    my $filename;

    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];

    foreach $filename (@filenames)
    {
        print STDERR "\tStarting $filename\n";

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
                $eduLevel[$record_count]     = $master_fields[5];

                if($gender[$record_count] eq "1" && $eduLevel[$record_count] eq "00")
                {
                    $maleNe++;
                }
                elsif($gender[$record_count] eq "2" && $eduLevel[$record_count] eq "00")
                {
                    $femaleNe++;
                }
                elsif($gender[$record_count] eq "1" && $eduLevel[$record_count] eq "99")
                {
                    $maleNs++;
                }
                elsif($gender[$record_count] eq "2" && $eduLevel[$record_count] eq "99")
                {
                    $femaleNs++;
                }
                elsif($gender[$record_count] eq "1" && ($eduLevel[$record_count] eq "01" || $eduLevel[$record_count] eq "02" || $eduLevel[$record_count] eq "03"|| $eduLevel[$record_count] eq "04" || $eduLevel[$record_count] eq "05" || $eduLevel[$record_count] eq "06" || $eduLevel[$record_count] eq "07" || $eduLevel[$record_count] eq "08"))
                {
                    $maleElem++;
                }
                elsif($gender[$record_count] eq "2" && ($eduLevel[$record_count] eq "01" || $eduLevel[$record_count] eq "02" || $eduLevel[$record_count] eq "03"|| $eduLevel[$record_count] eq "04" || $eduLevel[$record_count] eq "05" || $eduLevel[$record_count] eq "06" || $eduLevel[$record_count] eq "07" || $eduLevel[$record_count] eq "08"))
                {
                    $femaleElem++;
                }
                elsif($gender[$record_count] eq "1" && ($eduLevel[$record_count] eq "09" || $eduLevel[$record_count] eq "10" || $eduLevel[$record_count] eq "11"|| $eduLevel[$record_count] eq "12"))
                {
                    $maleHs++;
                }
                elsif($gender[$record_count] eq "2" && ($eduLevel[$record_count] eq "09" || $eduLevel[$record_count] eq "10" || $eduLevel[$record_count] eq "11"|| $eduLevel[$record_count] eq "12"))
                {
                    $femaleHs++;
                }
                elsif($gender[$record_count] eq "1" && ($eduLevel[$record_count] eq "13" || $eduLevel[$record_count] eq "14" || $eduLevel[$record_count] eq "15"|| $eduLevel[$record_count] eq "16" || $eduLevel[$record_count] eq "17"))
                {
                    $maleUni++;
                }
                elsif($gender[$record_count] eq "2" && ($eduLevel[$record_count] eq "13" || $eduLevel[$record_count] eq "14" || $eduLevel[$record_count] eq "15"|| $eduLevel[$record_count] eq "16" || $eduLevel[$record_count] eq "17"))
                {
                    $femaleUni++;
                }
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }

    }

    if($isPlotMode == 0)
    {
        print "From ".$initialYear." to ".$endYear." there were: \n";
        print $maleNe." Males with no education"."\n";
        print $femaleNe." Females with no education"."\n";
        print "\n";
        print $maleElem." Males with elementary school education"."\n";
        print $femaleElem." Females with elementary school education"."\n";
        print "\n";
        print $maleHs." Males with high school education"."\n";
        print $femaleHs." Females with high school education"."\n";
        print "\n";
        print $maleUni." Males with college education"."\n";
        print $femaleUni." Females with college education"."\n";
        print "\n";
        print $maleNs." Males with unstated education"."\n";
        print $femaleNs." Females with unstated education"."\n";
    }
    else
    {
        print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
        print "CATEGORY,XLABEL,VALUE\n";
        print "Male,"."No education".",".$maleNe."\n";
        print "Female,"."No education".",".$femaleNe."\n";

        print "Male,"."Elementary".",".$maleElem."\n";
        print "Female,"."Elementary".",".$femaleElem."\n";

        print "Male,"."High School".",".$maleHs."\n";
        print "Female,"."High School".",".$femaleHs."\n";

        print "Male,"."University".",".$maleUni."\n";
        print "Female,"."University".",".$femaleUni."\n";

        print "Male,"."Not stated".",".$maleNs."\n";
        print "Female,"."Not stated".",".$femaleNs."\n";
    }

} elsif($t1 eq "Funeral" && $t2 eq "deathMonth") {
    #Funeral deathMonth
    my $filename = 0;
    my $record_count = -1;
    my $janDeath = 0;
    my $febDeath = 0;
    my $marDeath = 0;
    my $aprDeath = 0;
    my $mayDeath = 0;
    my $junDeath = 0;
    my $julDeath = 0;
    my $augDeath = 0;
    my $sepDeath = 0;
    my $octDeath = 0;
    my $novDeath = 0;
    my $decDeath = 0;

    my @month;
    my @death;
    my @records;

    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];

    #    while($begYear != $endYear+1)
    #    {
    #        $filename = "mort".$begYear.".txt";
    #
    #        #my $file = "/mortTest/".$filename;
    #        #print $file."\n";

    foreach $filename (@filenames)
    {
        print STDERR "\tStarting $filename\n";
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
        foreach my $name_record ( @records )
        {
            if ( $csv->parse($name_record) )
            {
                my @master_fields = $csv->fields();
                $record_count++;
                $month[$record_count]     = $master_fields[1];
                $death[$record_count]     = $master_fields[7];

                if($month[$record_count] eq "01")
                {
                    $janDeath ++;
                }
                elsif($month[$record_count] eq "02")
                {
                    $febDeath ++;
                }
                elsif($month[$record_count] eq "03")
                {
                    $marDeath ++;
                }
                elsif($month[$record_count] eq "04")
                {
                    $aprDeath ++;
                }
                elsif($month[$record_count] eq "05")
                {
                    $mayDeath ++;
                }
                elsif($month[$record_count] eq "06")
                {
                    $junDeath ++;
                }
                elsif($month[$record_count] eq "07")
                {
                    $julDeath ++;
                }
                elsif($month[$record_count] eq "08")
                {
                    $augDeath ++;
                }
                elsif($month[$record_count] eq "09")
                {
                    $sepDeath ++;
                }
                elsif($month[$record_count] eq "10")
                {
                    $octDeath ++;
                }
                elsif($month[$record_count] eq "11")
                {
                    $novDeath ++;
                }
                elsif($month[$record_count] eq "12")
                {
                    $decDeath ++;
                }
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }

    }

    if($isPlotMode == 0)
    {
        print "From ".$initialYear." to ".$endYear." there were: \n";
        print "Jan: ".$janDeath." Deaths"."\n";
        print "Feb: ".$febDeath." Deaths"."\n";
        print "Mar: ".$marDeath." Deaths"."\n";
        print "Apr: ".$aprDeath." Deaths"."\n";
        print "May: ".$mayDeath." Deaths"."\n";
        print "Jun: ".$junDeath." Deaths"."\n";
        print "Jul: ".$julDeath." Deaths"."\n";
        print "Aug: ".$augDeath." Deaths"."\n";
        print "Sept: ".$sepDeath." Deaths"."\n";
        print "Oct: ".$octDeath." Deaths"."\n";
        print "Nov: ".$novDeath." Deaths"."\n";
        print "Dec: ".$decDeath." Deaths"."\n";
    }
    else
    {
        print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
        print "CATEGORY,XLABEL,VALUE\n";
        print "01,".$initialYear."-".$endYear.",".$janDeath."\n";
        print "02,".$initialYear."-".$endYear.",".$febDeath."\n";
        print "03,".$initialYear."-".$endYear.",".$marDeath."\n";
        print "04,".$initialYear."-".$endYear.",".$aprDeath."\n";
        print "05,".$initialYear."-".$endYear.",".$mayDeath."\n";
        print "06,".$initialYear."-".$endYear.",".$junDeath."\n";
        print "07,".$initialYear."-".$endYear.",".$julDeath."\n";
        print "08,".$initialYear."-".$endYear.",".$augDeath."\n";
        print "09,".$initialYear."-".$endYear.",".$sepDeath."\n";
        print "10,".$initialYear."-".$endYear.",".$octDeath."\n";
        print "11,".$initialYear."-".$endYear.",".$novDeath."\n";
        print "12,".$initialYear."-".$endYear.",".$decDeath."\n";
    }

} 
elsif($t1 eq "School" && $t2 eq "birthMonth") 
{
    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];

    my $filename;
    my $gender;
    my @monthValue;
    my $record_count;
    my @records;

    foreach $filename (@filenames)
    {

        print STDERR "\tStarting $filename\n";
        open my $names_fh, '<', $filename
            or die "Unable to open names file: $filename\n";

        @records = <$names_fh>;

        close $names_fh or
        die "Unable to close: $filename";   # Close the input file

        foreach my $birth_record ( @records )
        {
            if ( $csv->parse($birth_record) )
            {
                my @master_fields = $csv->fields();
                $record_count++;

                $monthValue[$master_fields[1]] += 1;


            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }
    }

    if ($isPlotMode == 0)
    {
        for (my $i = 1; $i < 13; $i++)
        {
            print "Total Births per month: " . $monthValue[$i] . " for month ". $i ."\n";

        }
    }
    else
    {
        print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
        print "CATEGORY,XLABEL,VALUE\n";
        print "01,".$initialYear."-".$endYear.",".$monthValue[1]."\n";
        print "02,".$initialYear."-".$endYear.",".$monthValue[2]."\n";
        print "03,".$initialYear."-".$endYear.",".$monthValue[3]."\n";
        print "04,".$initialYear."-".$endYear.",".$monthValue[4]."\n";
        print "05,".$initialYear."-".$endYear.",".$monthValue[5]."\n";
        print "06,".$initialYear."-".$endYear.",".$monthValue[6]."\n";
        print "07,".$initialYear."-".$endYear.",".$monthValue[7]."\n";
        print "08,".$initialYear."-".$endYear.",".$monthValue[8]."\n";
        print "09,".$initialYear."-".$endYear.",".$monthValue[9]."\n";
        print "10,".$initialYear."-".$endYear.",".$monthValue[10]."\n";
        print "11,".$initialYear."-".$endYear.",".$monthValue[11]."\n";
        print "12,".$initialYear."-".$endYear.",".$monthValue[12]."\n";
    }



} elsif($t1 eq "BabyToy" && $t2 eq "genderMonth") {
    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];

    my $filename;
    my $gender;
    my @monthValueMale;
    my @monthValueFemale;
    my $record_count;
    my @records;

    foreach $filename (@filenames)
    {

        print STDERR "\tStarting $filename\n";
        open my $names_fh, '<', $filename
            or die "Unable to open names file: $filename\n";

        @records = <$names_fh>;

        close $names_fh or
        die "Unable to close: $filename";   # Close the input file

        foreach my $birth_record ( @records )
        {
            if ( $csv->parse($birth_record) )
            {
                my @master_fields = $csv->fields();
                $record_count++;
                $gender = $master_fields[2];
                if ($gender eq  '1') {
                    $monthValueMale[$master_fields[1]] += 1;
                }

                elsif($gender eq '2') {
                    $monthValueFemale[$master_fields[1]] += 1;
                }

            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }
    }

    if ($isPlotMode == 0)
    {
        for (my $i = 1; $i < 13; $i++)
        {
            print "Female Total: " . $monthValueFemale[$i] . " for month ". $i ."\n";
            print "Male Total: " . $monthValueMale[$i] . " for month ". $i ."\n";

        }
    }
    else
    {
        print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
        print "CATEGORY,XLABEL,VALUE\n";
        print "01,"."MALE,".$monthValueMale[1]."\n";
        print "02,"."MALE,".$monthValueMale[2]."\n";
        print "03,"."MALE,".$monthValueMale[3]."\n";
        print "04,"."MALE,".$monthValueMale[4]."\n";
        print "05,"."MALE,".$monthValueMale[5]."\n";
        print "06,"."MALE,".$monthValueMale[6]."\n";
        print "07,"."MALE,".$monthValueMale[7]."\n";
        print "08,"."MALE,".$monthValueMale[8]."\n";
        print "09,"."MALE,".$monthValueMale[9]."\n";
        print "10,"."MALE,".$monthValueMale[10]."\n";
        print "11,"."MALE,".$monthValueMale[11]."\n";
        print "12,"."MALE,".$monthValueMale[12]."\n";

        print "01,"."FEMALE,".$monthValueFemale[1]."\n";
        print "02,"."FEMALE,".$monthValueFemale[2]."\n";
        print "03,"."FEMALE,".$monthValueFemale[3]."\n";
        print "04,"."FEMALE,".$monthValueFemale[4]."\n";
        print "05,"."FEMALE,".$monthValueFemale[5]."\n";
        print "06,"."FEMALE,".$monthValueFemale[6]."\n";
        print "07,"."FEMALE,".$monthValueFemale[7]."\n";
        print "08,"."FEMALE,".$monthValueFemale[8]."\n";
        print "09,"."FEMALE,".$monthValueFemale[9]."\n";
        print "10,"."FEMALE,".$monthValueFemale[10]."\n";
        print "11,"."FEMALE,".$monthValueFemale[11]."\n";
        print "12,"."FEMALE,".$monthValueFemale[12]."\n";
    }



} elsif($t1 eq "MentalHealth" && $t2 eq "maritalSuicide") {
    #MentalHealth maritalSuicide
    my $record_count = -1;
    my $gender = 0;
    my $singleCountMale = 0;
    my $marriedCountMale = 0;
    my $widowedCountMale = 0;
    my $divorcedCountMale = 0;
    my $unknownCountMale = 0;
    my $suicideCountMale = 0;

    my $singleCountFemale = 0;
    my $marriedCountFemale = 0;
    my $widowedCountFemale = 0;
    my $divorcedCountFemale = 0;
    my $unknownCountFemale = 0;
    my $suicideCountFemale = 0;

    my @mStatus;
    my @mannerOD;
    my @records;
    my $filename;

    my $initialYear = 0;
    my $unknown = 0;
    my $begYear = 0;
    my $endYear = 0;
    $initialYear = $yearRange[0];
    $begYear = $yearRange[0];
    $endYear = $yearRange[1];

    foreach $filename (@filenames)
    {
        print STDERR "\tStarting $filename\n";

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
                $gender                     = $master_fields[2];
                $mStatus[$record_count]     = $master_fields[4];
                $mannerOD[$record_count]    = $master_fields[7];

                if($mStatus[$record_count] eq "1" && $mannerOD[$record_count] eq "1")
                {
                    if ($gender eq "1") {
                        $singleCountMale++;
                    } elsif($gender eq "2") {
                        $singleCountFemale++;
                    }
                }
                elsif($mStatus[$record_count] eq "2" && $mannerOD[$record_count] eq "1")
                {
                    if ($gender eq "1") {
                        $marriedCountMale++;
                    } elsif($gender eq "2") {
                        $marriedCountFemale++;
                    }
                }
                elsif($mStatus[$record_count] eq "3" && $mannerOD[$record_count] eq "1")
                {
                    if ($gender eq "1") {
                        $widowedCountMale++;
                    } elsif($gender eq "2") {
                        $widowedCountFemale++;
                    }
                }
                elsif($mStatus[$record_count] eq "4" && $mannerOD[$record_count] eq "1")
                {
                    if ($gender eq "1") {
                        $divorcedCountMale++;
                    } elsif($gender eq "2") {
                        $divorcedCountFemale++;
                    }
                }
                elsif($mStatus[$record_count] eq "9" && $mannerOD[$record_count] eq "1")
                {
                    if ($gender eq "1") {
                        $unknownCountMale++;
                    } elsif($gender eq "2") {
                        $unknownCountFemale++;
                    }
                }
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }

    }

    if($isPlotMode == 0)
    {
        print "From ".$initialYear." to ".$endYear." there were: \n";
        print $singleCountMale." Single suicides for male"."\n";
        print $marriedCountMale." Married suicides for male"."\n";
        print $widowedCountMale." Widowed suicides for male"."\n";
        print $divorcedCountMale." Divorced suicides for male"."\n";
        print $unknownCountMale." Unknown suicides for male"."\n";
        print $singleCountFemale." Single suicides for female"."\n";
        print $marriedCountFemale." Married suicides for female"."\n";
        print $widowedCountFemale." Widowed suicides for female"."\n";
        print $divorcedCountFemale." Divorced suicides for female"."\n";
        print $unknownCountFemale." Unknown suicides for female"."\n";
    }
    else
    {
        if ($isIgnoreUnknown == 1)
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "Single,"."Male".",".$singleCountMale."\n";
            print "Married,"."Male".",".$marriedCountMale."\n";
            print "Widowed,"."Male".",".$widowedCountMale."\n";
            print "Divorced,"."Male".",".$divorcedCountMale."\n";
            print "Single,"."Female".",".$singleCountFemale."\n";
            print "Married,"."Female".",".$marriedCountFemale."\n";
            print "Widowed,"."Female".",".$widowedCountFemale."\n";
            print "Divorced,"."Female".",".$divorcedCountFemale."\n";
        }

        else
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "Single,"."Male".",".$singleCountMale."\n";
            print "Married,"."Male".",".$marriedCountMale."\n";
            print "Widowed,"."Male".",".$widowedCountMale."\n";
            print "Divorced,"."Male".",".$divorcedCountMale."\n";
            print "Unknown,"."Male".",".$unknownCountMale."\n";
            print "Single,"."Female".",".$singleCountFemale."\n";
            print "Married,"."Female".",".$marriedCountFemale."\n";
            print "Widowed,"."Female".",".$widowedCountFemale."\n";
            print "Divorced,"."Female".",".$divorcedCountFemale."\n";
            print "Unknown,"."Female".",".$unknownCountFemale."\n";
        }
    }

} else {
    printHelp();
    exit;
}
















