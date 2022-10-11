  version 1.0

  task checktype {
    
    input {
      String sample_id
      String docker = "quay.io/theiagen/utility:1.1"
      Int memory = 8
      Int cpu = 2
      Int disk_size = 50
      Int preemptible = 0
      String organism
    }

    command <<<
    SAMPLETYPE=$(echo ~{organism} | sed 's/ .*//')
    if [ "$SAMPLETYPE" == "Salmonella" ]
    then
      MIN_COV="30"
    elif [ "$SAMPLETYPE" == "Campylobacter" ]
    then
      MIN_COV="20"
    else
      MIN_COV="1000"
    fi
    echo "${MIN_COV}" > ~{sample_id}_min_coverage.txt
    >>>

    output {
      #File sample_type_file = "~{sample_id}_sampletype.txt"
      #String sample_type = read_string("~{sample_id}_sampletype.txt")
      Float min_coverage = read_float("~{sample_id}_min_coverage.txt")
    }

    runtime {
    docker: docker
    memory: "~{memory} GB"
    cpu: cpu
    disks: "local-disk ~{disk_size} SSD"
    preemptible: preemptible
    maxRetries: 3
  }

}
