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

# User Commands
