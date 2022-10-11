version 1.0

import "../tasks/task_versioning.wdl" as versioning
import "../tasks/task_pub_repo_prep.wdl" as submission_prep
import "../tasks/task_checktype.wdl" as checktype

workflow mercury_pe_prep {
  input {
    # Required Files
    File read1
    File read2
    # Required Metadata (TheiaCoV GC Outputs)
    String sample_id
    # Required Metadata (User Inputs)
    #String collection_date
    String filetype = "fastq"
    String instrument_model = "Illumina MiSeq"
    String library_layout = "paired"
    String library_selection = "RANDOM"
    String library_source = "GENOMIC"
    String library_strategy = "WGS"
    String organism
    String seq_platform = "ILLUMINA"
    String geo_loc_name = "USA:CA"
    String lat_lon = "missing"
    String county_id = "CA-Contra Costa"
    String design_description = "MiSeq Nextera XT shotgun sequencing of cultured isolate"
    Int n50_value
    Float est_coverage
    #Float campylobacter_min_coverage = 20
    #Float salmonella_min_coverage = 30
    #Float? min_coverage = 0
    String isolation_source
    # Optional Metadata
    String? biosample_accession
    String? serovar
    # Optional User-Defined Thresholds for Generating Submission Files
    Int n50_value_threshold = 25000
  }

  call checktype.checktype {
    input:
      sample_id = sample_id,
      organism = organism,
  }

  if (n50_value >= n50_value_threshold) {
    if (est_coverage >= checktype.min_coverage) {
      call submission_prep.ncbi_prep_one_sample {
        input:
          biosample_accession = biosample_accession,
          filetype = filetype,
          instrument_model = instrument_model,
          library_layout = library_layout,
          library_selection = library_selection,
          library_source = library_source,
          library_strategy = library_strategy,
          organism = organism,
          serovar = serovar,
          read1 = read1,
          read2 = read2,
          seq_platform = seq_platform,
          sample_id = sample_id,
          geo_loc_name = geo_loc_name,
          lat_lon = lat_lon,
          county_id = county_id,
          design_description = design_description,
          isolation_source = isolation_source,
      }
    }
  }
 
  call versioning.version_capture{
    input:
  }

  output {
    # Version Capture
    Float min_coverage = checktype.min_coverage
    String mercury_pe_prep_version = version_capture.phbg_version
    String mercury_pe_prep_analysis_date = version_capture.date
    # NCBI Submission Files
    File? biosample_attributes = ncbi_prep_one_sample.biosample_attributes
    File? sra_metadata = ncbi_prep_one_sample.sra_metadata
    File? sra_read1 = ncbi_prep_one_sample.sra_read1
    File? sra_read2 = ncbi_prep_one_sample.sra_read2
    Array[File]? sra_reads = ncbi_prep_one_sample.sra_reads
  }
}