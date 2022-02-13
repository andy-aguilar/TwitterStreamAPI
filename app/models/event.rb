class Event < ApplicationRecord

    def save
        TwitterStream.new_rule(self)
        super
    end
end
