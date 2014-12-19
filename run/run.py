#!/usr/bin/python                                                                                                                                                      
     
import sys
import re
import os
     
def create_commond():
    commond = 'irun -uvm -sv -f ../list/bench.f +UVM_CASENAME=ahb_case_base'
    for arg in sys.argv:
        if re.search('gui', arg) != None:
           commond += ' -gui -debug'
        if re.search('64bit', arg) != None:
           commond += ' -64bit'
        if re.search('dbg', arg) != None:
           commond += ' -gui -linedebug'
    run(commond)
     
def run(commond):
    print commond
    os.system(commond)
     
if __name__ == '__main__':
    path = os.getcwd()
    path = path.split('/')[-1]
    if path != 'run':
        print 'The script should be call in run() dir'
        exit(0)
    else:
        create_commond()
