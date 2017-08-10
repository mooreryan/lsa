require "lsa/version"

require "abort_if"

include AbortIf

module Lsa
  def clean_str str
    str.strip.gsub(/[^\p{Alnum}_]+/, "_").gsub(/_+/, "_")
  end

  def parse_mapping_file mapping_fname, mmseqs_final_outf
    data_labels = []
    label2outf = {}
    doc2new_doc = {}
    File.open(mapping_fname, "rt").each_line.with_index do |line, idx|
      if idx.zero?
        current_label, *data_labels = line.chomp.split("\t").map do |str|
          clean_str str
        end

        abort_if data_labels.any? { |label| label == "original" },
                 "Illegal data label: 'original'. Please change it."

        abort_unless data_labels.uniq.count == data_labels.count,
                     "The data labels are not unique in #{mapping_fname}"

        data_labels.each do |label|
          new_outfname =
            File.join "#{mmseqs_final_outf}.metadata_#{label}.txt"

          label2outf[label] = File.open new_outfname, "w"
        end
      else
        file_name, *data = line.chomp.split("\t").map do |str|
          clean_str str
        end

        abort_unless data_labels.length == data.length,
                     "Number of columns doesn't match for line " +
                     "#{idx + 1}"

        abort_if doc2new_doc.has_key?(file_name),
                 "File #{file_name} is repeated in #{mapping_fname}"

        doc2new_doc[file_name] = {}
        data_labels.each_with_index do |label, idx|
          doc2new_doc[file_name][label] = data[idx]
        end
      end
    end

    [label2outf, doc2new_doc]
  end

  def make_new_cluster_files mmseqs_final_outf, label2outf, doc2new_doc
    File.open(mmseqs_final_outf).each_line do |line|
      centroid, member = line.chomp.split "\t"

      centroid_doc, centroid_seq = centroid.split "~"
      member_doc, member_seq = member.split "~"

      # START HERE write a new line for each label to each label file
      abort_unless doc2new_doc.has_key?(centroid_doc),
                   "Missing #{centroid_doc} from #{doc2new_doc}"

      abort_unless doc2new_doc.has_key?(member_doc),
                   "Missing #{member_doc} from #{doc2new_doc}"

      label2outf.keys.each do |label|
        new_centroid_doc = doc2new_doc[centroid_doc][label]
        new_member_doc = doc2new_doc[member_doc][label]

        new_centroid = "#{new_centroid_doc}~#{centroid_seq}"
        new_member = "#{new_member_doc}~#{member_seq}"
        new_line = "#{new_centroid}\t#{new_member}"

        label2outf[label].puts new_line
      end
    end

    label2outf.each do |label, f|
      f.close
    end

    label2outf.map { |labef, f| File.absolute_path f }
  end
end
