# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

LineItem.delete_all
Product.delete_all
Product.create!(title: "Programming Ruby 1.9 & 2.0",
  description: "Ruby is the fastest growing and most exciting dynamic language out there. If you need to get working programs delivered fast, you should add Ruby to your toolbox.",
  image_url: "ruby.jpg",
  price: 49.95)

Product.create!(title: "Rails Test Prescriptions",
                description: "Rails Test Prescriptions is a comprehensive guide to testing Rails applications, covering Test-Driven Development from both a theoretical perspective (why to test) and from a practical perspective (how to test effectively). It covers the core Rails testing tools and procedures for Rails 2 and Rails 3, and introduces popular add-ons, including Cucumber, Shoulda, Machinist, Mocha, and Rcov.",
                image_url: "ruby.jpg",
                price: 34.95)

Product.create!(title: "Rails, Angular, Postgres, and Bootstrap",
                description: "Powerful, Effective, and Efficient Full-Stack Web Development",
                image_url: "ruby.jpg",
                price: 44.95)
