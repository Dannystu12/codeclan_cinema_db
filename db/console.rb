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
ticket1.create

#test getting films by customer and customers by film
daniel_films = daniel.get_films
andrew_films = andrew.get_films
anchorman_customers = film2.get_customers
the_room_customers = the_room.get_customers

# Test buying tickets reduces customer funds
original_ticket_count = Ticket.read_all.size

cheap_film = Film.new({"title" => "Iron Sky", "price" => "1.2"})
cheap_film.create

expensive_film = Film.new({"title" => "Iron Sky 2", "price" => "999"})
expensive_film.create

matthew = Customer.new({"name" => "Matthew", "funds" => "1.2"})
matthew.create

cheap_ticket = Ticket.new({"customer_id" => matthew.id, "film_id" => cheap_film.id})
cheap_ticket.create
matthew.refresh
raise "Funds not deducted correctly" unless matthew.funds == 0

expensive_ticket = Ticket.new({"customer_id" => matthew.id, "film_id" => expensive_film.id})
expensive_ticket.create
matthew.refresh
raise "Funds changing when cannot afford film" unless matthew.funds == 0

raise "incorrect number of tickets created" unless Ticket.read_all.size - original_ticket_count == 1

# Test buying ticket from customer
original_ticket_count = Ticket.read_all.size

matthew.funds = 1.2
matthew.update
matthew.buy_ticket cheap_film
raise "Funds not deducted correctly" unless matthew.funds == 0
raise "incorrect number of tickets created" unless Ticket.read_all.size - original_ticket_count == 1

# Test getting ticket count for a customer
raise "Wrong ticket count retrieved" unless matthew.ticket_count == 2
raise "Wrong customer count retrieved" unless cheap_film.customer_count == 2


binding.pry
nil
