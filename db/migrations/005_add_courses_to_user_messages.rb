
Sequel.migration do 
    change do 
         add_column :user_messages, :courses, String
    end 
end 