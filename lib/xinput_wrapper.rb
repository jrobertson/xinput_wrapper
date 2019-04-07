#!/usr/bin/env ruby

# file: xinput_wrapper.rb

require 'c32'


class XInputWrapper
  using ColouredText

  def initialize(device: '3', verbose: true, lookup: {}, debug: false )

    # defaults to QWERTY keyboard layout
    @modifiers = {
      62 => :shift,     # right control
      37 => :ctrl,   # left control 
      50 => :shift,     # left shift
      64 => :alt,       # alt shift
      92 => :alt,       # right alt  
      105 => :ctrl,  # right control     
      133 => :super,    # left super (windows key)
      134 => :super     # right super (windows key)
    }
    @lookup = {
      10=>:"1", 11=>:"2", 12=>:"3", 13=>:"4", 14=>:"5", 15=>:"6", 16=>:"7", 
      17=>:"8", 18=>:"9", 19=>:"0", 20=>:-, 21=>:"=", 22=>:backspace, 
      23=>:tab, 24=>:q, 25=>:w, 26=>:e, 27=>:r, 28=>:t, 29=>:y, 30=>:u, 
      31=>:i, 32=>:o, 33=>:p, 34=>:"[", 35=>:"]", 36=>:enter, 38=>:a, 39=>:s, 
      40=>:d, 41=>:f, 42=>:g, 43=>:h, 44=>:j, 45=>:k, 46=>:l, 47=>:";", 
      48=>:"'", 49=>nil, 52=>:z, 53=>:x, 54=>:c, 55=>:v, 56=>:b, 57=>:n, 
      58=>:m, 59=>:",", 60=>:".", 61=>:/,  65=>:" ",
      9 => :escape,
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
      95 => :f11,
      96 => :f12,
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
    }.merge(@modifiers).merge(lookup)
    
    @device, @verbose, @debug = device, verbose, debug
    
  end

  def listen()

    command = "xinput test-xi2 --root #{@device}"

    type = 0
    raw_keys = []

    IO.popen(command).each_line do |x|
 
      #print "GOT ", x
      raw_type = x[/EVENT type (\d+)/,1]

      type = raw_type.to_i unless raw_type.nil?
      next unless type == 13 or type == 14
    
      keycode = x[/detail: (\d+)/,1].to_i
      next if keycode == 0
          
      # type = 13 means a key has been pressed
      if type == 13 then
    
        raw_keys << keycode

        puts 'raw_keys: ' + raw_keys.inspect if @debug

        if raw_keys.length <= 1 then
          puts 'keycode: ' + keycode.to_s if keycode > 0 and @verbose
          puts ('>keycode: ' + keycode.to_s).debug  if @debug
      
          key = @lookup[keycode]
          


          puts ('key: ' + key.inspect).debug if @debug

          if key then
            puts key.to_s + ' key presssed' if @verbose
            name = "on_#{key}_key".to_sym
            method(name).call if self.protected_methods.include? name
            on_key_press key, keycode
          end        
    
        else

          keys = raw_keys.map {|kc| @lookup[kc] }
          puts ('keys: ' + keys.inspect) if @debug
          on_key_press(keys.last, keycode, keys[0..-2])    

        end
    


      elsif type == 14
    
        index = raw_keys.rindex(keycode)
        raw_keys.delete_at index if index

      end    
    
    end
  end
  
  protected
  
  def on_control_key()
    puts 'ctrl key pressed'
  end  
    
  def on_key_press(key, keycode, modifier)
    
    if @debug then
      puts ('key: ' + key.inspect).debug
    end
    
  end
  
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
  
  private
    
  def on_leftcontrol_key()  on_control_key()  end
  def on_rightcontrol_key() on_control_key()  end     
  def on_left_alt_key()     on_alt_key()      end
  def on_right_alt_key()   on_alt_key()      end    
  def on_left_shift_key()   on_shift_key()    end
  def on_right_shift_key()  on_shift_key()    end        
    
end

# puts  h.sort.map {|x| "%s => :%s" % x}.join(",\n")
