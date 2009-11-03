class RPNCalculator
  attr_accessor :stack

  def initialize
    @stack = []
  end

  def calc(exp)
    exp.split.each do |item|
      case item
      # Decimal numbers
      when /^-?(?:0|[1-9]\d*)(?:\.\d+)?$/
        @stack << item.to_f

      # Hexadecimal numbers
      when /^-?0x[0-9a-f]$/i
        @stack << item.to_i(16).to_f

      # Octal numbers
      when /^-?0[0-7]+$/
        @stack << item.to_i(8).to_f

      # Binary numbers
      when /^-?0b[01]+$/i
        @stack << item.to_i(2).to_f

      # Custom radix numbers (radix = base)
      when /^(-?)(\d)+r([0-9a-z])+$/
        sign, radix, digits = $1, $2, $3
        digits.to_i(radix).to_f * "#{sign}1".to_f
        # TODO: Error handling

      # Math operators
      when '+', '-', '*', '/', 'div', '%', '**'
        raise "Operator '#{item}' tried to pop 2 items, but the stack only has #{stack.length}" if @stack.length < 2
        a, b = @stack.pop(2)
        @stack << a.send(item, b)

      # Convenience math commands
      when 'sum'
        # Reduce the stack to a single value by adding all the numbers
        # together. Pushes 0 (the additive identity) if the stack is empty.
        @stack = [@stack.reduce(0, :+)]

      when 'prod'
        # Reduce the stack to a single value by multiplying all the
        # numbers together. Pushes 1 (the multiplicative identity) if
        # the stack is empty.
        @stack = [@stack.reduce(1, :*)]

      # Stack manipulation commands
      when 'flip'
        # Pops two values and pushes them back in reverse order.
        # [12, 24, 36] flip => [12, 36, 24]
        @stack += @stack.pop(2).reverse

      when 'pop'
        # Simply pops one value, destroying it.
        @stack.pop
      end
    end

    self
  end

  def inspect
    "#<RPNCalculator: #{stack.inspect}>"
  end
end
