# Classification pgvector

https://supabase.com/blog/openai-embeddings-postgres-vector

## Installation and Prerequisite

Figure it out

1. OpenAI API keys
2. Ruby 3 and up

### pgvector

Make sure you are running PostgreSQL version 11 and up

Install `pgvector` extension https://github.com/pgvector/pgvector

`$ brew install pgvector`

### Database

`psql`

```SQL
psql> CREATE DATABASE embeddings;
```

### Gemfile dependencies

`bundle install`

## Action

### Generate embeddings for existing data

See `1_create_embeddings.rb`

### Query

Note: practice index on your own purpose, see https://github.com/pgvector/pgvector#hnsw

Note 2: there are some operators

- `<->` for nearest neighbors
- `<=>` for cosine distance
- `<#>` negative inner product

Read the doc for more information.

See `2_query.rb`, it includes (1) getting embeddings of the input, (2) get the similarities

> can be `item.nearest_neighbors(:embedding, distance: "euclidean").limit(5)` if you've set its embedding, or
> `Item.nearest_neighbors(:embedding, [1, 1, 1], distance: "euclidean").limit(5)` if you don't set
