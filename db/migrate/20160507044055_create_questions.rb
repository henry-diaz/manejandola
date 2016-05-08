class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :category, index: true
      t.string :question
      t.string :answer_1
      t.string :answer_2
      t.string :answer_3
      t.string :answer_4
      t.integer :correct
      t.string :level, index: true
      t.attachment :image
      t.timestamps null: false
    end
  end
end
