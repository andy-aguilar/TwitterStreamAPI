# Add gems and create environment file
### Gems:
1. `typhoeus`: sends requests to twitters api (could probably also use rest-client, but twitter docs use typhoeus)
2. `json`: used to parse json coming from api
3. `figaro`: creates environment file and adds it to gitignore. Allows you to access env variables using `ENV["VARIABLE_NAME"]`
### Tasks:
1. Add all three gems to gemfile
2. Run `bundle install`
3. Run `bundle exec figaro install`: Creates `./config/application.yml` file where you can store env variables, and adds file to `.gitignore`

# Create app on twitter developer site
### Tasks:
1. Go to [Twitter's developer site](developer.twitter.com) and create an app.
2. Add the api_key, api_key_secret, and bearer-token to your `./config/application.yml` file. File should look like this: 

``` 
TWITTER_API_KEY: qNfakenumbersnotmyrealkeyzq
TWITTER_API_KEY_SECRET: jtSlsdkafjpiadsfpouhgfl;askjdftNasdfasfaocY
TWITTER_BEARER_TOKEN: AadfhasdkfjhakjsfhaslkjhdflkasjhflkajshdflkjashdfkljhasdkfjhaslkjhWrVhe 
```
# Create resources and migrate db
### Tasks:
1. For this example we ran `rails g resource Events name:string date:datetime hashtag:string rule_id:string` to create an Events migration, model, controller, and routes.
2. Run `rails db migrate` to create events.

# Create a class for the twitter stream
### Note:
The current implementation of the twitter stream does not require a database table. The rules for the stream are stored on the twitter api.
### Tasks
1. Create a twitter_stream.rb file in the models directory and create a class that extends application_record.
2. See `./app/models/twitter_stream.rb` in this repo for methods and explanations for creating the twitter stream.

# Link events to twitter stream
### Tasks:
1. If you haven't already read the `TwitterStream.new_rule` method that takes an event and a hashtag. It checks if the event has a rule_id currently associated with it, and if it does, it deletes that rule before adding a new rule to the stream and saving the new rule's id to the event's row in the database.
2. We also hijack the setter method for event.hashtag to call `TwitterStream.new_rule` every time a new hashtag is set.

