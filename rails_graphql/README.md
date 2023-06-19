# Rails graphql


## query1
```
{
  users{
    id
    firstName
    lastName
    city
  }
}
```

## result
```
User Load (0.2ms)  SELECT "users".* FROM "users"
Post Load (0.3ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN ($1, $2)  [["user_id", 1], ["user_id", 2]]
Comment Load (0.3ms)  SELECT "comments".* FROM "comments" WHERE "comments"."user_id" IN ($1, $2)  [["user_id", 1], ["user_id", 2]]

{
  "data": {
    "users": [
      {
        "id": "1",
        "firstName": "John",
        "lastName": "Doe",
        "city": "London"
      },
      {
        "id": "2",
        "firstName": "Jane",
        "lastName": "Doe",
        "city": "New York"
      }
    ]
  }
}
```

<br>

## query2
```
{
  users{
    id
    fullName
    city
    posts {
      id
      body
      comments {
        id
        body
      }
    }

  }
}
```

## result
```
 User Load (0.2ms)  SELECT "users".* FROM "users"
  Post Load (0.2ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN ($1, $2)  [["user_id", 1], ["user_id", 2]]
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" IN ($1, $2, $3)  [["post_id", 1], ["post_id", 2], ["post_id", 3]]

{
  "data": {
    "users": [
      {
        "id": "1",
        "fullName": "John Doe",
        "city": "London",
        "posts": [
          {
            "id": "1",
            "body": "This is a post",
            "comments": [
              {
                "id": "1",
                "body": "This is a comment"
              },
              {
                "id": "2",
                "body": "This is another comment"
              }
            ]
          },
          {
            "id": "2",
            "body": "This is another post",
            "comments": []
          }
        ]
      },
      {
        "id": "2",
        "fullName": "Jane Doe",
        "city": "New York",
        "posts": [
          {
            "id": "3",
            "body": "This is yet another post",
            "comments": []
          }
        ]
      }
    ]
  }
}
```

---
# refs
- https://www.youtube.com/watch?v=clCq23KM05c