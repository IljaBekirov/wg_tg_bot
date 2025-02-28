# frozen_string_literal: true

module TariffFiles
  class BulkUploadService
    Result = Struct.new(:success?, :tariff_file, :error_message, keyword_init: true)

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
      @tariff_file = TariffFile.new(tariff_id: params[:tariff_id])
    end

    def call
      return empty_files_result if filtered_files.empty?

      process_files(filtered_files)
    end

    private

    def filtered_files
      @params[:files].reject { |f| f.blank? || f == '' }
    end

    def empty_files_result
      Result.new(
        success?: false,
        tariff_file: @tariff_file,
        error_message: 'Пожалуйста, выберите хотя бы один файл.'
      )
    end

    def process_files(files)
      files.each do |file|
        tariff_file = TariffFile.new(file: file, tariff_id: @params[:tariff_id])
        return failed_save_result(tariff_file) unless tariff_file.save
      end
      Result.new(success?: true)
    end

    def failed_save_result(tariff_file)
      Result.new(
        success?: false,
        tariff_file: tariff_file,
        error_message: tariff_file.errors.full_messages.join(', ')
      )
    end
  end
end
