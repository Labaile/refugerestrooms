module API
  module V1
    class Api::V1::RestroomsController < ApplicationController

      before_filter :list_restrooms, only: [:index]
      before_filter :find_restroom, only: [:show, :update]

      def index
        render json: @restrooms
      end

      def show
        render json: @restroom
      end

      def update
        if params[:restroom][:downvote]
          if Restroom.increment_counter(:downvote, @restroom.id)
            render json: {status: 200, message: "#{@restroom.name} has been sucessfully downvoted!"}
          end
        elsif params[:restroom][:upvote]
          if Restroom.increment_counter(:upvote, @restroom.id)
            render json: {status: 200, message: "#{@restroom.name} has been sucessfully upvoted!"}
          end
        else
          render json: {status: 501, message: "Not Implemented"}
        end
      end

      private

      def find_restroom
        @restroom = Restroom.find(params[:id])
      end

      def list_restrooms
        @restrooms = Restroom.all
        @restrooms = if params[:lat].present? && params[:long].present?
          @restrooms.near([params[:lat], params[:long]], 20, :order => 'distance')
        elsif params[:search].present?
          @restrooms.text_search(params[:search])
        else
          @restrooms.reverse_order
        end
      end

      def permitted_params
        params.require(:restroom).permit(:upvote, :downvote)
      end


    end
  end
end




#     class Restrooms < Grape::API
#       include Grape::Kaminari
#       paginate :per_page => 10

#       version 'v1'
#       format :json

#       resource :restrooms do
#         desc "Get all restroom records ordered by date descending."
#         params do
#           optional :ada, type: Boolean, desc: "Only return restrooms that are ADA accessible."
#           optional :unirsex, type: Boolean, desc: "Only return restrooms that are unisex."
#         end
#         get do
#           r = Restroom
#           r = r.accessible if params[:ada].present?
#           r = r.unisex if params[:unisex].present?

#           paginate(r.order(created_at: :desc))
#         end

#         desc "Perform full-text search of restroom records."
#         params do
#           optional :ada, type: Boolean, desc: "Only return restrooms that are ADA accessible."
#           optional :unisex, type: Boolean, desc: "Only return restrooms that are unisex."
#           requires :query, type: String, desc: "Your search query."
#         end
#         get :search do
#           r = Restroom
#           r = r.accessible if params[:ada].present?
#           r = r.unisex if params[:unisex].present?

#           paginate(r.text_search(params[:query]))
#         end
#       end
#     end
#   end
# end
