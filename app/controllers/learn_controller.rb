class LearnController < ApplicationController
  before_action :authenticate_user!

  def index
    add_breadcrumb "Dashboard", root_path
    add_breadcrumb "Aprender más", learn_index_url
    puts params[:category]
    if params[:category]
      add_breadcrumb Question::CATEGORY[params[:category].to_s]
      @question = current_user.questions.where(category: params[:category]).random
    else
      @question = current_user.questions.random
    end
  end
end
