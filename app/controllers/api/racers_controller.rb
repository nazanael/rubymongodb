module Api
	class RacersController < ApplicationController
		
		def index
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers"
			else			
			end
		end

		def show
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:id]}"
			else						
			end
		end

		def racer_entry
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:racer_id]}/entries/#{params[:id]}"
			else
			end
		end

		def racer_entries
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:racer_id]}/entries"
			else	
			end
		end		
	end
end