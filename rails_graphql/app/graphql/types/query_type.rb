module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    field :test_field, String, null: false,
          description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end

    field :users, [UserType], null: false, description: 'List all users'

    def users
      User.includes(:posts, posts: :comments)
    end

    field :posts, [PostType], null: false, description: "List all posts"

    def posts
      Post.includes(:comments, :user)
    end
  end
end
