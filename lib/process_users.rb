require 'date'
require 'csv'
require 'email_address'

def upload_csv(file)
end

def check_accented_char(name)
  accented_letters = 'ŠšŽžÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝŸÞàáâãäåæçèéêëìíîïñòóôõöøùúûüýÿþƒ'
  without_accents = 'SsZzAAAAAAACEEEEIIIINOOOOOOUUUUYYBaaaaaaaceeeeiiiinoooooouuuuyybf'
  name.tr(accented_letters,without_accents)
end

def check_email(user_email)
  EmailAddress.valid?(user_email)
end

def create_influencer(user_row)
  email = user_row[7]
  if !check_email(email)
    # write invalid email to file and return
  else

  end
end
