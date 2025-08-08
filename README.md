[![Gem Version](https://badge.fury.io/rb/rdt.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/rdt)
# rdt (Ruby Data Tool)

SQL-based data modeling for Rails applications.

## Usage

Use `Rdt.run` to build your models:

```ruby
Rdt.run
```

> [!NOTE] 
> This gem is being renamed to **rdt (ruby data tool)** so it can be published in rubygems.

## Name change
1. Replace `gem "dbt", github: "felipedmesquita/dbt"` with `gem "rdt"`
2. Done

- Prefer `Rdt.run` in new apps, `Dbt.run` still works
- `config/rdt.yml` takes precedence over `config/dbt.yml`

#### Planed breaking changes
You can pin unmaintaned old apps to `gem "rdt", "= 0.1.1`.
- The default schema will be changed from `felipe_dbt` to `rdt`
- Use of the Dbt namespace will first emmit deprecation warnings, and then be removed in a future version

## Resources from the Extractor gem
Basic steps to clean, deduplicate and model Extractor results:
### 1. Clean responses and unroll arrays
Create a .sql file named example_cleaned containg exactly the following columns
1. unique_by
1. created_at
1. request_id
1. body

```sql
-- example_cleaned.sql
SELECT
  response_options -> 'response_body' ->> 'id' AS unique_by,
  created_at,
  id AS request_id,
  response_options -> 'response_body' AS body
FROM <%= source('requests') %>
WHERE extractor_class =  'ExampleTap'
```
#### Responses with multiple items
Use jsonb_path_query to split arrays of items to individual records
```sql
-- example_cleaned.sql
SELECT
  jsonb_path_query(response_options, '$.response_body[*].body.id') #>> '{}' AS unique_by,
  created_at,
  id AS request_id,
  jsonb_path_query(response_options, '$.response_body[*].body') body
FROM <%= source('requests') %>
WHERE extractor_class = 'MultipleItemsTap'
```
### 2. Deduplicate
```sql
-- example_deduplicated.sql
SELECT
  DISTINCT ON(unique_by)
  *
FROM <%= ref('example_cleaned') %>
ORDER BY unique_by, created_at DESC
```
### 3. Model
```sql
-- example_model.sql
SELECT
  body ->> 'id' AS id,
  body ->> 'userId' AS user_id,
  body ->> 'title' AS title,
  body ->> 'body' AS body
FROM <%= ref('example_deduplicated') %>
```
## Using SQL models as Active Record models
SQL models are currently materialized as either views or materialized views, those can be used as tables backing Active Record models, but are inherently read-only. To use a SQL model as an Active Record model, create a ruby file in app/models  defining a class that inherits from ApplicationRecord. Remember that for Zeitwert to autoload your file it should follow the naming conventions (class name should be the CamelCase version of the snake_case file name: inventory_transfer.rb defines `class InventoryTranfer`.
```ruby
# app/models/example_name.rb
class ExampleName < ApplicationRecord
  self.table_name = "rdt.example_model"
end
```
This, after re-entering the rails console, enables queries like:
```ruby
3.1.0 :001 > ExampleName.first
 =>
#<ExampleName:0x00000001126864e8
 id: 1,
 user_id: 1,
 title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
 body:
  "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto">
```
