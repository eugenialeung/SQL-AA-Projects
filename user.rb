require_relative 'questions_database'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'

class User 
  def self.find_by_id(id)
    user_data = QuestionsDatabase.get_first_row(<<-SQL, id: id)
      SELECT
        users.*
      FROM
        users
      WHERE
        users.id = :id
    SQL

    user_data.nil? ? nil : User.new(user_data)
  end

  def self.find_by_name(fname, lname)
    attrs = { fname: fname, lname: lname }
    user_data = QuestionsDatabase.get_first_row(<<-SQL, attrs)
      SELECT
        users.*
      FROM
        users
      WHERE
        users.fname = :fname AND users.lname = :lname
    SQL

    user_data.nil? ? nil : User.new(user_data)
  end

  attr_reader :id
  attr_accessor :fname, :lname

  def initialize(options = {})
    @id, @fname, @lname = options.values_at('id', 'fname', 'lname')
  end

  def attrs
    { fname: fname, lname: lname }
  end



  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end
  
  def average_karma
    QuestionsDatabase.get_first_value(<<-SQL, author_id: self.id)
      SELECT
        CAST(COUNT(question_likes.id) AS FLOAT) /
          COUNT(DISTINCT(questions.id)) AS avg_karma
      FROM
        questions
      LEFT OUTER JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        questions.author_id = :author_id
    SQL
  end
end
