
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











