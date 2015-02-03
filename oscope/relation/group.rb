class Oscope
  module Relation
    class Group < Base
      SUBS = %w{state state= size size=}
      def initialize scope, n
        @scope = scope
        @command = ":la:group#{n}"
      end

      def subcommands
        SUBS
      end

      def state
        query_full "#{@command}?"
      end

      def state= stat
        write "#{@command} #{stat}"
      end

      def size
        query_full "#{@command}:size?"
      end

      def size= len
        write "#{@command}:size #{len}"
      end
    end
  end
end
