require 'octopress-feeds/version'
require 'octopress-ink'
require 'octopress-include-tag'
require 'octopress-abort-tag'
require 'octopress-return-tag'
require 'octopress-date-format'

begin
  require 'octopress-linkblog'
rescue LoadError; end

module Octopress
  module Feeds
    class FeedTag < Liquid::Tag
      def render(context)
        context['site.pages'].dup \
          .select { |p| p.data['feed'] } \
          .sort_by { |p| p.url } \
          .sort_by { |p| p.url.size } \
          .map    { |p| tag(p) } \
          .join("\n")
      end

      def tag(page)
        url = page.url.sub(File.basename(page.url), '')

        "<link href='#{url}' title='#{page_title(page)}' rel='alternate' type='application/atom+xml'>"
      end

      def page_title(page)
        title = page.site.config['name'].dup || ''
        title << ': ' unless title.empty?
        title << page.data['title']

        title
      end
    end

    class FeedUpdatedTag < Liquid::Tag
      def render(context)
        feed = context['feed_type'] || 'posts'
        site = context['site']

        case feed
        when 'articles'
          posts = site['articles']
        when 'linkposts'
          posts = site['linkposts']
        else
          posts = site['posts']
        end

        if !posts.empty?
          post = posts.sort_by do |p|
            p.data['date_updated'] || p.date
          end.last

          post.data['date_updated_xml'] || post.data['date_xml']
        end
      end
    end
  end
end

Liquid::Template.register_tag('feed_tag', Octopress::Feeds::FeedTag)
Liquid::Template.register_tag('feed_updated_date', Octopress::Feeds::FeedUpdatedTag)

# A placeholder for smooth integration of Octopress Multilingual
unless defined? Octopress::Multilingual
  Liquid::Template.register_tag('set_lang', Liquid::Block)
end

Octopress::Ink.add_plugin({
  name:          "Octopress Feeds",
  slug:          "feeds",
  gem:           "octopress-feeds",
  path:          File.expand_path(File.join(File.dirname(__FILE__), "..")),
  type:          "plugin",
  version:       Octopress::Feeds::VERSION,
  description:   "RSS feeds for Jekyll sites, featuring link-blogging and multilingual support",
  website:       "https://github.com/octopress/feeds"
})

