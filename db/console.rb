require "pry"
require_relative "../models/customer"
require_relative "../models/film"
require_relative "../models/ticket"

Ticket.delete_all
Customer.delete_all
Film.delete_all

# MVP
# Test customers
customer1 = Customer.new({"name" => "Daniel", "funds" => 50})
customer1.create
raise "Customer not created correctly" unless Customer.read_all.size == 1

daniel = Customer.find_name "Daniel"
raise "Cannot find customer by name" unless daniel.id == customer1.id

customer1.funds = 100.50
customer1.update
daniel.refresh
raise "cannot update customer" unless daniel.funds == customer1.funds

customer1.delete
raise "Customer not deleted correctly" unless Customer.read_all.size == 0

daniel.create

customer2 = Customer.new({"name" => "Andrew", "funds" => 20})
customer2.create
andrew = Customer.find_id customer2.id


gordon = Customer.find_id 90000
raise "Error finding no existant customer" unless !gordon

connor = Customer.find_name "Connor"
raise "Error finding no existant customer" unless !gordon

customers = Customer.read_all
raise "incorrect amount of customers" unless customers.size == 2

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
raise "Wrong number of tickets created" unless Ticket.read_all.size == 1

ticket1.customer_id = daniel.id
ticket1.update

raise "Ticket not updated correctly" unless Ticket.get_films_by_customer(daniel.id).size == 1

tickets_before = Ticket.read_all.size
ticket1.delete
tickets_after= Ticket.read_all.size
raise "Wrong number of tickets remaining after delete" unless tickets_after - tickets_before == -1

ticket1.create

#test getting films by customer and customers by film
daniel_films = daniel.get_films
andrew_films = andrew.get_films
raise "Wrong number of films retrieved for customers" unless daniel_films.size == 1 && andrew_films.size == 0

anchorman_customers = film2.get_customers
the_room_customers = the_room.get_customers
raise "Wrong number of customers retrieved for films" unless anchorman_customers.size == 1 && the_room_customers.size == 0

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

# Test updating ticket refunds and reduces funds
daniel.refresh
daniel_funds_before = daniel.funds
matthew_funds_before = matthew.funds
cheap_ticket.customer_id = daniel.id
cheap_ticket.update
daniel.refresh
matthew.refresh

raise "Funds not deducted correctly from new customer" unless daniel.funds == daniel_funds_before - cheap_film.price

raise "Funds not refunded correctly to original customer" unless matthew.funds == matthew_funds_before + cheap_film.price

# Test can change film and charge customer
cheap_ticket.customer_id = matthew.id
cheap_ticket.update
matthew.refresh
matthew_funds_before = matthew.funds
another_film = Film.new({"title" => "Iron Sky 3", "price" => "1"})
another_film.create
cheap_ticket.film_id = another_film.id
cheap_ticket.update
matthew.refresh
raise "Error charging user for another film" unless matthew.funds == (matthew_funds_before + cheap_film.price - another_film.price).round(2)

# Test case where customer cant afford new film
matthew_funds_before = matthew.funds
cheap_ticket.film_id = expensive_film.id
cheap_ticket.update
matthew.refresh
cheap_ticket.refresh
raise "Customer funds incorrect when trying to change film" unless matthew.funds == matthew_funds_before
raise "Wrong film on ticket" unless cheap_ticket.film_id == another_film.id

# Test case where new customer cant affor new film
daniel.refresh
daniel_funds_before = daniel.funds
matthew_funds_before = matthew.funds
cheap_ticket.customer_id = daniel.id
cheap_ticket.film_id = expensive_film.id
cheap_ticket.update
matthew.refresh
daniel.refresh
cheap_ticket.refresh

raise "Wrong customer on ticket" unless cheap_ticket.customer_id == matthew.id
raise "Wrong film on ticket" unless cheap_ticket.film_id == another_film.id
raise "Customer not charged correctly" unless matthew.funds == matthew_funds_before
raise "Customer not charged correctly" unless daniel.funds == daniel_funds_before

binding.pry
nil
