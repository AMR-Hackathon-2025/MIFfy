import simplesam
from Bio import SeqIO
from collections import defaultdict
import re
import os
import argparse

def parse_cigar(cigar):
    """Parse CIGAR string into a list of (length, operation) tuples."""
    if not cigar:
        return []
    return [(int(length), op) for length, op in re.findall(r'(\d+)([A-Za-z])', cigar)]

def calculate_coverage(read_start, read_end, read_length):
    """Calculate coverage percentage of the read with bounds checking."""
    read_start = max(0, min(read_start, read_length))
    read_end = max(0, min(read_end, read_length))
    aligned_length = max(0, read_end - read_start)
    return min(100.0, (aligned_length / read_length) * 100) if read_length > 0 else 0.0

def create_sequence_db(fasta_file):
    """Create a dictionary database from a FASTA file."""
    sequence_db = {}
    try:
        for record in SeqIO.parse(fasta_file, "fasta"):
            sequence_db[record.id] = {
                'sequence': str(record.seq),
                'description': record.description,
                'length': len(record.seq)
            }
        print(f"Created sequence database with {len(sequence_db)} records")
        return sequence_db
    except Exception as e:
        print(f"Error parsing FASTA file: {str(e)}")
        raise

def process_sam_file(sam_file, sequence_db, output_dir):
    """Process SAM file and generate coverage reports."""
    counts = defaultdict(int)
    read_info = defaultdict(list)
    ref_lengths = {}
    
    base_name = os.path.splitext(os.path.basename(sam_file))[0]
    tsv_file = os.path.join(output_dir, f"{base_name}_alignments.tsv")
    enriched_tsv = os.path.join(output_dir, f"{base_name}_enriched_alignments.tsv")

    with open(sam_file) as f:
        # First pass to get reference lengths from header
        header_lines = []
        for line in f:
            if line.startswith('@SQ'):
                header_lines.append(line.strip())
            elif not line.startswith('@'):
                break
        
        # Parse SQ lines to get reference lengths
        for line in header_lines:
            if line.startswith('@SQ'):
                parts = dict(p.split(':', 1) for p in line.split('\t')[1:])
                ref_name = parts.get('SN', '')
                ref_len = int(parts.get('LN', 0))
                if ref_name:
                    ref_lengths[ref_name] = ref_len
        
        # Reset file pointer for second pass
        f.seek(0)
        reader = simplesam.Reader(f)
        
        with open(tsv_file, 'w') as out_f, open(enriched_tsv, 'w') as enriched_f:
            # Write headers
            out_f.write("Read_ID\tReference\tRef_Length\tRef_Position\tRead_Start\tRead_End\tCoverage(%)\n")
            enriched_f.write("Read_ID\tReference\tRef_Length\tRef_Position\tRead_Start\tRead_End\tCoverage(%)\tRef_Sequence\n")
            
            for read in reader:
                if not read.mapped:
                    continue

                counts[read.rname] += 1
                read_length = getattr(read, 'length', len(read.seq))
                read_start = 0
                read_end = read_length
                
                cigar_ops = parse_cigar(getattr(read, 'cigar', ''))
                if cigar_ops and cigar_ops[0][1] == 'S':
                    read_start = cigar_ops[0][0]
                if cigar_ops and cigar_ops[-1][1] == 'S':
                    read_end = read_length - cigar_ops[-1][0]
                
                coverage = calculate_coverage(read_start, read_end, read_length)
                
                # Get reference information
                ref_len = sequence_db.get(read.rname, {}).get('length', 
                           ref_lengths.get(read.rname, 0))
                ref_seq = sequence_db.get(read.rname, {}).get('sequence', 'N/A')
                
                # Get reference sequence segment
                ref_segment = 'N/A'
                if ref_seq != 'N/A' and read.pos and read.pos > 0:
                    end_pos = read.pos + (read_end - read_start)
                    ref_segment = ref_seq[read.pos-1:end_pos-1]
                
                # Write basic record
                record = (
                    read.qname, read.rname, str(ref_len),
                    str(read.pos), str(read_start + 1),
                    str(read_end), f"{coverage:.2f}"
                )
                out_f.write("\t".join(record) + "\n")
                
                # Write enriched record
                enriched_record = record + (ref_segment,)
                enriched_f.write("\t".join(enriched_record) + "\n")
                
                read_info[read.rname].append(record)

    print(f"\nAlignment counts per reference:")
    for rname, count in sorted(counts.items()):
        ref_len = sequence_db.get(rname, {}).get('length', 
                 ref_lengths.get(rname, "unknown"))
        print(f"{rname} (length: {ref_len}): {count} alignments")

    return {
        'basic_tsv': tsv_file,
        'enriched_tsv': enriched_tsv,
        'counts': dict(counts)
    }

def main():
    parser = argparse.ArgumentParser(
        description="Process SAM files and calculate alignment coverage percentages",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('-s', '--sam', required=True, help="Input SAM file")
    parser.add_argument('-f', '--fasta', required=True, help="Reference FASTA file")
    parser.add_argument('-o', '--output', default='.', help="Output directory")
    
    args = parser.parse_args()
    
    # Verify inputs
    if not os.path.exists(args.sam):
        raise FileNotFoundError(f"SAM file not found: {args.sam}")
    if not os.path.exists(args.fasta):
        raise FileNotFoundError(f"FASTA file not found: {args.fasta}")
    
    # Create output directory if needed
    os.makedirs(args.output, exist_ok=True)
    
    print(f"\nProcessing SAM file: {args.sam}")
    print(f"Using reference: {args.fasta}")
    print(f"Output directory: {args.output}")
    
    # Create sequence database
    sequence_db = create_sequence_db(args.fasta)
    
    # Process SAM file
    results = process_sam_file(args.sam, sequence_db, args.output)
    
    print("\nProcessing complete!")
    print(f"Basic alignment results saved to: {results['basic_tsv']}")
    print(f"Enriched alignment results saved to: {results['enriched_tsv']}")

if __name__ == "__main__":
    main()