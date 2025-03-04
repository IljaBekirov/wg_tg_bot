# frozen_string_literal: true

class TariffFileCreator
  Result = Struct.new(:success?, :created_count, :errors, keyword_init: true)

  def initialize(server_service, params)
    @server_service = server_service
    @base_name = params[:name]
    @quantity = params[:quantity].to_i.clamp(1, Float::INFINITY)
  end

  def create_configs
    created_names = create_clients
    return failure_result(0, ['Не удалось создать ни одного конфига']) if created_names.empty?

    clients = fetch_clients
    created_files, errors = process_configs(created_names, clients)

    Result.new(
      success?: errors.empty?,
      created_count: created_files.count,
      errors: errors
    )
  end

  private

  def create_clients
    created_names = []
    @quantity.times do |i|
      name = generate_unique_name("#{@base_name}_#{i + 1}")
      created_names << name if @server_service.create_client(name).success?
    end
    created_names
  end

  def fetch_clients
    @server_service.get_clients || []
  end

  def process_configs(names, clients)
    errors = []
    files = names.map do |name|
      client_data = clients.find { |client| client['name'] == name }
      if client_data
        create_config_or_log_error(name, client_data, errors)
      else
        nil.tap { errors << "Конфиг #{name} не найден" }
      end
    end.compact
    [files, errors]
  end

  def create_config_or_log_error(name, client_data, errors)
    create_single_config_with_data(name, client_data)
  rescue StandardError => e
    errors << "Ошибка для #{name}: #{e.message}"
    nil
  end

  def create_single_config_with_data(name, client_data)
    attrs = { name: name,
              wg_uuid: client_data['id'],
              expired_at: client_data['expiredAt'],
              enabled: client_data['enabled'] }
    tariff_file = TariffFile.new(attrs)
    config_file = @server_service.configuration(tariff_file.wg_uuid)
    tariff_file.file.attach(io: StringIO.new(config_file), filename: "#{name}.conf")
    tariff_file.save!
    tariff_file
  end

  def generate_unique_name(base_name)
    "#{base_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}_#{SecureRandom.hex(4)}"
  end

  def failure_result(count, errors)
    Result.new(success?: false, created_count: count, errors: errors)
  end
end
