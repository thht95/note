payload = 
  {  
    "customer": { 
      "group_id":1,
      "confirmation": 'yes',
      "created_at": customer.updated_at,
      "created_in":"Admin",
      "email": customer.email,
      "firstname": customer_firstname,
      "lastname": customer_lastname,
      "gender": gender[customer.meta_data['gender'].to_s.to_sym],
      "custom_attributes":[  
        {  
            "attribute_code":"role",
            "value": customer.role
        },
        {  
            "attribute_code":"lang",
            "value": customer.lang
        },
        {  
            "attribute_code":"uid",
            "value": customer.id.to_s
        },
        {  
            "attribute_code":"meta_data",
            "value": customer.meta_data.to_s
        },
        {
            "attribute_code": "customer_avatar",
            "value": customer.avatar
        },
        {  
            "attribute_code": "courses",
            "value": customer.courses.to_json
        }
      ]
    }
    # "password": "Strong-Password"
  }

author = {
  "username": ENV['MAGENTO_USER_ADMIN'],
  "password": ENV['MAGENTO_PASSWORD_ADMIN']
}

access_token = ""

RestClient.post("#{ENV['MAGENTO_HOST']}/integration/admin/token", author.to_json, headers={"Content-Type"=> "application/json"}) { |token, request, result, &block| 
  access_token = "Bearer"+" "+Hash.from_xml(token)["response"]
end

if access_token.blank?
  p "access_token fail"
else
  RestClient.post("#{ENV['MAGENTO_HOST']}/customers", payload.to_json, headers={"Authorization" => access_token, "Content-Type": "application/json"}) { |response, request, result, &block| 
    binding.pry
  }
end   

#generate 50 accounts with random pass
o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten and true
ctp = [["email", "password"]]
50.times { |i|
  u = User.new 
  u.email = "accountvip#{i+1}@edumall.vn"
  password = (0...8).map { o[rand(o.length)] }.join
  u.password = password
  u.verified = true
  u.verified_at = Time.now
  if u.save
    p "Success #{u.email}"
    ctp << [u.email, password]
  else
    p "Fail #{u.email} - #{u.errors}" 
  end
}

top6 = PrimaryCategory.all.take(6) and true
list_id = top6.map(&:id)
top25 = User.where(:email => /accountvip/).take(25)
top25 = User.where(:email => /accountvip/).skip(25).take(25)

list_course_id = top25[24].courses.pluck(:course_id) and true

all_course = Course.where(:primary_category_ids.in => list_id, :version => 'public', :enabled => true, :price.ne => 0, :id.nin => list_course_id).to_a and true
all_course.each { |c|
  top25.each { |u|
    u.create_new_owned_course(c)

    p u.courses.count
  }
}

vipaccount.each { |u|
  u.courses.delete_all
}

all_course = all_course.select { |c| !list.include?(c.id) }.count



list = [

 'Giới thiệu project 07',
'Kỹ thuật chỉnh sáng và màu cho mắt',
'Loại bỏ mụn và các nếp nhăn trên khuôn mặt',
'Làm mịn và làm căng da mặt',
'Chỉnh màu son môi và makeup khuôn mặt',
'Chỉnh mượt và nhuộm màu cho tóc',
'Chỉnh sửa cấu trúc khuôn mặt hoặc cơ thể',
'Project 07 Retouch ảnh chân dung',

]

list.each { |x|
  name = x
  begin
    url = course.curriculums.where(:type => 'lecture', :title => /#{name.strip}/i).first.url.gsub("?t=1490184458", "").gsub("?t=1490184111", "")
  rescue 
    
  end

  if url.blank?
    url = course.curriculums.where(:type => 'lecture', :title => name).first.url.gsub("?t=1490184458", "").gsub("?t=1490184111", "")
  end

  unless url.blank?
    begin 
      p Library.where(:final_link => url).first.label.name
    rescue Exception => e
      p e
    end
  else
    p "ua?"  
  end
}


v = Course.where(:code => code).first.versions.first
v.curriculums.pluck(:url)
list = [
 ["//d1mjfb268gelin.cloudfront.net/kelley-57e4def8ce4b145a1020dbf9/20170316-hangntt01-16032017/brub-81-bai-3-ke-hoach-marketingmp4/master.m3u8",7*60+7],
 ["//d1mjfb268gelin.cloudfront.net/kelley-57e4def8ce4b145a1020dbf9/20170316-hangntt01-16032017/brub-82-bai-3-ke-hoach-marketing-ttmp4/master.m3u8",5*60+33],
 ["//d1mjfb268gelin.cloudfront.net/kelley-57e4def8ce4b145a1020dbf9/20170316-hangntt01-16032017/brub-9-bai-4-hoa-hop-voi-sale_ketoanmp4/master.m3u8",7*60+9],
 ["//d1mjfb268gelin.cloudfront.net/kelley-57e4def8ce4b145a1020dbf9/20170316-hangntt01-16032017/brub-101-bai-5-cap-nhat-kien-thucmp4/master.m3u8",5*60+55],
 ["//d1mjfb268gelin.cloudfront.net/kelley-57e4def8ce4b145a1020dbf9/20170316-hangntt01-16032017/brub-102-bai-5-cap-nhat-kien-thuc-ttmp4/master.m3u8",5*60+52],
]

list.each { |o|
  v.curriculums.where(:url => o[0]).first.update(:duration => o[1])
  Library.where(:final_link => o[0]).first.update(:duration => o[1])
}
v.update(:duration => v.curriculums.pluck(:duration).inject(0){|sum,x| sum + x })


list.each { |lib|
  l = Library.where(:final_link => lib).first
}




code = 'SonHN.01.01'
v = Course.where(:code => code).first.versions.first
v.curriculums.pluck(:url)

cv.curriculums.where(:url => url).update(:duration => 5*60+11)
Library.where(:final_link => url).first.update(:duration => 5*60+11)

--falcon
list.each { |x|
  c = Course.where(:code => x[0]).first

  if c.blank?
    p 'not found #{x[0]}'
  else
    cpc = CampaignCourse.new
    cpc.old_price = c.price
    cpc.new_price = x[1]
    cpc.enabled = true
    cpc.campaign_id = 275
    cpc.course_id = c.id
    cpc.save
  end
}*

# fix transcode
code = 'MaiDT.02'
c = Course.where(:code => code).first
v = c.versions.desc(:created_at).first

# check lech content 
v.curriculums.where(:type => 'lecture').each { |cu|
  mid = cu.media_uiza_id
  l = Library.where(:media_uiza_id => mid).first
  unless l.blank?
    if l.final_link != cu.url
      p "Khac link #{cu.lecture_index + 1}" 
      p l.final_link
      p cu.url
      # p cu.media_uiza_id
      # p ""
      
    end
  else
    p "l blank #{mid}"
  end
}

# mids = v.curriculums.where(:type => 'lecture', :lecture_index.in => [4,]).pluck(:media_uiza_id)
mids = v.curriculums.where(:type => 'lecture', :lecture_index.in => [4,7,19]).pluck(:media_uiza_id)
# al = Library.where(:media_uiza_id.in => mids)
  mids.each { |id|
    l = Library.where(:media_uiza_id => id).first
    p l.origin_link

  if l.blank?
    p "Dit me hong roi. lib blank #{id}"
  else
    if l.job_id != "create_job_fail"
      p "#{l.id} job deo fail"
      binding.pry
    end
    
    key = l.key
    video_dimensions = {:width=>"1920", :height=>"1080"}    
    job = LunaServices.generate_job(key, video_dimensions)    
    result = LunaServices.create_job(job)
    job_id = result['id']
    l.update(:job_id => job_id)

    p "update job #{job_id} cho lib #{l.id}"
  end
}


label =Library::Label.where(:name => 'NamHG.01.2103').first
all = Library.where(:label_id => label.id).to_a
p all.count
all.each { |lib|
  key = lib.key
  video_dimensions = {:width=>"1920", :height=>"1080"}    
  job = LunaServices.generate_job(key, video_dimensions)    
  result = LunaServices.create_job(job)
  job_id = result['id']
  lib.update(:job_id => job_id)  
  p "update job #{job_id} cho lib #{lib.id}"
}




mids.each { |id|
  l = Library.where(:media_uiza_id => id).first
  cu = v.curriculums.where(:type => 'lecture', :media_uiza_id => id).first
  cu.update(:url => l.final_link) unless l.final_link.blank?

  if l.final_link != cu.url
    p "Khac link #{cu.lecture_index + 1}" 
    p l.final_link
    p cu.url
  else
    p "#{cu.lecture_index + 1}"
  end
}





a =  Question.where(:type => 'mutiple-choice', :question => 'Chúng tôi có thể làm tốt hơn nếu:').to_a
a.each { |q|
  q.metadata[:answers] = 
  [ 
    "Nhiều bài tập hơn", 
    "Nội dung chi tiết hơn", 
    "Tốc độ nhanh hơn", 
    "Tốc độ chậm hơn", 
    "Thêm tài liệu tham khảo", 
    "Cải thiện giọng nói", 
  ]

  q.save
}



count = 0
list_user_id_reviewed = Review.distinct(:user_id) and true
ctp = [["count", "name", "email", "Phone number", "Course name", "Course code", "Actived_at", "Learning progress"]]

all = User.where(:id.nin => list_user_id_reviewed, :created_at.gte => Time.new(2019,8,1)).pluck(:id)
all_count = all.count

all.each { |uid|
  u = User.find(uid)

  next if u.courses.count == 0 
  list_oc_id = u.courses.pluck(:course_id)
  all_courses = Course.where(:id.in => list_oc_id).to_a 

  u.courses.each_with_index { |oc, index|
    progress_range = logic_percent_complete(oc)
    next if progress_range < 5
    c = all_courses.select { |x| x.id == oc.course_id }.first
    obj = []

    if index == 0
      count += 1 
      obj << count
      obj << u.name
      obj << u.email
      obj << u.phone_number
    else
      obj << ""
      obj << ""
      obj << ""
      obj << ""
    end

    obj << c.name
    obj << c.code
    obj << oc.created_at
    obj << progress_range

    ctp << obj
    p "#{count}/#{all_count}"
  }
}


teachers = User.teachers
teachers.each { |id|
  t = User.find(id)

  p t.instr_id
  payload = {}
  payload["email"] = t.email
  payload["mobile"] = t.phone_number
  payload["name"] = t.name
  payload["username"] = t.username
  payload["kellyId"] = t.id
  payload["avatar"] = t.avatar

  RestClient.post("#{ENV["IS_DOMAIN"]}/user/kelley", payload.to_json, headers={"Content-Type"=> "application/json"}){ |response, request, result, &block|
    if response.code == 200
      t.update(:instr_id => JSON.parse(response)["id"])
      p "success #{t.instr_id}"
    elsif response.code == 409
      p "user already exist"
    else
      p "Loi gi do roi anh Hoa oi"
      p "#{response.code} - #{response}" 
    end
  }
}
