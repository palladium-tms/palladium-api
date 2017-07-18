# class must be autonomic. It contains some encrypt methods
module Encrypt
  # encrypt data by MD5 algoritm. Change it in production
  def self.encrypt(data)
    Digest::MD5.hexdigest(data)
  end
end
