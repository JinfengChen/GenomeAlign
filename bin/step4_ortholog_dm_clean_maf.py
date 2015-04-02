#!/opt/Python/2.7.3/bin/python
import sys
from collections import defaultdict
import numpy as np
import re
import os
import argparse
from Bio import SeqIO
from Bio import AlignIO
import glob


def usage():
    test="name"
    message='''
python ../../bin/step4_ortholog_dm_clean_maf.py

    '''
    print message

def fasta_id(fastafile):
    fastaid = defaultdict(str)
    for record in SeqIO.parse(fastafile,"fasta"):
        fastaid[record.id] = 1
    return fastaid

def update_flag(flag, ref_d, tar_d):
    if ref_d < 200000 and tar_d < 200000 and flag == 0:
        flag = 0
    elif ref_d > 200000 and tar_d < ref_d + 2000000 and flag == 0:
        flag = 0
    elif ref_d < 200000 and tar_d > 200000 and flag == 0:
        flag = 1
    #if tar_d > ref_d + 500000 and flag == 0:
    #    flag = 1
    return flag

def readtable(infile):
    data = defaultdict(str)
    with open (infile, 'r') as filehd:
        for line in filehd:
            line = line.rstrip()
            if len(line) > 2: 
                unit = re.split(r'\t',line)
                if not data.has_key(unit[0]):
                    data[unit[0]] = unit[1]
    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input')
    parser.add_argument('-o', '--output')
    parser.add_argument('-v', dest='verbose', action='store_true')
    args = parser.parse_args()

    chrsize = defaultdict(lambda : int())
    data = defaultdict(lambda : int())
    other= defaultdict(lambda : int())
    outdir = 'ortholog_maf_dm_clean'
    if not os.path.exists(outdir):
        os.mkdir(outdir)
    maf_raw = glob.glob('./ortholog_maf_clean/*.axt.chain.prenet.net.axt.maf')
    s = re.compile(r'(\d+)$')
    print 'Clean_maf\tNumOfAlign'
    for maf in sorted(maf_raw):
        #print maf
        aligns       = AlignIO.parse(maf, 'maf')
        aligns_new   = '%s/%s' %(outdir, os.path.split(maf)[-1])
        aligns_clean = []

        #determine start point of orthologous region on chromosome
        sample    = 200
        start_q_0 = 20000000
        start_t_0 = 20000000
        count     = 0
        for align in aligns:
            count += 1
            if count > sample:
                break
            chr_qry = s.search(align[0].id).groups(0)[0] if s.search(align[0].id) else 'NA'
            chr_tar = s.search(align[1].id).groups(0)[0] if s.search(align[1].id) else 'NA'
            start_q = align[0].annotations['start']
            start_t = align[1].annotations['start']
            if int(chr_qry) == int(chr_tar):
                if int(start_t) < start_t_0:
                    start_t_0 = int(start_t)
                    start_q_0 = int(start_q)
        print start_q_0, start_t_0
       
        #dynamic programming of identification of orthologous alignment
        max_interval = 4000000 # we allow adjacent orthologous region to have less than 500 kb interval
        aligns       = AlignIO.parse(maf, 'maf')
        flag         = 0 # allowed for backward
        for align in aligns:
            chr_qry = s.search(align[0].id).groups(0)[0] if s.search(align[0].id) else 'NA'
            chr_tar = s.search(align[1].id).groups(0)[0] if s.search(align[1].id) else 'NA'
            start_q = align[0].annotations['start']
            start_t = align[1].annotations['start']
            size_q  = align[0].annotations['size']
            size_t  = align[1].annotations['size']
            strand  = align[1].annotations['strand']
            if not chrsize.has_key(chr_qry):
                chrsize[chr_qry] = align[0].annotations['srcSize']
            print '>%s\t%s\t%s\t%s\t%s' %(chr_qry, chr_tar, start_q, start_t, strand)
            
            if int(chr_qry) == int(chr_tar) and strand == '+1' and int(start_q) >= int(start_q_0):
                ref_d = abs(int(start_q) - int(start_q_0))
                tar_d = abs(int(start_t) - int(start_t_0))
                ##orthologous alignment
                print '%s\t%s\t%s\t%s\t%s' %(chr_qry, chr_tar, start_q, start_t, flag)
                ##small step, not allowed to backward
                if flag == 0:
                    #allowed to backward within 200kb
                    #if int(start_t) < int(start_t_0) - 200000:
                    #    print 'flag0 no'
                    #    other[chr_qry] += size_q
                    #    continue
                    if (tar_d < ref_d + max_interval):
                        aligns_clean.append(align)
                        data[chr_qry] += size_q
                        start_q_0 = int(start_q)
                        start_t_0 = int(start_t)
                        flag = update_flag(int(flag), int(ref_d), int(tar_d))
                        print 'flag0 yes'
                    else:
                        print 'flag0 no'
                        other[chr_qry] += size_q
                ##previous step is large, allowed for backward
                elif flag == 1:
                    if (tar_d < ref_d + max_interval):
                        aligns_clean.append(align)
                        data[chr_qry] += size_q
                        if int(start_t) < int(start_t_0):
                            flag = 0
                        start_q_0 = int(start_q)
                        start_t_0 = int(start_t)
                        print 'flag1 yes'
                    else:
                        print 'flag1 no'
                        other[chr_qry] += size_q
                #if ref_d < 100000 and tar_d < 1000000 and flag == 0:
                #    flag = 0
                #elif ref_d < 100000 and tar_d > 100000 and flag == 0:
                #    flag = 1
                #if (tar_d < ref_d + max_interval):
                #    aligns_clean.append(align)
                #    data[chr_qry] += size_q
                #    start_q_0 = int(start_q)
                #    start_t_0 = int(start_t)
                ##not orthologous alignment
                #else:
                #    other[chr_qry] += size_q
            ##not orthologous alignment
            else:
                other[chr_qry] += size_q
                
        count     = AlignIO.write(aligns_clean, aligns_new, 'maf')
        print aligns_new, count
    print 'Chr\tSize\tAlignedSize\tAlignedRate\tRawAlignedRate'
    total   = 0
    aligned = 0
    aligned_o = 0
    for c in sorted(chrsize.keys()):
        print 'Chr%s\t%s\t%s\t%s\t%s' %(c, chrsize[c], data[c], float(data[c])/float(chrsize[c]), (float(data[c])+float(other[c]))/float(chrsize[c]))
        total     += int(chrsize[c])
        aligned   += int(data[c])
        aligned_o += int(other[c])
    print 'Total\t%s\t%s\t%s\t%s' %(total, aligned, float(aligned)/float(total), (float(aligned) + float(aligned_o))/float(total))

if __name__ == '__main__':
    main()

