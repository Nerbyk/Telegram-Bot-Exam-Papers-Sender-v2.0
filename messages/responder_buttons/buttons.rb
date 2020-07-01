# frozen_string_literal: true

class Button
  def initialize(request)
    @request = request
  end

  protected

  attr_reader :request
  def execute
    raise NotImplementedError
  end
end
# Admin Buttons
class AddAdminButton < Button
  def execute
    request.add_admin
  end
end

class DeleteAdminButton < Button
  def execute
    request.delete_admin
  end
end

class AddSubjectButton < Button
  def execute
    request.add_subject
  end
end

class EditSubjectButton < Button
  def execute
    request.edit_subject
  end
end

# User Buttons

class StartNostrButton < Button
  def execute
    request.start_nostrification
  end
end

class StartAdButton < Button
  def execute
    request.start_advertisement
  end
end

class SendRequestButton < Button
  def execute
    request.send_user_request
  end
end

class ResetRequestButton < Button
  def execute
    request.reset_user_request
  end
end
