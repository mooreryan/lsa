require "spec_helper"
require "fileutils"



def same_f f1, f2
  f1.lstat == f2.lstat
end

def compare_label2outf h1, h2
  same_keys = h1.keys == h2.keys

  same_vals = h1.keys.all? { |key| same_f h1[key], h2[key] }

  same_keys && same_vals
end

RSpec.describe Lsa do
  let(:test_file_dir) {
    File.join File.dirname(__FILE__), "..", "test_files"
  }
  let(:klass) { Class.extend Lsa }

  let(:mapping_fname) {
    File.join test_file_dir, "mapping.txt"
  }

  it "has a version number" do
    expect(Lsa::VERSION).not_to be nil
  end

  describe "#parse_mapping_file" do
    it "parses the mapping file" do
      mmseqs_final_outf = "mmseqs_final.txt"

      group_outf =
        File.open(mmseqs_final_outf + ".metadata_group.txt",
                  "w")

      another_group_outf =
        File.open(mmseqs_final_outf + ".metadata_another_group.txt",
                  "w")

      exp_label2outf = {
        "group" => group_outf,
        "another_group" => another_group_outf,
      }

      exp_doc2new_doc = {
        "e_coli_faa_gz" => { "group" => "bacteria",
                             "another_group" => "a"},
        "m_mazei_faa_gz" => { "group" => "archaea",
                              "another_group" => "a" },
        "s_flexneri_faa_gz" => { "group" => "bacteria",
                                 "another_group" => "b" }
      }


      label2outf, doc2new_doc =
                  klass.parse_mapping_file mapping_fname,
                                           mmseqs_final_outf

      expect(compare_label2outf label2outf, exp_label2outf).to be true
      expect(doc2new_doc).to eq exp_doc2new_doc

      FileUtils.rm [group_outf, another_group_outf]
    end
  end

  describe "#make_new_cluster_files" do
    it "makes new cluster files" do
      mmseqs_final_outf =
        File.join test_file_dir, "cluster_file_original.txt"
      group_outf =
        File.open(mmseqs_final_outf + ".metadata_group.txt",
                  "w")

      another_group_outf =
        File.open(mmseqs_final_outf + ".metadata_another_group.txt",
                  "w")

      group_fname =
        File.absolute_path group_outf

      another_group_fname =
        File.absolute_path another_group_outf

      exp_label2outf = {
        "group" => group_outf,
        "another_group" => another_group_outf,
      }

      exp_doc2new_doc = {
        "e_coli_faa_gz" => { "group" => "bacteria",
                             "another_group" => "a"},
        "m_mazei_faa_gz" => { "group" => "archaea",
                              "another_group" => "a" },
        "s_flexneri_faa_gz" => { "group" => "bacteria",
                                 "another_group" => "b" }
      }

      exp_cluster_group_dat =
        File.read(File.join test_file_dir,
                            "cluster_file_group.txt")
      exp_cluster_another_group_dat =
        File.read(File.join test_file_dir,
                            "cluster_file_another_group.txt")

      new_outfnames = klass.make_new_cluster_files mmseqs_final_outf,
                                                   exp_label2outf,
                                                   exp_doc2new_doc

      expect(File.read group_fname).to eq exp_cluster_group_dat
      expect(File.read another_group_fname).to eq exp_cluster_another_group_dat
      expect(new_outfnames).to eq [group_fname, another_group_fname]

      FileUtils.rm [group_fname, another_group_fname]
    end
  end
end
