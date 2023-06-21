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
    String input_sample_id
    # Required Metadata (User Inputs)
    #String collection_date
    String input_filetype = "fastq"
    String input_instrument_model = "Illumina MiSeq"
    String input_library_layout = "paired"
    String input_library_selection = "RANDOM"
    String input_library_source = "GENOMIC"
    String input_library_strategy = "WGS"
    String input_organism
    String input_seq_platform = "ILLUMINA"
    String input_geo_loc_name = "USA:CA"
    String input_lat_lon = "missing"
    String input_isolation_type = "Environmental"
    String input_county_id = "CA-Contra Costa"
    String input_design_description = "MiSeq Nextera XT shotgun sequencing of cultured isolate"
    Int n50_value
    String submission_prep_docker = "quay.io/theiagen/terra-tools:2023-03-16"
    Float est_coverage
    Float campylobacter_min_coverage = 20
    Float salmonella_min_coverage = 30
    #Float? min_coverage = 0
    String isolation_source
    # Optional Metadata
    String? biosample_accession
    String? input_serovar
    # Optional User-Defined Thresholds for Generating Submission Files
    Int n50_value_threshold = 25000
  }

  call checktype.checktype {
    input:
      sample_id = input_sample_id,
      organism = input_organism,
      campylobacter_min_coverage = campylobacter_min_coverage,
      salmonella_min_coverage = salmonella_min_coverage,
  }

  if (n50_value >= n50_value_threshold) {
    if (est_coverage >= checktype.min_coverage) {
      call submission_prep.ncbi_prep_one_sample {
        input:
          biosample_accession = biosample_accession,
          filetype = input_filetype,
          instrument_model = input_instrument_model,
          library_layout = input_library_layout,
          library_selection = input_library_selection,
          library_source = input_library_source,
          library_strategy = input_library_strategy,
          organism = input_organism,
          serovar = input_serovar,
          read1 = read1,
          read2 = read2,
          seq_platform = input_seq_platform,
          sample_id = input_sample_id,
          geo_loc_name = input_geo_loc_name,
          lat_lon = input_lat_lon,
          county_id = input_county_id,
          design_description = input_design_description,
          isolation_source = isolation_source,
          docker_image = submission_prep_docker
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
    String? bioproject_accession = ncbi_prep_one_sample.bioproject_accession
    String? title = ncbi_prep_one_sample.title
    String? collection_date = ncbi_prep_one_sample.collection_date
    String? host = ncbi_prep_one_sample.host
    String? host_disease = ncbi_prep_one_sample.host_disease
    String? library_ID = ncbi_prep_one_sample.library_ID
    String? library_strategy = "~{input_library_strategy}"
    String? library_source = "~{input_library_source}"
    String? library_selection = "~{input_library_selection}"
    String? library_layout = "~{input_library_layout}"
    String? platform = "~{input_seq_platform}"
    String? instrument_model = "~{input_instrument_model}"
    String? design_description = "~{input_design_description}"
    String? filetype = "~{input_filetype}"
    String? submission_id = "~{input_sample_id}"
    String? organism = "~{input_organism}"
    String? collected_by = "~{input_county_id}"
    String? geo_loc_name = "~{input_geo_loc_name}"
    String? lat_lon = "~{input_lat_lon}"
    String? isolation_type = "~{input_isolation_type}"
    String? strain = "~{input_sample_id}"
    String? serovar = "~{input_serovar}"
  }
}