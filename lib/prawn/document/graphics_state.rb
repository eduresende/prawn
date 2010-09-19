# encoding: utf-8
#
# graphics_state.rb: Implements graphics state saving and restoring
#
# Copyright January 2010, Michael Witrant. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  class GraphicStateStack
    attr_accessor :stack
    
    def initialize()
      self.stack = [GraphicState.new]
    end
    
    def save_graphic_state
      stack.push(GraphicState.new)
    end
    
    def restore_graphic_state
      if stack.size == 1
        raise Prawn::Errors::EmptyGraphicStateStack, 
          "\n You have reached the end of the graphic state stack" 
      end
      stack.pop
    end
    
    def current_state
      stack.last
    end
    
    def present?
      stack.size > 1
    end
      
  end
  
  class GraphicState
    attr_accessor :color_space, :dash
    
    def initialize
      @color_space = {}
      @dash = { :dash => nil, :space => nil, :phase => 0 }
    end
    
    def dash_setting
      "[#{@dash[:dash]} #{@dash[:space]}] #{@dash[:phase]} d"
    end
  end
  
  class Core::Page
    def current_graphic_state
      stack.current_state
    end
    
    def current_dash_state
      stack.current_state.dash
    end
  end
  
  class Document
    module GraphicsState

      # Pushes the current graphics state on to the graphics state stack so we
      # can restore it when finished with a change we want to isolate (such as
      # modifying the transformation matrix). Used in pairs with
      # restore_graphics_state or passed a block
      #
      # Example without a block:
      #
      #   save_graphics_state
      #   rotate 30
      #   text "rotated text"
      #   restore_graphics_state
      #
      # Example with a block:
      #
      #   save_graphics_state do
      #     rotate 30
      #     text "rotated text"
      #   end
      #
      def save_graphics_state
        add_content "q"
        current_graphic_stack.save_graphic_state
        if block_given?
          yield
          restore_graphics_state
        end
      end

      # Pops the last saved graphics state off the graphics state stack and
      # restores the state to those values
      def restore_graphics_state
        #if state.page.stack.present?
          
          current_graphic_stack.restore_graphic_state
          add_content "Q" 
        #end
        # require 'drop_to_console'
        # console_for(binding)
      end
      
      def current_graphic_stack
        state.page.stack
      end
      
      def current_graphic_state
        current_graphic_stack.current_state
      end
      
    end
  end
end
