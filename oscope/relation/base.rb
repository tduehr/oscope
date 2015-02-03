class Oscope
  module Relation
    class Base
      attr_reader :scope, :command
      def initialize scope, command, commands
        @scope = scope
        @command = command
        @subcommands = commands
      end

      def subcommands
        @subcommands.keys
      end

      def inspect
        "\#<Relation:0x#{(__id__ * 2).to_s(16).rjust(14, '0')} #{@command}>"
      end

      def method_missing meth, *args, &block
        subs = @subcommands[meth.to_s]
        super unless subs
        meth = meth.to_s.split('_').join
        if subs.kind_of?(::Hash) # sub-sub-commands
          self.class.new @scope, "#{@command}:#{meth.upcase}", subs
        else
          raise ArgumentError unless subs.include? args.size
          if meth.end_with? "=" # set something
            write ["#{@command}:#{meth[0..-2]}", args.join(',')].join(" ")
          else # get something
            query_full ["#{@command}:#{meth}?", args.join(',')].join(" ")
          end
        end
      end

      def respond_to_missing? meth
        subcommands.include? meth || super
      end

      private
      def write comm
        @scope.session.write comm
      end

      def query comm
        @scope.session.query comm
      end

      def query_full comm
        @scope.session.query_full comm
      end
    end
  end
end
