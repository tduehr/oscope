class Oscope
  module Relation
    class Key < Base
      COMM = ":key"
      SUBS = %w{
        lock run auto channel1 channel2 math ref f1 f2 f3 f4 f5 menu_off measure
        cursor acquire display storage utility menu_time menu_trig trig_50 force
        v_pos_inc v_pos_dec v_scale_inc v_scale_dec h_scale_inc h_scale_dec
        trig_lvl_inc trig_lvl_dec h_pos_inc h_pos_dec prompt_v prompt_h function
        p_function n_function la prompt_v_pos prompt_h_pos prompt_trig_lvl off
      }

      def initialize scope
        @scope = scope
        @command = COMM
      end

      def subcommands
        SUBS
      end

      def method_missing meth, *args, &block
        super unless SUBS.include? meth.to_s
        write ":key:#{meth}"
      end

      def lock= state; write ":key:lock #{state}"; end
      def lock; query_full ":key:lock"; end

      def menu_time; write ":key:mnutime"; end
      def menu_trig; write ":key:mnutrig"; end
      def menu_time; write ":key:trig%50"; end
      def p_function; write ':key:+function'; end
      def n_function; write ':key:-function'; end
    end
  end
end