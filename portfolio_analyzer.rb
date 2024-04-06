require 'json'
require 'net/http'
require 'uri'
require 'date'

API_BASE_URL = "https://fintual.cl/api/real_assets".freeze
MAX_MONTHS_SEARCH = 50
DATE_FORMAT = '%Y-%m-%d'

# Initializes a cache to store the values of the share_value
$share_value_cache = {}

# Obtain the value of the share_value, using cache
def get_fund_value(fund_id, target_date_str, max_months = MAX_MONTHS_SEARCH)
  # Generates a unique key for the cache
  cache_key = "#{fund_id}_#{target_date_str}"

  # Checks if the value is already in the cache
  return $share_value_cache[cache_key] if $share_value_cache.key?(cache_key)

  target_date = Date.strptime(target_date_str, DATE_FORMAT)

  # Try to obtain the value for the specific day
  uri_single_day = URI("#{API_BASE_URL}/#{fund_id}/days?date=#{target_date_str}")
  response_single_day = Net::HTTP.get(uri_single_day)
  data_single_day = JSON.parse(response_single_day) rescue nil

  if data_single_day && data_single_day['data'] && !data_single_day['data'].empty?
    # Cache and return
    $share_value_cache[cache_key] = data_single_day['data'].first['attributes']['price']
    return $share_value_cache[cache_key]
  else
    # If it does not find the value for the specific day, expand the search in a date range
    (1..max_months).each do |month_increment|
      from_date = (target_date - (15 * month_increment)).strftime(DATE_FORMAT)
      to_date = (target_date + (15 * month_increment)).strftime(DATE_FORMAT)
      
      uri_range = URI("#{API_BASE_URL}/#{fund_id}/days?from_date=#{from_date}&to_date=#{to_date}")
      response_range = Net::HTTP.get(uri_range)
      data_range = JSON.parse(response_range) rescue nil
      
      if data_range && data_range['data'] && !data_range['data'].empty?
        closest_entry = data_range['data'].min_by { |entry| (Date.parse(entry['attributes']['date']) - target_date).abs }
        if closest_entry
          # Cache and return
          $share_value_cache[cache_key] = closest_entry['attributes']['price']
          return $share_value_cache[cache_key]
        end
      end
    end
  end

  # If it does not find a value, it prints a message and returns nil
  puts "No se encontró un valor para el fondo #{fund_id} cerca de la fecha #{target_date_str}."
  $share_value_cache[cache_key] = nil
  return nil
end

# Calculate the profit of a portfolio
def calculate_gain_for_portfolio(portfolio, start_date, end_date, initial_amount, fund_ids)
  final_amount = initial_amount

  portfolio.each do |fund, weight|
    start_value = get_fund_value(fund_ids[fund], start_date)
    end_value = get_fund_value(fund_ids[fund], end_date)
    if start_value && end_value
      # Calculates fund growth
      growth_rate = end_value.to_f / start_value
      # Apply growth to the amount invested in this specific fund
      fund_contribution = initial_amount * weight * growth_rate
      # Accumulates the final amount, adding the growth of each fund
      final_amount += fund_contribution - (initial_amount * weight)
    else
      puts "No se pudo obtener el valor de la cuota para el fondo #{fund} en alguna de las fechas."
      return nil
    end
  end

  # Returns the net profit
  gain = final_amount - initial_amount
  return gain
end

# Load portfolios and calculate profit
file = File.read('portfolios.json')
portfolios = JSON.parse(file)

# Default values
default_start_date = '06/04/2023'
default_end_date = '06/04/2024'
# default_end_date = Date.today.strftime('%d/%m/%Y')
default_initial_amount = 100000

start_date = ARGV[0] || default_start_date
end_date = ARGV[1] || default_end_date
initial_amount = ARGV[2] ? ARGV[2].to_i : default_initial_amount

start_date_api = Date.strptime(start_date, '%d/%m/%Y').strftime(DATE_FORMAT)
end_date_api = Date.strptime(end_date, '%d/%m/%Y').strftime(DATE_FORMAT)

fund_ids = {
  'risky_norris' => '186',
  'moderate_pitt' => '187',
  'conservative_clooney' => '188',
  'very_conservative_streep' => '15077'
}

# Determine the best portfolio
best_gain = 0
best_portfolio_index = nil
best_portfolio = nil

portfolios.each_with_index do |portfolio, index|
  gain = calculate_gain_for_portfolio(portfolio, start_date_api, end_date_api, initial_amount, fund_ids)
  
  if gain and (gain > best_gain)
    best_gain = gain
    best_portfolio_index = index
    best_portfolio = portfolio
  end
end

if best_portfolio
  puts "El portafolio con mayor ganancia es el ##{best_portfolio_index + 1} con una ganancia de $#{best_gain.round(2)}"
else
  puts "No fue posible determinar el portafolio con mayor ganancia."
end