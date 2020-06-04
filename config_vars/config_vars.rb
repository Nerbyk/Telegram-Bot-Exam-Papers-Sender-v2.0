# frozen_string_literal: true

module CfgConst
  class BotButtons
    ADD_ADMIN = 'Add Admin'
    DELETE_ADMIN = 'Delete Admin'
    ADD_SUBJECT = 'Add Subject'
    EDIT_SUBJECT = 'Delete Subject'
  end

  class BotCommands
    START = '/start'
    MANAGE_ADMINS = '/manage_admins'
    UPDATE_DOCUMENTS = '/update_documents'
  end

  class Roles
    ADMIN = 'admin'
    USER  = 'user'
    DEV   = 'dev'
    MODERATOR = 'moderator'
  end
end
