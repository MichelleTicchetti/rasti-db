# Rasti::DB

[![Gem Version](https://badge.fury.io/rb/rasti-db.svg)](https://rubygems.org/gems/rasti-db)
[![Build Status](https://travis-ci.org/gabynaiman/rasti-db.svg?branch=master)](https://travis-ci.org/gabynaiman/rasti-db)
[![Coverage Status](https://coveralls.io/repos/github/gabynaiman/rasti-db/badge.svg?branch=master)](https://coveralls.io/github/gabynaiman/rasti-db?branch=master)
[![Code Climate](https://codeclimate.com/github/gabynaiman/rasti-db.svg)](https://codeclimate.com/github/gabynaiman/rasti-db)
[![Dependency Status](https://gemnasium.com/gabynaiman/rasti-db.svg)](https://gemnasium.com/gabynaiman/rasti-db)

Database collections and relations

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rasti-db'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rasti-db

## Usage

### Databse connection

```ruby
DB = Sequel.connect ...
```

### Databse schema

```ruby
DB.create_table :users do
  primary_key :id
  String :name, null: false, unique: true
end

DB.create_table :posts do
  primary_key :id
  String :title, null: false, unique: true
  String :body, null: false
  foreign_key :user_id, :users, null: false, index: true
end

DB.create_table :comments do
  primary_key :id
  String :text, null: false
  foreign_key :user_id, :users, null: false, index: true
  foreign_key :post_id, :posts, null: false, index: true
end

DB.create_table :categories do
  primary_key :id
  String :name, null: false, unique: true
end

DB.create_table :categories_posts do
  foreign_key :category_id, :categories, null: false, index: true
  foreign_key :post_id, :posts, null: false, index: true
  primary_key [:category_id, :post_id]
end
```

### Models

```ruby
User     = Rasti::DB::Model[:id, :name, :posts, :comments]
Post     = Rasti::DB::Model[:id, :title, :body, :user_id, :user, :comments, :categories]
Comment  = Rasti::DB::Model[:id, :text, :user_id, :user, :post_id, :post]
Category = Rasti::DB::Model[:id, :name, :posts]
```

### Collections

```ruby
class Users < Rasti::DB::Collection
  one_to_many :posts
  one_to_many :comments
end

class Posts < Rasti::DB::Collection
  many_to_one :user
  many_to_many :categories
  one_to_many :comments
end

class Comments < Rasti::DB::Collection
  many_to_one :user
  many_to_one :post
end

class Categories < Rasti::DB::Collection
  many_to_many :posts
end

users      = Users.new DB
posts      = Posts.new DB
comments   = Comments.new DB
categories = Categories.new DB
```

### Persistence

```ruby
DB.transaction do
  id = users.insert name: 'User 1'
  users.update id, name: 'User updated'
  users.delete id
end
```

### Queries

```ruby
posts.all #=> [Post, ...]
posts.first #=> Post
posts.count #=> 1
posts.query { where id: [1,2] } #=> [Post, ...]
posts.query { where{id > 1}.limit(10).offset(20) } #=> [Post, ...]
posts.query { graph(:user, :categories, 'comments.user')} #=> [Post(User, Categories, Comments([User])), ], ...]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabynaiman/rasti-db.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

