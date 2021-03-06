require 'active_storage_validations/matchers'

describe Champs::PieceJustificativeChamp do
  include ActiveStorageValidations::Matchers

  # TODO: once we're running on Rails 6, re-enable the PieceJustificativeChamp validator,
  # and re-enable this spec.
  #
  # See https://github.com/betagouv/demarches-simplifiees.fr/issues/4926
  describe "validations", pending: true do
    subject(:champ_pj) { build(:champ_piece_justificative) }

    it { is_expected.to validate_size_of(:piece_justificative_file).less_than(Champs::PieceJustificativeChamp::MAX_SIZE) }
    it { is_expected.to validate_content_type_of(:piece_justificative_file).allowing(Champs::PieceJustificativeChamp::ACCEPTED_FORMATS) }
  end

  describe "#for_export" do
    let(:champ_pj) { create(:champ_piece_justificative) }
    subject { champ_pj.for_export }

    it { is_expected.to eq('toto.txt') }

    context 'without attached file' do
      before { champ_pj.piece_justificative_file.purge }
      it { is_expected.to eq(nil) }
    end
  end

  describe '#for_api' do
    let(:champ_pj) { create(:champ_piece_justificative) }
    let(:metadata) { champ_pj.piece_justificative_file.blob.metadata }

    before { champ_pj.piece_justificative_file.blob.update(metadata: metadata.merge(virus_scan_result: status)) }

    subject { champ_pj.for_api }

    context 'when file is safe' do
      let(:status) { ActiveStorage::VirusScanner::SAFE }
      it { is_expected.to include("/rails/active_storage/disk/") }
    end

    context 'when file is not scanned' do
      let(:status) { ActiveStorage::VirusScanner::PENDING }
      it { is_expected.to include("/rails/active_storage/disk/") }
    end

    context 'when file is infected' do
      let(:status) { ActiveStorage::VirusScanner::INFECTED }
      it { is_expected.to be_nil }
    end
  end
end
