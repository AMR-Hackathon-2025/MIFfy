import csv
from Bio import SeqIO

# {chrom_name: {integron_id:, start:, end:}}
integron_dict = {}

with open("${integrons}", "r") as f:
    next(f)  # Skip the header
    next(f)  # Skip the header
    reader = csv.DictReader(f, delimiter="\t")
    for row in reader:
        integron_dict.setdefault(row["ID_replicon"], {})
        integron_dict[row["ID_replicon"]].setdefault("start", False)
        integron_dict[row["ID_replicon"]].setdefault("end", False)
        integron_dict[row["ID_replicon"]].setdefault("integron_id", row["ID_integron"])

        if not integron_dict[row["ID_replicon"]]["start"]:
            integron_dict[row["ID_replicon"]]["start"] = int(row["pos_beg"])

        if not integron_dict[row["ID_replicon"]]["end"]:
            integron_dict[row["ID_replicon"]]["end"] = int(row["pos_end"])

        if int(row["pos_beg"]) < integron_dict[row["ID_replicon"]]["start"]:
            integron_dict[row["ID_replicon"]]["start"] = int(row["pos_beg"])

        if int(row["pos_end"]) > integron_dict[row["ID_replicon"]]["end"]:
            integron_dict[row["ID_replicon"]]["end"] = int(row["pos_end"])

out_records = []

with SeqIO.parse("${fasta}", "fasta") as fasta_fh:
    for record in fasta_fh:
        if integron_dict.get(record.id):
            header = f">{record.id}_{integron_dict[record.id]['start']}_{integron_dict[record.id]['end']}"
            slice = record.seq[
                integron_dict[record.id]["start"] - 1 : integron_dict[record.id]["end"]
            ]
            out_records.append((header, slice))

for header, seq_slice in out_records:
    with open("output.fasta", "a") as f:
        print(f">{header}", file=f)
        print(seq_slice, file=f)


with open("output.tsv", "a") as f:
    print("chrom\tstart\tend\tintegron_id", file=f)
    for chrom, data in integron_dict.items():
        print(f"{chrom}\t{data['start']}\t{data['end']}\t{data['integron_id']}", file=f)
