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
    
    if ($startYear > $endYear){
        exit;
    } elsif ($startYear < 1968 || $endYear > 2014) {
        exit;
    }
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
    
    return @filenames;
    
}

sub printHelp {
    print "Usage: search.pl {tier 1} {tier 2} {year range} {plotMode on/off} {ignoreUnknown on/off}\n";
    print "Options: \n{tier 1}:\n\t{tier 2}\n\t{tier 2}\n";
    print "Race\n\tworkDeath\n\teduLvl\nGender\n\tworkDeath\n\teduLvl\nFuneral\n\tdeathMonth\nSchool\n\tbirthMonth\nBabyToy\n\tgenderMonth\nMentalHealth\n\tmaritalSuicide\n";
    print "Usage: search.pl Gender workDeath 1968-1971 on\n";
    print "To search a single year, put that year as both sides of the year range.\n";
    print "PlotMode off means the output is in a 'human readable' format. \nPlotMode on means the output is ready for our plotting tool\n";
    print "ignoreUnknown on means that the output of the search tool does not include statistics on \n\"unknown\" categories. For example it will not output information on unknown race, or education level. \nExceptions for workplace deaths, as unknown injury is more important there. \n";
    
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
if ($#ARGV != 4 ) {
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
    
    print STDERR "Will try to load these files:\n";
    foreach my $year (@filenames) {
        print STDERR $year."\n";
    }
    print STDERR "~~~~~~~~~~~~~~~~~\n";
    
}

###############################################################################
#Start of the search code######################################################
###############################################################################
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
                $workInjury[$record_count]     = $master_fields[6];
                
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
            print "WhiteNe,".$initialYear."-".$endYear.",".$whiteNe."\n";
            print "BlackNe,".$initialYear."-".$endYear.",".$blackNe."\n";
            print "IndianNe,".$initialYear."-".$endYear.",".$indianNe."\n";
            print "AsianNe,".$initialYear."-".$endYear.",".$asianNe."\n";
            print "OtherNe,".$initialYear."-".$endYear.",".$otherNe."\n";
            
            print "WhiteElem,".$initialYear."-".$endYear.",".$whiteElem."\n";
            print "BlackElem,".$initialYear."-".$endYear.",".$blackElem."\n";
            print "IndianElem,".$initialYear."-".$endYear.",".$indianElem."\n";
            print "AsianElem,".$initialYear."-".$endYear.",".$asianElem."\n";
            print "OtherElem,".$initialYear."-".$endYear.",".$otherElem."\n";
            
            print "WhiteHs,".$initialYear."-".$endYear.",".$whiteHs."\n";
            print "BlackHs,".$initialYear."-".$endYear.",".$blackHs."\n";
            print "IndianHs,".$initialYear."-".$endYear.",".$indianHs."\n";
            print "AsianHs,".$initialYear."-".$endYear.",".$asianHs."\n";
            print "OtherHs,".$initialYear."-".$endYear.",".$otherHs."\n";
            
            print "WhiteUni,".$initialYear."-".$endYear.",".$whiteUni."\n";
            print "BlackUni,".$initialYear."-".$endYear.",".$blackUni."\n";
            print "IndianUni,".$initialYear."-".$endYear.",".$indianUni."\n";
            print "AsianUni,".$initialYear."-".$endYear.",".$asianUni."\n";
            print "OtherUni,".$initialYear."-".$endYear.",".$otherUni."\n";
            
        }
        
        else
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "WhiteNe,".$initialYear."-".$endYear.",".$whiteNe."\n";
            print "BlackNe,".$initialYear."-".$endYear.",".$blackNe."\n";
            print "IndianNe,".$initialYear."-".$endYear.",".$indianNe."\n";
            print "AsianNe,".$initialYear."-".$endYear.",".$asianNe."\n";
            print "OtherNe,".$initialYear."-".$endYear.",".$otherNe."\n";
            
            print "WhiteElem,".$initialYear."-".$endYear.",".$whiteElem."\n";
            print "BlackElem,".$initialYear."-".$endYear.",".$blackElem."\n";
            print "IndianElem,".$initialYear."-".$endYear.",".$indianElem."\n";
            print "AsianElem,".$initialYear."-".$endYear.",".$asianElem."\n";
            print "OtherElem,".$initialYear."-".$endYear.",".$otherElem."\n";
            
            print "WhiteHs,".$initialYear."-".$endYear.",".$whiteHs."\n";
            print "BlackHs,".$initialYear."-".$endYear.",".$blackHs."\n";
            print "IndianHs,".$initialYear."-".$endYear.",".$indianHs."\n";
            print "AsianHs,".$initialYear."-".$endYear.",".$asianHs."\n";
            print "OtherHs,".$initialYear."-".$endYear.",".$otherHs."\n";
            
            print "WhiteUni,".$initialYear."-".$endYear.",".$whiteUni."\n";
            print "BlackUni,".$initialYear."-".$endYear.",".$blackUni."\n";
            print "IndianUni,".$initialYear."-".$endYear.",".$indianUni."\n";
            print "AsianUni,".$initialYear."-".$endYear.",".$asianUni."\n";
            print "OtherUni,".$initialYear."-".$endYear.",".$otherUni."\n";
            
            print "NotStated,".$initialYear."-".$endYear.",".$notStated."\n";
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
        print "MaleNe,".$initialYear."-".$endYear.",".$maleNe."\n";
        print "FemaleNe,".$initialYear."-".$endYear.",".$femaleNe."\n";
        
        print "MaleElem,".$initialYear."-".$endYear.",".$maleElem."\n";
        print "FemaleElem,".$initialYear."-".$endYear.",".$femaleElem."\n";
        
        print "MaleHs,".$initialYear."-".$endYear.",".$maleHs."\n";
        print "FemaleHs,".$initialYear."-".$endYear.",".$femaleHs."\n";
        
        print "MaleUni,".$initialYear."-".$endYear.",".$maleUni."\n";
        print "FemaleUni,".$initialYear."-".$endYear.",".$femaleUni."\n";
        
        print "MaleNs,".$initialYear."-".$endYear.",".$maleNs."\n";
        print "FemaleNs,".$initialYear."-".$endYear.",".$femaleNs."\n";
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
        print "Jan,".$initialYear."-".$endYear.",".$janDeath."\n";
        print "Feb,".$initialYear."-".$endYear.",".$febDeath."\n";
        print "Mar,".$initialYear."-".$endYear.",".$marDeath."\n";
        print "Apr,".$initialYear."-".$endYear.",".$aprDeath."\n";
        print "May,".$initialYear."-".$endYear.",".$mayDeath."\n";
        print "Jun,".$initialYear."-".$endYear.",".$junDeath."\n";
        print "Jul,".$initialYear."-".$endYear.",".$julDeath."\n";
        print "Aug,".$initialYear."-".$endYear.",".$augDeath."\n";
        print "Sept,".$initialYear."-".$endYear.",".$sepDeath."\n";
        print "Oct,".$initialYear."-".$endYear.",".$octDeath."\n";
        print "Nov,".$initialYear."-".$endYear.",".$novDeath."\n";
        print "Dec,".$initialYear."-".$endYear.",".$decDeath."\n";
    }
    
} elsif($t1 eq "School" && $t2 eq "birthMonth") {
    #School birthMonth
} elsif($t1 eq "BabyToy" && $t2 eq "genderMonth") {
    
    
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
                    $monthValueMale[$master_fields[1]] = $monthValueMale[$master_fields[1]] + 1;
                }
                elsif($gender eq '2') {
                    $monthValueFemale[$master_fields[1]] = $monthValueFemale[$master_fields[1]] + 1;
                }
            }
            else
            {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }
    }
    
    
    for (my $i = 1; $i < 13; $i++)
    {
        print "Total: " . $monthValueFemale[$i] . " for month ". $i ."\n";
        print "Total: " . $monthValueMale[$i] . " for month ". $i ."\n";
        
    }
} elsif($t1 eq "MentalHealth" && $t2 eq "maritalSuicide") {
    #MentalHealth maritalSuicide
    my $record_count = -1;
    my $singleCount = 0;
    my $marriedCount = 0;
    my $widowedCount = 0;
    my $divorcedCount = 0;
    my $unknownCount = 0;
    my $suicideCount = 0;
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
                $mStatus[$record_count]     = $master_fields[4];
                $mannerOD[$record_count]     = $master_fields[7];
                
                if($mStatus[$record_count] eq "1" && $mannerOD[$record_count] eq "1")
                {
                    $singleCount++;
                }
                elsif($mStatus[$record_count] eq "2" && $mannerOD[$record_count] eq "1")
                {
                    $marriedCount++;
                }
                elsif($mStatus[$record_count] eq "3" && $mannerOD[$record_count] eq "1")
                {
                    $widowedCount++;
                }
                elsif($mStatus[$record_count] eq "4" && $mannerOD[$record_count] eq "1")
                {
                    $divorcedCount++;
                }
                elsif($mStatus[$record_count] eq "9" && $mannerOD[$record_count] eq "1")
                {
                    $unknownCount++;
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
        print $singleCount." Single suicides"."\n";
        print $marriedCount." Married suicides"."\n";
        print $widowedCount." Widowed suicides"."\n";
        print $divorcedCount." Divorced suicides"."\n";
        print $unknownCount." Unknown suicides"."\n";
    }
    else
    {
        if ($isIgnoreUnknown == 1)
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "Single,".$initialYear."-".$endYear.",".$singleCount."\n";
            print "Married,".$initialYear."-".$endYear.",".$marriedCount."\n";
            print "Widowed,".$initialYear."-".$endYear.",".$widowedCount."\n";
            print "Divorced,".$initialYear."-".$endYear.",".$divorcedCount."\n";
        }
        
        else
        {
            print $t1.",".$t2.",".$initialYear."-".$endYear."\n";
            print "CATEGORY,XLABEL,VALUE\n";
            print "Single,".$initialYear."-".$endYear.",".$singleCount."\n";
            print "Married,".$initialYear."-".$endYear.",".$marriedCount."\n";
            print "Widowed,".$initialYear."-".$endYear.",".$widowedCount."\n";
            print "Divorced,".$initialYear."-".$endYear.",".$divorcedCount."\n";
            print "Unknown,".$initialYear."-".$endYear.",".$unknownCount."\n";
        }
    }
    
} else {
    printHelp();
    exit;
}
















