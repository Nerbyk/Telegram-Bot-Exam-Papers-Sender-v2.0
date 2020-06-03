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
