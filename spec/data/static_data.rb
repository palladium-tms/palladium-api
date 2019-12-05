
class StaticData
  ADDRESS = '0.0.0.0'.freeze
  PORT = 9292
  MAINPAGE = "http://#{ADDRESS}:#{PORT}".freeze

  ALPHABET = ('a'..'z').to_a
end

class ErrorMessages
  UNCORRECT_LOGIN = 'login or password is uncorrect'.freeze

  # region product
  UNCORRECT_PRODUCT_NAME = 'is invalid'.freeze
  NOT_UNIQ_PRODUCT_NAME = 'is already taken'.freeze
  PRODUCT_NOT_FOUND = 'product is not found'.freeze
  PRODUCT_ID_WRONG = 'product_id is not belongs to any product'.freeze
  # endregion product

  # region plan
  CANT_BE_EMPTY_PLAN_NAME = 'cannot be empty'.freeze
  PLAN_ID_CANT_BE_NIL_PLAN_NAME = "plan_id can't be nil".freeze
  PLAN_ID_WRONG = 'plan_id is not belongs to any product'.freeze
  # endregion plan

  # region run
  CANT_BE_EMPTY_RUN_NAME = 'cannot be empty'.freeze
  RUN_ID_WRONG = 'run_id is not belongs to any plans'.freeze
  RUN_ID_CANT_BE_EMPTY = "run_id can't be empty".freeze
  # endregion run
  #
  # #region result_set
  RESULT_SET_ID_WRONG = 'result_set_id is not belongs to any result_set_id'.freeze
  # endregion results_set
  #
  # # #region status
  STATUS_NAME_WRONG = 'status_name is not belongs to any statuses'.freeze
  # endregion status
end

class DefaultValues
  # #region status
  DEFAULT_STATUS_COLOR = '#ffffff'.freeze
  # endregion status
end
