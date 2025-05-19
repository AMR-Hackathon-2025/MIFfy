#!/usr/bin/env python

from collections import defaultdict
from Bio import SeqIO
import sys
import argparse
import re
import os

def valid_directory(path):
    if not os.path.isdir(path):
        raise argparse.ArgumentTypeError(f"Directory does not exist: '{path}'")
    return path


def commandline():
    parser = argparse.ArgumentParser(
        description='De-duplicate fasta sequence and output a table including count of duplicated sequences.'
    )
    parser.add_argument(
        '--fasta',
        '-f',
        type=argparse.FileType('r'),
        required=True,
        help='FASTA sequence to de-duplicate.',
    )
    parser.add_argument(
        '--output_dir',
        '-o',
        help='Output directory for de-duplicated sequence.',
        type=valid_directory,
        required=True,
    )
    args = parser.parse_args()
    return args

def deduplicate_fasta(input_fasta, output_dir):

    output_fasta = os.path.join(output_dir, os.path.basename(input_fasta).split('.')[0], str('.deduplicated.fasta'))
    summary_table = os.path.join(output_dir,  os.path.basename(input_fasta).split('.')[0], str('.duplication_counts.fasta'))

    seq_counts = defaultdict(list)  # sequence -> list of headers

    # Read and group by sequence
    for record in SeqIO.parse(input_fasta, "fasta"):
        sequence = str(record.seq).upper()
        seq_counts[sequence].append(record.id)

    # Write de-duplicated FASTA
    with open(output_fasta, "w") as out_fasta, open(summary_table, "w") as out_table:
        out_table.write("Representative_Header\tDuplicate_Count\tAll_Headers\n")
        for i, (sequence, headers) in enumerate(seq_counts.items(), 1):
            rep_header = headers[0]
            count = len(headers)
            SeqIO.write(
                SeqIO.SeqRecord(seq=sequence, id=rep_header, description=f"deduplicated_{count}x"),
                out_fasta,
                "fasta"
            )
            out_table.write(f"{rep_header}\t{count}\t{','.join(headers)}\n")



def main():
    args = commandline()
    deduplicate_fasta(args.input_fasta, args.output_dir)

if __name__ == '__main__':
    main()
