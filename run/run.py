#!/usr/bin/python                                                                                                                                                      
     
import sys 
import re
import os
import optparse
 
def create_commond(case_name):
    reach = 0 
    commond = 'irun -uvm -uvmhome $UVM_HOME -uvmnocdnsextra -sv -f ../list/bench.f -64bit -timescale 1ns/10ps'
    for arg in sys.argv:
        if re.search('^-?gui$', arg) != None:
            commond += ' -gui -debug'
            reach = 1 
        if re.search('^de?bu?g$', arg) != None:
            commond += ' -gui -linedebug'
            reach = 1 
        if re.search('^uv?m?de?bu?g$', arg) != None:
            commond += ' -gui -uvmlinedebug'
            reach = 1 
        if reach == 0 and arg != sys.argv[0] and arg != case_name:
            commond += ' ' + arg 
 
    commond += ' +UVM_TESTNAME=' + case_name
    print commond
    run(commond)
    
def get_case_list(case):
    if os.path.isdir('../case') == False:
        print 'Cannot find <case> folder'
        exit(0)
    else :
        for a, b, case_list in os.walk('../case'):
            for case_file in case_list:
                if re.match('\w+\.svh?$', case_file):
                    f = open('../case/' + case_file)
                    lines = f.readlines()
                    for line in lines:
                        gp = re.search('class\s+(\w+)', line)
                        if gp != None:
                            case.append(gp.group(1))
        return case
        
def run(commond):
    os.system(commond)
 
def check_run_dir (is_run = False):
    path = os.getcwd()
    path = path.split('/')[-1]
    if path != 'run':
        print 'The script should be call in run() dir'
        is_run = False
    else:
        is_run = True
 
    return is_run
 
if __name__ == '__main__':
    if check_run_dir():
        case = []
        get_case_list(case)
        for arg in sys.argv:
            for case_name in case:
                if arg == case_name :
                    create_commond(case_name)
                    exit(1)
        create_commond(case_name)
        exit(1)
