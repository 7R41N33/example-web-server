require_relative 'base_error.rb'

class ForbiddenError < BaseError
  attr_reader :code

  def initialize(message = 'Forbidden')
    @code = 403
    super(message)
  end
end
