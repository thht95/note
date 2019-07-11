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