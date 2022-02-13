class TwitterStream < ApplicationRecord
    @@STREAM_URL = "https://api.twitter.com/2/tweets/search/stream"
    @@RULES_URL = "https://api.twitter.com/2/tweets/search/stream/rules"
    @@BEARER_TOKEN = ENV["TWITTER_BEARER_TOKEN"]
    
    def self.stream_connect
        
        params = {
            "expansions": "attachments.poll_ids,attachments.media_keys,author_id,entities.mentions.username,geo.place_id,in_reply_to_user_id,referenced_tweets.id,referenced_tweets.id.author_id",
            "tweet.fields": "attachments,author_id,conversation_id,created_at,entities,geo,id,in_reply_to_user_id,lang",
        }

        options = {
            timeout: 60,
            method: 'get',
            headers: {
                "User-Agent": "v2FilteredStreamRuby",
                "Authorization": "Bearer #{@@BEARER_TOKEN}"
            },
            params: params
        }

        request = Typhoeus::Request.new(@@STREAM_URL, options)
        request.on_body do |chunk|
            puts chunk
        end
        request.run
    end
    
    def self.new_rule(event, hashtag)
        # Creates
        payload = {
            add: [{'value': hashtag}]
        }

        options = {
            headers: {
                "User-Agent": "v2FilteredStreamRuby",
                "Authorization": "Bearer #{@@BEARER_TOKEN}",
                "Content-type": "application/json"
            },
            body: JSON.dump(payload)
        }
        
        response = Typhoeus.post(@@RULES_URL, options)
        new_rule = JSON.parse(response.body)
        new_id = new_rule["data"][0]["id"]
        byebug
        raise "An error occurred while adding rules: #{response.status_message}" unless response.success?
    end
    
    
    
    
end
