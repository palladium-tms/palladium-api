
class StaticData
  ADDRESS = '0.0.0.0'
  PORT = 9292
  MAINPAGE = "http://#{ADDRESS}:#{PORT}"
  TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0OTYxNjIyMjksImlhdCI6MTQ5NjE1ODYyOSwiaXNzIjoibW9uZXlhcGkuY29tIiwic2NvcGVzIjpbInByb2R1Y3RzIiwicHJvZHVjdF9uZXciLCJwcm9kdWN0X2RlbGV0ZSIsInByb2R1Y3RfZWRpdCIsInBsYW5fbmV3IiwicGxhbnMiLCJwbGFuX2VkaXQiLCJwbGFuX2RlbGV0ZSIsInJ1bl9uZXciLCJydW5zIiwicnVuX2RlbGV0ZSIsInJ1bl9lZGl0Il0sInVzZXIiOnsiZW1haWwiOiIxQGcuY29tIn19.01Uiv9a0lBmkkrZ7qy8Sj0VjpJxtHyHbJR6IsgJWaxY'

  ALPHABET = ('a'..'z').to_a
end

class ErrorMessages
  UNCORRECT_LOGIN = "login or password is uncorrect"

  #region product
  UNCORRECT_PRODUCT_NAME = "is invalid"
  NOT_UNIQ_PRODUCT_NAME = "is already taken"
  PRODUCT_NOT_FOUND = "product is not found"
  PRODUCT_ID_WRONG = "product_id is not belongs to any product"
  #endregion product

  #region plan
  CANT_BE_EMPTY_PLAN_NAME = 'cannot be empty'
  PRODUCT_ID_CANT_BE_NIL_PLAN_NAME = "product_id can't be nil"
  PRODUCT_ID_CANT_BE_EMPTY_PLAN_NAME = "product_id can't be empty"
  PLAN_ID_CANT_BE_NIL_PLAN_NAME = "plan_id can't be nil"
  PLAN_ID_WRONG = "plan_id is not belongs to any product"
  #endregion plan

  #region run
  CANT_BE_EMPTY_RUN_NAME = 'cannot be empty'
  IN_NOT_NUMBER_RESULT_SET_STATUS = 'is not a number'
  RUN_ID_WRONG = "run_id is not belongs to any plans"
  RUN_ID_CANT_BE_EMPTY = "run_id can't be empty"
  #endregion run
  #
  # #region result_set
  RESULT_SET_ID_WRONG = "result_set_id is not belongs to any result_set_id"
  #endregion results_set
  #
  # # #region status
  UNCORRECT_Status_NAME = "is invalid"
  STATUS_NAME_WRONG = "status_name is not belongs to any statuses"
  #endregion status
end

class DefaultValues

  # #region status
  DEFAULT_STATUS_COLOR = "#ffffff"
  #endregion status
end