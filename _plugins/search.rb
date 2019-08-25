require "json"
require "jekyll"

module Jekyll
    class Search < Jekyll::Generator
        safe true
        priority :lowest

        def item(id, title, categories, excerpt, date)
            return {
                :id => id,
                :title => title,
                :categories => categories,
                :excerpt => excerpt,
                :date => date,
            }.freeze
        end

        def generate(site)
            Jekyll.logger.info "Jekyll Search:", "Generating search.json"
            ls = []
            for post in site.posts.docs
                id = post.id
                title = post.data["title"]
                categories = post.data["categories"]
                excerpt = post.data["excerpt"]
                date = post.data["date"]
                ls = Array(ls).push(item(id, title, categories, excerpt, date))
            end
            search = Jekyll::Page.new(site, __dir__, "", "search.json")
            search.content = ls.to_json
            search.data["layout"] = nil
            site.pages << search
        end
    end
end
