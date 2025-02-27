# frozen_string_literal: true

module NavigationHelper
  NAV_ITEMS = [
    { title: 'Пользователи', path: :users_path },
    { title: 'Заказы', path: :orders_path },
    { title: 'Тарифы', path: :tariffs_path },
    { title: 'Файлы', path: :tariff_files_path }
  ].freeze

  def sidebar_navigation
    content_tag(:aside, class: 'sidebar') do
      content_tag(:nav, class: 'sidebar-nav') do
        content_tag(:ul) do
          NAV_ITEMS.map do |item|
            content_tag(:li) do
              link_to item[:title], send(item[:path]),
                class: "sidebar-link #{active_class(send(item[:path]))}"
            end
          end.join.html_safe
        end
      end
    end
  end

  private

  def active_class(path)
    request.path.start_with?(path) ? 'active' : ''
  end
end
