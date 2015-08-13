class Response < ActiveRecord::Base

  validates :user_id, :presence => true
  validates :answer_choice_id, :presence => true
  validate :respondent_has_not_already_answered_question

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
    if id.nil?
      question.responses
    else
      question.responses.where("responses.id != ?", id)
    end
  end

  def respondent_has_not_already_answered_question
    if sibling_responses.any? { |response| response.user_id == respondent.id }
      errors[:already_answered] << "user has already answered this question"
    end
  end

  # def respondent_is_not_poll_author
  #   answer_choice
  # end

end
