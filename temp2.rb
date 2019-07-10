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
            # {  
            #     "attribute_code":"headline",
            #     "value": customer.headline
            # },
            {  
                "attribute_code":"profile_url",
                "value": customer.profile_url
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
                "attribute_code":"job",
                "value": customer.job
            },
            {  
                "attribute_code":"links",
                "value": customer.links.to_s
            },
            {  
                "attribute_code":"unread_notification",
                "value": customer['unread_notification'].to_s
            },
            {  
                "attribute_code":"seller_teacher_rev_share",
                "value": customer['seller_teacher_rev_share'].to_s
            },
            {  
                "attribute_code":"seller_topica_rev_share",
                "value": customer['seller_topica_rev_share'].to_s
            },
            {  
                "attribute_code": "vn_able",
                "value": customer['vn_able'].to_s
            },
            {  
                "attribute_code": "wishlist",
                "value": customer.wishlist.to_s
            },
            {  
                "attribute_code": "allot_ratio_instructor",
                "value": customer['allot_ratio_instructor'].to_s
            },
            {  
                "attribute_code": "allot_ratio_default",
                "value": customer['allot_ratio_default'].to_s
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