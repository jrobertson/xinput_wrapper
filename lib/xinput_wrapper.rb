#!/usr/bin/env ruby

# file: xinput_wrapper.rb


require 'sps-pub'
require 'secret_knock'


class XInputWrapper

  def initialize(device: '3', host: 'sps', port: '59000', 
                  topic: 'input/keyboard', verbose: true, lookup: nil)

    @lookup = {
      37 => :control,
      50 => :lshift,
      133 => :super
    }.merge(lookup)

    @device, @topic, @verbose = device, topic, verbose
    @sps = SPSPub.new host: host, port: port
    @sk = SecretKnock.new short_delay: 0.25, long_delay: 0.5, 
                              external: self, verbose: verbose
  end

  def knock()
    puts 'knock' if @verbose
  end

  def message(msg)
    return if msg.strip.empty?
    @sps.notice "%s: %s" % [@topic, msg]
  end

  def listen()

    command = "xinput test-xi2 --root #{@device}"
    @sk.detect timeout: 0.7
    sk = @sk
    type = 0

    IO.popen(command).each_line do |x|
 
      #print "GOT ", x
      raw_type = x[/EVENT type (\d+)/,1]

      type = raw_type.to_i unless raw_type.nil?
      
      # type = 13 means a key has been pressed
      if type == 13 then

        keycode = x[/detail: (\d+)/,1].to_i

        puts 'keycode: ' + keycode.to_s if keycode > 0 and @verbose

        case @lookup[keycode]
        when :lshift
          puts 'left shift' if @verbose
        when :control
          puts 'control' if @verbose
          sk.knock
        when :super
          puts 'super key pressed'  if @verbose
          message 'super key pressed' 
        end

      end
    end
  end
end
