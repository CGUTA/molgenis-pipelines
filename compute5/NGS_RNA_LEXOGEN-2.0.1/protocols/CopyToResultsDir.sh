#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping

#string projectResultsDir
#string project
#string intermediateDir
#string projectLogsDir
#string projectrawdatadir
#string projectQcDir
#string projectJobsDir
#string expressionTable
#string annotationGtf
#string fastqcVersion
#string samtoolsVersion
#string picardVersion
#string anacondaVersion
#string starVersion
#string htseqVersion
#string indexFileID

# Change permissions

umask 0007

# Make result directories
mkdir -p ${projectResultsDir}/alignment
mkdir -p ${projectResultsDir}/fastqc
mkdir -p ${projectResultsDir}/expression
mkdir -p ${projectResultsDir}/expression/perSampleExpression
mkdir -p ${projectResultsDir}/expression/expressionTable
mkdir -p ${projectResultsDir}/images

# Copy error, out and finished logs to project jobs directory

cp ${projectJobsDir}/*.out ${projectLogsDir}
cp ${projectJobsDir}/*.err ${projectLogsDir}
cp ${projectJobsDir}/*.log ${projectLogsDir}

# Copy project csv file to project results directory

cp ${projectJobsDir}/${project}.csv ${projectResultsDir}

# Copy fastQC output to results directory

	cp ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/fastqc



# Copy BAM plus index plus md5 sum to results directory

	cp ${intermediateDir}/*.Aligned.out.sorted.bam ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.Aligned.out.sorted.bam.md5 ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.Aligned.out.sorted.bai ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.Log.out ${projectResultsDir}/alignment

# copy GeneCounts to results directory

	cp ${intermediateDir}/*.htseq.txt ${projectResultsDir}/expression/perSampleExpression
	cp ${expressionTable} ${projectResultsDir}/expression/expressionTable
	cp ${annotationGtf} ${projectResultsDir}/expression/
	
# Copy QC images and report to results directory

	cp ${intermediateDir}/*.collectrnaseqmetrics.png ${projectResultsDir}/images
	cp ${intermediateDir}/*.GC.png ${projectResultsDir}/images
	cp ${projectQcDir}/${project}_QCReport.pdf ${projectResultsDir}

#only available with PE
	if [ -f "${intermediateDir}/*.insertsizemetrics.pdf" ]
	then
		cp ${intermediateDir}/*.insertsizemetrics.pdf ${projectResultsDir}/images
	fi


# write README.txt file

cat > ${projectResultsDir}/README.txt <<'endmsg'

Patrick Deelen
Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands
Please use both affiliations

Description of the different steps used in the RNA analysis pipeline

Gene expression quantification
The trimmed fastQ files where aligned to build 37 human reference genome using Bowtie 2.1.0 [1] 
allowing for 2 mismatches. Before gene quantification SAMtools 0.1.18 [2] was used to sort 
the aligned reads. The gene level quantification was performed by HTSeq-0.5.4 [3] 
using --mode=union --stranded=no and, Ensembl version 71 was used as gene annotation database.

Calculate QC metrics on raw and aligned data
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using 
the tool FastQC ${fastqcVersion} [4]. QC metrics are calculated for the aligned reads using 
Picard-tools ${picardVersion} [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and SAMtools ${samtoolsVersion} flagstat.

Results archive
The zipped archive contains the following data and subfolders:

- alignment: merged BAM file with index, md5sums and alignment statistics (.Log.final.out)
- expression: textfiles with gene level quantification per sample and per project. 
- fastqc: FastQC output
- images: QC images
- rawdata: raw sequence file in the form of a gzipped fastq file (.fq.gz)

The root of the results directory contains the final QC report, and the samplesheet which 
were the basis for this analysis. 


1. Langmead, Ben, and Steven L. Salzberg. Fast gapped-read alignment with Bowtie 2. 
Nature methods 9.4 (2012): 357-359.
2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,
Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.
Bioinforma 2009, 25 (16):2078–2079.
3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data
HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.
4. Andrews, S. (2010). FastQC a Quality Control Tool for High Throughput Sequence Data [Online]. 
Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ ${samtoolsVersion}
5. Picard Sourceforge Web site. http://picard.sourceforge.net/ ${picardVersion}

endmsg

# Create zip file for all "small text" files

cd ${projectResultsDir}

zip -gr ${projectResultsDir}/${project}.zip fastqc
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
zip -gr ${projectResultsDir}/${project}.zip alignment
zip -gr ${projectResultsDir}/${project}.zip expression
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.pdf
zip -g ${projectResultsDir}/${project}.zip README.txt

# Create md5sum for zip file

cd ${projectResultsDir}
md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5

# add u+rwx,g+r+w rights for GAF group

chmod -R u+rwX,g+rwX ${projectResultsDir}
chmod -R g+rwX ${intermediateDir}
