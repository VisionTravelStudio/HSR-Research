#拆分proto(to LunarCore)
#Author:Vision Travel
#For an anime rpg game

import os
import re
import linecache

def file_input():
    LineNum = 1
    ManageLine = []
    FileName = "StarRail.proto"
    file = open(FileName, 'r')
    keyword1 = "message "
    keyword2 = "enum "
    OutFileNameOriginal = []
    OutFileName = []
    destLines = []
    path = "outputLC"
    os.makedirs(path)
    #split
    for EachLine in file:
        target1 = re.search(keyword1, EachLine)
        target2 = re.search(keyword2, EachLine)
        if target1 is not None:
           ManageLine.append(LineNum)
           OutFileNameOriginal.append(linecache.getline(FileName, LineNum))
           OutFileName = (x.replace("message ", "").replace(" {\n", "").replace("enum ", "") for x in OutFileNameOriginal)
        if target2 is not None:
           ManageLine.append(LineNum)
           OutFileNameOriginal.append(linecache.getline(FileName, LineNum))
           OutFileName = (y.replace("enum ", "").replace(" {\n", "").replace("message ", "") for y in OutFileNameOriginal)
        LineNum += 1
    ManageLine.append(LineNum+1)
    size = int(len(ManageLine))
    #write
    for i in range(0,size-1):
        start = ManageLine[i]
        end = ManageLine[i+1]
        destLines = linecache.getlines(FileName)[start-1:end-1]
        for test in destLines:
            print(test)
        for genw in OutFileName:
            file_w = open('./outputLC/%s' %genw + '.proto', 'a+')
            file_w.write('syntax = "proto3";\n\noption java_package = "emu.lunarcore.proto";\n\n')
            for key in destLines:
                file_w.write(key)
        file_w.close()
if __name__ == "__main__":
    file_input()