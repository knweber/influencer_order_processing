require 'date'
require 'csv'

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

def check_required_fields(user)
  user[0] && user[1] && user[2] && user[4] && user[5] && user[6] && user[7] && user[9] && user[10] && user[11] && user[12] && user[13] && (user[6].length == 5 || user[6].length == 10)
end

def create_user(user)
  email = user[7]
  if !Influencer.find_by(email: email)
    if check_required_fields(user)
      three_item_to_bool(user[13])
      new_influencer =
      Influencer.new({
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
      })
      if new_influencer.valid?
        new_influencer.save
        new_influencer
      else
        return false
      end
    end
  end
end
