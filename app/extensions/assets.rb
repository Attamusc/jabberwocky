require 'sprockets'

module Jabberwocky
  module Extensions
    module Assets
      class << self
        class UnknownAsset < StandardError; end

        module Helpers
          def asset_path(name)
            asset = settings.assets[name]
            raise UnknownAsset, "Unknown asset: #{name}" unless asset
            "#{settings.asset_host}/assets/#{asset.digest_path}"
          end
        end

        def registered(app)
          # Assets
          app.set :assets, assets = Sprockets::Environment.new(app.settings.root)

          assets.append_path('app/assets/js')
          assets.append_path('app/assets/css')
          assets.append_path('app/assets/img')

          assets.append_path('vendor/assets/js')
          assets.append_path('vendor/assets/css')

          app.set :asset_host, ''

          app.configure :development do
            assets.cache = Sprockets::Cache::FileStore.new('./tmp')
          end

          app.configure :production do
            assets.cache          = Sprockets::Cache::MemcacheStore.new
            assets.js_compressor  = Closure::Compiler.new
            assets.css_compressor = YUI::CssCompressor.new
          end

          app.helpers Helpers
        end
      end
    end
  end
end
