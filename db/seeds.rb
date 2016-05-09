# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Load questions
require 'csv'
CSV.foreach("#{Rails.root.to_s}/db/conocimiento.csv", headers: true) do |row|
  h = row.to_hash
  q = Question.new
  q.category = h['category']
  q.question = h['question']
  q.answer_1 = h['answer1']
  q.answer_2 = h['answer2']
  q.answer_3 = h['answer3']
  q.answer_4 = h['answer4']
  q.correct = h['correct']
  q.level = h['level']
  q.image = File.new("#{Rails.root.to_s}/db/signs/#{h['image']}", "r") if h['image'].present?
  q.save
end
