# Sequel.migration do 
#     change do 
#         alter_table :user_messages do 
#             add_foreign_key :user_id, :users
#         end
#     end
# end 


Sequel.migration do 
    change do 

        from(:user_config).each do |row| 
            row[:user_name] = 'n/a' if row[:user_name].nil? 
            if row[:status] == 'accepted' || row[:status] == 'banned'
                from(:users).insert(user_id: row[:user_id].to_i,
                                user_name: row[:user_name],
                                role: 'user',
                                status: row[:status])
                row[:subjects] = row[:subjects].gsub(' ', ';')
                from(:user_messages).insert(user_id: row[:user_id].to_i,
                                        created: Date.today,
                                        name: row[:name],
                                        link: row[:link], 
                                        subjects: row[:subjects],
                                        photo: row[:image])
            else
                from(:users).insert(user_id: row[:user_id].to_i,
                    user_name: row[:user_name],
                    role: 'user',
                    status: 'logged')
            end
        end
    end 
end 