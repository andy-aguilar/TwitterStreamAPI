class Event < ApplicationRecord

    def save
        TwitterStream.new_rule(self)
    end
end
