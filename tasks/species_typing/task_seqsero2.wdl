version 1.0

task seqsero2_pe {
  # Inputs
  input {
    File read1
    File read2
    String samplename
    String mode ="a"
    String seqsero2_docker_image = "quay.io/staphb/seqsero2:1.2.1"
  }

  command <<<
    # capture date and version
    # Print and save date
    date | tee DATE
    # Print and save version
    SeqSero2_package.py --version | tee VERSION
    # Run SeqSero2 on the input read data
    SeqSero2_package.py \
    -p 8 \
    -t 2 \
    -m ~{mode} \
    -n ~{samplename} \
    -d ~{samplename}_seqseqro2_output_dir \
    -i ~{read1} ~{read2}
    # Run a python block to parse output file for terra data tables
    python3 <<CODE
    import csv
    with open("./~{samplename}_seqseqro2_output_dir/SeqSero_result.tsv",'r') as tsv_file:
      tsv_reader=csv.reader(tsv_file, delimiter="\t")
      tsv_data=list(tsv_reader)
      tsv_dict=dict(zip(tsv_data[0], tsv_data[1]))
      with open ("PREDICTED_ANTIGENIC_PROFILE", 'wt') as Predicted_Antigen_Prof:
        pred_ant_prof=tsv_dict['Predicted antigenic profile']
        Predicted_Antigen_Prof.write(pred_antigen_prof)
      with open ("PREDICTED_SEROTYPE", 'wt') as Predicted_Sero:
        pred_sero=tsv_dict['Predicted serotype']
        Predicted_Sero.write(pred_sero)
      with open ("CONTAMINATION", 'wt') as Contamination_Detected:
        cont_detect=tsv_dict['Potential inter-serotype contamination']
        if not cont_detect:
          cont_detect="None"
        Contamination_Detected.write(cont_detect)
    CODE
  >>>
  output {
    File seqsero2_report = "./~{samplename}_seqseqro2_output_dir/SeqSero_result.tsv"
    String seqsero2_version = read_string("VERSION")
    String seqsero2_predicted_antigenic_profile = read_string("PREDICTED_ANTIGENIC_PROFILE")
    String seqsero2_predicted_serotype = read_string("PREDICTED_SEROTYPE")
    String seqsero2_predicted_contamination = read_string("CONTAMINATION")
  }
  runtime {
    docker:       "~{seqsero2_docker_image}"
    memory:       "16 GB"
    cpu:          8
    disks:        "local-disk 100 SSD"
    preemptible:  0
    maxRetries:   3
  }
}