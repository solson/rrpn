class RpnCalculator
  DIGITS = %w{0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z}
  
  attr_accessor :stack

  def initialize
    @stack = []
  end

  def calc(exp)
    exp.split.each do |item|
      case item
      # Decimal numbers
      # Format: just 0 or any string of digits not starting in 0
      # (numbers beginning with 0 are treated as octal)
      # you may also have a sign and a decimal with digits afterwards
      #   [sign]<digits>[.<decimaldigits>]
      when /^-?(?:0|[1-9]\d*)(?:\.\d+)?$/
        @stack << item.to_f

      # Hexadecimal numbers
      # Format: [sign]0x<digits> (case-insensitive)
      when /^-?0x[0-9a-f]$/i
        @stack << item.to_i(16).to_f

      # Octal numbers
      # Format: [sign]0<digits>
      when /^-?0[0-7]+$/
        @stack << item.to_i(8).to_f

      # Binary numbers
      # Format: [sign]0b<digits> (case-insensitive)
      when /^-?0b[01]+$/i
        @stack << item.to_i(2).to_f

      # Arbitrary radix numbers
      # Format: [sign]<radix>r<digits> (case-insensitive)
      # Example: -3r102 (base 3 represention of -11)
      when /^(-?)(\d)+r([0-9a-z]+)$/
        sign, radix, digits = $1, $2, $3
        radix = radix.to_i
        
        raise "Invalid radix '#{radix}'. Please use a radix in the range of 2..36." if radix < 2 or radix > 36
        
        valid_digits = DIGITS[0,radix]
        raise "Invalid digits encountered in the arbitrary radix number '#{item}'." unless digits.downcase.chars.all? { |c| valid_digits.include? c }

        @stack << (sign + digits).to_i(radix).to_f
        
      # Basic arithmetic operators
      when '+', '-', '*', '/', '**'
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
    "#<RpnCalculator: #{stack.inspect}>"
  end
end
