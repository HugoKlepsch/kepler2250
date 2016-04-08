import random

# sampleFile
# Takes in a filename, and whether it's a mort filename, then copies a percentage of the original 
#   file into a new file. 
# Each line is randomly selected
def sampleFile(name, isMort):
    baseDirMort = '../processedMort/'
    newDirMort = 'processedMort/'
    baseDirBirth = '../processedBirth/'
    newDirBirth = 'processedBirth/'
    print "start", name

    if (isMort == True):
        fin = open(baseDirMort+name, 'r')
        fout = open(newDirMort + name, 'w')
    else:
        fin = open(baseDirBirth+name, 'r')
        fout = open(newDirBirth + name, 'w')

    percentage = 0.03

    #for every line in the original
    for line in fin:
        #if it's dice roll lands in a certain percentage
        if (random.random() < percentage):
            #write it to the new file
            fout.write(line)

    #clode both files
    fin.close()
    fout.close()

##########
###MAIN###
##########

baseMort = "mort"
endMort = ".txt"
baseBirth = ""
endBirth = "birth.txt"

#for every year in our preprocessed mort files
for year in range(1968, 2015):
    #sample it
    sampleFile(baseMort+str(year)+endMort, True);

#for every year in our preprocessed birth files
for year in range(1968, 2015):
    #sample it
    sampleFile(baseBirth+str(year)+endBirth, False);


