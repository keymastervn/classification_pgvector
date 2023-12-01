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

DB.run "CREATE EXTENSION IF NOT EXISTS vector"

DB.drop_table? :certifications
DB.create_table :certifications do
  primary_key :id
  text :content
  column :embedding, "vector(1536)"
end

DB.sql_log_level = :debug
DB.loggers << Logger.new($stdout)

class Certification < Sequel::Model
  plugin :pgvector, :embedding
end

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY")
  config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID") # Optional.
end

# https://platform.openai.com/docs/guides/embeddings/how-to-get-embeddings
# input can be an array with 2048 elements,
# but I suggest you control it within batch_size=200 items
# Dataset can be taken from huggingface or https://datasetsearch.research.google.com/
inputz = File.readlines('./data/all_certs.txt', chomp: true)

inputz.each_slice(_batch_size = 200) do |input|
  response = client.embeddings(
    parameters: {
      model: "text-embedding-ada-002",
      input: input
    }
  )

  certifications = []
  input.zip(response['data']) do |content, data|
    embedding = data['embedding']
    certifications << {content: content, embedding: Pgvector.encode(embedding)}
  end

  Certification.multi_insert(certifications)
end
