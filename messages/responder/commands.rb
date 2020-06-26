# frozen_string_literal: true

class Command
  attr_reader :request, :options
  def initialize(request, options = nil)
    @request = request
    @options = options
  end

  def execute
    raise NotImplementedError
  end
end

# Common commands
class StartCommand < Command
  def execute
    command = options[:role].downcase + '_start'
    request.send(command)
  end
end

# Admin commands
class ManageAdminsCommand < Command
  def execute
    request.admin_manage_admins
  end
end

class UpdateDocumentsCommand < Command
  def execute
    request.admin_update_documents
  end
end

class UpdateLinkCommand < Command
  def execute
    request.admin_update_link
  end
end

class SetAlertAmountCommand < Command
  def execute
    request.admin_set_alert_amount
  end
end

# Admin actions
class AddAdminAction < Command
  def execute
    request.add_admin_action
  end
end

class DeleteAdminAction < Command
  def execute
    request.delete_admin_action
  end
end

class AddSubjectAction < Command 
  def execute 
    request.add_subject_action
  end
end

class DeleteSubjectAction < Command 
  def execute 
    request.delete_subject_action
  end
end

class UpdatLinkAction < Command 
  def execute 
    request.update_link_action 
  end
end

class SetAlertAction < Command 
  def execute 
    request.set_alert_action
  end
end

# User Commands
