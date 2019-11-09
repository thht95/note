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