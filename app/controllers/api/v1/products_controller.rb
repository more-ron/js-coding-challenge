class Api::V1::ProductsController < ApplicationController
  def show
    if product.not_found?
      render json: { not_found: true }, status: :not_found
    else
      render json: product_json, status: :ok
    end
  end

  private

  def product_json
    product.as_json only: [
                      :asin,
                      :last_updated_at
                    ],
                    methods: [
                      :dimensions,
                      :main_category,
                      :main_image,
                      :name,
                      :rankings
                    ]
  end

  def product
    @product ||= retrieve_product
  end

  def retrieve_product
    found_product = Product.find_by asin: asin

    if found_product.present?
      RetrieveProductJob.perform_later(asin) if found_product.stale?
      found_product
    else
      RetrieveProductJob.perform_now asin
      Product.find_by asin: asin
    end
  end

  def asin
    params.require(:id)
  end
end
