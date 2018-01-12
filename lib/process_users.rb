require 'date'
require 'csv'

def process_users(user_csv_data)
  File.open('/tmp/invalid_emails.txt','a+') do |file|
    file.truncate(0)
  end
  # user_mapping = {
  #       first_name: user_csv_data[0],
  #       last_name: user_csv_data[1],
  #       address1: user_csv_data[2],
  #       address2: user_csv_data[3],
  #       city: user_csv_data[4],
  #       state: user_csv_data[5],
  #       zip: user_csv_data[6],
  #       email: user_csv_data[7],
  #       phone: user_csv_data[8],
  #       bra_size: user_csv_data[9],
  #       top_size: user_csv_data[10],
  #       bottom_size: user_csv_data[11],
  #       sports_jacket_size: user_csv_data[12],
  #       three_item: user_csv_data[13]
  #     }

  if check_email(user_csv_data)
    user_csv_data.each do |user|
      three_item_to_bool(user[13])
      new_influencer = Influencer.new(
        {
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
      )
      if new_influencer.valid?
        new_influencer.save
        puts "New Influencer: #{new_influencer.first_name} #{new_influencer.last_name}, #{new_influencer.email}"
      end
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

def check_email(users)
  filename = '/tmp/invalid.txt'
  users.each do |user|
    email = user[7]
    if email.include?("example") || email.include?("gmaill") || email.include?("..")
      File.open(filename,'a+') do |file|
        file.write("\n")
        file.write(user[0] + " " + user[1] + ", " + user[7])
      end
    end
  end
  data = File.read(filename)
  if data.length != 0
    return false
  else
    return true
  end
end
