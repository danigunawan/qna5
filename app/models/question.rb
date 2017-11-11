class Question < ApplicationRecord
  include HasAttachments
  include HasRates
  include HasUser
  include HasComments

  has_many :answers, dependent: :destroy

  validates :title, :body, presence: true

  scope :list, -> { includes(:user).all.order(id: :desc) }
end
