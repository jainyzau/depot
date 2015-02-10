module StoreHelper
    def pluralize_times(count)
       count == 1 ? 'once' : 
        count == 2 ? 'twice' : "#{count} times" 
    end
end
