require_relative 'base_error.rb'

class NotFoundError < BaseError
  attr_reader :code

  def initialize(message = 'Not Found')
    @code = 404
    super(message)
  end
end
