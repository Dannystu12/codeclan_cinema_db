require "pry"
require_relative "../models/customer"
require_relative "../models/film"
require_relative "../models/ticket"

customer1 = Customer.new({"name" => "Daniel", "funds" => 50})
customer1.create
daniel = Customer.find_name "Daniel"
customer1.funds = 100.50
customer1.update
customer1.delete

customer2 = Customer.new({"name" => "Andrew", "funds" => 20})
customer2.create
andrew = Customer.find_id customer2.id

gordon = Customer.find_id 90000
connor = Customer.find_name "Connor"
customers1 = Customer.read_all
Customer.delete_all
customers2 = Customer.read_all
binding.pry
nil
