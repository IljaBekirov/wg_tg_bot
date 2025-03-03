# frozen_string_literal: true

module TariffFiles
  class Presenter
    ENABLED_ICON = '✅'
    DISABLED_ICON = '❌'
    INDEFINITE_TEXT = 'Бессрочно'
    DATE_FORMAT = '%d %B %Y, %H:%M'

    def initialize(tariff_file)
      @tariff_file = tariff_file
    end

    def build_text_key
      return INDEFINITE_TEXT unless @tariff_file

      icon = status_icon
      text = expired_at_text
      "#{icon} #{text}"
    end

    private

    def status_icon
      @tariff_file.enabled? ? ENABLED_ICON : DISABLED_ICON
    rescue NoMethodError
      Rails.logger.warn("Tariff file #{@tariff_file&.id} does not respond to :enabled?")
      DISABLED_ICON
    end

    def expired_at_text
      if @tariff_file.expired_at.present?
        @tariff_file.expired_at.strftime(DATE_FORMAT)
      else
        INDEFINITE_TEXT
      end
    end
  end
end
