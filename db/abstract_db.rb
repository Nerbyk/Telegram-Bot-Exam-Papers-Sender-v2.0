class Db 
    def initialize
        @db = Sequel.sqlite('./db/user_config.db')
    end
end