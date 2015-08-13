class Question < ActiveRecord::Base

  validates :poll_id, :presence => true

  belongs_to :poll,
    class_name: "Poll",
    foreign_key: :poll_id,
    primary_key: :id

  has_many :answer_choices,
    class_name: "AnswerChoice",
    foreign_key: :question_id,
    primary_key: :id

  has_many :responses,
    through: :answer_choices,
    source: :responses

  # def results_n_plus_one
  #   output = {}
  #   answer_choices.each do |answer_choice|
  #     output[answer_choice.text] = answer_choice.responses.count
  #   end
  #   output
  # end
  #
  # def results_two_database_queries
  #   poll_results = answer_choices.includes(:responses)
  #
  #   output = {}
  #   poll_results.each do |poll_result|
  #     output[poll_result.text] = poll_result.responses.length
  #   end
  #   output
  # end

  def results
    poll_results = answer_choices
      .joins("LEFT OUTER JOIN responses ON answer_choices.id = responses.answer_choice_id")
      .group("answer_choices.id")
      .select("answer_choices.*, count(responses.id) AS num_responses")

    output = {}
    poll_results.each do |poll_result|
      output[poll_result.text] = poll_result.num_responses
    end
    output
  end

end
