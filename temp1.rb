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

#clear media_uiza_id
c = Course.where(:alias_name => x).first
c = Course.where(:code => x).first
c.curriculums.update_all(:media_uiza_id => false)

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

  p count
  count += 1 



  ctp << obj
}


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
} and true

#write csv
CSV.open("data_rating.csv", "w") do |row|
  ctp.each { |c|
    row << c

    #if c is not an array use [c]
  }
end

/(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z|^(0|84|\+84)+(\d{9}|\d{10})$)/i


b = []

#logic % complete course progress
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
# scp -P 2122 rails@sgkelley2.edumall.vn:~/kelley/current/EPS-12735.csv .
# scp rails@sgservreview.edumall.vn:~/tudemy/current/ratinggggg.csv

u = User.where(:email => 'huongdannotcainaydi@gmail.com').first
course = Course.where(:code => 'HanhPT.03').first
u.create_new_owned_course(course)

#create cod code
#openvpn

#10 code - 5 khoa => 2 code => 1 khoa
#run this on antman
9.times { |i|
  c = Cod.new
  # c.course_id = "Combo_QuyenVN.01_NgocPTN.01_ThongJ.01"
  c.course_id = '59098730ce4b141e4e43cd16'
  c.cod = "kodu#{i}kitu"  
  c.expired_date = Time.now + 1.year
  c.savessss
}

["5d52b6",
"046806",
"7e958c",
"5441bd",
"66d66e",
"48bfc8",
"33f961",
"1fd821",
"4b2a62",
"4b9a6b"]



insert into file(file_type, name, status, url, folder_id) values (0, "cailonkhonglacailonvutdi.mp4", 1, "abc.com/cailonkhonglacailonvutdi.mp4", 2);
insert into folder(name, parent_folder_id) values ("gau gau", 1)
insert into category(`alias`, `name`) values 
  ("cong_nghe_thong_tin", "Công nghệ thông tin"),
  ("ngoai_ngu", "Ngoại ngữ"),
  ("am_nhac", "Âm nhạc"),
  ("the_thao_suc_khoe", "Thể thao - sức khỏe")
  

#run this on jackfruit
9.times { |i|
list.each { |i|
  p = Payment.new 
  p.email = 'hoadt9@topica.edu.vn'
  p.method = 'cod'
  p.status = 'success'
  p.cod_version = 'new'
  p.cod_code = "49435d" 
  p.course_id = "59098730ce4b141e4e43cd16"
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
all = Library.where(:label_id => label.id, :type => 'video', :state.ne => 'COMPLETED').to_a.take(2) and true
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

lib = Library.where(:created_at.gte => Time.now - 1.day, :job_id => "create_job_fail").first



#query
u =User.where("courses" => { "$size" => 1}, "courses" => { "$size" => 2 }).first
all = User.collection.find({ "courses.1" => { "$exists" => true } }).to_a
top100 = all.sort_by { |x| -x["courses"].count }.take(100)

#search how many person have a course 
course = Course.where(:code => 'ThaiCD.02').first and true 
u = User.where("courses.course_id" => course.id).count

Course.where("curriculums.")


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


#query data user 
user_in_2k19 = User.where(:created_at.gte => Time.new(2019,1,1), "courses.course_id" => { "$ne" => nil })

utp = User.where(:created_at.gte => Time.now - 1.months, "courses.course_id" => { "$ne" => nil }).limit(50).pluck(
  :id,
  :email,
  :sign_in_count,
  :current_sign_in_at,
  :last_sign_in_at,
  :current_sign_in_ip,
  :last_sign_in_ip,
  :name,
  :mobile,
  :avatar,
  :meta_data
)


ctp = [["id","email","sign_in_count","current_sign_in_at","last_sign_in_at", "current_sign_in_ip", "last_sign_in_ip", "name", "mobile", "avatar", "meta_data", "number of payment", "number of course"]]

count_log = 0
all_count = utp.count

utp.each { |u|
  count_log += 1
  p "#{count_log}/#{all_count}"
  khong_cai_lon = 1
  
  obj = u 
  obj << Payment.where(:email => u[1]).count 
  obj << User.find(u[0]).courses.count

  ctp << obj
}

payments = Payment.where(:created_at.gte => Time.now - 2.month).limit(50).pluck(
  :id,
  :created_at,
  :name,
  :email,
  :mobile,
  :address,
  :money,
  :user_id,
  :course_id,
  :method,
  :status
) and true

ctp = [["id",
"created_at",
"name",
"email",
"mobile",
"address",
"money",
"user_id",
"course_id",
"method",
"status"]]


payments.each { |p|
  ctp << p
}



#spring.jpa:
#  properties:
#     hibernate:
#        dialect: org.hibernate.dialect.MySQL5InnoDBDialect
#        id.new_generator_mappings: false
#        format_sql: true
#  hibernate:
#     ddl-auto: create

1. Chinh lai config db thanh production cua jackfruit     
2. Chinh lai bien env                                     
3. Chinh lai config db thanh production cua ares          
4. Chinh lai data của review (wording)          

Question.where(:question => 'Góp ý của bạn dành cho giảng viên của Edumall').each { |q|
  # q.metadata["answers"] = ["Giáo trình đầy đủ", "Giải thích chi tiết", "Ngắn gọn, súc tích", "Tốc độ phù hợp", "Áp dụng hiệu quả", "Giảng viên nhiệt tình", "Kỹ năng sư phạm tốt"]
  # q.metadata["answer"] = ["Thời lượng ngắn", "Chất lượng video", "Cấu trúc khóa học", "Kiến thức chưa chuẩn", "Khối lượng kiến thức ít", "Thiếu ví dụ thực tế"]
  # q.metadata["answer"] = ["Giảng dạy không hấp dẫn", "Sử dụng ngôn từ khó hiểu", "Không nhiệt tình hỗ trợ", "Lặp đi lặp lại"]
  q.metadata["answer"] = ["Kiến thức chuyên môn", "Kỹ năng truyền đạt", "Giọng nói khó nghe", "Nói hơi nhanh/chậm"]
  q.save
}

#asset_host
nano /etc/default/unicorn

#file cloud/config-app/src/main/resources/application.yml
#     cloud/config-app/src/main/resources/application-local.yml
#edit searchLocations: file:./files-config-repo/


curl --location --request POST "https://code.edumall.vn/cod/create" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data "cod_code=kodu1kitu"

curl --location --request POST "http://localhost:8081/files/moveToFolder" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data "fileId=3&parentFolderId=1"

curl --location --request POST "http://localhost:8081/chapters/" \
  --header "Content-Type: application/json" \
  --data '{"title": "", "courseVersionId": 1}'

  curl --location --request PUT "http://localhost:8081/chapters/1" \
    --header "Content-Type: application/json" \
    --data '{"title": "neu ngay ay"}'

  curl --location --request POST "http://localhost:8081/folders/move2Folder" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data "folderId=4&parentFolderId=2"

curl --location --request DELETE "http://localhost:8081/chapters/28" 
curl --location --header "Authorization: Bearer 5a5d7b630e1266671b0006ff15707096426118" --request GET "https://sso.edumall.vn/sso/user_info"

  curl --location --request PUT "http://157.230.255.33:8890/api/lms/chapters/849" \
    --header "Content-Type: application/json" \
    --data '{"title": "gâu gâu"}'


curl -g "http://localhost:8081/api/file/detail?fileId=1"

curl -i -H "Accept: application/json" "localhost:3030/upload{filename: 'tbc_than_tai.jpg', filetype: 'image/jpeg'}" 

select status, count(*) as count from course_version cv 
join (
select cv.course_id, max(cv.created_at) created_at from course_version cv
left join teacher_course tc on tc.course_id = cv.course_id
left join teacher t on t.id = tc.teacher_id
left join user u on t.user_id = u.id
where u.id = 1
group by cv.course_id) a 
on a.course_id = cv.course_id and a.created_at = cv.created_at
group by status 
limit 1,1;

journalctl -u is-lms-api.service -f
scp -r root@167.71.202.58:/var/www/html/wp-content/uploads .

#cac buoc import data
- ssh vao server
- dump sql: `sudo mysqldump -u wordpress -p wordpress > user.sql`
- download sql ve may: `scp root@167.71.202.58:/var/www/html/user.sql .`
- import data vao trong mysql local (dung tool)
- export data ra file csv `SELECT * INTO OUTFILE 'export.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\' LINES TERMINATED BY '\n' FROM wp_users;`
- import data vao lai db mongo
- move file vao project

CSV.foreach("user.csv") do |row|
  u = User.where(:email => row[4]).first
  if u.blank? && u.valid_password?('12345678')
    u = User.new
    u.password = '12345678'
    u.email = row[4]
    u.username = row[3] 
    u.name = row[9]
    u.login_source = "hoptac"
    u.verified = true
    u.verified_at = Time.now
    unless u.save
      p u.errors
    else
      p u.email
      u.set(:encrypted_password => row[2])
    end
  else
    p "Da ton tai email #{row[1]}."
  end
end

CSV.foreach("user.csv") do |row|
  u = User.where(:email => row[4], :login_source => 'hoptac', :verified_at.gt => Time.now - 1.hour).first
  if u.present? && u.valid_password?('12345678')
      u.set(:encrypted_password => row[2])
  else
    p "Loi email #{row[4]}."
  end
end


# select name, id from sub_category;

list.each { |e|
  sub = SubCategory.where(:name => e[0]).first
  sub.set(:instr_id => e[1]) unless sub.blank?
}

curl -u hoadt9:hyp140313 -X GET -H "Content-Type: application/json" https://jira.topica.vn/rest/api/2/issue/createmeta




Kelley => Luna  =>  Vis      =>        Vis      =>       Luna           =>

File      Job      Transcode      Notification          Save job. Noti

Library


ctp = [["Course code", "User email", "User code"]]
all.each { |c|
  obj = [c.code]
  user = c.user
  unless user.blank?
    obj << user.email
    obj << user.username
  end

  ctp << obj
}

code = 'CO678179'
instr = 'INS682145'
Course.where(:code => code).first.update(:instructor_code => instr)
Course.where(:code => code).first.versions.desc(:created_at).first.update(:instructor_code => instr)


courses = Course.where(:version => 'public', :enabled => true, :code.nin => [/CO/]).to_a and true
count_succes = 0
count_fail = 0

courses.each { |course|
  if course.user.instr_id.blank? || course.user.instr_id == 0
    count_fail += 1
    p count_fail
    next
  end 

  if !course.user.blank? && !course.sub_categories.blank?
    payload  = {}
    payload["name"] = course.name
    payload["benefit"] = course.benefit.to_s
    payload["target"] = course.audience.to_s
    payload["requirement"] = course.requirement.to_s
    payload["shortDes"] = course.sub_title.blank? ? course.name : course.sub_title
    payload["longDes"] = course.description_editor
    payload["subCategoryId"] = course.sub_categories.first.instr_id
    payload["userId"] = course.user.instr_id
    payload["thumbnailImage"] = course.image
    payload["price"] = course.price
    payload["status"] = "PUBLISHED"
    payload["courseCode"] = course.code
    payload["kelly_id"] = course.id
    payload["chapters"] = []

    chapters = course.curriculums.where(:type => 'chapter').to_a
    chapters.each { |chapter|
      chapter_json =  {}
      chapter_json["title"] = chapter.title
      chapter_json["lectures"] = []

      lectures = course.curriculums.where(:type => 'lecture', :chapter_index => chapter.chapter_index).to_a
      lectures.each { |lecture|
        lecture_json = {}
        lecture_json["title"] = lecture.title
        lecture_json["assets"] = []

        lecture_asset = {}

        lecture_asset["asset_type"] = "VIDEO"
        lecture_asset["transcode_url"] = lecture.url
        lecture_asset["file"] = {
          "fileType": "VIDEO",
          "name": lecture.url,
          "url": lecture.url,
          "objectKey": "",
          "fileExtension": "mp4",
          "fileSize": "0",
          "duration": lecture.duration
        }

        lecture_json["assets"] << lecture_asset
        chapter_json["lectures"] << lecture_json
      }

      payload["chapters"] << chapter_json
    }

    RestClient.post("#{ENV["IS_DOMAIN"]}/courses/create-full-course", payload.to_json, headers={"Content-Type"=> "application/json"}){  |response, request, result, &block|
      if response.code == 200
        course.update(:instr_id => JSON.parse(response)["id"])
        count_succes += 1 
        p "success: #{count_succes}"
      else
        count_fail += 1
        p "fail: #{count_fail}"
        p "#{course.code} - #{response}"
      end
    }
  else
    p "fail: #{count_fail}"
    p "#{course.id} dont have teacher"
  end
}

#price uiza

count_all_lectures = 0
count_lecture_donthave_uiza = 0
count_lib_not_found = 0
count_lib_not_have_uiza_id = 0
list_lib_not_found = []

all = Course.where(:version => 'public', :enabled => true, :created_at.gte => Time.new(2019,1,1)).to_a and true
all.each { |c| 
  last_version = c.versions.desc(:created_at).first
  all_lecture = last_version.curriculums.where(:type => 'lecture').to_a
  all_media_uiza_id = all_lecture.map(&:media_uiza_id)
  if !all_media_uiza_id.include?(nil)
    count_all_lectures += all_lecture.count
  else
    all_lecture.each { |lecture|
      count_all_lectures += 1
      if lecture.media_uiza_id.blank?
        count_lecture_donthave_uiza += 1
        lib = Library.where(:final_link => lecture.url).first
        if lib.blank?
          count_lib_not_found += 1 
          list_lib_not_found << lecture.url
        else
          if lib.media_uiza_id.blank?
            count_lib_not_have_uiza_id += 1
          end
          # begin
          #   c.curriculums.where(:type => 'lecture', :lecture_index => lecture.lecture_index).first.update(:media_uiza_id => lib.media_uiza_id)
          # rescue
          #   p "Not found lecture on course"
          # end

          # last_version.curriculums.where(:type => 'lecture', :lecture_index => lecture.lecture_index).first.update(:media_uiza_id => lib.media_uiza_id)
        end
      end
    }
  end

  p "#{count_all_lectures} - #{count_lecture_donthave_uiza} - #{count_lib_not_found} - #{count_lib_not_have_uiza_id}"
}





all_map =  Instructor.where(:edumall_instructor_id.ne => nil).to_a and true
count = 0
all_map.each { |i|
  teacher = Teacher.where(:user_id => i.edumall_instructor_id).first

  unless teacher.blank?



  if teacher.blank?
    # teacher = Teacher.create(:code => i.code)
    t = Teacher.new
    t.user_id = i.edumall_instructor_id
    t.address = i.address
    t.code = i.code
    t.phone_number = i.mobile.first
    t.tax_identification_number = i.tax_number
    t.contact_email = i.email
    t.profile = Instructor::Student.where(:id => t.user_id).first.blank? ? "" : 


    unless i.bank_account.blank? 
      bank_account = i.bank_account.first

      t.bank_account_name = bank_account["account_name"]
      t.bank_account_number = bank_account["account_number"]
      t.bank_name = bank_account["bank_name"]
    end

    if i.company_info.blank? || i.company_info.name.blank?
      t.type = "individual"
      t.gender = i.gender == "man" ? "1" : "0"
      t.date_of_birth = i.birthday

      t.identification_number = i.cmnd
      t.identification_date_receive = i.cmnd_date
      t.identification_place_receive = i.cmnd_local
    else
      t.type = "company"
      t.company_name = i.company_info.name
      t.representative = i.company_info.representative
      t.representative_level = i.company_info.position
      t.contact_name = i.name
    end

    
    if t.save
      count += 1
      p "#{count}" 
    else
      p "fail #{i}"
    end
  end
}

Teacher.all.each { |x|
  u = x.user

  next if u.blank?

  u.phone_number = x.phone
  
}
  ip = u.instructor_profile

  next if ip.blank?

  x.profile = ip.description

  p x.profile

  x.save
}

project = EIS AND issuetype = Bug AND status in (Reopened, "TO DO", "Ready to test", "In Progress", NeedInfo, "Ready to review") ORDER BY priority DESC

ssh root@157.230.255.33 'cd /var/www/scripts && ./be_deploy.sh'
ssh root@206.189.149.24 'cd /var/www/scripts && ./be_deploy.sh'

ALTER TABLE annie.media_jobs MODIFY COLUMN params text
    CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL;