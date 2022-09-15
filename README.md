In this example, we'll show you how to prepare whole genome alignments and 
single gene alignments for use with *viral-mcorr*. We will be working with the set of 191 SARS-like coronavirus whole genome sequences
used in our paper (link [here](https://www.biorxiv.org/content/10.1101/2022.08.26.505425v1)). These were also used as the basis to create the *Nextstrain* build 
for SARS-like betacoronaviruses [https://nextstrain.org/groups/blab/sars-like-cov](https://nextstrain.org/groups/blab/sars-like-cov).

0. To get started, follow the instructions [link will go here] to install `viral-mcorr` and download or clone this repository.
You will also need to install ViralMSA: [https://github.com/niemasd/ViralMSA](https://github.com/niemasd/ViralMSA). 
   We used Minimap2 [https://github.com/lh3/minimap2](https://github.com/lh3/minimap2)
   to perform the alignment (as recommended by ViralMSA). You will also need to download
   this GitHub repository to your computer as well as install an in-house program we built to make XMFA files:

```sh
cd ~/Downloads
git clone https://github.com/kussell-lab/virus_alignment_example.git
cd virus_alignment_example/geneMSA
go install .
go install github.com/kussell-lab/ReferenceAlignmentGenerator/CollectGeneAlignments@latest
```
1. The unaligned sequences are provided in the file "sequences.fasta" take them, and align them to the NCBI reference
genome for SARS-CoV-2, provided in this repository and also [here](https://www.ncbi.nlm.nih.gov/nuccore/NC_045512).
   You can do this using the following commandline prompt:
   ```sh
   ViralMSA.py -s sequences.fasta -r ncbi_reference/GCF_009858895.2_ASM985889v3_genomic.fasta -e EMAIL -o viralmsa_output
   ```
2. Take the aligned genomes, then split them into separate files for each consensus genome using split_fasta.py
```sh
python3 split_fasta.py ./ viral_msa_output/sequences.fasta.aln
```
3. Use CollectGeneAlignments to make an XMFA file for the genomes
```sh
CollectGeneAlignments genomefile_list ncbi_reference/GCF_009858895.2_ASM985889v3_genomic.gff aligned_genomes aligned_sl-cov.xmfa --progress --appendix=".fa"
```
4. Remove orf1a CDS region (overlaps with the orf1ab region, and throws off `mcorrViralGenome` and `mcorrLDGenome`, 
   which assemble all CDS regions into one continuous coding sequence before it begins analysis)
```sh
python3 remove_extragene.py ./ aligned_sl-cov.xmfa
```
5. At this point `aligned_sl-cov.xmfa` is ready for use with `mcorrViralGenome` and `mcorrLDGenome`. 
To prepare single gene multi-fasta files for use with `mcorr-gene-aln`, just use the following commands:
```sh
geneMSA aligned_sl-cov.xmfa
```
This will output alignments for single genes into the folder `genes`
## Shortcuts
The TL;DR version is you can replicate the above steps by executing the shell script in this repository `align_viralgenomes.sh`:
```sh
bash align_viralgenomes.sh <sequences fasta> <reference fasta> <reference gff> <outdir> <out prefix>
```
* `sequences fasta` is the fasta file containing the unaligned sequences.
* `reference fasta` is the fasta file of the reference genome
* `reference gff` is the GFF3 file for the reference genome
* `outdir` is the output directory for the aligned xmfa files for all genes and single genes
* `out prefix` is the prefix for the xmfa file of whole genome alignments

To run through the example with the shell script use the following commandline prompts:
```sh
cd ~/Downloads
cd sars-like_cov_alignment_example
bash align_viralgenomes.sh sequences.fasta ncbi_reference/GCF_009858895.2_ASM985889v3_genomic.fasta ncbi_reference/GCF_009858895.2_ASM985889v3_genomic.gff example_out aligned_sl-cov
```