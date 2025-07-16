module Jekyll
  module UJPowertools
    class IfIsTruthyTag < Liquid::Block
      Syntax = /(\w+)/

      def initialize(tag_name, markup, tokens)
        super
        
        if markup =~ Syntax
          @variable_name = $1
        else
          raise SyntaxError, "Invalid syntax for ifistruthy tag. Usage: {% ifistruthy variable_name %}"
        end
      end

      def render(context)
        variable = context[@variable_name]
        is_truthy = check_truthy(variable)
        
        # Split content at else tag
        else_index = nil
        @nodelist.each_with_index do |node, index|
          if node.respond_to?(:tag_name) && node.tag_name == 'else'
            else_index = index
            break
          end
        end
        
        if is_truthy
          if else_index
            render_nodelist(@nodelist[0...else_index], context)
          else
            super(context)
          end
        else
          if else_index
            render_nodelist(@nodelist[(else_index + 1)..-1], context)
          else
            ''
          end
        end
      end

      def unknown_tag(tag_name, markup, tokens)
        if tag_name == 'else'
          @nodelist << Liquid::ElseTag.new(tag_name, markup, tokens)
        else
          super
        end
      end

      private

      def check_truthy(value)
        return false if value.nil?
        return false if value.respond_to?(:empty?) && value.empty?
        return false if value.to_s.downcase == 'null'
        return false if value == false
        true
      end

      def render_nodelist(nodelist, context)
        output = []
        nodelist.each do |token|
          case token
          when String
            output << token
          else
            if token.respond_to?(:render)
              output << token.render(context)
            else
              output << token.to_s
            end
          end
        end
        output.join
      end
    end

    class UnlessIsTruthyTag < Liquid::Block
      Syntax = /(\w+)/

      def initialize(tag_name, markup, tokens)
        super
        
        if markup =~ Syntax
          @variable_name = $1
        else
          raise SyntaxError, "Invalid syntax for unlessistruthy tag. Usage: {% unlessistruthy variable_name %}"
        end
      end

      def render(context)
        variable = context[@variable_name]
        is_truthy = check_truthy(variable)
        
        # Split content at else tag
        else_index = nil
        @nodelist.each_with_index do |node, index|
          if node.respond_to?(:tag_name) && node.tag_name == 'else'
            else_index = index
            break
          end
        end
        
        if !is_truthy
          if else_index
            render_nodelist(@nodelist[0...else_index], context)
          else
            super(context)
          end
        else
          if else_index
            render_nodelist(@nodelist[(else_index + 1)..-1], context)
          else
            ''
          end
        end
      end

      def unknown_tag(tag_name, markup, tokens)
        if tag_name == 'else'
          @nodelist << Liquid::ElseTag.new(tag_name, markup, tokens)
        else
          super
        end
      end

      private

      def check_truthy(value)
        return false if value.nil?
        return false if value.respond_to?(:empty?) && value.empty?
        return false if value.to_s.downcase == 'null'
        return false if value == false
        true
      end

      def render_nodelist(nodelist, context)
        output = []
        nodelist.each do |token|
          case token
          when String
            output << token
          else
            if token.respond_to?(:render)
              output << token.render(context)
            else
              output << token.to_s
            end
          end
        end
        output.join
      end
    end
  end
end

# Register the tags
Liquid::Template.register_tag('ifistruthy', Jekyll::UJPowertools::IfIsTruthyTag)
Liquid::Template.register_tag('unlessistruthy', Jekyll::UJPowertools::UnlessIsTruthyTag)