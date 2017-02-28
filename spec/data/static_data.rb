
class StaticData
  ADDRESS = '0.0.0.0'
  PORT = 9292
  MAINPAGE = "http://#{ADDRESS}:#{PORT}"

  ALPHABET = ('a'..'z').to_a
end

class ErrorMessages
  UNCORRECT_LOGIN = "login or password is uncorrect"

  #region product
  UNCORRECT_PRODUCT_NAME = "is invalid"
  NOT_UNIQ_PRODUCT_NAME = "is already taken"
  PRODUCT_NOT_FOUND = "product is not found"
  #endregion product
end