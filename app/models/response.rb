class Response < ActiveRecord::Base

  validates :user_id, :presence => true
  validates :answer_choice_id, :presence => true

  belongs_to :respondent,
    class_name: "User",
    foreign_key: :user_id,
    primary_key: :id

  belongs_to :answer_choice,
    class_name: "AnswerChoice",
    foreign_key: :answer_choice_id,
    primary_key: :id

  has_one :question,
    through: :answer_choice,
    source: :question

  def sibling_responses
    question.responses.where("responses.id != ?", id)
  end


end
