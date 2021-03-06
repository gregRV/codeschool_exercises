############################
# LEVEL 2 - RESOURCES & GET
############################

=begin
On the setup method, set the host to api.example.com.

Now, let’s create two humans. Set the first one’s name
to Allan with the brain_type set to large.
Then set the second one’s name to John with the
brain_type set to small.

Issue a GET request to the humans resources URI and pass
a query string with brain_type set to small.
Assert the response status code is 200 - Success.

Parse the response.body from json into a Ruby hash.
Make sure John is included in the body, and that Allan is not.
=end
class ListingHumansTest < ActionDispatch::IntegrationTest
  setup { host! 'api.example.com' }
  john 	= Human.create(name: 'John', brain_type: 'small')
  allan = Human.create(name: 'Allan', brain_type: 'large')

  test 'returns a list of humans by brain type' do
    # test code here
    get '/humans?brain_type=small'
    assert_equal response.status, 200

    humans = JSON.parse(response.body, symbolize_names: true)
    names = humans.collect {|humans| humans[:name]}
    assert_includes names, 'John'
    refute_includes names, 'Allan'
  end
end


=begin
Now it’s time to write production code and make our tests pass.
From API::HumansController#index, we need to check for a specific
parameter sent via URI query strings.

Using the params object, check if brain_type is passed in as
a parameter. If it is, then narrow down the list of humans
to only those with that specific brain_type.
Don’t forget to assign the new result back to the humans variable.

Finally, render a json representation
of humans with a 200 - Success* status code.
=end
module API
  class HumansController < ApplicationController
    def index
      humans = Human.all

      # your code here
      if brain_type = params[:brain_type]
        humans = humans.where(brain_type: brain_type)
      end
      render json: humans, status: 200
    end
  end
end


=begin
We will now add the ability to retrieve one specific human
by its id. Let’s start with a test.

Create a Human named Ash. Issue a GET request to the humans’ show endpoint using
Ash’s id, and assert that the response status is 200 - Success.

Parse the response.body and assert the name returned matches our recently
created human. Check the test/test_helper.rb tab for a helper method that might
be useful.
=end
class ListingHumansTest < ActionDispatch::IntegrationTest
  setup { host! 'api.example.com' }
  ash = Human.create(name: 'Ash')

  test 'returns human by id' do
    get "/humans/#{ash.id}"
    assert_equal response.status, 200
    human_response = json(response.body)
    assert_equal human_response[:name], 'Ash'
  end
end

=begin
With tests in place, now let’s implement the show action for our
API::HumansController. We’ll fetch a specific Human by
its id and return its JSON representation.

Find a Human by its id and render it back as JSON.

Respond with a 200 - Success status code.
=end
module API
  class HumansController < ApplicationController
    def show
      human = Human.find(params[:id])
      render json: human, status: 200
    end
  end
end


=begin
Use curl to issue a similar GET request to
http://cs-zombies-dev.com:3000/humans.
This time, we also want to send along the brain_type value
set to large using query string parameters.
=end
curl http://cs-zombies-dev.com:3000/humans?brain_type=large


##################################
#   LEVEL 3 - CONTENT NEGOTIATION
##################################

=begin
It’s time to improve the way our API determines the best response representation for different types of clients.
Let’s start by writing a test to ensure our API is able to serve humans resources in JSON.

Issue a GET request to the humans resource URI. Use the proper request header to ask for the JSON Mime Type.

Assert that the response status is 200 - Success and the response Content-Type is set to JSON.
=end
class ListingHumansTest < ActionDispatch::IntegrationTest
  test 'returns humans in JSON' do
    get '/humans', {}, {'Accept' => Mime::JSON}

    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type
  end
end


=begin
Call the respond_to method, which takes a block with a single argument named format.

Inside the block, use the format object to respond back with humans in JSON format and with a 200 - Success status code.

Now use the format object to respond back with humans in XML format and with a 200 - Success status code.
=end
class HumansController < ApplicationController
  def index
    humans = Human.all

    # your code here
    respond_to do |format|
      format.json { render json: humans, status: 200 }
      format.xml  { render xml: humans, status: 200 }
    end
  end
end


=begin
Issue a GET request to the humans resources URI. Specify the accepted language as en and the accepted Mime Type as JSON.

Using assert_equal, check for a 200 - Success status code.

We’ve selected the first human out of the array for you, and assigned it to the human variable. Using that human, assert its :message property is set to “My name is #{human[:name]} and I am alive!”.
=end
class ChangingLocalesTest < ActionDispatch::IntegrationTest
  test 'returns list of humans in English' do
    get '/humans', {}, {'Accept' => Mime::JSON, 'Accept-Language' => 'en'}
    # assertion here
    assert_equal response.status, 200

    human = json(response.body).first
    # assertion here
    assert_equal human[:message], "My name is #{human[:name]} and I am alive!"
  end
end


=begin
Create a controller callback that calls the set_locale method everytime a new request comes in. Define this method, but don’t worry about implementing it just yet. By following the convention for controller callback methods, mark this method as protected.

Now it is time to implement the set_locale method. This method reads from the Accept-Language request header and sets the application’s locale with the value from it.
=end
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  protected

  def set_locale
    I18n.locale = request.headers['Accept-Language']
  end
end


#########################################
#  LEVEL 4 - POST, PUT, PATCH, & DELETE
#########################################

=begin
Our web API needs an end point to register humans who have
survived the Zombie Apocalypse. We will start by writing some integration
tests for the POST method. These tests will ensure that only valid humans
can be created and that our API generates the proper response. Use the
following data for creating a valid
human: { human: { name: 'John', brain_type: 'small' } }.to_json.

Use the post method to issue a request to the humans resource URI.
The request will need to include valid human data as its second argument.
The third argument will need to send in a hash that tells the server that
our request expects the response to be in JSON, and that the payload we
are sending is also in JSON.

Assert the response status code is 201 - Created.

Assert the Content-Type response header is Mime::JSON.

=end
class CreatingHumansTest < ActionDispatch::IntegrationTest
  test 'creates human' do
    post '/humans',
      { human:
        {name: 'John', brain_type: 'small'}
      }.to_json,
      { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }

    assert_equal response.status, 201
  end
end


=begin
Our API is stateless. This means we don’t need to worry about managing sessions between requests, or exceptions caused by invalid authenticity tokens.

Change the protect_from_forgery method to null out the session, in case of invalid authenticity tokens.
=end
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
end

4.13
    human.update(human_params)
    render json: human

=begin
For unsuccessful POST requests, our API needs to respond with the errors that prevented the request from being fulfilled, along with the proper status code.

If a new human cannot be saved, then respond with the errors in JSON.

Now set the 422 - Unprocessable Entity status code when responding with the errors.
=end
class HumansController < ApplicationController
  def create
    human = Human.new(human_params)

    if human.save
      head 204, location: human
    else
      render json: human.errors, status: 422
    end
  end

  private

  def human_params
    params.require(:human).permit(:name, :brain_type)
  end
end


#######################
# LEVEL 5 - VERSIONING
#######################
# Set the proper request header used for versioning, with the value for our new custom media type of application/vnd.zombies.v1+json.
# Assert the Content-Type on the response is set to JSON.
# Now parse the response body and assert that there is a message property set to "This is version one". Check the test/test_helper.rb file on the secondary tab for a helper method that can help save some time.
class ListingZombiesTest < ActionDispatch::IntegrationTest
  test 'show zombie from API version 1' do
    get '/zombies/1', {}, { 'Accept' => 'application/vnd.zombies.v1+json' }
    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type
    assert_equal json(response.body)[:message], 'This is version one'
  end
end


# The default_version argument on the constructor needs to have a default value of false.
# The check_headers method needs to read from the Accept header, which can return either nil or an array. We’ll return true if it’s not nil and if it includes application/vnd.zombies.#{@version}+json.
class ApiVersion

  def initialize(version, default_version = false) # Task 1
    @version, @default_version = version, default_version
  end

  def matches?(request)
    @default_version || check_headers(request.headers)
  end

  private
    def check_headers(headers)
      accept = headers['Accept']
      accept && accept.include?("application/vnd.zombies.#{@version}+json")
    end
end

# With our ApiVersion class in place, all that’s left to do is use this class on our routes file. We’ll need create two ApiVersion objects - one for each API version that we need to support. Don’t forget to indicate that version 2 is the default API version!
# First, require the ApiVersion class file, which lives under the lib folder. The lib folder is currently added to the Rails load path.
# Set the v1 module constraint to a new object from the ApiVersion class. This object should be initialized to version v1.
# Set the v2 module constraint to a new object from the ApiVersion class. This object should be initialized to version v2 and this is the default API version.
require 'api_version'

SurvivingRails::Application.routes.draw do
  scope defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiVersion.new('v1') do # Task 2
      resources :zombies
    end
    scope module: :v2, constraints: ApiVersion.new('v2', true) do # Task 3
      resources :zombies
    end
  end
end


###########################
# LEVEL 6 - AUTHENTICATION
###########################

class ListingZombiesTest < ActionDispatch::IntegrationTest
  setup { @user = User.create! }

  test 'valid token lists zombies' do
    get '/zombies', {}, { 'Authorization' => token_header(@user.auth_token) }
    assert_equal response.status, 200
    assert_equal response.content_type, Mime::JSON
  end
end











