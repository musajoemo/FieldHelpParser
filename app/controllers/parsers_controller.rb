class ParsersController < ApplicationController
  before_action :set_parser, only: [:show, :edit, :update, :destroy]
  require 'csv'
  # GET /parsers
  # GET /parsers.json
  def index
    @parsers = Parser.all
  end

  # GET /parsers/1
  # GET /parsers/1.json
  def show
    doc = Nokogiri::HTML(open(@parser.file.path()))
    children = doc.at('body').children[1]
    data = Array.new
    page_id = nil
    children.children.each do |node|

      if node.name == "h1"
        page_id = node.text[0..4]
      elsif node.attribute("class").present? && node.attribute("class").text == "BulletList"
        field = node.css('b').text
        targetField = field.gsub(":","")
        help_text = node.text.gsub(field,"")
        help_text = help_text.gsub("·","")

        data << [page_id,targetField,help_text]
      end
    end
    #Grab our product specifications
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet
    sheet1.name = 'My First Worksheet'
    sheet1.row(0).concat %w{ PageID TargetField Help}
    data.each_with_index do |line, index|
      helping = line[2].gsub!("\r\n"," ")
      helping = helping.chars.reject { |char| char.ord == 160 }.join                                                      
      sheet1.row(index+1).push line[0],line[1],helping
    end  
    book.write "#{@parser.title}.xls"

    redirect_to parsers_path, notice: 'Spreadsheet was successfully created.'
    
  end

  # GET /parsers/new
  def new
    @parser = Parser.new
  end

  # GET /parsers/1/edit
  def edit
  end

  # POST /parsers
  # POST /parsers.json
  def create
    @parser = Parser.new(parser_params)

    respond_to do |format|
      if @parser.save
        format.html { redirect_to @parser, notice: 'Parser was successfully created.' }
        format.json { render :show, status: :created, location: @parser }
      else
        format.html { render :new }
        format.json { render json: @parser.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parsers/1
  # PATCH/PUT /parsers/1.json
  def update
    respond_to do |format|
      if @parser.update(parser_params)
        format.html { redirect_to @parser, notice: 'Parser was successfully updated.' }
        format.json { render :show, status: :ok, location: @parser }
      else
        format.html { render :edit }
        format.json { render json: @parser.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parsers/1
  # DELETE /parsers/1.json
  def destroy
    @parser.destroy
    respond_to do |format|
      format.html { redirect_to parsers_url, notice: 'Parser was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parser
      @parser = Parser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def parser_params
      params.require(:parser).permit(:title, :file)
    end
end
