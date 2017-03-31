#Yelp Information
require "json"
require "http"
require "optparse"


# Place holders for Yelp Fusion's OAuth 2.0 credentials. Grab them
# from https://www.yelp.com/developers/v3/manage_app
CLIENT_ID = "REDpwBFett23E7qChQc_Fg"
CLIENT_SECRET = "jD8dKzQ4pzlMGA3adYkCfl3AqMcV6FHgDRv7JSFwTh0poUS7YXHYrbubQrJdOOZJ"

# Constants, do not change these
API_HOST = "https://api.yelp.com"
SEARCH_PATH = "/v3/businesses/search"
BUSINESS_PATH = "/v3/businesses/"  # trailing / because we append the business id to the path
TOKEN_PATH = "/oauth2/token"
GRANT_TYPE = "client_credentials"

def bearer_token
  # Put the url together
  url = "#{API_HOST}#{TOKEN_PATH}"

  raise "Please set your CLIENT_ID" if CLIENT_ID.nil?
  raise "Please set your CLIENT_SECRET" if CLIENT_SECRET.nil?

  # Build our params hash
  params = {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    grant_type: GRANT_TYPE
  }

  response = HTTP.post(url, params: params)
  parsed = response.parse

  "#{parsed['token_type']} #{parsed['access_token']}"
end

def search(term, location)
  url = "#{API_HOST}#{SEARCH_PATH}"
  params = {
    term: term,
    location: location,
    limit: 20
  }

  response = HTTP.auth(bearer_token).get(url, params: params)
  response.parse
end

def package_results(response)
  unless response.nil?
    businesses = []
    results = response['businesses']
    for result in results do
      business = []
      name = result['name']
      address = result['location']['display_address']
      phone, price = result['display_phone'], result['price']
      image, yelp_url = result['image_url'], result['url']
      hash_business = hash_info(name, address, phone, price, image, yelp_url)
      businesses.push(hash_business)
    end
    return businesses
  else
    return []
  end
end



def hash_info(name, address, phone, price, image, yelp_url)
  hashed = { name: name, address: address, phone: phone, price: price, image: image, yelp_url: yelp_url}
  return hashed
end



class SearchesController < ApplicationController
  before_action :set_search, only: [:show, :edit, :update, :destroy]

  # GET /searches
  # GET /searches.json
  def index
    @searches = Search.all
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
    @businesses = package_results(search(@search.term, @search.location))

  end

  # GET /searches/new
  def new
    @search = Search.new
  end

  # GET /searches/1/edit
  def edit
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = Search.new(search_params)

    respond_to do |format|
      if @search.save
        @results = search(@search.term, @search.location)
        if @results == false
          format.html { render :new }
          format.json { redirect_to :new, notice: 'No options available with particular request' }
        else
          format.html { redirect_to @search, notice: 'Search was successfully created.' }
          format.json { render :show, status: :created, location: @search }
        end
      else
        format.html { render :new }
        format.json { redirect_to :new, notice: 'No options available with particular request' }
      end
    end
  end

  # PATCH/PUT /searches/1
  # PATCH/PUT /searches/1.json
  def update
    respond_to do |format|
      if @search.update(search_params)
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        format.json { render :show, status: :ok, location: @search }
      else
        format.html { render :edit }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search.destroy
    respond_to do |format|
      format.html { redirect_to searches_url, notice: 'Search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:search).permit(:term, :location)
    end


end
