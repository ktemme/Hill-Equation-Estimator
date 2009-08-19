require 'rubygems'
require 'sinatra'
require 'regression'
require 'sinatra/static_assets'


get '/?' do 
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
  hill = fraction.map do |t| 
    a = t.first == 0 ? -1.0/0 : Math.log(t.first)
    b = t.last/(1-t.last) == 0 ? -1.0/0 : Math.log(t.last/(1-t.last))
    # [Math.log(t.first), Math.log(t.last/(1-t.last))]
    [a,b]
  end
  
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