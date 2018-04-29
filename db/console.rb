require "pry"
require_relative "../models/customer"
require_relative "../models/film"
require_relative "../models/ticket"

Ticket.delete_all
Customer.delete_all
Film.delete_all

# Test customers
customer1 = Customer.new({"name" => "Daniel", "funds" => 50})
customer1.create
daniel = Customer.find_name "Daniel"
customer1.funds = 100.50
customer1.update
customer1.delete
daniel.create

customer2 = Customer.new({"name" => "Andrew", "funds" => 20})
customer2.create
andrew = Customer.find_id customer2.id

gordon = Customer.find_id 90000
connor = Customer.find_name "Connor"
customers = Customer.read_all

# Test films
film1 = Film.new({"title" => "The Room", "price" => "9.80"})
film1.create
film1.price = 10
film1.update
the_room = Film.find_title "The Room"
the_room2 = Film.find_id film1.id

film2 = Film.new({"title" => "Anchorman", "price" => "11.60"})
film2.create

films = Film.read_all
film1.delete
films2 = Film.read_all

# Test tickets
ticket1 = Ticket.new({"customer_id" => andrew.id, "film_id" => film2.id})
ticket1.create
ticket1.customer_id = daniel.id
ticket1.update
daniel_ticket = Ticket.find_id(Ticket.read_all()[0].id)
tickets = Ticket.read_all
ticket1.delete
tickets2 = Ticket.read_all

binding.pry
nil
