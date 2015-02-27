class OrderNotifier < ActionMailer::Base
  default from: "admin@depot.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_notifier.received.subject
  #
  def received(order)
    @order = order

    mail to: order.email, subject: 'Pragmatic Store Order Confirmation'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_notifier.shipped.subject
  #
  def shipped(order)
    @order = order

    mail to: order.email, subject: 'Pragmatic Store Order Shipped'
  end

  def notify_admin_email_error(order)
    @order = order

    mail to: 'haifeng.zhao@truepartner.cn', subject: '[Depot][Error] Email Notification Failed'
  end
end
