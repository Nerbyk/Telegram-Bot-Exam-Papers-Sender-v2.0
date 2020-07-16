
Sequel.migration do 
    change do 
        drop_table :user_config 
    end 
end 