module Api
	class RacesController < ApplicationController
		protect_from_forgery with: :null_session

		#captura la excepción DocumentNotFound y devuelve texto plano con el texto "woops ..."
		rescue_from Mongoid::Errors::DocumentNotFound do |exception|
			Rails.logger.debug exception
			@msg = "woops: cannot find race[#{params[:id]}]"
			render 	:status=>:not_found,:template=>"api/error_msg",:locals=>{ :msg=> @msg}
		end

		rescue_from ActionView::MissingTemplate do |exception|
			Rails.logger.debug exception
			render plain: "we do not support that content-type[#{request.accept}]", status: :unsupported_media_type
		end
		
		def index
			if !request.accept || request.accept == "*/*"				
				render plain: "/api/races, offset=[#{params[:offset]}], limit=[#{params[:limit]}]"
			else
			end
		end

		def show			
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:id]}"
			else
				#render json: @race	
				set_race
				render action: :race
			end
		end

		def race_result			
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:race_id]}/results/#{params[:id]}"
			else
				@result = Race.find(params[:race_id]).entrants.where(:id => params[:id]).first
				render :partial=>"result", :object => @result
			end
		end

		def update_race_result
			entrant = Race.find(params[:race_id]).entrants.where(:id => params[:id]).first
			result = params[:result]
			if result
				if result[:swim]
					entrant.swim = entrant.race.race.swim
					entrant.swim_secs = result[:swim].to_f
				end
				if result[:t1]
					entrant.t1 = entrant.race.race.t1
					entrant.t1_secs = result[:t1].to_f
				end
				if result[:bike]
					entrant.bike = entrant.race.race.bike
					entrant.bike_secs = result[:bike].to_f
				end
				if result[:t2]
					entrant.t2 = entrant.race.race.t2
					entrant.t2_secs = result[:t2].to_f
				end
				if result[:run]
					entrant.run = entrant.race.race.run
					entrant.run_secs = result[:run].to_f
				end
				entrant.save
			end
			render :partial=>"result", :object => entrant, formats: :json
		end

		def race_results			
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:race_id]}/results"
			else
				@race = Race.find(params[:race_id])
				@entrants = @race.entrants
				#stale se encarga de comprobar If-Modified-Since e If-None-Match, de poner
				#header[Last-Modified] y retornar un 304 (Not modified) si no cumple las condiciones
				if stale?(:last_modified => @entrants.max(:updated_at))
					render action: :results, formats: :json
				end
				#response.headers["Last-Modified"] = @entrants.max(:updated_at)
				#fresh_when last_modified: @entrants.max(:updated_at)
				#render action: :results, formats: :json
			end
		end

		def update
			set_race
			Rails.logger.debug("method=#{request.method}")
			@race.update(race_params)
			render json: @race
		end

		def destroy
			set_race
			@race.destroy
			render :nothing=> true, :status=> :no_content
		end

		def create						
			race = params[:race]
			if !request.accept || request.accept == "*/*"
				render plain: race ? race[:name] : :nothing, status: :ok
			else
				@race = Race.new(race_params)
				@race.save
				render plain: @race[:name], status: :created
			end
		end

		def race_params
      		params.require(:race).permit(:name, :date)
    	end

    	def set_race
      		@race = Race.find(params[:id])
    	end
	end
end