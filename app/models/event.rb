class Event < ApplicationRecord

    def hashtag=(hashtag)
        # First check if hashtag is actually changing or just getting set to its previous value
        if(hashtag != self.hashtag)
            TwitterStream.new_rule(self, hashtag)
        end
        # Super allows us to call the standard ActiveRecord setter method after we run the custom code above
        super(hashtag)
    end
end
