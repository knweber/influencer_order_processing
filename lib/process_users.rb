require 'date'
require 'csv'
require 'email_address'

def process_users(user_csv_data)
  user_mapping = {
        first_name: user[0],
        last_name: user[1],
        address1: user[2],
        address2: user[3],
        city: user[4],
        state: user[5],
        zip: user[6],
        email: user[7],
        phone: user[8],
        bra_size: user[9],
        top_size: user[10],
        bottom_size: user[11],
        sports_jacket_size: user[12],
        three_item: user[13]
      }

  user_csv_data.each do |user|
    if check_email(user[7])
      check_accented_char(user[0])
      check_accented_char(user[1])
      three_item_to_bool(user[13])
      puts "New Influencer"
    else
      # write records to file and redirect w/error
      return false
    end
  end
end

def three_item_to_bool(user_three_item)
  if user_three_item.downcase == "yes" || user_three_item.downcase == "y"
    user_three_item = true
  else
    user_three_item = false
  end
end

def check_accented_char(name)
  accented_letters = 'ŠšŽžÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝŸÞàáâãäåæçèéêëìíîïñòóôõöøùúûüýÿþƒ'
  without_accents = 'SsZzAAAAAAACEEEEIIIINOOOOOOUUUUYYBaaaaaaaceeeeiiiinoooooouuuuyybf'
  name.tr(accented_letters,without_accents)
end

def check_email(user_email)
  EmailAddress.valid?(user_email)
end
