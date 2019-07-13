require 'sqlite3'

class FraudDetector
  attr_reader :last_name, :postcode, :card_number, :card_expiry

  def initialize(last_name, postcode, card_number, card_expiry)
    @name_upper = last_name.upcase
    @name_lower = last_name.downcase
    @postcode = postcode.gsub(/\s+/, '')
    @card_number = card_number
    @card_expiry = card_expiry
    @id_number = 0
  end

  DB = SQLite3::Database.open('app/db.sqlite')

  def fraudulent?
    # TODO. Return true if they are fraudulent.
    true if name_postcode == true || name_card == true || postcode_card == true
  end

  private

  # Fraudulent? methods
  def name_postcode
    matching_name_ids = check_name.map { |item| item[0] }
    if matching_name_ids.length.positive?
      matching_name_ids.each do |id|
        @id_number = id
        return true if query_postcode.gsub(/\s+/, '') == @postcode
      end
    end
  end

  def name_card
    matching_name_ids = check_name.map { |item| item[0] }
    if matching_name_ids.length.positive?
      matching_name_ids.each do |id|
        @id_number = id
        return check_whole_card if query_card_number == @card_number
      end
    end
  end

  def postcode_card
    users = query_users
    users.each do |user|
      @id_number = user[0]
      if query_postcode.gsub(/\s+/, '') == @postcode
        return check_whole_card if query_card_number == @card_number
      end
    end
  end

  # DB Queries
  def query_users
    DB.execute('SELECT * FROM users')
  end

  def query_postcode
    DB.execute("SELECT DISTINCT postcode FROM users
      LEFT JOIN addresses
      ON #{@id_number} = addresses.user_id;")[0][0]
  end

  def query_card_number
    DB.execute("SELECT DISTINCT last_four_digits FROM users
      LEFT JOIN credit_cards
      ON #{@id_number} = credit_cards.user_id;")[0][0]
  end

  def query_card_month
    DB.execute("SELECT DISTINCT expiry_month FROM users
      LEFT JOIN credit_cards
      ON #{@id_number} = credit_cards.user_id;")[0][0]
  end

  def query_card_year
    DB.execute("SELECT DISTINCT expiry_year FROM users
      LEFT JOIN credit_cards
      ON #{@id_number} = credit_cards.user_id;")[0][0]
  end

  # ----------------------------------------------------------------------------

  def check_name
    DB.execute("SELECT * FROM users
      WHERE last_name = '#{@name_upper}'
      OR last_name = '#{@name_lower}'")
  end

  def two_digit_month(expiry_month)
    "0#{expiry_month}"
  end

  def two_digit_year(expiry_year)
    expiry_year.gsub(/^.{0,2}/, '')
  end

  def split_expiry(expiry)
    expiry = @card_expiry.split('/')
    expiry[0] = two_digit_month(expiry[0]) if expiry[0].length == 1
    expiry[1] = two_digit_year(expiry[1]) if expiry[1].length == 4
    expiry
  end

  def check_whole_card
    expiry_date = split_expiry(@card_expiry)
    month = query_card_month
    year = query_card_year
    return true if query_card_month == expiry_date[0] && query_card_year == expiry_date[1]

    month = two_digit_month(query_card_month) if query_card_month.length == 1
    year = two_digit_year(query_card_year) if query_card_year.length == 4
    return true if month == expiry_date[0] && year == expiry_date[1]
  end

  customer = FraudDetector.new('smith', 'SW18 3FR', 7835, '02/2020')

  p customer.fraudulent?
end
