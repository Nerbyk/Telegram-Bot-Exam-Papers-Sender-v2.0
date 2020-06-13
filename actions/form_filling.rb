# frozen_string_literal: true

class Form
  def start
    UserConfigDb.instance.get_role # to initialize new user in DB
    send(UserConfigDb.instance.get_status)
  end

  private

  def logged
    # changing default status
    UserConfigDb.instance.set_status(status: CfgConst::Status::NAME)
  end

  def name_step; end

  def link_step; end

  def subjects_step; end

  def photo_step; end

  def in_queue; end

  def accepted; end

  def banned; end
end
