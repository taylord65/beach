require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork

  handler do |job|
    puts "Running #{job}"
  end

  every(2.minutes, 'Filtering Streams') { Delayed::Job.enqueue FilterJob.new}
end