describe Champs::HeaderSectionChamp do
  describe '#section_index' do
    let(:types_de_champ) do
      [
        create(:type_de_champ_header_section, order_place: 1),
        create(:type_de_champ_civilite,       order_place: 2),
        create(:type_de_champ_text,           order_place: 3),
        create(:type_de_champ_header_section, order_place: 4),
        create(:type_de_champ_email,          order_place: 5)
      ]
    end

    context 'for root-level champs' do
      let(:procedure) { create(:procedure, types_de_champ: types_de_champ) }
      let(:dossier) { create(:dossier, procedure: procedure) }
      let(:first_header)  { dossier.champs[0] }
      let(:second_header) { dossier.champs[3] }

      it 'returns the index of the section (starting from 1)' do
        expect(first_header.section_index).to eq 1
        expect(second_header.section_index).to eq 2
      end
    end

    context 'for repetition champs' do
      let(:procedure) { create(:procedure, :with_repetition) }
      let(:dossier) { create(:dossier, procedure: procedure) }

      let(:repetition_tdc)  { procedure.types_de_champ.find(&:repetition?) }
      let(:first_header)  { dossier.champs.first.champs[0] }
      let(:second_header) { dossier.champs.first.champs[3] }

      before do
        repetition_tdc.types_de_champ = types_de_champ
      end

      it 'returns the index of the section in the repetition (starting from 1)' do
        expect(first_header.section_index).to eq 1
        expect(second_header.section_index).to eq 2
      end
    end
  end
end
