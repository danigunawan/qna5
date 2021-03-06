class QuestionsController < ApplicationController
  include Rated
  before_action :authenticate_user!, only: [:new, :create]
  before_action :load_question, only: [:show, :destroy, :update]
  after_action :publish_question, only: [:create]
  authorize_resource
  respond_to :js
  respond_to :json, only: [:rate, :cancel_rate]
  def index
    respond_with(@questions = params[:only_me] ? current_user.questions.list : Question.list)
  end

  def new
    respond_with(@question = Question.new)
  end


  def create
    respond_with(@question = Question.create(question_params.merge(user: current_user)))
  end

  def show
    respond_with(@question)
  end

  def destroy
    respond_with(@question.destroy)
  end

  def update
    @question.update(question_params)
    respond_with(@question)
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:file, :_destroy])
  end

  def load_question
    @question = Question.find(params[:id] || params[:question_id])
    gon.question_id = @question.id
  end

  def publish_question
    return if @question.errors.any?
    ActionCable.server.broadcast(
      "questions",
      {
        question: ApplicationController.render(
          locals: { question: @question },
          partial: 'questions/row_question'
        )
      }
    )
  end

end
