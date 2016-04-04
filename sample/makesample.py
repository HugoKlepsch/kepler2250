import random
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

    percentage = 0.1

    for line in fin:
        if (random.random() < percentage):
            fout.write(line)

    fin.close()
    fout.close()

baseMort = "mort"
endMort = ".txt"
baseBirth = ""
endBirth = "birth.txt"

for year in range(1968, 2015):
    sampleFile(baseMort+str(year)+endMort, True);

for year in range(1968, 2015):
    sampleFile(baseBirth+str(year)+endBirth, False);


