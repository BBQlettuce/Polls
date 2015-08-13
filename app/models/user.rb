class User < ActiveRecord::Base

  validates :user_name, :presence => true

  has_many :authored_polls,
    class_name: "Poll",
    foreign_key: :author_id,
    primary_key: :id

  has_many :responses,
    class_name: "Response",
    foreign_key: :user_id,
    primary_key: :id

  def completed_polls
    Poll
      .joins(questions: :answer_choices)
      .joins(user_responses_subquery)
      .group("polls.id")
      .having("COUNT(DISTINCT questions.id) = COUNT(user_responses.id)")
      .select("polls.*")

      # .joins('LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id' )
      # .where('responses.user_id = ? or responses.user_id IS NULL', id)
  end

  def user_responses_subquery
    'LEFT OUTER JOIN ' +
      '(SELECT * ' +
        'FROM responses ' +
        'WHERE responses.user_id = ' + id.to_s + ') ' +
        'AS user_responses ' +
        'ON user_responses.answer_choice_id = answer_choices.id'
  end

  def uncompleted_polls
    Poll
      .joins(questions: :answer_choices)
      .joins(user_responses_subquery)
      .group("polls.id")
      .having("COUNT(DISTINCT questions.id) != COUNT(user_responses.id)")
      .select("polls.*")
  end

end
      # .joins("?", responses)
# # +
# # # #
# SELECT
#   polls.* --polls.id p_id, questions.id q_id, answer_choices.id a_id, user_responses.id r_id, user_responses.user_id u_id
# FROM
#   polls
# LEFT OUTER JOIN
#   questions ON polls.id = questions.poll_id
# LEFT OUTER JOIN
# #   answer_choices ON answer_choices.question_id = questions.id
# LEFT OUTER JOIN
#   (SELECT
#     *
#   FROM
#     responses
#   WHERE
#     responses.user_id = 3 ) AS user_responses
# ON
#   user_responses.answer_choice_id = answer_choices.id
# # GROUP BY
#   polls.id
# HAVING
#   COUNT(DISTINCT questions.id) != COUNT(user_responses.id)
# #   #


# SELECT
#   *
# FROM
#   polls
# JOIN
#   questions ON polls.id = questions.poll_id
# JOIN
#   answer_choices ON answer_choices.question_id = questions.id
# JOIN
#   responses ON responses.answer_choice_id = answer_choices.id
