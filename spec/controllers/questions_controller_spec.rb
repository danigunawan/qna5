require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do

  login_user
  let(:question) { create(:question, user: @user) }

  it_behaves_like 'Rated', 'question'

  describe 'GET #index' do
    let(:questions) { create_list(:question, 3) }

    before { get :index}

    it 'populates an array of all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    xit 'builds new attachment for question' do
      expect(assigns(:question).attachments.first).to be_a_new(Attachment)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
   context 'with valid attributes' do
      it 'saves the new question in the database' do
        expect { post :create, params: { question: attributes_for(:question) } }.to change(Question, :count).by(1)
      end

      it 'question belongs to user' do
        post :create, params: { question: attributes_for(:question) }
        expect(Question.last.user).to eq(@user)
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to question_path(assigns(:question))
      end

      it 'broadcast' do
        post :create, params: { question: { title: 'My question', body: 'Cool!'} }
        have_broadcasted_to("questions").with(text: 'Cool!')
      end

    end

    context 'with invalid attributes' do
      it 'does not save the question' do
        expect { post :create, params: { question: attributes_for(:invalid_question)} }.to_not change(Question, :count)
      end

      it 're-renders new view' do
        post :create, params: { question: attributes_for(:invalid_question) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'DELETE #destroy' do
    before { question }
    context 'autor delete question' do
      it 'delete question in the database' do
        expect { delete :destroy, params: { id: question } }.to change(Question, :count).by(-1)
      end

      it 'redirect to index view' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to questions_path
      end
    end

    context 'not autor delete question' do
      let!(:question_2) { create(:question) }
      before { question_2 }
      it 'delete question in the database' do
        expect { delete :destroy, params: { id: question_2 } }.to_not change(Question, :count)
      end

      it 'redirect to index view' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to questions_path
      end
    end
  end


  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    xit 'builds new attachment for answer' do
      expect(assigns(:answer).attachments.first).to be_a_new(Attachment)
    end

  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'update the new question in the database' do
        post :update, format: :js, params: { id: question, question: { body: 'edited question' } }
        question.reload
        expect(question.body).to eq 'edited question'
      end
    end

    context 'with invalid attributes' do
      it 'does not save the question' do
        post :update, format: :js, params: { id: question, question: { body: '' } }
        question.reload
        expect(question.body).to_not eq ''
      end
    end

    let!(:question_2) { create(:question) }
    it "not author can't update question" do
      post :update, format: :js, params: { id: question_2, question: { body: 'edited question' } }
      question.reload
      expect(question.body).to_not eq 'edited answer'
      expect(response).to have_http_status(:forbidden)
    end

  end


end
