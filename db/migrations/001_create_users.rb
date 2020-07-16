Sequel.migration do 
    change do 

        create_table? :users do 
            primary_key :user_id 
            String :user_name
            String :role
            String :status
        end
 
    end
end