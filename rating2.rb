ctp = [["comment", "rating", "is_enable", "day rating", "course code", "course name", "user name", "user email"]]
log = 0
rv_count = Review.where(:created_at.gte => Time.new(2019,1,1), :created_at.lt => Time.new(2019,10,30)).count
Review.where(:created_at.gte => Time.new(2019,10,1), :created_at.lt => Time.new(2019,11,1)).each { |r|
  obj = []
  obj << r.description
  obj << r.rating
  obj << r.is_enable
  obj << r.created_at
  unless r.course.blank?
    obj << r.course.code
    obj << r.course.name
  else
    obj << ""
    obj << ""
  end

  unless r.user.blank?
    obj << r.user.name
    obj << r.user.email 
  else
    obj << ""
    obj << ""
  end  

  ctp << obj
  log += 1 
  p "#{log}/#{rv_count}"
}