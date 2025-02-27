module UsersHelper
  def telegram_username_link(user, fallback: 'Не указан', link_options: {})
    return fallback unless user&.username&.present?

    username = user.username
    default_options = {
      target: '_blank',
      class: 'telegram-link',
      rel: 'noopener noreferrer'
    }

    link_to "@#{username}", telegram_url(username), default_options.merge(link_options)
  end

  private

  def telegram_url(username)
    "https://t.me/#{username}"
  end
end
