require 'rubygems'
require 'sinatra'
require 'regression'

get '/' do 
  erb :index 
end 

post '/upload' do 
  data = params[:data].split("\n")
  data = data.map{|item| item.split("\t")}
  @data = data.map{|timepoint| timepoint.map{|data| data.chomp.to_f}}

  max = params[:max]=="" ? @data.map{|t| t.last}.max : params[:max].to_f
  min = params[:min]=="" ? @data.map{|t| t.last}.min : params[:min].to_f

  midpoint = (@data.first.first + @data.last.first )/2

  @maxline = [[@data.first.first,max],[midpoint,max],[@data.last.first,max]]
  @minline = [[@data.first.first,min],[midpoint,min],[@data.last.first,min]]
  
  fraction = @data.map{|t| [t.first, (t.last-min)/(max-min).to_f]}
  hill = fraction.map{|t| [Math.log(t.first), Math.log(t.last/(1-t.last))]}
  @hill = hill.select{|t| t.first.infinite? == nil && t.last.infinite? == nil}    
    
  hill_x = @hill.map{|t| t.first}
  hill_y = @hill.map{|t| t.last}
  
  @fit = LinearRegression.new(hill_x,hill_y)
  
  @fit_data = @hill.map{|t| [t.first, @fit.predict(t.first)]}
  
  erb :graph
end

# http://code.google.com/p/flot/issues/detail?id=26
# Flot logs
# http://www.hacknack.com/2009/03/writing-flot-plug-ins-and-the-decorator-pattern-in-javascript/