#!/bin/bash
# This script generates an XMFA file for whole genome sequences and multi-fasta files for individual genes
# which have been aligned to a reference created with ViralMSA
# Script by Asher Preska Steinberg (apsteinberg@nyu.edu).
# Usage is described in the README.md file

seq_fasta=$1
ref_genome=$2
ref_gff=$3
output_dir=$4
output_prefix=$5

#step 1: align using ViralMSA
ViralMSA.py -s ${seq_fasta} -r ${ref_genome} -e EMAIL -o viralmsa_output

#step 2: split the aligned multi-fasta file into files for each consensus genome
python3 split_fasta.py ./ viralmsa_output/${seq_fasta}.aln

#step 3: make xmfa for all gene alignments
mkdir -p ${output_dir}
CollectGeneAlignments genomefile_list ${ref_gff} aligned_genomes ${output_dir}/${output_prefix}.xmfa --progress --appendix=".fa"

#step 4: remove the redundant orf1a region (overlaps w/ orf1ab)
python3 remove_extragene.py ${output_dir} ${output_dir}/${output_prefix}.xmfa

#step 5: prepare single gene multi-fasta files (with suffix .xmfa) for use with mcorr-gene-aln
geneMSA ${output_dir}/${output_prefix}.xmfa --outdir=${output_dir}/genes

