module ApplicationHelper

  def percentages number_of_sets = 7, spread = 50
    percentages = []
    number_of_sets.times.to_a.each { |i| percentages << rand(50) }
    percentages
  end

  def color index
    [ '#CFF09E',
      '#A8DBA8',
      '#79BD9A',
      '#3B8686',
      '#0B486B'
    ][index]
  end

  def colors
    5.times.map.each do |i|
      color(i)
    end.join(',')
    nil
  end

end
