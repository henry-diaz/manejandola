class CreateUserQuestions < ActiveRecord::Migration
  def change
    create_table :user_questions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :question, index: true, foreign_key: true
      t.integer :answer
      t.string :level, index: true

      t.timestamps null: false
    end
  end
end
