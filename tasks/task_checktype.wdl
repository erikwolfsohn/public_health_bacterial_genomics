  task checktype {
    
    input {
      String sample_id
      #String organism
    }

    command <<<
    #SAMPLETYPE = echo ~{organism} | sed 's/ .*//' > ~{sample_id}_sampletype.txt

    if (echo ~{sample_id} | grep -i -- "-S";)
    then
      MIN_COV="30"
    elif (echo ~{sample_id} | grep -i -- "-C";)
    then
      MIN_COV="20"
    else
      MIN_COV="1000"
    fi
    echo "~{MIN_COV}" > ~{sample_id}_min_coverage.txt

    >>>

    output {
      #File sample_type_file = "~{sample_id}_sampletype.txt"
      #String sample_type = read_string("~{sample_id}_sampletype.txt")
      Float min_coverage = read_float("~{sample_id}_min_coverage.txt")
    }

  }
