# require 'active_support/conern'
# require 'application_controller'

module Qe::Concerns::Controllers::AnswerSheetsController
  extend ActiveSupport::Concern
  # include Qe::Concerns::Controllers::ApplicationController
  
  def check_valid_user
    true
  end

  included do
    unloadable
    layout 'qe/application'
    helper 'qe/answer_pages'
    before_filter :get_answer_sheet, :only => [:edit, :show, :send_reference_invite, :submit]
  end

  # list existing answer sheets
  def index
    
    # TODO dynamically reference this
    # @answer_sheets = answer_sheet_type.find(:all, :order => 'created_at')
    @answer_sheets = Qe::AnswerSheet.find(:all, :order => 'created_at')

    # drop down of sheets to capture data for
    @question_sheets = Qe::QuestionSheet.find(:all, :order => 'label').map {|s| [s.label, s.id]}
  end
  
  def create
    @question_sheet = Qe::QuestionSheet.find(params[:question_sheet_id])
    @answer_sheet = @question_sheet.answer_sheets.create
    
    
    redirect_to edit_answer_sheet_path(@answer_sheet)
  end
  
  # display answer sheet for data capture (page 1)
  def edit
    @presenter = Qe::AnswerPagesPresenter.new(self, @answer_sheet, params[:a])
    unless @presenter.active_answer_sheet.pages.present?
      flash[:error] = "Sorry, there are no questions for this form yet."
      if request.env["HTTP_REFERER"]
        redirect_to :back
      else
        render :text => "", :layout => true
      end
    else
      @elements = @presenter.questions_for_page(:first).elements
      @page = @presenter.pages.first
    end
  end
  
  # display captured answers (read-only)
  def show
    @question_sheet = @answer_sheet.question_sheet
    pf = Qe.table_name_prefix
    @elements = @question_sheet.pages.collect {|p| p.elements.includes(:pages).order("#{pf}pages.number,#{pf}page_elements.position").all}.flatten
    @elements = Qe::QuestionSet.new(@elements, @answer_sheet).elements.group_by{ |e| e.pages.first }
  end
  
  def send_reference_invite
    @reference = @answer_sheet.reference_sheets.find(params[:reference_id])
    @reference.update_attributes!(params[:reference][@reference.id.to_s])
    if @reference.valid?
      @reference.send_invite
    end
  end
    
  def submit
    return false unless validate_sheet
    flash[:notice] = "Your form has been submitted. Thanks!"
    redirect_to root_path
  end
  
  # protected 
    def answer_sheet_type
      (params[:answer_sheet_type] || Qe::Questionnaire.answer_sheet_class || 'Qe::AnswerSheet').constantize
    end
    
    def get_answer_sheet
      @answer_sheet = answer_sheet_type.find(params[:id])
    end
    
    def validate_sheet
      unless @answer_sheet.completely_filled_out?
        @presenter = Qe::AnswerPagesPresenter.new(self, @answer_sheet, params[:a])
        render 'incomplete'
        return false
      end
      return true
    end
end
