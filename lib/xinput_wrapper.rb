#!/usr/bin/env ruby

# file: xinput_wrapper.rb

# Captures keyboard or mouse events using program xinput.


# note: To display a list of xinput devices, run the 
#       xinput program without any options.

require 'c32'


MOTION = 6
RAWKEY_PRESS = 13
RAWKEY_RELEASE = 14
RAWBUTTON_PRESS = 15
RAWBUTTON_RELEASE = 16
BUTTONS = %i(left middle right scrollup scrolldown)


class XInputWrapper
  using ColouredText
  
  attr_accessor :stop

  # device list:
  #       3 = Virtual core keyboard
  #       4 = Virtual core XTEST pointer (active when using VNC)
  #       5 = Virtual core XTEST keyboard (active when using VNC)
  #       10 = USB Optical Mouse (locally attached)
  #       11 = Microsoft Wired Keyboard 600 (locally attached)
  #
  def initialize(device: nil, verbose: true, lookup: {}, debug: false, 
                 callback: nil )

    @callback = callback
    
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
      58=>:m, 59=>:",", 60=>:".", 61=>:/,  65=>:space,
      9 => :esc,
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
      78 => :scrolllock,
      95 => :f11,
      96 => :f12,
      107 => :sysrq, # print_screen
      110 => :home,
      111 => :up, # arrow keys
      112 => :pageup,
      113 => :left, # arrow keys
      114 => :right, # arrow keys
      115 => :end, 
      116 => :down, # arrow keys
      117 => :pagedown,
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
    
    @stop = false
    
    command = "xinput test-xi2 --root #{@device}"

    type = 0
    raw_keys = []
    t1 = Time.now
    lines = []    

    IO.popen(command).each_line do |x|
 
      break if @stop
      #print "GOT ", x
      if x[/EVENT type \d \(Motion\)/] and (Time.now > (t1 + 0.06125)) then 

        type = x[/EVENT type (\d+)/,1].to_i
    
        r = lines.join[/^\s+root: (\d+\.\d{2}\/\d+\.\d{2})/,1]

        if r then
      
          x1, y1 = r.split('/').map(&:to_f) 
          puts "x1: %s y1: %s" % [x1, y1] if @debug
          on_mousemove(x1, y1)
          @callback.on_mousemove(x1, y1) if @callback
          @mouse_pos = [x1,y1]
          t1 = Time.now  
    
        end        

        lines = [x]                                                                

      elsif x[/EVENT type \d+ \(Raw(?:Key|Button)(?:Release|Press)\)/]

        type = x[/EVENT type (\d+)/,1].to_i

        lines = [x]
    

      elsif [MOTION, RAWKEY_PRESS, RAWKEY_RELEASE, RAWBUTTON_PRESS, 
             RAWBUTTON_RELEASE].include? type

        lines << x
    
        if x == "\n" then
          case lines.first[/(?<=EVENT type )\d+/].to_i
          when RAWKEY_PRESS
      
            r = lines.join[/detail: (\d+)/,1]

            keycode = r.to_i if r

            type = lines.join[/EVENT type (\d+)/,1] .to_i
      
          when RAWKEY_RELEASE
      
            r = lines.join[/detail: (\d+)/,1]

            keycode = r.to_i if r

            type = lines.join[/EVENT type (\d+)/,1] .to_i          
    

          when RAWBUTTON_PRESS
      
            r = lines.join[/detail: (\d+)/,1]

            buttoncode = r.to_i if r

            type = lines.join[/EVENT type (\d+)/,1] .to_i
      
          when RAWBUTTON_RELEASE
      
            r = lines.join[/detail: (\d+)/,1]

            buttoncode = r.to_i if r

            type = lines.join[/EVENT type (\d+)/,1] .to_i       
      
          end    

    
        else
            next
        end
    
      else
        next
      end
    
      next unless keycode or buttoncode
      puts 'keycode: ' + keycode.inspect if @debug
      puts 'buttoncode: ' + buttoncode.inspect if @debug
          
      # type = 13 means a key has been pressed
      if type == RAWKEY_PRESS then
    
        if @modifiers.include? raw_keys.last or @modifiers.include? keycode then
          raw_keys << keycode
        end
    
        next if @modifiers.include? keycode

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
            
            keystring = ((key.length > 1 or key == ' ') ? "{%s}" % key : key)    
            block_given? ? yield(keystring) : on_key_press(keystring, keycode)
            @callback.on_keypress(keystring, keycode) if @callback

          end        
    
        else

          keys = raw_keys.map {|kc| @lookup[kc] }
          puts ('keys: ' + keys.inspect) if @debug
    
          if block_given? then
            yield(format_key(keys.last, keys[0..-2]))
          else
            on_key_press(keys.last, keycode, keys[0..-2])    
            @callback.on_keypress(keys.last, keycode, keys[0..-2])  if @callback
          end
    
          raw_keys = []

        end
    


      # a key has been released
      elsif type == RAWKEY_RELEASE
    
        # here we are only looking to detect a 
        # single modifier key press and release
    
        key = @lookup[keycode]
    
        unless raw_keys.empty? then
          puts key.to_s + ' key presssed' 
    
          if block_given? then
    
            yield(format_key(key.to_s))
    
          else
            name = "on_#{key}_key".to_sym
            method(name).call if self.protected_methods.include? name
            on_key_press(key, keycode)
            @callback.on_keypress(key, keycode) if @callback
          end
        end
    
        index = raw_keys.rindex(keycode)
        raw_keys.delete_at index if index
    
      elsif type == RAWBUTTON_PRESS
    
        button = BUTTONS[buttoncode-1]
    
        case button
        when :scrollup
          on_mouse_scrollup() 
          @callback.on_mouse_scrollup() if @callback
        when :scrolldown
          on_mouse_scrolldown()
          @callback.on_mouse_scrolldown() if @callback
        else
          on_mousedown(button, *@mouse_pos) 
          @callback.on_mousedown(button, *@mouse_pos) if @callback
        end
    
      elsif type == RAWBUTTON_RELEASE
    
        button = BUTTONS[buttoncode-1]
        on_mouseup(BUTTONS[buttoncode-1], *@mouse_pos)
    
      end    
    
    end
  end
  
  protected
  
  def on_control_key()
    puts 'ctrl key pressed'
  end  
    
  def on_key_press(key, keycode, modifier=nil)
    
    if @debug then
      puts ('key: ' + key.inspect).debug
    end
    
  end
    
  def on_mousedown(button, x,y)
    
    if @debug then
      puts "on_mousedown() %s click x: %s y: %s" % [button, x, y]
    end
    
  end    
    
  def on_mousemove(x,y)
    
    if @debug then
      puts "on_mousemove() x: %s y: %s" % [x, y]
    end
    
  end
    
  def on_mouseup(button, x,y)
    
    if @debug then
      puts "on_mousedown() %s click x: %s y: %s" % [button, x, y]
    end
    
  end        
    
  def on_mouse_scrolldown()
    
    if @debug then
      puts "on_mouse_scrolldown()"
    end
    
  end       
    
  def on_mouse_scrollup()
    
    if @debug then
      puts "on_mouse_scrollup()"
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
    
  def format_key(key, modifier=[])
    
    modifier.any? ? "{%s}" % (modifier + [key.to_s]).join('+') \
          : key.to_s
    
  end
    
  def on_leftcontrol_key()  on_control_key()  end
  def on_rightcontrol_key() on_control_key()  end     
  def on_left_alt_key()     on_alt_key()      end
  def on_right_alt_key()   on_alt_key()      end    
  def on_left_shift_key()   on_shift_key()    end
  def on_right_shift_key()  on_shift_key()    end        
    
end

# puts  h.sort.map {|x| "%s => :%s" % x}.join(",\n")
