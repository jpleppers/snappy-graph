require 'csv'

class PagesController < ApplicationController

  def index
    @heigths =  CSV.read("db/world_heights.csv")

  end

end