# Helper module for resolving variables in Jekyll tags
module Jekyll
  module UJPowertools
    module VariableResolver
      # Resolve a variable or string literal from context
      # If prefer_literal is true, unquoted strings are treated as literals unless they're clearly variables
      def resolve_input(context, input, prefer_literal = false)
        return nil if input.nil? || input.empty?
        
        # Check if the input is a quoted string literal
        if input.match(/^["'](.*)["']$/)
          # It's a string literal - extract the value between quotes
          $1
        elsif prefer_literal
          # In prefer_literal mode, only treat as variable if it has dots or exists in context
          if input.include?('.') || context[input]
            resolve_variable(context, input)
          else
            # Treat as literal string
            input
          end
        else
          # Default behavior - try to resolve as variable, return nil if not found
          resolve_variable(context, input)
        end
      end

      # Resolve a variable path through Jekyll's context
      def resolve_variable(context, variable_name)
        return nil if variable_name.nil? || variable_name.empty?
        
        # Handle nested variable access like page.resolved.post.id
        parts = variable_name.split('.')
        
        # Start with the first part
        current = context[parts.first]
        
        # Navigate through nested properties
        parts[1..-1].each do |part|
          break if current.nil?
          
          # Handle different types of objects
          if current.respond_to?(:[])
            current = current[part]
          elsif current.respond_to?(:data) && current.data.respond_to?(:[])
            # Handle Jekyll Drop objects
            current = current.data[part]
          else
            current = nil
          end
        end
        
        current
      end

      # Parse comma-separated arguments (preserving quotes)
      def parse_arguments(markup)
        args = []
        current_arg = ''
        in_quotes = false
        quote_char = nil

        markup.each_char do |char|
          if !in_quotes && (char == '"' || char == "'")
            in_quotes = true
            quote_char = char
            current_arg += char
          elsif in_quotes && char == quote_char
            in_quotes = false
            quote_char = nil
            current_arg += char
          elsif !in_quotes && char == ','
            args << current_arg.strip
            current_arg = ''
          else
            current_arg += char
          end
        end

        args << current_arg.strip if current_arg.strip.length > 0
        args
      end

      # Parse key=value options from arguments
      def parse_options(args, context = nil)
        options = {}
        
        args.each do |arg|
          if arg.include?('=')
            key, value = arg.split('=', 2)
            key = key.strip
            value = value.strip
            
            # If context provided, resolve variables in values
            if context
              value = resolve_input(context, value)
            else
              # Just strip quotes if no context
              value = value.gsub(/^['"]|['"]$/, '')
            end
            
            options[key] = value
          end
        end
        
        options
      end

      # Check if input was originally quoted
      def is_quoted?(input)
        !!(input && input.match(/^["']/))
      end
    end
  end
end