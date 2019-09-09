require_relative 'questions_database'
require_relative 'user'
require_relative 'question'

class Reply
    def self.find(id)
        replies_data = QuestionsDatabase.get_first_row(<<-SQL, id: id)
            SELECT
                replies.*
            FROM
                replies
            WHERE 
                replies.id = :id
        SQL
        Reply.new(replies_data)
    end

    def self.find_by_question_id(question_id)
        replies_data = QuestionsDatabase.execute(<<-SQL, question_id: question_id)
            SELECT
                replies.*
            FROM
                replies
            WHERE
                replies.question_id = :question_id
        SQL
        replies_data.map { |reply_data| Reply.new(reply_data) }
    end

    def self.find_by_user_id(user_id)
        replies_data = QuestionsDatabase.execute(<<-SQL, user_id: user_id)
            SELECT
                replies.*
            FROM
                replies
            WHERE
                replies.author_id = :user_id
        SQL
        replies_data.map { |reply_data| Reply.new(reply_data) }
    end

    def find_by_parent_id(parent_id)
        replies_data = QuestionsDatabase.execute(<<-SQL, parent_reply_id: parent_id)
            SELECT
                replies.*
            FROM
                replies
            WHERE
                replies.parent_reply_id = :parent_reply_id
        SQL
        replies_data.map { |reply_data| Reply.new(reply_data) }
    end

    attr_reader :id
    attr_accessor :question_id, :parent_reply_id, :author_id, :body
  
    def initialize(options)
      @id, @question_id, @parent_reply_id, @author_id, @body =
        options.values_at(
          'id', 'question_id', 'parent_reply_id', 'author_id', 'body'
        )
    end
  
    def attrs
      { question_id: question_id,
        parent_reply_id: parent_reply_id,
        author_id: author_id,
        body: body }
    end

    def author
        User.find_by_id(author_id)
    end

    def question
        Question.find(question_id)
    end

    def parent_reply
        Reply.find(parent_reply_id)
    end

    def child_replies
        Reply.find_by_parent_id(id)
    end
end