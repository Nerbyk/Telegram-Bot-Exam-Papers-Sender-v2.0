Sequel.migration do 
    change do 
        create_table? :user_messages do 
            foreign_key :user_id, :users, null: false
            Date   :created
            String :name
            String :link
            String :subjects
            String :photo
        end
    end 
end 