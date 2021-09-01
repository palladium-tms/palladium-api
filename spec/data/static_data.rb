# frozen_string_literal: true

class StaticData
  ADDRESS = '0.0.0.0'
  PORT = 80
  MAINPAGE = "http://#{ADDRESS}:#{PORT}"

  ALPHABET = ('a'..'z').to_a
end

class ErrorMessages
  UNCORRECT_LOGIN = 'login or password is uncorrect'

  # region product
  UNCORRECT_PRODUCT_NAME = 'is invalid'
  NOT_UNIQ_PRODUCT_NAME = 'is already taken'
  PRODUCT_NOT_FOUND = 'product is not found'
  PRODUCT_ID_WRONG = 'product_id is not belongs to any product'
  # endregion product

  # region plan
  CANT_BE_EMPTY_PLAN_NAME = 'cannot be empty'
  PLAN_ID_CANT_BE_NIL_PLAN_NAME = "plan_id can't be nil"
  PLAN_ID_WRONG = 'plan_id is not belongs to any product'
  # endregion plan

  # region run
  CANT_BE_EMPTY_RUN_NAME = 'cannot be empty'
  RUN_ID_WRONG = 'run_id is not belongs to any plans'
  RUN_ID_CANT_BE_EMPTY = "run_id can't be empty"
  # endregion run
  #
  # #region result_set
  RESULT_SET_ID_WRONG = 'result_set_id is not belongs to any result_set_id'
  # endregion results_set
  #
  # # #region status
  STATUS_NAME_WRONG = 'status_name is not belongs to any statuses'
  # endregion status
end

class DefaultValues
  # #region status
  DEFAULT_STATUS_COLOR = '#ffffff'
  # endregion status
end
