class TwitterStream < ApplicationRecord
    STREAM_URL = "https://api.twitter.com/2/tweets/search/stream"
    RULES_URL = "https://api.twitter.com/2/tweets/search/stream/rules"
    BEARER_TOKEN = ENV["TWITTER_BEARER_TOKEN"]
    
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
                "Authorization": "Bearer #{BEARER_TOKEN}"
            },
            params: params
        }

        request = Typhoeus::Request.new(STREAM_URL, options)
        request.on_body do |chunk|
            puts chunk
        end
        request.run
    end
    
    def self.new_rule(event)
        # If the event already has a hashtag associated with it update that hashtag.
        if(event.rule_id)
            delete_single_rule(event.rule_id)
        end

        # TODO: this method expects hashtag to already have its own # consider adding some sort of validation there.
        payload = {
            add: [{'value': event.hashtag, 'tag': event.hashtag }]
        }
        options = {
            headers: {
                "User-Agent": "v2FilteredStreamRuby",
                "Authorization": "Bearer #{BEARER_TOKEN}",
                "Content-type": "application/json"
            },
            body: JSON.dump(payload)
        }
        
        # When response comes back, set the event's rule_id to the new id.
        response = Typhoeus.post(RULES_URL, options)
        raise "An error occurred while adding rules: #{response.status_message}" unless response.success?
        new_rule = JSON.parse(response.body)
        new_id = new_rule["data"][0]["id"]
        byebug
        event.rule_id = new_id
        
    end

    def self.get_all_rules
        # Returns an array of all of the rules for the twitter stream. Generally only used to delete all rules
        options = {
            headers: {
                "User-Agent": "v2FilteredStreamRuby",
                "Authorization": "Bearer #{BEARER_TOKEN}"
            }
        }

        response = Typhoeus.get(RULES_URL, options)
        raise "An error occured while retrieving rules from your stream: #{response.body}" unless response.success?
        
        JSON.parse(response.body)
    end

    def self.delete_all_rules
        # Maps over all rules to get just the ids, then calls delete rules for those ids
        rules = get_all_rules
        ids = rules['data'].map { |rule| rule["id"]}

        delete_rules(ids)        
    end

    def self.delete_single_rule(id)
        # Can delete a single rule if given its ID
        delete_rules([id])
    end

    def self.delete_rules(ids)
        payload = {
            delete: {
                ids: ids
            }
        }

        options = {
            headers: {
                "User-Agent": "v2FilteredStreamRuby",
                "Authorization": "Bearer #{BEARER_TOKEN}",
                "Content-type": "application/json"
            },
            body: JSON.dump(payload)
        }

        response = Typhoeus.post(RULES_URL, options)
        puts response
        raise "An error occured while deleting your rules: #{response.status_message}" unless response.success?
    end
    
    
    
end
