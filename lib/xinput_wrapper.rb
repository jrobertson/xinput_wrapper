#!/usr/bin/env ruby

# file: xinput_wrapper.rb

require 'c32'


class XInputWrapper
  using ColouredText

  def initialize(device: '3', verbose: true, lookup: {}, debug: false )

    @lookup = {
      9 => :escape,
      37 => :control,
      50 => :shift,
      62 => :shift,
      64 => :alt,
      66 => :capslock,
      67 => :f1,
      68 => :f2,
      69 => :f3,
      70 => :f4,
      71 => :f5,
      72 => :f6,
      73 => :f7,
      74 => :f8,
      75 => :f9,
      76 => :f10,
      77 => :numlock,
      78 => :scroll_lock,
      92 => :alt,
      95 => :f11,
      96 => :f12,
      105 => :control,
      107 => :print_screen,
      110 => :home,
      111 => :up_arrow,
      112 => :pgup,
      113 => :left_arrow,
      114 => :right_arrow,
      115 => :end,
      116 => :down_arrow,
      117 => :pgdown,
      121 => :mute,
      122 => :vol_down,
      123 => :vol_up,
      127 => :pause_break,
      133 => :super,
      134 => :super,
      135 => :submenu,
      148 => :calc,
      150 => :sleep,
      151 => :wakeup,
      163 => :email,
      166 => :go_back,
      167 => :go_forward,
      171 => :next_track,
      172 => :play_stop,
      173 => :prev_track,
      174 => :stop,
      179 => :music,
      180 => :browser
    }.merge(lookup)
    
    @device, @verbose, @debug = device, verbose, debug
    
  end

  def listen()

    command = "xinput test-xi2 --root #{@device}"

    type = 0

    IO.popen(command).each_line do |x|
 
      #print "GOT ", x
      raw_type = x[/EVENT type (\d+)/,1]

      type = raw_type.to_i unless raw_type.nil?
      
      # type = 13 means a key has been pressed
      if type == 13 then

        keycode = x[/detail: (\d+)/,1].to_i
        next if keycode == 0

        puts 'keycode: ' + keycode.to_s if keycode > 0 and @verbose
        puts ('>keycode: ' + keycode.to_s).debug  if @debug
        
        on_key_press(keycode)

        key = @lookup[keycode]
        puts ('key: ' + key.inspect).debug if @debug

        if key then
          puts key.to_s + ' key presssed' if @verbose
          name = "on_#{key}_key".to_sym
          method(name).call if self.protected_methods.include? name
        end        

      end
    end
  end
  
  protected
  
  def on_control_key()
    puts 'ctrl key pressed'
  end  
  def on_key_press(keycode)  end
  
  def on_shift_key()  end
  def on_super_key()  end
  
  def on_f1_key()   end
  def on_f2_key()   end
  def on_f3_key()   end
  def on_f4_key()   end
  def on_f5_key()   end
  def on_f6_key()   end    
  def on_f7_key()   end
  def on_f8_key()   end
  def on_f9_key()   end
  def on_f10_key()  end
  def on_f11_key()  end
  def on_f12_key()  end    
    
end

# puts  h.sort.map {|x| "%s => :%s" % x}.join(",\n")
