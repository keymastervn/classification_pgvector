# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'logger'
require 'net/http'
require 'pgvector'
require 'sequel'
require 'openai'

Dotenv.load

DB = Sequel.connect("postgres://localhost/#{ENV['DB_NAME']}")

class Certification < Sequel::Model
  plugin :pgvector, :embedding
end

DB.sql_log_level = :debug
DB.loggers << Logger.new($stdout)

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY")
  config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID") # Optional.
end

input = 'SOMETHING HERE' # <--- your input, can be array

# Adult and Pediatric First Aid CPR AED certification from American Red Cross
# Certificate of NCEA Level 2 2014
# Certificate of NCEA Level 3 2015
# Certificate Of Participation
# Certificate of Responsible Service of Alcohol RSA and
# Certificate of Supporting Individual with Intellectual Disabilities and Mental Illness

response = client.embeddings(
  parameters: {
    model: "text-embedding-ada-002",
    input: input
  }
)

# Note, in production: to save embedding retrieval cost, better save in DB rather than in-line
embedding = response['data'][0]['embedding']

result = Certification.nearest_neighbors(:embedding, embedding, distance: "euclidean").limit(5)
result.to_a.map{|x| OpenStruct.new(content: x.content, neighbor_distance: x.values[:neighbor_distance]) }
[#<OpenStruct content="CPR First Aid Certificate", distance=0.42956879449964486>,
 #<OpenStruct content="Advanced First Aid Certificate", distance=0.47577724486420697>,
 #<OpenStruct content="First Aid Certificate", distance=0.4857017435830708>,
 #<OpenStruct content="Advanced Resuscitation Certificate", distance=0.5047791778629611>,
 #<OpenStruct content="Provide First Aid Certificate", distance=0.5061643999044998>]
