require 'spec_helper'

module Api
  module V1
    describe UsersController do
      describe 'GET #show' do
        before(:all)  { @user = FactoryGirl.create :user }
        before(:each) { get :show, id: @user.id }

        it 'returns the information about a reporter on a hash' do
          user_response = json_response

          expect(user_response[:email]).to eql @user.email
        end

        it { should respond_with 200 }
      end

      describe 'POST #create' do
        context 'when is successfully created' do
          before(:all)  { @user_attributes = FactoryGirl.attributes_for :user }
          before(:each) { post :create, { user: @user_attributes } }

          it 'renders the json representation for the user record just created' do
            user_response = json_response

            expect(user_response[:email]).to eql @user_attributes[:email]
          end

          it { should respond_with 201 }
        end

        context 'when is not created' do
          before(:all)  { @invalid_user_attributes = { password: '12345678', password_confirmation: '12345678' } }
          before(:each) { post :create, { user: @invalid_user_attributes } }

          it 'renders an errors json' do
            user_response = json_response

            expect(user_response).to have_key(:errors)
          end

          it 'renders the json errors on why the user could not be created' do
            user_response = json_response

            expect(user_response[:errors][:email]).to include "can't be blank"
          end

          it { should respond_with 422 }
        end
      end

      describe 'PUT/PATCH #update' do
        before(:all)  { @user = FactoryGirl.create :user }
        before(:each) { api_authorization_header(@user.auth_token) }

        context 'when is successfully updated' do
          before(:each) { patch :update, { id: @user.id, user: { email: "newmail@example.com" } } }

          it 'renders the json representation for the updated user' do
            user_response = json_response

            expect(user_response[:email]).to eql "newmail@example.com"
          end

          it { should respond_with 200 }
        end

        context 'when is not created' do
          before(:each) { patch :update, { id: @user.id, user: { email: "bademail.com" } } }

          it 'renders an errors json' do
            user_response = json_response

            expect(user_response).to have_key(:errors)
          end

          it 'renders the json errors on whye the user could not be created' do
            user_response = json_response

            expect(user_response[:errors][:email]).to include 'is invalid'
          end

          it { should respond_with 422 }
        end
      end

      describe 'DELETE #destroy' do
        before(:all)  { @user = FactoryGirl.create :user }
        before(:each) do
          api_authorization_header(@user.auth_token)
          delete :destroy, { id: @user.id }
        end

        it { should respond_with 204 }
      end
    end
  end
end
