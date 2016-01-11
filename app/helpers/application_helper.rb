module ApplicationHelper

  def body_data_dispatch
    [controller.controller_name, controller.action_name].compact.join(':')
  end

  def en?
    I18n.locale == :en
  end

  def demo?
    Rails.application.config_for(:application).fetch('demo')
  end
end
