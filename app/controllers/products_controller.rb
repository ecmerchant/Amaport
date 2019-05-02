class ProductsController < ApplicationController
  def show
    @login_user = current_user
    @test = Constants::AH
    logger.debug(@test)
  end
end
