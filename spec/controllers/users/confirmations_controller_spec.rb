describe Users::ConfirmationsController, type: :controller do
  let(:confirmation_token) { user.confirmation_token }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#show' do
    context 'when confirming within the auto-sign-in delay' do
      let!(:user) { create(:user, :unconfirmed) }

      before do
        Timecop.travel(1.hour.from_now) {
          get :show, params: { confirmation_token: confirmation_token }
        }
      end

      it 'confirms the user' do
        expect(user.reload).to be_confirmed
      end

      it 'signs in the user after confirming its token' do
        expect(controller.current_user).to eq(user)
        expect(controller.current_instructeur).to be(nil)
        expect(controller.current_administrateur).to be(nil)
      end

      it 'redirects the user to the root page' do
        # NB: the root page may redirect the user again to the stored procedure path
        expect(controller).to redirect_to(root_path)
      end
    end

    context 'when the auto-sign-in delay has expired' do
      let!(:user) { create(:user, :unconfirmed) }
      before do
        Timecop.travel(3.hours.from_now) {
          get :show, params: { confirmation_token: confirmation_token }
        }
      end

      it 'confirms the user' do
        expect(user.reload).to be_confirmed
      end

      it 'doesn’t sign in the user' do
        expect(subject.current_user).to be(nil)
        expect(subject.current_instructeur).to be(nil)
        expect(subject.current_administrateur).to be(nil)
      end

      it 'redirects the user to the sign-in path' do
        expect(subject).to redirect_to(new_user_session_path)
      end
    end

    context 'with a user already confirmed' do
      let!(:user) { create(:user, confirmation_token: 'some_token') }
      let(:confirmation_token) { user.confirmation_token }

      before do
        get :show, params: { confirmation_token: confirmation_token }
      end
      render_views

      it 'doesn’t sign in the user' do
        expect(subject.current_user).to be(nil)
        expect(subject.current_instructeur).to be(nil)
        expect(subject.current_administrateur).to be(nil)
      end

      it 'informs the user and asks it user to sign in' do
        expect(response.body).to have_content('Votre compte est déja activé')
        expect(response.body).to have_content('Vous pouvez vous dès à présent vous connecter')
      end
    end

    context 'with an invalid confirmation token' do
      let!(:user) { create(:user, :unconfirmed) }
      let(:confirmation_token) { 'an invalid confirmation token' }
      before do
        Timecop.travel(1.hour.from_now) {
          get :show, params: { confirmation_token: confirmation_token }
        }
      end
      render_views

      it 'does not confirm the user' do
        expect(user.reload).not_to be_confirmed
      end

      it 'doesn’t sign in the user' do
        expect(subject.current_user).to be(nil)
        expect(subject.current_instructeur).to be(nil)
        expect(subject.current_administrateur).to be(nil)
      end

      it 'suggests the user to ask for a new confirmation token' do
        expect(response.body).to have_content('Votre lien de confirmation est invalide')
      end
    end
  end
end
