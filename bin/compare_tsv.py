#!/usr/bin/env python

import sys
import os
import argparse
from datetime import datetime
import tsv

def load_tsv(tsv_file):
    reads = defaultdict()
    header = None
    with open(tsv_file, newline='', delimiter='\t') as tsvfile:
        reader = tsv.DictReader(tsvfile)
        for row in reader:
            if "Cassette_ID" in row:
                row["ReadID_CassetteID_Combined"] = row["ReadID"] + "_" + row["Cassette_ID"]
            elif "Reference" in row:
                row["ReadID_CassetteID_Combined"] = row["ReadID"] + "_" + row["Reference"]
            else:
                sys.exit("Unexpected columns")
            reads.append(row)
        header = reader.fieldnames()
    return header, reads

def compare_contents(content1, content2):
    lookup = defaultdict(lambda: defaultdict())
    for row in content2:
        lookup[row["ReadID_CassetteID_Combined"]] = row
    for row in content1:
        if row["ReadID_CassetteID_Combined"] in lookup:
            row.update(lookup[row["ReadID_CassetteID_Combined"]])
            row["Verified"] = True
        lookup[row["ReadID_CassetteID_Combined"]]["found"] = True
    for id, entry in lookup.iteritems():
        if "found" not in entry:
            content2[id] = entry
    return content2

def combine_tsv(tsv1, tsv2):
    header1, content1 = load_tsv(tsv1)
    header1, content2 = load_tsv(tsv2)

    combined_headers = header1
    for field in header2:
        if field not in header1:
            combined_headers.append(field)
    
    combined_content = compare_contents(content1, content2)

    # split by read_id
    read_ids = set([row["ReadID"] for row in combined_content])
    for read_id in read_ids:
        with open(f"{read_id}.tsv", "r") as outfile:
            writer = csv.DictWriter(csvfile, fieldnames=combined_headers, delimiter="\t")
            writer.writeheader()
            for row in combined_content:
                if row["ReadID"] == read_id:
                    writer.writerow(row)


# Main method
def main():
    # Parse arguments
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--bakta_tsv",
        dest="bakta_tsv",
        required=True,
        help="TSV output from bakta pipeline",
    )
    parser.add_argument(
        "--minimap_tsv",
        dest="minimap_tsv",
        required=True,
        help="TSV output from minimap2 pipeline",
    )

    args = parser.parse_args()

    # Start Program
    now = datetime.now()
    time = now.strftime("%m/%d/%Y, %H:%M:%S")
    sys.stderr.write("PROGRAM START TIME: " + time + "\n")

    combine_tsv(args.bakta_tsv, args.minimap_tsv)

    now = datetime.now()
    time = now.strftime("%m/%d/%Y, %H:%M:%S")
    sys.stderr.write("PROGRAM END TIME: " + time + "\n")

    sys.exit(0)


if __name__ == "__main__":
    main()