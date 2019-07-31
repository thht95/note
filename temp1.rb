
cu = course.curriculums.where(:title => /#{lecture_name.strip}/i, :type => 'lecture').first

if cu.blank?
  cu = course.curriculums.where(:type => 'lecture', :title => lecture_name.strip).first
end

unless cu.blank?
  lib = Library.where(:final_link => cu.url.gsub("?t=1490184458", "")).first
  if lib.blank? 
    row[5] += "\n lib blank #{cu.url}"  
  else
    if lib.label  .blank?
      row[5] += "\n Không có label"
    else
      row[5] += "\n #{lib.label.name}"
    end
  end
else
  row[5] += "\n lecture blank #{lecture_name.strip}"
end
else
row[5] += "\n lecture name blank #{d}"
      

#find label and update jwplayer link 

v.curriculums.where(:type => 'lecture').each {  |cu|
  # lib = Library.where(:final_link => cu.url.gsub("?t=1490184458", "")).first
  lib = Library.where(:media_uiza_id => cu.media_uiza_id).first 
  p cu.lecture_index
  p lib.label_id.blank? ? "" : lib.state
  # cu.update(:media_uiza_id => lib.media_uiza_id) 
}

v.curriculums.where(:type => 'lecture').pluck(:media_uiza_id, :lecture_index, :url)

mids = []

mids.each { |mid|
  lib = Library.where(:media_uiza_id => mid).first
  v.curriculums.where(:media_uiza_id => mid).first.update(:url => lib.final_link)
}


CSV.open("hanhpt3.csv", "wb") do |f|
  ctp.map { |c| 
    f << c
  }
end



ctp = [['code', 'name', 'version', 'published_at']]

Course.where(:version.ne => 'test').only(:curriculums, :code, :name, :version, :created_at).each { |c|
  c.curriculums.where(:type => 'lecture').each { |cu|
    next unless cu.media_uiza_id.blank?
    if cu.url.blank?
      h2_write_log("test3.txt", "#{c.code} - #{cu.lecture_index} - Url blank")
      next
    end

    next if cu.url.include?("youtu.be")
    next if cu.url.include?("youtube.com")

    if cu.url.blank?
      h2_write_log("test3.txt", "#{c.code} - #{cu.lecture_index} - Url blank")
    else
      l = Library.where(:final_link => cu.url.gsub("?t=1490184458","")).first
      if l.blank?
        h2_write_log("test3.txt", "Url #{cu.url} not found lib")
      else
        if l.state == 'COMPLETED'
          RestClient.post(uiza_api_upload,{:name => "#{c.code}_#{l.file_name}" , :url => l.origin_link, :inputType => 'http' }, {:Authorization => authorization}){ |response, request, result, &block|
            if (response != 'null' || !response.blank?)
              result = JSON.parse(response)
              data = result["data"]

              unless data.blank?
                media_uiza_id = data["id"]
                l.update(:media_uiza_id => media_uiza_id)
                cu.update(:media_uiza_id => media_uiza_id)

                h2_write_log("test3.txt","Update #{media_uiza_id} for #{l.id} and #{c.code}-#{cu.lecture_index}")

                # publish video
                RestClient.post(uiza_api_publish,{:id => media_uiza_id }, {:Authorization => authorization}){ |response, request, result, &block| }
              else
                h2_write_log("test3.txt", "Data blank. #{code}. #{l.origin_link}")
              end
            else
              h2_write_log("test3.txt", "Response blank. #{code}. #{l.origin_link}")
            end
          }
        else
          h2_write_log("test3.txt", "#{l.id} not COMPLETED")
        end
      end
    end
  }
}



  if c.curriculums.pluck(:media_uiza_id).blank?
    first_cu = c.curriculums.where(:type => 'lecture')[1]
    unless first_cu.blank? 
      unless  || 
        obj = []
        obj << c.name
        obj << c.code
        obj << c.version
        obj << c.versions.pluck(:published_at).first
        ctp << obj
      end
    end
  else
    count = c.curriculums.where(:type => 'lecture').count
    uiza_count = c.curriculums.pluck(:media_uiza_id).count
    if count != uiza_count
      obj = []
      obj << c.name
      obj << c.code
      obj << c.version
      obj << c.created_at
      ctp << obj

      c.curriculums.where(:type => 'lecture').each { |cu|
        if cu.media_uiza_id.blank?
          obj = ['','','','']
          obj << cu.lecture_index
          obj << cu.title
          ctp << obj
        end
      }
    end
  end
} 

list.each { |l|
  c = Course.where(:code => l).first
  firstcu = c.curriculums.where(:type => 'lecture')[2]
  if firstcu.url.include?("youtube.com") || firstcu.url.include?("youtu.be")
    p l
  end  
} 

 [["//d1mjfb268gelin.cloudfront.net/kelley-57e4def8ce4b145a1020dbf9/20161125-truonglv07-25112016/bai-14_1mp4/master.m3u8", 9*60+46],
 ["//d1mjfb268gelin.cloudfront.net/kelley-57e4def8ce4b145a1020dbf9/20161125-truonglv07-25112016/bai-16_1mp4/master.m3u8", 9*60+57]]



list.each { |o|
  v.curriculums.where(:url => o[0]).first.update(:duration => o[1])
  Library.where(:final_link => o[0]).first.update(:duration => o[1])
}


 User.where(:email.nin => [/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i]) 

ctp = []
check = []
Course.where(:enabled => true, :version => 'public').each { |c|
  c.curriculums.where(:type => 'lecture', :url.nin => [/youtu.be/]).each { |cu|
    if cu.media_uiza_id.blank?
      ctp << [c.code, cu.lecture_index, cu.url]
      check << cu.url
    end
  }
}

ctp = [["Stt", "category", "sub category", "code", "name" ]]
count = 1
Course.any_of({ :primary_category_ids.nin => [nil, []]} , {:sub_category_ids.nin => [nil,[]]}).each { |c|
  obj = []
  obj << count
  obj << c.primary_categories.pluck(:name).first
  obj << c.sub_categories.pluck(:name).first
  obj << c.code
  obj << c.name

  count += 1 

  ctp << obj
}

log = 0
rv_count = Review.where(:created_at.gte => Time.new(2019,6,1)).count
Review.where(:created_at.gte => Time.new(2019,6,1)).each { |r|
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

/(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z|^(0|84|\+84)+(\d{9}|\d{10})$)/i

#write csv

ctp = [["description", "rating", "is_enable", "created_at", "course code", "course name" ,"user name", "user email"]]
CSV.open("percent_complete_data.csv", "w") do |row|
  ctp.each { |c|
    row << c

    #if c is not an array use [c]
  }
end

b = []

#logic % complete course
def logic_percent_complete(oc)
  count_complete = oc.lectures.where(lecture_ratio: 100).count
  count_all = oc.lectures.count

  count_complete*100.0/count_all
end

#read csv
ctp =[]
count = 0
count_user_nil = 0
count_course_nil = 0
count_owned_course_nil = 0
count_success = 0
CSV.foreach("data2.csv") do |row|
  count += 1
  p count

  # b << row[1]
  u = User.where(:email => row[2]).first
  u = User.where(:phone_number => row[1]) if u.blank?

  if u.blank?
    count_user_nil += 1
    row << "User blank"
    ctp << row
    next
  end

  c = Course.where(:code => row[5]).first

  if c.blank?
    count_course_nil += 1
    row << "Course blank"
    ctp << row
    next
  end

  oc = u.courses.where(:course_id => c.id).first

  if oc.blank?
    row << "Owned course blank"
    ctp << row
    count_owned_course_nil += 1
    next
  end  

  #logic % complete course
  row << logic_percent_complete(oc)
  ctp << row
  count_success += 1
end

b = []
b = b.map { |x| x.first}

customers = Rails.cache.fetch("user_recent", expires_in: 1.days) do
  User.where(:email.in => [/(\A([^@.+'\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z|^(0|84|\+84)+(\d{9}|\d{10})$)/i], :last_sign_in_at.gte => Time.new(2018,1,1)).pluck(:id, :email, :name, :phone_number, :last_sign_in_at, :created_at)
end

name = 'hoc-illustrator-photoshop-va-animate-cc-2017-thong-qua-bai-tap-thuc-te'
c = Course.where(:alias_name => name).first
c.curriculums.pluck(:use_cdn)


#find label after pluck url from course or course version
codes = ["truongpx.05","truongpx.06"]
codes.each { |code|

}
code = "LongTT.04"
list = ["VietND.32", "VietND.34"]
  
list.each { |code|
  course = Course.where(:code => /#{code}/i).first
  if course.blank?
    p "Course bi nil deo hieu sao"
  else
    cus = course.versions.first.curriculums.where(:type => 'lecture').to_a and true
    cus.each { |cu|
      lb = Library.where(:final_link => cu.url.gsub("?t=1490184458", "")).first
      obj = []
      unless lb.blank?
        obj << cu.lecture_index + 1
        obj << (lb.label_id.blank? ? "Khong co label" : lb.label.name)
      else
        obj << cu.lecture_index + 1
        obj << "not found"
      end
      ctp << obj
    } 

    CSV.open("#{code.gsub(".","")}.csv", "w") do |row|
      ctp.each { |c|
        row << c
      }
    end
  end
}


# download file: 
# scp -P 2122 rails@sgkelley2.edumall.vn:~/kelley/current/HanhPT03.csv .
# scp rails@sgservreview.edumall.vn:~/tudemy/current/over400courses.csv




u = User.where(:email => 'huongdannotcainaydi@gmail.com').first
course = Course.where(:code => 'HanhPT.03').first
u.create_new_owned_course(course)

#create cod code
#openvpn

#run this on antman
9.times { |i|
  c = Cod.new
  # c.course_id = "Combo_QuyenVN.01_NgocPTN.01_ThongJ.01"
  c.course_id = '59098730ce4b141e4e43cd16'
  
  c.cod = "kcg112"  
  c.expired_date = Time.now + 1.year
  c.save
}

#run this on jackfruit
9.times { |i|
list.each { |i|
  p = Payment.new 
  p.email = 'hoadt9@topica.edu.vn'
  p.method = 'cod'
  p.status = 'success'
  p.cod_version = 'new'
  p.cod_code = i
  p.course_id = "Combo_QuyenVN.01_NgocPTN.01_ThongJ.01"
  # p.course_id = '59098730ce4b141e4e43cd16'
  p.save
}

alias_name = 'tim-mat-hang-hot-taobao-1688-va-tu-mua-hang-trung-quoc-chi-phi-thap-nhat'

list.each { |code|
c = Course.where(:code => code).first
# c = Course.where(:alias_name => alias_name).first
c = c.versions.desc(:created_at).first
c.curriculums.where(:type => 'lecture').each { |cu|
  # cu.update(:use_cdn => false)
  p cu.use_cdn
}
}

User.where(:role => 'user', :last_sign_in_at.gte => Time.new(2018,1,1)).each { |u|
  if u.courses.count > 400
    list << u.email
    p u.email
  end  
} 

User.where(:role => 'user', :last_sign_in_at.lt => Time.new(2018,1,1)).each { |u|
  if u.courses.count > 400
    list << u.email
    p u.email
  end  
} 

list = []
User.where(:role => 'user').each { |u|
  if u.courses.count > 400
    list << u.email
    p u.email
  end  
}
ctp = [["Email", "last_sign_in_at", "Payment count", "Course count", "List Course Id" ,"Status"]]
User.where(:email.in => list).each { |u|
  obj = []

  obj << u.email
  obj << u.last_sign_in_at
  obj << Payment.where(:email => u.email).count
  obj << u.courses.count
  obj << u.courses.pluck(:course_id).map {|c| c.to_s}.to_s.gsub(",","\n")
  obj << u.status

  ctp << obj
}

#get traffic from key
ctp = TrafficV2.where(:created_at.gte => Time.now - 1.hours, :is_mobile => false).pluck(:id, :user_agent, :referer, :ip_address, :is_valid, :origin)

#write content s3
def put_content(bucket, key, content)
  S3.bucket(bucket).put_object(
    key: key,
    body: content, acl: 'public-read',
    content_type: 'binary/octet-stream'
  )
end

#check upload theo label
label = "truongpx_fix_14_5"
l = Library::Label.where(:name => label).first
all = Library.where(:label_id => l.id).to_a 

#retranscode cho 1 so label
label =Library::Label.where(:name => 'CuongDN.09_0222').first
all = Library.where(:label_id => label.id, :type => 'video', :state.ne => 'COMPLETED').to_a and true
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



#query
u =User.where("courses" => { "$size" => 1}, "courses" => { "$size" => 2 }).first
all = User.collection.find({ "courses.15" => { "$exists" => true } }).to_a
top100 = all.sort_by { |x| -x["courses"].count }.take(100)

ctp = []

top100.each { |u|
  obj = []
  obj << u["name"]
  obj << u["email"]
  obj << u["courses"].count

  ctp << obj
}

all = User.collection.find({ 
    "$or" => [ 
        { "courses" => { "$size" => 2 } },
        { "courses" => { "$size" => 1 } } 
    ]
}).to_a

ctp = []

all.each { |u|
  obj = []
  obj << u["name"]
  obj << u["email"]
  obj << u["courses"].count

  ctp << obj
}


all = Course.where(:created_at.gte => Time.new(2019,1,1)).to_a and true

#code mau ko dc sua
Course.collection.aggregate([
    {
      '$match' => 
        { '$and' => 
          [
            { 
              'created_at' => 
              { 
                '$gte' => Time.new(2019,1,1) 
              } 
            },
            { 'created_at' => 
              { 
                '$lt' => Time.new(2020,1,1) 
              } 
            }
          ]
        }
    },
    {
      "$group" => {
        "_id" => {
          "$month" => "$created_at" 
        },
        "count" => {"$sum" => 1}
      }
    },
    {
      "$sort" => { "_id" => 1}
    }
]).to_a


Course::Version.collection.aggregate([
    {
      '$match' => 
        { '$and' => 
          [
            { 
              'published_at' => 
              { 
                '$gte' => Time.new(2018,1,1) 
              } 
            },
            { 'published_at' => 
              { 
                '$lt' => Time.new(2020,1,1) 
              } 
            },
            {
              'version_course' => '1.0'
            },
            {
              'version' => 'public'
            }
          ]
        }
    },
    {
      "$group" => {
        "_id" => {
          "$month" => "$published_at" 
        },
        "count" => {"$sum" => 1}
      }
    },
    {
      "$sort" => { "_id" => 1}
    }
]).to_a


#change player
count = 0
all = Course.where(:version.ne => 'test').to_a and true

all.reverse.each { |c|
  c.curriculums.where(:type => 'lecture').each {  |cu|
    cu.update(:player => "")
  }

  p "#{count}/#{all.count}"
  count += 1
}

Course.where(:version => 'public').each { |c|
  v = c.versions.desc(:created_at).first
  if v.blank?
    p "DHS v blank"
  else
    v.primary_category_ids = c.primary_category_ids
    v.sub_category_ids = c.sub_category_ids
    v.save
  end
}

#publish uiza

c = Course.where(:code => 'SaBD.04').first
c = Course.find('58e1c352ce4b14341357e66c')
c = Course.where(:alias_name => 'khoa-hoc-autocad-co-ban-va-nang-cao').first
v = c.versions.desc(:created_at).first
lecture_index = 22

urls = c.curriculums.where(:type => 'lecture', :lecture_index => lecture_index ).pluck(:url)
urls = c.curriculums.where(:type => 'lecture').pluck(:url)

#format lai url cho chuan. cai url nay nhieu van de nay.
urls = urls.map { |x| x.gsub(/\?t=1490184458/,"") } 

libs = Library.where(:final_link.in => urls)
libs = Library.where(:final_link => '//d3c5ulldcb6uls.cloudfront.net/library-kelley-01-07-2016-phucnh.01v2/vl03master.m3u8')

urls.count
libs.count

uiza_api_upload = Constants::Uiza::API_UPLOAD
authorization = Constants::Uiza::API_TOKEN
uiza_api_publish = Constants::Uiza::API_PUBLISH

libs.each { |lib|
  RestClient.post(uiza_api_upload,{:name => lib.file_name,   :url => lib.origin_link, :inputType => 'http' }, {:Authorization => authorization}){ |response, request, result, &block|
    begin
      result = JSON.parse(response)

      data = result["data"]
      media_uiza_id = data["id"]
      lib.update(:media_uiza_id => media_uiza_id)
      p "#{media_uiza_id}: #{lib.final_link}"

      RestClient.post(uiza_api_publish,{:id => media_uiza_id }, {:Authorization => authorization}){ |response, request, result, &block| 
        lib.update(:published => true)
      }
    rescue 
      p "Dit con me hong roi co loi #{lib.id}"
    end

  }
}

#check published
libs.each { |lib|
  RestClient.get("https://edm.uiza.co/api/public/v3/media/entity/publish/status?id=#{lib.media_uiza_id}", { :Authorization => authorization }) { |response, request, result, &block|
    result = JSON.parse(response)

    data = result["data"]
    p data

  }
}

#gan lai vao trong curriculums
#becareful
res = []
# c.curriculums.where(:type => 'lecture').each { |cu|
c.curriculums.where(:type => 'lecture', :lecture_index => 3).each { |cu|
  l = Library.where(:final_link => cu.url.gsub(/\?t=1490184458/,"")).first
  unless l.blank?
    cu.media_uiza_id = l.media_uiza_id
    cu.save
    p cu.lecture_index
    res << cu.lecture_index
  end
}

#api search then save media_uiza_id to curriculums
url = 'https://edm-api.uiza.co/api/private/v3/media/entity/search?page=1&limit=150&keyword=PhucNH.01'
res = []


RestClient.get(url, { :Authorization => authorization }) { |response, request, result, &block|
  result = JSON.parse(response)

  data = result["data"]
  data.each { |o|
    entity_name = o["name"]
    if entity_name.include?("PhucNH.01")
      lecture_index = entity_name.gsub("b","").split("_")[1].to_i
      
      #be careful. this is not for all
      lecture_index += 1

      res << lecture_index

      p "lecture_index: #{lecture_index}"
      
      cu = v.curriculums.where(:lecture_index => lecture_index, :type => 'lecture').first
      cu2 = c.curriculums.where(:lecture_index => lecture_index, :type => 'lecture').first
      l = Library.where(:final_link => cu.url).first

      unless l.blank?
        if l.media_uiza_id.blank?
          l.media_uiza_id = o["id"]
          l.save
        else
          p "not update for library"
        end
      end

      unless cu.blank? 
        if cu.media_uiza_id.blank?
          p o["id"]
          cu.update(:media_uiza_id => o["id"])
        end
      else
        p "Cu blank"
      end
    end
  }
}

#publish by code

list = ['Alphabook.16',
'Alphabooks.02',
'Alphabooks.15',
'AnhBT.01',
'AnhCV.01']
name = ['Phân tích thẩm định dự án đầu tư',
'Luật cạnh tranh']
Course.where(:name.in => name).each { |c|

  p "before: #{c.code}: #{c.primary_category_ids} - #{c.sub_category_ids}"
  
  v = c.versions.desc(:created_at).first

  fields = [
    :note, :type, :code, :instructor_code, :num_lecture, :course_goal,
    :name, :lang, :price, :alias_name, :sub_title, :level, :image, :intro_link,
    :requirement, :intro_image, :duration, :enabled_second_logo, :second_logo,
    :benefit, :audience, :labels_order, :related, :enabled_logo,
    :enabled, :version, :user_id, :category_ids, :label_ids, :primary_category_ids, :sub_category_ids,
    :quizzes, :description_editor, :short_description_editor, :description_raw
  ]
  fields.each do |field|
    c[field] = v[field]
  end

  c.curriculums = v.curriculums
  c.current_version = v.version_course
  c.publish
  c.save

  p "after: #{c.code}: #{c.primary_category_ids} - #{c.sub_category_ids}"
}

not_have_ecm_id = 0
not_have_user_id =  0
not_have_user = 0

#
Review.where(:ecommerce_id => nil).each { |r|
  if r.course.ecommerce_id.blank?
    not_have_ecm_id += 1
    p not_have_ecm_id
  elsif r.user_id.blank?
    not_have_user_id += 1
    p not_have_user_id
  elsif r.user.blank?
    not_have_user += 1
    p not_have_user
  end
}

ctp = [["Code", "Name", "Pri Course", "Sub course", "pri course version", "sub course version"]]

#danh sach nhugn khoa hoc co primary id nil hoac sub nil
Course.where(:version.ne => "test").each { |c|
  if !(c.version == 'public' and c.enabled == false)
    obj = []

    obj << c.code
    obj << c.name
    obj << c.versions.first.published_at

    ctp << obj
  end
}

Course.where(:version => 'public', :enabled => true).any_of({ :primary_category_ids.in => [nil, []]} , {:sub_category_ids.in => [nil,[]]}).each { |c|
  obj = []

  obj << c.code
  obj << c.name
  obj << c.primary_category_ids.to_s
  obj << c.sub_category_ids.to_s
  obj << c.versions.desc(:created_at).first.primary_category_ids.to_s
  obj << c.versions.desc(:created_at).first.sub_category_ids.to_s

  ctp << obj
}


########################
#fake user

listnguoinha = ["Đinh Phương Toàn", "Trần Quang Hợp", "Nguyễn Khắc Quang", "Lê Minh Quang", "Nguyễn Đa Long", "Đỗ Trung Hòa", "Nguyễn Thị Loan", "Bùi Hồng Quân", "Nguyễn Việt Đức",
  "Đào Thành Luân", "Nguyễn Anh Tuấn", "Vũ Văn Phước", "Trương Lâm Vũ", "Lê Tuấn Vũ", "Tùng Cẩ Rô", "Lê Cao Hoàng", "Đinh Luân", "Đinh Đức Nam", 
  "Bùi Chí Hoa", "Đáp Phạm", "Dzung Nguyễn", "Trần Thị Hương"
]


50.times {
  u = User.new 
  u.email = "lkladykilllah#{rand(100000)}@gmail.com"
  u.password = '1234567'
  u.name = "#{listnguoinha[rand(listnguoinha.count)]}"
  u.save
}

#benchmark
puts Benchmark.measure {
  User.count
}