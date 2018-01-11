require 'date'
require 'csv'

def upload_csv(file)
end

def check_accented_char(name)
  accented_letters = 'ŠšŽžÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝŸÞàáâãäåæçèéêëìíîïñòóôõöøùúûüýÿþƒ'
  without_accents = 'SsZzAAAAAAACEEEEIIIINOOOOOOUUUUYYBaaaaaaaceeeeiiiinoooooouuuuyybf'
  name.tr(accented_letters,without_accents)
end

def create_influencer(user)
end
