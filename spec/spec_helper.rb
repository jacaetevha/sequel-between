require 'rspec'
require 'sequel'

$LOAD_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)), '../lib/'))

if (RUBY_VERSION >= '2.0.0' && RUBY_ENGINE == 'ruby') || (RUBY_ENGINE == 'jruby' && (JRUBY_VERSION >= '9.3' || (JRUBY_VERSION.match(/\A9\.2\.(\d+)/) && $1.to_i >= 7)))
  Sequel.extension :core_refinements
end

require 'sequel/extensions/between'

Sequel::DB = nil
Sequel::Model.use_transactions = false
Sequel::Model.cache_anonymous_models = false

DB = Sequel.mock(fetch: {id: 1, x: 1}, numrows: 1, autoid: proc{ |sql| 10 })
def DB.schema(*) [[:id, {primary_key: true}]] end
def DB.reset() sqls end
def DB.supports_schema_parsing?() true end
Sequel::DATABASES.clear
