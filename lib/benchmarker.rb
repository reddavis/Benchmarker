$: << File.dirname(__FILE__)
require 'rubygems'
require 'fsevents'
require 'stringio'
require 'ext/kernel'
      
class Benchmarker
  class << self
        
    def go(path)
      @path = path
      check_path_exists
      add_sigint_handler
      
      stream = FSEvents::Stream.watch(path) do |events|
        output = capture_stdout do
          yield
        end   
        times << grab_times(output.string).flatten
        display_output
      end
      stream.run
    end
    
    def times
      @times ||= []
    end
    
    def add_sigint_handler
      trap 'INT' do
        puts "Bye!"
        raise Interrupt, nil # let the run loop catch it
      end
    end
    
    private
    
    def display_output
      output = ""
      last_time = @times[-2]
      now = @times[-1]
      output << "Last Time: #{last_time.inspect}\n" if last_time
      output << "Now      : #{now.inspect}\n"
      output << calculate_difference(last_time, now) if last_time
      output << "-" * 50
      puts output
    end
    
    def calculate_difference(last_time, now)
      changes = []
      last_time.each_with_index do |time, index|
        a = "#{(((time.to_f - now[index].to_f) / time.to_f) * 100).to_i}%"
        changes << a
      end
      "Change   : #{changes.inspect}\n"
    end
    
    def grab_times(output)
      output.scan(/(\d+\.?\d+)\)/)
    end
        
    def check_path_exists
      unless File.directory?(@path)
        raise "Error: Wheres your libs?"
      end
    end
    
  end
end