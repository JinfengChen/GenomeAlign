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
python ../../bin/step4_ortholog_clean_maf.py

    '''
    print message

def fasta_id(fastafile):
    fastaid = defaultdict(str)
    for record in SeqIO.parse(fastafile,"fasta"):
        fastaid[record.id] = 1
    return fastaid


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
    outdir = 'ortholog_maf_clean'
    if not os.path.exists(outdir):
        os.mkdir(outdir)
    maf_raw = glob.glob('./ortholog_maf/*.axt.chain.prenet.net.axt.maf')
    s = re.compile(r'(\d+)$')
    print 'Clean_maf\tNumOfAlign'
    for maf in sorted(maf_raw):
        #print maf
        aligns       = AlignIO.parse(maf, 'maf')
        aligns_new   = '%s/%s' %(outdir, os.path.split(maf)[-1])
        aligns_clean = []
        for align in aligns:
            chr_qry = s.search(align[0].id).groups(0)[0] if s.search(align[0].id) else 'NA'
            chr_tar = s.search(align[1].id).groups(0)[0] if s.search(align[1].id) else 'NA'
            start_q = align[0].annotations['start']
            start_t = align[1].annotations['start']
            size_q  = align[0].annotations['size']
            size_t  = align[1].annotations['size']
            if not chrsize.has_key(chr_qry):
                chrsize[chr_qry] = align[0].annotations['srcSize']
            #print '%s\t%s\t%s\t%s' %(chr_qry, chr_tar, start_q, start_t)
            if int(chr_qry) == int(chr_tar) and abs(int(start_q) - int(start_t)) < 15000000:
                aligns_clean.append(align)
                data[chr_qry] += size_q
            else:
                other[chr_qry] += size_q
            #for rec in align:
            #    print rec.id
            #    print rec.annotations['start']
            #    print rec.annotations['size']
            #    print rec.annotations['strand']
            #    print rec.annotations['srcSize']
                
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

