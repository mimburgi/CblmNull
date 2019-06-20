
import glob
files=glob.glob("*Printout.txt")
outfile = open ("_testfile.txt", "w")

#write header for outfile
outfile.write("sub")
outfile.write("\t")
outfile.write("session")
outfile.write("\t")
outfile.write("blocknum")
outfile.write("\t")
outfile.write("trial")
outfile.write("\t")
outfile.write("letterset")
outfile.write("\t")
outfile.write("load")
outfile.write("\t")
outfile.write("letter")
outfile.write("\t")
outfile.write("resp")
outfile.write("\t")
outfile.write("acc")
outfile.write("\t")
outfile.write("RT")
outfile.write("\n")

lettersetline = False

for file in files:
    infile = open(file, "r")

    lines = [line.rstrip('\n') for line in infile]

    #next two lines get subj num
    subNum_dict = lines[0].split(": ")
    if len(subNum_dict[1].split(".")) == 2:
        subNum = subNum_dict[1].split(".")[0]
        sessionNum = subNum_dict[1].split(".")[1]
    
    #start loop to go through lines and write things to output file
    for line in lines:
        #for block lines
        if line.split(" ")[0] == "Block":
            blockNum = line.split(" ")[1]
        #for letter set lines (letter set is listed in the line after the words)
        elif line.split(" ")[0] == "Letter":
            if line.split(" ")[1] == "Set:":
                lettersetline = True
            else:
                letter = line.split(" ")[2]
        elif lettersetline == True:
            if len(line.strip(" ")) > 1:
                letterset = line
                if len(line.strip("  ")) == 13:
                    load = "H"
                else:
                    load = "M"
                lettersetline = False
            elif (line == "A") or (line == "B") or (line == "D") or (line == "E") or (line == "F") or (line == "G") or (line == "H") or (line == "J") or (line == "K") or (line == "M") or (line == "N") or (line == "Q") or (line == "R") or (line == "T") or (line == "U") or (line == "W") or (line == "Y"):
                letterset = line
                load = "L"
                lettersetline = False
        #for trial lines
        elif line.split(" ")[0] == "Trial":
            trialNum = line.split(" ")[1]
        #for butotn and acc
        elif line.split(" ")[0] == "Button":
            button = line.split(" ")[2]
            acc = line.split(" ")[4]
        #RT
        elif line.split(" ")[0] == "Reaction":
            RT = line.split(" ")[2]
            #write output
            outfile.write(subNum)
            outfile.write("\t")
            outfile.write(sessionNum)
            outfile.write("\t")
            outfile.write(blockNum)
            outfile.write("\t")
            outfile.write(trialNum)
            outfile.write("\t")
            outfile.write(letterset)
            outfile.write("\t")
            outfile.write(load)
            outfile.write("\t")
            outfile.write(letter)
            outfile.write("\t")
            outfile.write(button)
            outfile.write("\t")
            outfile.write(acc)
            outfile.write("\t")
            outfile.write(RT)
            outfile.write("\n")
    infile.close()

outfile.close()
