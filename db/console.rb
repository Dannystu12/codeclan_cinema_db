require "pry"
require_relative "../models/customer"
require_relative "../models/film"
require_relative "../models/ticket"

customer1 = Customer.new({"name" => "Daniel", "funds" => 50})
customer1.create

binding.pry
nil
